pro set_intensity_event, event

@common
@common_w

; the DONE button is the only one that can create an event.  Once an
; event is encountered, read the buttons and return to the main panel.

widget_control, event.id, get_uvalue=target

case target of
   'DONE': begin
       widget_control, b_alti, get_value=alt
       widget_control, b_emax, get_value=emax
       widget_control, b_emin, get_value=emin
       widget_control, b_imax, get_value=imax
       widget_control, b_imin, get_value=imin
       widget_control, b_npowers, get_value=npowers
       if emin le 0 then emin=mmin(energy, above=0)
       if emax le emin then emax=max(energy)
       intensity_param.alt=alt
       intensity_param.erange(0)=emin
       intensity_param.erange(1)=emax
       intensity_param.irange(0)=imin
       intensity_param.irange(1)=imax
       if npowers ne alog10(imax)-alog10(imin) and npowers gt 0 then $
         intensity_param.irange(0)=10^(alog10(imax)-npowers)
       widget_control, event.top, /destroy
   end
endcase
return
end



pro set_intensity

@common
@common_w

alt=intensity_param.alt
emax=intensity_param.erange(1)
emin=intensity_param.erange(0)
imax=intensity_param.irange(1)
imin=intensity_param.irange(0)
npowers=0 ;alog10(imax)-alog10(imin)

s1=widget_base(/column, title='Set Parameters', $
               xoffset=300, yoffset=200)

b_alti=cw_field(s1, title='     Altitude (km) =', value=alt, /float)
b_emax=cw_field(s1, title='   Energy max (eV) =', value=emax, /float)
b_emin=cw_field(s1, title='   Energy min (eV) =', value=emin, /float)
b_imax=cw_field(s1, title='Intensity max (eV) =', value=imax, /float)
b_imin=cw_field(s1, title='Intensity min (eV) =', value=imin, /float)
b_npowers=cw_field(s1, title='number of decades =', value=npowers, $
          /int)
b_done=widget_button(s1, value='DONE', uvalue='DONE')

widget_control, s1, /realize
xmanager, 'set_intensity', s1, group_leader=main_base, /modal

return
end
