

pro correct_f107_wic,maf,f107,$
	normalize=normalize,iter2=iter2,iter1=iter1,correct=correct

;
;  Normalize an image to a particular value of f107 from the
;  value associated with the image.
;
;
;
;---Keyword description: 
;
;---normalize corrects an image to 150 Jy 
;---correct returns the counts to be added to a background
;---image to adjust a 150 Jy background to the F107 value sent with
;---the 'maf'. I.E. REPLACE MAF@!!@!!!#!$
;
;---

iteration=0

if keyword_set(iter2) then iteration=2
if keyword_set(iter1) then iteration=1




bck_flag=0
if keyword_set(correct) then bck_flag = 1

norm_value=150.

fuv_home='/home/immel/sci/fuv/'

if iteration eq 0 then restore,fuv_home + 'quiet/comp_f107.idl'
if iteration eq 1 then restore,fuv_home + 'quiet/comp_f107.idlf'
if iteration eq 2 then restore,fuv_home + 'quiet/comp_f107.idlff'

slopes=f107_fits(6,*,*)
corrector=reform(slopes*(f107-norm_value))
sizer=size(corrector)
ssize=sizer(1) & dsize=sizer(2)

img=maf.image
if bck_flag ne 0 then img(*)=0		;if /correct, then provide
					;only the corrections
s=maf.sza
d=maf.dza

thing=where(d ge 0 and d lt 90,counter)

if counter gt 0 then begin
  ss=fix(s(thing)) & dd=fix(d(thing))
  corrections=corrector(ss<ssize,dd<dsize)
  img(thing)=img(thing)-corrections
endif

;tvscl,img
;tvscl,maf.image,256,0
;stop

; if we are not just providing
; a correction array for a particular
; background, change the actual maf.

if bck_flag eq 0 then maf.image=img $
else maf=(-1) * img
return
end