;; Odds & Evens
;;  Contract for a 2-player betting game
;; Written by Mansa Souley

;; Game
;; Two players bet the same amount that a future block will odd or even
;; Player can have no more than 2 active bets at a time
;; Bets can oly be made in factors of 5 & have to less than 50
;; The contract should charge 2 STXs to create a bet. 2 STX to join a bet, & 1 STX each to cancel bet
;; All or nothing for winner

;; Bet
;; Create Bet -> a bet needs to have principal A(starts), principal B (come late - optional), bet amount & bet height
;; Cancel Bet -> manually or auto-expire
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

;; Var for keeping track of bet index
(define-data-var bet-index uint u0)

;; Var all open bets
(define-data-var open-bets (list 100 uint) (list ))

;; Var all active bets
(define-data-var active-bets (list 100 uint) (list ))


;; Helper var for filetring out uints
(define-data-var helper-uint uint u0)

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

;; Open / Create Bet
;; @desc- Public function for creating an initial bet
;; @param - Amount (uint), amount of bet / bet size - Height (uint), block that we're betting on
(define-public (create-bet (amount uint) (height uint)) 
    (let 
        (
            (current-bet-id (var-get bet-index))
            (next-bet-id (var-get bet-index))
            (current-user-bets (default-to {open-bets: (list ), active-bets: (list )} (map-get? user-bets tx-sender)))
            (current-active-user-bets (get active-bets current-user-bets))
        )

        ;; Assert that amount is less than or eqaul to 50 STX

        ;; Assert that amount is a factor of 5 (mod 5 = 0)

        ;; Assert that that height is higher than  (min-future-height) and less than (max-future-height)       

        ;; Charge create-match-fee in STX

        ;; Send amount / bet STX to escrow/contract

        ;; Map-set current-user-bets

        ;; Var-set open-bets by appending

        ;; Map-set bets

        ;; Var-set bet-index next-index      

        (ok false)
    )
)

;; Match Bet
;; @desc - public function for joining / matching an open bet as principal B
;; @param -  bet-id (uint)
(define-public (match-bet (bet-id uint)) 
    (let
        (
            (current-bet (unwrap! (map-get? bets bet-id) (err "err-bet-doesnt-exist")))
            (current-user-bets (default-to {open-bets: (list ), active-bets: (list )} (map-get? user-bets tx-sender)))
            (current-user-open-bets (get open-bets current-user-bets))
            (current-user-active-bets (get active-bets current-user-bets))
            (current-bet-height-bet (get height-bet current-bet))            
        )

        ;; Check if the block-height is equal to or less than the current-bet-height-bet

        ;; Assert that length of current-active-users-bets is less than 3

        ;; Transfer bet amount in STX to escrow/contract

        ;; Transfer current-bet-amount in STX

        ;; Map-set current-bet by merging current-bet with {matches-bet: (some tx-sender)}

        ;; Map-set user-bets by appending bet to current-active-bets list & by Filtering out bet with filter-out-uint    
       
        ;; Var-set helper-uint with bet

        ;; Map-set user-bets

        (ok false)
    )
)

(define-private (filter-out-uint (bet uint)) 
    (not (is-eq bet (var-get helper-uint)))
)