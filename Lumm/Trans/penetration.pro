pro penetration, _extra=extra, eflux=eflux, updn=updn, zrange=zrange, $
                 frange=frange, total=total, photo=photo, net=net

; make "penetration" plots: plot particle flux (up/down)
; as a fuction of altitude for selected energies.

; this needs some more work: allow to select the enery 
; levels where penetration plots are done, and label 
; the lines that are plotted.

@common

yrange = [min(altitude), max(altitude)]
if n_elements(zrange) eq 2 then if zrange[0] ne zrange[1] then yrange = zrange
xrange = [0.,0.]
if n_elements(frange) eq 2 then if frange[0] ne frange[1] then xrange = frange

if keyword_set(updn) then begin
   if !d.flags/256 then begin
      device, get_screen_size=screensize
      window, /free, xs=screensize(0)/2*w_scale, ys=screensize(1)*w_scale
   endif else $
        device, xsize=13, ysize=24, yoffset=2, xoffset=4.2

   p_save=!p.multi
   !p.multi=[0,1,2]

   ff=flux_down(1:nmax-1, *)
   if xrange[0] eq xrange[1] then xrange = [max(ff)/1e8, max(ff)]
   if keyword_set(eflux) then begin
      for m=0,mmax-1 do ff(*,m)=ff(*,m)*energy
      title='Energy Flux'
      unit='Energy Flux (eV cm!e-2!ns!e-1!n)'
   endif else begin
      title = 'Particle Flux'
      unit = 'Electron Flux (cm!e-2!ns!e-1!n)'
   endelse

   plot, ff(0,*), altitude, xtitle=unit, $
        ytitle='Altitude (km)', title='Downward '+title, $
        ysty=1, yrange=yrange, xrange=xrange, /xlog, _extra=extra
   for i=10, nmax-1, 10 do oplot, ff(i,*), altitude
   
   ff=flux_up(1:nmax-1, *)
   if xrange[0] eq xrange[1] then xrange = [max(ff)/1e8, max(ff)]
   if keyword_set(eflux) then begin
      for m=0,mmax-1 do ff(*,m)=ff(*,m)*energy
      title='Energy Flux'
      unit='Energy Flux (eV cm!e-2!ns!e-1!n)'
   endif else begin
      title = 'Particle Flux'
      unit = 'Electron Flux (cm!e-2!ns!e-1!n)'
   endelse

   plot, ff(0,*), altitude, xtitle=unit, $
        ytitle='Altitude (km)', title='Upward '+title, $
        ysty=1, yrange=yrange, xrange=xrange, /xlog, _extra=extra
   for i=10, nmax-1, 10 do oplot, ff(i,*), altitude
   !p.multi=p_save
endif else begin

   if keyword_set(total) then begin
      ff=flux_down(1:nmax-1, *)+flux_up(1:nmax-1, *)
      word="Total "
   endif

   if keyword_set(net) then begin
      ff=flux_down(1:nmax-1, *)-flux_up(1:nmax-1, *)
      word="Net "
   endif
   
   if keyword_set(photo) then begin
      ff=flux_extra(1:nmax-1, *)
      word="Internal Source "
   endif

   if keyword_set(eflux) then begin
      for m=0,mmax-1 do ff(*,m)=ff(*,m)*energy
      title='Energy Flux'
      unit='Energy Flux (eV cm!e-2!ns!e-1!n)'
   endif else begin
      title = 'Particle Flux'
      unit = 'Electron Flux (cm!e-2!ns!e-1!n)'
   endelse

   f = fltarr(mmax)
   for m=0,mmax-1 do f(m) = trap(ff(*,m), energy(1:nmax-1))

   if xrange[0] eq xrange[1] then xrange = [max(f)/1e8, max(f)]
   plot, f, altitude, title=word+title, xtit=unit, yrange=yrange, $
        /xlog, xrange=xrange
endelse

return
end
