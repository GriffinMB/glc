#lang glc/simply-typed

(: if (Boolean n n n))
(: succ (Number Number))
(: add (Number Number Number))
(: zero Number)
(: one Number)
(: two Number)
(: three Number)
(: four Number)
(: true Boolean)
(: false Boolean)
(: lambda->number (Number Void))

(: a (Number Number Number))
(def a (λ x (λ y (add (succ one) y))))

(: b (Boolean Boolean))
(def b (λ x (if x (if x true false) false)))

(: add-x (Number (Number Number)))
(def add-x (λ x (add x)))

(lambda->number (add one two))
(lambda->number ((add-x four) one))
