pro flx_cont, _extra=extra, energyflux=energyflux, total=total, up=up, $
              photo=photo, surf=surf, xrange=xrange, frange=frange, $
              yrange=yrange, net=net

; make contour plots of the particle flux 

@common

ysize = [12., 13.5]
win_size = 512
if !p.multi(1) ge 1 then begin
   if !d.flags/256 then begin
      device, get_screen_size=screensize
      win_size = screensize(1)*w_scale
   endif else ysize=[23., 2.5]
endif
if !p.multi(0) eq 0 then $
     if !d.flags/256 then window, ys=win_size, /free  $
                     else device, ysize=ysize[0], yoffset=ysize[1]

if xrange(0) ne xrange(1) then  $
     ix = where(xrange(0) le energy and energy le xrange(1)) else  $
     ix = indgen(n_elements(energy))
if yrange(0) ne yrange(1) then  $
     iy = where(yrange(0) le altitude and altitude le yrange(1)) else  $
     iy = indgen(n_elements(altitude))

f=flux_down(min(ix):max(ix),min(iy):max(iy))
word="Downward "

if keyword_set(total) then begin
   f=flux_down(min(ix):max(ix),min(iy):max(iy))+ $
        flux_up(min(ix):max(ix),min(iy):max(iy))
  word="Total "
endif

if keyword_set(net) then begin
   f=abs(flux_down(min(ix):max(ix),min(iy):max(iy))- $
        flux_up(min(ix):max(ix),min(iy):max(iy)))
  word="Net "
endif

if keyword_set(up) then begin
  f=flux_up(min(ix):max(ix),min(iy):max(iy))
  word="Upward "
endif

if keyword_set(photo) then begin
  f=flux_extra(min(ix):max(ix),min(iy):max(iy))
  word="Internal Source "
endif

title=word+"Particle Flux (log(flux eV!e-1!ncm!e-2!ns!e-1!n))"
unit=word+"Particle Flux (eV!e-1!ncm!e-2!ns!e-1!n))"

if keyword_set(energyflux) then begin
  for m=0,mmax-1 do f(*,m)=f(*,m)*energy
  title=word+"Energy Flux (log(flux cm!e-2!ns!e-1!n))"
  unit=word+"Energy Flux (cm!e-2!ns!e-1!n))"
endif

if n_elements(frange) eq 2 then begin
   if frange[0] eq frange[1] then begin
      fmax = max(f)
      fmin = fmax*1e-8
   endif else begin
      fmin = frange[0]
      fmax = frange[1]
   endelse
endif else begin
   fmax = max(f)
   fmin = fmax*1e-8
endelse

if keyword_set(surf) then begin
;   xsurf, (f > fmin), energy(ix), altitude(iy), title=title, $
;	 xstyle=1, ystyle=1, /xty, /zlog,  $
;	 xtitle="Energy (eV)", ytitle="Altitude (km)", _extra=extra
   image3, ((f > fmin) < fmax), energy(ix), altitude(iy),  $
        unit=unit, title=title, $
	 xstyle=1, ystyle=1, /xlog, /zlog, zmin=fmin, zmax=fmax, $
	 xtitle="Energy (eV)", ytitle="Altitude (km)", _extra=extra
endif else begin 
   f=alog10((f > fmin) < fmax)
   if min(f) ge max(f) then begin
      msg_out, 'No flux between minimum and maximum:'+ $
           strcompress(fmin)+strcompress(10^max(f))
      return
   endif

   fmin=long(2*(min(f)+0.5))*0.5 ; lowest contour level
   fmax=long(2*max(f))*0.5      ; highest contour level
   nlevels=min([(fmax-fmin)/0.5, 28]) ; number of levels
   index=findgen(nlevels+2)*!d.n_colors/(nlevels+2) ; define colour index
   index=index+index(1)
; make (and label) contour lines at multiples of 1/2
   levels=rotate(fmax-findgen(nlevels+1)*0.5,2)

   contour, f, energy(ix), altitude(iy), title=title, $
        levels=levels, xstyle=1, ystyle=1, /xty, /fill, $
        xtitle="Energy (eV)", ytitle="Altitude (km)", _extra=extra
   contour, f, energy(ix), altitude(iy), levels=levels, xstyle=4,  $
        ystyle=4, /xty, /follow, /over
endelse

return
end

