#lang lambda-calculus/base

(require "core.rkt" "cond.rkt")
(provide (all-defined-out))

(module+ test
  (require (only-in racket #%datum))
  (require rackunit))

(def zero identity)
(def succ (λ n (λ s (s false n))))
(def pred (λ n ((is-zero? n zero) (n false))))
(def is-zero? (λ n (n true)))

(module+ test
  (check-equal? zero zero)
  (check-equal? zero (! (pred (succ zero))))

  ; pred zero is also zero
  (check-equal? zero (! (pred zero)))
  (check-equal? (! (is-zero? zero)) true)
  (check-equal? (! (is-zero? (succ zero))) false))

(def one (succ zero))
(def two (succ one))
(def three (succ two))
(def four (succ three))
(def five (succ four))
(def six (succ five))
(def seven (succ six))
(def eight (succ seven))
(def nine (succ eight))
(def ten (succ nine))

(module+ test
  (check-equal? zero (! (pred one))))

(def add (λ x (λ y (if (is-zero? y) x (add (succ x) (pred y))))))

(module+ test
  (check-equal? zero (! (pred (pred ((add one) one)))))
  (check-equal? 7 (! (lambda->number ((add three) four)))))

(def sub (λ x (λ y (if (is-zero? y) x (sub (pred x) (pred y))))))

(module+ test
  (check-equal? 5 (! (lambda->number ((sub ((add three) four)) two)))))
