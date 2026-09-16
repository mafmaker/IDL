pro prnt_error_event, event

widget_control, event.top, /destroy

return
end


pro prnt_error, text

t_but=intarr(n_elements(text))
l_text=strarr(n_elements(text))
if n_elements(text) eq 1 then l_text(0)=text else l_text=text

s1=widget_base(/column, title='E R R O R', $
               xoffset=300, yoffset=200)
for i=0,n_elements(text)-1 do $
   t_but(i)=widget_label(s1, value=l_text(i))
button=widget_button(s1, value='OK')

widget_control, s1, /realize

xmanager, 'prnt_error', s1, /modal

return
end
