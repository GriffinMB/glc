#lang lambda-calculus/base

(require "core.rkt")
(provide (all-defined-out))

(def zero identity)
(def succ (λ n (λ s ((s false) n))))
(def pred (λ n (((is-zero? n) zero) (n false))))
(def is-zero? (λ n (n true)))

(def one (succ zero))
(def two (succ (succ zero)))
(def three (succ (succ (succ zero))))
(def four (succ (succ (succ (succ zero)))))
(def five (succ (succ (succ (succ (succ zero))))))
