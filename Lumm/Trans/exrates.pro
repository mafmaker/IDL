pro exrates, npowers=npowers, _extra=extra

; plot the excitation rates as a function of altitude for all states
; and all available species.

@common
@common_c

if not keyword_set(npowers) then npowers=6

if !d.flags/256 then begin
   device, get_screen_size=screensize
   window, /free, xs=screensize(0)/2*w_scale, ys=screensize(1)*w_scale
endif else $
   device, xsize=13, ysize=24, yoffset=2, xoffset=4.2

p_save=!p.multi
!p.multi=[0,2,2]

if jmax ge 1 then begin
  rmin=max(exr_n2)/10.^(npowers-1)
  rmax=max(exr_n2)
  rmin=rmax/1.e3
  if pick_n2 ge 0 then begin
     line = replicate(1, ex_states(0))
     line(pick_n2) = 0
  endif else line = intarr(ex_states(0))
;  plot_oi, exr_n2(*,0), altitude, title="N!i2!n excitation rates", $
  plot, exr_n2(*,0), altitude, title="N!i2!n ", $;!Cexcitation rates", $
	   xtitle="Excitation rate !C(cm!e-3!n s!e-1!n)", $
           ytitle="Altitude (km)", xsty=1., xticks=3., $
    xrange=[rmin,rmax], ystyle=16, line=line[0], _extra=extra, $
    xtickformat='log_label2'
  
  for j=1,ex_states(0)-1 do oplot, exr_n2(*,j), altitude, line=line[j]
  if pick_n2 ge 0 then xyouts, !x.window(1)-float(!d.x_ch_size)/!d.x_size*9, $
       !y.window(1)*0.99-float(!d.y_ch_size)/!d.y_size, states_n2(pick_n2), $
       /norm
endif

if jmax ge 2 then begin
  rmin=max(exr_o2)/10.^(npowers-1)
  rmax=max(exr_o2)
  rmin=rmax/1.e3
  if pick_o2 ge 0 then begin
     line = replicate(1, ex_states(0))
     line(pick_o2) = 0
  endif else line = intarr(ex_states(0))
;  plot_oi, exr_o2(*,0), altitude, title="O!i2!n excitation rates", $
  plot, exr_o2(*,0), altitude, title="O!i2!n ", $;!Cexcitation rates", $
	   xtitle="Excitation rate !C(cm!e-3!ns!e-1!n)", $
           ytitle="Altitude (km)", xsty=1., xticks=3., $
    xrange=[rmin,rmax], ystyle=16, line=line[0], _extra=extra, $
    xtickformat='log_label2'
  
  for j=1,ex_states(1)-1 do oplot, exr_o2(*,j), altitude, line=line[j]
  if pick_o2 ge 0 then xyouts, !x.window(1)-float(!d.x_ch_size)/!d.x_size*9, $
       !y.window(1)*0.99-float(!d.y_ch_size)/!d.y_size, states_o2(pick_o2), $
       /norm
endif

if jmax ge 3 then begin
  rmin=max(exr_o)/10.^(npowers-1)
  rmax=max(exr_o)
  rmin=rmax/1.e3
  if pick_o ge 0 then begin
     line = replicate(1, ex_states(0))
     line(pick_o) = 0
  endif else line = intarr(ex_states(0))
;  plot_oi, exr_o(*,0), altitude, title="O excitation rates", $
  plot, exr_o(*,0), altitude, title="O ", $;!Cexcitation rates", $
	   xtitle="Excitation rate !C(cm!e-3!ns!e-1!n)", $
           ytitle="Altitude (km)", xsty=1., xticks=3., $
    xrange=[rmin,rmax], ystyle=16, line=line[0], _extra=extra, $
    xtickformat='log_label2'
  
  for j=1,ex_states(2)-1 do oplot, exr_o(*,j), altitude, line=line[j]
  if pick_o ge 0 then xyouts, !x.window(1)-float(!d.x_ch_size)/!d.x_size*9, $
       !y.window(1)*0.99-float(!d.y_ch_size)/!d.y_size, states_o(pick_o), $
       /norm
endif

!p.multi=p_save

return
end
