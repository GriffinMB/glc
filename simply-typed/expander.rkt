#lang racket

(require (except-in glc/base/expander #%app)

         "../shared/cond.rkt"
         "../shared/core.rkt"
         "../shared/numbers.rkt"
         "../shared/list.rkt"

         (for-syntax racket/syntax syntax/parse racket/list))

(provide (except-out (all-from-out glc/base/expander) def)

         (all-from-out "../shared/cond.rkt")
         (all-from-out "../shared/core.rkt")
         (all-from-out "../shared/numbers.rkt")
         (all-from-out "../shared/list.rkt")

         (rename-out [glc-simply-typed-def def]
                     [glc-simply-typed-app #%app])

         :)

(define-syntax (: stx)
  (syntax-parse stx
    [(_ id:id type:expr)
     (with-syntax ([type-id (format-id stx "glc-type-~a" #'id)])
       #'(define-for-syntax type-id 'type))]))

(define-syntax (glc-simply-typed-app stx)
  (define normalized (datum->syntax stx (normalize-app (cdr (syntax->datum stx)))))

  (when (equal? (syntax-local-context) 'module)
    (typecheck normalized (make-immutable-hash)))

  (syntax-parse normalized
    ;; Not sure why app isn't automatically forceing here.
    [(x y) #'(!! (#%app x y))]))

(define-syntax (glc-simply-typed-def stx)
  (syntax-parse stx
    [(_ id:id expr:expr)
     (with-syntax ([type-id (format-id stx "glc-type-~a" #'id)])
       (let*-values ([(type) (eval-syntax #'type-id)]
                     [(env) (make-immutable-hash)]
                     [(ctx base) (set-context #'expr type env)]
                     [(normalized) (datum->syntax base (normalize-app (syntax->datum base)))])

         (if (equal? (last type) (typecheck normalized ctx))
             #'(define id expr)
             (raise (format "~a does not have type ~a" (syntax-e #'id) type)))))]))

(define-for-syntax (set-context stx type-id env)
  (let ([type-head (car type-id)]
        [type-tail (cdr type-id)])

    (if (> (length type-tail) 0)
        (syntax-parse stx
          ; TODO add error case
          [((~or (~literal λ) (~literal lambda)) (~or id:id (id:id)) expr)
           (set-context #'expr type-tail (hash-set env [syntax-e #'id] type-head))])
        (values env stx))))

(define-for-syntax (typecheck stx env)
  (syntax-parse stx
    [((~or (~literal λ) (~literal lambda)) _ _)
     (void)]
    [x:id (with-syntax ([type-id (format-id stx "glc-type-~a" #'x)])
            (hash-ref env (syntax-e #'x) (lambda () (eval-syntax #'type-id))))]
    [(x y) (let* ([x-type (typecheck #'x env)]
                  [y-type (typecheck #'y env)]
                  [x1 (car x-type)]
                  [xrest (cdr x-type)]
                  [sx1 (format "~a" x1)])

             (let ([return-type
                    (if (equal? y-type x1)
                        xrest
                        (if (equal? sx1 (string-downcase sx1))
                            (map (lambda (var)
                                   (if (equal? var x1)
                                       y-type
                                       var))
                                 xrest)
                            (raise (format "Type ~a does not match type ~a" y-type x-type))))])

               (if (equal? (length return-type) 1)
                   (car return-type)
                   return-type)))]
    [x (displayln #'x)]))
