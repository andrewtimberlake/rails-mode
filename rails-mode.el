;;; rails-mode.el

;; Copyright (C) 2012 Andrew Timberlake <http://andrewtimberlake.com>
;; Authors: Andrew Timberlake
;; URL: http://github.com/andrewtimberlake/rails-mode
;; Created: 2012
;; Version: 0.1
;; Keywords: rails ruby
;; Package-Requires: ((ruby-mode "1.1")
;;                    (ido "")))

;;; Commentary:
;;
;; This file is NOT part of GNU Emacs.
;;
;; Just getting started, let's see where this gets us :-)
;;
;; Leaned heavily on rspec-mode code to get started.

;;; Documentation
;;
;; This minor mode should make Rails development easier

;;; Code:
(require 'ruby-mode)

(defconst rails-mode-keymap (make-sparse-keymap) "Keymap used in rails mode")

(define-key rails-mode-keymap (kbd "C-c om") 'rails-find-model)
(define-key rails-mode-keymap (kbd "C-c oc") 'rails-find-controller)
(define-key rails-mode-keymap (kbd "C-c ov") 'rails-find-view)
(define-key rails-mode-keymap (kbd "C-c oj") 'rails-find-javascript)
(define-key rails-mode-keymap (kbd "C-c os") 'rails-find-stylesheet)
(define-key rails-mode-keymap (kbd "C-c or") 'rails-visit-routes)
(define-key rails-mode-keymap (kbd "C-c og") 'rails-visit-gemfile)

(defgroup rails-mode nil
  "Rails minor mode.")

(define-minor-mode rails-mode
  "Minor mode for Rails development"
  :lighter " Rails"
  :keymap rails-mode-keymap)


;; Helpers
(defun rails-parent-directory (a-directory)
  "Returns the parent directory of a-directory"
  (file-name-directory (directory-file-name a-directory)))

(defun rails-root-directory-p (a-directory)
  "Returns t if a-directory is the root"
  (equal a-directory (rails-parent-directory a-directory)))

(defun rails-directory (a-file)
  "Finds the root directory of the Rails project for a-file"
  (if (file-directory-p a-file)
      (or
       (if (first (directory-files a-file t "^app$"))
           a-file
         (rails-directory (rails-parent-directory a-file)))
       (if (rails-root-directory-p a-file)
           nil
         (rails-directory (rails-parent-directory a-file))))
    (rails-directory (rails-parent-directory a-file))))

(defun rails-model-directory-p (a-directory)
  "Returns t if a-directory is the app/models directory"
  (if (equal "models" (file-name-nondirectory (directory-file-name a-directory)))
      t
    nil))

(defun rails-model-file-p (a-file)
  "Returns t if a-file is a model"
  (if
      (and
       (file-regular-p a-file)
       (rails-model-directory-p (rails-parent-directory a-file)))
      t
    nil))

(defun rails-controller-directory-p (a-directory)
  "Returns t if a-directory is the app/controllers directory"
  (if (equal "controllers" (file-name-nondirectory (directory-file-name a-directory)))
      t
    nil))

(defun rails-controller-file-p (a-file)
  "Returns t if a-file is a controller"
  (if
      (and
       (file-regular-p a-file)
       (rails-controller-directory-p (rails-parent-directory a-file)))
      t
    nil))

;; Finders
(defun rails-find-model ()
  "Starts looking for a model in the app/models directory"
  (interactive)
  (let ((model-directory (concat (rails-directory(buffer-file-name)) "app/models/")))
    (if (rails-controller-file-p (buffer-file-name))
        (find-file (concat model-directory (replace-regexp-in-string "\\(s_controller.rb\\)$" ".rb" (file-name-nondirectory (buffer-file-name)))))
      (ido-find-file-in-dir model-directory))))

(defun rails-find-controller ()
  "Starts looking for a model in the app/controllers directory"
  (interactive)
  (let ((controller-directory (concat (rails-directory(buffer-file-name)) "app/controllers/")))
    (if (rails-model-file-p (buffer-file-name))
        (find-file (concat controller-directory (replace-regexp-in-string "\\(.rb\\)$" "s_controller.rb" (file-name-nondirectory (buffer-file-name)))))
      (ido-find-file-in-dir controller-directory))))

(defun rails-find-view ()
  "Starts looking for a model in the app/views directory"
  (interactive)
  (let ((views-directory (concat (rails-directory(buffer-file-name)) "app/views/")))
    (if (rails-controller-file-p (buffer-file-name))
        (ido-find-file-in-dir (concat views-directory (replace-regexp-in-string "\\(_controller.rb\\)$" "/" (file-name-nondirectory (buffer-file-name)))))
      (ido-find-file-in-dir views-directory))))

(defun rails-find-javascript ()
  "Starts looking for a model in the app/assets/javascript directory"
  (interactive)
  (ido-find-file-in-dir (concat (rails-directory(buffer-file-name)) "app/assets/javascripts/")))

(defun rails-find-stylesheet ()
  "Starts looking for a model in the app/assets/stylesheet directory"
  (interactive)
  (ido-find-file-in-dir (concat (rails-directory(buffer-file-name)) "app/assets/stylesheets/")))

(defun rails-visit-routes ()
  "Visits the routes file"
  (interactive)
  (find-file (concat (rails-directory(buffer-file-name)) "config/routes.rb")))

(defun rails-visit-gemfile ()
  "Visits the Gemfile file"
  (interactive)
  (find-file (concat (rails-directory(buffer-file-name)) "Gemfile")))

;; Add rails-mode to ruby files that are part of a Rails project
(eval-after-load 'ruby-mode
  '(add-hook 'ruby-mode-hook
             (lambda ()
               (when (rails-directory(buffer-file-name))
                 (rails-mode)))))

;; Add rails-mode to coffeescript files that are part of a Rails project
(eval-after-load 'coffee-mode
  '(add-hook 'coffee-mode-hook
             (lambda ()
               (when (rails-directory(buffer-file-name))
                 (rails-mode)))))

;; Add rails-mode to haml files that are part of a Rails project
(eval-after-load 'haml-mode
  '(add-hook 'haml-mode-hook
             (lambda ()
               (when (rails-directory(buffer-file-name))
                 (rails-mode)))))

(provide 'rails-mode)
;;; rails-mode.el ends here
