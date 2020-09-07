#lang racket

(require syntax/parse racket/require
         (for-syntax racket/syntax syntax/parse))

(provide (rename-out [module-begin #%module-begin]
                     [i-lambda lambda]
                     [i-lambda λ]
                     [app #%app]
                     [no-literals #%datum]
                     [unbound-as-quoted #%top])

         ; provide/require
         provide
         require
         all-defined-out
         only-in

         ; test helpers
         module+

         ; primitives
         if

         def
         print

         ; module exports
         #%top-interaction)

(define-syntax (module-begin stx)
  (syntax-parse stx
    [(_:id expr ...)
     #'(#%module-begin
        expr ...)]))

(define (print proc)
  (displayln (eval (get-lambda-proc proc))))

(define (get-lambda-proc p)
  (define proc (format "~a" p))

  (string->symbol
   (format "lambda~a"
           (string-trim proc (regexp "[#<>]") #:repeat? #t))))

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
     (with-syntax ([lambda-proc (format-id stx "lambdaprocedure:~a" (syntax-e #'id))])
       #'(begin
           (define id expr)
           (define lambda-proc 'expr)))]))
