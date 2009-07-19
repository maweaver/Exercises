(defun split (str delim)
	"Splits a string into a list of the substrings in string separated by delim.
	Delim will not occur inside any of the final strings."
	
	(declare (type string str delim) (optimize (safety 0) (speed 3)))
	
	(loop
		with result = nil
		with search-str of-type string = str
		for delim-index = (search delim search-str)
		while delim-index do (progn 
			(setq result (cons (subseq search-str 0 delim-index) result))
			(setq search-str (subseq search-str (+ delim-index (length delim)))))
		finally (return (reverse (cons search-str result)))))
