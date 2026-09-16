pro get_dmsp_anderson,filename,time,glat,glon,mlat,mlt,efp,ep

;
;This is a special DMSP data reader to interpret the data
;provided by Phil Anderson from Aerospace. These data only had
;proton energies listed, so hereeeee, we gooo.....
;

get_lun,unit
openr,unit,filename

counter=0
spare='    '

while spare ne '   seconds' do begin
	readf,unit,format='(a10)',spare  
	print,spare
endwhile

while not(eof(unit)) do begin

  readf,unit,format='(a80)',spare
  print,spare
  spare=strcompress(spare)
  data=strsplit(spare,' ',/extract)
  
  if counter eq 0 then begin
    time=float(data(0))
    mlat=float(data(1))
    mlt=float(data(2))
    glon=float(data(4))
    glat=float(data(5))
    efp=float(data(6))
    ep=data(7)
    counter = counter + 1
  endif else begin
    time=[time,float(data(0))]
    mlat= [mlat,float(data(1))]
    mlt= [mlt,float(data(2))]
    glon = [glon,float(data(4))]
    glat = [glat,float(data(5))]
    efp= [efp,float(data(6))]
    ep= [ep,float(data(7))]
    counter=counter + 1
  endelse
 
endwhile

free_lun,unit

return
end