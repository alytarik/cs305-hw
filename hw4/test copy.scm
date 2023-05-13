(define (listand func lst)
    (cond
        ((null? lst) #t)
        ((and 
            (func (car lst))
            (listand func (cdr lst))
        ) #t)
        (else #f)
    )
)

(define check-triple?
    (lambda (tripleList)
        (and 
            (listand (lambda (x) (check-length? x 3)) tripleList) ;check if lenght is 
            (listand check-sides? tripleList) ;check if sides are positive
        )
    )
)

(define check-length?
    (lambda (inTriple count)
        (= (length inTriple) count)
    )
)

(define check-sides?
    (lambda (inTriple)
        (and
            (listand number? inTriple) ;check values are numbers
            (listand (lambda (x) (> x 0)) inTriple) ;check values are positive
        )
    )
)



(check-triple? '((1 2) (3 4 5)))
(check-triple? '((5 12 12) (6 6 6) ()))
(check-triple? '((5 3 9) (9 55 32) ('a 28 67)))
(check-triple? '((5 12 13) (3 4 5) (16 63 65) (12 35 37)))
(check-triple? '((5 12 13) (3 4 5) (16 0 65) (12 35 37)))