;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/timeaxis_text.pro,v 1.37 2009/10/27 13:14:48 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $
;-------------------------------------------------------------
;+
; NAME:
;       TIMEAXIS_text
; PURPOSE:
;       Plot a time axis.
; CATEGORY:
; CALLING SEQUENCE:
;       timeaxis_text, [t]
; INPUTS:
;       t = optional array of seconds after midnight.  in
; KEYWORD PARAMETERS:
;       Keywords:
;         JD=jd   Set Julian Day number of reference date.
;         FORM=f  Set axis label format string, over-rides default.
;           do help,dt_tm_mak(/help) to get formats.
;           For multi-line labels use @ as line delimiter.
;         NTICKS=n  Set approximate number of desired ticks (def=6).
;         TITLE=txt Time axis title (def=none).
;         TRANGE=[tmin,tmax] Set specified time range.
;         YVALUE=Y  Y coordinate of time axis (def=bottom).
;         TICKLEN=t Set tick length as % of yrange (def=5).
;         /NOLABELS means suppress tick labels.
;         /NOYEAR drops year from automatically formatted labels.
;           Doesn't apply to user specified formats.
;         LABELOFFSET=off Set label Y offset as % yrange (def=0).
;           Allows label vertical position adjustment.
;         DY=d  Set line spacing factor for multiline labels (def=1).
;         COLOR=c   Axis color.
;         CHARSIZE=s    Axis text size.
;         CHARTHICK=cth thickness of label text (def=1).
;         THICK=thk thickness of axes and ticks (def=1).
;         MAJOR=g   Linestyle for an optional major tick grid.
;         MINOR=g2  Linestyle for an optional minor tick grid.
;	  NOTIME = if set, do not display time label
;	  PLABELOFFSET = offset label by this number of pixels
;		Will supersede 'labeloffset' keyword.
;	  ONLYLABEL = if set, will display label only, no axis, no tick marks.
;         AddInfo=addInfor  Array of additional data to be displayed under ticks
;         AddFormat=addFormat  Array of format strings for additional data
;         AddLabel=addLabel  Array of strings to put in front of first tick info
;	  Add_ds=Add_ds Array of strings to put after the last tick on each line
;	         for 
;	  BIGPLOT=bigplot added to allow some special settings for the large CDAWeb
;	  inventory plots.
; OUTPUTS:
; COMMON BLOCKS:
; NOTES:
;       Notes: To use do the following:
;         plot, t, y, xstyle=4
;         timeaxis_text
;         If no arguments are given to TIMEAXIS_text then an
;         axis will be drawn based on the last plot, if any.
;         Try DY=1.5 for PS fonts.
; MODIFICATION HISTORY:
;       R. Sterner, 25 Feb, 1991
;       R. Sterner, 26 Jun, 1991 --- made nticks=0 give default ticks.
;       R. Sterner, 18 Nov, 1991 --- allowed Log Y axes.
;       R. Sterner, 11 Dec, 1992 --- added /NOLABELS.
;       R. Sterner, 20 May, 1993 --- Made date labeling (jd2mdays).
;       Allowed CHARSIZE for SIZE.
;       Robert.M.Candey.1@gsfc.nasa.gov, 22 Sept 1993; added addInfo and
;          addFormat to put data under the times under the tick marks
;       R. Candey, 23 Jun 1995; updated latest version of timeaxis
;
; Copyright (C) 1991, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
pro timeaxis_text, t, jd=jd, form=form, nticks=nticks, $
	  yvalue=yvalue, trange=trange, color=color, size=size, $
	  help=hlp, ticklen=ticklen, labeloffset=laboff, dy=dy, $
	  title=title, major=grid, minor=grid2, charthick=charthick,$
	  thick=thick, nolabels=nolabels, noyear=noyear, notime=notime, $
	  charsize=charsize , plabeloffset=plaboff, onlylabel = onlylabel,$
          addInfo=addInfo, addFormat=addFormat, addLabel=addLabel, $
	  Add_ds=Add_ds, BIGPLOT=bigplot,FIVEYEAR=fiveyear
 
 
if keyword_set(hlp) then begin
   ;help:
   print,' Plot a time axis.'
   print,' timeaxis_text, [t]'
   print,'   t = optional array of seconds after midnight.  in'
   print,' Keywords:'
   print,'   JD=jd   Set Julian Day number of reference date.'
   print,'   FORM=f  Set axis label format string, over-rides default.'
   print,'     do help,dt_tm_mak(/help) to get formats.'
   print,'     For multi-line labels use @ as line delimiter.'
   print,'   NTICKS=n  Set approximate number of desired ticks (def=6).'
   print,'   TITLE=txt Time axis title (def=none).'
   print,'   TRANGE=[tmin,tmax] Set specified time range.'
   print,'   YVALUE=Y  Y coordinate of time axis (def=bottom).'
   print,'   TICKLEN=t Set tick length as % of yrange (def=5).'
   print,'   /NOLABELS means suppress tick labels.'
   print,'   /NOYEAR drops year from automatically formatted labels.'
   print,"     Doesn't apply to user specified formats."
   print,'   LABELOFFSET=off Set label Y offset as % yrange (def=0).'
   print,'     Allows label vertical position adjustment.'
   print,'   DY=d  Set line spacing factor for multiline labels (def=1).'
   print,'   COLOR=c   Axis color.'
   print,'   CHARSIZE=s    Axis text size.'
   print,'   CHARTHICK=cth thickness of label text (def=1).'
   print,'   THICK=thk thickness of axes and ticks (def=1).'
   print,'   MAJOR=g   Linestyle for an optional major tick grid.'
   print,'   MINOR=g2  Linestyle for an optional minor tick grid.'
   print,'   NOTIME = if set, do not display time label.'
   print,'   PLABELOFFSET = offset label by this number of pixels'
   print,'        Will supersede labeloffset keyword.'
   print,'   ONLYLABEL = if set, will display label only, no axis, no tick marks.'
   print,'   AddInfo=addInfo  Array of additional data to be displayed under ticks'
   print,'   AddFormat=addFormat  Array of format strings for additional data'
   print,'   AddLabel=addLabel  Array of strings to put in front of first tick info'
   print,'   Addds=Add_ds  Array of strings to put in behind the last tick label'
   print,' Notes: To use do the following:'
   print,'   plot, t, y, xstyle=4'
   print,'   timeaxis_text'
   print,'   If no arguments are given to TIMEAXIS_text then an'
   print,'   axis will be drawn based on the last plot, if any.'
   print,'   Try DY=1.5 for PS fonts.'
   return
endif
 
cr = string(13b)			; Carriage Return.
if n_elements(charsize) ne 0 then size = charsize
if keyword_set(onlylabel) then onlylabel=1 else onlylabel=0
;=================  Find Axis Endpoints  =============================
;-----  Values are in seconds after midnight of a reference date.
;-----  At this point in the routine the reference is not yet
;-----  determined.
;---------------------------------------------------------------------
 
if n_params(0) ge 1 then begin		; First try from given array.
   xmn = min(t)
   xmx = max(t)
endif
 
if n_elements(trange) ne 0 then begin	; Over-ride with range.
   xmn = trange(0)
   xmx = trange(1)
endif
 
if n_elements(xmn) eq 0 then begin	; Neither time array, t, or
   xmn = !x.crange(0)			; time range, trange, given,
   xmx = !x.crange(1)			; so use last plot range.
endif

if (xmn + xmx) eq 0 then begin
   ;goto, help
   print,'Min and max in x-axis are the same. Timeaxis_text failed.'
   return
endif
 
 
;====================  Find Axis Numbers  ============================
;-----  If the keyword JD=jd is given it is used as the reference
;-----  date, otherwise the days start counting up from 1.
;---------------------------------------------------------------------
 
;------------  Number of labeled tic marks. -----------------------
if n_elements(nticks) eq 0 then nticks=0	; Number of ticks.
if nticks eq 0 then nticks = 6   
;rc assume 10 characters per tick label
maxTicks = fix((!x.window(1)-!x.window(0))*!d.x_size/!d.x_ch_size/10.)
if (nticks gt maxTicks) then nticks = maxTicks > 2
;rc 

;-----  First find ticks for the case where JD is not given  ----------
;-----  or the time span is not more than 10 days.  -------------------
;-- Find axis labeled (major) and unlabeled (minor) tick positions. --- 
; Check input field for tnaxes to avoid error RTB 12/96
xdif1=xmx-xmn
; needed to be able to plot between 1sec and 10sec.
; so commented out the lines below and made nticks=1 if between 1 and 10sec.
; RCJ 07/00 
;if(xdif1 le 9) then begin
;   print, "STATUS=< 10 sec. of data available for selected interval"
;   return
;endif

if(xdif1 le 9) then nticks=3
if(xdif1 le .9) then nticks=5
;print, 'DEBUG, timeaxis_text xdif1 = ',xdif1, ' nticks set to ',nticks
tnaxes, xmn, xmx, nticks, tt1, tt2, dtt, t1, t2, dt, form=frm   ; Axis numbers.
;print, 'DEBUG, timeaxis_text: ',tt1, tt2, dtt, t1, t2, dt, frm

v = makex( tt1, tt2, dtt)	; Major ticks sec after midnight.
v2 = makex(t1, t2, dt)		; Minor ticks sec after midnight.
;print, 'DEBUG, timeaxis_text: after tnaxes call nticks set to ',nticks
;print,'timeaxis_text: major ticks = ', v
;print, 'timeaxis_text: minor ticks = ',v2
;stop;
;------  If JD given AND range > 10 days use month labels  --------
if (n_elements(jd) ne 0) and ((xmx-xmn) gt 864000.) then begin
   jd1 = jd + xmn/86400.d0	; JD of xmn.
   jd2 = jd + xmx/86400.d0	; JD of xmx.
   jd2mdays, jd1, jd2, approx=dtt/86400.d0, maj=mjr, min=mnr, form=frm
   ; RCJ 01/28/2003   Trying to fix the x-axis labels for sp_phys inventory graph.
   ;   Labels are so close together we can barely read them. The '20' is arbitrary.
   if n_elements(mjr) gt 20 then begin
      mjr1=0
      for i=0,n_elements(mjr)-1,2 do mjr1=[mjr1,mjr(i)]
      mjr=mjr1[1:*]
   endif   
   if keyword_set(noyear) then frm = getwrd(frm,-99,-1,/last)
   v = (mjr-jd)*86400.d0		; Major ticks sec after midnight on JD.
   v2 = (mnr-jd)*86400.d0	; Minor ticks sec after midnight on JD.
endif
 
;=========  Find labels, tick lengths, axis position.  ==============
 
;--------  Make axis labels  ------------
if n_elements(form) eq 0 then form = ''		; Label format.
if form eq '' then form = frm
; Not sure why line below was needed. It overrides any choice of 'form'... RCJ 09/26/02
;form='h$:m$:s$@y$ n$ d$'
lab = time_label(v, form, jd=jd)

;--------  Tick length  ---------------
ycr = !y.crange					; Y data range.
if !y.type eq 1 then ycr = 10^ycr		; Was log Y axis.
tmp = convert_coord([0,0],ycr,/data,/to_dev)	; Find in device coord.
yrange = tmp(4) - tmp(1)			; Full y range (pixels).
if n_elements(ticklen) eq 0 then ticklen = 3.	; Labeled tick length.
oneperc = yrange/100.				; 1% (pixels)
tickl = ticklen*oneperc				; Tick in pixels.
	
;-------  Axis y position  ------------
yv = !y.crange(0)	         		; Lower x axis y value.
if !y.type eq 1 then yv = 10^yv			; Allow log y axis.
if n_elements(yvalue) ne 0 then begin
   yv = yvalue
endif

;==================  Plot axis  =====================
;	mxlines = 1
;-------  Plot axis  ------------------
if n_elements(color) eq 0 then color = !p.color
if n_elements(size) eq 0 then size = 1.
if (!p.multi(1)>!p.multi(2)) gt 2 then size=size/2.
if n_elements(charthick) eq 0 then charthick = 1.
if n_elements(thick) eq 0 then thick = 1.
if n_elements(laboff) eq 0 then laboff = 0.
if n_elements(dy) eq 0 then dy = 1.
if (onlylabel eq 0) then plots, !x.crange, [yv, yv], color=color, thick=thick
tmp = convert_coord(v,v*0.+yv,/data,/to_dev)
ix = round(tmp(0,*))
iy = round(tmp(1,*))
iymin = (iy+tickl)<iy			; Want min dev Y used.
iyt = iymin				; Axis or bottom of tick.
;rc	for i = 0, n_elements(v)-1 do begin	; Major (Labeled) ticks.
;rc	  plots, [ix(i),ix(i)], [iy,iy+tickl], color=color, /dev, thick=thick
;rc	  if keyword_set(nolabels) then goto, skip
;rc;	  xprint, /init, ix(i) ,iy-laboff*oneperc, /dev, $
;rc	  xprint, /init, ix(i) ,iyt-laboff*oneperc, /dev, $
;rc	    size=size, dy=dy, yspace=ysp, charthick=charthick
;rc	  xprint,' '
;rc	  labtxt = lab(i)
;rc	  for j = 0, 5 do begin

ixmin = ix(0)
Ychsize = float(!d.y_ch_size) * size ; in device coordinates
for i = 0, n_elements(v)-1 do begin	; Major (Labeled) ticks.
   if (onlylabel eq 0) then plots, [ix(i),ix(i)], [iy,iy+tickl], color=color, /dev, thick=thick
   if keyword_set(nolabels) then goto, skip
   if keyword_set(plaboff) then begin
      xprint, /init, ix(i),iyt+plaboff, $
	 /dev, size=size, dy=dy, yspace=ysp, charthick=charthick
   endif else begin
      xprint, /init, ix(i),iyt-oneperc*laboff+min([tickl,0])-ychsize*1.5, $
	 /dev, size=size, dy=dy, yspace=ysp, charthick=charthick
   endelse

   ;xprint,' '
  if not (keyword_set(notime)) then labtxt = lab(i) else labtxt = ''
   if (n_elements(addInfo) ne 0) then begin ; print extra data below time
      addSize = size(addInfo)
      if (addSize(0) eq 2) then begin
         dummy = min(abs(addInfo(*,0) - v(i)), index) ; find array index for closest time
	 ;print,'v(i) = ',v(i), addInfo(0,0),index	
	 labtxt = labtxt + cr
	 for addI = 1, addsize(2)-1 do begin
	    if (n_elements(addFormat) ne 0) then begin
	       addFsize = size(addFormat)
	       if ((addFsize(addFsize(0)+1) eq 7) and $
			(addFsize(addFsize(0)+2) eq addSize(2))) then begin 
	          labtxt = labtxt + string(addInfo(index,addI), $
					format=addFormat(addI))
	       endif else begin ; if string array
		  labtxt = labtxt + string(addInfo(index,addI))
	       endelse
	    endif else begin
	       ;print,i,index,addI,string(addInfo(index,addI))
	       labtxt = labtxt + string(addInfo(index,addI))
	    endelse
	    if (addI ne (addsize(2)-1)) then labtxt = labtxt + cr
	 endfor ; addI
      endif ; addsize(0) eq 2
   endif ; addInfo
   for j = 0, 10 do begin
      ;rc
      txt = getwrd(labtxt, j, delim=cr)
      if txt eq '' then goto, skip
      ;mxlines = mxlines > (j+1)
      xprint, txt, align=.5, color=color,y0=y0, /dev
      iymin = iymin<(y0*!d.y_size)	; Update min dev y used.
   endfor
   skip:
endfor ; major (labeled) ticks
tmp = convert_coord(v2,v2*0.+yv,/data,/to_dev)
ix = round(tmp(0,*))
iy = round(tmp(1,*))
;Don't do these minor ticks for big plots
;if keyword_set(BIGPLOT) then begin
;  print, 'bigplot set in timeaxis_text'
;endif else begin
;  print, 'bigplot NOT set in timeaxis_text'
;endelse

if (not(keyword_set(BIGPLOT) or keyword_set(FIVEYEAR))) then begin
;print, 'DOING MINOR TICKS...'
  if (onlylabel eq 0) then begin
    for i = 0, n_elements(v2)-1 do begin	; Minor ticks.
      plots, [ix(i),ix(i)], [iy,iy+tickl/2.], color=color,/dev,thick=thick
    endfor 
  endif   
endif 
;-------  Top axis  -------------
if n_elements(yvalue) eq 0 then begin
   yv1 = !y.crange(1)
   if !y.type eq 1 then yv1 = 10^yv1
   if (onlylabel eq 0) then plots, !x.crange, [0,0]+yv1, color=color,thick=thick
   tmp = convert_coord(v,v*0.+yv1,/data,/to_dev)
   ix = round(tmp(0,*))
   iy = round(tmp(1,*))
   if (onlylabel eq 0) then begin
      for i = 0, n_elements(v)-1 do begin
         plots, [ix(i),ix(i)], [0,-tickl]+iy, color=color, /dev,thick=thick
      endfor
   endif   

   tmp = convert_coord(v2,v2*0.+yv1,/data,/to_dev)
   ix = round(tmp(0,*))
   iy = round(tmp(1,*))
;Don't do these minor ticks for big plots
 if (not keyword_set(BIGPLOT) and not keyword_set(FIVEYEAR)) then begin
   if (onlylabel eq 0) then begin
      for i = 0, n_elements(v2)-1 do begin	; Minor ticks.
         plots,[ix(i),ix(i)],[0,-tickl/2.]+iy,color=color,/dev,thick=thick
      endfor
   endif    
 endif
endif

;------------  Title  ---------------
if n_elements(title) ne 0 then begin
   tx = total(!x.crange)/2.
   tmp = convert_coord([tx],[yv],/data,/to_dev)
   ix = tmp(0)
   iy = min(iymin)
   xprint,/init,ix,iy,/dev,size=size,dy=dy,charthick=charthick
   xprint,' ',/dev
   xprint,' ',/dev
   ;if laboff ge 0 then for i = 1, mxlines do xprint,' '
   xprint, title, align=.5, color=color, /dev
endif
 
;if keyword_set(BIGPLOT) then begin
;want a vertical line every 2 years w/ dark lines every 10
;the default is to draw vertical lines every year.
;if keyword_set(FIVEYEAR) then want vertical lines every .5 year
;w/ darker lines at each year mark.
;	
;-------------  Grids  ----------------
;the ver routine draws vertical lines on a graph...
;
savethick = thick
if n_elements(grid) ne 0 then begin		; Major grid.
   for i = 0, n_elements(v)-1 do begin
;for the "bigplots that cover 20 years, the vertical lines and labels are drawn ever 2 years.
;and we want thicker lines ever 10 years (or ever 5th time tag)
      if (keyword_set(BIGPLOT)) then begin
	if ((i eq 0) or (i eq 5) or (i eq 10) or (i eq 15) or (i eq 20) or (i eq 25)) then thick = 4.0 else thick = savethick
      endif
      if (keyword_set(FIVEYEAR)) then begin 
	if ((i eq 0) or (i eq 2) or (i eq 4) or (i eq 6) or (i eq 8) or (i eq 10) or (i eq 12) or (i eq 14) or (i eq 16) or (i eq 18) or (i eq 20)) then thick = 4.0 else thick = savethick
      endif
      ver, v(i), color=color, linestyle=grid, thickness=thick
   endfor
endif
if n_elements(grid2) ne 0 then begin		; Minor grid.
   for i = 0, n_elements(v2)-1 do begin
      if (v2(i) mod dtt) ne 0 then begin
         ver, v2(i), color=color, linestyle=grid2, thickness=thick/2.0
      endif
   endfor
endif
;rc
if (n_elements(addLabel) ne 0) and not keyword_set(nolabels) then begin
   addLsize = size(addLabel)
   if ((addLsize(addLsize(0)+1) eq 7) and (addLsize(0) gt 0)) then begin
      Xchsize = float(!d.x_ch_size) * size ; in device coordinates
      Ychsize = float(!d.y_ch_size) * size ; in device coordinates
      tmp2 = convert_coord(!x.crange,!y.crange,/data,/to_dev)
      xtmp2 = tmp2(0,0) - (max(strlen(addLabel))+5) * Xchsize
      if keyword_set(plaboff) then begin
         ytmp2 = iyt + plaboff
      endif else begin
         ytmp2 = tmp2(1,0) - oneperc*laboff + min([tickl,0]) - ychsize*1.5
      endelse

      xprint, /init, xtmp2 ,ytmp2, /dev, size=size, dy=dy, yspace=ysp, charthick=charthick
      ;xprint,' '
      for i=0,n_elements(addLabel)-1 do begin
         xprint, addLabel(i), align=0., color=color,y0=y0, /dev
      endfor

;TJK add on...
      if (n_elements(add_ds) gt 0)then begin
        if (add_ds(0) ne '') then begin
	  xtmp2 = tmp2(0,1) + (15 * Xchsize)
          xprint, /init, xtmp2 ,ytmp2, /dev, size=size, dy=dy, yspace=ysp, charthick=charthick
          for i=0,n_elements(add_ds)-1 do begin
            xprint, Add_ds(i), align=1., color=color,y0=y0, /dev
          endfor
	endif
      endif

   endif ; string array
endif ; addLabel

;rc	  


return
end
