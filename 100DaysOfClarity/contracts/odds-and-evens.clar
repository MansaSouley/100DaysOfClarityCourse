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

;; Map that tracks the status of a bet
(define-map bets uint {
    opens-bet: principal,
    matches-bet: (optional principal),
    amount-bet: uint,
    height-bet: uint
})

;; Var all active bets
(define-data-var active-bets (list 100 uint) (list ))




;;;;;;;;;;;;;;;;;;;
;;;; Read-Only ;;;;
;;;;;;;;;;;;;;;;;;;




;;;;;;;;;;;;;;;;;;;
;;;; Bet Func ;;;;;
;;;;;;;;;;;;;;;;;;;

