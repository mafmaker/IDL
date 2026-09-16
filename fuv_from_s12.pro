pro fuv_from_s12,s12_cts,wic_cts_p,s13_cts_p,proton_energy=proton_energy

;
;  Author : Thomas Immel
;  Date   : 3-2-2001
;
;
;  This program returns the counts in the wic channel due to
;  LBH resulting from proton-created secondaries. Give it an s12
;  count rate, it will return a wic count rate.
;
;  It's fun, since it will take arrays of counts, or arrays 
;  of proton energies. Whee!
;
;  ee=electron energy
;  pe=proton energy
;-- next 2 are unused
;  lbh_e_abs=the amount of lbh per erg at above energies of electrons
;  lbh_p_abs=the amount of lbh per erg at above energies of protons
;  wic_e_abs=wic response per erg of above electrons
;  wic_p_abs=wic response per erg of above protons
;  s12_p = s12 response per erg of the above protons
;
;  version 1.1 now calculates s13 correction as well, going to rename
;  to fuv_from_s12
;
;  version 1.2 new values from Harald/J.C.
;Kappa
;ev (1 erg beam?)
;466               23.657760
;2330             38.125560
;4660             35.965404
;9320             27.858259
;13980           22.468206
;23300           17.899776
;32620           14.818180
;46600           11.706791
;116500         8.5152510
;
;
;


;ee=[.5,1.,5.,25.]		;characteristic energy in keV

;--- these must be the same as the values used in flux_from_s12.pro

pe=[2.,8.,25.,100.]			;need to hack in an asymtote?
s12_p=[28.9,26.9,16.0,8.]

;lbh_e=[1940.,2450.,3070.,3170.]	;Rayleighs for 1 erg at that energy
;lbh_p=[2310.,3040.,3310.]

;lbh_e_abs=[1910.,2390.,2320.,1010.]  ; Now including absorption
;lbh_p_abs=[2250.,2900.,3110.]

;wic_e=[351.,443.,556.,575.]	;counts for 1 erg at that energy
;wic_p_abs=[419.,551.,601.]
;wic_e_abs=[344.,427.,346.,95.4]	;Now including absorption


wic_p_abs=[401.,510.,538.,400.]	;big difference!!!
s13_p_rayleighs=[155,279,267,100.]		
s13_p_abs=s13_p_rayleighs * 1.48e-02		
				;J-C did not provide in table 1 s13 cts.




;--- at this point, have to assume a proton energy, unless it is provided
;--- in the call. 5 is the magic number.

if keyword_set(proton_energy) le 0 then proton_energy=10
proton_energy=float(proton_energy)

;--- given energy, interpolate to find predicted count rate for 1 erg

s12_coefs=poly_fit(pe,s12_p,2,s12a)	;binomial fit to s12 response
s13_coefs=poly_fit(pe,s13_p_abs,2,s13a)	;binomial fit to s12 response
wic_coefs=poly_fit(pe,wic_p_abs,2,wica) ;binomial fit to wic response

;;;save,filename='proton_coefs.idl',s12_coefs,s13_coefs,wic_coefs


predict_s12=s12_coefs(0) + s12_coefs(1)*proton_energy + $
	s12_coefs(2)*proton_energy^2; + 	s12_coefs(3)*proton_energy^3

predict_s13=s13_coefs(0) + s13_coefs(1)*proton_energy + $
	s13_coefs(2)*proton_energy^2

predict_wic=wic_coefs(0) + wic_coefs(1)*proton_energy + $
	wic_coefs(2)*proton_energy^2

;--- do the fits explicitly, as above.
;predict_s12=interpol(s12_p,pe,proton_energy,/quadratic)
;predict_wic=interpol(wic_p,pe,proton_energy,/quadratic)

;--- compare to actual count rate, calculating proton energy flux in ergs

p_eflux=s12_cts/predict_s12

;--- correct predicted (WIC) count rate (1 erg) for energy flux difference.

predict_wic=predict_wic * p_eflux * 1 	; 1 is 1 erg^-1
predict_s13=predict_s13 * p_eflux * 1 	; 1 is 1 erg^-1


;--- you are done!

wic_cts_p=predict_wic
s13_cts_p=predict_s13

;stop

return
end