  pro image_bckgnd_p,imageinfo,bck,iteration,noflat=noflat,$
	bastille=bastille,nof107=nof107,raw=raw,bias=bias,oct2003=oct2003
;
; This program calculates a background dayglow image for 
; any particular wic or si13 image. as of 9-1-2000, there is no
; si model, but this should be designed with si in mind.
;
;
;
;
;
; in bin_cts2.pro one will find:
;BIG_CT          DOUBLE    = Array[21, 110, 90]
;BIG_WT          INT       = Array[21, 110, 90]
;CT_ARR          DOUBLE    = Array[110, 90]
;WT_ARR          FLOAT     = Array[110, 90]
;
; in bias file (for WIC anyway) one will find bias_wic and surface 
; where surface is the fit to the whole thing
;
; the f107 corrections are found using correct_f107_wic or 
; correct_f107_si
;
; adapt to SI13 using imageinfo.src = '13LS' for that instrument
; 
; changes : 9-28-2000 - Choice to return 'flattened' image, selecting
;			noflat or flat keyword.
;	   10-11-2000 - Added iteration flag
;		      - changed correct_f107_wic to correct_f107_p
;			which has sc_flag (determined locally)
;		      - added s13 f107 corrections
;
;  The addition of iteration is a little tricky. 0 means there are
;  no f107 (or other future) corrections to make. The database used
;  to create the background is the raw s and d binned stuff.
;  Iteration=1 means use a normalized background (.idlf vs .idl) AND
;  make the proper corrections to images using (s13)comp_f107.idl

; You should ALWAYS use the latest iteration!!! 1 is the current level
; for wic and s13 (1-17-2001)
;
;  added bastille flag to use base file from ~/neo/sci/fuv/bastille/quiet 
;  images
;  added nof107 flag to NOT perform flaky f107 corrections
;  added raw flag to use no fitted values. It always restores fits
;  using the starter variable.
;
;  6-18-01 added adjustment so that it never ASSUMES the size of any image,  
;  	since Harald may hand a bigger one over from calculate_grids 
;  
;  

;Print,'Making Background : Iteration= ' + strcompress(iteration) + $
;	'



;@degree_trig		;these must now be called in the calling routine
;@fuv_ptg
;@/home/immel/sci/fuv/model/correct_f107_p.pro
;@/home/immel/sci/fuv/model/get_f107_for_time_p.pro

flat_flag = 1
bastille_flag = 0
oct2003_flag = 0
f107_flag = 1
raw_flag = 0


if keyword_set(noflat) eq 1 then flat_flag = 0
if keyword_set(raw) eq 1 then raw_flag = 1
if keyword_set(nof107) eq 1 then f107_flag = 0
if keyword_set(bastille) eq 1 then bastille_flag = 1
if keyword_set(oct2003) eq 1 then oct2003_flag = 1

image_size=size(imageinfo.image)
xsize=image_size(1)			;new 6-18-01
ysize=image_size(2)

if imageinfo.src eq 'HWIC' then begin
  def_xsize=256
  def_ysize=256
  restore,'$FUV_HOME/quiet/fit_bin_cts2.idlf'  ;this is a small file
					       ;and restores AVG only
					       ;there is no option to
					       ;restore raw data here.
  sc_flag=0
  
endif

if imageinfo.src eq '13LS' then begin
  def_xsize=128				;new 6-18-01
  def_ysize=128
  starter='fit_'
  if raw_flag eq 1 then starter=''		;if keyword 'raw' is set then
						;the raw data is restored
						;the same goes for SI12 below

  if bastille_flag eq 0 then $
	restore,'$FUV_HOME/quiet/'+starter+$
		's13_bin_cts2.idl' else $
	restore,'$FUV_HOME/quiet/'+starter+$
		'bastille_s13_bin_cts2.idl'   
  sc_flag = 2
  if oct2003_flag gt 0 then begin 
      restore,'$FUV_HOME/quiet/'+starter+$
   		'oct2003_s13_bin_cts2.idl'  
      avg=fitsurf   ;this special case of oct2003 has saved the fits as well
  endif 


  if raw_flag eq 1 then avg=ct_arr/wt_arr	;if keyword raw is set then
						;you have to calculate
						;avg quickly 
						;the same goes for SI12 below

endif						

if imageinfo.src eq '12LS' then begin
  def_xsize=128
  def_ysize=128
  starter='fit_'
  if raw_flag eq 1 then starter=''
  if bastille_flag eq 0 then $
	restore,'$FUV_HOME/quiet/'+starter+$
		's12_bin_cts2.idl' else $
	restore,'$FUV_HOME/quiet/'+starter+$
		'bastille_s13_bin_cts2.idl'   
  sc_flag = 3
  if raw_flag eq 1 then avg=ct_arr/wt_arr

endif

;---now get wic_bias background.

case imageinfo.src of				
  'HWIC' : restore,'$FUV_HOME/flatfield/wic_bias.idl' ;surface
   else  : begin
		surface=fltarr(128,128) & surface(*)=0
	   end
endcase

  if xsize ne def_xsize or ysize ne def_ysize then $
	surface=congrid(surface,xsize,ysize,/interp)


sza=imageinfo.sza
dza=imageinfo.dza

sza=fix(round(sza)) & dza=fix(round(dza))

bck=sza & bck(*)=0
doback=where(sza gt -1 and sza lt 110 and dza lt 80,count)
noback=where(sza eq -1 or sza ge 110 or dza gt 80,badoff)

if count gt 0 then begin

  for i=0L,count-1L do bck(doback(i))=avg[sza(doback(i)),dza(doback(i))]

  bad_pix=where(bck(doback) eq 0,baddiez)	;do no background 

  bck=bck + surface		;add the slightly temperature dependent
				; bias background for wic.

;---now get f107 correction array

  if iteration gt 0 and f107_flag gt 0 then begin

    case imageinfo.src of 
  'HWIC': begin 
		get_f107_for_time_p,imageinfo.time,f107
		spare=imageinfo
		correct_f107_p,spare,f107,iteration,sc_flag,/correct	
					;spare will have the correction
					;array since we provide the /correct
		bck=bck+spare
		
		print,'Added f107 corrections to wic background' 
	  end
  '13LS' : begin
		get_f107_for_time_p,imageinfo.time,f107
		spare=imageinfo
		correct_f107_p,spare,f107,iteration,sc_flag,/correct	
					;spare will have the correction
					;array since we provide the /correct
		bck=bck+spare
		print,'Added f107 corrections to s13 background' 
	   end


  else: print,'No f107 correction is yet available'
    endcase
  endif


;--- now FLAT FIELD the BACKGROUND IMAGE, so that it looks like an un
;--- flatfielded image


  if flat_flag eq 1 then begin

    year_=imageinfo.time(0)/1000
    day_=imageinfo.time(0) - 1000*year_

;--- all you have to say is this:

    flat_arr=get_flatfield(year_,day_,sc_flag)

    if xsize ne def_xsize or ysize ne def_ysize then $
	flat_arr=congrid(flat_arr,xsize,ysize,/interp)    
    
;    finite    
 
    bck=bck*(1./flat_arr)

  endif

  if baddiez gt 0 then bck(doback(bad_pix))=0		
				;make sure any bad values are set to zop

  if badoff gt 0 then bck(noback)=0

  if keyword_set(bias) gt 0 then begin
	if imageinfo.src eq 'HWIC' and badoff gt 0 $
	then bck(noback)=surface(noback)

	if imageinfo.src eq 'HWIC' and baddiez gt 0 $
	then bck(doback(bad_pix))=surface(doback(bad_pix))

  endif

;--- I would ALWAYS set uncalculated background values to 
;--- the bias value (for WIC), except that
;--- a lot of my software expects that 0 background means it was not
;--- calculated. If you want bias values everywhere, use the /bias flag

;stop

endif else print,'No good pixels for background calculation'
  
return
end
