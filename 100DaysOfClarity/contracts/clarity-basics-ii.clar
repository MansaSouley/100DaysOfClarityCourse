;; Clarity basics ii
;; Day 8 - Optionals & Parameters
(define-read-only (show-some-i) 
    (some u2)
)

(define-read-only (show-none-i) 
    none
)

(define-read-only (params (num uint) (string (string-ascii 48)) (boolean bool)) 
    num
)

(define-read-only (params-optional (num (optional uint)) (string (optional (string-ascii 48))) (boolean (optional bool))) 
    num
)

;; Day 9 - Optionals part 2
(define-read-only (is-some-example (num (optional uint))) 
    (is-some num)
)

(define-read-only (is-none-example (num (optional uint))) 
    (is-some num)
)

(define-read-only (params-optional-and (num (optional uint)) (string (optional (string-ascii 48))) (boolean (optional bool))) 
    (and 
        (is-some num)
        (is-some string)
        (is-some boolean)
    )    
)

;; Day 10 - Constants and Intro to Variables
(define-constant fav-num u10 )
(define-constant fav-string "hello")
(define-data-var fav-num-var uint u15)
(define-data-var your-name (string-ascii 30) " Souleymane bah")


(define-read-only (show-constant) 
    fav-num    
)

(define-read-only (show-constant-var) 
    (var-get fav-num-var)    
)

(define-read-only (show-var-double)     
    (* u2 (var-get fav-num-var))  
)

(define-read-only (say-hello)    
    (concat fav-string (var-get your-name))  
)

;; Day 11 - Public Functions and Responses
(define-public (change-name (new-name (string-ascii 24))) 
    (ok (var-set your-name new-name))
)

(define-public (change-fav-num (new-num uint)) 
    (ok (var-set fav-num-var new-num))
)

;; Day 12 - Tuples & Merging
(define-read-only (read-tuple-i) 
    {
        user: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
        user-name: "Souleymane",
        user-balance: u10,
    }
)

(define-public (write-tuple-i (new-user-principal principal) (new-user-name (string-ascii 24)) (new-user-balance uint)) 
    (ok {
        user: new-user-principal,
        user-name: new-user-name,
        user-balance: new-user-balance
    })
)

(define-data-var original { user: principal, user-name: (string-ascii 24), user-balance: uint} 
    {
        user: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM,
        user-name: "Souleymane",
        user-balance: u10,
    }
)

(define-read-only (read-original) 
    (var-get original)
)

(define-public (merge-principal (new-user-principal principal)) 
    (ok 
        (merge 
            (var-get original)
            {user-principal: new-user-principal}
        )
    )
)

(define-public (merge-user-name (new-user-name (string-ascii 24))) 
     (ok 
        (merge 
            (var-get original)
            {user-name: new-user-name}
        )
    )
)

(define-public (merge-user-balance (new-user-balance uint)) 
        (ok 
            (merge 
                (var-get original)
                {user-balance: new-user-balance}
            )
        )    
)

(define-public (merge-all (new-user-principal principal) (new-user-name (string-ascii 24)) (new-user-balance uint)) 
    (ok 
        (merge 
            (var-get original)
            {
                user-principal: new-user-principal,
                user-name: new-user-name,
                user-balance: new-user-balance
            }
        )
    )
)

;; Day 13 - Tx-Sender & Is-Eq

(define-read-only (read-tx-sender) 
    tx-sender
)

(define-constant admin 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
(define-read-only (check-admin) 
    (is-eq admin tx-sender)
)

;; Day 14 - Conditionals I
(define-read-only (show-asserts (num uint)) 
    (ok (asserts! (> num u2) (err u1)))
)

(define-constant err-too-large (err u1))
(define-constant err-too-small (err u2))
(define-constant err-not-auth (err u3))
(define-constant admin-one tx-sender)

(define-read-only (check-admin-ii) 
    (ok (asserts! (is-eq tx-sender admin-one) err-not-auth))
)

;; Day 15 - Begin
;; Set & say hello
;; Counter by even

(define-data-var hello-name (string-ascii 48) "Alice")
;; @desc - This function allows a user to provide a name, which if different, changes a name variable & returns "hello new name"
;; @param - new-name: (string-ascii 48) that represents the new name
(define-public (set-and-say-hello (new-name (string-ascii 48))) 
    (begin 
        ;;Assert that name is not empty
        (asserts! 
            (not (is-eq "" new-name)) (err u1)
        )

        ;; Assert that name is not the same as the current name
        (asserts! (not (is-eq (var-get hello-name) new-name)) (err u2))
        
        ;; Set the name
        (var-set hello-name new-name)

        ;; Return the new name
        (ok (concat "Hello " (var-get hello-name)))
        
    )
)

(define-read-only (read-hello-name) 
    (var-get hello-name)
)

;; @desc - This function allows a user to provide a number, which if even, increments a counter variable & returns the counter
;; @param - num: uint that the user submits to add to the counter

(define-data-var counter uint u0)
(define-read-only (read-counter) 
    (var-get counter)
)

(define-public (increment-counter-event (add-num uint)) 
    (begin
        ;; Assert that the number is even
        (asserts! (is-eq u0 (mod add-num u2)) (err u3))

        ;; Increment the counter
        (var-set counter (+ (var-get counter) add-num))

        ;; Return the counter
        (ok (var-get counter))
    )     
)
