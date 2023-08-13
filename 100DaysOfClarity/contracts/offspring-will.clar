
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

;; 18 years in Blockheight (18 years * 365 *144 blocks/day)
(define-constant eighteen-years-in-block-height (* u18 (* u365 u144)))

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

;; Get Offspring wallet
(define-read-only (get-offspring-wallet (parent principal)) 
    (map-get? offspring-wallet parent)
)

;; Get Offspring Wallet Balance
(define-read-only (get-offspring-wallet-balance (parent principal)) 
    (default-to u0 (get balance (map-get? offspring-wallet parent)))
)

;; Get Offsrping Principal
(define-read-only (get-offspring-wallet-principal (parent principal)) 
    (get offspring-principal (map-get? offspring-wallet parent))
)

;; Get Offspring dob
(define-read-only (get-offspring-wallet-dob (parent principal)) 
    (get offspring-dob (map-get? offspring-wallet parent))
)

(define-read-only (get-offspring-wallet-unlock-height (parent principal)) 
    (let 
        (   
            ;; vars - dob
            (offspring-dob (unwrap! (get-offspring-wallet-dob parent) (err u1)))
        ) 
        
        (ok (+ offspring-dob eighteen-years-in-block-height))
        
    )
)

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
