(cl:in-package #:cleavir-compilation-policy)

;;; Given a normalized OPTIMIZE declaration specifier, get the
;;; value of a quality, with return value like GETHASH.

(defun optimize-value (optimize quality)
  (let ((a (assoc quality optimize)))
    (if a
	(values (second a) t)
	(values nil nil))))

;;; Given an OPTIMIZE declaration specifier in code, return a
;;; normalized specification, so that (optimize space) becomes
;;; (optimize (space 3)). Additionally check that all qualities are
;;; known and have allowed values.
(defgeneric normalize-optimize (optimize environment)
  (:argument-precedence-order environment optimize))

(defmethod normalize-optimize (optimize environment)
  (let* ((optimize-qualities
	   (cleavir-environment:optimize-qualities environment))
	 (policy-qualities ; policies can also be provided directly
	   (policy-qualities environment))
	 (all-qualities
	   (append optimize-qualities policy-qualities))
	 normalized)
    ;; use a DOLIST instead of LOOP because it gets tricky with
    ;; all the nested conditionals and collecting.
    (dolist (spec optimize normalized)
      (if (consp spec) ; like (optimize (speed 3))
	  (destructuring-bind (name value) spec
	    (let ((info (assoc name all-qualities)))
	      (if info
		  (destructuring-bind (name type default) info
		    (declare (ignore default))
		    (if (typep value type)
			(push spec normalized) ; collect
			;; TODO: add more restarts? This will just
			;; ignore the bad spec.
			(warn 'bad-optimize-value
			      :specifier spec
			      :expected type)))
		  (warn 'unknown-optimize-quality
			:specifier spec))))
	  ;; like (optimize speed)
	  (let ((info (assoc spec all-qualities)))
	    (if info
		(destructuring-bind (name type default) info
		  (declare (ignore type))
		  (push (list spec default) normalized)) ; collect
		(warn 'unknown-optimize-quality
		      :specifier spec)))))))
