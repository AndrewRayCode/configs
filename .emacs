;(add-to-list 'load-path "~/.emacs.d/evil")
;(require 'evil)
;(evil-mode 1)

(require 'package)
(add-to-list 'package-archives 
    '("marmalade" .
      "http://marmalade-repo.org/packages/"))
(package-initialize)

(add-to-list 'load-path "/path/to/color-theme.el/file")
(require 'color-theme)
;(eval-after-load "color-theme"
;  '(progn
;     (color-theme-vividchalk)))
