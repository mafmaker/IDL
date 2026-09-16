pro z_question,ps_flag
;
; I'm sick of typing this at the fron end of every piece of code I write!
;
;

ps_flag=0
print,'Enter Z for z_buffer'
blank=' '
read,blank
if strcompress(strupcase(blank),/rem) eq 'Z' then ps_flag=1

return

end
