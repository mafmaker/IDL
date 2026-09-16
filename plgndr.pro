
function plgndr,L,M,X

; Program to return associated legendre polynomial fgive n m and l
; satisfying 0 <= m <= l with -1<= x= mu = cos(theta) <= 1 
;
; Uses recursion relation to do it. Funtime.
;

pmm=1.

sizer=size(x) & sizer=sizer(0)
tester=x
if sizer gt 0 then begin
  finder=where(abs(tester) gt 1,findcount)
  if findcount gt 0 then begin
	print,'bad arguments in plgndr input'
	return,-999
  endif else tester=0

endif
   

if m lt 0 or m gt l or abs(tester) gt 1 then begin
	print,'bad arguments in plgndr input'
	return,-999
endif

if m gt 0 then begin			;do pmm
  somx2=sqrt((1.0-x)*(1.0+x))
  fact= 1.
  for i=1,m do begin
    pmm= pmm*(-fact * somx2)
    fact = fact + 2
  endfor
endif

if l eq m then return,pmm else begin

  pmmp1= x*(2*m+1)*pmm
  if l eq (m+1) then return,pmmp1 else begin
    for ll=m+2, l do begin
      pll=(x*(2*ll-1)*pmmp1-(ll+m-1)*pmm)/(ll-m)
      pmm=pmmp1
      pmmp1=pll
    endfor
    return,pll
  endelse

endelse


end