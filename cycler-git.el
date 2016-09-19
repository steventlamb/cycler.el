(require 'dash)
(require 'f)
(require 'cycler)

;; required!
(setq magit-status-buffer-name-format "*magit: %b*")

(defun cycler/path-to-magit-buffer (path)
  (--> path (f-split it) (last it) (car it) (concat "*magit: " it "")))

(defun cycler/switch-to-buffers (&rest buffers)
  (--each buffers (progn
                    (switch-to-buffer it)
                    (other-window 1))))

(defun cycler/magit-multi-status (repos)
  "Given a list of repository paths, open magit statuses for each."
  ; kill all magit buffers.
  (setq repos (-filter 'f-exists? repos))
  (-map 'kill-buffer (-filter 'cycler/is-magit-buffer? (buffer-list)))
  (-filter (lambda (buffer-name) (s-starts-with? "*magit: " buffer-name)) (-map 'buffer-name (buffer-list)))
  (-each repos 'magit-status)
  (cycler/make-windows (length repos))
  (apply 'cycler/switch-to-buffers (-map 'cycler/path-to-magit-buffer repos)))

(defun cycler/is-magit-buffer? (buffer) (s-starts-with? "*magit: " (buffer-name buffer)))

;;;###autoload
(defmacro cycler/defgit (name repos)
  "Make functions for git statusing a bunch of repos."
  (add-to-list 'cycler/def name)
  (set name (length repos))
  `(defun ,name () (interactive) (cycler/magit-multi-status ,repos)))

(provide 'cycler-git)
