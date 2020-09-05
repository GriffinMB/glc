#lang lambda-calculus

(def x (pred (pred two)))

(((if (is-zero? x)) its-zero!) its-not-zero!)

(succ zero)
