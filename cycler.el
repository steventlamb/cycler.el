(require 'dash-functional)

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

(defun cycler/switch-to-buffers (&rest buffers)
  (--each buffers (progn
                    (switch-to-buffer it)
                    (other-window 1))))

(defvar cycler/def nil)
(defvar cycler/def-included nil)

;;;###autoload
(defmacro cycler/def (name body)
  "Make functions for git statusing a bunch of repos."
  (add-to-list 'cycler/def name)
  ;; todo: generalize
  (set name 1)
  `(defun ,name () (interactive) ,body))


(defvar cycler/cycle 0)
(put 'cycler/cycle 'risky-local-variable t)

(defun cycler/cycle-get-fn ()
  (let* ((len (length cycler/def))
         (n (mod cycler/cycle len)))
    (nth n cycler/def)))

(defun cycler/cycle ()
  "Cycle through registered def status buffer sets, or 'projects'"
  ;; todo: if not on magit buffer, go to most recent
  (interactive)
  (let* ((fn (cycler/cycle-get-fn))
         (flength (eval fn))
         (wlength (length (window-list))))
    ;; this particular line gets close to enhancing cycle to
    ;; only cycle when on a magit, otherwise backcycle.
    ;; (when t (or (equal wlength flength) (equal wlength 1))
    (when t
      (setq cycler/cycle (+ 1 cycler/cycle))
      (setq fn (cycler/cycle-get-fn)))
    (when cycler/def-included
      (if (not (-contains? cycler/def-included fn))
          (progn (cycler/cycle))
        (funcall fn))
      )))

(provide 'cycler)
