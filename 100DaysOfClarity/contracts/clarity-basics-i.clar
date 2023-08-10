;; CLarity Basics I
;; Day 3 - Boolean & Read-only
;; Here we're to review the very basics of Clarity

(define-read-only (show-true-i) 
    true
)

(define-read-only (show-false-i) 
    false
)

(define-read-only (show-true-ii) 
    (not false)
)

(define-read-only (show-false-ii) 
    (not true)
)

;; Day 4 - Numbers Uints, Ints, & simple operations

(define-read-only (add) 
    (+ u1 u2)
)

(define-read-only (subtract) 
    (- 1 2)
)

(define-read-only (multiply) 
    (* u2 u3)
)

(define-read-only (divide) 
    (/ u6 u2)
)

;; Day 5 - Strings 
(define-read-only (say-hello) 
    (concat "Hello" " World")
)

(define-read-only (say-hello-world-name)    
    (concat  
        (concat "Hello" " World," )
         " Souley"
    )
)

;; Day 7 - And & Or
(define-read-only (and-i) 
    (and true true)
)

(define-read-only (and-ii) 
    (and true false)
)

(define-read-only (and-iii) 
    (and
        (> u2 u1)
        (not false)
        true
    )
)

(define-read-only (or-i) 
    (or true false)
)

(define-read-only (or-ii) 
    (or 
        (not true) 
        false
    )
)