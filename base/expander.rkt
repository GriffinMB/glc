#lang racket

(require syntax/parse racket/require
         (rename-in lazy (lambda lazy:lambda))
         (for-syntax racket/syntax racket/list syntax/parse))

(provide (rename-out [glc-module-begin #%module-begin]
                     [glc-lambda lambda]
                     [glc-lambda λ]
                     [glc-app #%app]
                     [glc-datum #%datum]
                     [glc-top #%top])

         (for-syntax normalize-app)

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
  (define normalized (normalize-app (cdr (syntax->datum stx))))

  (syntax-parse (datum->syntax stx normalized)
    [(x y) #'(#%app x y)]))

(define-for-syntax (normalize-app dat)
  (if (and (list? dat) (<= 2 (length dat)))
      (let*-values ([(abs?) (equal? (car dat) 'λ)]
                    [(split) (if abs? 3 2)]
                    [(left right) (split-at dat split)]
                    [(empty-right?) (empty? right)]
                    [(lleft) (car left)]
                    [(rleft) (car (cdr left))])

        (cond
          [(and abs? empty-right?)
           (list lleft rleft (normalize-app (third left)))]
          [empty-right? (cons (normalize-app lleft) (list (normalize-app rleft)))]
          [else (normalize-app (cons left right))]))

      dat))

(define-syntax (glc-datum stx)
  (raise-syntax-error #f "Invalid use of datum literal" stx))

(define-syntax-rule (glc-top . id)
  'id)

(define-syntax (def stx)
  (syntax-parse stx
    [(_ id:id expr:expr)
     #'(define id expr)]))
