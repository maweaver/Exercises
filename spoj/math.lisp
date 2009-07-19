(defun decompose-s-d (n)
	"Decomposes a value n into two values s and d, such that d * 2 ^ s = n"
	
	(declare (type (unsigned-byte 64) n) (optimize (safety 0) (speed 3)))
	
	(loop for s = 1 then (+ s 1)
		for cur-n = n then (/ cur-n 2)
		until (oddp cur-n)
		finally (return (values (- s 1) cur-n))))

(defun rtl-bin-mod-expt (b e m)
	"Determines the value of b ^ e % m using the right-to-left binary method
	described at: 
	
	  http://en.wikipedia.org/wiki/Modular_exponentiation#Right-to-left_binary_method"
	  
	(declare (type (unsigned-byte 64) b e m) (optimize (safety 0) (speed 3)))
	
	(loop for bitnum from 0 below (integer-length e)
		for cur-b = b then (mod (* cur-b cur-b) m)
		with result = 1
		if (logbitp bitnum e) do (setq result (mod (* result cur-b) m))
		finally (return result)))

(defun naive-prime-p (n)
	"Evaluates whether a number is prime using a naive method: Loop from 2 to
	sqrt(n), if any number has a gcd with n > 1, then it n is composite.  If
	no such numbers are found, n is prime."
	
	(declare (type (unsigned-byte 64) n) (optimize (safety 0) (speed 3)))

	(if 
		(= n 1) nil
		(loop for a of-type (unsigned-byte 64) from 1 upto (floor (sqrt n))
			if (not (= (gcd a n) 1)) return nil
			finally (return t))))

(defvar *small-primes*
	(loop for i of-type (unsigned-byte 64) from 2 upto 257
		when (naive-prime-p i) collect i)
	
	"Small primes, used when checking for larger primes.  Because they are so
	small, they are determined using the naive method.")

(defun probable-prime-p (n a)
	"Determines whether n is a weak probable prime base a using fermat's
	little theorem.  In particular, checks whether mod(a^(n - 1, n) = 1.  If so,
	it is probable that n is prime, but not definite.  If not, n is definitely
	composite."
	
	(= (rtl-bin-mod-expt a (- n 1) n) 1))

(defun miller-rabin-p (n)
	"Performs k iterations of the miller-rabin test"
	
	(declare (type (unsigned-byte 64) n) (optimize (safety 0) (speed 3)))
	
	(cond 
		((= n 1) nil)
		((and (not (= n 2)) (= (mod n 2) 0)) nil)
		((< n 258) (if (find n *small-primes*) t nil))
;		((not (probable-prime-p n 3)) nil)
		(t (and 
				(loop for p of-type (unsigned-byte 64) in *small-primes*
					if (= (mod n p) 0) return nil
					finally (return t))
				(multiple-value-bind (s d) (decompose-s-d (- n 1))
					(declare (type (unsigned-byte 64) s d))	
					(progn
;						(format t "n: ~a, k: ~a, s: ~a, d: ~a~%" n k s d)
						(loop for a of-type (unsigned-byte 64) in 
							(cond
								((< n 1373653) '(2 3))
								((< n 9080191) '(31 73))
								((< n 4759123141) '(2 7 61))
								((< n 2152302898747) '(2 3 5 7 11)))
							for start-x of-type (unsigned-byte 64) = (rtl-bin-mod-expt a d n)
							unless (or (= start-x 1) (= start-x (- n 1)))
							do (progn
;								(format t "a: ~a, x: ~a~%" a start-x)
								(if (not (loop 
											for r of-type (unsigned-byte 64) from 1 to (- s 1)
											for x of-type (unsigned-byte 64) = (rtl-bin-mod-expt start-x 2 n) then (rtl-bin-mod-expt x 2 n)
;											do (format t "r: ~a, x: ~a~%" r x)
											if (= x 1) return nil
											if (= x (- n 1)) return t
											finally (return nil)))
									(return nil)))
							finally (return t))))))))
