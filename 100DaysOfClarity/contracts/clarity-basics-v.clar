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


;; Day 48 - Map Revisited
(define-constant test-list-principals (list 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG 'ST2JHG361ZXG51QTKY2NQCVBPPRRE2KZB1HR05NNC))
(define-constant test-list-tuple (list {user: "Alice", balance: u10} {user: "Bob", balance: u11} {user: "Carl", balance: u12} ))
(define-public (test-send-stx-multiple) 
    (ok (map send-stx-multiple test-list-principals))
)
(define-read-only (test-get-users) 
    (map get-user test-list-tuple)
)
(define-read-only (test-get-balance) 
    (map get-balance test-list-tuple)
)

(define-private (send-stx-multiple (item principal)) 
    (stx-transfer? u100000000 tx-sender item)
)

(define-private (get-user (item {user: (string-ascii 24), balance: uint})) 
    (get user item)
)
(define-private (get-balance (item {user: (string-ascii 24), balance: uint})) 
    (get balance item)
)

;; Day 49 - Fold
(define-constant test-list-ones (list u1 u1 u1 u1 u1))
(define-constant test-list-two (list u1 u2 u3 u4 u5))
(define-constant test-alphabet (list "a" "b" "c" "d" "e"))

(define-read-only (fold-add-start-zero) 
    (fold + test-list-ones u0)
)
(define-read-only (fold-add-start-ten) 
    (fold + test-list-ones u10)
)
(define-read-only (fold-multiply-one) 
    (fold * test-list-two u1)
)
(define-read-only (fold-multiply-two) 
    (fold * test-list-two u2)
)
(define-read-only (fold-characters) 
    (fold concat-string test-alphabet "")
)

(define-private (concat-string (a (string-ascii 10)) (b (string-ascii 10))) 
    (unwrap-panic (as-max-len? (concat b a) u10))
)

;; Day 50 - Contract-call?
(define-read-only (call-basics-i-multiply) 
    (contract-call? .clarity-basics-i multiply )
)
(define-read-only (call-basics-i-hello-world) 
    (contract-call? .clarity-basics-i say-hello-world-name)
)
(define-public (call-basics-ii-hello-world (name (string-ascii 48))) 
    (contract-call? .clarity-basics-ii set-and-say-hello name)
)
(define-public (call-basics-iii-set-second-map (new-username (string-ascii 24)) (new-balance uint) (new-referral (optional principal))) 
    (begin 
        (try! (contract-call? .clarity-basics-ii set-and-say-hello new-username))
        (contract-call? .clarity-basics-iii set-second-map new-username new-balance none)
    )
)

;; Day 52
(define-non-fungible-token nft-test uint)
(define-public (test-mint) 
    (nft-mint? nft-test u0 tx-sender)
)
(define-read-only (test-get-owner (id uint)) 
    (nft-get-owner? nft-test id)
)
(define-public (test-burn (id uint) (sender principal)) 
    (nft-burn? nft-test id sender)
)
(define-public (test-transfer (id uint) (sender principal) (recipient principal)) 
    (nft-transfer? nft-test u0 sender recipient)
)

;;