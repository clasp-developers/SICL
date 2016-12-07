(cl:in-package #:cleavir-test-generate-ast)

(defgeneric same-p (ast1 ast2))

(defvar *table*)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Testing framework.

(defparameter *e* (make-instance 'bogus-environment))

;;; FIXME: Pass an implementation instance (rather than NIL) to
;;; GENERATE-AST.
(defun test (form value)
  (let* ((ast (cleavir-generate-ast:generate-ast form *e* nil))
	 (hoisted (cleavir-ast-transformations:hoist-load-time-value ast))
	 (v (cleavir-ast-interpreter:interpret hoisted)))
    (assert (equalp v value))))

;;; FIXME: Pass an implementation instance (rather than NIL) to
;;; GENERATE-AST.
(defun test-error (form)
  (let* ((ast (cleavir-generate-ast:generate-ast form *e* nil)))
    (multiple-value-bind (v1 v2)
	(ignore-errors 
	 (cleavir-ast-interpreter:interpret ast))
      (assert (and (null v1) (typep v2 'condition))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Tests

(defun test-constant-ast ()
  (test 234 234)
  (test '(quote a)
	'a))

(defun test-lexical-ast ()
  (test '(let ((x 10)) x)
	10)
  (test '(let ((x 10)
	       (y 20))
	  (+ x y))
	30)
  (test '(let ((x 10))
	  (let ((x 20)
		(y x))
	    (+ x y)))
	30))

(defun test-symbol-value-ast ()
  (test '*print-base*
	10))

(defun test-block-return-from-ast ()
  (test '(block x (return-from x 10) 20)
	10))

(defun test-if-ast ()
  (test '(if t 10 20)
	10)
  (test '(if nil 10 20)
	20))

(defun test-tagbody-ast ()
  (test '(let ((x 1)) (tagbody (setq x 2) (go a) (setq x 3) a) x)
	2))

(defun test-fdefinition-ast ()
  (test '(function car)
	#'car))

(defun test-call ()
  (test '(1+ *print-base*)
	11)
  (test '(flet ((f () 1))
	  (+ (f) 2))
	3)
  (test '(flet ((f (x) x))
	  (+ (f 1) 2))
	3)
  (test '(flet ((f (x) x)
		(g (x) x))
	  (+ (f 1) (g 2)))
	3)
  (test '(flet ((f (x &optional (y 234)) (+ x y)))
	  (f 10))
	244)
  (test '(flet ((f (x &optional (y 234)) (+ x y)))
	  (f 10 20))
	30)
  (test '(flet ((f (x) (+ x 1))
		(g (x) (+ x 2)))
	  (+ (f 10) (g 20)))
	33)
  (test '(flet ((f (x &optional (y 234) (z (1+ y))) (+ x y z)))
	  (f 10 20 30))
	60)
  (test '(flet ((f (x &optional (y 234) (z (1+ y))) (+ x y z)))
	  (f 10 20))
	51)
  (test '(flet ((f (x &optional (y 234) (z (1+ y))) (+ x y z)))
	  (f 10))
	479)
  (test '(flet ((f (x &optional (y 234 y-p)) (list x y y-p)))
	  (f 10))
	'(10 234 nil))
  (test '(flet ((f (x &optional (y 234 y-p)) (list x y y-p)))
	  (f 10 20))
	'(10 20 t))
  (test '(flet ((f (&key x) x))
	  (f))
	nil)
  (test '(flet ((f (&key x) x))
	  (f :x 10))
	10)
  (test '(flet ((f (&key (x 10 x-p)) (list x x-p)))
	  (f :x 20))
	'(20 t))
  (test '(flet ((f (&key (x 10 x-p)) (list x x-p)))
	  (f))
	'(10 nil))
  (test '(flet ((f (&key (x 10) (y 20)) (list x y)))
	  (f))
	'(10 20))
  (test '(flet ((f (&key (x 10) (y 20)) (list x y)))
	  (f :x 'a))
	'(a 20))
  (test '(flet ((f (&key (x 10) (y 20)) (list x y)))
	  (f :y 'a))
	'(10 a))
  (test '(flet ((f (&key (x 10) (y (1+ x))) (list x y)))
	  (f :y 'a))
	'(10 a))
  (test '(flet ((f (&key (x 10) (y (1+ x))) (list x y)))
	  (f))
	'(10 11))
  (test '(flet ((f (&key (x 10) (y (1+ x))) (list x y)))
	  (f :x 20))
	'(20 21))
  (test '(flet ((f (&key (x 10) &allow-other-keys) x))
	  (f))
	10)
  (test '(flet ((f (&key (x 10) &allow-other-keys) x))
	  (f :x 20))
	20)
  (test '(flet ((f (&key (x 10 x-p) &allow-other-keys) (list x x-p)))
	  (f :y 30))
	'(10 nil))
  (test '(flet ((f (y &optional (x y x-p) (z x) &rest rest &key k1 (k2 x-p) &allow-other-keys &aux (zz 234))
		 (declare (special x))
		 x))
	  (f 10 20 30))
	20))

(defun test-labels ()
  (test '(labels ((f () 1))
	  (+ (f) 2))
	3)
  (test '(labels ((f (n) (if (zerop n) 1 (* n (f (1- n))))))
	  (f 5))
	120)
  (test '(labels ((f (x &optional (y 234)) (+ x y)))
	  (f 10))
	244))

(defun test-let* ()
  (test '(let* ((x 10)) x)
	10)
  (test '(let* ((x 10) (y (1+ x))) (+ x y))
	21)
  (test '(let* ((x 10) (y (1+ x)))
	  (declare (type integer x))
	  (+ x y))
	21))

(defun test-the ()
  (test '(the t 234)
	234)
  (test-error '(the symbol 234)))

(defun test-function ()
  (test '(flet ((f (x) (> x 3)))
	  (find-if #'f '(1 2 5 7)))
	5))

(defun test-symbol-macrolet ()
  (test '(symbol-macrolet ((m (f 10)))
	  (flet ((f (x) (+ x 2)))
	    m))
	12))

(defun no-local-calls (ast)
  ;; this is probably a bit fragile, but it searches for call-asts
  ;;  and returns nil if any of them don't call an (fdefinition x)
  (cleavir-ast:map-ast-depth-first-preorder
   (lambda (ast)
     (when (and (typep ast 'cleavir-ast:call-ast)
		(typep (cleavir-ast:callee-ast ast)
		       '(not cleavir-ast:fdefinition-ast)))
       (return-from no-local-calls nil)))
   ast)
  t)

(defun local-inline-test (form)
  (let ((inline (subst '(declare (inline f))
		       'shibboleth form))
	(noinline (subst '(declare (noinline f))
			 'shibboleth form)))
    (let ((inline
	    (cleavir-generate-ast:generate-ast inline *e* nil))
	  (noinline
	    (cleavir-generate-ast:generate-ast noinline *e* nil)))
      (assert (no-local-calls inline))
      (assert (not (no-local-calls noinline)))
      (let ((inline
	      (cleavir-ast-interpreter:interpret
	       (cleavir-ast-transformations:hoist-load-time-value
		inline)))
	    (noinline
	      (cleavir-ast-interpreter:interpret
	       (cleavir-ast-transformations:hoist-load-time-value
		noinline))))
	(assert (equalp inline noinline))))))

(defun local-inline-test-error (form)
  (let* ((ast (cleavir-generate-ast:generate-ast form *e* nil))
	 (hoist (cleavir-ast-transformations:hoist-load-time-value
		 ast)))
    (multiple-value-bind (val cond)
	(ignore-errors (cleavir-ast-interpreter:interpret hoist))
      ;; too many arguments, etc. signals a program error.
      ;;  or rather it should, but the interpreter does not.
      (assert (and (null val) (typep cond 'error))))))

(defun test-local-inline ()
  (local-inline-test '(flet ((f ())) shibboleth (f)))
  (local-inline-test
   '(flet ((f (x) (1+ x))) shibboleth (f 38919)))
  (local-inline-test
   '(flet ((f (x &optional (y 234)) (+ x y)))
     shibboleth
     (f 10 20)))
  (local-inline-test
   '(flet ((f (x &optional (y 234) (z t z-p)) (list x y z)))
     shibboleth
     (f 10 20)))
  (local-inline-test '(flet ((f (x) x)) shibboleth (+ (f 1) 2)))
  (local-inline-test
   '(flet ((f (x &optional (y 234 y-p)) (list x y y-p)))
     shibboleth
     (f 10)))
  (local-inline-test
   '(flet ((f (x &rest y) (list x y)))
     shibboleth
     (f 1 3 89 47)))
  (local-inline-test
   '(labels ((f (x &optional y &rest z) (list x y z)))
     shibboleth
     (list (f 1 2 3 4) (f 1 2) (f 1))))
  (local-inline-test-error '(flet ((f ()))
			     (declare (inline f))
			     (f 0)))
  (local-inline-test-error '(flet ((f (x) x))
			     (declare (inline f))
			     (f)))
  (local-inline-test-error '(flet ((f (&optional x) x))
			     (declare (inline f))
			     (f 0 0))))

(defun run-tests ()
  (test-constant-ast)
  (test-lexical-ast)
  (test-symbol-value-ast)
  (test-block-return-from-ast)
  (test-if-ast)
  (test-tagbody-ast)
  (test-fdefinition-ast)
  (test-call)
  (test-labels)
  (test-let*)
  (test-the)
  (test-symbol-macrolet)
  (test-function)
  (test-local-inline))
