(cl:in-package #:cleavir-ir)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Macro DEFINE-ARRAY-INSTRUCTIONS.
;;;
;;; This macro defines four instructions and their associated
;;; constructors: one instruction for reading an element of a simple
;;; array, one instruction for writing an element of a simple array,
;;; one instruction for reading an element of a non-simple array, one
;;; instruction for writing an element of a non-simple array,
(defmacro define-array-instructions
    (simple-aref-instruction
     simple-aref-constructor
     simple-aset-instruction
     simple-aset-constructor
     non-simple-aref-instruction
     non-simple-aref-constructor
     non-simple-aset-instruction
     non-simple-aset-constructor)
  `(progn
     (defclass ,simple-aref-instruction
	 (instruction one-successor-mixin)
       ())

     (defun ,simple-aref-constructor (input1 input2 output successor)
       (make-instance ',simple-aref-instruction
	 :inputs (list input1 input2)
	 :outputs (list output)
	 :successors (list successor)))

     (defclass ,simple-aset-instruction
	 (instruction one-successor-mixin side-effect-mixin)
       ())

     (defun ,simple-aset-constructor (input1 input2 input3 successor)
       (make-instance ',simple-aset-instruction
	 :inputs (list input1 input2 input3)
	 :outputs ()
	 :successors (list successor)))

     (defclass ,non-simple-aref-instruction
	 (instruction one-successor-mixin)
       ())

     (defun ,non-simple-aref-constructor (input1 input2 output successor)
       (make-instance ',non-simple-aref-instruction
	 :inputs (list input1 input2)
	 :outputs (list output)
	 :successors (list successor)))

     (defclass ,non-simple-aset-instruction
	 (instruction one-successor-mixin side-effect-mixin)
       ())

     (defun ,non-simple-aset-constructor (input1 input2 input3 successor)
       (make-instance ',non-simple-aset-instruction
	 :inputs (list input1 input2 input3)
	 :outputs ()
	 :successors (list successor)))))

(define-array-instructions
  simple-t-aref-instruction
  make-simple-t-aref-instruction
  simple-t-aset-instruction
  make-simple-t-aset-instruction
  non-simple-t-aref-instruction
  make-non-simple-t-aref-instruction
  non-simple-t-aset-instruction
  make-non-simple-t-aset-instruction)

(define-array-instructions
  simple-bit-aref-instruction
  make-simple-bit-aref-instruction
  simple-bit-aset-instruction
  make-simple-bit-aset-instruction
  non-simple-bit-aref-instruction
  make-non-simple-bit-aref-instruction
  non-simple-bit-aset-instruction
  make-non-simple-bit-aset-instruction)

(define-array-instructions
  simple-short-float-aref-instruction
  make-simple-short-float-aref-instruction
  simple-short-float-aset-instruction
  make-simple-short-float-aset-instruction
  non-simple-short-float-aref-instruction
  make-non-simple-short-float-aref-instruction
  non-simple-short-float-aset-instruction
  make-non-simple-short-float-aset-instruction)

(define-array-instructions
  simple-single-float-aref-instruction
  make-simple-single-float-aref-instruction
  simple-single-float-aset-instruction
  make-simple-single-float-aset-instruction
  non-simple-single-float-aref-instruction
  make-non-simple-single-float-aref-instruction
  non-simple-single-float-aset-instruction
  make-non-simple-single-float-aset-instruction)

(define-array-instructions
  simple-double-float-aref-instruction
  make-simple-double-float-aref-instruction
  simple-double-float-aset-instruction
  make-simple-double-float-aset-instruction
  non-simple-double-float-aref-instruction
  make-non-simple-double-float-aref-instruction
  non-simple-double-float-aset-instruction
  make-non-simple-double-float-aset-instruction)

(define-array-instructions
  simple-long-float-aref-instruction
  make-simple-long-float-aref-instruction
  simple-long-float-aset-instruction
  make-simple-long-float-aset-instruction
  non-simple-long-float-aref-instruction
  make-non-simple-long-float-aref-instruction
  non-simple-long-float-aset-instruction
  make-non-simple-long-float-aset-instruction)

(define-array-instructions
  simple-unsigned-byte-8-aref-instruction
  make-simple-unsigned-byte-8-aref-instruction
  simple-unsigned-byte-8-aset-instruction
  make-simple-unsigned-byte-8-aset-instruction
  non-simple-unsigned-byte-8-aref-instruction
  make-non-simple-unsigned-byte-8-aref-instruction
  non-simple-unsigned-byte-8-aset-instruction
  make-non-simple-unsigned-byte-8-aset-instruction)
