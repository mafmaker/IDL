pro convert_wic_si12_new,x_in,y_in,x_out,y_out,x_out2,y_out2,x_out3,y_out3,$
	x_out4,y_out4,x_out5,y_out5,x_out6,y_out6,x_out7,y_out7,$
	x_out8,y_out8,x_out9,y_out9,x_out10,y_out10,time_diff,$
	reverse=reverse

;if keyword_set(reverse) then begin
;	print,'First test y-offset'
;	stop
;	endif

	; Benoit's numbers for 167
if Keyword_set(reverse) then begin
  a=[ 5.52795,    2.12085,-5.51346e-2,-1.42358e-3,-5.99070e-5,2.74837e-4]
  b=[-27.5392,-5.25057e-3,    2.07296, 5.00733e-5,-2.75358e-4,2.79281e-5]
  endif else begin
  a=[-2.13807,4.65917e-1,1.39155e-2, 1.81857e-4,3.46088e-6,-2.55412e-5]
  b=[ 13.3064,1.40022e-3,4.83860e-1,-6.71349e-6,3.34555e-5,-4.00316e-6]
  endelse

x_out=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in
y_out=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

	; Benoit's numbers for 171
if Keyword_set(reverse) then begin
  a=[ 19.6197,  1.83233e0,-4.84066e-2, 1.98617e-4, 1.74755e-4,-9.08746e-5]
  b=[-26.9996,-1.45481e-3,  2.07098e0,-1.31031e-5,-2.51590e-4, 8.34861e-5]
  endif else begin
  a=[-10.4412, 5.49372e-1,1.12657e-2,-4.25005e-5,-2.33647e-5, 1.47779e-5]
  b=[ 13.0706,-4.10468e-5,4.84251e-1, 2.12055e-6, 3.05264e-5,-1.05187e-5]
  endelse

x_out2=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in
y_out2=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

	; my simple linear fit
if keyword_set(reverse) then begin
  a=[17.4209,1.8508]
  b=[-26.625,2.0504]
  endif else begin
  a=[-9.2935,5.3946e-1]
  b=[12.9898,4.8763e-1]
  endelse

x_out3=a[0]+a[1]*x_in
y_out3=b[0]+b[1]*y_in

;==================================================================
; own data set for early 262

if keyword_set(reverse) then begin
  a=[ 13.73,1.944e-0,6.332e-3,-2.546e-4,-1.335e-4,-4.417e-4]
  b=[-26.38,2.062e-3,2.041e-0, 5.328e-6, 2.213e-4,-8.212e-5]
  endif else begin
  a=[-7.188,5.181e-1,-6.002e-4, 2.101e-5, 8.152e-6,6.614e-5]
  b=[ 12.90,1.920e-5, 4.884e-1,-1.864e-6,-2.571e-5,1.077e-5]
  endelse

x_out4=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in
y_out4=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

;=========== for day 262 own data set ===========

; linear simple
if keyword_set(reverse) then begin
  a=[ 7.868,1.931]
  b=[-25.67,2.042]
  endif else begin
  a=[-3.923,5.167e-1]
  b=[12.570,4.898e-1]
  endelse
x_out5=a[0]+a[1]*x_in
y_out5=b[0]+b[1]*y_in

;================= late 262

; multiple
if Keyword_set(reverse) then begin
  a=[ 11.07, 1.963e+0,-1.080e-1,-2.416e-4, 5.481e-4,-6.514e-5]
  b=[-25.97,-5.390e-3, 2.060e+0, 1.005e-5,-1.953e-4, 1.030e-4]
  endif else begin
  a=[-4.720, 5.041e-1,2.392e-2, 5.059e-5,-6.297e-5, 2.769e-6]
  b=[12.620, 1.018e-3,4.866e-1,-1.211e-6, 2.300e-5,-1.262e-5]
  endelse

x_out6=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in
y_out6=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

; =====================multiple with time_diff
;if Keyword_set(reverse) then begin
;  a=[ 8.328, 1.974e+0,-1.654e-4,-4.649e-4,-1.705e-2]
;  b=[-26.27, 2.064e+0,-1.905e-4, 3.986e-5]
;  endif else begin
;  a=[-3.947, 5.025e-1, 3.930e-5, 6.030e-5, 8.831e-3]
;  b=[12.730, 4.859e-1, 2.296e-5,-7.004e-6]
;  endelse
;x_out7=a[0]+a[1]*x_in+a[2]*x_in*x_in+a[3]*x_in*y_in+a[4]*time_diff
;y_out7=b[0]+b[1]*y_in+b[2]*y_in*y_in+b[3]*x_in*y_in

if Keyword_set(reverse) then begin
  a=[ 11.62, 1.966e+0,-1.062e-1,-2.627e-4, 5.725e-4,-1.273e-4,-1.656e-2]
  b=[-25.96,-5.922e-3, 2.060e+0, 1.522e-5,-1.939e-4, 1.052e-4]
  endif else begin
  a=[-5.015,5.033e-1,2.319e-2, 5.311e-5,-6.614e-5, 1.159e-5,8.537e-3]
  b=[13.620,1.020e-3,4.868e-1,-1.733e-6, 2.286e-5,-1.302e-5]		; +1 linear
  endelse

x_out7=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in+a[6]*time_diff
y_out7=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

; =====================multiple without time_diff day 297

if Keyword_set(reverse) then begin
  a=[ 1.459e+1, 1.940e-0,-8.173e-2,-3.858e-5, 2.421e-4,-7.776e-5]
  b=[-3.282e+1,-2.192e-2, 2.104e-0, 5.287e-5,-6.701e-4, 2.273e-4]
  endif else begin
  a=[-6.858e-0,5.153e-1,1.887e-2, 6.414e-6,-2.854e-5,6.338e-6]
  b=[ 1.562e+1,5.022e-3,4.801e-1,-7.626e-6, 7.984e-5,-2.933e-5]		; +1 linear
  endelse

x_out8=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in
y_out8=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

; ========== Benoits numbers without time_diff day 297

if Keyword_set(reverse) then begin
  a=[ 1.396178141E+01,  1.934406153E+00, -7.490980741E-02,  4.152494308E-05,  3.561179104E-04, -2.843714247E-04]
  b=[-3.320743878E+01, -1.645759484E-02,  2.104371628E+00,  3.876941810E-05, -5.799746646E-04,  1.541814094E-04]
  endif else begin
  a=[-6.551870810E+00,  5.167370811E-01,  1.539391281E-02, -1.393706709E-06, -4.071734980E-05,  3.600979320E-05]
  b=[ 1.582262681E+01,  3.562954764E-03,  4.792332740E-01, -4.877349250E-06,  6.868460454E-05, -1.898386371E-05]		
  endelse

x_out9=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in
y_out9=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

; =========== Benoits numbers with time_diff day 297

if Keyword_set(reverse) then begin
  a=[ 1.608235428E+01,  1.937864196E+00, -8.154214743E-02,  1.223735869E-05,  4.135799311E-04, -2.844679993E-04,  3.949420178E-02]
  b=[-3.304204266E+01, -1.618788149E-02,  2.103854332E+00,  3.648510483E-05, -5.754928584E-04,  1.541738771E-04,  3.080388231E-03]
  endif else begin
  a=[-7.649144176E+00,  5.163678585E-01,  1.677191927E-02,  9.938122200E-07, -4.898203245E-05,  3.624434318E-05,  2.055697548E-02]
  b=[ 1.574048749E+01,  3.535315617E-03,  4.793364283E-01, -4.698625157E-06,  6.806592970E-05, -1.896630585E-05,  1.538847187E-03]		
  endelse

x_out10=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in+a[6]*time_diff
y_out10=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in+b[6]*time_diff




end