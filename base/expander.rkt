#lang racket

(require syntax/parse racket/require
         (rename-in lazy (lambda lazy:lambda))
         (for-syntax racket/syntax syntax/parse))

(provide (rename-out [glc-module-begin #%module-begin]
                     [glc-lambda lambda]
                     [glc-lambda λ]
                     [glc-app #%app]
                     [glc-datum #%datum]
                     [glc-top #%top])

         ; provide/require
         provide
         require
         all-defined-out
         only-in

         ; test helpers
         module+

         ; primitives
         !
         !!

         ; base
         def
         lambda->number

         ; module exports
         #%top-interaction)

(define-syntax (glc-module-begin stx)
  (syntax-parse stx
    [(_:id expr ...)
     #'(#%module-begin
        expr ...)]))

(define (lambda->number num (count 0))
  (if (equal? "#<procedure:identity>" (format "~a" num))
      count
      (lambda->number (num (lambda (x) (lambda (y) y))) (+ count 1))))

(define-syntax (glc-lambda stx)
  (syntax-parse stx
    [(_ (~or x:id (x:id)) expr) #'(lazy:lambda (x) expr)]))

(define-syntax (glc-app stx)
  (syntax-parse stx
    [(_ x y) #'(#%app x y)]
    [(_ x y z ...) #'(glc-app (#%app x y) z ...)]))

(define-syntax (glc-datum stx)
  (raise-syntax-error #f "no" stx))

(define-syntax-rule (glc-top . id)
  'id)

(define-syntax (def stx)
  (syntax-parse stx
    [(_ id:id expr:expr)
     #'(define id expr)]))
