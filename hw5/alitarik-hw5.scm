; check the statement is if statement
(define if-stmt? (lambda (e)
	(and (list? e) (equal? (car e) 'if)  (= (length e) 4))
))

; check the statement is cond statement
(define cond-stmt? (lambda (e)
	(and (list? e) (equal? (car e) 'cond) (>= (length e) 3) (conditional-list? (cdr e)))
))

; check conditions are valid and ends with 'else' statement
(define conditional-list? (lambda (conditions)
	(cond 
        ((and (> (length conditions) 1) (list? (car conditions)) (equal? (length (car conditions)) 2) (not (equal? (caar conditions) 'else))) (conditional-list? (cdr conditions)))
        ((and (equal? (length conditions) 1) (equal? (caar conditions) 'else)) #t)
        (else #f)
    )
))

; check the statement is operation statement
(define op-stmt? (lambda (e)
	(or
        (equal? (car e) '+)
        (equal? (car e) '-)
        (equal? (car e) '*)
        (equal? (car e) '/)
    )
))
  
; check the statement is define statement
(define define-stmt? (lambda (e)
	(and (list? e) (equal? (car e) 'define) (symbol? (cadr e)) (= (length e) 3))
))

(define let-stmt? (lambda (e)
    (and (list? e) (= (length e) 3) (equal? (car e) 'let) (var-binding-list? (cadr e)))
))

(define let-star-stmt? (lambda (e)
    (and (list? e) (= (length e) 3) (equal? (car e) 'let*) (var-binding-list? (cadr e)))
))


; check the bindings are length of 2 and valid
(define var-binding-list? (lambda (vars)
    (if (null? vars)
        #t
        (and
            (= (length (car vars)) 2)
            (symbol? (caar vars))
            (var-binding-list? (cdr vars))
        )
    )
))

; apply define statement to env list
(define extend-env (lambda (var val old-env)
    (cond
        ((null? old-env) (cons (cons var val) '()))
        ((equal? (caar old-env) var) (cons (cons var val) (cdr old-env)))
        (else (cons (car old-env) (extend-env var val (cdr old-env))))
    )
))

; get the value of var from env
(define get-value (lambda (var env)
    (cond
        ((null? env) #f)
        ((equal? (caar env) var) (cdar env))
        (else (get-value var (cdr env)))
    )
))



(define interpret-if (lambda (e env) 
    (if (equal? (s7 (car e) env) 0) ; check value==0
        (s7 (caddr e) env) ; if it is 0, interpret 3rd expr
        (s7 (cadr e) env) ; else, interpret 4th expr
    )
))

(define interpret-cond
  (lambda (clauses env)
    (cond
        ((equal? (caar clauses) 'else) (s7 (cadar clauses) env))
        ((not (equal? (s7 (caar clauses) env) 0)) (s7 (cadar clauses) env))
        (else (interpret-cond (cdr clauses) env))
    )
))

(define interpret-op (lambda (e env)
    (cond 
        ((equal? (car e) '+) (apply + (interpret-args (cdr e) env)))
        ((equal? (car e) '-) (apply - (interpret-args (cdr e) env)))
        ((equal? (car e) '*) (apply * (interpret-args (cdr e) env)))
        ((equal? (car e) '/) (apply / (interpret-args (cdr e) env)))
    )
))

(define interpret-args (lambda (exprs env)
    (if (null? exprs)
        '()
        (cons
            (s7 (car exprs) env)
            (interpret-args (cdr exprs) env)
        )
    )
))

(define interpret-let-args (lambda (args env)
    (if (null? args)
        args
        (cons (cons (caar args) (s7 (cadar args) env)) (interpret-let-args (cdr args) env))
    )
))

(define interpret-let-star-args (lambda (args env)
    (if (null? args)
        env
        (interpret-let-star-args (cdr args) (cons (cons (caar args) (s7 (cadar args) env)) env))
    )
))


(define interpret-let (lambda (vars body env)
    (let 
        ((new-env (append (interpret-let-args vars env) env)))
        (s7 body new-env)
    )
))

(define interpret-let-star (lambda (vars body env)
    (s7 body (interpret-let-star-args vars env))
))

; get input and display values
(define repl (lambda (env)
    (let* (
        (dummy1 (display "cs305> "))
        (expr (read))
        (new-env
            (if (define-stmt? expr)
                (extend-env (cadr expr) (s7 (caddr expr) env) env)
                env
            )
        )
        (val (if (define-stmt? expr)
            (cadr expr)
            (s7 expr env))
        )
        (dummy2 (display "cs305: "))
        (dummy3
            (if (equal? val #f)
                (display "ERROR")
                (display val)
            )
        )
        (dummy4 (newline))
        (dummy4 (newline)))
        (repl new-env)
    )
))

; main interpreter
(define s7 (lambda (e env)
    (cond
        ((number? e) e)
        ((symbol? e) (get-value e env))
        ((if-stmt? e) (interpret-if (cdr e) env))
        ((cond-stmt? e) (interpret-cond (cdr e) env))
        ((op-stmt? e) (interpret-op e env))
        ((let-stmt? e) (interpret-let (cadr e) (caddr e) env))
        ((let-star-stmt? e) (interpret-let-star (cadr e) (caddr e) env))
        (else #f)
    )
))


; repl with clean environment
(define cs305 (lambda () (repl '())))