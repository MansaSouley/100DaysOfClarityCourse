
;; artist-discography
;; Contract that models an artis discography (discography -> albums -> tracks)
;; Written by: MansaSouley

;; Discography
;; An artist discography is a list of albums
;; The artist or an admin can start a discography and can add/remove albums

;; Album
;; An album is a list of tracks + additional information(title, release date, etc)
;; The artist or an admin can start an album and can add/remove tracks

;; Track
;; A track is a list of name, duration (in seconds), and possible feature(optional feature)


;;;;;;;;;;;;;;;;;;;;;;;;;
;; Cons, Vars & Maps  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Admin list of principals
(define-data-var admin-list (list 10 principal) (list tx-sender)  )

(define-map track { artist: principal, album-id: uint, track-id: uint } { 
    title: (string-ascii 24),
    duration: uint,
    featured: (optional principal)
})

(define-map album { artist: principal, album-id: uint } { 
    title: (string-ascii 24),
    tracks: (list 10 uint),
    height-published: uint
})

(define-map discography principal (list 10 uint))



;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Read Functions   ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get track data
(define-read-only (get-track-data (artist principal) (album-id uint) (track-id uint)) 
    (map-get? track { artist: artist, album-id: album-id, track-id: track-id })    
)

;; Get featured artist
(define-read-only (get-featured-artist (artist principal) (album-id uint) (track-id uint)) 
   (get featured  (map-get? track { artist: artist, album-id: album-id, track-id: track-id}))    
)

;; Get album data
(define-read-only (get-album-data (artist principal) (album-id uint)) 
    (map-get? album { artist: artist, album-id: album-id })    
)

;; Get published data
(define-read-only (get-published-height (artist principal) (album-id uint)) 
    (get height-published (map-get? album { artist: artist, album-id: album-id }))    
)

;; Get discography data

(define-read-only (get-discography (artist principal)) 
    (map-get? discography artist)    
)

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Write Functions  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add track
;; @desc - function that allows a user or admin to add a track to an album
;; @param - title: (string-ascii 24), duration: (uint), featured: (optional principal), album-id: (uint)
(define-public (add-a-track (artist principal) (title (string-ascii 24)) (duration uint) (featured (optional principal)) (album-id uint)) 
    (let 
        (
           (current-discography (unwrap! (map-get? discography artist) (err u0)))
           (current-album (unwrap! (index-of current-discography album-id) (err u2)))
           (current-album-data (unwrap! (map-get? album {artist: artist, album-id: album-id}) (err u3)))
           (current-album-tracks  (get tracks current-album-data))
           (current-album-track-id (len current-album-tracks))
           (next-album-track-id (+ current-album-track-id u1))           
        )

        ;; Assert that tx-sender is artist or admin
        (asserts! (or (is-eq tx-sender artist) (is-some (index-of (var-get admin-list) tx-sender))) (err u1))

        ;; Assert that album exists in discography
        ;; (asserts! (is-some current-album) (err u2))       

        ;; Assert that duration is greater than 0 and less that 10 minutes (600 seconds)
        (asserts! (< duration u600) (err u3))
    
        ;; Map-set new track 
        (map-set track {artist: artist, album-id: album-id, track-id: current-album-track-id} {
            title: title,
            duration: duration,
            featured: featured
        })

        ;; Map-set append track to album
        (ok (map-set album {artist: artist, album-id: album-id} 
            (merge current-album-data 
                {tracks: (unwrap! (as-max-len? (append  current-album-tracks next-album-track-id) u10) (err u4))}
            )
        ))             
    )
)
;; Add album
;; @desc - function that allows the artist or admin to add an album or start a new discography & then add an album
(define-public (add-album-or-create-discography-and-add-album (artist principal) (album-title (string-ascii 24)) ) 
    (let 
        (
           (current-discography (default-to (list ) (map-get? discography artist)))
           (current-album-id (len current-discography))
           (next-album-id (+ current-album-id u1))  
        ) 
        ;; Assert that tx-sender is artist or admin

        ;; Check whether discography exists / if discography is-some
        (ok (if (is-eq current-album-id u0) 

            ;; Empty discography
            (begin 
                (map-set discography artist (list current-album-id))
                (map-set album { artist: artist, album-id: current-album-id } {
                    title: album-title,
                    tracks: (list),
                    height-published: block-height
                })
            
            )

            ;; Discography exist
            (begin  
                (map-set discography artist (unwrap! (as-max-len? (append  current-discography next-album-id) u10) (err u4)))
                (map-set album { artist: artist, album-id: current-album-id } {
                        title: album-title,
                        tracks: (list),
                        height-published: block-height
                })            
            )
        ))        
         
    )
)


;; Add discography


;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Admin Functions ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Add Admin
;; @desc - function that allows the artist or admin to add new admin
;;@param - admin: principal
(define-public (add-admin (new-admin principal)) 
    (let 
        (
            (test u0)
        ) 
        ;; Assert that tx-sender is artist or admin

        ;; Assert that admin is NOT already an admin

        ;; Map-set  append new admin

        (ok test)

    )
)

;; Remove Admin
;; @desc - function that allows the artist or admin to remove an admin
;;@param - admin: principal
(define-public (remove-admin (removed-admin principal)) 
    (let 
        (
            (test u0)
        ) 
        ;; Assert that tx-sender is artist or admin

        ;; Assert that removed-admin is an admin

        ;; Map-set  remove admin from admin list

        (ok test)

    )
)