#lang racket

(require glc/base/expander
         "../shared/cond.rkt"
         "../shared/core.rkt"
         "../shared/numbers.rkt"
         "../shared/list.rkt"

         (rename-in glc/base/expander [#%app glc-app])

         (for-syntax racket/syntax syntax/parse racket/list))

(provide (except-out (all-from-out glc/base/expander)
                     #%module-begin
                     #%app
                     def)

         (all-from-out "../shared/cond.rkt")
         (all-from-out "../shared/core.rkt")
         (all-from-out "../shared/numbers.rkt")
         (all-from-out "../shared/list.rkt")

         (rename-out [glc-simply-typed-module-begin #%module-begin]
                     [glc-simply-typed-def def]
                     [glc-simply-typed-app #%app])

         :)

(define-syntax (glc-simply-typed-module-begin stx)
  (syntax-parse stx
    [(_:id expr ...)
     (begin
       (get-requires #'(expr ...))

       #'(#%module-begin
          expr ...))]))

(define-for-syntax (get-requires stx)
  (syntax-parse stx
    [((id:id arg) ~rest stx)
     (begin
       (if (equal? (syntax-e #'id) 'require)
           (namespace-require (syntax-e #'arg))
           (void))
       (get-requires #'stx))]
    [_ (void)]))

(define-syntax (: stx)
  (syntax-parse stx
    [(_ id:id type:id)
     (with-syntax ([type-id (format-id stx "glc-type-~a" #'id)])
       #'(define-for-syntax type-id '(type)))]
    [(_ id:id type:expr)
     (with-syntax ([type-id (format-id stx "glc-type-~a" #'id)])
       #'(define-for-syntax type-id 'type))]))

(define-syntax (glc-simply-typed-app stx)
  (when (equal? (syntax-local-context) 'module)
    (displayln (nest-app (cdr (syntax->datum stx))))
    (displayln stx))

  (syntax-parse stx
    [(_ x ...) (with-syntax ([app #'(glc-app x ...)])
                 ;(displayln (nest-app #'(x ...)))
                 ;(displayln #'(x ...))
                 #'app)]))

(define-for-syntax (nest-app dat [lst '()])
  (if (and (list? dat) (<= 2 (length dat)))
      (let*-values ([(abs?) (equal? (car dat) 'λ)]
                    [(split) (if abs? 3 2)]
                    [(left right) (split-at dat split)]
                    [(empty-right?) (empty? right)]
                    [(lleft) (car left)]
                    [(rleft) (car (cdr left))])
        (cond
          [(and abs? empty-right?)
           (list lleft rleft (nest-app (third left)))]
          [empty-right? (cons (nest-app lleft) (list (nest-app rleft)))]
          [else (nest-app (cons left right))]))

      dat))

(define-syntax (glc-simply-typed-def stx)
  (syntax-parse stx
    [(_ id:id expr:expr)
     (with-syntax* ([type-id (format-id stx "glc-type-~a" #'id)])
       ;(displayln (eval-syntax #'type-id))
       (typecheck #'expr (make-immutable-hash (list (cons 'top (eval-syntax #'type-id)))))
       #'(define id expr))]))

(define-for-syntax (typecheck-lambda id expr env)
  (define type-spec (hash-ref env 'top))
  (define type-head (car type-spec))
  (define type-tail (cdr type-spec))

  (when (> (length type-tail) 0)
    (typecheck expr (hash-set* env [syntax-e id] type-head 'top type-tail))))

(define-for-syntax (typecheck stx env)
  ;(displayln stx)
  (syntax-parse stx
    [((~or (~literal λ) (~literal lambda)) (~or x:id (x:id)) expr)
     (typecheck-lambda #'x #'expr env)]
    [(_) (void)]
    [_ (void)])
  ;(displayln (syntax->list stx))
  (void))

(define-for-syntax (get-type stx env)
  (syntax-parse stx
    [(x:id) (void)]
    [(x:id y:expr)
     (typecheck-lambda #'x #'expr env)]))
