pro read_iridium_p2,starttime,stoptime,iridiumdata

;  New program to read net_db from file provided online by Brian Anderson.
;  Some cleanup will be applied, interpolating to bad data values,
;  (which are 0?)
;
;
;
;starttime


datadir='/home/immel/sci/iridium/stats/'

syear=strcompress(starttime(0),/rem)
doy0=starttime(1)
doy1=stoptime(1)
hour0=starttime(2)
hour1=stoptime(2)

ydn2md,starttime(0),starttime(1),month0,day0
ydn2md,stoptime(0),stoptime(1),month1,day1

hour0=starttime(2)
hour1=stoptime(2)

;-- on the first day of the month, you lack the first 8 hours of data
;   from the previous month. So add the previous month's file to your list.
print,day0
if day0 eq 1 then $
  ydn2md,starttime(0),starttime(1)-1,month0,day0

filebase=datadir + syear + '/dbs' + syear

counter=0
for i=month0,month1 do begin
;index=i-month0
;--- create filename
  smonth=strcompress(i,/rem) & if i lt 10 then smonth='0'+smonth
  filename=filebase+ smonth + '.dat'
;--- open file
  get_lun,unit
  openr,unit,filename
;  print,'Reading '+ filename
;--- read first line
  bla=' '
  readf,unit,bla
;--- read number of lines
  while not(eof(unit)) do begin
    bla=' '
    readf,unit,bla
;    print,bla
    counter=counter + 1
  endwhile
;--- close file
  close,unit
  free_lun,unit
endfor

;--- now create arrays of size counter
year_arr=intarr(counter)
day_arr=intarr(counter)
hour_arr=fltarr(counter)
net_db_arr=fltarr(counter)-1
;--- now load the arrays

counter2=0
for i=month0,month1 do begin
;--- create filename
  smonth=strcompress(i,/rem) & if i lt 10 then smonth='0'+smonth
  filename=filebase+ smonth + '.dat'
;--- open file
  get_lun,unit
  openr,unit,filename
;--- read first line
  bla=' '
  readf,unit,bla
;--- read number of lines
  while not(eof(unit)) do begin
    bla=' '
    readf,unit,bla
    splitter=strsplit(bla,/extract)


;--- assign the variables

    year_arr(counter2)=fix(splitter(0))
    day_arr(counter2)=fix(splitter(1))
    hour_arr(counter2)=  (float(splitter(1))-fix(splitter(1)))* 24.
    if strcompress(splitter(3),/rem) ne 'NaN' then $
      net_db_arr(counter2)= float(splitter(3))
    counter2=counter2 + 1
  endwhile
;--- close file
  close,unit
  free_lun,unit
endfor


 finder=where(day_arr gt doy0 and day_arr lt doy1 or $
               (day_arr eq doy0 and hour_arr ge hour0) or $
                (day_arr eq doy1 and hour_arr lt hour1),found_data)


; iridiumdata={net_db:fltarr(found_data),year:intarr(found_data),$
;              day:intarr(found_data),hour:intarr(found_data)}

  iridiumdata={net_db:net_db_arr(finder),year:year_arr(finder),$
              day:day_arr(finder),hour:hour_arr(finder)}


return
end

