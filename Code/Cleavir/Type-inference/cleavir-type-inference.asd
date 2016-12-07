(cl:in-package #:asdf-user)

(defsystem cleavir-type-inference
  :depends-on (:cleavir-hir
	       :cleavir-liveness)
  :serial t
  :components
  ((:file "packages")
   (:file "dictionary")
   (:file "type-descriptor")
   (:file "sanity-checks")
   (:file "filter")
   (:file "bag-equal")
   (:file "bag-join")
   (:file "update")
   (:file "transfer")
   (:file "type-inference")))
