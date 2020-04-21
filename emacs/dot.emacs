;; my initialization configurations

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(load "~/.emacs.d/my-config.el")
;==================================
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#27212E" "#964C7B" "#74DFC4" "#FFE261" "#40B4C4" "#EB64B9" "#B4DCE7" "#FFFFFF"])
 '(custom-enabled-themes (quote (doom-laserwave)))
 '(custom-safe-themes
   (quote
    ("3788e589eb432e6a515d557cbeb8dc4eaca9e00ae54f932b4bd43ed78605532e" "be9645aaa8c11f76a10bcf36aaf83f54f4587ced1b9b679b55639c87404e2499" "72fda75af7caddec17ba9b49d2f99703c20a5f5f5c4dcec641d34a0b83569e88" "fa3bdd59ea708164e7821574822ab82a3c51e262d419df941f26d64d015c90ee" "99ea831ca79a916f1bd789de366b639d09811501e8c092c85b2cb7d697777f93" "1c8171893a9a0ce55cb7706766e57707787962e43330d7b0b6b0754ed5283cda" "e1ecb0536abec692b5a5e845067d75273fe36f24d01210bf0aa5842f2a7e029f" "001e4dbbdb8d01bb299c0244c489504d51ef5939ace24049079b377294786f7c" "1ed5c8b7478d505a358f578c00b58b430dde379b856fbcb60ed8d345fc95594e" "6231254e74298a1cf8a5fee7ca64352943de4b495e615c449e9bb27e2ccae709" "bc836bf29eab22d7e5b4c142d201bcce351806b7c1f94955ccafab8ce5b20208" "c83c095dd01cde64b631fb0fe5980587deec3834dc55144a6e78ff91ebc80b19" "d5d2ab76985738c142adbe6a35dc51c8d15baf612fdf6745c901856457650314" "3d5ef3d7ed58c9ad321f05360ad8a6b24585b9c49abcee67bdcbb0fe583a6950" "96998f6f11ef9f551b427b8853d947a7857ea5a578c75aa9c4e7c73fe04d10b4" "3cd28471e80be3bd2657ca3f03fbb2884ab669662271794360866ab60b6cb6e6" "3cc2385c39257fed66238921602d8104d8fd6266ad88a006d0a4325336f5ee02" "72a81c54c97b9e5efcc3ea214382615649ebb539cb4f2fe3a46cd12af72c7607" "58c6711a3b568437bab07a30385d34aacf64156cc5137ea20e799984f4227265" "1436d643b98844555d56c59c74004eb158dc85fc55d2e7205f8d9b8c860e177f" "e0d42a58c84161a0744ceab595370cbe290949968ab62273aed6212df0ea94b4" "c48551a5fb7b9fc019bf3f61ebf14cf7c9cdca79bcb2a4219195371c02268f11" "b3775ba758e7d31f3bb849e7c9e48ff60929a792961a2d536edec8f68c671ca5" "987b709680284a5858d5fe7e4e428463a20dfabe0a6f2a6146b3b8c7c529f08b" "7b37f10643dd2fb61b5e1d8c368ca92b022c62ae404e9d0963921518f1108cba" "8e797edd9fa9afec181efbfeeebf96aeafbd11b69c4c85fa229bb5b9f7f7e66c" "9583f0b6511c5774e5ebfe32662105b4d7157f51473f64e5e1d8be3fc8565f01" "a22f40b63f9bc0a69ebc8ba4fbc6b452a4e3f84b80590ba0a92b4ff599e53ad0" default)))
 '(fci-rule-color "#544863")
 '(jdee-db-active-breakpoint-face-colors (cons "#222228" "#40B4C4"))
 '(jdee-db-requested-breakpoint-face-colors (cons "#222228" "#74DFC4"))
 '(jdee-db-spec-breakpoint-face-colors (cons "#222228" "#4E415C"))
 '(objed-cursor-color "#964C7B")
 '(package-selected-packages
   (quote
    (company-lsp delight purescript-mode doom-themes company cmake-mode sqlup-mode emacsql-sqlite3 multiple-cursors golden-ratio sublime-themes telephone-line yaml-mode racket-mode pastelmac-theme magit highlight-indent-guides gruvbox-theme elpy)))
 '(pdf-view-midnight-colors (cons "#FFFFFF" "#27212E"))
 '(rustic-ansi-faces
   ["#27212E" "#964C7B" "#74DFC4" "#FFE261" "#40B4C4" "#EB64B9" "#B4DCE7" "#FFFFFF"])
 '(vc-annotate-background "#27212E")
 '(vc-annotate-color-map
   (list
    (cons 20 "#74DFC4")
    (cons 40 "#a2e0a3")
    (cons 60 "#d0e182")
    (cons 80 "#FFE261")
    (cons 100 "#ffd35f")
    (cons 120 "#ffc55d")
    (cons 140 "#FFB85B")
    (cons 160 "#f89c7a")
    (cons 180 "#f18099")
    (cons 200 "#EB64B9")
    (cons 220 "#ce5ca4")
    (cons 240 "#b2548f")
    (cons 260 "#964C7B")
    (cons 280 "#834973")
    (cons 300 "#72466b")
    (cons 320 "#604363")
    (cons 340 "#544863")
    (cons 360 "#544863")))
 '(vc-annotate-very-old-color nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
