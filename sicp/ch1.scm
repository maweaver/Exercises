(define (square x) 
  (* x x))

(define (sum-of-squares x y) 
  (+ (square x) (square y)))

(define (biggest a b c)
  (cond ((and (> a b) (> a c)) a)
	((and (> b a) (> b c)) b)
	((and (> c a) (> c b)) c)))

(define (middle a b c)
  (cond ((and (> a b) (< a c)) a)
	((and (> a c) (< a b)) a)
	((and (> b a) (< b c)) b)
	((and (> b c) (< b a)) b)
	((and (> c a) (< c b)) c)
	((and (> c b) (< c a)) c)))

(define (sum-of-squares-of-two-largest a b c)
  (sum-of-squares (biggest a b c) (middle a b c)))

(define (a-plus-abs-b a b)
	((if (> b 0) + -) a b))

(define (sqrt-iter guess x)
	(if (good-enough? guess x)
		guess
		(sqrt-iter (improve guess x) x)))

(define (improve guess x)
	(average guess (/ x guess)))

(define (average x y)
	(/ (+ x y) 2))

(define (good-enough? guess x)
	(< (abs (- x (square guess))) .001))

(define (sqrt x)
	(sqrt-iter 1.0 x))

(define (new-if predicate predicate-clause else-clause)
	(cond (predicate predicate-clause)
	      (else else-clause)))

;; sqrt(0.00001) = 0.01
;; Our guess: 0.03135

(define (better-good-enough? guess previous-guess)
	(print "***")
	(print "Guess: " guess)
	(print "Previous: " previous-guess)
	(print "***")
	(< (/ (abs (- guess previous-guess)) previous-guess) 0.01))

(define (better-sqrt-iter guess x)
	(define next-guess (improve guess x))
	(if (better-good-enough? next-guess guess)
		next-guess
		(better-sqrt-iter next-guess x)))

(define (cube-iter guess x)
	(define next-guess (cube-improve guess x))
	(if (better-good-enough? next-guess guess)
		next-guess
		(cube-iter next-guess x)))

(define (cube-improve guess x)
	;; (x / y ^ 2 + 2y ) / 3
	;; x = num, y = guess
	(/ (+ (/ x (square guess)) (* 2 guess)) 3))

(define (cube x)
	(cube-iter 1.0 x))

(define (better-sqrt x)
	(better-sqrt-iter 1.0 x))

(define (A x y)
  (cond ((= y 0) 0)
        ((= x 0) (* 2 y))
        ((= y 1) 2)
        (else (A (- x 1)
                 (A x (- y 1))))))

(define (f n) (A 0 n))

(define (g n) (A 1 n))

(define (h n) (A 2 n))

(define (f-rec n)
	(if (< n 3)
		n
		(+ (f-rec (- n 1)) (* (f-rec (- n 2)) 2) (* (f-rec (- n 3)) 3))))

(define (test-f-rec n)
	(print (f-rec n))
	(if (> n 0)
		(test-f-rec (- n 1))))

(define (f-iter n) (f-iter-step 2 1 0 (- n 2)))

(define (f-iter-step l1 l2 l3 count)
	(if(<= count 0)
		l1
		(f-iter-step (+ l1 (* 2 l2) (* 3 l3)) 
			l1 l2 (- count 1))))

(define (test-f-iter n)
	(print (f-iter n))
	(if (> n 0)
		(test-f-rec (- n 1))))

(define (pascal height)
	(define (do-pascal height)
		(cond ((> height 0)
				(pascal-row height)
				(print "*")
				(do-pascal (- height 1)))))

	(define (pascal-row len)
		(pascal-do-row len (- len 1)))

	(define (pascal-do-row len pos)
		(cond ((>= pos 0)
				(print (pascal-element len pos))
				(pascal-do-row len (- pos 1)))))
			
	(define (pascal-element row-len col-pos)
		(cond ((<= col-pos 0) 1)
		      ((>= col-pos (- row-len 1)) 1)
		      (else (+ (pascal-element (- row-len 1) (- col-pos 1)) (pascal-element (- row-len 1) col-pos)))))

	(do-pascal height)
)

(define (even? n)
	(= (remainder n 2) 0))

(define (expt-iter-loop a b n)
	(cond ((= n 0) a)
	      ((even? n) (expt-iter-loop a (* b b) (/ n 2)))
	      (else (expt-iter-loop (* a b) b (- n 1)))))

(define (expt-iter b n)
	(expt-iter-loop 1 b n))

(define (half n)
	(floor (/ n 2)))

(define (double n)
	(* n 2))

(define (fast-mult a b)
	(cond ((= b 0) 0)
	      ((even? b) double (fast-mult (double a) (half b)))
	      (else (+ a (fast-mult a (- b 1))))))

(define (fast-mult-iter a b)
	(fast-mult-iter-step 0 a b))

(define (fast-mult-iter-step sum a b)
	(cond ((= a 1) (+ sum b))
	      ((even? a)
		      (fast-mult-iter-step sum (half a) (double b)))
	      (else 
		      (fast-mult-iter-step (+ sum b) (half a) (double b)))))

;; (expmod 3 5 5)
;; = (remainder (* 3 (expmod 3 4 5)) 5)
;; = (remainder (* 3 (remainder (square (expmod 3 2 5)) 5)) 5)
;; = (remainder (* 3 (remainder (square (remainder (square (expmod 3 1 5)) 5)) 5)) 5)
;; = (remainder (* 3 (remainder (square (remainder (square (remainder (* 3 (expmod  3 0 5)) 5)) 5)) 5)) 5)
;; = (remainder (* 3 (remainder (square (remainder (square (remainder (* 3 1) 5)) 5)) 5)) 5)
;; = (remainder (* 3 (remainder (square (remainder (square 3) 5)) 5)) 5)
;; = (remainder (* 3 (remainder (square 4) 5)) 5)
;; = (remainder (* 3 1) 5)
;; = 3

(define (expmod base exp m)
  (cond ((= exp 0) 1)
        ((even? exp)
         (remainder (square (expmod base (/ exp 2) m))
                     m))
        (else
         (remainder (* base (expmod base (- exp 1) m))
                     m))))

(define (smallest-divisor n)
	(find-divisor n 2))

(define (find-divisor n test-divisor)
	(cond ((> (square test-divisor) n) n)
		((divides? test-divisor n) test-divisor)
		(else (find-divisor n (+ test-divisor 1)))))

(define (divides? a b)
	(= (remainder b a) 0))

(define (prime? n)
  (= n (smallest-divisor n)))

(define (search-for-primes start count)
	(if (> count 0)
		(cond ((fast-prime? start 1)
				(display start)
				(newline)
				(search-for-primes (+ start 1) (- count 1)))
			(else
				(search-for-primes (next-prime-search start) count)))))

(define (next-prime-search n)
	(cond ((even? n) (+ n 1))
		(else (+ n 2))))

(define (fermat-test n)
	(define (try-it a)
		(= (expmod a n n) a))
	(try-it (+ 1 (random (- n 1)))))

(define (fast-prime? n times)
	(cond ((= times 0) #t)
		((fermat-test n) (fast-prime? n (- times 1)))
		(else #f)))

(define (miller-rabin n)
	(define (square x) (* x x))
	
	(define (non-trivial-root? x n)
		(cond 
			((= x (- n 1)) #f)
			((= x 1) #f)
			((= (remainder (- (square x) 1) n) 0) #t)
			(else #f))))

(define (is-congruent? a n)
	(= (expmod a n n) (remainder a n)))

(define (all-congruent? n)
	(all-congruent-rec (- n 1) n))

(define (all-congruent-rec a n)
	(cond ((= a 0) #t)
		((is-congruent? a n) (all-congruent-rec (- a 1) n))
		(else #f)))

(define (simpsons f a b n)
	(define h (/ (- b a) n))
	
	(define (y k)
		(f (+ a (* k h))))
	
	(define (multiplier k n)
		(cond ((= k 0) 1)
			((= k n) 1)
			((even? k) 2)
			(else 4)))
	
	(define (simpsons-step cur-val cur-k)
		(if (= cur-k 0) 
			(+ cur-val (y cur-k))
			(simpsons-step (+ cur-val (* (multiplier cur-k n) (y cur-k))) (- cur-k 1))))
	(* (/ h 3.0) (simpsons-step 0.0 n)))

(define (cube x) (* x x x))

(define (sum term a next b)
	(if (> a b)
		0
		(+ (term a)
			(sum term (next a) next b))))

(define (sum-iter term a next b)
  (define (iter a result)
    (if (> a b)
        result
        (iter (next a) (+ result (term a)))))
  (iter a 0))

(define (inc n) (+ n 1))

(define (sum-cubes a b)
  (sum-iter cube a inc b))

(define (product term a next b)
	(if (> a b)
		1
		(* (term a)
			(product term (next a) next b))))

(define (product-iter term a next b)
  (define (iter a result)
    (if (> a b)
        result
        (iter (next a) (* result (term a)))))
  (iter a 1))

(define (fact n)
	(product-acc identity 1 inc n))

(define (pi-term n)
	(/ (* (double n) (+ (double n) 2.0))
		(square (+ (double n) 1.0))))

(define (pi n)
	(* (product-iter pi-term 1 inc n) 4))

(define (accumulate combiner null-value term a next b)
	(if (> a b)
		null-value
		(combiner (term a)
			(accumulate combiner null-value term (next a) next b))))

(define (sum-acc term a next b)
	(define (sum-comb a b)
		(+ a b))
	
	(accumulate-iter sum-comb 0 term a next b))

(define (product-acc term a next b)
	(define (prod-comb a b)
		(* a b))
	
	(accumulate-iter prod-comb 1 term a next b))

(define (accumulate-iter combiner null-value term a next b)
  (define (iter a result)
    (if (> a b)
        result
        (iter (next a) (combiner result (term a)))))
  (iter a null-value))

(define (accumulate combiner null-value term a next b)
	(if (> a b)
		null-value
		(combiner (term a)
			(accumulate combiner null-value term (next a) next b))))

(define (filtered-accumulate combiner null-value term a next b filter)
	(if (> a b) null-value
		(combiner 
			(if (filter a) (term a) null-value)
			(filtered-accumulate combiner null-value term (next a) next b filter))))

(define (sum-of-squares-of-primes a b)
	(filtered-accumulate + 0 square a inc b prime?))

(define (sum-of-rel-primes n)
	(define (is-rel-prime p)
		(= (gcd p n) 1))
	(filtered-accumulate + 0 identity 1 inc n is-rel-prime))

(define tolerance 0.00001)
(define (fixed-point f first-guess)
	(define (close-enough? v1 v2)
		(display "Guess: ")
		(display v1)
		(newline)
		(< (abs (- v1 v2)) tolerance))
	(define (try guess)
		(let ((next (/ (+ guess (f guess)) 2)))
			(if (close-enough? guess next)
				next
				(try next))))
	(try first-guess))

(define (cont-frac n d k)
	(define (cont-frac-step n d cur-k max-k)
		(if (= cur-k max-k) 0.0
			(/ (n cur-k) (+ (d cur-k) (cont-frac-step n d (+ cur-k 1) max-k)))))
	(cont-frac-step n d 1 k))

(define (cont-frac-iter n d k)
	(define (cont-fract-iter-step n d cur-val cur-k)
		(if (= cur-k 0) cur-val
			(cont-fract-iter-step n d (/ (n cur-k) (+ (d cur-k) cur-val)) (- cur-k 1))))
	(cont-fract-iter-step n d 0.0 k))

(define (e-minus-2 k)
	(define (d i)
		(if (= (remainder (+ i 1) 3) 0)
			(* (/ (+ i 1) 3) 2.0)
			1.0))
	(cont-frac-iter (lambda (i) 1.0) d k))

(define (tancf x k)
	(define (d i) (- (* i 2) 1))
	(define (n i) (if (= i 1) x (- 0 (* x x))))
	(cont-frac-iter n d k))

(define (deriv g)
	(lambda (x)
		(/ (- (g (+ x dx)) (g x))
			dx)))

(define (newton-transform g)
	(lambda (x)
		(- x (/ (g x) ((deriv g) x)))))

(define (newtons-method g guess)
	(fixed-point (newton-transform g) guess))

(define dx .00001)

(define (cubic a b c)
	(lambda (x) (+ (* x x x) (* a x x) (* b x) c)))

(define (double f)
	(lambda (x) (f (f x))))

(define (compose f g)
	(lambda (x) (f (g x))))

(define (repeated f n)
	(if (= n 1) f
		(compose f (repeated f (- n 1)))))

(define (smooth f)
	(lambda (x) (/ (+ (f (- x dx)) (f x) (f (+ x dx))) 3.0)))

(define really-smooth-square
	(((repeated smooth 10) (lambda (x) (* x x))) 3))

(define (average-damp f)
	(lambda (x) (average x (f x))))

(define (fixed-point-of-transform g transform guess)
	(fixed-point (transform g) guess))

(define (nth-root n x)
	(define (pow n x)
		(if (= n 0) 1
			(* x (pow (- n 1) x))))
	(fixed-point-of-transform (lambda (y) (/ x (pow (- n 1) y)))
		(repeated average-damp n)
		1.0))

(define (iterative-improve good-enough next-guess)
	(define (iterative-improve-step val)
		(if (good-enough val) val
			(iterative-improve-step (next-guess val))))
	(lambda (x) (iterative-improve-step x)))

(define (ii-sqrt x)
	(define (improve guess) (average guess (/ x guess)))
	(define (good-enough guess) (< (abs (- (square guess) x)) 0.001))
	((iterative-improve good-enough improve) 1.0))

(define (ii-fixed-point f x)
	(define (improve guess) (f guess))
	(define (good-enough guess) (< (abs (- (f guess) guess)) 0.001))
	((iterative-improve good-enough improve) 1.0))

(display (ii-fixed-point cos 1.0))
(newline)

