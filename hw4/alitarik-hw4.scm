(define (applyand func lst)
    (if (null? lst)
        #t
        (and 
            (func (car lst))
            (applyand func (cdr lst))
        )
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
        (if (null? inTriple)
            (= count 0)
            (check-length? (cdr inTriple) (- count 1))
        )
    )
)

(define check-sides?
    (lambda (inTriple)
        (and
            (applyand integer? inTriple) ;check values are numbers
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
        (insertion-sort inTriple <) 
    )
)

(define filter-triangle
    (lambda (tripleList)
        (if (null? tripleList)
            tripleList
            (if (triangle? (car tripleList))
                (cons (car tripleList) (filter-triangle (cdr tripleList)))
                (filter-triangle (cdr tripleList))
            )
        )
    )
)

(define triangle?
    (lambda (triple)
    (> 
        (+ (car triple) (cadr triple)) ; a+b
        (caddr triple) ; c
    )
    )
)

(define filter-pythagorean
    (lambda (tripleList)
        (if (null? tripleList)
            tripleList
            (if (pythagorean-triangle? (car tripleList))
                (cons (car tripleList) (filter-pythagorean (cdr tripleList)))
                (filter-pythagorean (cdr tripleList))
            )
        )
    )
)

(define pythagorean-triangle?
    (lambda (triple)
        (= 
            (+
                (* (car triple) (car triple)) ; a^2
                (* (cadr triple) (cadr triple)); b^2
            )
            (* (caddr triple) (caddr triple)) ; c^2
        )
    )
)

(define (insertion-sort mlist func)
    (define (insert mlist element)
        (cond
            ((null? mlist) (list element))
            ((func element (car mlist)) (cons element mlist))
            (else (cons (car mlist) (insert (cdr mlist) element)))
        )
    )
    
    (define (insertion-sort-helper sorted mlist)
        (if (null? mlist)
            sorted
            (insertion-sort-helper (insert sorted (car mlist)) (cdr mlist))
        )
    )
    
    ; start from empty list and insert min
    (insertion-sort-helper '() mlist)
)

(define sort-area
    (lambda (tripleList)
        (insertion-sort tripleList (lambda (x y) (< (get-area x) (get-area y))))
    )
)

(define get-area
    (lambda (triple)
        (/ (* (car triple) (cadr triple)) 2) ; a*b/2
    )
)

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

(main-procedure '((1.5 2.5 3)))