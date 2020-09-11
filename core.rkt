#lang lambda-calculus/base

(provide (all-defined-out))

(module+ test
  (require rackunit))

(def identity (λ x x))
(def true (λ x (λ y x)))
(def false (λ x (λ y y)))

(module+ test
  (check-equal? ident (! (identity ident)))
  (check-equal? true (! (identity true)))
  (check-equal? false (! (identity false))))

(def select-first true)
(def select-second false)
