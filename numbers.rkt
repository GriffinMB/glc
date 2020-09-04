#lang lambda-calculus/base

(require "core.rkt")
(provide (all-defined-out))

(def zero identity)

(def succ (λ n (λ s ((s false) n))))
