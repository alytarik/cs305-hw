(load "alitarik-hw5")

(cs305)

;ERROR
(cond (0 1) (1 (if 1 2)) (else 2))
(let ((x (if 1 2))) (+ 1 2 3))
(let ((x (if 0 100 200)) (y (if 1 10))) (+ x y 1))
(let ((x (if 0 100 200)) (y (let ((x (if 0 200)) (y (if 1 10 20))) (+ x y 1)))) (+ x y 1))

(if 1 2)
(if ())
(if 1 (if 0 1 (cond (1 99) (2 -1))) -99)