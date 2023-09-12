
;; offspring-will
;; Smart contract that allows parents to create & fund wallets unlockable only by an assigned off-spring
;; Written by Mansa Souley

;; Offspring Wallet
;; This our main map that is created & funded by a parent, & only unlockable by an assigned offspring(principal)
;; Principal -> {offspring-principal: principal, offspring-dob: uint, balance: (optinal uint)}
;; 1. Create wallet
;; 2. Fund wallet
;; 3. Claim wallet
    ;; A. OffSpring
    ;; B. Parent/Admin

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Deployer
(define-constant deployer tx-sender)

;; Contract
(define-constant contract (as-contract tx-sender))

;; create Offspring wallet fee
(define-constant create-wallet-fee u5000000)

;; Add Offspring Wallet Funds fee
(define-constant add-wallet-funds-fee u2000000)

;; Min. Add Offspring Wallet Funds amount
(define-constant min-add-wallet-amount u5000000)

;; Early Withdrawal fee (10%)
(define-constant early-withdrawal-fee u10)

;; Normal Withdrawal fee (2%)
(define-constant normal-withdrawal-fee u2)

;; 18 years in Blockheight (18 years * 365 *144 blocks/day)
(define-constant eighteen-years-in-block-height (* u18 (* u365 u144)))

;; Admin list of principals
(define-data-var admin-list (list 10 principal) (list tx-sender))

;; Total Fees Earned
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

;; Get Offspring Principal
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

;; Get earned fees
(define-read-only (get-earned-fees) 
    (var-get total-fees-earned)
)

;; Get STX in Contract
(define-read-only (get-contract-stx-balance) 
    (stx-get-balance contract)
)

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Parent Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;



;; Create wallet
;; @desc - creates new offspring wallet new parent (no initial deposit required)
;; @param - new-offspring-principal: principal, new-offspring-dob: uint, balance
(define-public (create-wallet (new-offspring-principal principal) (new-offspring-dob uint) ) 
    (let 
        (
            ;; Local vars here
            (current-total-fees (var-get total-fees-earned))
            (new-total-fees (+ current-total-fees create-wallet-fee))
            
        ) 
        ;; Assert that map-get? offspring-wallet is-none
        (asserts! (is-none (get-offspring-wallet tx-sender))  (err "offspring-wallet-already-exists"))
        
        ;; Assert  that new-offspring-dob is at least higher than block-height - 18 years of blocks
        (asserts! (> (+ new-offspring-dob eighteen-years-in-block-height)  block-height) (err "You too old!"))

        ;; Assert that new-offspring-principal is Not an admin or tx-sender
        (asserts! (or 
                    (is-none (index-of (var-get admin-list) new-offspring-principal)) 
                    (not (is-eq new-offspring-principal tx-sender))
                   ) 
                   (err "err-invalid-offspring-principal")
        )

        ;; Pay create-wallet-fee in stx
        (unwrap! (stx-transfer? create-wallet-fee tx-sender deployer) (err "err-stx-transfer-wallet-fee"))

        ;; Var-get total-fees
        (var-set total-fees-earned new-total-fees)

        ;; Map-set offspring-wallet
        (ok (map-set offspring-wallet tx-sender {
            offspring-principal: new-offspring-principal, 
            offspring-dob: new-offspring-dob, 
            balance: u0
        }))
        
    )
)
;; (define-map offspring-wallet principal { 
;;     offspring-principal: principal, 
;;     offspring-dob: uint, 
;;     balance: uint
;;  })
;; Fund Wallet
;; @desc - allows anyone to fund an existing wallet
;; @param - parent: principal, amount: uint
(define-public (fund-wallet (parent principal) (amount uint)) 
    (let 
        (
            (current-offspring-wallet (unwrap! (map-get? offspring-wallet parent) (err "err-no-offspring-wallet")))
            (current-offspring-wallet-balance (get balance current-offspring-wallet))
            (new-offspring-wallet-balance (+ amount current-offspring-wallet-balance))
            (current-total-fees (var-get total-fees-earned))
            (new-total-fees (+ current-total-fees min-add-wallet-amount))
        ) 
        ;; Assert that amount is higher than min-add-wallet-amount ()
        (asserts! (> amount min-add-wallet-amount) (err "err-not-enough-stx"))

        ;; Send stx (amount - fee) to contract
        (unwrap! (stx-transfer? (- amount add-wallet-funds-fee) tx-sender contract) (err "err-sending-stx-to-contract"))

        ;; Send stx (fee) to deployer
        (unwrap! (stx-transfer? add-wallet-funds-fee tx-sender deployer) (err "err-sending-stx-to-deployer"))

        ;; Var-set total-fees
        (var-set total-fees-earned new-total-fees)

        ;; Map-set current offspring-wallet by merging with old balance + amount
        (ok (map-set offspring-wallet parent
            (merge 
                current-offspring-wallet
                { balance: new-offspring-wallet-balance}
            )        
        ))

        
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Offspring Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (define-map offspring-wallet principal { 
;;     offspring-principal: principal, 
;;     offspring-dob: uint, 
;;     balance: uint
;;  })

;; Claim Wallet
;; @desc - allows offspring to claim wallet once & once only
;; @param - parent: principal
(define-public (claim-wallet (parent principal)) 
    (let 
        (
            (current-offspring-wallet (unwrap! (map-get? offspring-wallet parent) (err "err--no-offspring-wallet")))
        
        )

        ;; Assert tx-sender is-eq to offspring-principal

        ;; Assert that block-height => 18 years 

        ;; send stx(amount - withdrawal fee) to offspring wallet

        ;; send stx withdrawal to deployer

        ;; Delete offspring-wallet map

        ;; Update total-fees-earned
        
        (ok false)
    )

)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Emergency Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Emergengy Claim
;; @desc - allows either parent or and admin to withdraw all stx (minus early withdrawal fee), back to parent & remove wallet
;; @param - parent: principal
(define-public (emergency-claim (parent principal)) 
    (let 
        (
            (current-offspring-wallet (unwrap! (map-get? offspring-wallet parent) (err "err--no-offspring-wallet")))
        ) 

        ;; Assert that tx-sender is parent or admin

        ;; Assert that block-height is Not 18 years in block later than offspring-dob

        ;; Send stx (amount - early-withdrawal-fee) to offspring

        ;; Send stx early-withdrawal to deployer

        ;; Delete offspring-wallet map

        ;; Update total-fees-earned
        
        (ok false)
    )

)


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Admin Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Add admin
;; @desc - function to add an admin to the existing admins list
;; @param - new-admin: principal
(define-public (add-admin (new-admin principal)) 
    (let 
        (
            (test false)
        ) 
        ;; Assert that tx-sender is parent or admin

        ;; Assert that admin is NOT already an admin

        ;; Map-set  append new admin

        (ok test)

    )
)

;; Remove Admin
;; @desc - function that allows the parent or admin to remove an admin
;; @param - admin: principal
(define-public (remove-admin (removed-admin principal)) 
    (let 
        (
            (test false)
        ) 
        ;; Assert that tx-sender is parent or admin

        ;; Assert that removed-admin is an admin

        ;; Map-set  remove admin from admin list

        (ok test)

    )
)