#lang lambda-calculus/base

(require "core.rkt")
(provide (all-defined-out))

(def cond
  (λ e1
    (λ e2
      (λ c ((c e1) e2)))))

(def if
  (λ c
    (λ e1
      (λ e2 ((c e1) e2)))))

(def not (λ x ((x false) true)))

(def and
  (λ x
    (λ y ((x y) false))))

(def or
  (λ x
    (λ y ((x true) y))))
