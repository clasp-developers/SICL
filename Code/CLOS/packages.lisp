(cl:in-package #:common-lisp-user)

;;; FIXME: The list of exported symbols is not complete.

(defpackage #:sicl-clos
  (:use #:common-lisp)
  (:import-from #:cleavir-code-utilities
		#:parse-ordinary-lambda-list
		#:parse-specialized-lambda-list)
  (:import-from #:sicl-additional-conditions #:no-such-class-name)
  (:shadow #:documentation)
  (:export
   ;; MOP classes
   #:class #:standard-class #:built-in-class #:structure-class
   #:funcallable-standard-class
   #:standard-object #:function #:funcallable-standard-object
   #:generic-function #:standard-generic-function
   #:method #:standard-method
   #:metaobject
   #:specializer
   #:method-combination
   #:slot-definition
   #:direct-slot-definition
   #:effective-slot-definition
   #:standard--slot-definition
   #:standard-direct-slot-definition
   #:standard-effective-slot-definition
   #:standard-reader-method
   #:standard-writer-method
   ;; Accessors for method metaobjects.
   #:method-function
   #:method-generic-function
   #:method-lambda-list
   #:method-qualifiers
   #:method-specializers
   #:accessor-method-slot-definition
   ;; Accessors for class metaobjects. 
   #:class-name
   #:class-direct-superclasses
   #:class-direct-slots
   #:class-direct-default-initargs
   #:class-precedence-list
   #:class-slots
   #:class-default-initargs
   #:class-finalized-p
   #:class-prototype
   #:instance-size
   ;; Accessors for generic function metaobjects.
   #:generic-function-name
   #:generic-function-argument-precedence-order
   #:generic-function-lambda-list
   #:generic-function-declarations
   #:generic-function-method-class
   #:generic-function-method-combination
   #:generic-function-methods
   ;; Accessors for slot definition metaobjects.
   #:slot-definition-name
   #:slot-definition-allocation
   #:slot-definition-type
   #:slot-definition-initargs
   #:slot-definition-initform
   #:slot-definition-initfunction
   #:slot-definition-readers
   #:slot-definition-writers
   #:slot-definition-location
   ;; Macros
   #:defclass #:defgeneric #:defmethod
   ;; Generic functions.
   #:compute-effective-slot-definition
   #:class-of
   #:allocate-instance
   #:make-instance
   #:initialize-instance
   #:reinitialize-instance
   #:shared-initialize
   #:make-instances-obsolete
   #:update-instance-for-different-class
   #:update-instance-for-redefined-class
   #:make-method #:add-method #:call-method #:find-method
   #:method-qualifiers #:compute-applicable-methods #:next-method-p
   #:compute-applicable-methods-using-classes
   #:invalid-method-error
   #:no-applicable-method #:no-next-method #:remove-method #:defmethod
   #:method-combination #:define-method-combination #:method-combination-error
   #:make-instance
   #:ensure-generic-function #:ensure-generic-function-using-class
   #:ensure-class #:ensure-class-using-class
   #:slot-value #:slot-missing #:slot-boundp #:slot-makunbound
   #:print-object #:describe-object #:documentation
   #:make-method-lambda
   #:direct-slot-definition-class
   #:effective-slot-definition-class
   #:reader-method-class #:writer-method-class
   #:validate-superclass
   #:finalize-inheritance
   ;; Other functions
   #:set-funcallable-instance-function
   #:shared-initialize-around-real-class-default
   ;; SICL-specific classes
   #:real-class #:regular-class
   ;; SICL-specific functions
   #:ensure-method
   #:default-superclasses
   #:allocate-general-instance
   #:general-instance-p
   #:general-instance-access
   ;; SICL-specific macro
   #:subclassp))
