;;;; -*- Mode: lisp -*-
;;;;
;;;; Copyright (c) 2007 Raymond Toy
;;;;
;;;; Permission is hereby granted, free of charge, to any person
;;;; obtaining a copy of this software and associated documentation
;;;; files (the "Software"), to deal in the Software without
;;;; restriction, including without limitation the rights to use,
;;;; copy, modify, merge, publish, distribute, sublicense, and/or sell
;;;; copies of the Software, and to permit persons to whom the
;;;; Software is furnished to do so, subject to the following
;;;; conditions:
;;;;
;;;; The above copyright notice and this permission notice shall be
;;;; included in all copies or substantial portions of the Software.
;;;;
;;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
;;;; OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;;;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;;;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;;;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
;;;; OTHER DEALINGS IN THE SOFTWARE.


;;; Some simple timing tests
(in-package #:oct)

(defun time-add (&optional (n 100000))
  (declare (fixnum n))
  (flet ((sum-double ()
	   (let ((sum 0d0))
	     (declare (double-float sum)
		      (optimize (speed 3)))
	     (dotimes (k n)
	       (declare (fixnum k))
	       (setf sum (cl:+ sum 1d0)))
	     sum))
	 (sum-%qd ()
	   (let ((sum (qdi::make-qd-d 0d0))
		 (one (qdi::make-qd-d 1d0)))
	     (declare (type qdi::%quad-double sum)
		      (optimize (speed 3)))
	     (dotimes (k n)
	       (declare (fixnum k))
	       (setf sum (add-qd sum one)))
	     sum))
	 (sum-qd ()
	   (let ((sum #q0))
	     (declare (type qd-real sum)
		      (optimize (speed 3)))
	     (dotimes (k n)
	       (declare (fixnum k))
	       (setf sum (+ sum #q1)))
	     sum)))
    (format t "Add double-floats ~d times~%" n)
    #+cmu (ext:gc :full t)
    (time (sum-double))
    (format t "Add %quad-double (internal) ~d times~%" n)
    #+cmu (ext:gc :full t)
    (time (sum-%qd))
    (format t "Add QD-REAL (method) ~d times~%" n)
    #+cmu (ext:gc :full t)
    (time (sum-qd))))


(defun time-mul (&optional (n 100000))
  (declare (fixnum n))
  (flet ((mul-double ()
	   (let ((sum 0d0))
	     (declare (double-float sum)
		      (optimize (speed 3)))
	     (dotimes (k n)
	       (declare (fixnum k))
	       (setf sum (cl:* sum 1d0)))
	     sum))
	 (mul-%qd ()
	   (let ((sum (qdi::make-qd-d 0d0))
		 (one (qdi::make-qd-d 1d0)))
	     (declare (type qdi::%quad-double sum)
		      (optimize (speed 3)))
	     (dotimes (k n)
	       (declare (fixnum k))
	       (setf sum (mul-qd sum one)))
	     sum))
	 (mul-qd ()
	   (let ((sum #q0))
	     (declare (type qd-real sum)
		      (optimize (speed 3)))
	     (dotimes (k n)
	       (declare (fixnum k))
	       (setf sum (* sum #q1)))
	     sum)))
    (format t "Multiply double-floats ~d times~%" n)
    #+cmu (ext:gc :full t)
    (time (mul-double))
    (format t "Multiply %quad-double (internal) ~d times~%" n)
    #+cmu (ext:gc :full t)
    (time (mul-%qd))
    (format t "Multiply QD-REAL (method) ~d times~%" n)
    #+cmu (ext:gc :full t)
    (time (mul-qd))))

(defun time-div (&optional (n 100000))
  (declare (fixnum n))
  (flet ((div-double ()
	   (let ((sum 7d0))
	     (declare (double-float sum)
		      (optimize (speed 3)))
	     (dotimes (k n)
	       (declare (fixnum k))
	       (setf sum (cl:/ sum 1d0)))
	     sum))
	 (div-%qd ()
	   (let ((sum (qdi::make-qd-d 7d0))
		 (one (qdi::make-qd-d 1d0)))
	     (declare (type qdi::%quad-double sum)
		      (optimize (speed 3)))
	     (dotimes (k n)
	       (declare (fixnum k))
	       (setf sum (div-qd sum one)))
	     sum))
	 (div-qd ()
	   (let ((sum #q7))
	     (declare (type qd-real sum)
		      (optimize (speed 3)))
	     (dotimes (k n)
	       (declare (fixnum k))
	       (setf sum (/ sum #q1)))
	     sum)))
    (format t "Divide double-floats ~d times~%" n)
    #+cmu (ext:gc :full t)
    (time (div-double))
    (format t "Divide %quad-double (internal) ~d times~%" n)
    #+cmu (ext:gc :full t)
    (time (div-%qd))
    (format t "Divide QD-REAL (method) ~d times~%" n)
    #+cmu (ext:gc :full t)
    (time (div-qd))))

(defun time-sqrt (&optional (n 100000))
  (declare (fixnum n))
  (flet ((sqrt-double ()
	   (let ((sum 7d0))
	     (declare (double-float sum)
		      (optimize (speed 3)))
	     (dotimes (k n)
	       (declare (fixnum k))
	       (setf sum (cl:sqrt sum)))
	     sum))
	 (sqrt-%qd ()
	   (let ((sum (qdi::make-qd-d 7d0)))
	     (declare (type qdi::%quad-double sum)
		      (optimize (speed 3)))
	     (dotimes (k n)
	       (declare (fixnum k))
	       (setf sum (sqrt-qd sum)))
	     sum))
	 (sqrt-qd-real ()
	   (let ((sum #q7))
	     (declare (type qd-real sum)
		      (optimize (speed 3)))
	     (dotimes (k n)
	       (declare (fixnum k))
	       (setf sum (sqrt sum)))
	     sum)))
    (format t "Sqrt double-floats ~d times~%" n)
    #+cmu (ext:gc :full t)
    (time (sqrt-double))
    (format t "Sqrt %quad-double (internal) ~d times~%" n)
    #+cmu (ext:gc :full t)
    (time (sqrt-%qd))
    (format t "Sqrt QD-REAL (method) ~d times~%" n)
    #+cmu (ext:gc :full t)
    (time (sqrt-qd-real))))