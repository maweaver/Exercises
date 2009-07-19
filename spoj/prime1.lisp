(load "math.lisp")
(load "string.lisp")

(let ((num-test-cases (parse-integer (read-line))))
	(dotimes (i num-test-cases)
		(let* ((line (read-line))
				(min-max (split line " "))
				(min-prime (parse-integer (car min-max)))
				(max-prime (parse-integer (cadr min-max))))
			(loop for i from min-prime upto max-prime
				if (miller-rabin-p i) do (progn (write i) (write-char #\Newline)))
			(write-char #\Newline))))
