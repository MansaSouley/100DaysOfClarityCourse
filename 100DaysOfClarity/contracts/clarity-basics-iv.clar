
;; Clarity Basics IV
;; Reviewing more Clarity fundamentals
;; Written by Souley

;; Day 26.5 - Let
(define-data-var counter uint u0)
(define-map counter-history uint {user: principal, count: uint})

(define-public (increase-count-begin (increase-by uint)) 
    (begin 
        ;; Assert that tx-sender is not previous counter-history
        (asserts! (not (is-eq (some tx-sender) (get user (map-get? counter-history (var-get counter))))) (err u0))
    
        ;; Var-set counter-history
        (map-set counter-history (var-get counter) {
            user: tx-sender, 
            count: (+ increase-by (get count (unwrap! (map-get? counter-history (var-get counter)) (err u1))))
        })

        ;; Var-set counter
        (var-set counter (+ increase-by (var-get counter)))

        (ok true)
    )
)

;; (let
;;      (
            ;; local vars are created/stored
;;          (test-var u1)
;;      )
;;      body (function 1)
;;      (function 2)
;; )

(define-public (increase-count-let (increase-by uint)) 
    (let 
        (
            (current-counter (var-get counter))
            (current-counter-history (default-to {user: tx-sender, count: u0}  (map-get? counter-history current-counter)))
            (previous-counter-user (get user current-counter-history))
            (previous-counter-count (get count current-counter-history))
        ) 
        ;; Assert that tx-sender is not previous counter-history
        (asserts! (not (is-eq  tx-sender previous-counter-user)) (err u0))

        ;; Var-set counter-history
        (map-set counter-history current-counter {
            user: tx-sender, 
            count: (+ increase-by previous-counter-count)
        })

        ;; Var-set counter
        (ok (var-set counter (+ u1 current-counter)))        
    )
)

;; Day 32 - Syntax
;; Trailing (heavy parenthesis that trail)
;; Encapsulated (highlights internal functions)
(define-public (increase-count-trailing (increase-by uint))
    
    (begin  
        ;; Assert that tx-sender is not previous counter-history
        (asserts! 
            (not (is-eq 
                (some tx-sender) (get user (map-get? counter-history (var-get counter))))) (err u0))
     
      ;; Var-set counter
        (ok 
            (var-set counter 
                (+ (var-get counter) u1)))
    )
)

(define-public (increase-count-encapsulation (increase-by uint)) 
    
    (begin  
        ;; Assert that tx-sender is not previous counter-history
        (asserts! 
            (not 
                (is-eq 
                    (some tx-sender) 
                    (get 
                        user 
                        (map-get? counter-history (var-get counter))
                    )
                )
            )
            (err u0)
        )

        ;; Var-set counter
        (ok 
            (var-set counter 
                (+ 
                    (var-get counter)
                    u1
                )
            )
        )       
    )
)

;; Day 33 - Stx-Transfer
(define-public (send-stx-single) 
    (stx-transfer? u1000000 tx-sender 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
)

(define-public (send-stx-double) 
    (begin  
        (unwrap! (stx-transfer? u1000000 tx-sender 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5) (err u0))
        (stx-transfer? u1000000 tx-sender 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
    )
)

;; Day 34 - Stx-get-balance & Burn
;; Get balance
;; Stx burn
(define-read-only (balance-of) 
    (stx-get-balance tx-sender)
)

(define-public (send-stx-balance) 
    (stx-transfer? (stx-get-balance tx-sender) tx-sender 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
)

(define-public (burn-some (amount uint)) 
    (stx-burn? amount tx-sender)
)

(define-public (burn-half-of-balance) 
    (stx-burn? (/ (stx-get-balance tx-sender) u2)  tx-sender)
) 

;; Day 35 - Block-Height
(define-read-only (read-current-height) 
    block-height
)

(define-constant day-in-blocks u144)
(define-read-only (has-a-day-passed) 
    (if (> block-height day-in-blocks)  
        true 
        false
    )
)

(define-read-only (has-a-week-passed) 
    (if (> block-height (* day-in-blocks u7))  
        true 
        false
    )
)

;; Day 36 - As-Contract

;; Principal -> Contract
(define-public (send-to-contract-literal) 
    (stx-transfer? u1000000 tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.clarity-basics-iv)
)

(define-public (send-to-contract-context) 
    (stx-transfer? u1000000 tx-sender (as-contract tx-sender))
)

;; Contract -> Principal
(define-public (send-as-contract) 
    (as-contract (stx-transfer? u1000000 tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM))
)

