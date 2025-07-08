;; Sports Coach Credential System Smart Contract
;; A platform for athletic coaches to store coaching licenses, team achievements, and coaching networks

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-tier (err u104))

;; Access tiers
(define-constant TIER-PUBLIC u0)
(define-constant TIER-LICENSED-COACHES u1)
(define-constant TIER-PRIVATE u2)

;; Data Variables
(define-data-var coaching-fee uint u400) ;; 0.04% fee in basis points

;; Data Maps

;; Coach profiles
(define-map coach-profiles
  { coach: principal }
  {
    coach-name: (string-ascii 100),
    sport-specialties: (string-ascii 200),
    team-affiliation: (string-ascii 100),
    profile-tier: uint,
    joined-at: uint,
    is-licensed: bool
  }
)

;; Team achievements
(define-map team-achievements
  { coach: principal, achievement-id: uint }
  {
    competition-name: (string-ascii 100),
    achievement-type: (string-ascii 100),
    achieved-date: uint,
    season-start: (optional uint),
    achievement-details: (string-ascii 500),
    tier-level: uint,
    recorded-at: uint
  }
)

;; Coach achievement counters
(define-map coach-achievement-count
  { coach: principal }
  { count: uint }
)

;; Coaching licenses
(define-map coaching-licenses
  { coach: principal, license-id: uint }
  {
    license-type: (string-ascii 100),
    issuing-federation: (string-ascii 100),
    issued-date: uint,
    renewal-date: (optional uint),
    license-hash: (buff 32),
    tier-level: uint,
    is-verified: bool,
    recorded-at: uint
  }
)

;; Coach license counters
(define-map coach-license-count
  { coach: principal }
  { count: uint }
)

;; Player testimonials
(define-map player-testimonials
  { coach: principal, testimonial-id: uint }
  {
    coaching-skill: (string-ascii 50),
    recommending-player: principal,
    testimonial-text: (string-ascii 300),
    provided-at: uint
  }
)

;; Coach testimonial counters
(define-map coach-testimonial-count
  { coach: principal }
  { count: uint }
)

;; Coaching networks
(define-map coaching-networks
  { coach1: principal, coach2: principal }
  {
    network-status: (string-ascii 20), ;; "pending", "connected", "inactive"
    initiated-by: principal,
    connected-at: uint
  }
)

;; Coaching skill endorsement counts
(define-map skill-endorsements
  { coach: principal, skill: (string-ascii 50) }
  { count: uint }
)

;; Read-only functions

;; Get coach profile
(define-read-only (get-coach-profile (coach principal))
  (map-get? coach-profiles { coach: coach })
)

;; Get team achievement
(define-read-only (get-team-achievement (coach principal) (achievement-id uint))
  (map-get? team-achievements { coach: coach, achievement-id: achievement-id })
)

;; Get coaching license
(define-read-only (get-coaching-license (coach principal) (license-id uint))
  (map-get? coaching-licenses { coach: coach, license-id: license-id })
)

;; Get player testimonial
(define-read-only (get-player-testimonial (coach principal) (testimonial-id uint))
  (map-get? player-testimonials { coach: coach, testimonial-id: testimonial-id })
)

;; Get network status
(define-read-only (get-network-status (coach1 principal) (coach2 principal))
  (map-get? coaching-networks { coach1: coach1, coach2: coach2 })
)

;; Get skill endorsement count
(define-read-only (get-skill-endorsement-count (coach principal) (skill (string-ascii 50)))
  (default-to u0 (get count (map-get? skill-endorsements { coach: coach, skill: skill })))
)

;; Check if coaches are networked
(define-read-only (are-coaches-networked (coach1 principal) (coach2 principal))
  (let ((network1 (map-get? coaching-networks { coach1: coach1, coach2: coach2 }))
        (network2 (map-get? coaching-networks { coach1: coach2, coach2: coach1 })))
    (or
      (and (is-some network1) (is-eq (get network-status (unwrap-panic network1)) "connected"))
      (and (is-some network2) (is-eq (get network-status (unwrap-panic network2)) "connected"))
    )
  )
)

;; Check if coach can view private content
(define-read-only (can-view-private-content (owner principal) (viewer principal) (tier-level uint))
  (or
    (is-eq owner viewer)
    (is-eq tier-level TIER-PUBLIC)
    (and 
      (is-eq tier-level TIER-LICENSED-COACHES)
      (are-coaches-networked owner viewer)
    )
  )
)

;; Public functions

;; Create coach profile
(define-public (create-coach-profile (coach-name (string-ascii 100)) (sport-specialties (string-ascii 200)) (team-affiliation (string-ascii 100)) (profile-tier uint))
  (begin
    (asserts! (<= profile-tier TIER-PRIVATE) err-invalid-tier)
    (ok (map-set coach-profiles
      { coach: tx-sender }
      {
        coach-name: coach-name,
        sport-specialties: sport-specialties,
        team-affiliation: team-affiliation,
        profile-tier: profile-tier,
        joined-at: block-height,
        is-licensed: false
      }
    ))
  )
)

;; Record team achievement
(define-public (record-team-achievement (competition-name (string-ascii 100)) (achievement-type (string-ascii 100)) (achieved-date uint) (season-start (optional uint)) (achievement-details (string-ascii 500)) (tier-level uint))
  (let ((current-count (default-to u0 (get count (map-get? coach-achievement-count { coach: tx-sender })))))
    (begin
      (asserts! (<= tier-level TIER-PRIVATE) err-invalid-tier)
      (map-set team-achievements
        { coach: tx-sender, achievement-id: current-count }
        {
          competition-name: competition-name,
          achievement-type: achievement-type,
          achieved-date: achieved-date,
          season-start: season-start,
          achievement-details: achievement-details,
          tier-level: tier-level,
          recorded-at: block-height
        }
      )
      (map-set coach-achievement-count
        { coach: tx-sender }
        { count: (+ current-count u1) }
      )
      (ok current-count)
    )
  )
)

;; Add coaching license
(define-public (add-coaching-license (license-type (string-ascii 100)) (issuing-federation (string-ascii 100)) (issued-date uint) (renewal-date (optional uint)) (license-hash (buff 32)) (tier-level uint))
  (let ((current-count (default-to u0 (get count (map-get? coach-license-count { coach: tx-sender })))))
    (begin
      (asserts! (<= tier-level TIER-PRIVATE) err-invalid-tier)
      (map-set coaching-licenses
        { coach: tx-sender, license-id: current-count }
        {
          license-type: license-type,
          issuing-federation: issuing-federation,
          issued-date: issued-date,
          renewal-date: renewal-date,
          license-hash: license-hash,
          tier-level: tier-level,
          is-verified: false,
          recorded-at: block-height
        }
      )
      (map-set coach-license-count
        { coach: tx-sender }
        { count: (+ current-count u1) }
      )
      (ok current-count)
    )
  )
)

;; Send network request
(define-public (send-network-request (target-coach principal))
  (begin
    (asserts! (not (is-eq tx-sender target-coach)) err-unauthorized)
    (asserts! (is-none (map-get? coaching-networks { coach1: tx-sender, coach2: target-coach })) err-already-exists)
    (asserts! (is-none (map-get? coaching-networks { coach1: target-coach, coach2: tx-sender })) err-already-exists)
    (ok (map-set coaching-networks
      { coach1: tx-sender, coach2: target-coach }
      {
        network-status: "pending",
        initiated-by: tx-sender,
        connected-at: block-height
      }
    ))
  )
)

;; Accept network request
(define-public (accept-network-request (requesting-coach principal))
  (let ((network (map-get? coaching-networks { coach1: requesting-coach, coach2: tx-sender })))
    (begin
      (asserts! (is-some network) err-not-found)
      (asserts! (is-eq (get network-status (unwrap-panic network)) "pending") err-unauthorized)
      (ok (map-set coaching-networks
        { coach1: requesting-coach, coach2: tx-sender }
        {
          network-status: "connected",
          initiated-by: requesting-coach,
          connected-at: (get connected-at (unwrap-panic network))
        }
      ))
    )
  )
)

;; Submit player testimonial
(define-public (submit-player-testimonial (coach principal) (coaching-skill (string-ascii 50)) (testimonial-text (string-ascii 300)))
  (let ((current-count (default-to u0 (get count (map-get? coach-testimonial-count { coach: coach }))))
        (current-skill-count (default-to u0 (get count (map-get? skill-endorsements { coach: coach, skill: coaching-skill })))))
    (begin
      (asserts! (not (is-eq tx-sender coach)) err-unauthorized)
      (asserts! (are-coaches-networked tx-sender coach) err-unauthorized)
      (map-set player-testimonials
        { coach: coach, testimonial-id: current-count }
        {
          coaching-skill: coaching-skill,
          recommending-player: tx-sender,
          testimonial-text: testimonial-text,
          provided-at: block-height
        }
      )
      (map-set coach-testimonial-count
        { coach: coach }
        { count: (+ current-count u1) }
      )
      (map-set skill-endorsements
        { coach: coach, skill: coaching-skill }
        { count: (+ current-skill-count u1) }
      )
      (ok current-count)
    )
  )
)

;; Verify coaching license (admin only)
(define-public (verify-coaching-license (coach principal) (license-id uint))
  (let ((license (map-get? coaching-licenses { coach: coach, license-id: license-id })))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (asserts! (is-some license) err-not-found)
      (ok (map-set coaching-licenses
        { coach: coach, license-id: license-id }
        (merge (unwrap-panic license) { is-verified: true })
      ))
    )
  )
)

;; License coach (admin only)
(define-public (license-coach (coach principal))
  (let ((profile (map-get? coach-profiles { coach: coach })))
    (begin
      (asserts! (is-eq tx-sender contract-owner) err-owner-only)
      (asserts! (is-some profile) err-not-found)
      (ok (map-set coach-profiles
        { coach: coach }
        (merge (unwrap-panic profile) { is-licensed: true })
      ))
    )
  )
)

;; Update coaching fee (admin only)
(define-public (update-coaching-fee (new-fee uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set coaching-fee new-fee)
    (ok true)
  )
)