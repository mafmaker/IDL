pro quick_question,ps_flag
;
; I'm sick of typing this at the fron end of every piece of code I write!
;
;

ps_flag=1
print,'Enter Y to read the data'
blank=' '
read,blank
if strmid(strcompress(strupcase(blank),/rem),0,1) eq 'Y' then ps_flag=0

return

end
