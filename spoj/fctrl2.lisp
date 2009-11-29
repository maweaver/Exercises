(defun fact (n)
  (if (= n 1)
	  1
	(* n (fact (- n 1)))))

(let ((num-test-cases (parse-integer (read-line))))
  (dotimes (i num-test-cases)
	(let ((n (parse-integer (read-line))))
	  (write (fact n))
	  (write-char #\Newline))))