(define main-procedure
    (lambda (tripleList)
        (if (or (null? tripleList) (not (list? tripleList)))
            (error "ERROR305: the input should be a list full of triples")
            (if (check-triple? tripleList)
                (sort-area (filter-pythagorean (filter-triangle (sort-all-triples tripleList))))
                (error "ERROR305: the input should be a list full of triples")
            )
        )
    )
)

(define (applyand func lst)
    (cond
        ((null? lst) #t)
        ((and 
            (func (car lst))
            (applyand func (cdr lst))
        ) #t)
        (else #f)
    )
)

(define check-triple?
    (lambda (tripleList)
        (and 
            (applyand (lambda (x) (check-length? x 3)) tripleList) ;check if lenght is 
            (applyand check-sides? tripleList) ;check if sides are positive
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
            (applyand number? inTriple) ;check values are numbers
            (applyand (lambda (x) (> x 0)) inTriple) ;check values are positive
        )
    )
)

(define sort-all-triples
    (lambda (tripleList)
        (map sort-triple tripleList)
    )
)

(define sort-triple
    (lambda (inTriple)
        (sort inTriple <) 
    )
)

(define filter-triangle
    (lambda (tripleList)
        (filter triangle? tripleList)
    )
)

(define triangle?
    (lambda (triple)
    (> 
        (+ (car triple) (cadr triple))
        (caddr triple)
    )
    )
)

(define filter-pythagorean
    (lambda (tripleList)
        (filter pythagorean-triangle? tripleList)
    )
)

(define pythagorean-triangle?
    (lambda (triple)
        (= 
            (* (caddr triple) (caddr triple)) ; c^2
            (+
                (* (car triple) (car triple)) ; a^2
                (* (cadr triple) (cadr triple)); b^2
            )
        )
    )
)

(define sort-area
    (lambda (tripleList)
        (sort tripleList (lambda (x y) (< (get-area x) (get-area y))))
    )
)

(define get-area
    (lambda (triple)
        (/ (* (car triple) (cadr triple)) 2) ; a*b/2
    )
)


(main-procedure '((6 10 8) (5 4 3) (1 2 3)))