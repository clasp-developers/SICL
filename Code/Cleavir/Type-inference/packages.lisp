(cl:in-package #:common-lisp-user)

(defpackage #:cleavir-type-inference
  (:use #:common-lisp)
  (:export #:approximate-type #:canonicalize-type
	   #:top-p #:bottom-p
	   #:binary-join #:binary-meet #:difference
	   #:join #:meet)
  (:export #:infer-types #:arc-bag
	   #:instruction-input #:find-type
           #:delete-the
           #:prune-typeqs)
  (:export #:type-missing
	   #:type-missing-location #:type-missing-bag))
