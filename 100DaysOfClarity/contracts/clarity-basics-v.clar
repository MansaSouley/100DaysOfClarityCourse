;; Clarity Basics V
;; Reviewing more Clarity fundamentals
;; Written by Souley

;; Day 45 - Private Functions
(define-read-only (say-hello-read) 
    (say-hello-world)
)
(define-public (say-hello-public) 
    (ok (say-hello-world))
)
(define-private (say-hello-world) 
    "hello world"
)

;; Day 46 -Filter
(define-constant test-list (list u1 u2 u3 u4 u5 u6 u7 u8 u9 u10))
(define-read-only (test-filter-remove-smaller-than-five) 
    (filter filter-smaller-than-five test-list)
)

(define-read-only (test-filter-remove-odds) 
    (filter filter-remove-odds test-list)
)

(define-private (filter-smaller-than-five (item uint)) 
    (< item u5)
)

(define-private (filter-remove-odds (item uint)) 
    (is-eq (mod item u2) u0)
)

;; Day 47 - Map
(define-constant test-list-string (list "alice" "bob" "carl"))
(define-read-only (test-map-increase-by-one) 
    (map add-by-one test-list)
)
(define-read-only (test-map-double) 
    (map double test-list)
)

(define-read-only (test-map-names) 
    (map hello-name test-list-string)
)

(define-private (add-by-one (item uint)) 
    (+ item u1)
)
(define-private (double (item uint)) 
    (* item u2)
)

(define-private (hello-name (item (string-ascii 24))) 
    (concat "Hello " item)
)
