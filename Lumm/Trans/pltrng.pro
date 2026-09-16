pro pltrng, file

openr, 10, file

message=string(0,format='(i120)')
readf, 10, message
print, message

mmax=0
jmax=0
epeak=0.
qtot=0.
flux=0.
flux2=0.
readf, 10, mmax, jmax, epeak, qtot, flux, flux2

dummi=fltarr(4+2*jmax)
x=fltarr(mmax)
y=x
for m=0,mmax-1 do begin
  readf, 10, dummi
  x(m)=dummi(2+2*jmax)/0.981
  y(m)=dummi(3+2*jmax)/flux
endfor
close, 10

; plot, x, y, title="Energy Deposition as Function of Range", $
;	xtitle="range (gr/cm!E2!N)", ytitle="energy deposition (eV/cm/s)"
y=y/max(y)
plot, x, y, xtitle="Fractional Range (gr cm!e-2!n)", ytitle="Ionization Rate (arbitrary units)", $
	xrange=[0,2e-5], yrange=[0,1.1]

dx=x(0:mmax-2)-x(1:mmax-1)
dy=y(0:mmax-2)-y(1:mmax-1)
dydx=dy/dx
nx=min(where(dydx eq min(dydx(4:mmax-5))))
range=fltarr(5)
for i=0,4 do begin
  i1=nx-4+i
  i2=i1+4
  range(i)=(x(i1)*y(i2)-x(i2)*y(i1))/(y(i2)-y(i1))
endfor
rr=total(range)/5.

oplot, [2*x(nx)-rr,rr], [2*y(nx),0.], line=2

; add some points from Barrett and Hays (2keV)
x=[0.1, 3.2, 6.4, 9.1, 12.9, 16.0]*1e-6
x=x*1.77/1.61			; renormalize Barrett & Hays ??
y=[4.5, 6.2, 6.1, 4.5, 2.2, 0.5]
y=y/max(y+.2)
oplot, x, y, psym=1, symsize=2

stop
end

