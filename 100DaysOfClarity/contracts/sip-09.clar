
;; SIP-09
;; Implemtin SIP-09 locally so we work with NFTs correctly
;; Written by Mansa Souley
;; Day 51

(define-trait nft-trait
    (
        ;; Last token ID
        (get-last-token-id () (response uint uint))
        ;; Get owner
        (get-owner (uint) (response uint uint))
        ;; URI metadata
        (get-token-uri (uint) (response (optional (string-ascii 256)) uint))
        ;; Transfer
        (transfer (uint principal principal) (response bool uint))
    )

)