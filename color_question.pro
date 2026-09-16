pro color_question,color_flag
;
; I'm sick of typing this at the fron end of every piece of code I write!
;
;

ps_flag=0
print,'Enter C for Color'
blank=' '
read,blank
if strcompress(strupcase(blank),/rem) eq 'C' then color_flag=1

return

end
