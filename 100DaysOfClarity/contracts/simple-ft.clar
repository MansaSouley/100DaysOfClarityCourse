
;; FT Simple
;; Our very first FT implementation
;; Written by Mansa Souley
;; Day 77

;; FT - ClarityToken, supply of 100
;; Every principal can claim 1 CT, once

(impl-trait .sip-10.ft-trait)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define FT
(define-fungible-token clarity-token u100)

;; Human readable name
(define-constant name "ClarityToken")

;; Human-readable symbol
(define-constant symbol "CT")

;; Token decimals
(define-constant decimals u0)


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SIP-10 Functions  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Transfer
(define-public (transfer (amount uint) (sender principal) (recipient principal) (note (optional (buff 34)))) 
    (ft-transfer? clarity-token amount sender recipient)
)

;; Get Token Name
(define-public (get-name) 
    (ok name)
)

;; Get Token Symbol
(define-public (get-symbol) 
    (ok symbol)
)

;; Get Token Decimals
(define-public (get-decimals) 
    (ok decimals)
)

;; Get Balance
(define-public (get-balance (wallet principal)) 
    (ok (ft-get-balance clarity-token wallet))
)

;; Get Total Supply
(define-public (get-total-supply) 
    (ok (ft-get-supply clarity-token))
)
;; Get Token URI
(define-public (get-token-uri) 
    (ok none)
)