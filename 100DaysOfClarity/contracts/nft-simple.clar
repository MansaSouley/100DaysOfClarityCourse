
;; NFT Simple
;; THe most simple NFT
;; Written by Mansa Souley

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Cons, Vars & Maps ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Define NFT
(define-non-fungible-token simple-nft uint)

;; Adhere to SIP09
(impl-trait .sip-09.nft-trait)


;; Collection Limit
(define-constant collection-limit u100)

;; Collection Index
(define-data-var collection-index uint u1)

;; Root URI
(define-constant collection-root-uri "ipfs://ipfs/QmYcrELFT5dsdes567trhsDSEDFVhesn4Idnfse/")


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; SIP-09 Functions  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get last token Id
(define-public (get-last-token-id) 
    (ok (var-get collection-index))
)

;; Get token uri
(define-public (get-token-uri (id uint)) 
    (ok 
        (some (concat 
            collection-root-uri 
            (concat 
                (uint-to-ascii id)
                ".json"
            )  
        ))
    )
)

;; Get token owner
(define-public (get-owner (id uint)) 
    (ok (nft-get-owner? simple-nft id))
)

;; Transfer 
(define-public (transfer (id uint) (sender principal) (recipient principal)) 
    (begin
        (asserts! (is-eq sender tx-sender) (err u1))
        (nft-transfer? simple-nft id sender recipient)    
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Helper Functions  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (uint-to-ascii (value uint))
  (if (<= value u9)
    (unwrap-panic (element-at "0123456789" value))
    (get r (fold uint-to-ascii-inner
      0x000000000000000000000000000000000000000000000000000000000000000000000000000000
      {v: value, r: ""}
    ))
  )
)

(define-read-only (uint-to-ascii-inner (i (buff 1)) (d {v: uint, r: (string-ascii 39)}))
  (if (> (get v d) u0)
    {
      v: (/ (get v d) u10),
      r: (unwrap-panic (as-max-len? (concat (unwrap-panic (element-at "0123456789" (mod (get v d) u10))) (get r d)) u39))
    }
    d
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Core Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Admin Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;
