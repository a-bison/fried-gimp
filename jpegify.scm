; jpegify - gimp plugin for artificially inducing jpeg artifacting
; Copyright (C) 2021 a-bison
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <https://www.gnu.org/licenses/>.

(define (script-fu-jpegify image
                           drawable
                           quality)
  (let*
    (
      (tmp-path (car (gimp-temp-name "jpg")))
      (jpegged-image 0)
      (out-layer 0)
      (jpeg-smoothing 1)
      (jpeg-optimize 1)
      (jpeg-progressive 0)
      (jpeg-comment "")
      (jpeg-subsmp 0)
      (jpeg-baseline 1)
      (jpeg-restart 0)
      (jpeg-dct 1)
      (width (car (gimp-image-width image)))
      (height (car (gimp-image-height image)))
    )

    (gimp-context-push)
    (gimp-image-undo-group-start image)

    (file-jpeg-save RUN-NONINTERACTIVE
      image
      drawable
      tmp-path
      tmp-path
      quality
      jpeg-smoothing
      jpeg-optimize
      jpeg-progressive
      jpeg-comment
      jpeg-subsmp
      jpeg-baseline
      jpeg-restart
      jpeg-dct
    )

    (set! jpegged-image 
      (car (file-jpeg-load RUN-NONINTERACTIVE tmp-path tmp-path)))
    
    (set! out-layer 
      (car (gimp-layer-new image
                           width
                           height
                           RGB-IMAGE
                           "JPEGIFY"
                           100
                           LAYER-MODE-NORMAL)))
    (gimp-image-insert-layer image out-layer 0 0)

    (gimp-edit-copy 
      (car (gimp-image-get-layer-by-name jpegged-image "Background")))
    
    (let ((floating-layer (car (gimp-edit-paste out-layer FALSE))))
      (gimp-floating-sel-anchor floating-layer)
    )

    (gimp-image-delete jpegged-image)
    (file-delete tmp-path)

    (gimp-image-undo-group-end image)
    (gimp-displays-flush)
    (gimp-context-pop)
  )
)

(script-fu-register "script-fu-jpegify"
  "_Jpegify..."
  "Applies JPEG compression to the current layer."
  "a-bison"
  "Copyright (C) 2021, a-bison"
  "March 23, 2021"
  ""
  SF-IMAGE      "Image"    0
  SF-DRAWABLE   "Drawable" 0
  SF-ADJUSTMENT "Quality" '(0.01 0 1 0.01 0.1 2 0)
)

(script-fu-menu-register "script-fu-jpegify"
                         "<Image>/Filters/Deepfry")
