pro convert_si12_si13_new,x_in,y_in,x_out,y_out,x_out2,y_out2,x_out3,y_out3,$
	x_out4,y_out4,x_out5,y_out5,x_out6,y_out6,x_out7,y_out7,$
	x_out8,y_out8,x_out9,y_out9,x_out10,y_out10,time_diff,$
	reverse=reverse

;if keyword_set(reverse) then begin
;	print,'First test y-offset'
;	stop
;	endif

	; Benoit's numbers for 167
if Keyword_set(reverse) then begin
  a=[-16.227, 1.09675e-0,1.56025e-1,1.50025e-4, 2.33251e-4,-1.74921e-3]
  b=[6.51154,-4.80718e-2,9.48951e-1,1.90200e-4,-2.76929e-4, 3.43122e-4]
  endif else begin
  a=[15.7724, 9.02708e-1,-1.45256e-1,-1.67085e-4,-2.11743e-4, 1.71630e-3]
  b=[-6.34791,4.62675e-2, 1.04654e-0,-1.83678e-4, 3.23387e-4,-3.59025e-4]
  endelse
  a=a-a
  b=b-b

x_out=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in
y_out=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

	; Benoit's number sfor day 171
if Keyword_set(reverse) then begin
  a=[-8.368,1.012e-0,3.764e-3,-2.889e-6, 6.008e-5, 5.313e-5]
  b=[ 4.431,2.557e-3,9.456e-1,-4.785e-5, 1.258e-6, 6.593e-5]
  endif else begin
  a=[ 8.319, 9.884e-1,-4.239e-3, 1.699e-6,-6.135e-5,-5.139e-5]
  b=[-4.710,-1.485e-3, 1.058e-0, 4.504e-5,-2.557e-5,-5.957e-5]
  endelse

x_out2=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in
y_out2=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

	; simple linear
if keyword_set(reverse) then begin
  a=[-100,0.]
  b=[-100,0.]
  endif else begin
  a=[-100,0.]
  b=[-100,0.]
  endelse
  a=a-a
  b=b-b

x_out3=a[0]+a[1]*x_in
y_out3=b[0]+b[1]*y_in

;==================================================================
; own data set for early 262

if keyword_set(reverse) then begin
  a=[-8.367,1.015e-0,-9.028e-3, 1.376e-5, 1.864e-4,4.124e-5]
  b=[ 4.232,1.402e-3, 9.630e-1,-3.946e-6,-1.445e-4,2.838e-5]
  endif else begin
  a=[ 8.182, 9.857e-1,1.139e-2,-1.762e-5,-2.079e-4,-4.158e-5]
  b=[-4.398,-1.081e-3,1.036e-0, 2.930e-6, 1.709e-4,-3.155e-5]
  endelse

x_out4=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in
y_out4=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

;=========== for day 262 own data set, late data set ===========

; linear simple
if keyword_set(reverse) then begin
  a=[-100,0.]
  b=[-100,0.]
  endif else begin
  a=[-100,0.]
  b=[-100,0.]
  endelse
  a=a-a
  b=b-b
  
x_out5=a[0]+a[1]*x_in
y_out5=b[0]+b[1]*y_in

	; multiple
if Keyword_set(reverse) then begin
  a=[-1.928e-0,9.579e-1,2.351e-2, 1.916e-4,-9.884e-5, 3.680e-5]
  b=[ 4.464e-0,1.565e-3,9.468e-1,-1.185e-5, 7.701e-5,-1.276e-5]
  endif else begin
  a=[ 2.379e-0, 1.033e-0,-2.648e-2,-1.332e-4, 1.294e-4,-5.808e-5]
  b=[-4.710e-0,-1.848e-3, 1.057e-0, 1.398e-5,-8.735e-5, 1.406e-5]
  endelse

x_out6=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in
y_out6=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

; =====================multiple with time_diff, late 262
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
  a=[-1.935,9.586e-1,2.379e-2, 1.872e-4,-9.790e-5, 3.421e-5,-1.225e-2]
  b=[ 4.464,1.565e-3,9.468e-1,-1.185e-5, 7.701e-5,-1.276e-5]
  endif else begin
  a=[ 2.382, 1.033e-0,-2.671e-2,-1.286e-4, 1.282e-4,-5.573e-5,1.250e-2]
  b=[-4.710,-1.848e-3, 1.057e-0, 1.398e-5,-8.735e-5, 1.406e-5]		; +1 linear
  endelse

x_out7=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in+a[6]*time_diff
y_out7=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in


; =====================multiple without time_diff, day 297

if Keyword_set(reverse) then begin
  a=[-4.040e-0,9.922e-1,2.124e-2,-4.076e-5,-7.407e-5, 4.339e-5]
  b=[ 4.512e-0,5.689e-3,9.372e-1,-8.612e-8, 1.710e-4,-5.525e-5]
  endif else begin
  a=[ 4.157e-0, 1.008e-0,-2.270e-2, 4.422e-5, 8.088e-5,-5.554e-5]
  b=[-4.850e-0,-6.003e-3, 1.069e-0,-2.218e-6,-2.006e-4, 6.033e-5]		; +1 linear
  endelse

x_out8=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in
y_out8=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

; ======= Benoits numbers without time_diff, day 297

if Keyword_set(reverse) then begin
  a=[-4.011370816E+00,  9.854307970E-01,  2.868849415E-02,  3.305237924E-06, -1.797748422E-04,  8.953062883E-05]
  b=[ 4.505339574E+00,  4.705074233E-03,  9.408001904E-01, -4.625038159E-06,  1.043411293E-04, -3.890384411E-05]
  endif else begin
  a=[ 4.213585380E+00,  1.015010859E+00, -3.256265606E-02, -2.232000607E-06,  2.015347503E-04, -9.727485845E-05]
  b=[-4.796946690E+00, -5.194895076E-03,  1.063738053E+00,  4.773798241E-06, -1.198095894E-04,  4.444760266E-05]
  endelse

x_out9=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in
y_out9=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in

; ======= Benoits numbers with time_diff, day 297

if Keyword_set(reverse) then begin
  a=[-4.000247327E+00,  9.852583094E-01,  2.884431076E-02,  3.915983865E-06, -1.799025505E-04,  8.659524675E-05, -5.799085429E-03]
  b=[ 4.504143196E+00,  4.723625993E-03,  9.407834317E-01, -4.690726463E-06,  1.043548648E-04, -3.858813141E-05,  6.237160877E-04]
  endif else begin
  a=[ 4.203500116E+00,  1.015190302E+00, -3.273648828E-02, -3.003368017E-06,  2.017226275E-04, -9.405657401E-05, -5.843157005E-03]
  b=[-4.795791210E+00, -5.215454042E-03,  1.063757969E+00,  4.862174630E-06, -1.198311147E-04,  4.407888037E-05,  6.694567425E-04]
  endelse

x_out10=a[0]+a[1]*x_in+a[2]*y_in+a[3]*x_in*x_in+a[4]*y_in*y_in+a[5]*x_in*y_in+a[6]*time_diff
y_out10=b[0]+b[1]*x_in+b[2]*y_in+b[3]*x_in*x_in+b[4]*y_in*y_in+b[5]*x_in*y_in+b[6]*time_diff


end