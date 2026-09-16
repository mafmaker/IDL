function make_label,imname

;---make a label from a filename which goes as wicyyyydddhhmm
  name=imname
  YEARLB=', ' + strmid(NAME,3,4) 
  UTLB=', ' + strmid(NAME,10,2)+':'+strmid(NAME,12,2) + ' UT'
  daylb=' (Day ' + strmid(name,7,3) + ')'
  call_procedure,'ydn2md',fix(strmid(NAME,3,4)),fix(strmid(NAME,7,3)),m,d
  lines=size(img) & lines=lines(1)
  month=get_months(m-1)                            ;careful...... m-1
  lab=  month+ string(d)+yearlb+daylb+utlb     ; make label for title
  lab=strcompress(lab)                         ; remove extra spaces
;---make a label

return,lab

end
