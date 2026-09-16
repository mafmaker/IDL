;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: $
;$Locker: $
;$Revision: 8 $
;-------------------------------------------------------------------------
; Written by TJK on 11/10/1999
; FUNCTION print_inv_stats, bar_names, bars, times, /file
;   bar_names : strarr(n)
;   bars      : lonarr(n,m)
;   times     : double(m)
; FUNDAMENTAL PROBLEM:  Need to be able to produce statistics on the cdaweb
;			database.
;
; This is called from inventory_stats (in the inventory.pro) 
;
; 
;--------------------------------------------------------------------------
FUNCTION print_inv_stats,bar_names,bars,times,DEBUG=DEBUG,TITLE=TITLE, file=file

; Validate input parameters.  Bars should be a intarr(n,m), bar_names should
; be strarr(n), times should be dblarr(m) of CDF_EPOCH times.
print,'print_inv_stats parameter validation TBD.'

; Calculate array sizes
ntags = n_elements(bar_names) & ntimes = n_elements(times)

; Create a subtitle for the plot showing the data start and stop times
CDF_EPOCH,times(0),year,month,day,hour,minute,second,milli,/BREAK
subtitle = 'TIME RANGE='+strtrim(string(year),2)+'/'+strtrim(string(month),2)
subtitle = subtitle + '/' + strtrim(string(day),2) + ' to '
CDF_EPOCH,times(ntimes-1),year,month,day,hour,minute,second,milli,/BREAK
subtitle = subtitle + strtrim(string(year),2)+'/'+strtrim(string(month),2)
subtitle = subtitle + '/' + strtrim(string(day),2)

; Convert the time array into seconds since first time
CDF_EPOCH,times(0),year,month,day,hour,minute,second,milli,/BREAK
CDF_EPOCH,a,year,month,day,0,0,0,0,/COMPUTE_EPOCH
secs   = (times - a) / 1000 & julday = ymd2jd(year,month,day)

; Determine label for time axis based on time range
trange = secs(ntimes-1) - secs(0)
if (trange le 60.0) then tform='h$:m$:s$.f$@y$ n$ d$' $
else if (trange le 86400L) then tform='h$:m$@y$ n$ d$'$
else tform='n$ d$@y$'

if keyword_set(file) then file = file else file = tmp.txt
print, 'output being written to ',file

openw, unit, file, /get_lun
printf, unit, 'This file was generated on ',systime()
printf, unit, subtitle
printf, unit, 'Date     Number of distinct datasets'

num_ds_day = intarr(n_elements(times))
num_years = (ntimes/365) + 2
print, 'number of years', num_years
num_ds_month = intarr(num_years,12)
num_days_month = intarr(num_years,12)
year_tag = intarr(num_years)

iyear = 0

for num_days = 0, ntimes-1 do begin
  data_found = where(bars(*,num_days) eq 48, d_count)
  if (d_count gt 0) then begin
    CDF_EPOCH,times(num_days),year,month,day,hour,minute,second,milli,/BREAK
    Num_ds = N_elements(bar_names(data_found))
    date = strtrim(string(year),2)+'/'+strtrim(string(month),2)
    date = date + '/' + strtrim(string(day),2)

    if (month eq 1 and day eq 1) then begin
	iyear = iyear + 1 & print, 'iyear = ',iyear
    endif
    num_ds_month(iyear,month-1) = num_ds_month(iyear,month-1) + num_ds ; tally by month
    num_days_month(iyear,month-1) = num_days_month(iyear,month-1) + 1
    year_tag(iyear) = year

    printf, unit, date, Num_ds
    if (d_count le 20) then num_ds_day(num_days) = 20
    if (d_count ge 21 and d_count le 40) then num_ds_day(num_days) = 40
    if (d_count ge 41 and d_count le 60) then num_ds_day(num_days) = 60
    if (d_count ge 61 and d_count le 80) then num_ds_day(num_days) = 80
    if (d_count ge 81 and d_count le 100) then num_ds_day(num_days) = 100
    if (d_count ge 101 and d_count le 120) then num_ds_day(num_days) = 120
  endif else num_ds_day(num_days) = 1

endfor
;print out the averaged stats by the month
printf, unit, 'Date	Average number of datasets'
for y = 0, num_years-1 do begin
  if (year_tag(y) gt 0) then begin
    for m = 0, 11 do begin
      d_title = strtrim(string(year_tag(y)),2)+'/'+strtrim(string(m+1),2)+' '
      if (num_days_month(y,m) gt 0) then begin
        printf, unit, d_title,num_ds_month(y,m)/num_days_month(y,m) 
      endif else printf, unit, d_title, 'no stats requested/available'
    endfor
  endif
endfor 


  found = where(num_ds_day eq 1, ds_count) & printf, unit, 'num days where 0 datasets = ',ds_count
  found = where(num_ds_day eq 20, ds_count) & printf, unit, 'num days where 1-20 datasets = ',ds_count
  found = where(num_ds_day eq 40, ds_count) & printf, unit, 'num days where 21-40 datasets = ',ds_count
  found = where(num_ds_day eq 60, ds_count) & printf, unit, 'num days where 41-60 datasets = ',ds_count
  found = where(num_ds_day eq 80, ds_count) & printf, unit, 'num days where 61-80 datasets = ',ds_count
  found = where(num_ds_day eq 100, ds_count) & printf, unit, 'num days where 81-100 datasets = ',ds_count
  found = where(num_ds_day eq 120, ds_count) & printf, unit, 'num days where 101-120 datasets = ',ds_count

close, unit

; Plot the inventory data
;for i=0,ntags-1 do begin ; process each dataset
;  bar = bars(i,*) & bar = reform(bar) & from=0L & to=0L & done=0L & c=max(bar)
;  while done eq 0 do begin
;    w = where(bar(from:ntimes-1) ne 0,wc) ; find where next sub-bar starts
;    if wc gt 0 then begin & from = from + w(0)
;      u = where(bar(from:ntimes-1) eq 0,uc) ; find sub-bar end
;      if uc eq 0 then to=(ntimes-1) else to=from+(u(0)-1)
;      plots,([secs(from),secs(to)]),([1,1]*ntags-i),thick=8,color=c
;    endif else done=1
;    from = to+1 & if from eq ntimes then done=1
;  endwhile
;  ypos = convert_coord(([1,1]*ntags-i),/data,/to_device)
;  xyouts,5,(ypos(1)-2),bar_names(i),/device,color=c
;endfor

return,0
end
