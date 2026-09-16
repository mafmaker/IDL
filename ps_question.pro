pro ps_question,ps_flag
;
; I'm sick of typing this at the fron end of every piece of code I write!
;
;

ps_flag=0
print,'Enter P for Postscript'
blank=' '
read,blank
if strcompress(strupcase(blank),/rem) eq 'P' then ps_flag=1

return

end
