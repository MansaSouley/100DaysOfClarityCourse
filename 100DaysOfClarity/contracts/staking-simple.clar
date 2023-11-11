;; Staking - Simple
;; A barebones simple staking contract
;; User stakes "simple-nft" in exchange for "clarity-token"
;; Written by Mansa Souley
;; Day 80

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; NFT status - map that keeps track of the status of an NFT
(define-map nft-status uint {staked: bool, last-staked-or-claimed: uint})

;; Map that keeps track of all of a users stakes
(define-map user-stakes principal (list 100 uint))


;;;;;;;;;;;;;;;;;;;
;;;; Read-Only ;;;;
;;;;;;;;;;;;;;;;;;;

;; Check unclaimed balance
(define-read-only (get-unclaimed-balance) 
    (let
        (
            (current-user-stakes (unwrap! (map-get? user-stakes tx-sender) (err "err-no-stakes")))
            (current-user-height-differences (map map-from-ids-to-height-differences current-user-stakes))
        )

        (ok (fold + current-user-height-differences u0))
    )
)

;; Private function that maps from list of ids to list of height differences
(define-private (map-from-ids-to-height-differences (item uint)) 
    (let
        (
            (current-item-status (default-to {staked: true, last-staked-or-claimed: block-height} (map-get? nft-status item)))
            (current-item-height (get last-staked-or-claimed current-item-status))
        )

        (- block-height current-item-height)
    )
)


;; Check NFT stake status



;; Check principal reward rate



;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Core Writing Fnc ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Stake NFT

;; Unstake NFT

;; Claim FT Reward