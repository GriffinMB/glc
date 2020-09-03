#lang racket

(require syntax/parse
         (for-syntax racket/syntax syntax/parse))

(provide (rename-out [module-begin #%module-begin]
                     [i-lambda lambda]
                     [i-lambda λ]
                     [app #%app]
                     [no-literals #%datum]
                     [unbound-as-quoted #%top])

         def require provide

         ; module exports
         #%top-interaction)

(define-syntax (module-begin stx)
  (syntax-parse stx
    [(_:id expr ...)
     #'(#%module-begin
        expr ...)]))

(define-syntax (i-lambda stx)
  (syntax-parse stx
    [(_ (~or x:id (x:id)) expr) #'(lambda (x) expr)]))

(define-syntax-rule (app x y)
  (#%app x y))

(define-syntax (no-literals stx)
  (raise-syntax-error #f "no" stx))

(define-syntax-rule (unbound-as-quoted . id)
  'id)

(define-syntax (def stx)
  (syntax-parse stx
    [(_ id:id expr:expr)
     #'(define id expr)]))
