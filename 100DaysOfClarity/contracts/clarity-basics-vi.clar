;; Clarity Basics VI
;; Reviewing more Clarity fundamentals
;; Written by Mansa Souley

;; Day 57 - Minting Whitelist Logic
(define-non-fungible-token test-nft uint)
(define-constant collection-limit u10)
(define-constant admin tx-sender)
(define-data-var collection-index uint u1)

(define-map whitelist-map principal uint)

;; Minting Logic
(define-public (mint) 
    (let 
        (
            (current-index (var-get collection-index))
            (next-index (+ current-index u1))
            (current-whitelist-mints (unwrap! (map-get? whitelist-map tx-sender) (err "err-whitelist-map-none")))
        )

        ;; Assert that current-index < collection-limit
        (asserts! (< current-index collection-limit) (err "err-no-mints-left"))

        ;; Assert that tx-sender has mints left
        (asserts! (> current-whitelist-mints u0) (err "err-whitelist-mints-all-used"))

        ;; Mint
        (unwrap! (nft-mint? test-nft current-index tx-sender) (err "err-minting"))

        ;; Update allocated whitelist mints
        (map-set whitelist-map tx-sender (- current-whitelist-mints u1))

        ;; Increase collection-index
        (ok (var-set collection-index next-index))
    )
)

;; Add Principal To Whitelist
(define-public (whitelist-principal (whitelist-address principal) (mint-allocated uint)) 
    (begin

        ;; Assert that tx-sender is admin
        (asserts! (is-eq tx-sender admin) (err "err-not-admin"))

        ;; Map-set whitelist-map
        (ok (map-set whitelist-map whitelist-address mint-allocated))
    )
)

;; Day 58 - Non-Custodial Functions
(define-map market uint {price: uint, owner: principal})
(define-public (list-in-ustx (item uint) (price uint)) 
    (let 
        (
            (nft-owner (unwrap! (nft-get-owner? test-nft item) (err "err-nft-doesnt-exist")))
        )

            ;; Assert that tx-sender is-eq to nft-owner
            (asserts! (is-eq tx-sender nft-owner) (err "err-not-owner"))

            ;; Map set market with new NFT
            (ok (map-set market item {price: price, owner: tx-sender}))            
    )    
)
(define-read-only (get-list-in-ustx (item uint)) 
    (map-get? market item)
)
(define-public (unlist-in-ustx (item uint)) 
    (let
        (
            (current-listing (unwrap! (map-get? market item) (err "err-listing-doesnt-exist")))
            (current-price (get price current-listing))
            (current-owner (get owner current-listing))
        )

            ;; Assert that tx-sender is current-owner
            (asserts! (is-eq current-owner tx-sender) (err "err-not-owner"))

            ;; Map delete existing listing
            (ok (map-delete market item))
    )
)
(define-public (buy-in-ustx (item uint)) 
    (let
        (
            (current-listing (unwrap! (map-get? market item) (err "err-listing-doesnt-exist")))
            (current-price (get price current-listing))
            (current-owner (get owner current-listing))
        )

        ;; Tx-sender buys by transfering STX
        (unwrap! (stx-transfer? current-price tx-sender current-owner) (err "err-stx-transfer"))

        ;; Transfer NFT to new-buyer
        (unwrap! (nft-transfer? test-nft item current-owner tx-sender) (err "err-nft-transfer"))

        ;; Map-delete the listing
        (ok (map-delete market item))
    )    
)

;; Day 66 - Use-Trait to make Dynamic Contract calls

(use-trait nft .sip-09.nft-trait)

;; Get last Id
(define-public (get-last-id (nft-principal <nft>)) 
    (contract-call? nft-principal get-last-token-id)
)

;; Get Owner
(define-public (get-owner (nft-principal <nft>) (item uint)) 
    (contract-call? nft-principal get-owner item)
)

;; Day -76 Native Fungible TOken (FT) Functions
(define-fungible-token test-token u100)
(define-public (mint-test-token) 
    (ft-mint? test-token u1 tx-sender)
)
(define-read-only (get-test-token-balance (user principal)) 
    (ft-get-balance test-token user)
)
(define-read-only (get-test-token-supply) 
    (ft-get-supply test-token)
)
(define-public (transfer-test-token (amount uint) (recipient principal)) 
    (ft-transfer? test-token amount tx-sender recipient)
)
(define-public (burn-test-token (amount uint) (sender principal)) 
    (ft-burn? test-token amount sender)
)

;; Day 90 - Buffers
(define-read-only (test-element-at (test-buff (buff 30))) 
    (element-at test-buff u0)
)

(define-read-only (test-index-of (test-buff (buff 30))) 
    (index-of test-buff 0x00)
)
(define-read-only (test-concat (test-buff (buff 6))) 
    (concat test-buff 0x0011)
)

;; Day 91 - Buffers cont. Get-Block-Info? & INtro to VRF
(define-read-only (test-get-block (block uint)) 
    (get-block-info? vrf-seed block)
)

(define-data-var random-number-at-block uint u21234567890) 

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
