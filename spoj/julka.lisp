(dotimes (i 10)
  (let* (
		(x (parse-integer (read-line)))
		(y (parse-integer (read-line)))
		(a (/ (- x y) 2))
		(b (- x a)))
	(write b)
	(write-char #\Newline)
	(write a)
	(write-char #\Newline)))
