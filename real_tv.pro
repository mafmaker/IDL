
pro real_tv,image_, nobytscl = nobytscl

;  I am so sick of IDL not being able to display images with
;  contours in a reasonable amount of time!!! This is it!
;
;  Sep !p.position before calling this and you're good!
;

image = image_
thing=size(image)

xsize=thing(1) & ysize=thing(2)
;HELP,IMAGE
if keyword_set(nobytscl) ne 1 then image=bytscl(image)
                   ;do before call if you care about
				      ;max and min

oplotscl,image,255,0,findgen(xsize),findgen(ysize),' ',' ',' '
                                     ;do your labels with the contour routine!
return

end
