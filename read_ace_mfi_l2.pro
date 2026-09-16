pro read_ace_mfi_l2,year,month,day, hr,bxx,byy,bzz,mfi_time,xgse,flag

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
;  input  - year month and day
;  output - bx,by,bz,timestamp, xgse position of ACE 
;  requires - L2 ascii input file in AC_K2_MFI_yyyy_mm_dd
;
;
;  L2 files from ACE Data Center, following format:
;
;year day hr min sec proton_density x_dot_GSE pos_gse_x pos_gse_y pos_gse_z 
;BEGIN DATA
;2011 219  0  0 51.000      1.052   -587.34  1.5852e+06  1.0739e+05  2.7596e+04
;
;
;


syear=strcompress(year,/rem)
smonth=strcompress(month,/rem) & if month lt 10 then smonth='0' + smonth
sday=strcompress(day,/rem) & if day lt 10 then sday='0' + sday

spawn,'ls /home/immel/sci/ace/AC_K2_MFI_' + syear + '_' + smonth + '_' + sday + '*' ,filelist

if filelist(0) eq '' then $
	print,'No ACE MFI Level 0 data file is available' else begin

  close,5
  openr,5,filelist(0)
  spare=' '
  bla=' '
  while spare ne 'year day' do readf,5,format='(a8)',spare
  counter=0
  killer = 0 
;--- add another line read to read statement to get past 'BEGIN DATA'
;--- line at the start of the data in POST 2011 downloads
  readf,5,format='(a8)',spare

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

  mfi_data=fltarr(4,counter)
  date_data=intarr(5,counter)
  time=indgen(counter)
  mfi_time=dblarr(counter)			;for holding EPOCH time
  bla='                                             '
  spare=' '
;--- load the data
  while spare ne 'year day' do readf,5,format='(a8)',spare
  readf,5,format='(a8)',spare

  for i=0,counter-1 do begin
    readf,5,format='(a100)',bla
    bla=strcompress(bla)
    newbla=strsplit(bla(0),/extract)
    mfi_data(0,i)=float(newbla(6))
    mfi_data(1,i)=float(newbla(7))
    mfi_data(2,i)=float(newbla(8))
    mfi_data(3,i)=float(newbla(9))
;--- need specific timing to get gsm coordinates.

;    cutter=strsplit(newbla(0),'-',/extract)
    date_data(0,i)=fix(newbla(0))
    date_data(1,i)=fix(newbla(1));
			;ymd2dn(fix(cutter(2)),fix(cutter(1)),fix(cutter(0)))
;    timer=strsplit(newbla(1),':',/extract)
    date_data(2,i)=fix(newbla(2))
    date_data(3,i)=fix(newbla(3))
    date_data(4,i)=fix(newbla(4))
    ydn2md,fix(newbla(0)),fix(newbla(1)),month,mday
			;year		month		day

    cdf_epoch, epoch1, date_data(0,i), month, mday ,$
       date_data(2,i),date_data(3,i),date_data(4,i),0d, /Compute_Epoch
	;hour		minute		second      msec
    mfi_time(i)=epoch1

  endfor

;  for i=0,2 do begin
;    data=mfi_data(i,*)
;    baddata=where(data eq flag,baddy)
;    if baddy gt 0 then sw_interp,data,time,flag
;    mfi_data(i,*)=data
;  endfor

  bxx=fltarr(counter)
  byy=bxx & bzz=bxx

;--- convert to GSM coordinates using Harald's converter. 
;--- WTF happened to my converter, it doesn't work!
;--- THIS ONE WORKS. 

  for i=0,counter-1 do begin
	
	gsmgse,gsmx,gsmy,gsmz,mfi_data(0,i),mfi_data(1,i),mfi_data(2,i),$
	-1 ,date_data(0,i),date_data(1,i),date_data(2,i),date_data(3,i),$
	date_data(4,i)
		
	bxx(i)=gsmx
	byy(i)=gsmy
 	bzz(i)=gsmz
  endfor
	xgse=reform(mfi_data(3,*))


;endif	;where does this thing start???
 

endelse





end
