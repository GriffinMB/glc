#lang racket

(require (only-in glc/base/expander normalize-app lambda->number)

         (rename-in lazy (lambda lazy:lambda))

         (for-syntax racket/syntax syntax/parse racket/list))

(provide (rename-out [glc-simply-typed-module-begin #%module-begin]
                     [glc-simply-typed-app #%app]
                     [glc-simply-typed-datum #%datum]
                     [glc-simply-typed-top #%top]
                     [glc-simply-typed-lambda lambda]
                     [glc-simply-typed-lambda λ])

         ; provide/require
         require

         ; test helpers
         module+

         ; primitives
         !
         !!

         ; base
         def
         lambda->number
         :

         ; module exports
         #%top-interaction)

(define-syntax (glc-simply-typed-module-begin stx)
  (syntax-parse stx
    [(_:id expr ...)
     #'(#%module-begin
        expr ...)]))

(define-syntax (: stx)
  (syntax-parse stx
    [(_ id:id type:expr)
     (with-syntax ([type-id (format-id stx "glc-type-~a" #'id)])
       #'(define-for-syntax type-id 'type))]))

(define-syntax (glc-simply-typed-lambda stx)
  (syntax-parse stx
    [(_ (~or x:id (x:id)) expr) #'(lazy:lambda (x) expr)]))

(define-syntax (glc-simply-typed-app stx)
  (define normalized (datum->syntax stx (normalize-app (cdr (syntax->datum stx)))))

  (when (equal? (syntax-local-context) 'module)
    (typecheck normalized (make-immutable-hash)))

  (syntax-parse normalized
    [(x y) #'(#%app x y)]))

(define-syntax (glc-simply-typed-datum stx)
  (raise-syntax-error #f "Invalid use of datum literal" stx))

(define-syntax-rule (glc-simply-typed-top . id)
  'id)

(define-syntax (def stx)
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
          ; TODO fix error case - i.e. the id won't syntax-match a literal λ or lambda???
          [(lam:id (~or id:id (id:id)) expr)
           (let* ([lam (syntax-e #'lam)]
                  [sl (equal? lam 'lambda)]
                  [ss (equal? lam 'λ)])
             (if (or sl ss)
                 (set-context #'expr type-tail (hash-set env [syntax-e #'id] type-head))
                 (raise "Lambda expected")))])
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
                    (if (match-type? y-type x1)
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

(define-for-syntax (match-type? y x [tkn #f])
  (cond
    ; basic type case
    [(equal? y x) #t]

    ; U constructor
    [(equal? tkn 'U) (index-of x y)]

    [(list? x) (match-type? y (cdr x) (car x))]

    ; no match or parameterized
    [else #f]))
