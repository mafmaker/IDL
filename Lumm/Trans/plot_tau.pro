pro plot_tau, path

; draw colored contour lines of total scattering depth as a function
; of energy and altitude, and of thickness of layes in terms of 
; scattering depth

; read data file from trans
file=path+"/TAUDAT"
openr, unit, file, /get_lun
 
mmax=0L
nmax=0L
readf, unit, nmax, mmax
z=fltarr(mmax)
readf, unit, z
work=fltarr(mmax+1, nmax)
readf, unit, work
close, unit
energy=rotate(reform(work(0,*)),2)
tau=rotate(reform(work(1:mmax,*)),1)

; set up plot arrays
ttau=alog10(tau > (max(tau)*1e-5))
nn=size(ttau)
nmax=nn(1)
mmax=nn(2)

e=fltarr(nmax+1)
e(1)=alog10(energy(1:nmax-1))
e(0)=e(1)
e(nmax)=e(nmax-1)

a=fltarr(mmax+2)
a(1)=z
a(0)=a(1)
a(mmax+1)=a(mmax)

f=replicate(min(ttau), nmax+1, mmax+2)
f(1,1)=ttau(1:nmax-1,*)

fmin=long(2*(min(f)+0.5))*0.5   ; lowest contour level
fmax=long(2*max(f))*0.5         ; highest contour level
nlevels=(fmax-fmin)/0.5         ; number of levels
index=findgen(nlevels+2)*!d.n_colors/(nlevels+2)        ; define colour index
index=index+index(1)
levels=rotate(fmax-findgen(nlevels+1)*0.5,2)    ; make (and label) contour lines at multiples of 1/2

contour, f, e, a, levels=levels, /follow, xstyle=5, $
	xtitle="Altitude (km)", ytitle="log Energy (eV)", ysty=5, $
	title="Contours of log(tau)", path_filename='lines.dat', $
	xrange=[e(1),e(nmax-1)], yrange=[a(mmax),a(1)]
polycontour, "lines.dat", color_index=index, /delete
contour, f, e, a, levels=levels, /noerase, xrange=[e(1),e(nmax-1)], $
	 yrange=[a(mmax),a(1)], xstyle=5, ystyle=5, /follow
plot_oi, energy(1:nmax-1), z, /nodata, /noerase, xstyle=1, ystyle=1, $
	 xtitle="Energy (eV)", ytitle="Altitude (km)"

; now make plots of layer thickness
window, /free
dtau=tau(*,1:mmax-1) - tau(*,0:mmax-2)
dtau=alog10(dtau)

; set up plot arrays (same thing over again)
a=fltarr(mmax+1)
a(1)=z
a(0)=a(1)
a(mmax)=a(mmax-1)

f=replicate(min(dtau), nmax+1, mmax+1)
f(1,1)=dtau(1:nmax-1,*)

fmin=long(2*(min(f)+0.5))*0.5   ; lowest contour level
fmax=long(2*max(f))*0.5         ; highest contour level
nlevels=(fmax-fmin)/0.5         ; number of levels
index=findgen(nlevels+2)*!d.n_colors/(nlevels+2)        ; define colour index
index=index+index(1)
levels=rotate(fmax-findgen(nlevels+1)*0.5,2)    ; make (and label) contour lines at multiples of 1/2

contour, f, e, a, levels=levels, /follow, xstyle=5, $
	xtitle="Altitude (km)", ytitle="log Energy (eV)", ysty=5, $
	title="Contours of log(tau)", path_filename='lines.dat', $
	xrange=[e(1),e(nmax-1)], yrange=[a(mmax-1),a(1)]
polycontour, "lines.dat", color_index=index, /delete
contour, f, e, a, levels=levels, /noerase, xrange=[e(1),e(nmax-1)], $
	yrange=[a(mmax-1),a(1)], xstyle=5, ystyle=5, /follow
plot_oi, energy(1:nmax-1), z, /nodata, /noerase, xstyle=1, ystyle=1, $
	xtitle="Energy (eV)", ytitle="Altitude (km)"
						   
stop
end

