#lang lambda-calculus/base

(require "core.rkt")
(provide (all-defined-out))

(module+ test
  (require rackunit))

(def zero identity)
(def succ (λ n (λ s ((s false) n))))
(def pred (λ n (((is-zero? n) zero) (n false))))
(def is-zero? (λ n (n true)))

(module+ test
  (check-equal? zero zero)
  (check-equal? zero (pred (succ zero)))

  ; pred zero is also zero
  (check-equal? zero (pred zero))
  (check-equal? (is-zero? zero) true)
  (check-equal? (is-zero? (succ zero)) false))

(def one (succ zero))
(def two (succ (succ zero)))
(def three (succ (succ (succ zero))))
(def four (succ (succ (succ (succ zero)))))
(def five (succ (succ (succ (succ (succ zero))))))

(module+ test
  (check-equal? zero (pred one)))
