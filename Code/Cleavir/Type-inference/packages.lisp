(cl:in-package #:common-lisp-user)

(defpackage #:cleavir-type-inference
  (:use #:common-lisp)
  (:export #:approximate-type #:canonicalize-type
	   #:top-p #:bottom-p
	   #:binary-join #:binary-meet #:difference
	   #:join #:meet)
  (:export #:infer-types #:arc-bag
<<<<<<< HEAD
	   #:instruction-input #:find-type)
  (:export #:type-missing
	   #:type-missing-location #:type-missing-bag))
=======
	   #:instruction-input #:find-type
           #:delete-the
           #:prune-typeqs))
>>>>>>> bca293ee6cf3f73b740daffd54a0c1f0d905198b
