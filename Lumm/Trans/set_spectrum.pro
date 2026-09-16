pro set_spectrum_event, event

@common
@common_w

; the DONE button is the only one that can create an event.  Once an
; event is encountered, read the buttons and return to the main panel.

widget_control, b_emax, get_value=emax
widget_control, b_emin, get_value=emin
widget_control, b_fmax, get_value=fmax
widget_control, b_fmin, get_value=fmin
widget_control, b_alti, get_value=count
spectrum_param.emin=emin
spectrum_param.emax=emax
spectrum_param.fmin=fmin
spectrum_param.fmax=fmax
spectrum_param.count=count

widget_control, event.top, /destroy

return
end



pro set_spectrum

@common
@common_w

emax=spectrum_param.emax
emin=spectrum_param.emin
fmin=spectrum_param.fmin
fmax=spectrum_param.fmax
count=spectrum_param.count

s1=widget_base(/column, title='Set Parameters', $
               xoffset=300, yoffset=200)
b_emax=cw_field(s1, title='          emax (eV) =', value=emax, /float)
b_emin=cw_field(s1, title='          emin (eV) =', value=emin, /float)
b_fmax=cw_field(s1, title='  fmax 1/(eV cm2 s) =', value=fmax, /float)
b_fmin=cw_field(s1, title='  fmin 1/(eV cm2 s) =', value=fmin, /float)
b_alti=cw_field(s1, title='number of altitudes =', value=count, $
          /int)
b_done=widget_button(s1, value='DONE')

widget_control, s1, /realize
xmanager, 'set_spectrum', s1, group_leader=main_base, /modal

return
end
