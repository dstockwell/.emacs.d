(menu-bar-mode 0)
(global-hl-line-mode)

(require 'linum)
(global-linum-mode)
(setq linum-format "%3d ")

(add-to-list 'load-path "~/.emacs.d/evil")
(require 'evil)
(evil-mode 1)

(set-face-attribute 'default nil
                    :foreground "#f5f5f5"
                    :background "#333333")

(set-face-attribute 'hl-line nil
                    :background "#444444")

(set-face-attribute 'font-lock-keyword-face nil
                    :foreground "#ccee00"
                    :weight 'bold)

(set-face-attribute 'header-line
		    :foreground "#007700"
		    :background "#cc0000")
		    
