(cl:in-package #:cleavir-ast-to-hir)

;;; During compilation, this variable contains a hash table that maps
;;; ASTs representing locations to HIR locations.
(defvar *location-info*)

;;; Given an AST of type LEXICAL-LOCATION, return a corresponding HIR
;;; lexical location.  If no corresponding HIR location is found, one
;;; is created and retured, and made to correspond to the AST in
;;; future invocations.
(defun find-or-create-location (ast)
  (or (gethash ast *location-info*)
      (let ((location
	      (etypecase ast
		(cleavir-ast:lexical-ast
		 (cleavir-ir:make-lexical-location
		  (cleavir-ast:name ast))))))
	(setf (gethash ast *location-info*) location))))

;;; Convenience function to avoid having long function names.
(defun make-temp ()
  (cleavir-ir:new-temporary))

;;; Given a list of results and a successor, generate a sequence of
;;; instructions preceding that successor, and that assign NIL to each
;;; result in the list.
(defun nil-fill (results successor)
  (let ((next successor))
    (loop for value in results
	  do (setf next
		   (cleavir-ir:make-assignment-instruction
		    (cleavir-ir:make-constant-input 'nil)
		    value next))
	  finally (return next))))

;;; The generic function called on various AST types.  It compiles AST
;;; in the compilation context CONTEXT and returns the first
;;; instruction resulting from the compilation.
(defgeneric compile-ast (ast context))

;;; Instructions inherit policies from the AST that birthed them.
(defmethod compile-ast :around ((ast cleavir-ast:ast) context)
  (declare (ignore context))
  (let ((cleavir-ir:*policy* (cleavir-ast:policy ast)))
    (call-next-method)))

;;; When an AST that is meant for a test (as indicated by it being an
;;; instance of BOOLEAN-AST-MIXIN) is compiled in a context where one
;;; or more values are needed, we signal an error.
(defmethod compile-ast :around ((ast cleavir-ast:boolean-ast-mixin) context)
  (with-accessors ((results results)
		   (successors successors)
		   (invocation invocation))
      context
    (ecase (length successors)
      (1
       ;; FIXME: Use a specific condition
       (error "Boolean AST in a context requiring a value"))
      (2
       (call-next-method)))))

(defun check-context-for-boolean-ast (context)
  (assert (and (zerop (length (results context)))
	       (= (length (successors context)) 2))))

;;; This :AROUND method serves as an adapter for the compilation of
;;; ASTs that generate a single value.  If such an AST is compiled in
;;; a unfit context (i.e, a context other than one that has a single
;;; successor and a single required value), this method either creates
;;; a perfect context for compiling that AST together with
;;; instructions for satisfying the unfit context, or it signals an
;;; error if appropriate.
(defmethod compile-ast :around ((ast cleavir-ast:one-value-ast-mixin) context)
  (with-accessors ((results results)
		   (successors successors)
		   (invocation invocation))
      context
    (ecase (length successors)
      (1
       ;; We have a context with one successor, so RESULTS can be a
       ;; list of any length, or it can be a values location,
       ;; indicating that all results are needed.
       (cond ((typep results 'cleavir-ir:values-location)
	      ;; The context is such that all multiple values are
	      ;; required.
	      (let ((temp (make-temp)))
		(call-next-method
		 ast
		 (context (list temp)
			  (list (cleavir-ir:make-fixed-to-multiple-instruction
				 (list temp)
				 results
				 (first successors)))
			  invocation))))
	     ((null results)
	      ;; We don't need the result.  This situation typically
	      ;; happens when we compile a form other than the last of
	      ;; a PROGN-AST.
	      (if (cleavir-ast:side-effect-free-p ast)
		  (progn
		    ;; For now, we do not emit this warning.  It is a bit
		    ;; too annoying because there is some automatically
		    ;; generated code that is getting warned about.
		    ;; (warn "Form compiled in a context requiring no value.")
		    (first successors))
		  ;; We allocate a temporary variable to receive the
		  ;; result, and that variable will not be used.
		  (call-next-method ast
				    (context (list (make-temp))
					     successors
					     invocation))))
	     (t
	      ;; We have at least one result.  In case there is more
	      ;; than one, we generate a successor where all but the
	      ;; first one are filled with NIL.
	      (let ((successor (nil-fill (rest results) (first successors))))
		(call-next-method ast
				  (context (list (first results))
					   (list successor)
					   invocation))))))
      (2
       ;; We have a context where a test of a Boolean is required.
       ;; FIXME: Use a specific condition.
       (error "AST generating value(s) found where a Boolean AST is required")))))

(defun check-context-for-one-value-ast (context)
  (assert (and (= (length (results context)) 1)
	       (= (length (successors context)) 1))))

(defun check-context-for-no-value-ast (context)
  (assert (and (null (results context))
	       (= (length (successors context)) 1))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile ASTs that represent Common Lisp operations.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile an IF-AST.
;;;
;;; We compile the test of the IF-AST in a context where no value is
;;; required and with two successors, the else branch and the then
;;; branch.  The two branches are compiled in the same context as the
;;; IF-AST itself.

(defmethod compile-ast ((ast cleavir-ast:if-ast) context)
  (let ((then-branch (compile-ast (cleavir-ast:then-ast ast) context))
	(else-branch (compile-ast (cleavir-ast:else-ast ast) context)))
    (compile-ast (cleavir-ast:test-ast ast)
		 (context '()
			  (list then-branch else-branch)
			  (invocation context)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a PROGN-AST.
;;;
;;; The last sub-ast is compiled in the same context as the progn-ast
;;; itself.  All the others are compiled in a context where no value is
;;; required, and with the code for the following form as a single
;;; successor.
;;;
;;; In the process of converting forms to ASTs, we make sure that
;;; every PROGN-AST has at least one FORM-AST in it.  Otherwise a
;;; different AST is generated instead.

(defmethod compile-ast ((ast cleavir-ast:progn-ast) context)
  (let ((form-asts (cleavir-ast:form-asts ast)))
    (assert (not (null form-asts)))
    (let ((next (compile-ast (car (last form-asts)) context)))
      (loop for sub-ast in (cdr (reverse (cleavir-ast:form-asts ast)))
	    do (setf next (compile-ast sub-ast
				       (context '()
						(list next)
						(invocation context)))))
      next)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a BLOCK-AST.
;;;
;;; A BLOCK-AST is compiled by compiling its body in the same context
;;; as the block-ast itself.  However, we store that context in the
;;; *BLOCK-INFO* hash table using the block-ast as a key, so that a
;;; RETURN-FROM-AST that refers to this block can be compiled in the
;;; same context.
;;;
;;; FIXME: we should make sure the context we store is one that has a
;;; single successor.  If this BLOCK-AST was compiled in a context
;;; with two successors, we should create a new context for it.

(defparameter *block-info* nil)

(defun block-info (block-ast)
  (gethash block-ast *block-info*))

(defun (setf block-info) (new-info block-ast)
  (setf (gethash block-ast *block-info*) new-info))

(defmethod compile-ast ((ast cleavir-ast:block-ast) context)
  (setf (gethash ast *block-info*) context)
  (compile-ast (cleavir-ast:body-ast ast) context))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a RETURN-FROM-AST.
;;;
;;; We must determine whether this RETURN-FROM represents a local
;;; control transfer or a non-local control transfer.  To determine
;;; that, we compare the INVOCATION of the context in which the
;;; corresponding BLOCK-AST was compiled to the INVOCATION of the
;;; current CONTEXT.  If they are the same, we have a local control
;;; transfer.  If not, we have a non-local control transfer.
;;;
;;; If we have a local control transfer, we compile the
;;; RETURN-FROM-AST is as follows: The context is ignored, because the
;;; RETURN-FROM does not return a value in its own context.  Instead,
;;; the FORM-AST of the RETURN-FROM-AST is compiled in the same
;;; context as the corresponding BLOCK-AST was compiled in.
;;;
;;; If we have a non-local control transfer, we must compile the
;;; FORM-AST with the same results as the ones in the context in which
;;; the BLOCK-AST was compiled, but in the current invocation.  We
;;; then insert and UNWIND-INSTRUCTION that serves as the successor of
;;; the compilation of the FORM-AST.  The successor of that
;;; UNWIND-INSTRUCTION is the successor of the context in which the
;;; BLOCK-AST was compiled.

(defmethod compile-ast ((ast cleavir-ast:return-from-ast) context)
  (let ((block-context (block-info (cleavir-ast:block-ast ast))))
    (with-accessors ((results results)
		     (successors successors)
		     (invocation invocation))
	block-context
      (if (eq (invocation context) invocation)
	  (compile-ast (cleavir-ast:form-ast ast) block-context)
	  (let* ((new-successor (cleavir-ir:make-unwind-instruction
				 (first successors) invocation))
		 (new-context (context results
				       (list new-successor)
				       (invocation context))))
	    (compile-ast (cleavir-ast:form-ast ast) new-context))))))
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a TAGBODY-AST.
;;;
;;; The TAGBODY-AST is always the first AST of two ASTs in a
;;; PROGN-AST.  The second AST in the PROGN-AST is a CONSTANT-AST
;;; containing NIL.  Therefore, we know that the TAGBODY-AST is always
;;; compiled in a context where no values are required and that has a
;;; single successor.

;;; During AST-to-HIR translation, this variable contains a hash table
;;; that maps a TAG-AST to information about the tag.  The information
;;; is a list of two elements.  The first element is the NOP
;;; instruction that will be the target of any GO instruction to that
;;; tag.  The second element is the INVOCATION of the compilation
;;; context, which is used to determine whether the GO to this tag is
;;; local or non-local.
(defparameter *go-info* nil)

(defun go-info (tag-ast)
  (gethash tag-ast *go-info*))

(defun (setf go-info) (new-info tag-ast)
  (setf (gethash tag-ast *go-info*) new-info))

;;; For each TAG-AST in the tagbody, a NOP instruction is created.  A
;;; list containing this instruction and the INVOCATION of the current
;;; context is created.  That list is entered into the hash table
;;; *GO-INFO* using the TAG-AST as a key.  Then the items are compiled
;;; in the reverse order, stacking new instructions before the
;;; successor computed previously.  Compiling a TAG-AST results in the
;;; successor of the corresponding NOP instruction being modified to
;;; point to the remining instructions already computed.  Compiling
;;; something else is done in a context with an empty list of results,
;;; using the remaining instructions already computed as a single
;;; successor.
(defmethod compile-ast ((ast cleavir-ast:tagbody-ast) context)
  (loop for item-ast in (cleavir-ast:item-asts ast)
	do (when (typep item-ast 'cleavir-ast:tag-ast)
	     (setf (go-info item-ast)
		   (list (cleavir-ir:make-nop-instruction nil)
			 (invocation context)))))
  (with-accessors ((successors successors))
      context
    (let ((next (first successors)))
      (loop for item-ast in (reverse (cleavir-ast:item-asts ast))
	    do (setf next
		     (if (typep item-ast 'cleavir-ast:tag-ast)
			 (let ((instruction (first (go-info item-ast))))
			   (setf (cleavir-ir:successors instruction)
				 (list next))
			   instruction)
			 (compile-ast item-ast
				      (context '()
					       (list next)
					       (invocation context))))))
      next)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a GO-AST.
;;;
;;; We obtain the GO-INFO that was stored when the TAG-AST of this
;;; GO-AST was compiled.  This info is a list of two elements.  The
;;; first element is the NOP instruction that resulted from the
;;; compilation of the TAG-AST.  The second element is the INVOCATION
;;; of the compilation context when the TAG-AST was compiled.
;;;
;;; The INVOCATION of the parameter CONTEXT is compared to the
;;; invocation in which the target TAG-AST of this GO-AST was
;;; compiled, which is the second element of the GO-INFO list.  If
;;; they are the same, we have a local transfer of control, so we just
;;; return the NOP instruction that resulted from the compilation of
;;; the TAG-AST.  If they are not the same, we generate an
;;; UNWIND-INSTRUCTION with that NOP instruction as its successor, and
;;; we store the INVOCATION of the compilation context when the
;;; TAG-AST was compiled in the UNWIND-INSTRUCTION so that we know how
;;; far to unwind.

(defmethod compile-ast ((ast cleavir-ast:go-ast) context)
  (let ((info (go-info (cleavir-ast:tag-ast ast))))
    (if (eq (second info) (invocation context))
	(first info)
	(cleavir-ir:make-unwind-instruction (first info) (second info)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a CALL-AST.

(defmethod compile-ast ((ast cleavir-ast:call-ast) context)
  (with-accessors ((results results)
		   (successors successors))
      context
    (let* ((all-args (cons (cleavir-ast:callee-ast ast)
			   (cleavir-ast:argument-asts ast)))
	   (temps (make-temps all-args)))
      (compile-arguments
       all-args
       temps
       (ecase (length successors)
	 (1
	  (if (typep results 'cleavir-ir:values-location)
	      (make-instance 'cleavir-ir:funcall-instruction
		:inputs temps
		:outputs (list results)
		:successors successors)
	      (let* ((values-temp (make-instance 'cleavir-ir:values-location)))
		(make-instance 'cleavir-ir:funcall-instruction
		  :inputs temps
		  :outputs (list values-temp)
		  :successors
		  (list (cleavir-ir:make-multiple-to-fixed-instruction
			 values-temp results (first successors)))))))
	 (2
	  (error "CALL-AST appears in a Boolean context.")))
       (invocation context)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a FUNCTION-AST.
;;;
;;; The FUNCTION-AST represents a closure, so we compile it by
;;; compiling its LAMBDA-LIST and BODY-AST into some code, represented
;;; by the first instruction in the body.  We then generate an
;;; ENCLOSE-INSTRUCTION that takes this code as input.

(defun translate-lambda-list (lambda-list)
  (loop for item in lambda-list
	collect (cond ((member item lambda-list-keywords)
		       item)
		      ((consp item)
		       (if (= (length item) 3)
			   (list (first item)
				 (find-or-create-location (second item))
				 (find-or-create-location (third item)))
			   (list (find-or-create-location (first item))
				 (find-or-create-location (second item)))))
		      (t
		       (find-or-create-location item)))))


;;; The logic of this method is a bit twisted.  The reason is that we
;;; must create the ENTER-INSTRUCTION before we compile the body of
;;; the FUNCTION-AST.  The reason for that is that the
;;; ENTER-INSTRUCTION should be the value of the INVOCATION of the
;;; context when the body is compiled.  On the other hand, the result
;;; of compiling the body must be the successor of the ENTER-INSTRUCTION.
;;;
;;; We solve this problem by creating the ENTER-INSTRUCTION with a
;;; dummy successor.  Once the body has been compiled, we call
;;; REINITIALIZE-INSTANCE on the ENTER-INSTRUCTION to set the slots to
;;; their final values.
(defmethod compile-ast ((ast cleavir-ast:function-ast) context)
  (check-context-for-one-value-ast context)
  (let* ((ll (translate-lambda-list (cleavir-ast:lambda-list ast)))
	 (enter (cleavir-ir:make-enter-instruction ll))
	 (values (cleavir-ir:make-values-location))
	 (return (cleavir-ir:make-return-instruction (list values)))
	 (body-context (context values (list return) enter))
	 (body (compile-ast (cleavir-ast:body-ast ast) body-context)))
    (reinitialize-instance enter :successors (list body))
    (cleavir-ir:make-enclose-instruction
     (first (results context))
     (first (successors context))
     enter)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a SETQ-AST.

(defmethod compile-ast ((ast cleavir-ast:setq-ast) context)
  (check-context-for-no-value-ast context)
  (let ((location (find-or-create-location (cleavir-ast:lhs-ast ast))))
    (compile-ast
     (cleavir-ast:value-ast ast)
     (context
      (list location)
      (successors context)
      (invocation context)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a MULTIPLE-VALUE-SETQ-AST.

(defmethod compile-ast ((ast cleavir-ast:multiple-value-setq-ast) context)
  (check-context-for-no-value-ast context)
  (let ((locations (mapcar #'find-or-create-location
			   (cleavir-ast:lhs-asts ast))))
    (compile-ast
     (cleavir-ast:value-ast ast)
     (context
      locations
      (successors context)
      (invocation context)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a THE-AST.

(defun make-type-check (type-specifier var successor)
  (cleavir-ir:make-the-instruction var successor type-specifier))

(defmethod compile-ast ((ast cleavir-ast:the-ast) context)
  (with-accessors ((results results)
		   (successors successors)
		   (invocation invocation))
      context
    (assert (= (length successors) 1))
    (let ((form-ast (cleavir-ast:form-ast ast))
	  (required (cleavir-ast:required-types ast))
	  (optional (cleavir-ast:optional-types ast))
	  (rest (cleavir-ast:rest-type ast))
	  (successor (first successors)))
      (cond
	((typep results 'cleavir-ir:values-location)
	 (compile-ast form-ast
		      (context results
			       (list
				(cleavir-ir:make-the-values-instruction
				 results successor
				 required optional rest))
			       invocation)))
	(t ; lexical locations
	 (loop for lex in results
	       do (setf successor
			(cleavir-ir:make-the-instruction
			 lex successor (cond
					 (required (pop required))
					 (optional (pop optional))
					 (t rest)))))
	 (compile-ast form-ast (context results
					(list successor)
					invocation)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a SYMBOL-VALUE-AST.

(defmethod compile-ast ((ast cleavir-ast:symbol-value-ast) context)
  (check-context-for-one-value-ast context)
  (let ((temp (make-temp)))
    (compile-ast
     (cleavir-ast:symbol-ast ast)
     (context
      (list temp)
      (list (cleavir-ir:make-symbol-value-instruction
	     temp (first (results context)) (first (successors context))))
      (invocation context)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a SET-SYMBOL-VALUE-AST.

(defmethod compile-ast ((ast cleavir-ast:set-symbol-value-ast) context)
  (check-context-for-no-value-ast context)
  (let ((temp1 (make-temp))
	(temp2 (make-temp)))
    (compile-ast
     (cleavir-ast:symbol-ast ast)
     (context
      (list temp1)
      (list (compile-ast
	     (cleavir-ast:value-ast ast)
	     (context
	      (list temp2)
	      (list (cleavir-ir:make-set-symbol-value-instruction
		     temp1 temp2 (first (successors context))))
	      (invocation context))))
      (invocation context)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a FDEFINITION-AST.

(defmethod compile-ast ((ast cleavir-ast:fdefinition-ast) context)
  (check-context-for-one-value-ast context)
  (let ((temp (make-temp)))
    (compile-ast
     (cleavir-ast:name-ast ast)
     (context
       (list temp)
       (list
	(cleavir-ir:make-fdefinition-instruction
	 temp
	 (first (results context))
	 (first (successors context))))
       (invocation context)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a TYPEQ-AST.

(defmethod compile-ast ((ast cleavir-ast:typeq-ast) context)
  (with-accessors ((results results)
		   (successors successors))
      context
    (let ((temp (make-temp)))
      (compile-ast
       (cleavir-ast:form-ast ast)
       (context
	(list temp)
	(list (cleavir-ir:make-typeq-instruction
	       temp
	       successors
	       (cleavir-ast:type-specifier ast)))
	(invocation context))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a LEXICAL-AST.
;;;
;;; This AST has ONE-VALUE-AST-MIXIN as a superclass.

(defmethod compile-ast ((ast cleavir-ast:lexical-ast) context)
  (check-context-for-one-value-ast context)
  (cleavir-ir:make-assignment-instruction
   (find-or-create-location ast)
   (first (results context))
   (first (successors context))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; COMPILE-TOPLEVEL
;;;
;;; This is the main entry point.

(defun compile-toplevel (ast)
  (let ((*block-info* (make-hash-table :test #'eq))
	(*go-info* (make-hash-table :test #'eq))
	(*location-info* (make-hash-table :test #'eq))
	(cleavir-ir:*policy* (cleavir-ast:policy ast)))
    (assert (typep ast 'cleavir-ast:top-level-function-ast))
    (let* ((ll (translate-lambda-list (cleavir-ast:lambda-list ast)))
	   (forms (cleavir-ast:forms ast))
	   (enter (cleavir-ir:make-top-level-enter-instruction ll forms))
	   (values (cleavir-ir:make-values-location))
	   (return (cleavir-ir:make-return-instruction (list values)))
	   (body-context (context values (list return) enter))
	   (body (compile-ast (cleavir-ast:body-ast ast) body-context)))
      ;; Now we must set the successors of the ENTER-INSTRUCTION to a
      ;; list of the result of compiling the AST.
      (reinitialize-instance enter :successors (list body))
      ;; Make sure the list of predecessors of each instruction is
      ;; initialized correctly.
      (cleavir-ir:set-predecessors enter)
      enter)))

(defun compile-toplevel-unhoisted (ast)
  (let ((*block-info* (make-hash-table :test #'eq))
	(*go-info* (make-hash-table :test #'eq))
	(*location-info* (make-hash-table :test #'eq))
	(cleavir-ir:*policy* (cleavir-ast:policy ast)))
    (let* ((ll (translate-lambda-list (cleavir-ast:lambda-list ast)))
	   (enter (cleavir-ir:make-enter-instruction ll))
	   (values (cleavir-ir:make-values-location))
	   (return (cleavir-ir:make-return-instruction (list values)))
	   (body-context (context values (list return) enter))
	   (body (compile-ast (cleavir-ast:body-ast ast) body-context)))
      ;; Now we must set the successors of the ENTER-INSTRUCTION to a
      ;; list of the result of compiling the AST.
      (reinitialize-instance enter :successors (list body))
      ;; Make sure the list of predecessors of each instruction is
      ;; initialized correctly.
      (cleavir-ir:set-predecessors enter)
      enter)))

;;; When the FUNCTION-AST is in fact a TOP-LEVEL-FUNCTION-AST it also
;;; contains a list of LOAD-TIME-VALUE forms to be evaluated and then
;;; supplied as arguments to the function.  We need to preserve that
;;; list of forms which we can do by producing an instance of
;;; TOP-LEVEL-ENTER-INSTRUCTION rather than of a plain
;;; ENTER-INSTRUCTION.  For that reason, we define an :AROUND method
;;; on that type of AST that turns the ENTER-INSTRUCTION into a
;;; TOP-LEVEL-ENTER-INSTRUCTION.

(defmethod compile-ast :around ((ast cleavir-ast:top-level-function-ast) context)
  (declare (ignore context))
  (let* ((enclose (call-next-method))
	 (enter (cleavir-ir:code enclose)))
    (change-class enter 'cleavir-ir:top-level-enter-instruction
		  :forms (cleavir-ast:forms ast))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile ASTs that represent low-level operations.

(defun make-temps (arguments)
  (loop for argument in arguments
	collect (make-temp)))

(defun compile-arguments (arguments temps successor invocation)
  (loop with succ = successor
	for arg in (reverse arguments)
	for temp in (reverse temps)
	do (setf succ (compile-ast arg
				   (context `(,temp)
					    `(,succ)
					    invocation)))
	finally (return succ)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a IMMEDIATE-AST.
;;;
;;; The IMMEDIATE-AST is a subclass of ONE-VALUE-AST-MIXIN, so the
;;; :AROUND method on COMPILE-AST has adapted the context so that it
;;; has a single result.

(defmethod compile-ast ((ast cleavir-ast:immediate-ast) context)
  (with-accessors ((results results)
		   (successors successors))
      context
    (cleavir-ir:make-assignment-instruction
     (cleavir-ir:make-immediate-input (cleavir-ast:value ast))
     (first results)
     (first successors))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a MULTIPLE-VALUE-CALL-AST.

(defmethod compile-ast ((ast cleavir-ast:multiple-value-call-ast) context)
  (with-accessors ((results results)
		   (successors successors)
		   (invocation invocation))
      context
    (let ((function-temp (cleavir-ir:new-temporary))
	  (form-temps (loop repeat (length (cleavir-ast:form-asts ast))
			    collect (cleavir-ir:make-values-location))))
      (let ((successor
	      (ecase (length successors)
		(1
		 (if (typep results 'cleavir-ir:values-location)
		     (make-instance 'cleavir-ir:multiple-value-call-instruction
		       :inputs (cons function-temp form-temps)
		       :outputs (list results)
		       :successors successors)
		     (let* ((values-temp (make-instance 'cleavir-ir:values-location)))
		       (make-instance 'cleavir-ir:multiple-value-call-instruction
			 :inputs (cons function-temp form-temps)
			 :outputs (list values-temp)
			 :successors
			 (list (cleavir-ir:make-multiple-to-fixed-instruction
				values-temp results (first successors)))))))
		(2
		 (let* ((temp (cleavir-ir:new-temporary))
			(values-temp (make-instance 'cleavir-ir:values-location))
			(false (cleavir-ir:make-constant-input nil)))
		   (make-instance 'cleavir-ir:multiple-value-call-instruction
		     :inputs (cons function-temp form-temps)
		     :outputs (list values-temp)
		     :successors
		     (list (cleavir-ir:make-multiple-to-fixed-instruction
			    values-temp
			    (list temp)
			    (make-instance 'cleavir-ir:eq-instruction
			      :inputs (list temp false)
			      :outputs '()
			      :successors (reverse successors))))))))))
	(loop for form-ast in (reverse (cleavir-ast:form-asts ast))
	      for form-temp in (reverse form-temps)
	      do (setf successor
		       (compile-ast
			form-ast
			(context form-temp (list successor) invocation))))
	(compile-ast
	 (cleavir-ast:function-form-ast ast)
	 (context (list function-temp) (list successor) invocation))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;; Compile an EQ-AST

(defmethod compile-ast ((ast cleavir-ast:eq-ast) context)
  (check-context-for-boolean-ast context)
  (with-accessors ((successors successors)
		   (invocation invocation))
      context
    (let ((arg1-ast (cleavir-ast:arg1-ast ast))
	  (arg2-ast (cleavir-ast:arg2-ast ast))
	  (temp1 (cleavir-ir:new-temporary))
	  (temp2 (cleavir-ir:new-temporary)))
      (compile-ast
       arg1-ast
       (context
	(list temp1)
	(list (compile-ast
	       arg2-ast
	       (context
		(list temp2)
		(list (cleavir-ir:make-eq-instruction
		       (list temp1 temp2)
		       successors))
		invocation)))
	invocation)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Compile a LOAD-TIME-VALUE-AST.
;;;
;;; The LOAD-TIME-VALUE-AST is a subclass of ONE-VALUE-AST-MIXIN, so
;;; the :AROUND method on COMPILE-AST has adapted the context so that
;;; it has a single result.

(defmethod compile-ast ((ast cleavir-ast:load-time-value-ast) context)
  (with-accessors ((results results)
		   (successors successors))
      context
    (cleavir-ir:make-assignment-instruction
     (cleavir-ir:make-load-time-value-input
      (cleavir-ast:form ast) (cleavir-ast:read-only-p ast))
     (first results)
     (first successors))))
