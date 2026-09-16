pro engdep, total_dep, npowers=npowers, only_total=only_total, _extra=extra

; plot the energy deposition profiles for all states.
; return the total energy deposition in total_dep

@common 

if not keyword_set(npowers) then npowers=7

p_save=!p.multi
if not keyword_set(only_total) then begin
    !p.multi=[0,2,2]
    if !d.flags/256 then begin
        device, get_screen_size=screensize
        window, /free, xs=screensize(0)/2*w_scale, ys=screensize(1)*w_scale
    endif else $
      device, xsize=13, ysize=24, yoffset=2, xoffset=4.2
endif else if !d.flags/256 then window, /free

total_dep=dep_electron
if jmax ge 1 then begin		; do we have at least data for N2?
  rmin=max(edep(*,0))/10.^(npowers-1)
  rmax=max(edep(*,0))
  rmin=rmax/1.e3
  if not keyword_set(only_total) then begin
    plot_oi, edep(*,0), altitude, $
;    plot, edep(*,0), altitude, $
           title="N2", $;!C Energy Deposition Rates", $
	   xtitle="Energy Deposition Rate !C(eV cm!e-3!n s!e-1!n)", $
           ytitle="Altitude (km)", _extra=extra, $
	   xrange=[rmin,rmax], xsty=1., xticks=3., xtickformat='log_label'
    for j=0,ex_states(0)-1 do oplot, exdep_n2(*,j), altitude, line=1
    for j=0,ion_states(0)-1 do oplot, iondep_n2(*,j), altitude, line=2
  endif
  total_dep=total_dep+edep(*,0)
endif

if jmax ge 2 then begin		; do we also have data for O2?
  rmin=max(edep(*,1))/10.^(npowers-1)
  rmax=max(edep(*,1))
  rmin=rmax/1.e3
  if not keyword_set(only_total) then begin
    plot_oi, edep(*,1), altitude, $
;    plot, edep(*,1), altitude, $
            title="O2", $; !CEnergy Deposition Rates", $
	   xtitle="Energy Deposition Rate !C(eV cm!e-3!n s!e-1!n)", $
           ytitle="Altitude (km)", _extra=extra, $
	   xrange=[rmin,rmax], xsty=1., xticks=3., xtickformat='log_label'
    for j=0,ex_states(1)-1 do oplot, exdep_o2(*,j), altitude, line=1
    for j=0,ion_states(1)-1 do oplot, iondep_o2(*,j), altitude, line=2
  endif
  total_dep=total_dep+edep(*,1)
endif

if jmax ge 3 then begin		; do we also have data for atomic O?
  rmin=max(edep(*,2))/10.^(npowers-1)
  rmax=max(edep(*,2))
  rmin=rmax/1.e3
  if not keyword_set(only_total) then begin
    plot_oi, edep(*,2), altitude, $
;    plot, edep(*,2), altitude, $
           title="O ", $;!CEnergy Deposition Rates", $
	   xtitle="Energy Deposition Rate !C(eV cm!e-3!n s!e-1!n)", $
           ytitle="Altitude (km)", _extra=extra, $
	   xrange=[rmin,rmax], xsty=1., xticks=3., xtickformat='log_label'
    for j=0,ex_states(2)-1 do oplot, exdep_o(*,j), altitude, line=1
    for j=0,ion_states(2)-1 do oplot, iondep_o(*,j), altitude, line=2
  endif
  total_dep=total_dep+edep(*,2)
endif

rmin=max(total_dep)/10.^(npowers-1)
rmax=max(total_dep)
rmin=rmax/1.e3
plot_oi, total_dep, altitude, title='Total Energy Deposition Rate', $
;plot, total_dep, altitude, title='Total ', $;!CEnergy Deposition Rate', $
         xtitle="Energy Deposition Rate !C(eV cm!e-3!n s!e-1!n)", $
         ytitle="Altitude (km)", _extra=extra, $
	 xrange=[rmin,rmax], xsty=1., xticks=3., xtickformat='log_label'
oplot, dep_electron, altitude, line=1
for j=0,jmax-1 do oplot, edep(*,j), altitude, line=2

!p.multi=p_save

return
end
