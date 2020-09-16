#lang lambda-calculus/base

(require "core.rkt" "cond.rkt" "numbers.rkt")
(provide (all-defined-out))

(module+ test
  (require (only-in racket #%datum) rackunit))

(def nil (λ _ (λ _ true)))
(def cons (λ h (λ t (λ s ((s (λ s2 ((s2 h) false))) t)))))
(def head (λ list ((list select-first) select-first)))
(def tail (λ list (list select-second)))
(def is-empty? (λ list ((list select-first) select-second)))
(def length (λ list (((if (is-empty? list)) zero) (succ (length (tail list))))))

(module+ test
  (check-equal? true (! (is-empty? nil)))
  (check-equal? a (! (head ((cons a) nil))))
  (check-equal? 0 (! (lambda->number (length (tail ((cons a) nil))))))
  (check-equal? 2 (! (lambda->number (length [[cons b] [[cons a] nil]])))))
