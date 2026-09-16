

pro correct_msis_p,maf,o_n2_den,iteration,sc_flag,$
	normalize=normalize,correct=correct,bastille=bastille

;
;  Normalize an image to a particular value of f107 from the
;  value associated with the image.
;
;
;
;---Keyword description: 
;
;   /normalize corrects an image to 0.6 [O]/[N2]
;
;   /correct returns the counts to be added to a background
;   image to adjust a 150 Jy background to the F107 value sent with
;   the 'maf'. I.E. REPLACE MAF@!!@!!!#!$
;
;---  Adding features(?) to do column densities instead.
;   When would you ever call with correct? When you are correcting
;   a background (i.e. image_bckgnd_p.pro). The result is ADDED to the
;   background.
;
;   If you are building up the model, you do not necessarily want to 
;   do that (it's always easier if you know if you call it right,
;   you do NOTHING OR just add the returned correction array, never subtract)
;  
;   Yes, the codes in the quiet time directory just pass the maf and use
;   the returned maf as usual


bck_flag=0
if keyword_set(correct) then bck_flag = 1
bastille_flag = 0
if keyword_set(bastille) then bastille_flag = 1

norm_value=.6		;value of O/N2 column density that we are norming to.

fuv_home='/disks/neo/home/immel/sci/fuv/quiet/'
if bastille_flag eq 1 then fuv_home=fuv_home + 'bastille_
if sc_flag eq 2 then fuv_home=fuv_home + 's13_'


;--- YOU HAVE TO BE ON at LEAST the 1st ITERATION if you are
;--- calling this program!!!

if iteration eq 0 then restore,fuv_home + 'quick_msis.idl'
if iteration eq 1 then restore,fuv_home + 'quick_msis.idlf'
if iteration eq 2 then restore,fuv_home + 'quick_msis.idlff'
if iteration eq 3 then restore,fuv_home + 'quick_msis.idlfff'

if sc_flag eq 0 then print,'WIC not done yet' else begin

;--- use the actual slope data if s13, since the fits are so crappieeeee

  slopes=reform(rat_corr(1,*,*))			;slopes are flt_arr(s,d)

  newslopes=median_arr(slopes,5,0)
  
  ksmooth,newslopes,5,0
  slopes=newslopes
endelse


s=maf.sza
d=maf.dza
thing=where(d ge 0 and d lt 90,counter)



if counter gt 0 then begin
  ss=fix(s(thing)) & dd=fix(d(thing))

;--- the old corrector is too simple for this work
;--- corrector is loaded with the difference between the 
;--- n2 normalization value and the MSIS prediction TIMES
;--- the slope at that location

  corrector=maf.image & corrector(*)=0
  corrector2=corrector
  sizer=size(corrector)
  ssize=sizer(1) & dsize=sizer(2)
  corrector(thing)=slopes(ss,dd)*(o_n2_den(thing)-norm_value)
  corrector2(thing)=slopes(ss,dd)

endif


img=maf.image
save,filename='o_n2_correction.idl',corrector,corrector2,img



;--- if you want the image corrected properly, you better have shifted 
;--- the image, and there is no shifting
;--- happening in the model directory. Luckily image_bckgnd_p
;--- uses the /correct flag so everything's alright for now.

if bck_flag ne 0 then img(*)=0		;if /correct, then provide
					;only the corrections



if counter gt 0 then begin
;  ss=fix(s(thing)) & dd=fix(d(thing))
;  corrections=corrector(ss<ssize,dd<dsize)
;  img(thing)=img(thing)-corrector

  img=img-corrector

endif

;tvscl,img
;tvscl,maf.image,256,0
;stop

; if we are not just providing
; a correction array for a particular
; background, change the actual maf.

if bck_flag eq 0 then maf.image=img $
else maf=(-1) * img

;print,'stopping in correct_msis, check to see what is in maf and img'
;stop

return
end