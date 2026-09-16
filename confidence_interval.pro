pro confidence_interval,r,n,upper,lower
;
;  Program to determine 9*% confidence range of correlation coefficient
;  given # of samples and correlation coefficient
;
; r=correlation coefficient
; n=# of samples
; zr = z factor for r
; sig_zr = sigma for zr
; ZZ = factor which determines degree of confidence
; zp = population correlation coefficient
; zpmax = maximum correlation coefficient for given population/confidence

;r=-.39
;n=11.

n=float(n)
zr=0.5 * (alog(1. + r) - alog(1.-r))
sig_zr=((n-3)^(-1))

ZZ=1.65                                 ;for +-95% interval

zpmax= zr - sig_zr*ZZ
zpmin= zr + sig_zr*ZZ

;---look at zpmax first
b=exp(2*zpmax)
rmax=(b-1.)/(1.+b)

;---next do zpmin
b=exp(2*zpmin)
rmin=(b-1.)/(1.+b)

;---that's it, it doesn't work!!!
lower=rmax
upper=rmin

return
end