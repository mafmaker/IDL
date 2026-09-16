pro  rat_2_char2,rat,E,rat_boost=rat_boost,rat_power=rat_power,$
	reversi=reversi

;  
;  
;  TJI/UCB/BSD
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
;  v 2.0  have to interpolate rat_ at every point to do this right.
;         this is now happening. This now takes *much longer*
;
;         need to add some sort of allowance so that a range of
;	  powers can be compared for a single E, and vice-versa!
;   	  Not sure how that will pan out.  But a single power adjustment
;	  does not require a different 4uck1n9 rat_ array
;	  
;    2.1  incorporate reversi keyword, to interpolate ratios from 
;	  given energies. This is only useful in that it is instructional
; 	  to see what energies would appear as what ratios when varying
;   	  rat_power
	  
;--- not going to use rat_booster anymore!
rat_booster=0
;if keyword_set(rat_boost) gt 0 then rat_booster=rat_boost

rat_pow=0
if keyword_set(rat_power) gt 0 then rat_pow=rat_power


;--- if rat power is more than a single value, then one must assume
;--- that the corrections are different for each pixel!

d_flag=0
;sizer=size(rat_booster) 
;if sizer(0) gt 1 then twod_flag = 1
sizer=size(rat_power)
if sizer(0) ge 1 then d_flag = sizer(0)




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

rat_size=size(rat_)
rat_size=rat_size(1)

;--- the 0-d version (below) works great!

if d_flag lt 1 then begin	

  print,'adjusting ratios for rat_power'
  print,rat_
  rat_= (rat_-rat_(0)) ^ (1. + rat_pow/10.) + rat_(0)
  rat_=rat_ + rat_booster
  print,rat_
  if keyword_set(reversi) le 0 then $
	newE=interpol(E_,rat_,rat) else $    ;this works in 0,1,and 2-	D
	newR=interpol(rat_,E_,E)
endif
;--- this will be slightly more complex!
;endif else begin	;have to work with the 2d array instead!

if d_flag eq 1 then begin

  if keyword_set(reversi) le 0 then begin 
    newE=rat & newE(*)=0
  endif else begin
    newR=E & newR(*)=0
  endelse


  print,'adjusting ratios for rat_power'

;  full_rat=  fltarr(sizer(1)) ## rat_
  for i=0,sizer(1) - 1 do begin
;    full_rat(i,*) = (full_rat-rat_(0)) ^ (1. + rat_pow(i)/10.) + rat_(0)
      new_rat= (rat_-rat_(0)) ^ (1. + rat_pow(i)/10.) + rat_(0) +rat_booster
        if keyword_set(reversi) le 0 then $
		newE(i)=interpol(E_,new_rat,rat(i)) else $
		newR(i)=interpol(new_rat,E_,E(i)) 

  endfor

  
endif

if d_flag eq 2 then begin

  if keyword_set(reversi) le 0 then begin 
    newE=rat & newE(*)=0
  endif else begin
    newR=E & newR(*)=0
  endelse


  print,'adjusting ratios for rat_power'

; full_rat=  fltarr(sizer(1),sizer(2),rat_size)	;cannot even initialize it
						;IDL sorta sucks for this!

  for i=0,sizer(1) -1 do begin
    for j=0,sizer(2) -1 do begin
      new_rat= (rat_-rat_(0)) ^ (1. + rat_pow(i,j)/10.) + rat_(0)+rat_booster
        if keyword_set(reversi) le 0 then $
	  newE(i,j)=interpol(E_,new_rat,rat(i,j)) else $    
          newR(i,j)=interpol(new_rat,E_,E(i,j))    
    endfor
  endfor
endif


;--- do now rat_booster


if keyword_set(reversi) le 0 then E=newE else rat=newR

;print,'in rat_2_char'
;help,E

;This works nicely. IF you do NOT use the quadratic fit in the interpolation!

end





