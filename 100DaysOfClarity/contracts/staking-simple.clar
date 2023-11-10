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


;;;;;;;;;;;;;;;;;;;
;;;; Read-Only ;;;;
;;;;;;;;;;;;;;;;;;;

;; Check unclaimed balance

;; Check NFT stake status

;; Check principal reward rate

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Core Writing Fnc ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Stake NFT

;; Unstake NFT

;; Claim FT Reward