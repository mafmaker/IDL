pro read_mol3_data_p,time,gsex,gsey,gsez

  get_lun,unit
  openr,unit,'/home/immel/sci/orbital/mol3-39-2004-dec21.txt'
  minutes=60*24
  gsex=fltarr(minutes)
  gsey=fltarr(minutes)
  gsez=fltarr(minutes)
  time=fltarr(minutes)
  line='                                           '
  counter=0
  while not(eof(unit)) do begin
    readu,unit,line
;    print,line
    minutes=counter
    counter=counter + 1
    dummy=strsplit(line,/extract)
  endwhile

  close,unit

end
