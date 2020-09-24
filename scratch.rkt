#lang glc/simply-typed

(: if (Boolean n n))

(if true hello bye)

((if false) zz zzz)

(lambda->number ((add one) two))

;(: test (-> Any Any))
;(def test (λ x x))
;(test hello-world)

(: b (Boolean Any))
(def b (λ x (if x hello byebye)))

(: a Boolean)
(def a (λ x (λ y x)))

(b true)

(lambda->number ((λ x (x two two)) add))


(: jj Number)
(def jj (((if false) one) zero))
