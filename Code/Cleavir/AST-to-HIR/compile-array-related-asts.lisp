(cl:in-package #:cleavir-ast-to-hir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a SIMPLE-T-AREF-AST

(defmethod compile-ast ((ast cleavir-ast:simple-t-aref-ast) context)
  (check-context-for-one-value-ast context)
  (let ((temp1 (make-temp))
	(temp2 (make-temp)))
    (compile-ast
     (cleavir-ast:array-ast ast)
     (context
      (list temp1)
      (list (compile-ast
	     (cleavir-ast:index-ast ast)
	     (context (list temp2)
		      (list (make-instance 'cleavir-ir:simple-t-aref-instruction
			      :inputs (list temp1 temp2)
			      :outputs (results context)
			      :successors (successors context)))
		      (invocation context))))
      (invocation context)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a SIMPLE-T-ASET-AST

(defmethod compile-ast ((ast cleavir-ast:simple-t-aset-ast) context)
  (check-context-for-no-value-ast context)
  (let ((temp1 (make-temp))
	(temp2 (make-temp))
	(temp3 (make-temp)))
    (compile-ast
     (cleavir-ast:array-ast ast)
     (context
      (list temp1)
      (list (compile-ast
	     (cleavir-ast:index-ast ast)
	     (context
	      (list temp2)
	      (compile-ast
	       (cleavir-ast:element-ast ast)
	       (context
		(list temp3)
		(list (make-instance 'cleavir-ir:simple-t-aset-instruction
			:inputs (list temp1 temp2 temp3)
			:outputs '()
			:successors (successors context)))
		(invocation context)))
	      (invocation context))))
      (invocation context)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a NON-SIMPLE-T-AREF-AST

(defmethod compile-ast ((ast cleavir-ast:non-simple-t-aref-ast) context)
  (check-context-for-one-value-ast context)
  (let ((temp1 (make-temp))
	(temp2 (make-temp)))
    (compile-ast
     (cleavir-ast:array-ast ast)
     (context
      (list temp1)
      (list (compile-ast
	     (cleavir-ast:index-ast ast)
	     (context (list temp2)
		      (list (make-instance 'cleavir-ir:non-simple-t-aref-instruction
			      :inputs (list temp1 temp2)
			      :outputs (results context)
			      :successors (successors context)))
		      (invocation context))))
      (invocation context)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a NON-SIMPLE-T-ASET-AST

(defmethod compile-ast ((ast cleavir-ast:non-simple-t-aset-ast) context)
  (check-context-for-no-value-ast context)
  (let ((temp1 (make-temp))
	(temp2 (make-temp))
	(temp3 (make-temp)))
    (compile-ast
     (cleavir-ast:array-ast ast)
     (context
      (list temp1)
      (list (compile-ast
	     (cleavir-ast:index-ast ast)
	     (context
	      (list temp2)
	      (compile-ast
	       (cleavir-ast:element-ast ast)
	       (context
		(list temp3)
		(list (make-instance 'cleavir-ir:non-simple-t-aset-instruction
			:inputs (list temp1 temp2 temp3)
			:outputs '()
			:successors (successors context)))
		(invocation context)))
	      (invocation context))))
      (invocation context)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Macro for compiling specialized AREF ASTs

(defmacro compile-specialized-aref-ast
    (ast-class aref-instruction-class box-instruction-class)
  `(defmethod compile-ast ((ast ,ast-class) context)
     (check-context-for-one-value-ast context)
     (let ((temp1 (make-temp))
	   (temp2 (make-temp))
	   (temp3 (make-temp)))
       (compile-ast
	(cleavir-ast:array-ast ast)
	(context
	 (list temp1)
	 (list (compile-ast
		(cleavir-ast:index-ast ast)
		(context
		 (list temp2)
		 (list (make-instance ',aref-instruction-class
			 :inputs (list temp1 temp2)
			 :outputs (list temp3)
			 :successors
			 (list (make-instance ',box-instruction-class
				 :inputs (list temp3)
				 :outputs (results context)
				 :successors (successors context)))))
		 (invocation context))))
	 (invocation context))))))

(compile-specialized-aref-ast cleavir-ast:simple-bit-aref-ast
			      cleavir-ir:simple-bit-aref-instruction
			      cleavir-ir:bit-box-instruction)

(compile-specialized-aref-ast cleavir-ast:non-simple-bit-aref-ast
			      cleavir-ir:non-simple-bit-aref-instruction
			      cleavir-ir:bit-box-instruction)

(compile-specialized-aref-ast cleavir-ast:simple-short-float-aref-ast
			      cleavir-ir:simple-short-float-aref-instruction
			      cleavir-ir:short-float-box-instruction)

(compile-specialized-aref-ast cleavir-ast:non-simple-short-float-aref-ast
			      cleavir-ir:non-simple-short-float-aref-instruction
			      cleavir-ir:short-float-box-instruction)

(compile-specialized-aref-ast cleavir-ast:simple-single-float-aref-ast
			      cleavir-ir:simple-single-float-aref-instruction
			      cleavir-ir:single-float-box-instruction)

(compile-specialized-aref-ast cleavir-ast:non-simple-single-float-aref-ast
			      cleavir-ir:non-simple-single-float-aref-instruction
			      cleavir-ir:single-float-box-instruction)

(compile-specialized-aref-ast cleavir-ast:simple-double-float-aref-ast
			      cleavir-ir:simple-double-float-aref-instruction
			      cleavir-ir:double-float-box-instruction)

(compile-specialized-aref-ast cleavir-ast:non-simple-double-float-aref-ast
			      cleavir-ir:non-simple-double-float-aref-instruction
			      cleavir-ir:double-float-box-instruction)

(compile-specialized-aref-ast cleavir-ast:simple-long-float-aref-ast
			      cleavir-ir:simple-long-float-aref-instruction
			      cleavir-ir:long-float-box-instruction)

(compile-specialized-aref-ast cleavir-ast:non-simple-long-float-aref-ast
			      cleavir-ir:non-simple-long-float-aref-instruction
			      cleavir-ir:long-float-box-instruction)

(defmacro compile-specialized-aset-ast
    (ast-class aset-instruction-class unbox-instruction-class)
  `(defmethod compile-ast ((ast ,ast-class) context)
     (check-context-for-no-value-ast context)
     (let ((temp1 (make-temp))
	   (temp2 (make-temp))
	   (temp3 (make-temp))
	   (temp4 (make-temp)))
       (compile-ast
	(cleavir-ast:array-ast ast)
	(context
	 (list temp1)
	 (list (compile-ast
		(cleavir-ast:index-ast ast)
		(context
		 (list temp2)
		 (compile-ast
		  (cleavir-ast:element-ast ast)
		  (context
		   (list temp3)
		   (list (make-instance ',unbox-instruction-class
			   :inputs (list temp3)
			   :outputs (list temp4)
			   :successors
			   (list (make-instance ',aset-instruction-class
				   :inputs (list temp1 temp2 temp4)
				   :outputs '()
				   :successors (successors context)))))
		   (invocation context)))
		 (invocation context))))
	 (invocation context))))))

(compile-specialized-aset-ast cleavir-ast:simple-bit-aset-ast
			      cleavir-ir:simple-bit-aset-instruction
			      cleavir-ir:bit-unbox-instruction)

(compile-specialized-aset-ast cleavir-ast:non-simple-bit-aset-ast
			      cleavir-ir:non-simple-bit-aset-instruction
			      cleavir-ir:bit-unbox-instruction)

(compile-specialized-aset-ast cleavir-ast:simple-short-float-aset-ast
			      cleavir-ir:simple-short-float-aset-instruction
			      cleavir-ir:short-float-unbox-instruction)

(compile-specialized-aset-ast cleavir-ast:non-simple-short-float-aset-ast
			      cleavir-ir:non-simple-short-float-aset-instruction
			      cleavir-ir:short-float-unbox-instruction)

(compile-specialized-aset-ast cleavir-ast:simple-single-float-aset-ast
			      cleavir-ir:simple-single-float-aset-instruction
			      cleavir-ir:single-float-unbox-instruction)

(compile-specialized-aset-ast cleavir-ast:non-simple-single-float-aset-ast
			      cleavir-ir:non-simple-single-float-aset-instruction
			      cleavir-ir:single-float-unbox-instruction)

(compile-specialized-aset-ast cleavir-ast:simple-double-float-aset-ast
			      cleavir-ir:simple-double-float-aset-instruction
			      cleavir-ir:double-float-unbox-instruction)

(compile-specialized-aset-ast cleavir-ast:non-simple-double-float-aset-ast
			      cleavir-ir:non-simple-double-float-aset-instruction
			      cleavir-ir:double-float-unbox-instruction)

(compile-specialized-aset-ast cleavir-ast:simple-long-float-aset-ast
			      cleavir-ir:simple-long-float-aset-instruction
			      cleavir-ir:long-float-unbox-instruction)

(compile-specialized-aset-ast cleavir-ast:non-simple-long-float-aset-ast
			      cleavir-ir:non-simple-long-float-aset-instruction
			      cleavir-ir:long-float-unbox-instruction)
