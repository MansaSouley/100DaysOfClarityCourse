
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
(define-map whitelisted-collections principal bool)

;; Whitelist collections
(define-map collection principal {
    name: (string-ascii 64),
    royalty-percent: uint,
    royalty-address: principal
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
    (map-get? whitelisted-collections nft-collection)
)

;; Get all listed items in a collection
(define-read-only (listed (nft-collection principal)) 
    (map-get? collection-listing nft-collection)
)

;; Get item status
(define-read-only (item (nft-collection principal) (nft-item uint)) 
    (map-get? item-status {collection: nft-collection, item: nft-item})
)


;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Buyer Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Buy item
;; @desc- function that allows a principal to purchase a listed NFT
;; @param - nft-collection:nft-trait, nft-item:uint
(define-public (buy-item (nft-collection <nft>) (nft-item uint)) 
    (let
        (

        )

        ;; Assert NFT collection is whitelisted


        ;; Assert that item is listed


        ;; Assert tx-sender is NOT owner

        ;; Send STX(price - royalty) to owner

        ;; Send STX(royalty) to artist/royalty-address

        ;; Transfer NFT from custodial/contract to buyer/NFT

        ;; Map-delete item-listing

        (ok false)
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

        )

        ;; Assert that tx-sender is current NFT owner

        ;; Assert that collection is whitelisted

        ;; Assert nft-item is NOT in collection-listings

        ;; Assert item-status is-none

        ;; Transfer NFT from tx-sender to contract

        ;; Map-set item-status w/ new price & owner (tx-sender)

        ;; Map-set collection-listing

        (ok false)
    )
)

;; Unlist item
(define-public (unlist-item (nft-collection <nft>) (nft-item uint)) 
    (let
        (

        )

        ;; Assert that current NFT owner is contract

        ;; Assert that item-status is-some

        ;; Assert that owner property from item-status tuple is tx-sender

        ;; Assert that uint is in collection-listing map

        ;; Transfer NFT back from contract to tx-sender/original owner

        ;; Map-set collection-listing (remove uint)

        ;; Map-set item-status (delete entry)
    
        (ok false)
    )    
)
;; change price
(define-public (change-price (nft-collection <nft>) (nft-item uint) (nft-price uint)) 
    (let
        (

        )

        ;; Assert nft-item is in collection-listing

        ;; Assert nft-item item-stats map-get is-some

        ;; Assert nft current owner is contract

        ;; Assert that tx-sender is Owner from item-status tuple

        ;; Map-set merge item-status with new price

        (ok false)
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Artist Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Submit collection

;; Change royalty address

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Whitelist Funcs ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Admin Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Accept or reject whitelisting

;; Add an admin

;; Remove an admin


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Helper Functions  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
