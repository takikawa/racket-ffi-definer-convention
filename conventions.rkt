#lang racket/base

;; Functions that transform identifiers to implement certain FFI
;; naming conventions

(require racket/string
         racket/syntax)

(provide convention:hyphen->underscore
         convention:hyphen->camelcase
         convention:prefix-scheme)

(define (convention:hyphen->underscore id)
  (format-id
   id
   (string-replace (symbol->string (syntax-e id)) "-" "_")))


(define (convention:hyphen->camelcase id)
  (define str (symbol->string (syntax-e id)))
  (format-id id
             (apply string-append
                    (map string-titlecase (string-split str "-")))))

(define (convention:prefix-scheme id)
  (format-id id "scheme_~a" (syntax-e id)))
