pro read_ace_swe,year,month,day, hr,dynp,vx,sw_time, dst,flag

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
;
;

;year='2000'
;month='07'
;day='16'
;hr='5'
;  flag = -999.9

syear=strcompress(year,/rem)
smonth=strcompress(month,/rem) & if month lt 10 then smonth='0' + smonth
sday=strcompress(day,/rem) & if day lt 10 then day='0' + day

spawn,'ls /home/immel/sci/ace/AC_K0_SWE_' + syear + '_' + smonth + '_' + sday + '*' ,filelist

if filelist(0) eq '' then $
	print,'No ACE SW data file is available' else begin

  close,5
  openr,5,filelist(0)
  spare=' '
  bla='                       '
  while spare ne 'dd-mm' do readf,5,format='(a5)',spare
  counter=0
  killer=0


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

  sw_data=fltarr(2,counter)
  sw_time=dblarr(counter)			;decimal hours
  time=indgen(counter)
  bla='                                             '
  spare=' '
;--- load the data
  while spare ne 'dd-mm' do readf,5,format='(a5)',spare


  for i=0,counter-1 do begin
    readf,5,format='(a70)',bla
    bla=strcompress(bla)
    newbla=strsplit(bla(0),/extract)
    sw_data(0,i)=float(newbla(2))
    sw_data(1,i)=float(newbla(3))
    sw_hour=fix(strmid(newbla(1),0,2))
    sw_min=fix(strmid(newbla(1),3,2))
    sw_sec=fix(strmid(newbla(1),6,2))
    cdf_epoch, epoch1, fix(year), fix(month), fix(day),$
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

;assuming protons, pressure=v^2 * n den * mass per n
;convert nden to per m^3 with 1e6
;convert velocity is in km /sec so correct that as well. Pressure should
;be on the order of 1-10 nanopascal

  dynpress=(sw_data(1,*)*1000)^2 * sw_data(0,*)*1e6 * 1.6e-27  


; The other programs return DST with the satellite data. Here is my way.

  dst_dir='$HOME/sci/dst/'
  restore,dst_dir + 'dst' +syear+'.idl'

  doy=ymd2dn(fix(year),fix(month),fix(day))
  dst=dst_arr(fix(hr)-1 > 0,fix(doy)-1)


  dynp=reform(dynpress)  * 1e9	;report in nPa, not Pa
				;this is what tsyganenko expects!!!
  vx=reform(sw_data(1,*))

endelse



;stop

end