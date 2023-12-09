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
    opens-bet-guess: bool,
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
;; @param - Amount (uint), amount of bet / bet size - Height (uint), block that we're betting on, Guess (bool), true = even, false = odd
(define-public (create-bet (amount uint) (height uint) (guess bool)) 
    (let 
        (
            (current-bet-id (var-get bet-index))
            (next-bet-id (var-get bet-index))
            (current-user-bets (default-to {open-bets: (list ), active-bets: (list )} (map-get? user-bets tx-sender)))
            (current-active-user-bets (get active-bets current-user-bets))
        )

        ;; Assert that amount is less than or equal to 50 STX
        (asserts! (< amount u5000000) (err "err-bet-amount-too-high"))

        ;; Assert that amount is a factor of 5 (mod 5 = 0)
        (asserts! (is-eq (mod amount u5) u0) (err "err-bet-amount-not-factor-of-5"))

        ;; Assert that that height is higher than  (min-future-height + block-height) and less than (max-future-height + block-height)
        (asserts! (and 
                        (>= height (+ block-height min-future-height)) 
                        (<= height (+ block-height max-future-height)))
                 (err "err-bet-height-not-in-range"))

        ;; Charge create-match-fee in STX
        (unwrap! (stx-transfer? create-match-fee tx-sender (as-contract tx-sender)) (err "err-stx-transfer-failed"))

        ;; Send amount / bet STX to escrow/contract
        (unwrap! (stx-transfer? amount tx-sender (as-contract tx-sender)) (err "err-stx-transfer-failed"))

        ;; Map-set current-user-bets by merging current-user-bets
        (map-set user-bets tx-sender (merge 
        current-user-bets 
        {open-bets: (unwrap! (as-max-len? (append current-active-user-bets current-bet-id) u100) (err "err-user-bets-list-too-long"))}))

        ;; Var-set open-bets by appending current-bet-id to open-bets
        (var-set open-bets (unwrap! (as-max-len? (append (var-get open-bets) current-bet-id) u100) (err "err-open-bets-list-too-long")))

        ;; Map-set bets
        (map-set bets current-bet-id 
            {opens-bet: tx-sender, 
            opens-bet-guess: guess, 
            amount-bet: amount, 
            height-bet: height, 
            matches-bet: none, 
            winner: none})

        ;; Var-set bet-index next-index
        (ok (var-set bet-index (+ next-bet-id u1)))
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
            (current-contract-wide-open-bets (var-get open-bets))
            (current-contract-wide-active-bets (var-get active-bets))            
        )

        ;; Check if the block-height is equal to or less than the current-bet-height-bet
        (asserts! (<= block-height current-bet-height-bet) (err "err-bet-height"))

        ;; Assert that length of current-active-users-bets is less than 3
        (asserts! (< (len current-user-active-bets) max-active-bets) (err "err-user-active-bets-too-many"))

       
        ;; Transfer current-bet-amount & match-fee in STX
        (unwrap! (stx-transfer? (+ (get amount-bet current-bet) create-match-fee) tx-sender (as-contract tx-sender)) (err "err-stx-transfer-failed"))   

        ;; Map-set current-bet by merging current-bet with {matches-bet: (some tx-sender)}
        (map-set bets bet-id (merge current-bet {matches-bet: (some tx-sender)}))

        ;; Var-set helper-uint with bet
        (var-set helper-uint bet-id)

        ;; Map-set user-bets by appending bet to current-active-bets list & by Filtering out bet with filter-out-uint
        (map-set user-bets tx-sender {
            open-bets: (filter filter-out-uint current-user-open-bets),
            active-bets: (unwrap! (as-max-len? (append current-user-active-bets bet-id) u3) (err "err-user-active-bets-list-too-long"))
        } )

        ;; Var-set open-bets by filtering out bet from current-contract-wide-open-bets susing filtering-out-uint
        (var-set open-bets (filter filter-out-uint current-contract-wide-open-bets))

        ;; Var-set active-bets by appending bet to current-contract-wide-active-bets
        (ok (var-set active-bets (unwrap! (as-max-len? (append current-contract-wide-active-bets bet-id) u100) (err "err-active-bets-list-too-long"))))
    )
)

(define-private (filter-out-uint (bet uint)) 
    (not (is-eq bet (var-get helper-uint)))
)

;; Reveal Bet
;; @desc - Public function for either principal a or b to reveal & end an active bet
;; @param - bet-id (uint), the bet that we're ending
(define-public (reveal-bet (bet-id uint)) 
    (let
        (
            (current-bet (unwrap! (map-get? bets bet-id) (err "err-bet-doesnt-exist")))
            (current-bet-height (get height-bet current-bet))
            (current-bet-opener (get opens-bet current-bet))
            (current-bet-opener-guess (get opens-bet-guess current-bet))
            (current-bet-matcher (unwrap! (get matches-bet current-bet) (err "err-bet-not-matched")))
            (current-user-bets (default-to {open-bets: (list ), active-bets: (list )} (map-get? user-bets tx-sender)))
            (current-user-open-bets (get open-bets current-user-bets))
            (current-user-active-bets (get active-bets current-user-bets))
            (current-matcher-bets (default-to {open-bets: (list ), active-bets: (list )} (map-get? user-bets current-bet-matcher)))
            (current-matcher-open-bets (get open-bets current-matcher-bets))
            (current-matcher-active-bets (get active-bets current-matcher-bets))
            (current-bet-height-bet (get height-bet current-bet))
            (current-contract-wide-open-bets (var-get open-bets))
            (current-contract-wide-active-bets (var-get active-bets))
            (random-numbet-at-block (unwrap! (get-random-uint-at-block current-bet-height) (err "err-random-number-at-block")))   
        )

        ;; Assert that bet is active by checking index-of current-contract-wide-active-bets
        (asserts! (is-some (index-of current-contract-wide-active-bets bet-id)) (err "err-bet-not-active"))

        ;; Assert that block-height is greater than current-bet-height
        (asserts! (> block-height current-bet-height) (err "err-bet-height"))

        ;; Check if random-number-at-block mod 2 == 0
            ;; Random number is even
                ;; Check if opener-guess is even
                    ;; Send double amount to opener
                    ;; Send double amount to matcher
                     ;; Map-set bet by merging current-bet with {winner:}
            ;; Random number is odd
                ;; Check if opener-guess is even
                    ;; Send double amount to matcher
                    ;; Send double amount to opener
                     ;; Map-set bet by merging current-bet with {winner:}
        
        (if (is-eq (mod random-numbet-at-block u2) u0)
            (if current-bet-opener-guess
                (begin
                    (as-contract (unwrap! (stx-transfer? (* (get amount-bet current-bet) u2) tx-sender current-bet-opener) (err "err-stx-transfer-failed")))
                    (map-set bets bet-id (merge current-bet {winner: (some current-bet-opener)}))
                )                
                (begin
                    (as-contract (unwrap! (stx-transfer? (* (get amount-bet current-bet) u2) tx-sender current-bet-matcher) (err "err-stx-transfer-failed")))
                    (map-set bets bet-id (merge current-bet {winner: (some current-bet-matcher)}))
                )
            )            
            (if current-bet-opener-guess
                (begin
                    (as-contract (unwrap! (stx-transfer? (* (get amount-bet current-bet) u2) tx-sender current-bet-matcher) (err "err-stx-transfer-failed")))
                    (map-set bets bet-id (merge current-bet {winner: (some current-bet-matcher)}))
                )
                (begin
                    (as-contract (unwrap! (stx-transfer? (* (get amount-bet current-bet) u2) tx-sender current-bet-opener) (err "err-stx-transfer-failed")))
                    (map-set bets bet-id (merge current-bet {winner: (some current-bet-opener)}))
                )
            )
        )                    

        ;; Var-set helper uint
        (var-set helper-uint bet-id)

        ;; Map-set active-bets by filtering out bet from active-bets
        (var-set active-bets (filter filter-out-uint current-contract-wide-active-bets))

        ;; Map-set user-bets for opener 
        (map-set user-bets current-bet-opener {open-bets: (filter filter-out-uint current-user-open-bets), active-bets: (filter filter-out-uint current-user-active-bets)})

        ;; Map-set user-bets for matcher
        (ok (map-set user-bets current-bet-matcher {open-bets: (filter filter-out-uint current-matcher-open-bets), active-bets: (filter filter-out-uint current-matcher-active-bets)}))
    )
)

;; Cancel Bet
;; @desc - cancel an open bet
;; @param - bet-id (uint), bet that we're cancelling
(define-public (cancel-bet (bet-id uint)) 
    (let
        (
            (current-bet (unwrap! (map-get? bets bet-id) (err "err-bet-doesnt-exist")))
            (current-bet-opener (get opens-bet current-bet))
            (current-bet-amount (get amount-bet current-bet))
            (current-bet-matcher (get matches-bet current-bet))
            (current-user-bets (default-to {open-bets: (list ), active-bets: (list )} (map-get? user-bets tx-sender)))
            (current-user-open-bets (get open-bets current-user-bets))
            (current-contract-wide-open-bets (var-get open-bets))
            (current-contract-wide-active-bets (var-get active-bets))
        )

        ;; Assert that tx-sender is-eq current-bet-opener
        (asserts! (is-eq tx-sender current-bet-opener) (err "err-not-bet-opener"))

        ;; Assert that current-bet-matcher is-none
        (asserts! (is-none current-bet-matcher) (err "err-bet-matched"))

        ;; Assert that current-contract-wide-active-bets index-of is-none
        (asserts! (is-none (index-of current-contract-wide-active-bets bet-id)) (err "err-bet-already-active"))

        ;; Assert that current-contract-wide-open-bets index-of bet is-some
        (asserts! (is-some (index-of current-contract-wide-open-bets bet-id)) (err "err-bet-not-open"))

        ;; Assert that current-user-open-bets index-of bet is-some
        (asserts! (is-some (index-of current-user-open-bets bet-id)) (err "err-bet-not-open"))

        ;; Transfer STX (bet-amount - cancel-fee) from contract to user
        (as-contract (unwrap! (stx-transfer? (- current-bet-amount cancel-fee) tx-sender current-bet-opener) (err "err-stx-transfer-failed")))

        ;; Delete map
        (map-delete bets bet-id)

        ;; Var-set helper-uint
        (var-set helper-uint bet-id)

        ;; Map-set user-bets with filtered out open-bet
        (map-set user-bets tx-sender (merge current-user-bets {open-bets: (filter filter-out-uint current-user-open-bets)}))

        ;; Var-set open-bets with filtered out open-bet
        (ok (var-set open-bets (filter filter-out-uint current-contract-wide-open-bets)))
    )
)


;;;;;;;;;;;;;;;;;;;;;;
;;;; Random Func ;;;;;
;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (get-random-uint-at-block (stacksBlock uint)) 
    (let
        (
            (vrf-lower-uint-opt (match (get-block-info? vrf-seed stacksBlock) 
                    vrf-seed (some (buff-to-uint-le (lower-16-le vrf-seed)))
                    none))
        )
        vrf-lower-uint-opt
    )
)

;; UTILITIES
;; lookup table for converting 1-byte bufferes to uints via index-of
(define-constant BUFF_TO_BYTE (list 
    0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x0a 0x0b 0x0c 0x0d 0x0e 0x0f
    0x10 0x11 0x12 0x13 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f
    0x20 0x21 0x22 0x23 0x24 0x25 0x26 0x27 0x28 0x29 0x2a 0x2b 0x2c 0x2d 0x2e 0x2f
    0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x3a 0x3b 0x3c 0x3d 0x3e 0x3f
    0x40 0x41 0x42 0x43 0x44 0x45 0x46 0x47 0x48 0x49 0x4a 0x4b 0x4c 0x4d 0x4e 0x4f
    0x50 0x51 0x52 0x53 0x54 0x55 0x56 0x57 0x58 0x59 0x5a 0x5b 0x5c 0x5d 0x5e 0x5f
    0x60 0x61 0x62 0x63 0x64 0x65 0x66 0x67 0x68 0x69 0x6a 0x6b 0x6c 0x6d 0x6e 0x6f
    0x70 0x71 0x72 0x73 0x74 0x75 0x76 0x77 0x78 0x79 0x7a 0x7b 0x7c 0x7d 0x7e 0x7f
    0x80 0x81 0x82 0x83 0x84 0x85 0x86 0x87 0x88 0x89 0x8a 0x8b 0x8c 0x8d 0x8e 0x8f
    0x90 0x91 0x92 0x93 0x94 0x95 0x96 0x97 0x98 0x99 0x9a 0x9b 0x9c 0x9d 0x9e 0x9f
    0xa0 0xa1 0xa2 0xa3 0xa4 0xa5 0xa6 0xa7 0xa8 0xa9 0xaa 0xab 0xac 0xad 0xae 0xaf
    0xb0 0xb1 0xb2 0xb3 0xb4 0xb5 0xb6 0xb7 0xb8 0xb9 0xba 0xbb 0xbc 0xbd 0xbe 0xbf
    0xc0 0xc1 0xc2 0xc3 0xc4 0xc5 0xc6 0xc7 0xc8 0xc9 0xca 0xcb 0xcc 0xcd 0xce 0xcf
    0xd0 0xd1 0xd2 0xd3 0xd4 0xd5 0xd6 0xd7 0xd8 0xd9 0xda 0xdb 0xdc 0xdd 0xde 0xdf
    0xe0 0xe1 0xe2 0xe3 0xe4 0xe5 0xe6 0xe7 0xe8 0xe9 0xea 0xeb 0xec 0xed 0xee 0xef
    0xf0 0xf1 0xf2 0xf3 0xf4 0xf5 0xf6 0xf7 0xf8 0xf9 0xfa 0xfb 0xfc 0xfd 0xfe 0xff
))

;; Convert a 1-byte bufferinto its uint representation
(define-private (buff-to-u8 (byte (buff 1))) 
    (unwrap-panic (index-of BUFF_TO_BYTE byte))
)

;; Convert a little-endian 16-byte buff into a uint
(define-private (buff-to-uint-le (word (buff 16))) 
    (get acc
      (fold add-and-shift-uint-le (list u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 u11 u12 u13 u14 u15) { acc: u0, data: word })
    )
)

;; Inner fold function for converting a 16-byte buff into a uint
(define-private (add-and-shift-uint-le (idx uint) (input { acc: uint, data: (buff 16)})) 
    (let
        (
            (acc (get acc input))
            (data (get data input))
            (byte (buff-to-u8 (unwrap-panic (element-at data idx))))
        )
        { acc: (+ (* byte (pow u2 (* u8 (- u15 idx)))) acc), data: data }
    )
)

;; Convert the lower 16 bytes of a buff into a little-endian uint.
(define-private (lower-16-le (input (buff 32))) 
    (get acc 
        (fold lower-16-le-closure (list u16 u17 u18 u19 u20 u21 u22 u23 u24 u25 u26 u27 u28 u29 u30 u31) {acc: 0x, data: input})
    )
)

;; Inner closure for obtaining the lowe 16 bytes of a 32-byte buff
(define-private (lower-16-le-closure (idx uint) (input {acc: (buff 16), data: (buff 32)})) 
    (let
        (
            (acc (get acc input))
            (data (get data input))
            (byte (unwrap-panic (element-at data idx)))
        )
        {acc: (unwrap-panic (as-max-len? (concat acc byte) u16)),
        data: data}
    )
)
