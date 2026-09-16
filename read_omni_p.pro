;  procedure read_omni_p
;  Author : Thomas Immel
;  Licence : BSD - http://www.opensource.org/licenses/bsd-license.html
;  Date : 9-9-2004
;  INPUT : starttime [yyyy,doy,h],endtime [yyyy,doy,h]
;  OUTPUT : 2 structures 
;           swdata (den,vel,theta,phi,source,year,day,hour)
;           imfdata  (bx,by,bz,source,year,day,hour)
;
;  CALLING : read_omni_p,starttime,endtime,swdata,imfdata
;
;  Requirements :1 ymd2dn.pro 
;               :2 hardwiring of the OMNI directory where one finds
;               the same directory structure as at 
;               ftp://cdaweb.gsfc.nasa.gov/pub/istp/omni/

;
;
;  Notes  Version 0.1 - does not work across June-July date boundary
;                       or year boundary.
;
; In the CDF files, these are the available variables:
;       0Epoch
;       1YR
;       2Day
;       3HR
;       4Rot#
;       5IMF
;       6PLS
;       7IMF_PTS
;       8PLS_PTS
;       9ABS_B
;      10F
;      11THETA_AV
;      12PHI_AV
;      13BX_GSE
;      14BY_GSE
;      15BZ_GSE
;      16BY_GSM
;      17BZ_GSM
;      18SIGMA-ABS_B
;      19SIGMA-B
;      20SIGMA-Bx
;      21SIGMA-By
;      22SIGMA-Bz
;      23T
;      24N
;      25V
;      26PHI-V
;      27THETA-V
;      28SIGMA-T
;      29SIGMA-N
;      30SIGMA-V
;      31SIGMA-PHI-V
;      32SIGMA-THETA-V
;      33KP
;      34C9
;      35R
;      36DST
;      37PR-FLX_1
;      38PR-FLX_2
;      39PR-FLX_4
;      40PR-FLX_10
;      41PR-FLX_30
;      42PR-FLX_60
;      43MFLX
;




pro read_omni_p,starttime,stoptime,swdata,imfdata

year=starttime(0)
doy1=starttime(1)
doy2=stoptime(1)
hour1=starttime(2)
hour2=stoptime(2)

ydn2md,year,doy1,month,dayofmonth

;adjust this path for your own uses

datapath='/home/immel/sci/omniweb/'

syear= strcompress(year,/rem)

datapath2=datapath + syear + '/'

filename= 'omni_h0_mrg1hr_' + syear 

if month ge 1 and month le 6 then $
  filename = filename + '0101_v01.cdf' else $
  filename = filename + '0701_v01.cdf'


id=cdf_open(datapath2 + filename)

data=cdf_inquire(id)
for i=0,data.natts -1 do begin
  cdf_attinq,id,i,name,dummy1,dummy2
  print,i,name
endfor

for i=0,data.nvars -1 do begin
  vardata=cdf_varinq(id,i)
  print,i,vardata.name
endfor


for i=0,data.nvars-1 do begin


  if i eq 1 then cdf_varget,id,i,year_arr,rec_count=data.maxrec
  if i eq 2 then cdf_varget,id,i,day_arr,rec_count=data.maxrec
  if i eq 3 then cdf_varget,id,i,hour_arr,rec_count=data.maxrec
  if i eq 5 then cdf_varget,id,i,IMF,rec_count=data.maxrec
  if i eq 6 then cdf_varget,id,i,PLS,rec_count=data.maxrec
  if i eq 13 then cdf_varget,id,i,IMFBX,rec_count=data.maxrec
  if i eq 16 then cdf_varget,id,i,IMFBY,rec_count=data.maxrec
  if i eq 17 then cdf_varget,id,i,IMFBZ,rec_count=data.maxrec
  if i eq 24 then cdf_varget,id,i,den_arr,rec_count=data.maxrec
  if i eq 25 then cdf_varget,id,i,vel_arr,rec_count=data.maxrec
  if i eq 26 then cdf_varget,id,i,phi_arr,rec_count=data.maxrec
  if i eq 27 then cdf_varget,id,i,theta_arr,rec_count=data.maxrec


endfor




;--- do interpolation here, it is not that computationally expensive

fiximf=where(imfbx eq 999.9,baddata)
goodimf=where(imfbx ne 999.9,gooddata)
if baddata gt 0 then begin
  imfbx(fiximf)=interpol(imfbx(goodimf),goodimf,fiximf)
  imfby(fiximf)=interpol(imfby(goodimf),goodimf,fiximf)
  imfbz(fiximf)=interpol(imfbz(goodimf),goodimf,fiximf)
endif

fixvel=where(vel_arr eq 9999.0,baddata)
goodvel=where(vel_arr ne 9999.0,gooddata)

if baddata gt 0 then begin
  vel_arr(fixvel)=interpol(vel_arr(goodvel),goodvel,fixvel)
endif

fixden=where(den_arr eq 999.9,baddata)
goodden=where(den_arr ne 999.9,gooddata)

if baddata gt 0 then begin
  den_arr(fixden)=interpol(den_arr(goodden),goodden,fixden)
endif

;---narrow down the data interval
  finder=where(day_arr gt doy1 and day_arr lt doy2 or $
               (day_arr eq doy1 and hour_arr ge hour1) or $
                (day_arr eq doy2 and hour_arr lt hour2),found_data)

if found_data gt 0 then begin

  imfdata={bx:fltarr(found_data),by:fltarr(found_data),bz:fltarr(found_data),$
           source:intarr(found_data),year:intarr(found_data),$
           day:intarr(found_data),hour:intarr(found_data)}
  swdata={vel:fltarr(found_data),den:fltarr(found_data),$
           phi:fltarr(found_data), theta:fltarr(found_data),$
           source:intarr(found_data),year:intarr(found_data),$
           day:intarr(found_data),hour:intarr(found_data)}

;---


  imfdata.bx=imfbx(finder)
  imfdata.by=imfby(finder)
  imfdata.bz=imfbz(finder)
  imfdata.source=imf(finder)
  imfdata.year=year_arr(finder)
  imfdata.day=day_arr(finder)
  imfdata.hour=hour_arr(finder)

  swdata.vel=vel_arr(finder)
  swdata.den=den_arr(finder)
  swdata.phi=phi_arr(finder)
  swdata.theta=theta_arr(finder)
  swdata.source=pls(finder)
  swdata.year=year_arr(finder)
  swdata.day=day_arr(finder)
  swdata.hour=hour_arr(finder)
  

endif else begin
    imfdata = {bx:-1,by:-1,bz:-1,source:-1}
    swdata  = {vel:-1,den:-1,phi:-1,theta:-1}
endelse

cdf_close,id


;stop
end
