pro density, npowers=npowers, _extra=extra

; This program produces plots of the neutral and electron density
; versus altitude.  Electron temperature is also plotted.

@common

if !d.flags/256 then begin
   device, get_screen_size=screensize
   window, /free, xs=screensize(0)/2*w_scale, ys=screensize(1)*w_scale
endif else $
   device, xsize=13, ysize=24, yoffset=2, xoffset=4.2

p_save=!p.multi
!p.multi=[0,1,2]

if not keyword_set(npowers) then npowers=10

dmax=max(n2)
dmin=dmax/10.^(npowers-1)

if jmax ge 1 then $
plot_oi, n2, altitude, title="Neutral Density", xtitle="Density (cm!e-3!n)", $
	 ytitle="Altitude (km)", ysty=16, xrange=[dmin,dmax], _extra=extra

if jmax ge 2 then oplot, o2, altitude
if jmax ge 3 then oplot, o, altitude

oplot, n_e, altitude, line=2

plot, t_e, altitude, title="Electron and Neutral Temperature", $
      xtitle="Temperature (K)", xr=[min([t_n,t_e]),max([t_n,t_e])], $
      ytitle="Altitude (km)", ysty=16, line=2, _extra=extra
oplot, t_n, altitude

!p.multi=p_save

return
end
