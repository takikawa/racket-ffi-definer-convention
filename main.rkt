#lang racket/base

;; Overrides `define-ffi-definer` and adds a renaming option

(require ffi/unsafe
         (prefix-in orig: ffi/unsafe/define)
         (for-syntax racket/base
                     syntax/parse
                     "conventions.rkt"))

(provide define-ffi-definer
         (for-syntax (all-from-out "conventions.rkt")))

(begin-for-syntax
  (define-splicing-syntax-class options
    #:attributes (maker-expr
                  provide-id
                  core-define-id
                  default-make-fail-expr)
    (pattern (~seq (~or (~optional (~seq #:make-c-id maker-expr:expr)
                                   #:defaults ([maker-expr #f]))
                        (~optional (~seq #:provide provide-id)
                                   #:defaults ([provide-id #f]))
                        (~optional (~seq #:define core-define-id)
                                   #:defaults ([core-define-id #f]))
                        (~optional (~seq #:default-make-fail
                                         default-make-fail-expr)
                                   #:defaults ([default-make-fail-expr #f])))
                   ...))))

(define-syntax (define-wrapper-definer stx)
  (syntax-parse stx
    [(_ ?define-id ?temp-define ?maker-expr)
     #'(define-syntax (?define-id stx)
         (syntax-case stx ()
           [(_ ??id ??type . opts)
            (quasisyntax/loc stx
              (?temp-define ??id ??type
                            (unsyntax-splicing
                              (if (member '#:c-id
                                          (map syntax-e (syntax->list (syntax opts))))
                                  (list)
                                  (list #'#:c-id
                                        (?maker-expr (syntax ??id)))))
                            . opts))]))]))

(define-syntax (define-ffi-definer stx)
  (syntax-parse stx
    [(_ ?define-id:id ?ffi-lib-expr:expr ?opts:options)
     (with-syntax ([(?temp-define) (generate-temporaries (list 1))])
       (quasisyntax/loc stx
         (begin
           (define-wrapper-definer ?define-id
                                   ?temp-define
                                   #,(or (attribute ?opts.maker-expr)
                                         #'(λ (x) x)))
           (orig:define-ffi-definer
            ?temp-define ?ffi-lib-expr
            #,@(if (attribute ?opts.core-define-id)
                   (list #'#:define #'?opts.core-define-id)
                   (list))
            #,@(if (attribute ?opts.provide-id)
                   (list #'#:provide #'?opts.provide-id)
                   (list))
            #,@(if (attribute ?opts.default-make-fail-expr)
                   (list #'#:default-make-fail #'?opts.default-make-fail-expr)
                   (list))))))]))
