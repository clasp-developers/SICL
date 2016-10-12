(cl:in-package #:sicl-cons)

(defun car (list)
  (if (consp list)
      (cleavir-primop:car list)
      (if (null list)
	  nil
	  (error 'must-be-list :datum list))))

(defun cdr (list)
  (if (consp list)
      (cleavir-primop:cdr list)
      (if (null list)
	  nil
	  (error 'must-be-list :datum list))))
  
(defun rplaca (cons object)
  (if (consp list)
      (progn (cleavir-primop:rplaca cons object) cons)
      (error 'must-be-cons cons)))

(defun rplacd (cons object)
  (if (consp list)
      (progn (cleavir-primop:rplacd cons object) cons)
      (error 'must-be-cons cons)))
