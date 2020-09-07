#lang lambda-calculus

(def x (pred (pred two)))

(if (is-zero? x) is-zero is-not-zero)
