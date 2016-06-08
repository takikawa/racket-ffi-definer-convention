#lang racket/base

(require "main.rkt"
         ffi/unsafe
         (only-in ffi/unsafe/define make-not-available)
         racket/string
         (for-syntax racket/base
                     racket/string
                     racket/syntax))

(define-ffi-definer define-rkt-1 #f #:make-c-id convention:prefix-scheme)
(define-ffi-definer define-rkt-2 #f #:make-c-id convention:hyphen->underscore)
(define-ffi-definer define-rkt-3 #f
                    #:make-c-id (compose convention:prefix-scheme
                                         convention:hyphen->underscore))

;; test name conventions
(define-rkt-1 get_milliseconds (_fun -> _int))
(define-rkt-2 scheme-get-milliseconds (_fun -> _int))
(define-rkt-3 get-milliseconds (_fun -> _int))

(get_milliseconds)
(scheme-get-milliseconds)
(get-milliseconds)

;; see if other arguments still work
(define-rkt-3 unrelated-name (_fun -> _int)
              #:c-id scheme_get_milliseconds)
(unrelated-name)

(define-rkt-1 foo (_fun -> _int)
              #:c-id scheme_get_milliseconds
              #:wrap values)
(define-rkt-1 bar (_fun -> _int)
              #:c-id scheme_get_milliseconds
              #:make-fail make-not-available)
(define-rkt-1 baz (_fun -> _int)
              #:c-id scheme_get_milliseconds
              #:fail (λ () (error "baz")))
