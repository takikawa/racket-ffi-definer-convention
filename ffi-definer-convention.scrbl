#lang scribble/manual

@(require scribble/example
          (for-label racket/base
                     ffi-definer-convention))

@(define ev (make-base-eval))
@(ev '(require racket/function ffi/unsafe ffi-definer-convention))
@(ev '(require (for-syntax racket/base racket/string racket/syntax)))

@(module sub racket/base
   (require scribble/manual
            (for-label ffi/unsafe/define))
   (provide dfd-id)
   (define dfd-id (racket define-ffi-definer)))
@(require 'sub)

@title{ffi-definer-convention: augments @racket[define-ffi-definer]}
@author{Asumu Takikawa}

@defmodule[ffi-definer-convention]

This module overrides the @dfd-id form from @racketmodname[ffi/unsafe/define]
to allow the use of naming conventions that translate from Racket identifiers
to C identifiers.

@defform/subs[(define-ffi-definer define-id ffi-lib-expr option ...)
              ([option other-options
                       (code:line #:make-c-id make-c-id-expr)])]{

Overrides the @dfd-id form, adding a new keyword argument @racket[#:make-c-id].
When @racket[make-c-id-expr] is provided, its result is called to create
an identifier argument that is provided for the @racket[#:c-id] keyword
argument of the defined definer. This function expression is evaluated
at syntax phase (phase level 1).

@examples[#:eval ev
(begin-for-syntax
  (define (prefix-scheme id)
    (format-id id "scheme_~a" (syntax-e id)))

  (define (hyphen->underscore id)
    (format-id
     id
     (string-replace (symbol->string (syntax-e id)) "-" "_"))))

(define-ffi-definer define-rkt #f
                    #:make-c-id (compose prefix-scheme
                                         hyphen->underscore))
(define-rkt get-milliseconds (_fun -> _int))
(get-milliseconds)
]
}

@deftogether[(@defproc[(convention:hyphen->underscore [id identifier?])
                       identifier?]
              @defproc[(convention:hyphen->camelcase [id identifier?])
                       identifier?]
              @defproc[(convention:prefix-scheme [id identifier?])
                       identifier?])]{

These functions are intended for use with the @racket[#:make-c-id]
keyword argument for @racket[define-ffi-definer]. They encode common
naming conventions for foreign functions.

All of these functions are provided at syntax phase (phase level 1).

@examples[#:eval ev
(begin-for-syntax
  (displayln (convention:hyphen->underscore #'hello-world))
  (displayln (convention:hyphen->camelcase #'hello-world))
  (displayln (convention:prefix-scheme #'hello_world)))
]
}
