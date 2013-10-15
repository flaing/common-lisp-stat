;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; -*-

;; this contains the dataframe functions used in determining the metadata for columns and types.
;; there are also some print related functions - equivalents of head and tail

(in-package #:cls-dataframe)

;;;;;;;;;; DATE MANAGEMENT (FIXME: move elsewhere)

(defparameter *CLS-DATE-FORMAT* :UK
  "should be one of :UK (d/m/y) :US (m/d/y) or maybe others as required. Giving a hint to the parsing routine.SUffix with a -TIME (is :US-TIME for MDY hhmmss. Or supply the ANTIK specification as a list '(2 1 0 3 4 5)  ")

(defparameter *CLS-DATE-TEST-LIMIT* 5
  "the number of rows to check when deciding if the column is a date column or not.")
(defun antik-date-format-helper (date)
  "provide decoding for shorthand notation in *CLS-DATE-FORMAT*  or allow the full spec to be supplied "
  (cond
    ((equal date :UK) '(2 1 0))
    ((equal date :UK-TIME) '(2 1 0 3 4 5))
    ((equal date :US) '(2 0 1))
    ((equal date :US-TIME) '(2 0 1 3 4 5))
    (t date)))



;;; Why is this "ANTIK"?  We naturally will be including the antik
;;; package within this framework. At this point we are heavy, heavy,
;;; heavy, and done on purpose.  Need to be heavy before we are
;;; light-weight.
(defun antik-date-format-helper (date)
  "provide decoding for shorthand notation in *CLS-DATE-FORMAT* or
allow the full spec to be supplied "
  (cond
    ((equal date :UK) '(2 1 0))
    ((equal date :UK-TIME) '(2 1 0 3 4 5))
    ((equal date :US) '(2 0 1))
    ((equal date :US-TIME) '(2 0 1 3 4 5))
    (t date)))



(defun date-conversion-fu (df)
  "for any string column in the dataframe, try to parse the first n entries as a date according to the global format. If we can do that successfully for at least one entry, the convert the column, converting failures to nil"
  (labels ((read-timepoint (row column)
	   "read a timepoint. if there is an error return nil"
	   (handler-case
			 (antik:read-timepoint (xref df row column)
					       (antik-date-format-helper *CLS-DATE-FORMAT*))
	     (error () nil)))
	 
	   (date-column-detected (index)
	     "guess if the column has dates or not"
	   (loop
	     for i below *CLS-DATE-TEST-LIMIT*
	     collect  (read-timepoint i index) into result
	     finally (return (some #'identity result))))
	 
	 (convert-date-column (column )
	   (loop for i below (nrows df) do
	     (setf (xref df i column) (read-timepoint i column)))))
    
    (let ((maybe-dates
	    (loop for i upto (length (vartypes df))
			     and item in (vartypes df)
			     when (equal 'string item)
			       collect i)))
      
      (when maybe-dates
	(dolist (index maybe-dates)
	  (when (date-column-detected index)
	    (convert-date-column  index)
	    ;; FIXME: A nice accessor required!
	    (setf (getf  (nth index (variables df)) :type ) 'date)))))))


;;;;;;;; PRINTING (FIXME: move elsewhere)

(defun classify-print-type ( variable-type)
  " look at the type of each column, assuming that types are homogenous of course, and assign a descriptive type - number, date, string etc, to enable  for nice tabular printing"
  (labels ((integer-variable (variable)
	     (member variable '(FIXNUM INTEGER RATIONAL)))
	   (float-variable (variable)
	     (member variable '(NUMBER FLOAT LONG-FLOAT SHORT-FLOAT SINGLE-FLOAT DOUBLE-FLOAT)))
	   (string-variable (variable)
	     (equal variable 'STRING))
	   (keyword-variable (variable)
	     (equal variable 'KEYWORD))
	   (date-variable (variable)
	     (member variable '(DATE ANTIK:TIMEPOINT))))
    
    (cond
      ( (integer-variable variable-type) :INTEGER)
      ((float-variable variable-type) :FLOAT)
      ((keyword-variable variable-type) :KEYWORD)
      ((string-variable variable-type) :STRING)
      ((date-variable variable-type) :DATE)
      (t (error "classify-print-type, unrecognized type ~a~%" variable-type)))))
  
(defun determine-print-width (df  column type) 
  "build the format string by checking widths of each column. "
  (labels ((numeric-width (the-col)
	     (1+  (reduce #'max (mapcar #'(lambda (x) (ceiling (log (abs x) 10))) (dfcolumn df the-col)) )))
	   (string-width (the-col)
	     (1+ (reduce  #'max (mapcar #'length (dfcolumn df the-col)))))
	   (keyword-width (the-col)
	     (1+ (reduce #'max (mapcar #'(lambda (x) (length (symbol-name x))) (dfcolumn df the-col)))))
	   ;; FIXME - what is the print width of a timepoint?
	   (date-width (the-col) 12))
    
    (case (classify-print-type  type)
      ((:INTEGER :FLOAT) (numeric-width column))
      (:KEYWORD          (keyword-width column))
      (:STRING           (string-width column))
      (:DATE             (date-width column))
      (t (error "determine-print-width, unrecognized type ~%" )))))

