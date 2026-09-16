

pro correct_f107_p,maf,f107,iteration,sc_flag,$
	normalize=normalize,correct=correct

;
;  Normalize an image to a particular value of f107 from the
;  value associated with the image.
;
;
;
;---Keyword description: 
;
;   /normalize corrects an image to 150 Jy 
;
;   /correct returns the counts to be added to a background
;   image to adjust a 150 Jy background to the F107 value sent with
;   the 'maf'. I.E. REPLACE MAF@!!@!!!#!$
;
;---


bck_flag=0
if keyword_set(correct) then bck_flag = 1

norm_value=150.

fuv_home='/disks/neo/home/immel/sci/fuv/quiet/'
if sc_flag eq 2 then fuv_home=fuv_home + 's13_'


;--- YOU HAVE TO BE ON at LEAST the 1st ITERATION if you are
;--- calling this program!!!

if iteration eq 1 then restore,fuv_home + 'quick_f107.idl'
if iteration eq 2 then restore,fuv_home + 'quick_f107.idlf'
if iteration eq 3 then restore,fuv_home + 'quick_f107.idlff'

;if sc_flag eq 0 then $
;	slopes=reform(f107_fits(6,*,*)) else $	
	slopes=f107_corr_arr

;--- use the actual slope data if s13, as above



corrector=reform(slopes*(f107-norm_value))
sizer=size(corrector)
ssize=sizer(1) & dsize=sizer(2)

img=maf.image

;--- if you want the image corrected properly, you better have shifted 
;--- the image, and there is no shifting
;--- happening in the model directory. Luckily image_bckgnd_p
;--- uses the /correct flag so everything's alright for now.

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

;print,'stopping in correct_f107, check to see what is in maf and img'
;stop

return
end