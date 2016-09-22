(menu-bar-mode 0)
(global-hl-line-mode 1)
(global-linum-mode 1)
(xterm-mouse-mode 1)
(mouse-wheel-mode 1)
(set-terminal-coding-system 'utf-8)
(setq inhibit-splash-screen 1)
(setq require-final-newline 1)
(setq truncate-lines 1)
(setq linum-format "%3d ")

(add-to-list 'load-path "~/.emacs.d/untracked")
(add-to-list 'load-path "~/.emacs.d/skeleton-complete")
(require 'skeleton-complete)

; vim > emacs

(setq evil-want-C-u-scroll t)
(add-to-list 'load-path "~/.emacs.d/evil")
(require 'evil)
(evil-mode 1)
(define-key evil-normal-state-map (kbd ":") 'undefined)
(define-key evil-normal-state-map (kbd "TAB") 'indent-for-tab-command)
(define-key evil-normal-state-map (kbd "C-g") 'evil-force-normal-state)
(define-key evil-visual-state-map (kbd "C-g") 'evil-exit-visual-state)
(define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
(define-key evil-replace-state-map (kbd "C-g") 'evil-normal-state)
(define-key evil-ex-completion-map (kbd "C-g") 'abort-recursive-edit)
(define-key evil-insert-state-map (kbd "TAB") 'skeleton-display-abbrev)

; git
(add-to-list 'load-path "~/.emacs.d/git-gutter")
(require 'git-gutter)
(setq git-gutter:modified-sign "  ~ ")
(setq git-gutter:added-sign "  + ")
(setq git-gutter:deleted-sign "  - ")

; snippets
(add-to-list 'load-path "~/.emacs.d/yasnippet")
(require 'yasnippet)
(yas-global-mode 1)

; chords
(require 'key-chord)
(key-chord-mode 1)
(key-chord-define-global "sf" 'save-buffer)
(key-chord-define-global "kl" 'switch-to-buffer)
(key-chord-define-global "oj" 'find-file)
(key-chord-define-global "df" 'find-file) ; FIXME - git

; indicate fill-column
(add-to-list 'load-path "~/.emacs.d/fill-column-indicator")
(require 'fill-column-indicator)
(setq fci-rule-character ?│)
(setq fci-rule-character-color "#444444")

(or standard-display-table (setq standard-display-table (make-display-table)))
(set-display-table-slot standard-display-table 'vertical-border (vector ?a))
(set-display-table-slot standard-display-table 'wrap (vector ?↩))
(set-display-table-slot standard-display-table 'truncation (vector ?…))

; Automatic text insertion
(setq-default indent-tabs-mode nil)

; Style
;(add-to-list 'custom-theme-load-path "~/.emacs.d/emacs-color-theme-solarized")
;(load-theme 'solarized-dark t)
(set-face-attribute 'default nil
                    :foreground "#f5f5f5"
                    :background "#333333")

(set-face-attribute 'region nil
                    :background "#005f87")

(set-face-attribute 'hl-line nil
                    :background "#444444")

(add-hook 'evil-insert-state-entry-hook 'insert-mode-colors)
(add-hook 'evil-visual-state-entry-hook 'visual-mode-colors)
(add-hook 'evil-normal-state-entry-hook 'default-mode-colors)
(add-hook 'evil-motion-state-entry-hook 'default-mode-colors)
(add-hook 'evil-replace-state-entry-hook 'default-mode-colors)
(add-hook 'evil-operator-state-entry-hook 'default-mode-colors)

(defun insert-mode-colors ()
  (set-face-attribute 'hl-line nil
                      :background "#5f5f87"))

(defun visual-mode-colors ()
  (set-face-attribute 'hl-line nil
                      :background "#333333"))

(defun default-mode-colors ()
  (set-face-attribute 'hl-line nil
                      :background "#444444"))

(set-face-attribute 'font-lock-comment-face nil
                    :foreground "#c0c0c0"
                    :slant 'italic)

(set-face-attribute 'font-lock-keyword-face nil
                    :foreground "#ccaa00"
                    :weight 'bold)

; Show whitespace
(require 'whitespace)
(setq whitespace-style '(face tabs trailing))
(set-face-background 'whitespace-trailing  "red")
(set-face-background 'whitespace-tab  "red")
(global-whitespace-mode)

; Mode-line
(add-to-list 'load-path "~/.emacs.d/emacs-powerline")
(require 'powerline)

(set-face-attribute 'mode-line nil
                    :background "#ff8700"
                    :foreground "#333333"
                    :weight 'bold)

(set-face-attribute 'mode-line-inactive nil
                    :background "#777777")


(defun fuz-completer (str predicate action)
  "hello!"
  (cond
   ((null action) "helloz")
   ((eq action t) '("hello1" "hello2" "hello3"))
   (t t)))

(define-minor-mode fuz-completer-mode "Something." nil
  " fuz" nil
  (if fuz-completer-mode
      (progn ;; turning on
        (make-variable-buffer-local 'after-change-functions)
        (setq after-change-functions (cons #'fuz-completer-after-change after-change-functions)))
    (setq after-change-functions
          (delete #'fuz-completer-after-change after-change-functions))))

(defun fuz-get-command (string)
  (concat "git ls-files | ~/a.out " string "# % sort -n % head -n 20 % cut -d ' ' -f 2"))

(defun fuz-completer-after-change (start end &optional rest)
  (save-excursion
    (let ((fuz-proc (get-process "fuz-process")))
      (if fuz-proc
          (delete-process fuz-proc)))
    (goto-line 1)
    (end-of-line)
    (setq fuz-first-result t)
    (if (<= end (point))
        (let ((process-connection-type nil))
          (let ((fuz-proc
                 (start-process-shell-command "fuz-process"
                                              (buffer-name)
                                              (fuz-get-command (thing-at-point 'line)))))
            (set-process-filter fuz-proc 'fuz-completer-stash-filter)
            (set-process-sentinel fuz-proc 'fuz-completer-sentinel))))))

(defun fuz-completer-stash-filter (proc string)
  (with-current-buffer (process-buffer proc)
    (save-excursion
      (if fuz-first-result
          (progn
            (setq fuz-first-result nil)
            (goto-line 1)
            (end-of-line)
            (delete-region (point) (point-max))
            (newline)
            ))
      (end-of-buffer)
      (insert string))))

(defun fuz-completer-sentinel (proc event)
  (with-current-buffer (process-buffer proc)
    (save-excursion
      (if (and fuz-first-result (string= "finished\n" event))
          (progn
            (setq fuz-first-result nil)
            (goto-line 1)
            (end-of-line)
            (delete-region (point) (point-max))
            (newline))))))










; ┠ ┡ ┢ ┣ ┤ ┥ ┦ ┧ ┨ ┩ ┪ ┫ ┬ ┭ ┮ ┯
; ┰ ┱ ┲ ┳ ┴ ┵ ┶ ┷ ┸ ┹ ┺ ┻ ┼ ┽ ┾ ┿
; ╀ ╁ ╂ ╃ ╄ ╅ ╆ ╇ ╈ ╉ ╊ ╋ ╌ ╍ ╎ ╏
; ═ ║ ╒ ╓ ╔ ╕ ╖ ╗ ╘ ╙ ╚ ╛ ╜ ╝ ╞ ╟
; ╠ ╡ ╢ ╣ ╤ ╥ ╦ ╧ ╨ ╩ ╪ ╫ ╬ ╭ ╮ ╯
; ╰ ╱ ╲ ╳ ╴ ╵ ╶ ╷ ╸ ╹ ╺ ╻ ╼ ╽ ╾ ╿
; ▀ ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▉ ▊ ▋ ▌ ▍ ▎ ▏
; ▐ ░ ▒ ▓ ▔ ▕ ▖ ▗ ▘ ▙ ▚ ▛ ▜ ▝ ▞ ▟
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes (quote ("5a0848741ac701447829d4ca13ada2527999534471bb5e7ddc5b0153c90d0e6a" "1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" "fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6" default)))
 '(ido-enable-flex-matching t)
 '(ido-everywhere t)
 '(ido-mode (quote both) nil (ido)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
