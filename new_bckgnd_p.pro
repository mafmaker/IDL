  pro new_bckgnd_p,imageinfo,bck,iteration,noflat=noflat,$
	bastille=bastille,nof107=nof107,raw=raw
;
; This background generation program uses the raw data bins of
; azimuth, s, d, and mlt to calculate a model background for images
; Should probably run a WIC Bastille Day model.
; 
; f107 or some other measure of solar EUV is not included, as variations
; across the disc are of greater importance right now, since they cannot
; be corrected by a single multiplier, which works alright with overall
; brightness errors.
;
; in bias file (for WIC anyway) one will find bias_wic and surface 
; where surface is the fit to the whole thing
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
;  added bastille flag to use base file from ~/neo/sci/fuv/bastille/quiet 
;  images
;  added nof107 flag to NOT perform flaky f107 corrections
;  added raw flag to use no fitted values.
;


Print,'Making Background : Iteration= ' + strcompress(iteration) + $
	'



;@degree_trig		;these must now be called in the calling routine
;@fuv_ptg
;@/home/immel/sci/fuv/model/correct_f107_p.pro
;@/home/immel/sci/fuv/model/get_f107_for_time_p.pro

flat_flag = 1
bastille_flag = 1
f107_flag = 1
raw_flag = 1

;restore,'../bastille/images/s1320001980349.idl'


if keyword_set(noflat) eq 1 then flat_flag = 0
if keyword_set(raw) eq 1 then raw_flag = 1
if keyword_set(nof107) eq 1 then f107_flag = 0
if keyword_set(bastille) eq 1 then bastille_flag = 1

if imageinfo.src eq 'HWIC' then begin

  starter='fit_'
  if raw_flag eq 1 then starter=''
  if bastille_flag eq 0 then $
	restore,'/home/immel/neo/sci/fuv/quiet/'+starter+$
		'new_model.idl' else $
	restore,'/home/immel/neo/sci/fuv/quiet/'+starter+$
		'bastille_new_model.idl'   

;  restore,'/home/immel/neo/sci/fuv/quiet/fit_bin_cts2.idlf'  ;this is a small
  sc_flag=0						;floating point array
endif
							;only and does not
							;add much overhead.
							;the variable is avg
if imageinfo.src eq '13LS' then begin
  starter='fit_'
  if raw_flag eq 1 then starter=''
  if bastille_flag eq 0 then $
	restore,'/home/immel/neo/sci/fuv/quiet/'+starter+$
		's13_new_model.idl' else $
	restore,'/home/immel/neo/sci/fuv/quiet/'+starter+$
		'bastille_s13_new_model.idl'   
  if bastille_flag eq 0 then $
	print,'restoring /home/immel/neo/sci/fuv/quiet/'+starter+$
		's13_new_model.idl' else $
	print,'restoring /home/immel/neo/sci/fuv/quiet/'+starter+$
		'bastille_s13_new_model.idl'   


  sc_flag = 2
;  if raw_flag eq 1 then avg=ct_arr/wt_arr

endif

;---now get wic_bias background.

case imageinfo.src of				
  'HWIC' : restore,'/home/immel/neo/sci/fuv/flatfield/wic_bias.idl' ;surface
   else  : begin
		surface=fltarr(128,128) & surface(*)=0
	   end
endcase

;;;;;;;;;;;if strpos(image

sza=imageinfo.sza
dza=imageinfo.dza
quick_azimuth_p,imageinfo,azi
mlt=imageinfo.mlt

sza=fix(round(sza)/sza_s) & dza=fix(round(dza)/dza_s)
azi=fix(round(azi)/azi_s) & mlt=fix(round(mlt)/mlt_s)

bck=sza & bck(*)=0
doback=where(sza gt -1 and sza lt max_sza/sza_s and $
					dza lt max_dza/dza_s,count)
noback=where(sza eq -1 or sza ge max_sza/sza_s or $
		dza gt max_dza/dza_s,badoff)

for i=0L,count-1L do bck(doback(i))=avg(sza(doback(i)),dza(doback(i)),$
					mlt(doback(i)),azi(doback(i)))
;tvscl,bck


bad_pix=where(bck(doback) eq 0,baddiez)	;no background could be provided


bck=bck + surface		;add the slightly temperature dependent
				; bias background for wic.


case imageinfo.src of 
  'HWIC': begin 
		ksmooth,bck,5,0		
		print,'Applying KSMOOTH to bck'
	  end
  '13LS' : begin
;		get_f107_for_time_p,imageinfo.time,f107
;		spare=imageinfo
;		correct_f107_p,spare,f107,iteration,sc_flag,/correct	
;					;spare will have the correction
;					;array since we provide the /correct
;		bck=bck+spare
;		print,'Added f107 corrections to s13 background' 
; 		print,'Better check that BS'
;		stop
	   end
endcase



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
;		print,'Added f107 corrections to s13 background' 
; 		print,'Better check that BS'
;		stop
	   end


  else: print,'No f107 correction is yet available'
  endcase
endif


;--- now FLAT FIELD the BACKGROUND IMAGE, so that it looks like an un
;--- flatfielded image


if flat_flag eq 1 then begin

  year_=imageinfo.time(0)/1000
  day_=imageinfo.time(0) - 1000*year_


  case imageinfo.src of 
    'HWIC' : begin
;		restore,'/home/immel/sci/fuv/flatfield/wic_flatfield.idl'
		flat_arr=get_flatfield(year_,day_,0)
		bck=bck*(1./flat_arr)
	     end

    '13LS' : begin
		flat_arr=get_flatfield(year_,day_,2)
;		restore,'/home/immel/sci/fuv/flatfield/si_flatfield.idl'
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