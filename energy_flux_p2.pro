pro energy_flux_p2,year,day,s12map_,wicmap_,s13map_,EE,EF,EFP,$
	all_good=all_good,no_corr=no_corr,$
	proton_energy=proton_energy,golow=golow,goverylow=goverylow,$
	uncertain=uncertain,wic_samples=wic_samples,$
	si_samples=si_samples,ee_limit=ee_limit,rat_boost=rat_boost,$
	s13_no_corr=s13_no_corr,use_msis=use_msis,median=median,$	
	resize=resize, cal_correct=cal_correct, stopper = stopper,$
                   free_correct=free_correct

; Author : Thomas Immel, UCB
; Date   : 5-8-2001
; Purpose: Using all 3 channels, calculate characteristic
;  	   energy of incoming electrons. s12 is used to correct
;	   wic images. If a 0 is provided, no_corr should be set to 1
;	   NEW FEATURE (v2) this code now also provides proton energy	
;	   flux. Should have done that from the start!!!
;
; inputs  :  s12_map, wicmap, s13map,  preferably 2-D auroral data. 
;	  :  year and day are provided only to make adjustment for WIC
;	  :  gain. If you provide 2000, day 300, it turns it off.
;
; outputs :  EE, EF electron energy and flux
; 	  :  EFP  proton energy flux (characteristic energy is a given)
;
; keyword : all_good : do not look for a minimum in the data set, assume
;	  : all the data are prepared for this calculation.
;	  : proton_energy : pass the proton energy to 
;		-update, should just load Hardy model for proton
;		energy if /hardy is used.
;
;	  : no_corr : no proton corrections
;	  : golow : allow s13 counts lt 9 (down to min_s13)
;	  : uncertain : return range ofpossible EE and EF values by
;	  :  way of EE and EF, where these will now be 3 element vectors
;	  :  with [EE, EElow, EEhigh]
;	  : si_samples,wic_samples - number of samples that went into 
;	  :  determining the 3 main inputs. For reduction of estimated error.
;	  : resize - returns map arrays normalized to same exact size.
;         : cal_correct - apply fuv_mission_correction to 3 channels
;
; issues  : better_data and 3 values are only used if you do the
;	    proton correction!
;
; New keyword : ee_limit - limit the ee calculated from the ratio
;             : rat_boost - boost the ratios by this amount to account for
;	      : the disturbed atmosphere
;             : s13_no_corr means don't correct s13 images for proton effects
;	      : use_msis - not implemented yet, but this is a replacement
;		for rat_boost, where the ratio boost will be calculated for
;		every position in the map, using the column densities in 
;		the use_msis array
;	      10-08-01 : if you do uncertainties, a 1-d array (or 2d) is 
;		       : expected.
;             03-02-05 
;             : free_correct allows ratios of O/N2 that are greater than
;             0.67 to affect the s13/wic ratio curve. Default is to
;             limit rat_boost to values > 0, limiting the O/N2 effect
;
;
;--- if s13_flag is 1, make the proton correction

;print, 'check s12map' &  stop


s13_flag = 1  	
if keyword_set(s13_no_corr) gt 0 then s13_flag = 0


rat_booster=0
if keyword_set(rat_boost) gt 0 then rat_booster=rat_boost


if keyword_set(wic_samples) le 0 then begin
  wic_samples=1.
  si_samples=1.
endif


p2d_flag =0			;proton energies in a 2d array
if keyword_set(proton_energy) ge 1 then begin
  proton_size=size(proton_energy)
  if proton_size(0) gt 1 then p2d_flag=1 
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

;if proton_energy

;--- this should only be done if the arrays are 2D!!!
;--- AND NOTE, this works only for the northern hemisphere!!!
;--- you would have to flip the arrays or index these differently to make
;--- it work at the SP.

if wicsize(0) gt 1 then begin

  latsize=min([s12size(2),wicsize(2),s13size(2)])

  if latsize le 1 then $
	latsize=min([wicsize(2),s13size(2)])    ; protons were not provided
  wicmap=wicmap(*,wicsize(2)-latsize:*)
  s13map=s13map(*,s13size(2)-latsize:*)
  if latsize gt 1 then s12map=s12map(*,s12size(2)-latsize:*)
  if p2d_flag gt 0 then proton_energy=proton_energy(*,proton_size(2)-latsize:*)
endif

;--- now that all arrays are absolutely the same size (if you didn't
;--- make sure of that already) find the bad overlapping data points
missing_count=0

if keyword_set(all_good) ne 1 then begin

;--- this ends up killing lots of pixels on the dayside if you did a 
;--- decent dayglow subtraction. Thats' OK.

; missing_data=where(wicmap lt 0 or s12map lt 0 or s13map lt 0,missing_count)
;--- leave s12map out of this
  missing_data=where(wicmap lt 0 or s13map lt 0,missing_count)
;--

;  zero_data=where(wicmap ge 0 and s12map ge 0 and s13map ge 0)
  good_data=where(wicmap gt 0 and s12map gt 0 and s13map gt 0,goodcount)
  if keyword_set(no_corr) gt 0 then $
    good_data = where(wicmap gt 0 and s13map gt 0, goodcount)

if goodcount eq 0 then begin
  ef=wicmap_  &  ee=wicmap_  &  efp=wicmap_
  ef(*)=0 & ee(*)=0 & efp(*)=0
  print,'there were no counts in S12,WIC, OR S13'

  print,'setting all energies to 0'
  print,'exiting'
  goto,GET_OUT
endif



  fixwic=min(wicmap(good_data)) & wicmap=wicmap-fixwic
  fixs13=min(s13map(good_data)) & s13map=s13map-fixs13
  fixs12=min(s12map(good_data)) & s12map=s12map-fixs12
  help, fixwic,fixs13,fixs12
endif

;--- now that wic is minimized to a base background level...
;--- if you only have auroral data, this is probably not good!!!
;

min_s13=9.
if keyword_set(golow) eq 1 then min_s13=3.	;should consitute a signal
if keyword_set(golower) eq 1 then min_s13=2.	;should consitute a signal

better_data=where(wicmap gt 0 and s12map gt 0 and s13map gt min_s13,betcount)
if keyword_set(no_corr) gt 0 then better_data=where(wicmap gt 0 and s13map gt min_s13,betcount)
print,min_s13,'MIN SI-13 counts!', betcount,'Number of pixels to use!'

;---- consider you may hand off an image which won't even have aurora in rt

if betcount eq 0 then begin
  ef=wicmap_  &  ee=wicmap_  &  efp=wicmap_
  ef(*)=0 & ee(*)=0 & efp(*)=0
  print,'there were no counts in S12,WIC, and in S13 all counts < ',min_s13 
  print,'setting all energies to 0'
  print,'exiting'
  goto,GET_OUT
endif

;--- the min latitude will change, so any mapping should be done
;--- with a small grain of salt.

;--- correct wic for change in gain effected in late 2000.
;--- (need to get a better handle on that)  NO KIDDING. WHAT ABOUT THE
;    SENSITIVITY CORRECTIONS FROM HARALD??? 10-10

;   if (fix(day) gt 353 and fix(year) eq 2000) or $
;	 (fix(year) ge 2001 and fix(day) lt 95) then begin 
;     wicmap=wicmap * 1./1.4
;     print,'Correcting WIC response for gain change'
;   endif

    if keyword_set(cal_correct) gt 0 then begin
        print,'Correcting for temperature sensitivity in energy_flux_p2'
        fuv_mission_correction,year,day,correction_array
        wicmap=wicmap * correction_array(0)
        s12map=s12map * correction_array(1)
        s13map=s13map * correction_array(2)
    endif
;--- correct wic for proton precipitation ---;




;--- cycle through proton energies until all corrected counts are > 0


if keyword_set(no_corr) lt 1 then begin	  ;must make proton correction

;option 1 : use energy provided in proton_energy keyword
;         : allow this to be a 2D variable, and simply pass it on to
;         : fuv_from_s12 

  if keyword_set(proton_energy) gt 0 then begin	  ;have been given proton <E>
    fuv_from_s12,s12map(better_data),wic_protons,s13_protons,$
		proton_energy=proton_energy

;  endif else if keyword_set(hardy) gt 0 then begin

  endif else begin	;gotta estimate the proton energy somehow


    wic_top=12		;kev THIS SHOULD BE THE SAME AS EE_LIMIT, RIGHT 10-10
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
  if s13_flag eq 1 then s13map(better_data)=s13map(better_data)-s13_protons

;  stop

  bad_protons=where(wicmap lt 0, negcount) ;
  if negcount gt 0 then begin wicmap(bad_protons)=0 & $
	print,'Protons LBH > WIC at '+strcompress(negcount)+' sites' & endif

endif  else print,' energy_flux_p2 : No proton correction'

;--- there is some smoothing going on here...

  if wicsize(0) gt 1 then begin	;else you have handed this program a single
				;data point or 1-D array and smoothing is
				;dumb or not needed

;--- WHEN will I make use of min_s13 if protons are not involved?!!?

;this is to kill those terrible values from the flatfield
;--- tried to comment all this bs out on 2-28-02
    killinf=where(finite(s13map) eq 0,s13inf_counter)
    if s13inf_counter gt 0 then s13map(killinf)=0
    ss13=smooth(s13map,3)
    rat=wicmap/ss13	;/edge does terrible things!!!

;    rat = wicmap/s13map

    default_minrat=10

;stop

;--- commented all this bs out on 2-28-02
    if (missing_count gt 0) then rat(missing_data)=default_minrat
    if (s13inf_counter gt 0) then rat(killinf)=default_minrat

;    s13inf_counter = 0; this is needed later. ARG

  endif else rat=wicmap/s13map

;print,'What does the ratio look like. Better not be any negative values!'
;stop

;--- edit so that use_msis (array of column O/N2 column ratios)

if keyword_set(use_msis) le 0 then $
  rat_2_char2,rat,EE,rat_boost=rat_booster $
else begin

  help,use_msis				;THIS BETTER BE 2D!!!

  ref_col=.67	                         ;reference column used in modeling  

  multiplier=(ref_col / use_msis) - 1   	;generally comes out 0-3

;  multiplier=multiplier/2.

  if keyword_set(free_correct) le 0 then multiplier=(multiplier > 0) ;* 100.		;make it so
  
  rat_2_char2,rat,EE,rat_power=multiplier	;this + 2 addition makes
						;the correction almost 
						;outrageous

;  --- multiplier is looking good.
;  contour,multiplier,levels=[.25,.50,.75,1.00,1.25,1.50,1.75,2.00],$
;		   c_labels=[1, 0 , 1, 1,  1, 1,  1, 0]


endelse

;--- start reining in weird values

  if keyword_set(ee_limit) gt 0 then ee=(ee < ee_limit)
;  stop
  if keyword_set(median) gt 0 then ee=median_arr(ee,3,0)
;  stop


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
  bads12=where(finite(ds12) ne 1,bads12ct)
;  bads13=where(finite(ds13) ne 1,bads13ct)
  if bads12ct gt 0 then ds12(bads12)=0
;  if bads13ct gt 0 then ds13(bads13)=0

  drat=((dwic/wicmap)^2 + (ds13/s13map)^2)^0.5 * rat
  ratlow=rat-drat
  rathigh=rat+drat


  if keyword_set(use_msis) le 0 then begin

    rat_2_char,ratlow,EElow,rat_boost=rat_booster
    rat_2_char,rathigh,EEhigh,rat_boost=rat_booster

  endif else begin

    ref_col=.76	                         ;reference column used in modeling  
    multiplier=(ref_col / use_msis) - 1   	;generally comes out 0-3
    multiplier=(multiplier > 0) ;* 100.		;make it so
    rat_2_char2,ratlow,EElow,rat_power=multiplier	
    rat_2_char2,rathigh,EEhigh,rat_power=multiplier

  endelse		

  if keyword_set(median) gt 0 then begin

;    ee=median_arr(ee,5,0)
    eelow=median_arr(eelow,3,0)
    eehigh=median_arr(eehigh,3,0)
 
;    print,'compare ee and elow,eehigh now'
;    stop

  endif


;--- even if we are setting the ee values to reasonable values,
;--- we should use the error one calculates from the measured ratio
;--- the following method does that, and ensures eelow is not less than 1/3
;--- of the limit

;--- why did I ever do such a thing?

  if keyword_set(ee_limit) then begin

    ceiling=where(ee eq ee_limit,hotcounts)
    if hotcounts gt 0 then begin
      range=eehigh(ceiling)-eelow(ceiling)
      eehigh(ceiling)=ee_limit(ceiling) + range/2.
      eelow(ceiling)=(ee_limit(ceiling)-range/2) > (ee_limit/3.)
    endif
  endif
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

  if keyword_set(uncertain) eq 1 then begin
	wic_2_flux,wicmap-dwic,EElow,wicEFlow
        wic_2_flux,wicmap+dwic,EEhigh,wicEFhigh
;--- do the median earlier! (ee is where it counts!)
;	if keyword_set(median) eq 1 then begin
;	  wicEFlow=median_arr(wiceflow,3,1)
;	  wicEFhigh=median_arr(wicefhigh,3,1)
;	endif
  endif

;--- quickly work with proton image



  flux_from_s12,s12map,EFP,proton_energy=proton_energy

;stop

;--- is this where my proton values get hosed ^^^^^^ ?????
;--- no it is earlier



  if keyword_set(uncertain) eq 1 then begin

	flux_from_s12,s12map-ds12,$
	  EFPlow,proton_energy=proton_energy
        flux_from_s12,s12map+ds12,$
	  EFPhigh,proton_energy=proton_energy
;	if keyword_set(median) eq 1 then begin
;	  efphigh=median_arr(efphigh,3,1)
;	  efplow=median_arr(efplow,3,1)
;        endif
  endif

; s13_2_flux,s13map,EE,s13EF		;Do I need to write this?	
					;if things are self consistent, this
					;should work as well!!!

;--- certainly, the WIC energy flux will have better S-N

  if (missing_count gt 0) then wicEF(missing_data)=0


EF=wicEF

if keyword_set(uncertain) eq 1 then begin
  sizer=size(ee)
  if sizer(0) eq 2 then begin	;--- if the image is 2D...

    ee2=fltarr(3,sizer(1),sizer(2))
    ef2=fltarr(3,sizer(1),sizer(2))
    efp2=fltarr(3,sizer(1),sizer(2))
    EE2(0,*,*)=EE & ee2(1,*,*)=EElow & ee2(2,*,*)=EEhigh
    Ef2(0,*,*)=Ef & ef2(1,*,*)=wicEflow & ef2(2,*,*)=wicEfhigh
    Efp2(0,*,*)=Efp & efp2(1,*,*)=Efplow & efp2(2,*,*)=Efphigh

  endif else begin 

    ee2=fltarr(3,sizer(1))
    ef2=fltarr(3,sizer(1))
    efp2=fltarr(3,sizer(1))
    EE2(0,*)=EE & ee2(1,*)=EElow & ee2(2,*)=EEhigh
    Ef2(0,*)=Ef & ef2(1,*)=wicEflow & ef2(2,*)=wicEfhigh
    Efp2(0,*)=Efp & efp2(1,*)=Efplow & efp2(2,*)=Efphigh

  endelse

    efp=efp2 & ef=ef2 & ee=ee2

endif

GET_OUT:

;if keyword_set(median) gt 0 then begin
;  print,'stopping in energy_flux_p2'
;  stop
;endif

if keyword_set(stopper) gt 0 then stop

if keyword_set(resize) gt 0 then begin

  s12map_=s12map	  ;make sure these variables are not affected before
  wicmap_=wicmap	  ;being returned!!!
  s13map_ = s13map        ; DUMBASS< this INSURES they will be affected@!
                                ; BUT, that is what you want because
                                ; it is in THIS procedure that they
                                ; are resized to match one another.
endif  



return
end
