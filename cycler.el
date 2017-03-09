(require 'dash-functional)

;; internal vars - used for tracking state
(defvar cycler/cycle 0)
(defvar cycler/def nil)
(defvar cycler/def-included nil)
(put 'cycler/cycle 'risky-local-variable t)
(put 'cycler/def 'risky-local-variable t)
(put 'cycler/def-included 'risky-local-variable t)

(defun cycler/make-windows (n)
  (delete-other-windows)
  (when (> n 1) (split-window-below))
  (when (> n 2) (split-window-right))
  (when (> n 3)
    (other-window 2)
    (split-window-right)
    (other-window 2))
  (when (> n 4)
    (other-window 2)
    (enlarge-window-horizontally 20)
    (split-window-right)
    (other-window 3))
  (when (> n 5)
    (enlarge-window-horizontally 20)
    (split-window-right)
    (other-window 3))
  (when (> n 6)
    (error "not supported")))

;;;###autoload
(defmacro cycler/def (name body)
  (add-to-list 'cycler/def name)
  ;; todo: generalize
  (set name 1)
  `(defun ,name () (interactive) ,body))

(defun cycler/cycle ()
  "Cycle through registered def status buffer sets, or 'projects'"
  (interactive)
  (when (eq last-command 'cycler/cycle)
    (setq cycler/cycle (+ 1 cycler/cycle)))
  (let* ((len (length cycler/def-included))
         (n (mod cycler/cycle len))
         (git-definition (nth n cycler/def-included)))
    (if (symbolp git-definition) (funcall git-definition) (eval git-definition))))

(provide 'cycler)
