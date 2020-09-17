#lang lambda-calculus/base

(require "core.rkt")
(provide (all-defined-out))

(module+ test
  (require rackunit))

(def cond
  (λ e1
    (λ e2
      (λ c (c e1 e2)))))

(module+ test
  (check-equal? x (! (((cond x) y) true)))
  (check-equal? y (! (((cond x) y) false))))

(def if
  (λ c
    (λ e1
      (λ e2 (c e1 e2)))))

(module+ test
  (check-equal? x (! (((if true) x) y)))
  (check-equal? y (! (((if false) x) y))))

(def not (λ x (x false true)))

(module+ test
  (check-equal? false (! (not true)))
  (check-equal? true (! (not false))))

(def and
  (λ x
    (λ y (x y false))))

(module+ test
  (check-equal? false (! ((and true) false)))
  (check-equal? true (! ((and true) true))))

(def or
  (λ x
    (λ y (x true y))))

(module+ test
  (check-equal? true (! ((or true) false)))
  (check-equal? false (! ((or false) false)))
  (check-equal? true (! ((or true) true))))
