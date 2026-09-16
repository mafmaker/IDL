;$Author: kovalick $
;$Date: 1998/10/23 20:28:01 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/bar_chart.pro,v 1.3 1998/10/23 20:28:01 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.3 $
;-------------------------------------------------------------------------
; FUNCTION bar_chart, bar_names, bars, times, COLORS
;   bar_names : strarr(n)
;   bars      : lonarr(n,m)
;   times     : double(m)
; FUNDAMENTAL PROBLEM:  bar chart showing data availability needs two points
;                       to plot, (start and end), not just a single point like
;                       a time-series plot.
;
; APPROACH:  a) Find first non-zero bars point.  Draw until next zero point.
;            b) repeat until done.
;--------------------------------------------------------------------------
FUNCTION bar_chart,bar_names,bars,times,COLORS=COLORS,DEBUG=DEBUG,GIF=GIF,$
                                        TITLE=TITLE,XSIZE=XSIZE

; Validate input parameters.  Bars should be a intarr(n,m), bar_names should
; be strarr(n), times should be dblarr(m) of CDF_EPOCH times.
print,'bar_chart parameter validation TBD.'

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

; Initialize plotting parameters
pheight=10
if keyword_set(XSIZE) then xs=XSIZE else xs=500
ys = (ntags * pheight)+100 ; compute window size

; Open GIF file or xwindow
if keyword_set(GIF) then begin
  deviceopen,6,fileOutput=GIF,sizeWindow=[xs,ys]
endif else begin
  window,/free,xsize=xs,ysize=ys,title='Bar Chart'
endelse
; ct_bar_chart ; load bar chart color table

; add ytickname set to blanks to over-ride the default numeric labels
yticknames = make_array(30, /string, value = ' ')

; Create empty plot and frame it

plot,[0,1],[1,0],/nodata,xrange=[secs(0),secs(ntimes-1)],xmargin=[12,4],$
         xstyle=5,xticklen=0.01,xcharsize=0.8,yrange=[0,ntags],ystyle=1,$
         yticklen=1.0, ytickname=yticknames
;TJK added yticklen=1.0, above to create a y grid, and had to change ystyle
;from 5 to 1 in order to see the grids.  Then had to add ytickname set
;to blanks to over-ride the default numeric labels

plots,[secs(0),secs(0)],[0,ntags]
plots,[secs(ntimes-1),secs(ntimes-1)],[0,ntags]

; Plot the inventory data
for i=0,ntags-1 do begin ; process each dataset
  bar = bars(i,*) & bar = reform(bar) & from=0L & to=0L & done=0L & c=max(bar)
  while done eq 0 do begin
    w = where(bar(from:ntimes-1) ne 0,wc) ; find where next sub-bar starts
    if wc gt 0 then begin & from = from + w(0)
      u = where(bar(from:ntimes-1) eq 0,uc) ; find sub-bar end
      if uc eq 0 then to=(ntimes-1) else to=from+(u(0)-1)
      plots,([secs(from),secs(to)]),([1,1]*ntags-i),thick=8,color=c
    endif else done=1
    from = to+1 & if from eq ntimes then done=1
  endwhile
  ypos = convert_coord(([1,1]*ntags-i),/data,/to_device)
  xyouts,5,(ypos(1)-2),bar_names(i),/device,color=c
endfor

; Title and subtitle the plot
if keyword_set(TITLE) then xyouts,(xs/2),(ys-11),TITLE,/device,alignment=0.5
timeaxis_text,FORM=tform,JD=julday,title=subtitle,CHARSIZE=0.9,TICKLEN=1,$
              major=0, NTICKS=12
;TJK added major=1 above to add a grid on the x axis

if keyword_set(GIF) then begin
  deviceclose & set_plot,'X'
endif
return,0
end
