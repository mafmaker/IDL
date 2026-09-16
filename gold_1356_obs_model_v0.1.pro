;Name:
;	gold_1356_obs_model_v0

;Puropse:
;	computes the expected signal and noise 
;	for given a 135.6 nm atomic oxygen radiance structure, specified in Rayleighs

;Inputs:
;	input_radiance:		oxygen 135.6 nm radiance structrue (single point, 1D vector, or 2D image) in Rayleighs
;	integration_time:	integration_time in seconds (default integration period is 2.5 seconds if integration_time is not specified)
;	spatial_scale:		spatial scale is xkm x ykm or 100km x 100km (defalut spatial scale is 100km x 100km if spatial_scale is not specified)
;				set spatial_scale=[25,25] for 25km x 25km spatial scale  or spatial_scale=[100,100] for 100km x 100km spatial scale
;	randomn_seed:		randomn_seed = seed value for the randomn number routine (if not set the default value is calculated from computer clock time)
;       /normal:		default noise model is Poisson set /normal for Gaussian noise


;Outputs:
;	output_counts:		instrument output_counts including noise (in counts per integration)
;	output_signal:		instrument output-signal without noise   (in counts per integration)

; Version 0 - 3/09/2007 WEM
; Version 0.1 3/12/2007 TJI   - Unix newline formatted (vs Mac
;                               linefeed format! of v0)

pro gold_1356_obs_model_v0,input_radiance,output_counts,output_signal,integration_time=integration_time,spatial_scale=spatial_scale,randomn_seed=randomn_seed,sensitivity=sensitivity,normal=normal
; sensitivity (count/Rayleigh at 100km x 100km resolution)
; S=(10^6./4./!pi)*(W_slit*H_pixel/F_no/F_no)*Optics*Detector*Grating*int_time
 F_no=7.5									;F/7.5 focal ratio
 w_slit = 15.*(100/35787.) 							;assumes 15 cm focal length telescope and 100 km slit width at the sub-spacecraft point
 h_pixel = w_slit								;assumes a square spatial resolution element  
 refl = 0.85
 optics = refl^3.  								;3 optical elements in addition to the grating
 grating = 0.48 *refl   							;50% groove efficiency for the grating at 140 nm
 detector = 0.26								;26% efficiency at 135.6 nm
 int_time = 2.5									; 2.5 second integration
 
 ; modify defalut integration time and spatial scale
 if keyword_set (integration_time) then int_time=float(integration_time)
 
 ; modify defalut spatial scale
 if keyword_set(spatial_scale) then begin
 	w_slit=w_slit*spatial_scale(0)/100.
 	h_pixel=h_pixel*spatial_scale(1)/100.
  endif
  
 Sensitivity=(10^6./4./!pi)*(W_slit*H_pixel/F_no/F_no)*Optics*Detector*Grating*int_time
 print,'Sensitivity = ',Sensitivity,' counts/integration_period/Rayleigh of 135.6 nm emission'
 if keyword_set(sensitivity) then sensitivity=sensitivity
  
 ; get seed for noise calculation
  
 seed=fix(systime(1,/seconds)-1.17345e+09)
 if keyword_set(randomn_seed) then seed=randomn_seed
  
 ; determine the size of the input data structure
 ; convert input data to a floating point number
 input_radiance=input_radiance*1.
 output_signal=input_radiance*Sensitivity
 sz=size(input_radiance)
 
 ;normal statistics
 if keyword_set(normal) then begin
 case sz(0) of
 0: output_noise=randomn(seed,1)
 1: output_noise=randomn(seed,sz(1))
 2: output_noise=randomn(seed,sz(1),sz(2))
 endcase
 output_counts=output_signal+sqrt(output_signal)*output_noise
 ;print,'Normal statistics'
 return
 endif
 
 ;poisson statistics
 if sz(0) eq 0 then output_counts=randomn(seed,1,poisson=output_signal)
 if sz(0) eq 1 then begin
 	output_counts=fltarr(sz(1))
 	for k=0,sz(1)-1 do output_counts(k)=randomn(seed+k,1,poisson=output_signal(k))
 endif
 if sz(0) eq 2 then begin
 	output_counts=fltarr(sz(1),sz(2))
 	for k=0,sz(1)-1 do for l=0,sz(2)-1 do output_counts(k,l)=randomn(seed+k+l*k,1,poisson=output_signal(k,l))
 endif
 ;print,'Poisson statistics'	
 return
  end
  
  	
 


