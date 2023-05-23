(define s8-interpret (lambda (e env)
  (cond
    ((number? e) e)

    ((symbol? e) (get-value e env))

    ((not (list? e)) (error "s8-interpret: cannot evaluate -->" e))

    ((if-stmt? e)
      (if (eq? (s8-interpret (cadr e) env) 0)
          (s8-interpret (cadddr e) env)
          (s8-interpret (caddr e) env)
      )
    )
          
    ((let-stmt? e)
      (let
        (
          (names (map car (cadr e)))
          (inits (map cadr (cadr e)))
        )
        (let
          ((vals (map (lambda (init) (s8-interpret init env)) inits)))

          (
            let
            (
              (new-env (append (map cons names vals) env))
            )
            (s8-interpret (caddr e) new-env)
            )
        )
      )
    )


  ((letstar-stmt? e) 
    (if (= (length (cadr e)) 1)
      (let 
        ((l (list 'let (cadr e) (caddr e)))) 
          (let ((names (map car (cadr l))) (inits (map cadr (cadr l))))
        (let ((vals (map (lambda (init) (s8-interpret init env)) inits)))
        (let ((new-env (append (map cons names vals) env)))
          (s8-interpret (caddr l) new-env))))
      )


      (let ((first (list 'let (list (caadr e)))) (rest (list 'let* (cdadr e) (caddr e))))
      (let ((l (append first (list rest)))) (let ((names (map car (cadr l))) (inits (map cadr (cadr l))))
        (let ((vals (map (lambda (init) (s8-interpret init env)) inits)))
          (let ((new-env (append (map cons names vals) env)))
          (s8-interpret (caddr l) new-env))))))
  ))



    (else (cond ((lambda-stmt? (car e)) (if (= (length (cadar e)) (length (cdr e)))
  (let* ((par (map s8-interpret (cdr e) (make-list (length (cdr e)) env))) (nenv (append (map cons (cadar e) par) env))) (s8-interpret (caddar e) nenv))
    (error "s8-interpret: number of formal parameters and actual parameters do not match")))
      ((built-in-op? (car e))(let ((operands (map s8-interpret (cdr e) (make-list (length (cdr e)) env))) (operator (get-operator (car e) env)))
      (cond ((and (equal? operator '+) (= (length operands) 0)) 0)
        ((and (equal? operator '*) (= (length operands) 0)) 1)
          ((and (or (equal? operator '-) (equal? operator '/)) (= (length operands) 0)) (error "s8-interpret: need at least to operands for this operator -->" operator))
          (else (apply operator operands)))))
        (else (let* ((result (s8-interpret (list (get-value (car e) env) (cadr e)) env))) result)))))
))