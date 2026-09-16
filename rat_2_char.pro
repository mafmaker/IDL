pro  rat_2_char,rat,E,rat_boost=rat_boost,rat_power=rat_power

;
;  program to interpolate/extrapolate in Gerard et al.'s 
;  calculations of WIC/S13 ratio given <E>, to return <E>
;
;  input : 
;
;  v 1.1 - added a guess for 50 keV ratio.
;  v 1.2 - new values from J.-C., added rat_boost to start to 
;  account for decreased O (increased N2 has greater effect at 
;  lower energies, at high energies, it is essentially the same
;  
;  v 1.3  rat_power is next big keyword. Takes ratios to 
;  the 1 + rat_power/10 power. The booster keyword has been basically 
;  unsuccessful
;
;  Note : These energy values are for mean energy, not characteristic
;         energy! Otherwise, the top modeling (50 keV) would be for
;	  a 100 keV mean energy Maxwellian. This does not occur in
;	  the aurora!

rat_booster=0
if keyword_set(rat_boost) gt 0 then rat_booster=rat_boost

rat_pow=0
if keyword_set(rat_power) gt 0 then rat_pow=rat_power

twod_flag=0
sizer=size(rat_booster) 
if sizer(0) gt 1 then twod_flag = 1
sizer=size(rat_power)
if sizer(0) gt 1 then twod_flag = 1

;E_=[0.5,1.,5.,25.,50]	;my guess at 50 was conservative
;rat_=[34.14,52.49,85.28,132.49,160.]
;E_=[0.5,1.,5.,25.,50]
;E_= [1.000000015E-01,  5.000000000E-01,$
;	  1.000000000E+00,  2.000000000E+00,  5.000000000E+00,$
;	  1.000000000E+01,  2.000000000E+01,  2.500000000E+01]
;
;E_=E_*2
E_  = [0.200000  ,1.00000  ,2.00000  ,4.00000   ,10.0000, $
   20.0000 ,  40.0000  , 50.0000]

rat_ = [28.0441 , 54.9829  , 71.6532  ,  86.3470  , 104.307,$
  128.823 , 174.569  , 195.318]

if twod_flag lt 1 then begin
  print,'adjusting ratios for rat_power'
  print,rat_
  rat_= (rat_-rat_(0)) ^ (1. + rat_pow/10.) + rat_(0)
  rat_=rat_ + rat_booster
  print,rat_
endif else begin	;have to work with the 2d array instead!

  bad_rat=where(rat lt rat_(0),badratcount)
  rat= (rat-rat_(0)) ^ (1. + rat_pow/10.) + rat_(0)
  
  rat=rat-rat_booster
  rat=(rat > rat_(0))

endelse

newE=interpol(E_,rat_,rat)
E=newE

;print,'in rat_2_char'
;help,E

;This works nicely. IF you do NOT use the quadratic fit in the interpolation!

end





