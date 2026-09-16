pro set_flx_cont_event, event

@common
@common_w

; the DONE button is the only one that can create an event.  Once an
; event is encountered, read the buttons and return to the main panel.

widget_control, event.id, get_uvalue=target

case target of
   'bgroup': begin
       case event.value of
           'up': begin
               oldvalue=0
               flx_cont_param.up=1
               flx_cont_param.total=0
               flx_cont_param.photo=0
               flx_cont_param.net=0
           end
           'down': begin 
               oldvalue=1
               flx_cont_param.up=0
               flx_cont_param.total=0
               flx_cont_param.photo=0
               flx_cont_param.net=0
           end
           'total': begin
               oldvalue=2
               flx_cont_param.up=0
               flx_cont_param.total=1
               flx_cont_param.photo=0
               flx_cont_param.net=0
           end
           'photo': begin
               oldvalue=3
               flx_cont_param.up=0
               flx_cont_param.total=0
               flx_cont_param.photo=1
               flx_cont_param.net=0
           end
           'net': begin
               oldvalue=4
               flx_cont_param.up=0
               flx_cont_param.total=0
               flx_cont_param.photo=0
               flx_cont_param.net=1
           end
       endcase
   end
   'b_surf': begin
      case event.value of 
         'colorbar': begin
            old_surf = 1
            flx_cont_param.surf = 1
         end
         'contour': begin
            old_surf = 0
            flx_cont_param.surf = 0
         end
      endcase
   end
   'energy': begin
       widget_control, event.id, get_value=e_label
       if strpos(e_label, 'particle') ge 0 then begin
           e_label='energy flux'
           flx_cont_param.energyflux=1
       endif else begin
           e_label='particle flux'
           flx_cont_param.energyflux=0
       endelse
       widget_control, event.id, set_value=e_label
   end
   'DONE': begin
       widget_control, b_zmax, get_value=zmax
       widget_control, b_zmin, get_value=zmin
       widget_control, b_emax, get_value=emax
       widget_control, b_emin, get_value=emin
       widget_control, b_fmin, get_value=fmin
       widget_control, b_fmax, get_value=fmax
       if emax ne emin then emin=max([0.01,emin])
       flx_cont_param.yrange(0)=zmin
       flx_cont_param.yrange(1)=zmax
       flx_cont_param.xrange(0)=emin
       flx_cont_param.xrange(1)=emax
       flx_cont_param.frange[0]=fmin
       flx_cont_param.frange[1]=fmax
      widget_control, event.top, /destroy
   end
endcase
return
end



pro set_flx_cont

@common
@common_w

zmax=flx_cont_param.yrange(1)
zmin=flx_cont_param.yrange(0)
emax=flx_cont_param.xrange(1)
emin=flx_cont_param.xrange(0)
fmin = flx_cont_param.frange[0]
fmax = flx_cont_param.frange[1]


s1=widget_base(/column, title='Set Parameters', $
               xoffset=300, yoffset=200)

bgroup=cw_bgroup(s1, ['up', 'down', 'total', 'photo', 'net'], row=1, $
                 /exclusive, /return_name, uvalue='bgroup', $
                 set_value=oldvalue)
b_surf = cw_bgroup(s1, ['contour', 'colorbar'], row=1, $
                 /exclusive, /return_name, uvalue='b_surf', $
                 set_value=old_surf)
b_energy=widget_button(s1, value=e_label, uvalue='energy')
b_zmax=cw_field(s1, title='         zmax (km) =', value=zmax, /float)
b_zmin=cw_field(s1, title='         zmin (km) =', value=zmin, /float)
b_emax=cw_field(s1, title='         emax (eV) =', value=emax, /float)
b_emin=cw_field(s1, title='         emin (eV) =', value=emin, /float)
b_fmax=cw_field(s1, title='fmax (eV-1cm-2s-1) =', value=fmax, /float)
b_fmin=cw_field(s1, title='fmin (eV-1cm-2s-1) =', value=fmin, /float)
b_done=widget_button(s1, value='DONE', uvalue='DONE')

widget_control, s1, /realize
xmanager, 'set_flx_cont', s1, group_leader=main_base, /modal

return
end
