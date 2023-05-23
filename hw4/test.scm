(define (insertion-sort lst func)
    (define (insert lst element)
        (cond
            ((null? lst) (list element))
            ((func element (car lst)) (cons element lst))
            (else (cons (car lst) (insert (cdr lst) element)))
        )
    )
    
    (define (insertion-sort-helper sorted lst)
        (cond 
            ((null? lst) sorted)
            (else (insertion-sort-helper (insert sorted (car lst)) (cdr lst)))
        )
    )
    
    (insertion-sort-helper '() lst)
)

;; Example usage:
(insertion-sort '(5 2 8 1 9) <)  ; Returns: (1 2 5 8 9)
(insertion-sort '((1 2) (3 9) (5 1)) (lambda (x y) (< (cadr x) (cadr y))))  ; Returns: (1 2 5 8 9)