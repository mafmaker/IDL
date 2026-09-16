  pro image_bckgnd2_p,imageinfo,rat_arr,bck,iteration,noflat=noflat,bastille=bastille,nomsis=nomsis,nof107=nof107
;
; This program calculates a background dayglow image for 
; any particular wic or si13 image. as of 9-1-2000, there is no
; si model, but this should be designed with si in mind.
;
; This is image_bckgnd2_p, which differs in that it requires n2 density
; be provided in the call. It is passed to correct_msis_p
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
;
;
;  added bastille flag to use base file from 
;

Print,'Making Background : Iteration= ' + strcompress(iteration)



;@degree_trig		;these must now be called in the calling routine
;@fuv_ptg
;@/home/immel/sci/fuv/model/correct_f107_p.pro
;@/home/immel/sci/fuv/model/get_f107_for_time_p.pro

flat_flag = 1
bastille_flag = 0	
raw_flag=0
f107_flag = 1
msis_flag = 1

if keyword_set(noflat) eq 1 then flat_flag = 0
if keyword_set(bastille) eq 1 then bastille_flag = 1
if keyword_set(nof107) eq 1 then f107_flag = 0
if keyword_set(nomsis) eq 1 then msis_flag = 0



if imageinfo.src eq 'HWIC' then begin
  restore,'/disks/neo/home/immel/sci/fuv/quiet/fit_bin_cts2.idlf'	;this is a small
  sc_flag=0						;floating point array
endif
							;only and does not
							;add much overhead.
							;the variable is avg
if imageinfo.src eq '13LS' then begin
  if bastille_flag eq 0 then $
	restore,'/disks/neo/home/immel/sci/fuv/quiet/fit_s13_bin_cts2.idl' else $
	restore,'/disks/neo//home/immel/sci/fuv/quiet/fit_bastille_s13_bin_cts2.idl'   
  if oct2003_flag gt 0 then restore

  sc_flag = 2
endif

;---now get wic_bias background.

case imageinfo.src of				
  'HWIC' : restore,'/home/immel/sci/fuv/flatfield/wic_bias.idl' ;surface
   else  : begin
		surface=fltarr(128,128) & surface(*)=0
	   end
endcase

;;;;;;;;;;;if strpos(image

sza=imageinfo.sza
dza=imageinfo.dza

sza=fix(round(sza)) & dza=fix(round(dza))

bck=sza & bck(*)=0
doback=where(sza gt -1 and sza lt 110 and dza lt 80,count)
noback=where(sza eq -1 or sza ge 110 or dza gt 80,badoff)

for i=0L,count-1L do bck(doback(i))=avg(sza(doback(i)),dza(doback(i)))
;tvscl,bck
bad_pix=where(bck(doback) eq 0,baddiez)	;no background could be provided


bck=bck + surface		;add the slightly temperature dependent
				; bias background for wic.

;---now get f107 correction array

if iteration gt 0 then begin

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
;		print,'Added f107 corrections to s13 background' 
; 		print,'Better check that BS'
;		stop
	   end


  else: print,'No f107 correction is yet available'
  endcase
endif


;--- NOW correct for O/N2 density.

if iteration gt 0 and msis_flag eq 1 then begin

  case imageinfo.src of 
  'HWIC': begin 

		spare2=imageinfo
		correct_msis_p,spare2,rat_arr,iteration,sc_flag,/correct	
					;spare will have the correction
					;array since we provide the /correct
		bck=bck+spare2
	  end
  '13LS' : begin
		spare2=imageinfo
		correct_msis_p,spare2,rat_arr,iteration,sc_flag,/correct	
					;spare will have the correction
					;array since we provide the /correct
		bck=bck+spare2
	   end
  endcase
endif

;--- now FLAT FIELD the BACKGROUND IMAGE, so that it looks like an un
;--- flatfielded image


if flat_flag eq 1 then begin

  case imageinfo.src of 
    'HWIC' : begin
		restore,'/disks/neo/home/immel/sci/fuv/flatfield/wic_flatfield.idl'
		bck=bck*(1./flat_arr)
	     end

    '13LS' : begin
                year_=imageinfo.time(0)/1000
                day_=imageinfo.time(0) - 1000*year_
                flat_arr=get_flatfield(year_,day_,2)
		bck=bck*(1./flat_arr)
	     end
  endcase
endif

if baddiez gt 0 then bck(doback(bad_pix))=0		
				;make sure any bad values are set to zop

if badoff gt 0 then bck(noback)=0

;stop

return
end
