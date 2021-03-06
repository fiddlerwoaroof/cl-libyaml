(in-package :cl-user)
(defpackage libyaml.macros
  (:use :cl)
  (:import-from :cffi
                :foreign-alloc
                :with-foreign-string)
  (:export :with-parser
           :with-event)
  (:documentation "Some macros to simplify managing foreign objects."))
(in-package :libyaml.macros)

(defmacro with-parser ((parser input-string) &rest body)
  "Create a parser using input-string as the YAML input, execute body, then free
the parser."
  `(let ((,parser (libyaml.parser:allocate-parser)))
     (with-foreign-string ((c-string octet-size) ,input-string)
       (libyaml.parser:initialize ,parser)
       (libyaml.parser:set-input-string ,parser
                                        c-string
                                        (1- octet-size))
       (unwind-protect
            (progn
              ,@body)
         (libyaml.parser:parser-delete ,parser)
         (cffi:foreign-free ,parser)))))

(defmacro with-event ((event) &rest body)
  "Allocate event, execute body, then free it."
  `(let ((,event (libyaml.event:allocate-event)))
     (unwind-protect
          (progn
            ,@body)
       (libyaml.event:event-delete ,event)
       (cffi:foreign-free ,event))))
