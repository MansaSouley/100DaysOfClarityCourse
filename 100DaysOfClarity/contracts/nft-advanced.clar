;; NFT Advanced
;; An advanced NFT that has all modern functions required for a high quality NFT project
;; Written by Mansa Souley

;; Unique Properties & Features
;; 1. Implements non-custodial marketplace functions
;; 2. Implements a whitelist minting system
;; 3. Option to mint 1,2 or 5
;; 4. Multiple admin system


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define NFT
(define-non-fungible-token advanced-nft uint)

;; Adhere to SIP09
;;(impl-trait .sip-09.nft-trait)

;; Collection Limit
(define-constant collection-limit u10)

;; Root URI
(define-constant collection-root-uri "ipfs://ipfs/QmYcrELFT5dsdes567trhsDSEDFVhesn4Idnfse/")

;; Collection Index
(define-data-var collection-index uint u1)

;; NFT Price
(define-constant advanced-nft-price u10000000)

;; Admin Deployer
(define-constant deployer  (as-contract tx-sender))

;; admin list
(define-data-var admins (list 10 principal) (list tx-sender))

;; Marketplace map
(define-map market uint {price: uint, owner: principal})

;; Whitelist map
(define-map whitelist-map principal uint)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SIP-09 Functions  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get last token Id
(define-public (get-last-token-id) 
    (ok (var-get collection-index))
)

;; Get token uri
(define-public (get-token-uri (id uint)) 
    (ok 
        (some (concat 
            collection-root-uri 
            (concat 
                (uint-to-ascii id)
                ".json"
            )  
        ))
    )
)

;; Get token owner
(define-public (get-owner (id uint)) 
    (ok (nft-get-owner? advanced-nft id))
)

;; Transfer token
(define-public (transfer (id uint) (sender principal) (recipient principal)) 
    (begin
        (asserts! (is-eq sender tx-sender) (err u1))
        (if (is-some (map-get? market id)) 
            (map-delete market id) 
            false
        )
        (nft-transfer? advanced-nft id sender recipient)    
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Noncustodial Funcs  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; List in ustx
(define-public (list-in-ustx (item uint) (price uint)) 
    (let
        (
            (nft-owner (unwrap! (nft-get-owner? advanced-nft item) (err "err-nft-doesnt-exist")))
        )
            ;; Assert that tx-sender is-eq to nft-owner
            (asserts! (is-eq tx-sender nft-owner) (err "err-not-owner"))

            ;; Map set market with new NFT
            (ok (map-set market item {price: price, owner: tx-sender}))    
    )
)

;; Unlist in ustx
(define-public (unlist-in-ustx (item uint)) 
    (let
        (
            (current-listing (unwrap! (map-get? market item) (err "err-nft-not-listed")))
            (current-price (get price current-listing))
            (current-owner (get owner current-listing))
        )

            ;; Assert that tx-sender is current-owner
            (asserts! (is-eq tx-sender current-owner) (err "err-not-owner"))

            ;; Map delete existing listing
            (ok (map-delete market item))
    )
)
;; Buy in ustx
(define-public (buy-in-ustx (item uint)) 
    (let
        (
            (current-listing (unwrap! (map-get? market item) (err "err-nft-not-listed")))
            (current-price (get price current-listing))
            (current-owner (get owner current-listing))
        )
            ;; Tx-sender buys by transfering STX
            (unwrap! (stx-transfer? current-price tx-sender current-owner) (err "err-stx-transfer"))

            ;; Transfer NFT to new-buyer
            (unwrap! (nft-transfer? advanced-nft item current-owner tx-sender) (err "err-nft-transfer"))

            ;; Map-delete the listing
            (ok (map-delete market item))
    )
)

;; Check listing
(define-read-only (check-listing (item uint)) 
    (map-get? market item)
)

;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Mint Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Mint 1
(define-public (mint-one) 
    (let
        (
            (current-index (var-get collection-index))
            (next-index (+ current-index u1))
            (whitelist-mints (unwrap! (map-get? whitelist-map tx-sender) (err "err-not-whitelisted")))
        )

        ;; Assert that collection is not minted out (current-index < collection-limit)
        (asserts! (< current-index collection-limit) (err "err-minted-out"))

        ;; Assert that tx-sender has mints left
        (asserts! (> whitelist-mints u0) (err "err-no-whitelist-mints-left"))

        ;; Pay for mint
        (unwrap! (stx-transfer? advanced-nft-price tx-sender deployer) (err "err-stx-transfer"))
        
        ;; Mint
        (unwrap! (nft-mint? advanced-nft current-index tx-sender) (err "err-minting"))

        ;; Var-set collection-index to next-index
        (var-set collection-index next-index)

        ;; map-set whitelist-mint to whitelist-mints - 1
        (ok (map-set whitelist-map tx-sender (- whitelist-mints u1)))
    )
)
;; Mint 2
(define-public (mint-two) 
    (begin 
        (unwrap! (mint-one) (err "err-mint-1"))
        ( ok (unwrap! (mint-one) (err "err-mint-2")))
    )
)

;; Mint 5
(define-public (mint-five) 
    (begin 
        (unwrap! (mint-one) (err "err-mint-1"))
        (unwrap! (mint-one) (err "err-mint-2"))
        (unwrap! (mint-one) (err "err-mint-3"))
        (unwrap! (mint-one) (err "err-mint-4"))
        ( ok (unwrap! (mint-one) (err "err-mint-5")))
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Whitelist Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add whitelist
(define-public (whitelist-principal (user principal) (mints uint)) 
    (let
        (
            (whitelist-mints (map-get? whitelist-map user))
        )

        ;; Assert that tx-sender is an admin
        (asserts! (is-some (index-of (var-get admins) tx-sender)) (err "err-user-not-admin"))
        
        ;; Assert that whitelist-mints is-none
        (asserts! (is-none whitelist-mints) (err "err-user-already-whitelisted"))

        ;; Map set the whitelist-map
        (ok (map-set whitelist-map user mints))        
    )
)

;; Check whitelist status
(define-read-only (whitelist-status (user principal)) 
    (map-get? whitelist-map user)
)

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Admin Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Add admin
(define-public (add-admin (new-admin principal)) 
    (let
        (
            (current-admins (var-get admins))
        )
        ;; Assert that tx-sender is admin
        (asserts! (is-some (index-of (var-get admins) tx-sender)) (err "err-user-not-admin"))

        ;; Assert that new-admin is not already admin
        (asserts! (is-none (index-of (var-get admins) new-admin)) (err "err-already-admin"))

        ;; Var-set admins by appending new-admin
        (ok (var-set admins ( unwrap! (as-max-len? (append current-admins new-admin) u10) (err "err-admin-overflow"))))
    )
)
;; Remove admin

;; Remove admin helper


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Helper Functions  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (uint-to-ascii (value uint))
  (if (<= value u9)
    (unwrap-panic (element-at "0123456789" value))
    (get r (fold uint-to-ascii-inner
      0x000000000000000000000000000000000000000000000000000000000000000000000000000000
      {v: value, r: ""}
    ))
  )
)

(define-read-only (uint-to-ascii-inner (i (buff 1)) (d {v: uint, r: (string-ascii 39)}))
  (if (> (get v d) u0)
    {
      v: (/ (get v d) u10),
      r: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get v d) u10))) (get r d)) u39))
    }
    d
  )
)