#lang glc/simply-typed

(: if (Boolean n n n))
(: succ (Number Number))
(: add (Number Number Number))
(: zero Number)
(: one Number)
(: two Number)
(: three Number)
(: four Number)
(: nil Nil)
(: true Boolean)
(: false Boolean)
(: lambda->number (Number Void))

(: cons (Number (U (List Number) Nil) (List Number)))
(: head ((List Number) Number))

(: a (Number Number Number))
(def a (λ x (λ y (add (succ one) y))))

(: b (Boolean Boolean))
(def b (λ x (if x (if x true false) false)))

(: add-x (Number (Number Number)))
(def add-x (λ x (add x)))

(: c (Boolean Boolean))
(def c (λ x (if x true (c x))))

(lambda->number (add one two))
(lambda->number ((add-x four) one))

(lambda->number (head (cons two (cons one nil))))
