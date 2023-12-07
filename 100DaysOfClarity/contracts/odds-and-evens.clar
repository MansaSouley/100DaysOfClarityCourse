;; Odds & Evens
;;  Contract for a 2-player betting game
;; Written by Mansa Souley

;; Game
;; Two players bet the same amount that a future block will odd or even
;; Player can have no more than 2 active bets at a time
;; Bets can oly be maee in factore of 5 & have to less than 50
;; The contract should charge 2 STXs to create a bet. 2 STX tp join a bet, & 1 STX each to cancel bet
;; All or nothing for winner

;; Bet
;; Create Bet -> a bet needs to have principal A(starts), principal B (come late - optional), bet amount & bet height
;; Match Bet -> Principal B spots Bet A & fills in the second slot, bet is now locked until reveal height
;; Reveal Bet -> once reveal is surpassed, either player can call to reveal

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Min bet height in blocks
(define-constant min-future-height  u10)

;; Max bet height in blocks( ~ a week)
(define-constant max-future-height u1008)

;; Max user active bets
(define-constant max-active-bets u3)

;;; Max bet  amount
(define-constant max-bet-amount u51)

;; Create / match bet fee
(define-constant create-match-fee u2000000)

;; Cancel bet fee
(define-constant cancel-fee u1000000)

;; Map that tracks the status of a bet
(define-map bets uint {
    opens-bet: principal,
    matches-bet: (optional principal),
    amount-bet: uint,
    height-bet: uint,
    winner: (optional principal)
})

;; Map that tracks active bets per user
(define-map user-bets principal {open-bets: (list 100 uint), active-bets: (list 3 uint)})
;; Var all open bets
(define-data-var open-bets (list 100 uint) (list ))

;; Var all active bets
(define-data-var active-bets (list 100 uint) (list ))




;;;;;;;;;;;;;;;;;;;
;;;; Read-Only ;;;;
;;;;;;;;;;;;;;;;;;;

;; Get all open bets
(define-read-only (get-open-bets) 
    (var-get open-bets)
)

;; Get all active bets
(define-read-only (get-active-bets) 
    (var-get active-bets)
)
;; Get specific bet
(define-read-only (get-bet (bet-id uint))    
    (map-get? bets bet-id)
)

;; Get user bets
(define-read-only (get-user-bets (user principal)) 
    (map-get? user-bets user)
)

;;;;;;;;;;;;;;;;;;;
;;;; Bet Func ;;;;;
;;;;;;;;;;;;;;;;;;;

