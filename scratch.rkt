#lang lambda-calculus

(def identity (λ (x) x))

(identity true)

(((cond x) y) true)
(((cond x) y) false)

(((if true) x) y)
