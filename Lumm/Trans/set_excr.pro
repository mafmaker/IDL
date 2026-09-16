pro set_excr_event, event

@common
@common_w
@common_c

widget_control, event.id, get_uvalue=test

; read all numeric fields if either one has changed, or if the 'done'
; button is pressed.  The 'select state drop lists are handled separately

case string(test) of
   'PICK_N2': begin
      pick_n2 = event.index-1
      if pick_n2 ge 0 then msg_out, 'highlight '+states_n2(pick_n2,0)
   end
   'PICK_O2': begin
      pick_o2 = event.index-1
      if pick_o2 ge 0 then msg_out, 'highlight '+states_o2(pick_o2,0)
   end
   'PICK_O': begin
      pick_o = event.index-1
      if pick_o ge 0 then msg_out, 'highlight '+states_o(pick_o,0)
   end
   'DONE': begin
      widget_control, b_zmax, get_value=zmax
      widget_control, b_zmin, get_value=zmin
      widget_control, b_npowers, get_value=npowers
      ionr_param.yrange(0)=zmin
      ionr_param.yrange(1)=zmax
      ionr_param.npowers=npowers
      widget_control, event.top, /destroy
   end
   else: begin
      widget_control, b_zmax, get_value=zmax
      widget_control, b_zmin, get_value=zmin
      widget_control, b_npowers, get_value=npowers
      ionr_param.yrange(0)=zmin
      ionr_param.yrange(1)=zmax
      ionr_param.npowers=npowers
   end
endcase

return
end

pro set_excr

; bring up a widget to set parameters for the plotting of excitation
; rate profiles

@common
@common_w
@common_c

zmax=ionr_param.yrange(1)
zmin=ionr_param.yrange(0)
npowers=ionr_param.npowers

s1=widget_base(/column, title='Set Excitation Rate Parameters', $
               xoffset=300, yoffset=200, group=main_base, /float)
b_zmax=cw_field(s1, title='        zmax (km) =', value=zmax, /float, /return)
b_zmin=cw_field(s1, title='        zmin (km) =', value=zmin, /float, /return)
b_npowers=cw_field(s1, title='number of decades =', value=npowers, $
          /int, /return)
b0 = widget_label(s1, value='Highlight a specific state')
s2 = widget_base(s1, /row, title='select state')
b1 = widget_droplist(s2, value=['none', states_n2(0:nstat_n2(0)-1,0)],  $
                     uvalue='PICK_N2', title='N2')
b2 = widget_droplist(s2, value=['none', states_o2(0:nstat_o2(0)-1,0)],  $
                     uvalue='PICK_O2', title='O2')
b3 = widget_droplist(s2, value=['none', states_o(0:nstat_o(0)-1,0)],  $
                     uvalue='PICK_O', title='O')
                               
b_done=widget_button(s1, value='DONE', uvalue='DONE')

widget_control, s1, /realize
xmanager, 'set_excr', s1, group_leader=main_base

return
end
