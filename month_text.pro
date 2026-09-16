pro month_text,monthnum,monthabrev,monthfull


;
;
;scratched together in a big fn hurry to give me something I can use
;again someday,
;
;


month1=['January','February','March','April','May','June','July','August','September','October','November','December']


month2=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sept','Oct','Nov','Dec']

monthabrev=month2(monthnum-1)
monthfull=month1(monthnum-1)

return
end
