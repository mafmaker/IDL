;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/bar_chart.pro,v 1.14 2009/04/09 17:27:09 johnson Exp johnson $
;$Locker: johnson $
;$Revision: 7092 $
;-------------------------------------------------------------------------
; FUNCTION bar_chart, bar_names, bars, times, COLORS, BIGPLOT=BIGPLOT,
; FIVEYEAR=FIVEYEAR, COLORNEW=COLORNEW, long_line=long_line, wide_margin=wide_margin
;   bar_names : strarr(n)
;   bars      : lonarr(n,m)
;   times     : double(m)
;   long_line: 0/1  to draw a line between availability bar and dataset name.
;                   Best when it's difficult to tell what bar goes w/ what dataset
;                   because of the distance between them.
;   wide_margin: 0/1  when need wider margin on left side because of long dataset names.
;
; FUNDAMENTAL PROBLEM:  bar chart showing data availability needs two points
;                       to plot, (start and end), not just a single point like
;                       a time-series plot.
;
; APPROACH:  a) Find first non-zero bars point.  Draw until next zero point.
;            b) repeat until done.
;--------------------------------------------------------------------------
FUNCTION bar_chart,bar_names,bars,times,COLORS=COLORS,DEBUG=DEBUG,GIF=GIF,$
                  TITLE=TITLE,XSIZE=XSIZE,BIGPLOT=bigplot,FIVEYEAR=fiveyear,$
                  COLORNEW=colornew, long_line=long_line, wide_margin=wide_margin

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
;else tform='n$ d$@y$'
; The above format is not good if we're trying to plot decades of inventory data.RCJ 09/26/02
else tform='n$@y$'

; Initialize plotting parameters
pheight=10
if keyword_set(XSIZE) then xs=XSIZE else xs=500
;ys = (ntags * pheight)+100 ; compute window size
ys = (ntags * pheight)+130 ; compute window size - increase size to allow for date line

; Open GIF file or xwindow
if keyword_set(GIF) then begin
  deviceopen,6,fileOutput=GIF,sizeWindow=[xs,ys]
endif else begin
  window,/free,xsize=xs,ysize=ys,title='Bar Chart'
endelse
; ct_bar_chart ; load bar chart color table


; Create empty plot and frame it
;plot,[0,1],[1,0],/nodata,xrange=[secs(0),secs(ntimes-1)],xmargin=[15,4],$ ; allow for date
;plot,[0,1],[1,0],/nodata,xrange=[secs(0),secs(ntimes-1)],xmargin=[15,4],ymargin=[6,2],$
; RCJ 12/11/2003 Changed xmargin to fit longer dataset names 

;plot,[0,1],[1,0],/nodata,xrange=[secs(0),secs(ntimes-1)],xmargin=[17,4],ymargin=[6,4],$
;       xstyle=5,xticklen=0.01,xthick=3.0, yrange=[0,ntags],ystyle=1,$

print,'ntags = ', ntags
ytickm = ntags/10
;TJK IDL has a limit on the number of ticks, labels can't be over 60...
if (ytickm ge 60) then ytickm = 40
if (ytickm lt 1) then ytickm = ntags
;print, 'TJK DEBUG requesting ',ytickm,' y ticks'
; add ytickname set to blanks to over-ride the default numeric labels
yticknames = make_array(ytickm+1, /string, value = ' ') 

if keyword_set(wide_margin) then thisxmargin=[40,4] else thisxmargin=[20,4]
plot,[0,1],[1,0],/nodata,xrange=[secs(0),secs(ntimes-1)],xmargin=thisxmargin,ymargin=[8,4],$
       xstyle=5,xticklen=0.01,xthick=2.0, yrange=[0,ntags],ystyle=1,$
       yticklen=1.0, ytickname=yticknames, ythick=4.0, yticks=ytickm

;TJK added yticklen=1.0, above to create a y grid, and had to change ystyle
;from 5 to 1 in order to see the grids.  Then had to add ytickname set
;to blanks to over-ride the default numeric labels

plots,[secs(0),secs(0)],[0,ntags]
plots,[secs(ntimes-1),secs(ntimes-1)],[0,ntags]

c = 48 ;default color blue
recent_data_color = 100 ; has to match the color set in ingest_database

maxl=max(strlen(bar_names))  ; if long_line=1 this will be needed further down
; Plot the inventory data
for i=0,ntags-1 do begin ; process each dataset
  bar = bars(i,*) & bar = reform(bar) & from=0L & to=0L & done=0L ;TJK c=max(bar)
  while done eq 0 do begin
    w = where(bar(from:ntimes-1) ne 0,wc) ; find where next sub-bar starts
    if wc gt 0 then begin & from = from + w(0)
      u = where(bar(from:ntimes-1) eq 0,uc) ; find sub-bar end
      if uc eq 0 then to=(ntimes-1) else to=from+(u(0)-1)
      plots,([secs(from),secs(to)]),([1,1]*ntags-i),thick=8,color=c
      if keyword_set(long_line) then plots,([secs(0),secs(ntimes-1)]),([1,1]*ntags-i),thick=1,color=c
    endif else done=1
    from = to+1 & if from eq ntimes then done=1
  endwhile

;TJK add a second loop to plot the more recent data in a bright blue color
  if keyword_set(COLORNEW) then begin

    from=0L & to=0L & done=0L ;TJK c=max(bar)

    while done eq 0 do begin
      w = where((bar(from:ntimes-1) ne 0 and bar(from:ntimes-1) ne c),wc) ; find where next sub-bar starts
      if wc gt 0 then begin & from = from + w(0)
        u = where((bar(from:ntimes-1) eq 0) or (bar(from:ntimes-1) eq c),uc) ; find sub-bar end
        if uc eq 0 then begin
          to=(ntimes-1) 
;          print,'For ',bar_names(i), ' found some recent data ',from, to
          plots,([secs(from),secs(to)]),([1,1]*ntags-i),thick=8,color=recent_data_color
        endif else begin
          to = from+(u(0)-1)
          recent = where(bar(from:to) eq recent_data_color, rc) ;look inbetwen from and next 0
          if (rc gt 0) then begin                                   ;for "recent" data
            to=from+(rc-1)
;            print,'For ',bar_names(i), ' found some recent data ',from, to
            plots,([secs(from),secs(to)]),([1,1]*ntags-i),thick=8,color=recent_data_color
          endif
        endelse
      endif else done=1
      from = to+1 & if from eq ntimes then done=1
    endwhile
  endif
;TJK end second loop
  ypos = convert_coord(([1,1]*ntags-i),/data,/to_device)
  if keyword_set(long_line) then begin
     for j=strlen(bar_names(i)), maxl do bar_names(i)=bar_names(i)+'_'
     xyouts,5,ypos(1),bar_names(i),/device,color=c
  endif else xyouts,5,(ypos(1)-2),bar_names(i),/device,color=c
endfor

; Title and subtitle the plot
if keyword_set(TITLE) then xyouts,(xs/2),(ys-9),TITLE,/device,alignment=0.5

;TJK 9/14/2005 - adding a label at the top (for Bob)
timeaxis_text,FORM=tform,JD=julday,CHARSIZE=1.05,TICKLEN=1,$
major=0, NTICKS=12, /onlylabel, yvalue=ntags+3.5, BIGPLOT=bigplot, FIVEYEAR=fiveyear

;timeaxis_text,FORM=tform,JD=julday,title=subtitle,CHARSIZE=0.9,TICKLEN=1,$
;RCJ 12/11/2003  Changed charsize. 0.9 seems too small.
timeaxis_text,FORM=tform,JD=julday,title=subtitle,CHARSIZE=1.05,TICKLEN=1,$
              major=0, NTICKS=12, thick=1.0, BIGPLOT=bigplot, FIVEYEAR=fiveyear

if keyword_set(COLORNEW) then begin
  xyouts,((xs/4)+6),20, '= Data added/updated since Sept. 2003', /device
  plots,(xs/4),22,/device,psym=6, thick=4, color=recent_data_color
  xyouts,((xs - (xs/3))+6),20, '= Prior to Sept. 2003', /device
  plots,(xs - (xs/3)),22,/device,psym=6, thick=4, color=c
endif

generated = 'Generated by CDAWeb on ' + systime()
xyouts,(xs/2),3, generated, /device, alignment=0.5

;TJK added major=1 above to add a grid on the x axis

if keyword_set(GIF) then begin
  deviceclose & set_plot,'X'
endif
return,0
end









