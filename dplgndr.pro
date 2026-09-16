
function dplgndr,l,m,x

;
; Program to return the derivative of the given legendre polynomial.
;
;
;

if l eq 0 then return, 0

if l eq 1 then return, 1


plm=plgndr(l,m,x)


if l-m ge 1 then begin	; do derivative with varying order,
			; which allows l=m

	plml=plgndr(l-1,m,x)
	dplm=(l* z* plm - (l+m)* plml)/(z^2 - 1)

	return,dplm

endif else begin	;do derivative with varying degree (m) 
			;m has to be equal to l

	plmm=plgndr(l,m-1,x)
	dplm=((l + m) * (l-m + 1)* sqrt(x^2-1)*plmm - m*x*plm)/(z^2 -1)
	
	return,dplm
endelse



end
