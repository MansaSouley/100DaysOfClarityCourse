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

;; admin list
(define-data-var admin (list 10 principal) (list tx-sender))

;; Marketplace map
(define-map market uint {price: uint, owner: principal})

;; Whitelist map
(define-map whitelist-map principal uint)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SIP-09 Functions  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get last token Id

;; Get token uri

;; Get token owner

;; Transfer token

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Noncustodial Funcs  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; List in ustx

;; Unlist in ustx

;; Buy in ustx

;; Check listing


;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Mint Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Mint 1

;; Mint 2

;; Mint 3


;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Whitelist Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add whitelist

;; Check whitelist status

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Admin Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Add admin

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