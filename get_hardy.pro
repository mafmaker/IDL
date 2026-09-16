
pro get_hardy,kp,pe,ll=ll,geo=geo,ut=ut,interpol=interpol,ratio=ratio

;

; get_hardy.pro
; program to ingest proton characteristic energies from the idl file
; created on 5-11-2001 from the ascii data provided by Benoit Hubert
; for kp=3. Default resolution is full earth, 0.5,0.5 degrees
;
; All code by TJI - UCB - BSD 
;
;
; NEW : Fixed so you could not use kp over 6 (which is not provided
;     : by Hardy anyway.
;     : added ll (lower limit) keyword to bound proton energies
;
;     : geo keyword shifts the hardy model to geographic coordinates
;     : the geo keyword must be accompanied by a UT keyword (decimal hours)
;
;     : 10-5-04 - setting limits of kp=1-5. Outside of these values
;                 the patterns look pretty strange.
;     :           This obviously needs interpolation to lower
;     latitudes for real proton aurorae. Do it! (It is done and included)
;
;     Added keyword ratio to restore ETOT/NTOT determined ratio. Otherwise
;     the default is going to be Marina style EAVG, determined using
;     the iavgkp.f routines. *In this, we are switching away from the Belgian method!*

time=-1
if keyword_set(ut) ge 0 and $
	keyword_set(geo) gt 0 then print,'Doing Geographic Transformation'

lower_limit=0.
if keyword_set(ll) gt 0 then lower_limit=ll

skp=strcompress(round(kp < 6),/rem)

;---only if you are using the ratio determined averages do you have to
;---avoid low and high kp
if keyword_set(ratio) gt 0 then begin

  if kp le 0 then begin & kp = 1 & print,'Disallowing Kp=0' & endif
  skp=strcompress(round(kp < 5),/rem)

endif

ratio_txt='avg'
if keyword_set(ratio) gt 0 then ratio_txt=''

restore,'/home/immel/sci/hardy/kp' + ratio_txt + skp + '.idl'
print, 'restoring /home/immel/sci/hardy/kp' + ratio_txt + skp + '.idl'

pe=avg_e
pe=pe > lower_limit

if keyword_set(interpol) gt 0 then hardy_interpolate,pe,kp
  
if keyword_set(ut) ge 0 then begin
  if keyword_set(geo) gt 0 then begin

    hardy_2_geo,pe,ut

  endif
endif
return
end
