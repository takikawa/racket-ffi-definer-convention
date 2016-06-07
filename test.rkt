#lang racket/base

(require "main.rkt"
         ffi/unsafe
         racket/string
         (for-syntax racket/base
                     racket/string
                     racket/syntax))

(begin-for-syntax
  (define (prefix-scheme id)
    (format-id id "scheme_~a" (syntax-e id)))

  (define (hyphen->underscore id)
    (format-id
     id
     (string-replace (symbol->string (syntax-e id)) "-" "_"))))

(define-ffi-definer define-rkt-1 #f #:make-c-id prefix-scheme)
(define-ffi-definer define-rkt-2 #f #:make-c-id hyphen->underscore)
(define-ffi-definer define-rkt-3 #f
                    #:make-c-id (compose prefix-scheme
                                         hyphen->underscore))

(define-rkt-1 get_milliseconds (_fun -> _int))
(define-rkt-2 scheme-get-milliseconds (_fun -> _int))
(define-rkt-3 get-milliseconds (_fun -> _int))
(define-rkt-3 unrelated-name (_fun -> _int)
              #:c-id scheme_get_milliseconds)

(get_milliseconds)
(scheme-get-milliseconds)
(get-milliseconds)
(unrelated-name)
