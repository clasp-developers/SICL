(cl:in-package #:asdf-user)

(defsystem :sicl-sequence-small-support
  :serial t
  :components
  ((:file "Common/packages")
   (:file "Common/conditions")
   (:file "Common/condition-reporters-en")
   (:file "Common/docstrings-en")
   (:file "Common/utilities")
   (:file "Small/utilities")
   (:file "Small/find")
   (:file "Small/position")
   (:file "Small/count")))
