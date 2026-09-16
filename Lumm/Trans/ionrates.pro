pro ionrates, npowers=npowers, _extra=extra

; plot the ionization rates as a function of altitude for all states
; and all available species.

;common grid, energy, altitude, angle, mu_weight
;common header, messag, crs_file, nmax, mmax, kmax, jmax, ex_states, ion_states
;common excitation, exr_n2, exr_o2, exr_o, ion_n2, ion_o2, ion_o
@common

if !d.flags/256 then begin
   device, get_screen_size=screensize
   window, /free, xs=screensize(0)/2*w_scale, ys=screensize(1)*w_scale
endif else $
   device, xsize=13, ysize=24, yoffset=2, xoffset=4.2

p_save=!p.multi
!p.multi=[0,2,2]
if not keyword_set(npowers) then npowers=5

tot_ion=fltarr(mmax,4)
if jmax ge 1 then begin
  rr=fltarr(mmax)
  for m=0,mmax-1 do rr(m)=total(ion_n2(m,*))
  tot_ion(*,1)=rr
  tot_ion(*,0)=rr
  rmin=max(rr)/10.^(npowers-1)
  rmax=max(rr)
  rmin=rmax/1.e3
;  plot_oi, rr, altitude, title="N!i2!n ionization rates", $
  plot, rr, altitude, title="N!i2!n", $; !Cionization rates", $
	   xtitle="Ionization rate !C(cm!e-3!ns!e-1!n)", $
           ytitle="Altitude (km)", xsty=1.,xticks=3., $
	   xrange=[rmin,rmax], ystyle=16, _extra=extra, $
           xtickformat='log_label2'
  for j=1,ion_states(0) do oplot, ion_n2(*,j-1), altitude, line=j
endif

if jmax ge 2 then begin
  rr=fltarr(mmax)
  for m=0,mmax-1 do rr(m)=total(ion_o2(m,*))
  ;window, /free
  tot_ion(*,2)=rr
  tot_ion(*,0)=tot_ion(*,0)+rr
  rmin=max(rr)/10.^(npowers-1)
  rmax=max(rr)
  rmin=rmax/1.e3
;  plot_oi, rr, altitude, title="O!i2!n ionization rates", $
  plot, rr, altitude, title="O!i2!n", $; !Cionization rates", $
	   xtitle="Ionization rate !C(cm!e-3!ns!e-1!n)", $    
           ytitle="Altitude (km)", xsty=1.,xticks=3., $
	   xrange=[rmin,rmax], ystyle=16, _extra=extra, $
           xtickformat='log_label2'
  for j=1,ion_states(1) do oplot, ion_o2(*,j-1), altitude, line=j
endif

if jmax ge 3 then begin
  rr=fltarr(mmax)
  for m=0,mmax-1 do rr(m)=total(ion_o(m,*))
  tot_ion(*,3)=rr
  tot_ion(*,0)=tot_ion(*,0)+rr
  ;window, /free
  rmin=max(rr)/10.^(npowers-1)
  rmax=max(rr)
  rmin=rmax/1.e3
;  plot_oi, rr, altitude, title="O ionization rates", $
  plot, rr, altitude, title="O", $; !Cionization rates", $
	   xtitle="Ionization rate !C(cm!e-3!ns!e-1!n)", $    
           ytitle="Altitude (km)", xsty=1.,xticks=3., $
	   xrange=[rmin,rmax], ystyle=16, _extra=extra, $
           xtickformat='log_label2'
  for j=1,ion_states(2) do oplot, ion_o(*,j-1), altitude, line=j
endif

;window, /free
rmin=max(tot_ion)/10.^(npowers-1)
rmax=max(tot_ion)
rmin=rmax/1.e3
;plot_oi, tot_ion(*,0), altitude, title="Total ionization rates", $
plot, tot_ion(*,0), altitude, title="Total", $; !Cionization rates", $
	 xtitle="Ionization rate !C(cm!e-3!ns!e-1!n)", $    
         ytitle="Altitude (km)", xsty=1., xticks=3.,$
	 xrange=[rmin,rmax], ystyle=16, _extra=extra, $
        xtickformat='log_label2'
for j=1,jmax do oplot, tot_ion(*,j), altitude, line=j

!p.multi=p_save

return
end
