(cl:in-package #:asdf-user)

(defsystem :cleavir-generate-ast
  :depends-on (:cleavir-ast
	       :cleavir-ast-transformations
	       :cleavir-primop
	       :cleavir-code-utilities
	       :cleavir-environment
<<<<<<< HEAD
	       :cleavir-compilation-policy
=======
>>>>>>> bca293ee6cf3f73b740daffd54a0c1f0d905198b
               :acclimation)
  :serial t
  :components
  ((:file "packages")
   (:file "conditions")
   (:file "condition-reporters-english")
   (:file "source-tracking")
   (:file "destructuring")
   (:file "check-special-form-syntax")
   (:file "environment-query")
   (:file "utilities")
   (:file "minimal-compilation")
   (:file "generate-ast")
   (:file "convert-form")
   (:file "convert-special")
   (:file "convert-primop")
   (:file "ast-from-file")))
