(cl:in-package #:cleavir-ir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instructions for Common Lisp operators.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction ENTER-INSTRUCTION.
;;;
;;; This instruction encapsulates all the implementation-specific
;;; machinery involved in verifying the argument count and parsing the
;;; arguments.  It has a single successor.

(defclass enter-instruction (instruction one-successor-mixin)
  ((%lambda-list :initarg :lambda-list :accessor lambda-list)))

(defun make-enter-instruction
    (lambda-list &optional (successor nil successor-p))
  (let* ((outputs (loop for item in lambda-list
			append (cond ((member item lambda-list-keywords) '())
				     ((consp item)
				      (if (= (length item) 3)
					  (cdr item)
					  item))
				     (t (list item))))))
    (make-instance 'enter-instruction
      :lambda-list lambda-list
      ;; We add an additional output that will hold the static
      ;; environment.
      :outputs (cons (new-temporary) outputs)
      :successors (if successor-p (list successor) '()))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction TOP-LEVEL-ENTER-INSTRUCTION.
;;;
;;; This is a subclass of ENTER-INSTRUCTION used as the initial
;;; instruction of a flowchart that represents a LOAD FUNCTION.
;;;
;;; An initial form F to be evaluated is turned into a load function
;;; LF.  When LF is called with the values of the LOAD-TIME-VALUE
;;; forms (including non-immediate constants) of F, then the result is
;;; the values and the effects of evaluating F.
;;;
;;; The TOP-LEVEL-ENTER-INSTRUCTION supplies a slot containing the
;;; list of the LOAD-TIME-VALUE forms to be evaluated before being
;;; supplied as arguments.

(defclass top-level-enter-instruction (enter-instruction)
  ((%forms :initarg :forms :accessor forms)))

(defun make-top-level-enter-instruction (lambda-list forms)
  (let ((enter (make-enter-instruction lambda-list)))
    (change-class enter 'top-level-enter-instruction
		  :forms forms)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction NOP-INSTRUCTION.

(defclass nop-instruction (instruction one-successor-mixin)
  ())

(defun make-nop-instruction (successors)
  (make-instance 'nop-instruction
    :successors successors))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction ASSIGNMENT-INSTRUCTION.

(defclass assignment-instruction (instruction one-successor-mixin)
  ())

(defun make-assignment-instruction
    (input output &optional (successor nil successor-p))
  (make-instance 'assignment-instruction
    :inputs (list input)
    :outputs (list output)
    :successors (if successor-p (list successor) '())))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction FUNCALL-INSTRUCTION.

(defclass funcall-instruction
    (instruction one-successor-mixin side-effect-mixin)
  ())

(defun make-funcall-instruction
    (inputs outputs &optional (successor nil successor-p))
  (make-instance 'funcall-instruction
    :inputs inputs
    :outputs outputs
    :successors (if successor-p (list successor) '())))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction FUNCALL-NO-RETURN-INSTRUCTION.
;;;
;;; This is for calls that are known to never return normally,
;;; e.g. calls to ERROR. Having no successor simplifies analysis
;;; by making whatever leads here irrelevant to other code.
;;;
;;; It's a separate class because funcall having one-successor-mixin
;;; is pretty convenient.

(defclass funcall-no-return-instruction
    (instruction no-successors-mixin side-effect-mixin)
  ())

(defun make-funcall-no-return-instruction (inputs)
  (make-instance 'funcall-no-return-instruction
    :inputs inputs))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction TAILCALL-INSTRUCTION.

(defclass tailcall-instruction (instruction no-successors-mixin)
  ())

(defun make-tailcall-instruction (inputs)
  (make-instance 'tailcall-instruction
    :inputs inputs))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction RETURN-INSTRUCTION.

(defclass return-instruction
    (instruction no-successors-mixin side-effect-mixin)
  ())

(defun make-return-instruction (inputs)
  (make-instance 'return-instruction
    :inputs inputs))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction ENCLOSE-INSTRUCTION.

(defclass enclose-instruction (instruction one-successor-mixin)
  ((%code :initarg :code :accessor code)))  

(defun make-enclose-instruction (output successor code)
  (make-instance 'enclose-instruction
    :outputs (list output)
    :successors (list successor)
    :code code))

(defmethod clone-instruction :around ((instruction enclose-instruction))
  (let ((new (call-next-method)))
    (setf (code new) (code instruction))
    new))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction TYPEQ-INSTRUCTION.
;;;
;;; This instruction takes one input, namely a datum for which a type
;;; should be tested.  
;;;
;;; As a result of various transformations of the instruction graph,
;;; this instruction will either be eliminated (because we can
;;; determine statically the result of the test), or it will be
;;; replaced by a call to TYPEP.  When it is replaced by a call to
;;; TYPEP, we use the constant input as the second argument to TYPEP.

(defclass typeq-instruction (instruction two-successors-mixin)
  ((%value-type :initarg :value-type :reader value-type)))

(defun make-typeq-instruction (input successors value-type)
  (make-instance 'typeq-instruction
    :inputs (list input)
    :successors successors
    :value-type value-type))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction THE-INSTRUCTION.
;;;
;;; This instruction is similar to the TYPEQ-INSTRUCTION.  It is
;;; different in that it has only a single successor and no error
;;; branch.  Operationally, it has no effect.  But it informs the type
;;; inference machinery that the input is of a particular type. 

(defclass the-instruction (instruction one-successor-mixin)
  ((%value-type :initarg :value-type :reader value-type)))

(defun make-the-instruction (input successor value-type)
  (make-instance 'the-instruction
    :inputs (list input)
    :outputs '()
    :successors (list successor)
    :value-type value-type))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction THE-VALUES-INSTRUCTION.
;;;
;;; This is like THE-INSTRUCTION, but takes a VALUES-LOCATION
;;; as input instead of a lexical one, and correspondingly, a
;;; (decomposed) values type instead of a single-value type.
;;; A separate instruction is useful because values locations can
;;; have an unknown or varying number of values.

(defclass the-values-instruction (instruction one-successor-mixin)
  ((%required-types :initarg :required :reader required-types)
   (%optional-types :initarg :optional :reader optional-types)
   (%rest-type :initarg :rest :reader rest-type)))

(defun make-the-values-instruction (input successor
				    required optional rest)
  (make-instance 'the-values-instruction
    :inputs (list input)
    :outputs '()
    :successors (list successor)
    :required required
    :optional optional
    :rest rest))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction CATCH-INSTRUCTION.
;;;
;;; This instruction is used to mark the stack to be an exit point.
;;; It takes a single input and it has a single successor.  It has no
;;; outputs.  The effect of the instruction is to push an entry onto
;;; the dynamic environment that contains the value of the input to
;;; the instruction and the current stack.
;;;
;;; To implement the Common Lisp CATCH special operator, the entire
;;; CATCH form would be placed in a thunk that can not be inlined
;;; (because the return address must be explicit).  Inside that thunk,
;;; the CATCH-INSTRUCTION would be used to mark capture the stack at
;;; that point.  The THROW special operator would search the dynamic
;;; environment for the frame, and use the return address stored in it. 
;;;
;;; The CATCH-INSTRUCTION can also be used to implement lexical
;;; non-local control transfers such as RETURN-FROM and GO.  It would
;;; be used when the successor of an instruction I at some lexical
;;; depth is an instruction J at a lesser lexical depth.  The
;;; procedure at the lesser lexical depth would contain a lexical
;;; location L into which some unique object (say the result of (LIST
;;; NIL)) is placed.  This instruction would then be used with L as an
;;; input.  An UNIWIND-INSTRUCTION would be inserted into the arc from
;;; I to J.  That instruction would use L as an input.  The effect
;;; would be that before J is reached, the stack would be unwound to
;;; the state it had when the CATCH-INSTRUCTION was executed. 

(defclass catch-instruction (instruction one-successor-mixin)
  ())

(defun make-catch-instruction (input &optional (successor nil successor-p))
  (make-instance 'catch-instruction
    :inputs (list input)
    :successors (if successor-p (list successor) '())))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction UNWIND-INSTRUCTION.
;;;
;;; This instruction is used to indicate a lexical non-local transfer
;;; of control resulting form a GO or a RETURN-FROM form.

(defclass unwind-instruction
    (instruction one-successor-mixin side-effect-mixin)
  (;; The invocation of the UNWIND-INSTRUCTION is the
   ;; ENTER-INSTRUCTION that represents the function invocation at
   ;; which execution should continue after the stack has been
   ;; unwound.
   (%invocation :initarg :invocation :reader invocation)))

(defun make-unwind-instruction (successor invocation)
  (make-instance 'unwind-instruction
    :inputs '()
    :outputs '()
    :successors (list successor)
    :invocation invocation))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction EQ-INSTRUCTION.

(defclass eq-instruction (instruction two-successors-mixin)
  ())

(defun make-eq-instruction (inputs successors)
  (make-instance 'eq-instruction
    :inputs inputs
    :successors successors))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction CONSP-INSTRUCTION.
;;;
;;; This instruction is used to test whether its input is a CONS cell.
;;; If that is the case, then the first output is chosen.  Otherwise,
;;; the second output is chosen.

(defclass consp-instruction (instruction two-successors-mixin)
  ())

(defun make-consp-instruction (input successors)
  (make-instance 'consp-instruction
    :inputs (list input)
    :successors successors))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction FIXNUMP-INSTRUCTION.
;;;
;;; This instruction is used to test whether its input is a FIXNUM.
;;; If that is the case, then the first output is chosen.  Otherwise,
;;; the second output is chosen.

(defclass fixnump-instruction (instruction two-successors-mixin)
  ())

(defun make-fixnump-instruction (input successors)
  (make-instance 'fixnump-instruction
    :inputs (list input)
    :successors successors))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction SYMBOL-VALUE-INSTRUCTION.

(defclass symbol-value-instruction (instruction one-successor-mixin)
  ())

(defun make-symbol-value-instruction (input output successor)
  (make-instance 'symbol-value-instruction
    :inputs (list input)
    :outputs (list output)
    :successors (list successor)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction SET-SYMBOL-VALUE-INSTRUCTION.

(defclass set-symbol-value-instruction
    (instruction one-successor-mixin side-effect-mixin)
  ())

(defun make-set-symbol-value-instruction (symbol-input value-input successor)
  (make-instance 'set-symbol-value-instruction
    :inputs (list symbol-input value-input)
    :outputs '()
    :successors (list successor)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction FDEFINITION-INSTRUCTION.

(defclass fdefinition-instruction (instruction one-successor-mixin)
  ())

(defun make-fdefinition-instruction
    (input output &optional (successor nil successor-p))
  (make-instance 'fdefinition-instruction
    :inputs (list input)
    :outputs (list output)
    :successors (if successor-p (list successor) '())))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction PHI-INSTRUCTION.
;;; 
;;; This is an instruction used in SSA form.  It has at least two
;;; inputs, a single output and a single successor.
;;;
;;; Let A be some PHI-INSTRUCTION with N inputs.  A can have one or
;;; more predecessors.  If A has a single predecessor B, then B is
;;; also a PHI-INSTRUCTION with N inputs.  If A has more than one
;;; predecessor, then it has N predecessors.

(defclass phi-instruction (instruction one-successor-mixin)
  ())

(defun make-phi-instruction (inputs output successor)
  (make-instance 'phi-instruction
    :inputs inputs
    :outputs (list output)
    :successors (list successor)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Instruction USE-INSTRUCTION.
;;;
;;; This instruction is similar to the NOP-INSTRUCTION in that it does
;;; nothing.  The difference is that this instruction takes a single
;;; input, is a lexical variable.  The purpose is to create an
;;; artificial use for the input so that it will be kept alive until
;;; after this instruction is encountered.  An instance of this
;;; instruction class will typically be emitted when the DEBUG quality
;;; has a high value and a SCOPE-AST is encountered.

(defclass use-instruction (instruction one-successor-mixin)
  ())

(defun make-use-instruction (input successor)
  (make-instance 'use-instruction
    :inputs (list input)
    :outputs '()
    :successors (list successor)))
