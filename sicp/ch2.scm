;;; 2.1 ;;;

(define (make-rat n d)
	(if (> (* n d) 0)
		(cons (abs n) (abs d))
		(cons (- (abs n)) (abs d))))

; (display (make-rat 1 2)) (newline)
; (display (make-rat -1 2)) (newline)
; (display (make-rat 1 -2)) (newline)
; (display (make-rat -1 -2)) (newline)

;;; 2.2 ;;;

(define (make-point x y)
	(cons x y))

(define (x-point p) (car p))

(define (y-point p) (cdr p))

(define (print-point p)
	(newline)
	(display "(")
	(display (x-point p))
	(display ",")
	(display (y-point p))
	(display ")"))

(define (make-segment start end)
	(cons start end))

(define (start-segment segment) (car segment))

(define (end-segment segment) (cdr segment))

(define (midpoint-segment segment)
	(define x1 (x-point (start-segment segment)))
	(define x2 (x-point (end-segment segment)))
	(define y1 (y-point (start-segment segment)))
	(define y2 (y-point (end-segment segment)))
		
	(make-point
		(+ x1 (/ (- x2 x1) 2.0))
		(+ y1 (/ (- y2 y1) 2.0))))

; (display (midpoint-segment (make-segment (make-point 1 2) (make-point 4 5))))
; (newline)

;;; 2.3 ;;;

(define (make-rect ul lr) (cons ul lr))

(define (rect-ul r) (car r))

(define (rect-lr r) (cdr r))

(define (rect-width r) (- (x-point (rect-lr r)) (x-point (rect-ul r))))

(define (rect-height r) (- (y-point (rect-lr r)) (y-point (rect-ul r))))

(define (rect-perimiter r) (+ (* (rect-width r) 2) (* (rect-height r) 2)))

(define (rect-area r) (* (rect-width r) (rect-height r)))

; (display (rect-perimiter (make-rect (make-point 5 5) (make-point 10 10))))
; (newline)
; (display (rect-area (make-rect (make-point 5 5) (make-point 10 10))))
; (newline)

(define (make-rect ul size) (cons ul size))

(define (rect-ul r) (car r))

(define (rect-lr r) (make-point (+ (x-point ul) (x-point size)) (+ (y-point ul) (y-point size))))

(define (rect-width r) (x-point (cdr r)))

(define (rect-height r) (y-point (cdr r)))

; (display (rect-perimiter (make-rect (make-point 5 5) (make-point 5 5))))
; (newline)
; (display (rect-area (make-rect (make-point 5 5) (make-point 5 5))))
; (newline)

;;; 2.4 ;;;

(define (cons-24 x y)
	(lambda (m) (m x y)))

(define (car-24 z)
	(z (lambda (p q) p)))

(define (cdr-24 z)
	(z (lambda (p q) q)))

; (display (car-24 (cons-24 3 5)))
; (newline)
; (display (cdr-24 (cons-24 3 5)))
; (newline)

;;; 2.5 ;;;

(define (cons-25 x y)
	(* (expt 2 x) (expt 3 y)))

(define (car-25 z)
	(define (car-step cur-z)
		(if (not (= (remainder cur-z 2) 0)) 0
			(+ 1 (car-step (/ cur-z 2)))))
	(car-step z))

(define (cdr-25 z)
	(define (car-step cur-z)
		(if (not (= (remainder cur-z 3) 0)) 0
			(+ 1 (car-step (/ cur-z 3)))))
	(car-step z))

; (display (car-25 (cons-25 3 5)))
; (newline)
; (display (cdr-25 (cons-25 3 5)))
; (newline)

;;; 2.6 ;;;

(define zero (lambda (f) (lambda (x) x)))

(define (add-1 n)
  (lambda (f) (lambda (x) (f ((n f) x)))))

(define (church-value x)
	(define (church-f x) (+ x 1))
	((x church-f) 0))

; (display (church-value zero))
; (newline)
; (display (church-value (add-1 zero)))
; (newline)
; (display (church-value (add-1 (add-1 zero))))
; (newline)

(define one (lambda (f) (lambda (x) (f x))))
(define two (lambda (f) (lambda (x) (f (f x)))))

; (display (church-value zero))
; (newline)
; (display (church-value one))
; (newline)
; (display (church-value two))
; (newline)

(define (add x y)
	((x (lambda (g) (lambda (h) (lambda (i) (h ((g h) i)))))) y))

; (display (church-value (add two one)))
; (newline)
; (display (church-value (add two two)))
; (newline)

;;; 2.7 ;;;

(define (make-interval a b) (cons a b))

(define (lower-bound i) (min (car i) (cdr i)))

(define (upper-bound i) (max (car i) (cdr i)))

(define (add-interval x y)
	(make-interval (+ (lower-bound x) (lower-bound y))
		(+ (upper-bound x) (upper-bound y))))

(define (mul-interval x y)
	(let ((p1 (* (lower-bound x) (lower-bound y)))
			(p2 (* (lower-bound x) (upper-bound y)))
			(p3 (* (upper-bound x) (lower-bound y)))
			(p4 (* (upper-bound x) (upper-bound y))))
		(make-interval (min p1 p2 p3 p4)
			(max p1 p2 p3 p4))))

(define (div-interval x y)
	(mul-interval x 
		(make-interval (/ 1.0 (upper-bound y))
			(/ 1.0 (lower-bound y)))))

; (display (div-interval (make-interval 1.0 1.0) 
; 		(add-interval 
; 			(div-interval (make-interval 1.0 1.0) (make-interval 6.12 7.48))
; 			(div-interval (make-interval 1.0 1.0) (make-interval 4.465 4.935)))))
; (newline)

;;; 2.8 ;;;

(define (sub-interval x y)
	(make-interval (- (lower-bound x) (upper-bound y))
		(- (upper-bound x) (lower-bound y))))

;(display (sub-interval (make-interval 1 2) (make-interval 3 4)))
;(newline)

;;; 2.9 ;;;

; let width(interval) = (interval.upper-bound - interval.lower-bound) / 2
;
; width(i1 + i2) = width((i1.u + i2.u) . (i1.l + i2.l))
;                = ((i1.u + i2.u) - (i1.l + i2.l) / 2
;                = (i1.u + i2.u - i1.l - i2.l) / 2
;                = ((i1.u - i1.l) + (i2.u - i2.l)) / 2
;                = (i1.u - i1.l) / 2 + (i2.u - i2.l) / 2
;                = width(i1) + width(i2)
;
; width(i1 - i2) = width((i1.l - i2.u) . (i1.u - i2.l))
;                = ((i1.l - i2.u) - (i1.u - i2.l)) / 2
;                = (i1.l - i1.u + i2.l - i2.u) / 2
;                = (i1.l - i1.u) / 2 + (i2.l - i2.u) / 2
;                = -width(i1) - width(i2)
;
; let i1 = (1, 2), i2 = (3, 4)
; then width(i1) = 0.5, width(i2) = 0.5
; i1 * i2 = 3 . 8, and width(i1 * i2) = 2.5 != 0.5 * 0.5
; i1 / i2 = 1/4 . 2/3, width = (2/3 - 1/4) / 2 = (8/12 - 3/12)/2 = (5/12)/2 = 5/24 != 1/4

;;; 2.10 ;;;

(define (div-interval x y)
	(cond
		((and (< (lower-bound x) 0) (> (upper-bound x) 0)) (/ (lower-bound x) 0))
		((and (> (lower-bound x) 0) (< (upper-bound x) 0)) (/ (upper-bound x) 0))
		((and (< (lower-bound y) 0) (> (upper-bound y) 0)) (/ (lower-bound y) 0))
		((and (> (lower-bound y) 0) (< (upper-bound y) 0)) (/ (upper-bound y) 0))
		(else 
			(mul-interval x 
				(make-interval (/ 1.0 (upper-bound y))
					(/ 1.0 (lower-bound y)))))))

; (display (div-interval (make-interval -2.0 2.0) (make-interval 1.0 1.0)))
; (newline)

;;; 2.11 ;;;

; Given: i1.l < i1.u, i2.l < i2.u
;
; Then:
;
; (+ . +) * (+ . +) => (i1.l * i2.l . i1.u * i2.u)
; (+ . +) * (- . +) => (i1.u * i2.l . i1.u * i2.u)
; (+ . +) * (- . -) => (i1.u * i2.l . i1.l * i2.u)

; (- . +) * (+ . +) => (i1.l * i2.u . i1.u * i2.u)
; (- . +) * (- . +) => (min(i1.l * i2.u, i1.u * i2.l) . max(i1.u * i2.u, i1.l * i2.l))
; (- . +) * (- . -) => (i1.u * i2.l . i1.l * i2.l)

; (- . -) * (+ . +) => (i1.l * i2.u . i1.u * i2.l)
; (- . -) * (- . +) => (i1.l * i2.u . i1.l * i2.l)
; (- . -) * (- . -) => (i1.l * i2.l . i1.u * i2.u)

(define (mul-interval-signs x y)
	(let (
			(i1-l (lower-bound x))
			(i1-u (upper-bound x))
			(i2-l (lower-bound y))
			(i2-u (upper-bound y)))
		(cond
			((and (> i1-l 0) (> i1-u 0) (< i2-l 0) (> i2-u 0))
				(make-interval (* i1-u i2-l) (* i1-u i2-u)))			
			((and (> i1-l 0) (> i1-u 0) (< i2-l 0) (< i2-u 0))
				(make-interval (* i1-u i2-l) (* i1-l i2-u)))
			((and (< i1-l 0) (> i1-u 0) (> i2-l 0) (> i2-u 0))
				(make-interval (* i1-l i2-u) (* i1-u i2-u)))
			((and (< i1-l 0) (> i1-u 0) (< i2-l 0) (> i2-u 0))
				(make-interval (min (* i1-l i2-u) (* i1-u i2-l)) (max (* i1-u i2-u) (* i1-l i2-l))))
			((and (< i1-l 0) (> i1-u 0) (< i2-l 0) (< i2-u 0))
				(make-interval (* i1-u i2-l) (* i1-l i2-l)))
			((and (< i1-l 0) (< i1-u 0) (> i2-l 0) (> i2-u 0))
				(make-interval (* i1-l i2-u) (* i1-u i2-l)))
			((and (< i1-l 0) (< i1-u 0) (< i2-l 0) (> i2-u 0))
				(make-interval (* i1-l i2-u) (* i1-l i2-l)))
			((and (< i1-l 0) (< i1-u 0) (< i2-l 0) (< i2-u 0))
				(make-interval (* i1-u i2-u) (* i1-l i2-l)))
			(else (make-interval (* i1-l i2-l) (* i1-u i2-u))))))

; (display (mul-interval (make-interval 1 2) (make-interval 3 4)))
; (newline)
; (display (mul-interval-signs (make-interval 1 2) (make-interval 3 4)))
; (newline)
; (newline)

; (display (mul-interval (make-interval 1 2) (make-interval -3 4)))
; (newline)
; (display (mul-interval-signs (make-interval 1 2) (make-interval -3 4)))
; (newline)
; (newline)

; (display (mul-interval (make-interval 1 2) (make-interval -3 -4)))
; (newline)
; (display (mul-interval-signs (make-interval 1 2) (make-interval -3 -4)))
; (newline)
; (newline)

; (display (mul-interval (make-interval -1 2) (make-interval 3 4)))
; (newline)
; (display (mul-interval-signs (make-interval -1 2) (make-interval 3 4)))
; (newline)
; (newline)

; (display (mul-interval (make-interval -1 2) (make-interval -3 4)))
; (newline)
; (display (mul-interval-signs (make-interval -1 2) (make-interval -3 4)))
; (newline)
; (newline)

; (display (mul-interval (make-interval -1 2) (make-interval -3 -4)))
; (newline)
; (display (mul-interval-signs (make-interval -1 2) (make-interval -3 -4)))
; (newline)
; (newline)

; (display (mul-interval (make-interval -1 -2) (make-interval 3 4)))
; (newline)
; (display (mul-interval-signs (make-interval -1 -2) (make-interval 3 4)))
; (newline)
; (newline)

; (display (mul-interval (make-interval -1 -2) (make-interval -3 4)))
; (newline)
; (display (mul-interval-signs (make-interval -1 -2) (make-interval -3 4)))
; (newline)
; (newline)

; (display (mul-interval (make-interval -1 -2) (make-interval -3 -4)))
; (newline)
; (display (mul-interval-signs (make-interval -1 -2) (make-interval -3 -4)))
; (newline)
; (newline)

;;; 2.12 ;;;

(define (make-center-percent center percent)
	(make-interval (- center (* center percent)) (+ center (* center percent))))

; (display (make-center-percent 6.8 0.1))
; (newline)

(define (center i)
	(/ (+ (lower-bound i) (upper-bound i)) 2))

(define (percent i)
	(/ (max (- (upper-bound i) (center i)) (- (center i) (lower-bound i))) (center i)))

; (display (percent (make-center-percent 6.8 0.1)))
; (newline)

;;; 2.13 ;;;

; i1 + i2 = (i1.l + i2.l . i1.u + i2.u)
; (percent (+ i1 i2)) = (percent (i1.l + i2.l . i1.u + i2.u)
;                     = max((i1.u + i2.u) - ((i1.l + i2.l) + (i1.u + i2.u)) / 2,
;                           ((i1.l + i2.l) + (i1.u + i2.u)) / 2 - (i1.l + i2.l)) /
;                       (((i1.l + i2.l) + (i1.u + i2.u)) / 2)
;                     = max((2*i1.u + 2*i2.u)/2 + (-i1.l - i2.l - i1.u - i2.u)/2,
;                           (i1.l + i2.l + i1.u + i2.u)/2 + (-2*i1.l - 2*i2.l)/2) /
;                        (i1.l + i2.l + i1.u + i2.u)/2
;                     = max(i1.u + i2.u - i1.l - i2.l, -i1.l - i2.l + i1.u + i2.u) / 2 /
;                          (i1.l + i2.l + i1.u + i2.u)/2
;                     = max(i1.u + i2.u - i1.l - i2.l, i1.u + i2.u - i1.l - i2.l) /
;                          (i1.l + i2.l + i1.u + i2.u)
;                      = (i1.u + i2.u - i1.l - i2.l) / (i1.l + i2.l + i1.u + i2.u)

;;; 2.14 ;;;

(define (par1 r1 r2)
	(div-interval (mul-interval r1 r2)
		(add-interval r1 r2)))

(define (par2 r1 r2)
	(let ((one (make-interval 1 1))) 
		(div-interval one
			(add-interval (div-interval one r1)
				(div-interval one r2)))))

(define ra (make-center-percent 100 .01))
(define rb (make-center-percent 500 .05))

(define par1-res (par1 ra rb))
(define par2-res (par2 ra rb))

; (display (center par1-res))
; (display " . ")
; (display (percent par1-res))
; (newline)

; (display (center par2-res))
; (display " . ")
; (display (percent par2-res))
; (newline)

;;; 2.15 ;;;

; No, this is not the problem.  Whether one is re-used or not makes no 
; difference.  The problem is rounding in par2 due to the extra divisions, 
; making par1 actually the better choice.

;;; 2.16 ;;;

; It is possible to work around this using an arbitrary-precision library.  No,
; I'm not going to write one (that would be very difficult :) )

;;; 2.17 ;;;

(define (last-pair l)
	(if (null? (cdr l)) 
		(list (car l))
		(last-pair (cdr l))))

;(display (last-pair (list 23 72 149 34)))
;(newline)

;;; 2.18 ;;;

; (1 . (2 . 3)) -> (3 . (2 . 1))

(define nil (cdr (list 1)))

(define (reverse l)
	(define (reverse-step l reversed)
		(if (null? l) reversed
			(reverse-step (cdr l) (cons (car l) reversed))))
	(reverse-step l nil))

;(display (reverse (list 1 4 9 16 25)))
;(newline)

;;; 2.19 ;;;

(define us-coins (list 50 25 10 5 1))
(define uk-coins (list 100 50 20 10 5 2 1 0.5))

(define (cc amount coin-values)
	(define (no-more? coin-values) (null? coin-values))
	(define (first-denomination coin-values) (car coin-values))
	(define (except-first-denomination coin-values) (cdr coin-values))
	(cond ((= amount 0) 1)
		((or (< amount 0) (no-more? coin-values)) 0)
		(else
			(+ (cc amount
					(except-first-denomination coin-values))
				(cc (- amount
						(first-denomination coin-values))
					coin-values)))))

;(display (cc 100 us-coins))
;(newline)

;;; 2.20 ;;;

(define (same-parity f . l)
	(define (even n) (= (remainder n 2) 0))
	(define (odd n) (not (even n)))
	(define (filter l predicate)
		(if (null? l) l
			(if (predicate (car l)) (cons (car l) (filter (cdr l) predicate))
				(filter (cdr l) predicate))))
	(cons f 
		(if (even f) (filter l even)
			(filter l odd))))

;(display (same-parity 1 2 3 4 5 6 7))
;(newline)
;(display (same-parity 2 3 4 5 6 7))
;(newline)

;;; 2.21 ;;;

(define (square-list items)
	(if (null? items)
		nil
		(cons (* (car items) (car items)) (square-list (cdr items)))))

;(display (square-list (list 1 2 3 4)))
;(newline)

(define (square-list items)
	(map (lambda (x) (* x x)) items))

;(display (square-list (list 1 2 3 4)))
;(newline)

;;; 2.22 ;;;

; Because the square happens inside the call, the list is built from the
; bottom up, starting from the end.  This reverses the result.
;
; Reversing the arguments to cons does not fix the problem, since instead
; you end up with something like ((nil . 1) . 2), which is not a proper list.

;;; 2.23 ;;;

(define (for-each f l)
	(cond
		((null? l) #t)
		(else 
			(f (car l))
			(for-each f (cdr l)))))

;(for-each (lambda (x) (newline) (display x))
;	(list 57 321 88))
;(newline)

;;; 2.24 ;;;

; (list 1 (list 2 (list 3 4)))
;
; (1 (2 (3 4)))
;
; o--o--/
; |  |
; 1  |
;    |
; 2--o--o--/
;       |
;    3--o--o--/
;          |
;          4
;
; (1 (2 (3 4)))
;     / \
;    1   (2 (3 4))
;          / \
;         2 (3 4)
;            /  \
;           3    4

;;; 2.25 ;;;

;(display (car (cdr (car (cdr (cdr (list 1 3 (list 5 7) 9)))))))
; (newline)

;(display (car (car (list (list 7)))))
;(newline)

;(display (car (cdr (car (cdr (car (cdr (car (cdr (car (cdr (car (cdr (list 1 (list 2 (list 3 (list 4 (list 5 (list 6 7)))))))))))))))))))
; (newline)

;;; 2.26 ;;;

; (define x (list 1 2 3))
; (define y (list 4 5 6))

; guile> (append x y)
; (1 2 3 4 5 6)

; guile> (cons x y)
; ((1 2 3) 4 5 6)

; guile> (list x y)
; ((1 2 3) (4 5 6))

;;; 2.27 ;;;

(define (deep-reverse l)
	(define (reverse-step l reversed)
		(cond 
			((null? l) reversed)
			((pair? (car l)) (reverse-step (cdr l) (cons (deep-reverse (car l)) reversed)))
			(else (reverse-step (cdr l) (cons (car l) reversed)))))
	(reverse-step l nil))

(define x (list (list 1 2) (list 3 4)))

;(display (reverse x))
;(newline)

;(display (deep-reverse x))
;(newline)

;;; 2.28 ;;;

(define (fringe l)
	(define (fringe-step l fringed)
		(cond
			((null? l) fringed)
			((pair? (car l)) (append fringed (append (fringe (car l)) (fringe-step (cdr l) fringed))))
			(else (fringe-step (cdr l) (append fringed (list (car l)))))))
	(fringe-step l nil))

(define x (list (list 1 2) (list 3 4)))

;(display (fringe x))
;(newline)

;(display (fringe (list x x)))
;(newline)

;;; 2.29 ;;;

(define (make-mobile left right)
	(list left right))

(define (make-branch length structure)
	(list length structure))

;;;; a. ;;;;

(define (left-branch m) (car m))
(define (right-branch m) (cadr m))

(define (branch-length b) (car b))
(define (branch-structure b) (cadr b))

;(display (left-branch (make-mobile (make-branch 1 2) (make-branch 3 4))))
;(newline)

;(display (right-branch (make-mobile (make-branch 1 2) (make-branch 3 4))))
;(newline)

;(display (branch-length (make-branch 1 2)))
;(newline)

;(display (branch-structure (make-branch 1 2)))
;(newline)

;;;; b. ;;;;;

(define (total-weight m)
	(if (pair? (branch-structure m))
		(+ (total-weight (left-branch m)) (total-weight (right-branch m)))
		(branch-structure m)))

;(display (total-weight (make-mobile (make-branch 1 2) (make-branch 3 4))))
;(newline)

;;;; c. ;;;;;


