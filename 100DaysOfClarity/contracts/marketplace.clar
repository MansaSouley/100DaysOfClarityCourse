
;; Marketplace
;; Simple NFT Marketplace
;; Written by Mansa Souley

;; Unique Properties
;; All Custodial
;; Multiple Admins
;; Collections *Have* To Be Whitelisted By Admins
;; Only STX (no FT)

;; Selling An NFT Lifecycle
;; Collection is submitted for whitelisting
;; Collection is approved or rejected 
;; NFT(s) are listed
;; NFT is purchased
;; STX is transferred 
;; NFT is transferred
;; Listing is deleted

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define the NFT trait we'll use throughout
(use-trait nft .sip-09.nft-trait)

;; All admins
(define-data-var admins (list 10 principal) (list tx-sender))

;; Whitelist collections
;;(define-map whitelisted-collections principal bool)

;; Whitelist collections
;; Is-none -> collection not submitted
;; False -> collection has not been approved by admin
;; True -> collection has been whitelisted by admin
(define-map collection principal {
    name: (string-ascii 64),
    royalty-percent: uint,
    royalty-address: principal,
    whitelisted: bool
})

;; List of all for sale in collection
(define-map collection-listing principal (list 10000 uint))

;; Item status
(define-map item-status {collection: principal, item: uint} {
    owner: principal,
    price: uint
})

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Read Functions  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Get collection whitelist status
(define-read-only (is-collection-whitelisted (nft-collection principal)) 
    (map-get? collection nft-collection)
)

;; Get all listed items in a collection
(define-read-only (listed (nft-collection principal)) 
    (map-get? collection-listing nft-collection)
)

;; Get item status
(define-read-only (item (nft-collection principal) (nft-item uint)) 
    (map-get? item-status {collection: nft-collection, item: nft-item})
)

;; Helper uint
(define-data-var helper-uint uint u0)

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Buyer Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Buy item
;; @desc- function that allows a principal to purchase a listed NFT
;; @param - nft-collection:nft-trait, nft-item:uint
(define-public (buy-item (nft-collection <nft>) (nft-item uint)) 
    (let
        (
            (current-collection (unwrap! (map-get? collection (contract-of nft-collection)) (err "err-collection-not-whitelisted")))
            (current-royalty-percent (get royalty-percent current-collection))
            (current-royalty-address (get royalty-address current-collection))
            (current-listing (unwrap! (map-get? item-status {collection: (contract-of nft-collection), item: nft-item}) (err "err-item-not-listed")))
            (current-collection-listings (unwrap! (map-get? collection-listing (contract-of nft-collection)) (err "err-collection-has-no-listings")))
            (current-listing-price (get price current-listing))
            (current-listing-royalty (/ (* current-royalty-percent current-listing-price) u100))
            (current-listing-owner (get owner current-listing))
        )       


        ;; Assert that item is listed
        (asserts! (is-some (index-of current-collection-listings nft-item)) (err "err-item-not-listed"))

        ;; Assert tx-sender is NOT owner
        (asserts! (not (is-eq tx-sender current-listing-owner)) (err "err-buyer-is-owner"))

        ;; Send STX(price) to owner
        (unwrap! (stx-transfer? current-listing-price tx-sender current-listing-owner) (err "err-stx-transfer-price"))
        
        ;; Send STX(royalty) to artist/royalty-address
        (unwrap! (stx-transfer? current-listing-royalty tx-sender current-royalty-address) (err "err-stx-transfer-royalty"))

        ;; Transfer NFT from custodial/contract to buyer/NFT
        (unwrap! (contract-call? nft-collection transfer nft-item (as-contract tx-sender) tx-sender) (err "err-nft-transfer"))
        
        ;; Map-delete item-listing
        (map-delete item-status {collection: (contract-of nft-collection), item: nft-item})

        ;; Filter out nft-item from collection-listing
        (var-set helper-uint nft-item)

        (ok (map-set collection-listing (contract-of nft-collection) (filter remove-uint-from-list current-collection-listings)))
    )
)


;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; owner Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; List item
;; @desc - func that allows an owner to list an NFT
;; @param - collection:<nft-trait>, item:uint, price:uint
(define-public (list-item (nft-collection <nft>) (nft-item uint) (nft-price uint)) 
    (let
        (
           (current-nft-owner (unwrap! (contract-call? nft-collection get-owner nft-item) (err "err-get-owner")))
           (current-collection-listing (unwrap! (map-get? collection-listing (contract-of nft-collection)) (err "err-no-collection-listing")))
           (current-collection (unwrap! (map-get? collection (contract-of nft-collection)) (err "err-collection-not-whitelisted")))
           (current-collection-whitelist (get whitelisted current-collection))
        )

        ;; Assert that tx-sender is current NFT owner
        (asserts! (is-eq current-nft-owner (some tx-sender)) (err "err-not-nft-owner"))
        
        ;; Assert that collection is whitelisted
        (asserts! current-collection-whitelist (err "err-collection-not-whitelisted"))
                
        ;; Assert item-status is-none
        (asserts! (is-none (map-get? item-status {collection: (contract-of nft-collection), item: nft-item})) (err "err-item-is-listed"))

        ;; Transfer NFT from tx-sender to contract
        (unwrap! (contract-call? nft-collection transfer nft-item tx-sender (as-contract tx-sender)) (err "err-nft-transfer") )

        ;; Map-set item-status w/ new price & owner (tx-sender)
        (map-set item-status {collection: (contract-of nft-collection), item: nft-item} {
            owner: tx-sender,
            price: nft-price
        })
        
        ;; Map-set collection-listing
        (ok (map-set collection-listing (contract-of nft-collection) (unwrap! (as-max-len? (append current-collection-listing nft-item)  u10000) (err "err-collection-listing-overflow")))) 
    )
)

;; Unlist item
(define-public (unlist-item (nft-collection <nft>) (nft-item uint)) 
    (let
        (
            (current-collection (unwrap! (map-get? collection (contract-of nft-collection)) (err "err-collection-not-whitelisted")))
            (current-royalty-percent (get royalty-percent current-collection))
            (current-royalty-address (get royalty-address current-collection))
            (current-listing (unwrap! (map-get? item-status {collection: (contract-of nft-collection), item: nft-item}) (err "err-item-not-listed")))
            (current-collection-listings (unwrap! (map-get? collection-listing (contract-of nft-collection)) (err "err-collection-has-no-listings")))
            (current-listing-price (get price current-listing))
            (current-listing-royalty (/ (* current-royalty-percent current-listing-price) u100))
            (current-listing-owner (get owner current-listing))
            (current-nft-owner (unwrap! (contract-call? nft-collection get-owner nft-item) (err "err-get-owner")))
        )

        ;; Assert that current NFT owner is contract
         (asserts! (is-eq (some (as-contract tx-sender)) current-nft-owner) (err "err-contract-not-owner"))

        ;; Assert that tx-sender is-eq current-listing-owner
        (asserts! (is-eq current-listing-owner tx-sender) (err "err-not-listing-owner"))

        ;; Assert that uint is in collection-listing map
        (asserts! (is-some (index-of current-collection-listings nft-item)) (err "err-item-not-in-listings"))

        ;; Transfer NFT back from contract to tx-sender/original owner
        (unwrap! (contract-call? nft-collection transfer nft-item (as-contract tx-sender) tx-sender ) (err "err-returning-nft"))

         ;; Map-delete item-listing
        (map-delete item-status {collection: (contract-of nft-collection), item: nft-item})

        ;; Filter out nft-item from collection-listing
        (var-set helper-uint nft-item)

        (ok (map-set collection-listing (contract-of nft-collection) (filter remove-uint-from-list current-collection-listings)))
    )    
)
;; change price
(define-public (change-price (nft-collection <nft>) (nft-item uint) (nft-price uint)) 
    (let
        (
            (current-collection (unwrap! (map-get? collection (contract-of nft-collection)) (err "err-collection-not-whitelisted")))
            (current-royalty-percent (get royalty-percent current-collection))
            (current-royalty-address (get royalty-address current-collection))
            (current-listing (unwrap! (map-get? item-status {collection: (contract-of nft-collection), item: nft-item}) (err "err-item-not-listed")))
            (current-collection-listings (unwrap! (map-get? collection-listing (contract-of nft-collection)) (err "err-collection-has-no-listings")))
            (current-listing-price (get price current-listing))
            (current-listing-royalty (/ (* current-royalty-percent current-listing-price) u100))
            (current-listing-owner (get owner current-listing))
            (current-nft-owner (unwrap! (contract-call? nft-collection get-owner nft-item) (err "err-get-owner")))
        )

       ;; Assert that item is listed
        (asserts! (is-some (index-of current-collection-listings nft-item)) (err "err-item-not-listed"))        

        ;; Assert nft current owner is contract
        (asserts! (is-eq (some (as-contract tx-sender)) current-nft-owner) (err "err-contract-not-owner"))

        ;; Assert that tx-sender is Owner from item-status tuple
        (asserts! (is-eq tx-sender current-listing-owner) (err "err-not-listed-owner"))

        ;; Map-set merge item-status with new price
        (ok (map-set item-status {collection: (contract-of nft-collection), item: nft-item} 
            (merge 
                current-listing
                {price: nft-price}
            )
        ))       
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Artist Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Submit collection
(define-public (submit-collection (nft-collection <nft>) (royalty-percent uint) (collection-name (string-ascii 64))) 
    (begin
        ;; Assert that collection & collection-listing is-none
        (asserts! (and 
                        (is-none (map-get? collection-listing (contract-of nft-collection))) 
                        (is-none (map-get? collection (contract-of nft-collection)))
                   ) 
                (err "err-collection-already-exits")
        )

        ;; Assert that royalty is greater than 1 & less 20
        (asserts! (and (> royalty-percent u0) (< royalty-percent u21)) (err "err-bad-royalty"))

        ;; Map set whitelisted-collections to false
        (ok (map-set collection (contract-of nft-collection) {
            name: collection-name,
            royalty-percent: royalty-percent,
            royalty-address: tx-sender,
            whitelisted: false
        }))        
    )
)

;; Change royalty address
(define-public (change-royalty-address (nft-collection principal) (new-royalty principal)) 
    (let
        (

        )

        ;; Assert that collection is whitelisted

        ;; Assert that tx-sender is current royalty-address

        ;; Map-set / merge existing collection tuple w/ new royalty-address

        (ok false)
    )

)

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Admin Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Accept or reject whitelisting
(define-public (whitelisting-approval (nft-collection principal) (approval-boolean bool)) 
    (let
        (
            (current-collection (unwrap! (map-get? collection nft-collection) (err "err-collection-not-whitelisted")))
        )       

        ;; Assert that tx-sender is admin       
        (asserts! (is-some (index-of (var-get admins) tx-sender)) (err "err-not-admin"))

        ;; Map-set / merge existing collection tuple w/ true as whitelisted
        (map-set collection nft-collection 
                (merge 
                    current-collection
                    {whitelisted: true}    
                )
        )

        ;; Map-set collection-listings
        (ok (map-set collection-listing nft-collection (list )))
    )
)
;; Add an admin
(define-public (add-admin (new-admin principal)) 
    (let
        (
            ;;(current-admins (var-get admins))
        )
        ;; Assert that tx-sender is admin
        ;;(asserts! (is-some (index-of (var-get admins) tx-sender)) (err "err-user-not-admin"))

        ;; Assert that new-admin is not already admin
        ;;(asserts! (is-none (index-of (var-get admins) new-admin)) (err "err-already-admin"))

        ;; Var-set admins by appending new-admin
        ;;(ok (var-set admins ( unwrap! (as-max-len? (append current-admins new-admin) u10) (err "err-admin-overflow"))))

        (ok false)
    )
)

;; Remove an admin
(define-public (remove-admin (admin principal)) 
    (let
        (

        )

        ;; Asset that tx-sender is admin

        ;; Assert that remove-admin exists

        ;; Var-set  helper principal

        ;; Filter-out remove admin

        (ok false)
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Helper Functions  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Filter uint from list
(define-private (remove-uint-from-list (item-helper uint)) 
    (not (is-eq item-helper  (var-get helper-uint)))
)