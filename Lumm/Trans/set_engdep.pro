pro set_engdep_event, event

@common
@common_w

; the DONE button is the only one that can create an event.  Once an
; event is encountered, read the buttons and return to the main panel.

widget_control, event.id, get_uvalue=target

case target of
   'total': begin
       widget_control, event.id, get_value=t_label
       if strpos(t_label, 'total') ge 0 then begin
           t_label='individual states'
           engdep_param.only_total=0
       endif else begin
           t_label='only total'
           engdep_param.only_total=1
       endelse
       widget_control, event.id, set_value=t_label
   end
   'DONE': begin
       widget_control, b_zmax, get_value=zmax
       widget_control, b_zmin, get_value=zmin
       widget_control, b_npowers, get_value=npowers
       engdep_param.yrange(0)=zmin
       engdep_param.yrange(1)=zmax
       engdep_param.npowers=npowers
       widget_control, event.top, /destroy
   end
endcase
return
end



pro set_engdep

@common
@common_w

zmax=engdep_param.yrange(1)
zmin=engdep_param.yrange(0)
npowers=engdep_param.npowers

s1=widget_base(/column, title='Set Parameters', $
               xoffset=300, yoffset=200)

b_total=widget_button(s1, value=t_label, uvalue='total')
b_zmax=cw_field(s1, title='        zmax (km) =', value=zmax, /float)
b_zmin=cw_field(s1, title='        zmin (km) =', value=zmin, /float)
b_npowers=cw_field(s1, title='number of decades =', value=npowers, $
          /int)
b_done=widget_button(s1, value='DONE', uvalue='DONE')

widget_control, s1, /realize
xmanager, 'set_engdep', s1, group_leader=main_base, /modal

return
end
