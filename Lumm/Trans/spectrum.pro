pro spectrum, emin=emin, emax=emax, fmin=fmin, fmax=fmax, count=count, $
              index=index 

; make "spectrum" plots: plot particle flux (up/down)
; as a function of energy for selected altitudes.

; this needs some more work: allow to select the altitude 
; levels where spectrum plots are done, and label 
; the lines that are plotted.

@common

if !d.flags/256 then begin
   device, get_screen_size=screensize
   window, /free, xs=screensize(0)/2*w_scale, ys=screensize(1)*w_scale
endif else $
   device, xsize=13, ysize=24, yoffset=2, xoffset=4.2

p_save=!p.multi
!p.multi=[0,1,2]

if not keyword_set(count) then count=10
if keyword_set(index) then begin
  max_count=n_elements(index)-1
  count=1
endif else begin
  max_count=mmax-1
  index=indgen(mmax)
endelse
steps=max_count/(count-1)

ff=flux_down  ;(1:nmax-1, *)
ee=energy  ;(1:nmax-1)
if not keyword_set(emin) then emin=.3
if not keyword_set(emax) then emax=max(ee)
if not keyword_set(fmin) then fmin=mmin(ff, above=0)
if not keyword_set(fmax) then fmax=max(ff)
print, 'fmin, fmax', fmin, fmax

nmin=where(abs(ee-emin) eq min(abs(ee-emin)))
nmin=nmin(0)
for i=0,nmin do begin
  ff(i,*)=ff(nmin,*)
  ee(i)=ee(nmin)
endfor

plot_oo, ee, ff(*,index(0)), xtitle="Energy (eV)", $
  ytitle="Particle Flux (eV!e-1!ncm!e-2!ns!e-1!n)", $ 
  title="Downward Particle Flux", xrange=[emin, emax], $
  yrange=[fmin, fmax]
for i=steps, max_count, steps do oplot, ee, ff(*,index(i))
for i=0, max_count, steps do xyouts, emin*1.2, ff(nmin,index(i)), $
                               strcompress(fix(altitude(index(i))))

ff=flux_up  ;(1:nmax-1, *)
for i=0,nmin do ff(i,*)=ff(nmin,*)

plot_oo, ee, ff(*,index(0)), xtitle="Energy (eV)", $
  ytitle="Particle Flux (eV!e-1!ncm!e-2!ns!e-1!n)", $
  title="Upward Particle Flux", xrange=[emin, emax], $
  yrange=[fmin, fmax]
for i=steps, max_count, steps do oplot, ee, ff(*,index(i))
for i=0, max_count, steps do xyouts, emin*1.2, ff(nmin,index(i)), $
                               strcompress(fix(altitude(index(i))))

!p.multi=p_save

return
end
