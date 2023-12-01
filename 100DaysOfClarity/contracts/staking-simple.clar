;; Staking - Simple
;; A barebones simple staking contract
;; User stakes "simple-nft" in exchange for "clarity-token"
;; Written by Mansa Souley
;; Day 80

;; Staking
;; User earns 1 CT per block staked

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; NFT status - map that keeps track of the status of an NFT
(define-map nft-status uint {last-staked-or-claimed: (optional uint), staker: principal})

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
            (current-item-status (default-to {last-staked-or-claimed: (some block-height), staker: tx-sender} (map-get? nft-status item)))
            (current-item-height (get last-staked-or-claimed current-item-status))
        )

        (- block-height (default-to u0 current-item-height))
    )
)


;; Check NFT stake status
;; @desc - Read-only function that gets the current stake status (aka nft-status)
;; @param 0 Item (uint), NFT identifier that we are checking status
(define-read-only (get-stake-status (item uint)) 
    (map-get? nft-status item)
)


;; Check principal reward rate
;; @desc - Read-only function that ggets the current total reward rate for tx-sender
(define-read-only (get-reward-rate) 
    (len (default-to (list ) (map-get? user-stakes tx-sender)))
)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Core Writing Fnc ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;


;; Stake NFT
;; @desc -Function to stake an unstaked nft-a item
;; @param - Item (uint), NFT identifier for item submitted for staking
(define-public (stake-nft (item uint)) 
    (let
        (
            (current-nft-owner (unwrap! (contract-call? .nft-simple get-owner item) (err "err-not-item-minted")))
            (current-user-stakes (default-to (list) (map-get? user-stakes tx-sender)))
        )

        ;; Assert that user owns the NFT submitted
        (asserts! (is-eq (some tx-sender) current-nft-owner) (err "err-not-nft-owner"))

        ;; Assert that NFT submitted is not already staked
        ;; Assert that last-claimed-or-staked is-none
        (asserts! (or 
                     (is-none (map-get? nft-status item)) 
                     (is-none (get last-staked-or-claimed (default-to {last-staked-or-claimed: none, staker: tx-sender} (map-get? nft-status item))))
                   ) 
                   (err "err-nft-already-staked")
        )

        ;; Stake NFT Custodially -> Transfer NFT from tx-sender to contract
        (unwrap! (contract-call? .nft-simple transfer item tx-sender (as-contract tx-sender)) (err "err-transferring-nft"))

        ;; Update NFT-status map
        (map-set nft-status item {last-staked-or-claimed: (some block-height), staker: tx-sender})

        ;; Update user-stakes map
        (ok (unwrap! (as-max-len? (append current-user-stakes item) u100) (err "err-user-stakes-overflow")))
    )
)


;; Unstake NFT
;; @desc - function to unstake a staked NFT
;; @param - Item (uint), NFT identifer for unstaking item
(define-public (unstake-nft (item uint)) 
    (let
        (
            (current-nft-status (unwrap! (map-get? nft-status item) (err "err-nft-not-staked")))
            (current-user-stakes (unwrap! (map-get? user-stakes tx-sender) (err "err-user-has-no-stakes")))
        )

        ;; Asserts that item is staked
        (asserts! (is-some (get last-staked-or-claimed current-nft-status)) (err "err-nft-not-staked"))
        
        ;; Asserts that tx-sender is the previous staker

        ;; Transfer NFT from contract to tx-sender/staker

        ;; If unclaimed balanced > 0
            ;; Send unclaimed balanced
            ;; Don't send

        ;; Update NFT-status map

        ;; Update user-stakes map

        (ok false)
    )
)

;; Claim CT Reward
;; @desc - Function to claim un-claimed / earned CT
;; @param - Item (uint), NFT identifier for claiming
(define-public (claim-reward (item uint)) 
    (let
        (

        )

        ;; Assert that item is actively staked

        ;; Assert that claimable balance > 0

        ;; Assert that tx-sender is staker in the stake-status map

        ;; Calculate reward & mint from FT contract

        ;; Update nft-status map

        (ok false)
    )
)

