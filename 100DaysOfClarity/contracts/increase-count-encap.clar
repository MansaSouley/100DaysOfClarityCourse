(define-data-var counter uint u0)
(define-map counter-history uint {user: principal, count: uint})

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