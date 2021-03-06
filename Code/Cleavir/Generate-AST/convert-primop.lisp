(cl:in-package #:cleavir-generate-ast)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:EQ.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:eq)) form env system)
  (db origin (op arg1 arg2) form
    (declare (ignore op))
    (cleavir-ast:make-eq-ast
     (convert arg1 env system)
     (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:TYPEQ.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:typeq)) form env system)
  (db origin (op arg1 arg2) form
    (declare (ignore op))
    (cleavir-ast:make-typeq-ast
     (convert arg1 env system)
     arg2)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:CAR.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:car)) form env system)
  (db origin (op arg) form
    (declare (ignore op))
    (cleavir-ast:make-car-ast (convert arg env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:CDR.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:cdr)) form env system)
  (db origin (op arg) form
    (declare (ignore op))
    (cleavir-ast:make-cdr-ast (convert arg env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:RPLACA.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:rplaca)) form env system)
  (db origin (op arg1 arg2) form
    (declare (ignore op))
    (cleavir-ast:make-rplaca-ast (convert arg1 env system)
				 (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:RPLACD.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:rplacd)) form env system)
  (db origin (op arg1 arg2) form
    (declare (ignore op))
    (cleavir-ast:make-rplacd-ast (convert arg1 env system)
				 (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM-ARITHMETIC.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum-arithmetic)) form env system)
  (cleavir-code-utilities:check-form-proper-list form)
  (cleavir-code-utilities:check-argcount form 4 4)
  (destructuring-bind (variable operation normal overflow) (cdr form)
    (assert (symbolp variable))
    (let ((new-env (cleavir-env:add-lexical-variable env variable)))
      (cleavir-ast:make-if-ast (convert operation new-env system)
			       (convert normal new-env system)
			       (convert overflow new-env system)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM-+.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum-+)) form env system)
  (db origin (op arg1 arg2 variable) form
    (declare (ignore op))
    (cleavir-ast:make-fixnum-add-ast (convert arg1 env system)
				     (convert arg2 env system)
				     (convert variable env system))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM--.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum--)) form env system)
  (db origin (op arg1 arg2 variable) form
    (declare (ignore op))
    (cleavir-ast:make-fixnum-sub-ast (convert arg1 env system)
				     (convert arg2 env system)
				     (convert variable env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM-<.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum-<)) form env system)
  (destructuring-bind (arg1 arg2) (cdr form)
    (make-instance 'cleavir-ast:fixnum-less-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM-<=.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum-<=)) form env system)
  (destructuring-bind (arg1 arg2) (cdr form)
    (make-instance 'cleavir-ast:fixnum-not-greater-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM->.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum->)) form env system)
  (destructuring-bind (arg1 arg2) (cdr form)
    (make-instance 'cleavir-ast:fixnum-greater-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM->=.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum->=)) form env system)
  (destructuring-bind (arg1 arg2) (cdr form)
    (make-instance 'cleavir-ast:fixnum-not-less-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM-=.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum-=)) form env system)
  (destructuring-bind (arg1 arg2) (cdr form)
    (make-instance 'cleavir-ast:fixnum-equal-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM-ADD.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum-add)) form env system)
  (db origin (op arg1 arg2 variable) form
    (declare (ignore op))
    (cleavir-ast:make-fixnum-add-ast (convert arg1 env system)
				     (convert arg2 env system)
				     (convert variable env system))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM-SUB.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum-sub)) form env system)
  (db origin (op arg1 arg2 variable) form
    (declare (ignore op))
    (cleavir-ast:make-fixnum-sub-ast (convert arg1 env system)
				     (convert arg2 env system)
				     (convert variable env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM-LESS.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum-less)) form env system)
  (destructuring-bind (arg1 arg2) (cdr form)
    (make-instance 'cleavir-ast:fixnum-less-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM-NOT-GREATER.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum-<=)) form env system)
  (destructuring-bind (arg1 arg2) (cdr form)
    (make-instance 'cleavir-ast:fixnum-not-greater-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM-GREATER.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum-GREATER)) form env system)
  (destructuring-bind (arg1 arg2) (cdr form)
    (make-instance 'cleavir-ast:fixnum-greater-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM-NOT-LESS.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum-not-less)) form env system)
  (destructuring-bind (arg1 arg2) (cdr form)
    (make-instance 'cleavir-ast:fixnum-not-less-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FIXNUM-EQUAL.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:fixnum-equal)) form env system)
  (destructuring-bind (arg1 arg2) (cdr form)
    (make-instance 'cleavir-ast:fixnum-equal-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:LET-UNINITIALIZED.
;;;
;;; A form using the operator LET-UNINITIALIZED has the following
;;; syntax:
;;;
;;; (CLEAVIR-PRIMOP:LET-UNINITIALIZED (var*) form*)
;;;
;;; It sole purpose is to create a lexical environment for the
;;; variables in which the forms are evaluated.  An absolute
;;; requirement is that the variables must be assigned to before they
;;; are used in the forms, or else things will fail spectacularly.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:let-uninitialized)) form env system)
  (destructuring-bind (variables &rest body) (rest form)
    (let ((new-env env))
      (loop for variable in variables
	    for variable-ast = (cleavir-ast:make-lexical-ast variable)
	    do (setf new-env
		     (cleavir-env:add-lexical-variable
		      new-env variable variable-ast)))
      (process-progn (convert-sequence body new-env system)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SHORT-FLOAT-ADD.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function +.  It takes two arguments, both forms that
;;; must evaluate to short floats.
;;;
;;; The value of a form with this operator is a short float
;;; representing the sum of the two arguments.
;;;
;;; If the result of the operation is greater than the value of the
;;; constant variable MOST-POSITIVE-SHORT-FLOAT, then an error of type
;;; FLOATING-POINT-OVERFLOW is signaled.
;;;
;;; If the result of the operation is less than the value of the
;;; constant variable MOST-NEGATIVE-SHORT-FLOAT, then an error of
;;; type FLOATING-POINT-UNDERFLOW is signaled.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:short-float-add)) form env system)
  (db origin (op arg1 arg2) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:short-float-add-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system)
      :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SHORT-FLOAT-SUB.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function -.  It takes two arguments, both forms that
;;; must evaluate to short floats.
;;;
;;; The value of a form with this operator is a short float
;;; representing the difference between the two arguments.
;;;
;;; If the result of the operation is greater than the value of the
;;; constant variable MOST-POSITIVE-SHORT-FLOAT, then an error of type
;;; FLOATING-POINT-OVERFLOW is signaled.
;;;
;;; If the result of the operation is less than the value of the
;;; constant variable MOST-NEGATIVE-SHORT-FLOAT, then an error of
;;; type FLOATING-POINT-UNDERFLOW is signaled.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:short-float-sub)) form env system)
  (db origin (op arg1 arg2) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:short-float-sub-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system)
      :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SHORT-FLOAT-MUL.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function *.  It takes two arguments, both forms that
;;; must evaluate to short floats.
;;;
;;; The value of a form with this operator is a short float
;;; representing the product of the two arguments.
;;;
;;; If the result of the operation is greater than the value of the
;;; constant variable MOST-POSITIVE-SHORT-FLOAT, then an error of type
;;; FLOATING-POINT-OVERFLOW is signaled.
;;;
;;; If the result of the operation is less than the value of the
;;; constant variable MOST-NEGATIVE-SHORT-FLOAT, then an error of
;;; type FLOATING-POINT-UNDERFLOW is signaled.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:short-float-mul)) form env system)
  (db origin (op arg1 arg2) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:short-float-mul-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system)
      :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SHORT-FLOAT-DIV.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function /.  It takes two arguments, both forms that
;;; must evaluate to short floats.
;;;
;;; The value of a form with this operator is a short float
;;; representing the quotient of the two arguments.
;;;
;;; If the result of the operation is greater than the value of the
;;; constant variable MOST-POSITIVE-SHORT-FLOAT, then an error of type
;;; FLOATING-POINT-OVERFLOW is signaled.
;;;
;;; If the result of the operation is less than the value of the
;;; constant variable MOST-NEGATIVE-SHORT-FLOAT, then an error of
;;; type FLOATING-POINT-UNDERFLOW is signaled.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:short-float-div)) form env system)
  (db origin (op arg1 arg2) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:short-float-div-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system)
      :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SHORT-FLOAT-LESS.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function <.  It takes two arguments, both forms that
;;; must evaluate to short floats.  It can only appear as the
;;; TEST-FORM in the special form IF.
;;;
;;; The value of a form with this operator is a short float
;;; representing the quotient of the two arguments.
;;;
;;; If the first argument is strictly less than the second argument,
;;; then the THEN branch of the IF form is evaluated.  Otherwise, the
;;; ELSE branch of the IF form is evaluated.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:short-float-less)) form env system)
  (db origin (op arg1 arg2) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:short-float-less-ast
      :arg1-ast (convert arg1 env system)
      :arg2-ast (convert arg2 env system)
      :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:FUNCALL.
;;;
;;; This primop is similar to the function CL:FUNCALL.  The difference
;;; is that the primop does not allow function NAMES as its first
;;; argument.  It has to be a form that evaluates to a function.
;;;
;;; In order to inline CL:FUNCALL, a possible strategy would be to
;;; define a compiler macro on that function that expands to a form
;;; that turns the first argument into a function if it is not already
;;; a function and then calls this primop.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:funcall)) form env system)
  (destructuring-bind (function-form . argument-forms) (rest form)
    (cleavir-ast:make-call-ast
     (convert function-form env system)
     (loop for argument-form in argument-forms
	   collect (convert argument-form env system)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SLOT-READ.
;;;
;;; This primop takes two arguments.  The first argument is a form
;;; that must evaluate to a standard instance.  The second argument is
;;; a form that must evaluate to a fixnum and that indicates the slot
;;; number to be read.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:slot-read)) form env system)
  (destructuring-bind (instance-form slot-number-form) (rest form)
    (cleavir-ast:make-slot-read-ast
     (convert instance-form env system)
     (convert slot-number-form env system))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SLOT-WRITE.
;;;
;;; This primop takes three arguments.  The first argument is a form
;;; that must evaluate to a standard instance.  The second argument is
;;; a form that must evaluate to a fixnum and that indicates the slot
;;; number to be written.  The third argument is a form that evaluates
;;; to the object that will be written to the slot.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:slot-write)) form env system)
  (destructuring-bind (instance-form slot-number-form value-form) (rest form)
    (cleavir-ast:make-slot-write-ast
     (convert instance-form env system)
     (convert slot-number-form env system)
     (convert value-form env system))))

(defmacro define-array-conversion (simple-aref-primop-name
				   simple-aref-ast-name
				   simple-aset-primop-name
				   simple-aset-ast-name
				   non-simple-aref-primop-name
				   non-simple-aref-ast-name
				   non-simple-aset-primop-name
				   non-simple-aset-ast-name)
  `(progn
     (defmethod convert-special
	 ((symbol (eql ',simple-aref-primop-name)) form env system)
       (db origin (op array index) form
	 (declare (ignore op))
	 (make-instance ',simple-aref-ast-name
	   :array-ast (convert array env system)
	   :index-ast (convert index env system)
	   :origin origin)))

     (defmethod convert-special
	 ((symbol (eql ',simple-aset-primop-name)) form env system)
       (db origin (op array index object) form
	 (declare (ignore op))
	 (make-instance ',simple-aset-ast-name
	   :array-ast (convert array env system)
	   :index-ast (convert index env system)
	   :element-ast (convert object env system)
	   :origin origin)))

     (defmethod convert-special
	 ((symbol (eql ',non-simple-aref-primop-name)) form env system)
       (db origin (op array index) form
	 (declare (ignore op))
	 (make-instance ',non-simple-aref-ast-name
	   :array-ast (convert array env system)
	   :index-ast (convert index env system)
	   :origin origin)))

     (defmethod convert-special
	 ((symbol (eql ',non-simple-aset-primop-name)) form env system)
       (db origin (op array index object) form
	 (declare (ignore op))
	 (make-instance ',non-simple-aset-ast-name
	   :array-ast (convert array env system)
	   :index-ast (convert index env system)
	   :element-ast (convert object env system)
	   :origin origin)))))

(define-array-conversion
  cleavir-primop:simple-t-aref
  cleavir-ast:simple-t-aref-ast
  cleavir-primop:simple-t-aset
  cleavir-ast:simple-t-aset-ast
  cleavir-primop:non-simple-t-aref
  cleavir-ast:non-simple-t-aref-ast
  cleavir-primop:non-simple-t-aset
  cleavir-ast:non-simple-t-aset-ast)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SIMPLE-SHORT-FLOAT-AREF.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function AREF.  The ARRAY argument is a form that must
;;; evaluate to a simple array specialized to SHORT-FLOAT.  The INDEX
;;; argument is a form that must evaluate to a fixnum.  It represents
;;; a valid row-major index into ARRAY.
;;;
;;; This primitive operation returns the object at INDEX in ARRAY.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:simple-short-float-aref)) form env system)
  (db origin (op array index) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:simple-short-float-aref-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SIMPLE-SHORT-FLOAT-ASET.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function (SETF AREF).  The ARRAY argument is a form
;;; that must evaluate to a simple array specialized to SHORT-FLOAT.
;;; The INDEX argument is a form that must evaluate to a fixnum.  It
;;; represents a valid row-major index into ARRAY.
;;;
;;; This primitive operation stores SHORT-FLOAT at INDEX in ARRAY.
;;;
;;; Forms using this primitive operation must occur in a context that
;;; does not require a value, such as in a PROGN other than as the
;;; last form.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:simple-short-float-aset)) form env system)
  (db origin (op array index short-float) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:simple-short-float-aset-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :element-ast (convert short-float env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:NON-SIMPLE-SHORT-FLOAT-AREF.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function AREF.  The ARRAY argument is a form that must
;;; evaluate to a non-simple array specialized to SHORT-FLOAT.  The
;;; INDEX argument is a form that must evaluate to a fixnum.  It
;;; represents a valid row-major index into ARRAY.
;;;
;;; This primitive operation returns the object at INDEX in ARRAY.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:non-simple-short-float-aref)) form env system)
  (db origin (op array index) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:non-simple-short-float-aref-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:NON-SIMPLE-SHORT-FLOAT-ASET.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function (SETF AREF).  The ARRAY argument is a form
;;; that must evaluate to a non-simple array specialized to
;;; SHORT-FLOAT.  The INDEX argument is a form that must evaluate to a
;;; fixnum.  It represents a valid row-major index into ARRAY.
;;;
;;; This primitive operation stores SHORT-FLOAT at INDEX in ARRAY.
;;;
;;; Forms using this primitive operation must occur in a context that
;;; does not require a value, such as in a PROGN other than as the
;;; last form.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:non-simple-short-float-aset)) form env system)
  (db origin (op array index short-float) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:non-simple-short-float-aset-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :element-ast (convert short-float env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SIMPLE-SINGLE-FLOAT-AREF.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function AREF.  The ARRAY argument is a form that must
;;; evaluate to a simple array specialized to SINGLE-FLOAT.  The INDEX
;;; argument is a form that must evaluate to a fixnum.  It represents
;;; a valid row-major index into ARRAY.
;;;
;;; This primitive operation returns the object at INDEX in ARRAY.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:simple-single-float-aref)) form env system)
  (db origin (op array index) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:simple-single-float-aref-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SIMPLE-SINGLE-FLOAT-ASET.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function (SETF AREF).  The ARRAY argument is a form
;;; that must evaluate to a simple array specialized to SINGLE-FLOAT.
;;; The INDEX argument is a form that must evaluate to a fixnum.  It
;;; represents a valid row-major index into ARRAY.
;;;
;;; This primitive operation stores SINGLE-FLOAT at INDEX in ARRAY.
;;;
;;; Forms using this primitive operation must occur in a context that
;;; does not require a value, such as in a PROGN other than as the
;;; last form.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:simple-single-float-aset)) form env system)
  (db origin (op array index single-float) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:simple-single-float-aset-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :element-ast (convert single-float env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:NON-SIMPLE-SINGLE-FLOAT-AREF.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function AREF.  The ARRAY argument is a form that must
;;; evaluate to a non-simple array specialized to SINGLE-FLOAT.  The INDEX
;;; argument is a form that must evaluate to a fixnum.  It represents
;;; a valid row-major index into ARRAY.
;;;
;;; This primitive operation returns the object at INDEX in ARRAY.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:non-simple-single-float-aref)) form env system)
  (db origin (op array index) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:non-simple-single-float-aref-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:NON-SIMPLE-SINGLE-FLOAT-ASET.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function (SETF AREF).  The ARRAY argument is a form
;;; that must evaluate to a non-simple array specialized to SINGLE-FLOAT.
;;; The INDEX argument is a form that must evaluate to a fixnum.  It
;;; represents a valid row-major index into ARRAY.
;;;
;;; This primitive operation stores SINGLE-FLOAT at INDEX in ARRAY.
;;;
;;; Forms using this primitive operation must occur in a context that
;;; does not require a value, such as in a PROGN other than as the
;;; last form.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:non-simple-single-float-aset)) form env system)
  (db origin (op array index single-float) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:non-simple-single-float-aset-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :element-ast (convert single-float env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SIMPLE-DOUBLE-FLOAT-AREF.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function AREF.  The ARRAY argument is a form that must
;;; evaluate to a simple array specialized to DOUBLE-FLOAT.  The INDEX
;;; argument is a form that must evaluate to a fixnum.  It represents
;;; a valid row-major index into ARRAY.
;;;
;;; This primitive operation returns the object at INDEX in ARRAY.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:simple-double-float-aref)) form env system)
  (db origin (op array index) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:simple-double-float-aref-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SIMPLE-DOUBLE-FLOAT-ASET.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function (SETF AREF).  The ARRAY argument is a form
;;; that must evaluate to a simple array specialized to DOUBLE-FLOAT.
;;; The INDEX argument is a form that must evaluate to a fixnum.  It
;;; represents a valid row-major index into ARRAY.
;;;
;;; This primitive operation stores DOUBLE-FLOAT at INDEX in ARRAY.
;;;
;;; Forms using this primitive operation must occur in a context that
;;; does not require a value, such as in a PROGN other than as the
;;; last form.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:simple-double-float-aset)) form env system)
  (db origin (op array index double-float) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:simple-double-float-aset-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :element-ast (convert double-float env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:NON-SIMPLE-DOUBLE-FLOAT-AREF.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function AREF.  The ARRAY argument is a form that must
;;; evaluate to a non-simple array specialized to DOUBLE-FLOAT.  The INDEX
;;; argument is a form that must evaluate to a fixnum.  It represents
;;; a valid row-major index into ARRAY.
;;;
;;; This primitive operation returns the object at INDEX in ARRAY.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:non-simple-double-float-aref)) form env system)
  (db origin (op array index) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:non-simple-double-float-aref-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:NON-SIMPLE-DOUBLE-FLOAT-ASET.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function (SETF AREF).  The ARRAY argument is a form
;;; that must evaluate to a non-simple array specialized to DOUBLE-FLOAT.
;;; The INDEX argument is a form that must evaluate to a fixnum.  It
;;; represents a valid row-major index into ARRAY.
;;;
;;; This primitive operation stores DOUBLE-FLOAT at INDEX in ARRAY.
;;;
;;; Forms using this primitive operation must occur in a context that
;;; does not require a value, such as in a PROGN other than as the
;;; last form.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:non-simple-double-float-aset)) form env system)
  (db origin (op array index double-float) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:non-simple-double-float-aset-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :element-ast (convert double-float env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SIMPLE-LONG-FLOAT-AREF.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function AREF.  The ARRAY argument is a form that must
;;; evaluate to a simple array specialized to LONG-FLOAT.  The INDEX
;;; argument is a form that must evaluate to a fixnum.  It represents
;;; a valid row-major index into ARRAY.
;;;
;;; This primitive operation returns the object at INDEX in ARRAY.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:simple-long-float-aref)) form env system)
  (db origin (op array index) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:simple-long-float-aref-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SIMPLE-LONG-FLOAT-ASET.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function (SETF AREF).  The ARRAY argument is a form
;;; that must evaluate to a simple array specialized to LONG-FLOAT.
;;; The INDEX argument is a form that must evaluate to a fixnum.  It
;;; represents a valid row-major index into ARRAY.
;;;
;;; This primitive operation stores LONG-FLOAT at INDEX in ARRAY.
;;;
;;; Forms using this primitive operation must occur in a context that
;;; does not require a value, such as in a PROGN other than as the
;;; last form.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:simple-long-float-aset)) form env system)
  (db origin (op array index long-float) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:simple-long-float-aset-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :element-ast (convert long-float env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:NON-SIMPLE-LONG-FLOAT-AREF.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function AREF.  The ARRAY argument is a form that must
;;; evaluate to a non-simple array specialized to LONG-FLOAT.  The INDEX
;;; argument is a form that must evaluate to a fixnum.  It represents
;;; a valid row-major index into ARRAY.
;;;
;;; This primitive operation returns the object at INDEX in ARRAY.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:non-simple-long-float-aref)) form env system)
  (db origin (op array index) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:non-simple-long-float-aref-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:NON-SIMPLE-LONG-FLOAT-ASET.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function (SETF AREF).  The ARRAY argument is a form
;;; that must evaluate to a non-simple array specialized to LONG-FLOAT.
;;; The INDEX argument is a form that must evaluate to a fixnum.  It
;;; represents a valid row-major index into ARRAY.
;;;
;;; This primitive operation stores LONG-FLOAT at INDEX in ARRAY.
;;;
;;; Forms using this primitive operation must occur in a context that
;;; does not require a value, such as in a PROGN other than as the
;;; last form.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:non-simple-long-float-aset)) form env system)
  (db origin (op array index long-float) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:non-simple-long-float-aset-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :element-ast (convert long-float env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SIMPLE-BIT-AREF.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function AREF.  The ARRAY argument is a form that must
;;; evaluate to a simple array specialized to BIT.  The INDEX argument
;;; is a form that must evaluate to a fixnum.  It represents a valid
;;; row-major index into ARRAY.
;;;
;;; This primitive operation returns the bit at INDEX in ARRAY.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:simple-bit-aref)) form env system)
  (db origin (op array index) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:simple-bit-aref-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:SIMPLE-BIT-ASET.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function (SETF AREF).  The ARRAY argument is a form
;;; that must evaluate to a simple array specialized to BIT.  The
;;; INDEX argument is a form that must evaluate to a fixnum.  It
;;; represents a valid row-major index into ARRAY.
;;;
;;; This primitive operation stores BIT at INDEX in ARRAY.
;;;
;;; Forms using this primitive operation must occur in a context that
;;; does not require a value, such as in a PROGN other than as the
;;; last form.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:simple-bit-aset)) form env system)
  (db origin (op array index bit) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:simple-bit-aset-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :element-ast (convert bit env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:NON-SIMPLE-BIT-AREF.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function AREF.  The ARRAY argument is a form that must
;;; evaluate to a non-simple array specialized to BIT.  The INDEX
;;; argument is a form that must evaluate to a fixnum.  It represents
;;; a valid row-major index into ARRAY.
;;;
;;; This primitive operation returns the bit at INDEX in ARRAY.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:non-simple-bit-aref)) form env system)
  (db origin (op array index) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:non-simple-bit-aref-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :origin origin)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting CLEAVIR-PRIMOP:NON-SIMPLE-BIT-ASET.
;;;
;;; This primitive operation is used in the implementation of the
;;; Common Lisp function (SETF AREF).  The ARRAY argument is a form
;;; that must evaluate to a non-simple array specialized to BIT.  The
;;; INDEX argument is a form that must evaluate to a fixnum.  It
;;; represents a valid row-major index into ARRAY.
;;;
;;; This primitive operation stores BIT at INDEX in ARRAY.
;;;
;;; Forms using this primitive operation must occur in a context that
;;; does not require a value, such as in a PROGN other than as the
;;; last form.

(defmethod convert-special
    ((symbol (eql 'cleavir-primop:non-simple-bit-aset)) form env system)
  (db origin (op array index bit) form
    (declare (ignore op))
    (make-instance 'cleavir-ast:non-simple-bit-aset-ast
     :array-ast (convert array env system)
     :index-ast (convert index env system)
     :element-ast (convert bit env system)
     :origin origin)))
