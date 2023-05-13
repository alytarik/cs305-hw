
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

(sort-area '(
    (3 4 5)
    (8 40 41)
    (7 24 25)
    (6 8 10)
))