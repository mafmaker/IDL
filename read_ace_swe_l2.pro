pro read_ace_swe_l2,year,month,day, hr,dynp,vx,sw_time, dst,xgse,flag=flag

;--- emergency read of sw data
;--- written rapidly by TJI
;--- could be converted to subroutine
;
;  --- does not return IMF, use read_ace_mfi for that
;  --- this code does not time shift anything! It just 
;  --- returns a full array for the day
;
;  INPUT , year, month, day, and hr (for dst), and flag for interpolating
;	   bad data values
;  OUTPUT, dynp, vx,sw_time,dst
;
;  Keywords, NONE!!!
;
;  Changes : changed flag from passed variable to keyword ; 7-17-01
; 

;year='2000'
;month='07'
;day='16'
;hr='5'

if keyword_set(flag) ne 1 then flag = -9999.9  ;else, flag is defined!

syear=strcompress(year,/rem)
smonth=strcompress(month,/rem) & if month lt 10 then smonth='0' + smonth
sday=strcompress(day,/rem) & if day lt 10 then sday='0' + sday


forspawn = 'ls /home/immel/sci/ace/AC_K2_SWE_' + syear + '_' 
forspawn=forspawn +  smonth + '_' + sday + '*'
print,'looking for ' +  forspawn + ' in read_ace_swe_l2'

;spawn,'ls /home/immel/sci/ace/AC_L2_SWE_' + syear + '_' + smonth + '_' + sday + '*' ,filelist

spawn,forspawn,filelist

;stop


if filelist(0) eq '' then $
	print,'No ACE SW data file is available' else begin

  close,5
  openr,5,filelist(0)
  spare=' '
  bla=' '
  while spare ne 'year day' do readf,5,format='(a8)',spare
  counter=0
  killer=0
;--- add another line read to read statement to get past 'BEGIN DATA'
;--- line at the start of the data in POST 2011 downloads
  readf,5,format='(a8)',spare

;--- count how many times to read this thing.
  while not(eof(5)) and killer eq 0 do begin
    readf,5,format='(a68)',bla
    bla=strcompress(bla)
    newbla=strsplit(bla(0),/extract)
    bla=strcompress(bla,/rem)
    if strlen(bla) lt 2 then killer=1
;    print,newbla(2),newbla(3)
    if strlen(bla) gt 2 then counter=counter + 1
  endwhile

  close,5
  openr,5,filelist(0)

  sw_data=fltarr(3,counter)
  sw_time=dblarr(counter)			;decimal hours
  time=indgen(counter)
  bla='                                             '
  spare=' '
;--- load the data
  while spare ne 'year day' do readf,5,format='(a8)',spare
  readf,5,format='(a8)',spare  ;extra line read necessary for post 2011 data

  for i=0,counter-1 do begin
    readf,5,format='(a80)',bla
    bla=strcompress(bla)
    newbla=strsplit(bla(0),/extract)
    sw_data(0,i)=float(newbla(5)) 
    sw_data(1,i)=float(newbla(6))     	; * (-1) do this change after
					; interpolating over bad data
    sw_data(2,i)=float(newbla(7))

    sw_hour=fix(newbla(2))
    sw_min=fix(newbla(3))
    sw_sec=fix(newbla(4))
    ydn2md,fix(newbla(0)),fix(newbla(1)),month,mday


    cdf_epoch, epoch1, fix(newbla(0)), fix(month), fix(mday),$
			sw_hour,sw_min,sw_sec,0d, /Compute_Epoch
;    sw_time(i)=float(strmid(newbla(1),0,2)) + $
;		float(strmid(newbla(1),3,2))
    sw_time(i)=epoch1

  endfor
  data=reform(sw_data(0,*))


  for i=0,1 do begin
    data=sw_data(i,*)
    sw_interp,data,time,flag
    sw_data(i,*)=data
  endfor

  sw_data(1,*)=sw_data(1,*) * (-1)	;convert x-vel to radial speed

;assuming protons, pressure=v^2 * n den * mass per n
;convert nden to per m^3 with 1e6
;convert velocity is in km /sec so correct that as well. Pressure should
;be on the order of 1-10 nanopascal

  dynpress=(sw_data(1,*)*1000)^2 * sw_data(0,*)*1e6 * 1.6e-27  


; The other programs return DST with the satellite data. Here is my way.

;--- NO what is this doign here ? I am commenting out this DST file
;    restore 10-19-2012


;  dst_dir='$HOME/sci/dst/'
;  restore,dst_dir + 'dst' +syear+'.idl'

;  doy=ymd2dn(fix(year),fix(month),fix(day))
;  dst=dst_arr(fix(hr)-1 > 0,fix(doy)-1)


  dynp=reform(dynpress)  * 1e9	;report in nPa, not Pa
				;this is what tsyganenko expects!!!
  vx=reform(sw_data(1,*))
  xgse=reform(sw_data(2,*))

endelse



;stop

end
