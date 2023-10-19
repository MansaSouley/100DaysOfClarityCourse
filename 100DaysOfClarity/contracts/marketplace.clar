
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
(define-public (submit-collection (nft-colection <nft>) (royalty-percent uint) (collection-name (string-ascii 64))) 
    (let
        (   

        )

        ;; Assert that collection is not already whitelisted my making sure it's is-none

        ;; Assert that tx-sender is deployer of nft parameter

        ;; Map set whitelisted-collections to false

        (ok false)
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

        )

        ;; Assert that collection is whitelisted

        ;; Assert that tx-sender is admin       

        ;; Map-set / merge existing collection tuple w/ true as whitelisted

        (ok false)
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
