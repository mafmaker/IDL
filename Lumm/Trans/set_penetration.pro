pro set_penetration_event, event

@common
@common_w

; the DONE button is the only one that can create an event.  Once an
; event is encountered, read the buttons and return to the main panel.

widget_control, event.id, get_uvalue=target

case target of
   'b_updn': begin
       case event.value of
           'up/down': begin
               oldvalue1=0
               penetration_param.updn = 1
               penetration_param.total = 0
               penetration_param.photo = 0
               penetration_param.net = 0
            end
            'total': begin
               oldvalue1=1
               penetration_param.updn = 0
               penetration_param.total = 1
               penetration_param.photo = 0
               penetration_param.net = 0
            end
            'photo': begin
               oldvalue1=2
               penetration_param.updn = 0
               penetration_param.total = 0
               penetration_param.photo = 1
               penetration_param.net = 0
            end
            'net': begin
               oldvalue1=3
               penetration_param.updn = 0
               penetration_param.total = 0
               penetration_param.photo = 0
               penetration_param.net = 1
            end
       endcase
   end
   'b_pe': begin
       case event.value of
           'Particle Flux': begin
               oldvalue2=0
               penetration_param.eflux = 0
            end
            'Energy Flux': begin
               oldvalue2=1
               penetration_param.eflux = 1
            end
       endcase
   end
   'DONE': begin
       widget_control, b_zmax, get_value=zmax
       widget_control, b_zmin, get_value=zmin
       widget_control, b_fmax, get_value=fmax
       widget_control, b_fmin, get_value=fmin
       if zmin le 0 then zmin=min(altitude)
       if zmax le zmin then zmax=max(altitude)
       penetration_param.zrange(0)=zmin
       penetration_param.zrange(1)=zmax
       penetration_param.frange(0)=fmin
       penetration_param.frange(1)=fmax
       widget_control, event.top, /destroy
   end
endcase
return
end



pro set_penetration

@common
@common_w

zmax=penetration_param.zrange(1)
zmin=penetration_param.zrange(0)
fmax=penetration_param.frange(1)
fmin=penetration_param.frange(0)

s1=widget_base(/column, title='Set Parameters', $
               xoffset=300, yoffset=200)

b1=cw_bgroup(s1, ['up/down', 'total', 'photo', 'net'], row=1, $
                 /exclusive, /return_name, uvalue='b_updn', $
                 set_value=oldvalue1)
b2=cw_bgroup(s1, ['Particle Flux', 'Energy Flux'], row=1, $
                 /exclusive, /return_name, uvalue='b_pe', $
                 set_value=oldvalue2)

b_zmax=cw_field(s1, title=' Altitude max (km) =', value=zmax, /float)
b_zmin=cw_field(s1, title=' Altitude min (km) =', value=zmin, /float)
b_fmax=cw_field(s1, title='         Flux max  =', value=fmax, /float)
b_fmin=cw_field(s1, title='         Flux min  =', value=fmin, /float)
b_done=widget_button(s1, value='DONE', uvalue='DONE')

widget_control, s1, /realize
xmanager, 'set_penetration', s1, group_leader=main_base, /modal

return
end
