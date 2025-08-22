(define-constant err-unauthorized (err u100))
(define-constant err-invalid-option (err u101))
(define-constant err-expired (err u102))
(define-constant err-not-expired (err u103))
(define-constant err-already-exercised (err u104))

(define-data-var admin principal tx-sender)

(define-map options
  {option-id: uint}
  {
    owner: principal,
    is-call: bool,
    strike: uint,
    expiry: uint,
    amount: uint,
    exercised: bool
  }
)

(define-data-var next-id uint u1)

;; ========== ADMIN FUNCTIONS ==========

(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (not (is-eq new-admin tx-sender)) err-unauthorized)
    (asserts! (is-eq tx-sender (var-get admin)) err-unauthorized)
    (var-set admin new-admin)
    (ok true)
  )
)

;; ========== USER FUNCTIONS ==========

(define-public (mint-option (is-call bool) (strike uint) (expiry uint) (amount uint))
  (let 
    ((id (var-get next-id)))
    (begin
      (asserts! (and
              (> strike u0)
              (> expiry block-height)
              (> amount u0))
            err-invalid-option)
      (map-set options
        {option-id: id}
        {
          owner: tx-sender,
          is-call: is-call,
          strike: strike,
          expiry: expiry,
          amount: amount,
          exercised: false
        }
      )
      (var-set next-id (+ id u1))
      (ok id)
    )
  )
)

(define-public (exercise-option (id uint) (market-price uint))
  (let ((opt (unwrap! (map-get? options {option-id: id}) err-invalid-option)))
    (begin
      (asserts! (is-eq tx-sender (get owner opt)) err-unauthorized)
      (asserts! (not (get exercised opt)) err-already-exercised)
      (asserts! (< block-height (get expiry opt)) err-expired)

      ;; Check profitability
      (if (get is-call opt)
        (asserts! (> market-price (get strike opt)) err-invalid-option)
        (asserts! (< market-price (get strike opt)) err-invalid-option)
      )

      ;; Mark as exercised
      (map-set options
        { option-id: (var-get next-id) }
        (merge opt { exercised: true })
      )

      ;; Simulate transfer or log event
      (ok {
        exercised: true,
        profit: (if (> market-price (get strike opt))
                  (- market-price (get strike opt))
                  (- (get strike opt) market-price))
      })
    )
  )
)

(define-public (expire-option (id uint))
  (begin
    (asserts! (>= id u0) err-invalid-option)
    (let ((opt (unwrap! (map-get? options { option-id: id }) err-invalid-option)))
      (begin
        (asserts! (>= block-height (get expiry opt)) err-not-expired)
        (map-delete options { option-id: id })
        (ok true)
      )
    )
  )
)
