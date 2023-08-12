
;; offspring-will
;; Smart contract that allows parents to create & fund wallets unlockable only by an assigned off-spring
;; Written by Mansa Souley

;; Offspring Wallet
;; This our main map that is created & funded by a parent, & only unlockable by an assigned offspring(principal)
;; Principal -> {offspring-principal: principal, offspring-dob: uint, balance: (optinal uint)}

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;


;; create Offspring wallet fee
(define-constant create-wallet-fee u5000000)

;; Add Offspring Wallet Funds fee
(define-constant add-wallet-funds-fee u2000000)

;; Min. Add Offspring Wallet Funds fee
(define-constant min-create-wallet-fee u5000000)

;; Early Withdrawal fee (10%)
(define-constant early-withdrawal-fee u10)

;; Normal Withdrawal fee (2%)
(define-constant normal-withdrawal-fee u2)

;; Admin list of principals
(define-data-var admin-list (list 10 principal) (list tx-sender))

;; TOtal Fees Earned
(define-data-var total-fees-earned uint u0)

;; Offspring Wallet
(define-map offspring-wallet principal { 
    offspring-principal: principal, 
    offspring-dob: uint, 
    balance: uint
 })

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Read Functions  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Parent Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Offspring Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Write Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;
;;; Admin Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
