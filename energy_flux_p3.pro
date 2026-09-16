pro energy_flux_p2,year,day,s12map_,wicmap_,s13map_,EE,EF,EFP,$
	all_good=all_good,no_corr=no_corr,$
	proton_energy=proton_energy,golow=golow,$
	uncertain=uncertain,wic_samples=wic_samples,$
	si_samples=si_samples

; Author : Thomas Immel
; Date   : 5-8-2001
; Purpose: Using all 3 channels, calculate characteristic
;  	   energy of incoming electrons. s12 is used to correct
;	   wic images. If a 0 is provided, no_corr should be set to 1
;	   NEW FEATURE (v2) this code now also provides proton energy	
;	   flux. Should have done that from the start!!!
;
; inputs  :  s12_map, wicmap, s13map,  preferably 2-D auroral data. 
; outputs :  EE, EF electron energy and flux
; 	  :  EFP  proton energy flux (characteristic energy is a given)
;
; keyword : all_good : do not look for a minimum in the data set, assume
;	  : all the data are prepared for this calculation.
;	  : proton_energy : pass the proton energy to 
;	  : no_corr : no proton corrections
;	  : golow : allow s13 counts lt 9 (down to min_s13)
;	  : uncertain : return range of possible EE and EF values by
;	  :  way of EE and EF, where these will now be 3 element vectors
;	  :  with [EE, EElow, EEhigh]
;	  : si_samples,wic_samples - number of samples that went into 
;	  :  determining the 3 main inputs. For reduction of estimated error.
;



if keyword_set(wic_samples) le 0 then begin
  wic_samples=1.
  si_samples=1.
endif


if keyword_set(all_good) gt 0 then print,'Assuming all FUV data is good'
if keyword_set(no_corr) gt 0 then print,'Doing no corrections for protons'

s12map=s12map_		;make sure these variables are not affected before
wicmap=wicmap_		;being returned!!!
s13map=s13map_

;--- check to make sure they are all the same size (this is for
;--- northern hemisphere maps.

wicsize=size(wicmap)
s13size=size(s13map)
s12size=size(s12map)

;--- this should only be done if the arrays are 2D!!!
if wicsize(0) gt 1 then begin

  latsize=min([s12size(2),wicsize(2),s13size(2)])

  if latsize le 1 then $
	latsize=min([wicsize(2),s13size(2)])    ; protons were not provided
  wicmap=wicmap(*,wicsize(2)-latsize:*)
  s13map=s13map(*,s13size(2)-latsize:*)
  if latsize gt 1 then s12map=s12map(*,s12size(2)-latsize:*)

endif

;--- now that all arrays are absolutely the same size (if you didn't
;--- make sure of that already) find the bad overlapping data points
missing_count=0

if keyword_set(all_good) ne 1 then begin


  missing_data=where(wicmap lt 0 or s12map lt 0 or s13map lt 0,missing_count)
  zero_data=where(wicmap ge 0 and s12map ge 0 and s13map ge 0)
  good_data=where(wicmap gt 0 and s12map gt 0 and s13map gt 0)

  fixwic=min(wicmap(good_data)) & wicmap=wicmap-fixwic
  fixs13=min(s13map(good_data)) & s13map=s13map-fixs13
  fixs12=min(s12map(good_data)) & s12map=s12map-fixs12

endif

;--- now that wic is minimized to a base background level...
;--- if you only have auroral data, this is probably not good!!!
;

min_s13=9.
if keyword_set(golow) eq 1 then min_s13=3.	;should consitute a signal

better_data=where(wicmap gt 0 and s12map gt 0 and s13map gt min_s13)

;print,'check that there are no negative values in wicmap or s12map!!!'
;stop


;--- the min latitude will change, so any mapping should be done
;--- with a small grain of salt.

;--- correct wic for change in gain effected in late 2000.
;--- (need to get a better handle on that)

   if (fix(day) gt 353 and fix(year) eq 2000) or $
	 (fix(year) ge 2001 and fix(day) lt 95) then begin 
     wicmap=wicmap * 1./1.5
     print,'Correcting WIC response for gain change'
   endif

;--- correct wic for proton precipitation ---;




;--- cycle through proton energies until all corrected counts are > 0


if keyword_set(no_corr) lt 1 then begin	  ;must make proton correction

  if keyword_set(proton_energy) gt 0 then begin	  ;have been given proton <E>
    fuv_from_s12,s12map(better_data),wic_protons,s13_protons,$
		proton_energy=proton_energy

  endif else begin	;gotta estimate the proton energy


    wic_top=12		;kev
    wic_mins=1
    counter=5

    while wic_mins gt 0 and counter lt wic_top do begin
      fuv_from_s12,s12map(better_data),wic_protons,s13_protons,$
		proton_energy=counter
      wic_mins=min(wicmap(better_data)-wic_protons)
      print,wic_mins
      counter=counter + 1
    endwhile

    print,'Proton Energy Threshold : ' + strcompress(counter)

  endelse	

;  old_wicmap=wicmap

  wicmap(better_data)=wicmap(better_data)-wic_protons
  s13map(better_data)=s13map(better_data)-s13_protons

;  stop

  bad_protons=where(wicmap lt 0, negcount) ;
  if negcount gt 0 then begin wicmap(bad_protons)=0 & $
	print,'Protons LBH > WIC at '+strcompress(negcount)+' sites' & endif

endif  else print,' energy_flux_p : No proton correction'

;--- 
;print,'Make sure proton correction does not take you below 0 counts!!!'

;--- there is some smoothing going on here...

  if wicsize(0) gt 1 then begin	;else you have handed this program a single
				;data point or 1-D array and smoothing is
				;dumb or not needed

;this is to kill those terrible values from the flatfield
;    killinf=where(s13map lt min_s13,s13inf_counter)
    killinf=where(finite(s13map) eq 0,s13inf_counter)
    if s13inf_counter gt 0 then s13map(killinf)=0
    ss13=smooth(s13map,3)

    rat=wicmap/ss13	;/edge does terrible things!!!

    default_minrat=10

    if (missing_count gt 0) then rat(missing_data)=default_minrat
    if (s13inf_counter gt 0) then rat(killinf)=default_minrat

  endif else rat=wicmap/s13map

;print,'What does the ratio look like. Better not be any negative values!'
;stop


  rat_2_char,rat,EE
;--- do the range of the statistically possible ratios and calculate the
;--- equivalent range of uncertainties in EE
;--- start with counting statistics (and gain for WIC), but reduce to 
;--- statistical mean uncertainty if wic_samples or si_samples gt 1
;  uncertainty_rat= d(wic)/wic + d(s13)/s13
;

if keyword_set(uncertain) eq 1 then begin

  wic_gain=14.
  dwic=((wicmap/wic_gain)^0.5 * wic_gain) / (wic_samples-1 > 1)^0.5
  ds13=s13map^0.5 / (si_samples-1 > 1)^0.5
  ds12=s12map^0.5 / (si_samples-1 > 1)^0.5
  drat=((dwic/wicmap)^2 + (ds13/s13map)^2)^0.5 * rat
  ratlow=rat-drat
  rathigh=rat+drat


 rat_2_char,ratlow,EElow
 rat_2_char,rathigh,EEhigh

endif
;--- done with uncertainties in EE


  if wicsize(0) gt 1 then begin	;else you have handed this program a single
				;data point to work with.

    if (missing_count gt 0) then begin 
	ee(missing_data)=0
	if keyword_set(uncertain) eq 1 then eelow(missing_data)=0
	if keyword_set(uncertain) eq 1 then eehigh(missing_data)=0
    	print,'You were missing data and ee values have been set to 0'
    endif

    if (s13inf_counter gt 0) then begin
	ee(killinf)=0
	print,'You had non-finite ee values, which were set to 0'
	if keyword_set(uncertain) eq 1 then eelow(killinf)=0
	if keyword_set(uncertain) eq 1 then eehigh(killinf)=0
    endif
  endif

;print,'You have EE, look at it!. Where is it negative???'
;stop


;--- if you do all_good, why does wicmap get populated with 0.33333333???
;--- and ee full of 0 and 2.8889598

  wic_2_flux,wicmap,EE,wicEF

  if keyword_set(uncertain) eq 1 then wic_2_flux,wicmap-dwic,EElow,wicEFlow
  if keyword_set(uncertain) eq 1 then wic_2_flux,wicmap+dwic,EEhigh,wicEFhigh

  flux_from_s12,s12map,EFP,proton_energy=proton_energy
  if keyword_set(uncertain) eq 1 then flux_from_s12,s12map-ds12,$
	EFPlow,proton_energy=proton_energy
  if keyword_set(uncertain) eq 1 then flux_from_s12,s12map+ds12,$
	EFPhigh,proton_energy=proton_energy


; s13_2_flux,s13map,EE,s13EF		;Do I need to write this?	
					;if things are self consistent, this
					;should work as well!!!

;--- certainly, the WIC energy flux will have better S-N

  if (missing_count gt 0) then wicEF(missing_data)=0


EF=wicEF

if keyword_set(uncertain) eq 1 then begin

  EE=[[EE],[EElow],[EEhigh]]
  EF=[[EF],[wicEFlow],[wicEFhigh]]
  EFP=[[EFP],[EFPlow],[EFPhigh]]

endif

;stop
return
end