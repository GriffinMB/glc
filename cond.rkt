#lang lambda-calculus/base

(provide true false
         cond if
         not and or)

(def true (λ x (λ y x)))

(def false (λ x (λ y y)))

(def cond
  (λ e1
    (λ e2
      (λ c ((c e1) e2)))))

(def if
  (λ c
    (λ e1
      (λ e2 (((cond e1) e2) c)))))

(def not (λ x ((x false) true)))

(def and
  (λ x
    (λ y ((x y) false))))

(def or
  (λ x
    (λ y ((x true) y))))
