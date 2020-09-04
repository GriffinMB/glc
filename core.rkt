#lang lambda-calculus/base

(provide (all-defined-out))

(def identity (λ x x))

(def true (λ x (λ y x)))
(def false (λ x (λ y y)))

(def select-first true)
(def select-second false)
