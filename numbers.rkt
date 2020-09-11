#lang lambda-calculus/base

(require "core.rkt" "cond.rkt" (only-in racket displayln begin) racket/promise)
(provide (all-defined-out))

(module+ test
  (require rackunit))

(def zero identity)
(def succ (λ n (λ s ((s false) n))))
(def pred (λ n (((is-zero? n) zero) (n false))))
(def is-zero? (λ n (n true)))

(module+ test
  (check-equal? zero zero)
  (check-equal? zero (! (pred (succ zero))))

  ; pred zero is also zero
  (check-equal? zero (! (pred zero)))
  (check-equal? (! (is-zero? zero)) true)
  (check-equal? (! (is-zero? (succ zero))) false))

(def one (succ zero))
(def two (succ (succ zero)))
(def three (succ (succ (succ zero))))
(def four (succ (succ (succ (succ zero)))))
(def five (succ (succ (succ (succ (succ zero))))))

(module+ test
  (check-equal? zero (! (pred one))))

(def add (λ x (λ y (((if (is-zero? y)) x) ((add (succ x)) (pred y))))))

(module+ test
  (check-equal? zero (! (pred (pred ((add one) one))))))
