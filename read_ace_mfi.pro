pro read_ace_mfi,year,month,day, hr,bxx,byy,bzz,mfi_time,flag

;--- emergency read of sw data
;--- written rapidly by TJI
;--- could be converted to subroutine
;
;  --- does not return IMF, use read_ace_mfi for that
;  --- this code does not time shift anything! It just 
;  --- returns a full array for the day
;
;  --- this one finally works, and it calls gsmgse which Harald whacked
;	into IDL from FORTRAN.
;

;year='2000'
;month='07'
;day='16'
;hr='5'
;flag = -999.9

syear=strcompress(year,/rem)
smonth=strcompress(month,/rem) & if month lt 10 then smonth='0' + smonth
sday=strcompress(day,/rem) & if day lt 10 then day='0' + day

spawn,'ls /home/immel/sci/ace/AC_K0_MFI_' + syear + '_' + smonth + '_' + sday + '*' ,filelist

if filelist(0) eq '' then $
	print,'No ACE MFI Level 0 data file is available' else begin

  close,5
  openr,5,filelist(0)
  spare=' '
  bla=' '
  while spare ne 'dd-mm' do readf,5,format='(a5)',spare
  counter=0
  killer = 0 
;--- count how many times to read this thing.
  while not(eof(5)) and killer eq 0 do begin
    readf,5,format='(a90)',bla
;    print,bla
    bla=strcompress(bla,/rem)
    if strlen(bla) lt 2 then killer=1
;    newbla=strsplit(bla(0),/extract)
;    print,newbla(2),newbla(3)
    if strlen(bla) gt 2 then counter=counter + 1
  endwhile

  close,5
  openr,5,filelist(0)

  mfi_data=fltarr(3,counter)
  date_data=intarr(5,counter)
  time=indgen(counter)
  mfi_time=dblarr(counter)			;for holding EPOCH time
  bla='                                             '
  spare=' '
;--- load the data
  while spare ne 'dd-mm' do readf,5,format='(a5)',spare


  for i=0,counter-1 do begin
    readf,5,format='(a90)',bla
    bla=strcompress(bla)
    newbla=strsplit(bla(0),/extract)
    mfi_data(0,i)=float(newbla(3))
    mfi_data(1,i)=float(newbla(4))
    mfi_data(2,i)=float(newbla(5))

;--- need specific timing to get gsm coordinates.

    cutter=strsplit(newbla(0),'-',/extract)
    date_data(0,i)=fix(cutter(2))
    date_data(1,i)=ymd2dn(fix(cutter(2)),fix(cutter(1)),fix(cutter(0)))
    timer=strsplit(newbla(1),':',/extract)
    date_data(2,i)=fix(timer(0))
    date_data(3,i)=fix(timer(1))
    date_data(4,i)=fix(timer(2))
			;year		month		day
    cdf_epoch, epoch1, date_data(0,i), fix(cutter(1)),fix(cutter(0)),$
       date_data(2,i),date_data(3,i),date_data(4,i),0d, /Compute_Epoch
	;hour		minute		second      msec
    mfi_time(i)=epoch1

  endfor

;  data=reform(mfi_data(0,*))
;  flag = -999.9

  for i=0,2 do begin
    data=mfi_data(i,*)
    baddata=where(data eq flag,baddy)
    if baddy gt 0 then sw_interp,data,time,flag
    mfi_data(i,*)=data
  endfor

;assuming protons, pressure=v^2 * n den * mass per n
;convert nden to per m^3 with 1e6
;convert velocity is in km /sec so correct that as well. Pressure should
;be on the order of 1-10 nanopascal

;  dynpress=(sw_data(1,*)*1000)^2 * sw_data(0,*)*1e6 * 1.6e-27  
; The other programs return DST with the satellite data. Here is my way.

;  dst_dir='$HOME/sci/dst/'
;  restore,dst_dir + 'dst' +year+'.idl'

;  doy=ymd2dn(fix(year),fix(month),fix(day))
;  dst=dst_arr(fix(hr)-1 > 0,fix(doy)-1)


;  dynp=dynpress
 
  bxx=fltarr(counter)
  byy=bxx & bzz=bxx

;--- convert to GSM coordinates using Harald's converter. 
;--- WTF happened to my converter, it doesn't work!

  for i=0,counter-1 do begin
	
	gsmgse,gsmx,gsmy,gsmz,mfi_data(0,i),mfi_data(1,i),mfi_data(2,i),$
	-1 ,date_data(0,i),date_data(1,i),date_data(2,i),date_data(3,i),$
	date_data(4,i)
		
	bxx(i)=gsmx
	byy(i)=gsmy
 	bzz(i)=gsmz
  endfor
	
;endif	;where does this thing start???
 

endelse





end