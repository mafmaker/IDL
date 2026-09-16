;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/plot_stack.pro,v 1.36 2009/07/22 17:54:01 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $
;+------------------------------------------------------------------------
; NAME: PLOT_STACK
; PURPOSE: To generate a multiple line time series plot given the 
;	   anonymous structures returned by the read_mycdf function.
; CALLING SEQUENCE:
;       out = plot_stack(Xstruct,Ystruct)
; INPUTS:
;       Xstruct = structure containing the Epoch variable structure of the
;                 type returned by the read_mycdf structure.
;       Ystruct = structure containing the variable to be plotted against
;                 the Epoch variable in the Xstruct parameter
;	Zstruct = structure containing the variable to be used as the color
;		  bar for scaling and labeling purposes.
; KEYWORD PARAMETERS:
;       TSTART   = Forces the time axis to begin at this Epoch time.
;       TSTOP    = Forces the time axis to end at this Epoch time.
;       ELEMENTS = if set, then only these elements of a dimensional variable
;                  will be plotted.
;       POSITION = If set, this routine will draw the plot(s) at this position
;                  of an existing window, rather than open a new one.
;       FIRSTPLOT= Use this key in conjunction with the position keyword. Set
;                  this flag to indicate that the variable is the first in the
;                  window.
;       LASTPLOT = Use this key in conjunction with the position keyword. Set
;                  this flag to indicate that the variable is the last in the
;                  window.
;       PANEL_HEIGHT = vertical height, in pixels, of each panel
;       CDAWEB   = If set, the plot will have sufficient margin along the Z
;                  axis to hold a colorbar.
;       GIF      = If set, the plot will be a .gif file instead of Xwindow
;       XSIZE    = if set, forces the plot window to this width
;       YSIZE    = if set, forces the plot window to this height
;       AUTO     = if set, turns auto-scaling on
;       NOGAPS   = if set, eliminates data gap scanning
;       NONOISE  = if set, filter out values outside 3 sigma from mean
;       IGNORE_DISPLAY_TYPE = if set, causes the attribute display_type to
;                             be ignored.
;       DEBUG    = if set, turns on additional debug output.
;	COLORBAR = if set, turns on a colorbar associated w/ each line
;	 	   being plotted. (TJK)
;       NOSUBTITLE = if set, will not print 'time range = ' subtitle even after
;                       the last graph. Needed for timetext case. RCJ
;	COMBINE = if set, need to add the dataset name to the y axis label
;		  added 10/14/2003 - TJK.	
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       Tami Kovalick; April 24, 1997
;	Based on plot_timeseries.pro
; MODIFICATION HISTORY:
;       
;-------------------------------------------------------------------------
FUNCTION plot_stack, Xvar, Yvar, Zvar,$
                          TSTART=TSTART,TSTOP=TSTOP,ELEMENTS=ELEMENTS,$
                          POSITION=POSITION,PANEL_HEIGHT=PANEL_HEIGHT,$
                          FIRSTPLOT=FIRSTPLOT,LASTPLOT=LASTPLOT,$
                          CDAWEB=CDAWEB,GIF=GIF,COMBINE=COMBINE,$
                          XSIZE=XSIZE,YSIZE=YSIZE,$
                          AUTO=AUTO,NOGAPS=NOGAPS,NOVALIDS,$
                          IGNORE_DISPLAY_TYPE=IGNORE_DISPLAY_TYPE,$
                          NONOISE=NONOISE,DEBUG=DEBUG,REPORT=REPORT,$
			  COLORBAR=COLORBAR, NOSUBTITLE=NOSUBTITLE, $
			  _EXTRA=EXTRAS


; Open report file if keyword is set
if keyword_set(REPORT) then begin & reportflag=1L
  a=size(REPORT) & if (a(n_elements(a)-2) eq 7) then $
  OPENW,1,REPORT,132,WIDTH=132
endif else reportflag=0L

; Verify that both Xvar and Yvar are present
if (n_params() ne 3) then begin
  print,'ERROR=Missing parameter to plot_stack function' & return,-1
endif

; Verify the type of the first parameter and retrieve the data
a = size(Xvar)
if (a(n_elements(a)-2) ne 8) then begin
  print,'ERROR=1st parameter to plot_stack not a structure' & return,-1
endif else begin
  a = tagindex('DAT',tag_names(Xvar))
  if (a(0) ne -1) then times = Xvar.DAT $
  else begin
    a = tagindex('HANDLE',tag_names(Xvar))
    if (a(0) ne -1) then handle_value,Xvar.HANDLE,times $
    else begin
      print,'ERROR=1st parameter does not have DAT or HANDLE tag' & return,-1
    endelse
    b = size(times)
    if (b(n_elements(b)-2) ne 5) then begin
      print,'ERROR=1st parameter datatype not CDF EPOCH' & return,-1
    endif
  endelse
endelse
szck=size(times)
if(szck(szck(0)+2) ne 1) then $ ; RTB added to prevent reform(scalar)
       times = reform(times) ; eliminate any redundant dimensions

; Verify the type of the second parameter and retrieve the data
a = size(Yvar)
if (a(n_elements(a)-2) ne 8) then begin
  print,'ERROR=2nd parameter to plot_stack not a structure' & return,-1
endif else begin
  YTAGS = tag_names(Yvar) ; avoid multiple calls to tag_names
  a = tagindex('DAT',YTAGS)
  if (a(0) ne -1) then THEDATA = Yvar.DAT $
  else begin
    a = tagindex('HANDLE',YTAGS)
    if (a(0) ne -1) then handle_value,Yvar.HANDLE,THEDATA $
    else begin
      print,'ERROR=2nd parameter does not have DAT or HANDLE tag' & return,-1
    endelse
  endelse
endelse
szck=size(thedata)
if(szck(szck(0)+2) ne 1) then $ ; RTB added to prevent reform(scalar)
      thedata = reform(thedata) ; eliminate any redundant dimensions

; Verify the type of the third parameter and retrieve the data
a = size(Zvar)
if (a(n_elements(a)-2) ne 8) then begin
  print,'ERROR=3rd parameter to plot_stack not a structure' & return,-1
endif else begin
  ZTAGS = tag_names(Zvar) ; avoid multiple calls to tag_names
  a = tagindex('DAT',ZTAGS)
  if (a(0) ne -1) then THECOLOR = Zvar.DAT $
  else begin
    a = tagindex('HANDLE',ZTAGS)
    if (a(0) ne -1) then handle_value,Zvar.HANDLE,THECOLOR $
    else begin
      print,'ERROR=3rd parameter does not have DAT or HANDLE tag' & return,-1
    endelse
  endelse
endelse
szck=size(thecolor)
if(szck(szck(0)+2) ne 1) then $ ; RTB added to prevent reform(scalar)
      thecolor = reform(thecolor) ; eliminate any redundant dimensions


; Verify type of data and determine the number of panels that will be plotted
; and which elements of the data array are to be plotted.
a = size(thedata) & b = a(n_elements(a)-2) & thedata_size = a
if ((b eq 0) OR (b gt 5)) then begin
  print,'STATUS=datatype indicates that data is not plottable' & return,-1
endif else begin
  case a(0) of
  0   : begin
;        print,'ERROR=Single data points are not plottable' & return,-1
        print,'STATUS=Re-select longer time interval. Single data points are not plottable' & return,-1
        end
  1   : begin
;      num_plots = 1L & elist=0 ;TJK 1/20/2004 for this type of plot, 1 records
;	worth of data is also not plottable.
        print,'STATUS=Re-select longer time interval. Single data points are not plottable' & return,-1
        end
  2   : begin ; #panels determined by dimensionality or by display type
        elist=indgen(a(1))
        if keyword_set(ELEMENTS) then elist = ELEMENTS $
        else begin
          if NOT keyword_set(IGNORE_DISPLAY_TYPE) then begin
            b = tagindex('DISPLAY_TYPE',YTAGS)
            if (b(0) ne -1) then begin ; evaluate the display type
              c = strupcase(Yvar.(b(0))) & c = break_mystring(c,delimiter='>')
              if ((c(0) eq 'STACK_PLOT')AND(n_elements(c) gt 1)) then begin
                d = break_mystring(c(1),delimiter=',')
                elist = long(d) & elist = elist -1
              endif
            endif
          endif
        endelse
        end
  else: begin
        print,'ERROR=Cannot plot data with > 2 dimensions' & return,-1
        end
  endcase
endelse
num_plots = n_elements(elist)

; Determine the proper start and stop times of the plot
tbegin = times(0) & tend = times(n_elements(times)-1) ; default to data
if keyword_set(TSTART) then begin ; set tbegin
  tbegin = TSTART & a = size(TSTART)
  if (a(n_elements(a)-2) eq 7) then tbegin = encode_CDFEPOCH(TSTART)
endif
if keyword_set(TSTOP) then begin ; set tend
  tend = TSTOP & a = size(TSTOP)
  if (a(n_elements(a)-2) eq 7) then tend = encode_CDFEPOCH(TSTOP)
endif

; Compare the range of the time data to the requested start and stop times
pad_front = 0L & pad_end = 0L
if (tbegin lt times(0)) then begin
  if keyword_set(DEBUG) then print,'Padding front of times...'
  times = [tbegin,times] & pad_front = 1L
endif
if (tend gt times(n_elements(times)-1)) then begin
  if keyword_set(DEBUG) then print,'Padding end of times...'
  times = [times,tend] & pad_end = 1L
endif

; Determine the first and last data time points to be plotted
rbegin = 0L & w = where(times ge tbegin,wc)
if (wc gt 0) then rbegin = w(0)
rend = n_elements(times)-1 & w = where(times le tend,wc)
if (wc gt 0) then rend = w(n_elements(w)-1)
if (rbegin ge rend) then begin
  print,'STATUS=No data within specified time range.' & return,-1
endif

if not (keyword_set(nosubtitle)) then begin
   ; Create a subtitle for the plots showing the data start and stop times
   CDF_EPOCH,tbegin,year,month,day,hour,minute,second,milli,/BREAK
   subtitle = 'TIME RANGE='+strtrim(string(year),2)+'/'+strtrim(string(month),2)
   subtitle = subtitle + '/' + strtrim(string(day),2) + ' to '
   CDF_EPOCH,tend,year,month,day,hour,minute,second,milli,/BREAK
   subtitle = subtitle + strtrim(string(year),2)+'/'+strtrim(string(month),2)
   subtitle = subtitle + '/' + strtrim(string(day),2)
endif else subtitle=''   

; Convert the time array into seconds since tbegin
CDF_EPOCH,tbegin,year,month,day,hour,minute,second,milli,/BREAK
CDF_EPOCH,a,year,month,day,0,0,0,0,/COMPUTE_EPOCH
times  = (times - a) / 1000
julday = ymd2jd(year,month,day)

; Determine label for time axis based on time range
xranger = lonarr(2)
xranger(0) = (tbegin-a)/1000
xranger(1) = (tend-a)/1000
trange = xranger(1) - xranger(0)
if (trange le 60.0) then tform='h$:m$:s$.f$@y$ n$ d$' $
else tform='h$:m$:s$@y$ n$ d$'

; Determine if a new window should be opened for the plots
new_window = 1L ; initialize assuming a new window needs to be created
if keyword_set(POSITION) then begin ; adding to existing plot
  a = size(POSITION) & b = n_elements(a)
  if ((a(b-1) ne 4)OR(a(b-2) ne 3)) then begin
    print,'ERROR=Invalid value for POSITION keyword' & return,-1
  endif
  if keyword_set(PANEL_HEIGHT) then begin ; verify it
    a = size(PANEL_HEIGHT) & b = n_elements(a)
    if ((a(b-2) le 1)OR(a(b-2) gt 5)) then begin
      print,'ERROR=Invalid value for PANEL_HEIGHT keyword' & return,-1
    endif else psize = PANEL_HEIGHT
  endif else begin
    print,'ERROR=PANEL_HEIGHT keyword must be specified with POSITION keyword'
    return,-1
  endelse
  if keyword_set(FIRSTPLOT) then clear_plot = 0L else clear_plot = 1L
  new_window = 0L ; no new window needed
endif

; Determine the size of the new window to be created
if (new_window eq 1) then begin
  if keyword_set(GIF) then begin
    xs = 640 & ys = 512 & psize = 100 ; set default gif sizes
    if keyword_set(XSIZE) then xs = XSIZE ; override if keyword present
    if keyword_set(YSIZE) then ys = YSIZE ; override if keyword present
    if keyword_set(PANEL_HEIGHT) then begin
;TJK      psize = PANEL_HEIGHT & ys = (psize * num_plots) + 100
      psize = PANEL_HEIGHT & ys = psize + 200
    endif else psize = ((ys-100) / num_plots)

  endif else begin ; generating an X-window
    a = lonarr(2) & DEVICE,GET_SCREEN_SIZE=a ; get device resolution
    xs = (a(0)*0.66) & ys = (a(1)*0.66) ; compute defaults
    if keyword_set(XSIZE) then xs = XSIZE ; override if keyword present
    if keyword_set(YSIZE) then ys = YSIZE ; override if keyword present
    if keyword_set(PANEL_HEIGHT) then begin
      psize = PANEL_HEIGHT
;TJK      ys = (psize * num_plots) + 100
      ys = psize + 200
      if (ys gt a(1)) then begin
        print,'ERROR=Computed window Ysize greater than device resolution'
        return,-1
      endif
    endif else psize = ((ys-100) / num_plots)
  endelse
  if (psize lt 50) then begin ; sanity check for #pixels per panel
    print,'ERROR=Insufficient resolution for a ',num_plots,' stack plot'
    return,-1
  endif
endif

; Initialize plotting position arrays and flags
if keyword_set(POSITION) then ppos = POSITION $
else begin
  ppos    = fltarr(4)         ; create position array
;TJK  ppos(0) = 100               ; default plot x origin
;  ppos(2) = (xs - 40)         ; default plot x corner
;  ppos(1) = (ys - 30) - psize ; 1st plot y origin
;  ppos(3) = (ys - 30)         ; 1st plot y corner

;TJK redefined for stacked plot type
  ppos(0) = 100               ; bottom left corner (x)
  ppos(1) = 100	      	      ; bottom left corner (y)
  ppos(2) = (xs - 40)         ; top right corner (x)
  ppos(3) = (ys - 30)         ; top right corner (y)
  if keyword_set(CDAWEB) then ppos(2) = xs - 100 ; set margin for spectrogram
endelse


; Determine the title for the window or gif file
if (new_window eq 1) then begin
  a = tagindex('SOURCE_NAME',YTAGS)
  if (a(0) ne -1) then b = Yvar.SOURCE_NAME else b = ''
  a = tagindex('DESCRIPTOR',YTAGS)
  if (a(0) ne -1) then b = b + '  ' + Yvar.DESCRIPTOR
  window_title = b
endif

; Output debug output if requested
;if keyword_set(DEBUG) then begin
;  print,'TIMEAXIS FORMAT=',tform
;  print,'PANEL HEIGHT=',psize
;  print,'#of PANELS=',num_plots
;  print,'ELEMENT LIST=',elist+1
;  print,'pad_front=',pad_front,' pad_end=',pad_end
;endif

; Create the new window or the gif file
if (new_window eq 1) then begin
  if keyword_set(GIF) then begin
    a = size(GIF) & if (a(n_elements(a)-2) ne 7) then GIF = 'idl.gif'
;TJK commented out, should be handled by plotmaster since its merged w/ the
;time-series and spectrogram plots.
;    deviceopen,6,fileOutput=GIF,sizeWindow=[xs,ys]
    fcolor = 0
  endif else begin ; open x-window display
    clear_plot = 0L ; initialize clear plot flag
;    fcolor = !d.n_colors ;number of available colors
    fcolor = 0 ; now switching the background so that now the
		;text has to be in black.
;TJK commented out, should be handled by plotmaster since its merged w/ the
;time-series and spectrogram plots.
;    deviceopen,0
;    window,/FREE,XSIZE=xs,YSIZE=ys,TITLE=window_title
    
  endelse
endif

; adjust the margin for plots w/ a colorbar
xmargin=!x.margin
if COLORBAR then begin
 if (!x.omargin(1)+!x.margin(1)) lt 14 then !x.margin(1) = 14
 !x.margin(1) = 14
 plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
endif


; Determine the fill value for the Y data and valid min and valid max values
a = tagindex('FILLVAL',YTAGS)
if (a(0) ne -1) then Yfillval = Yvar.FILLVAL else Yfillval = 1.0e31
if (a(0) ne -1) then Zfillval = Zvar.FILLVAL else Zfillval = 1.0e31
  colr_dims = size(thecolor, /n_dimensions)
print, 'DEBUG, stack_plot: number of dimensions in the color variable = ',colr_dims



; EXTRACT THE DATA FOR EACH PANEL AND PLOT
; for a multi line time series plot, instead of plotting each
; y variable (or part of y variable) into a separate "frame",
; we just want to over plot them.  Need to determine a common
; Y scale range for all values and just oplot them.

  ; screen out fill data from the data and the times array for
  ; the portions of the data specified in elist.

  edata = thedata(elist,*)
  all = where(edata ne Yfillval,no_fill)
  mytimes = times(rbegin:rend)
  if (no_fill ne 0) then begin
    scaledata = edata(all) & all=0
  endif else begin
    if(no_fill eq 0) then begin
	all=0
	ylabel = ''
  	a = tagindex('FIELDNAM',YTAGS)
  	if (a(0) ne -1) then ylabel = Yvar.(a(0))
	print, 'STATUS=No non-fill data to display for ',ylabel
	return, -2 ;all data is fill, return a special return code
    endif
  endelse
  ; clear edata
  edata = 0
  ; TJK - change this to be the scale min/max for all of the lines being
  ; plotted.

  ; determine the proper scale for the Y axis
  ymax = 1.0 & ymin = 0.0 ; initialize to any value
  a = tagindex('VALIDMIN',YTAGS)
  if (a(0) ne -1) then begin & b=size(Yvar.VALIDMIN)
   if (string(Yvar.VALIDMIN(0)) ne '') then begin
      if (b(0) eq 0) then ymin = Yvar.VALIDMIN $
      else ymin = min(Yvar.VALIDMIN(elist))
   endif
  endif
  a = tagindex('VALIDMAX',YTAGS)
  if (a(0) ne -1) then begin & b=size(Yvar.VALIDMAX)
   if (string(Yvar.VALIDMAX(0)) ne '') then begin
     if (b(0) eq 0) then ymax = Yvar.VALIDMAX $
     else ymax = max(Yvar.VALIDMAX(elist))
   endif
  endif
  a = tagindex('SCALEMIN',YTAGS)
  if (a(0) ne -1) then begin & b=size(Yvar.SCALEMIN)
   if (string(Yvar.SCALEMIN(0)) ne '') then begin
    if (b(0) eq 0) then ymin = Yvar.SCALEMIN $
    else ymin = min(Yvar.SCALEMIN(elist))
   endif
  endif
  a = tagindex('SCALEMAX',YTAGS)
  if (a(0) ne -1) then begin & b=size(Yvar.SCALEMAX)
   if (string(Yvar.SCALEMAX(0)) ne '') then begin
     if (b(0) eq 0) then ymax = Yvar.SCALEMAX $
     else ymax = max(Yvar.SCALEMAX(elist))
   endif
  endif

  all_ymin = ymin & all_ymax = ymax ;TJK added defaults so that tests below
				    ;will work - 2/4/2004

if (keyword_set(DEBUG)) then print, 'all_ymin/max = ',all_ymin, all_ymax

;TJK 11/28/2007 Add this little section to determine ymin/max for all
;of the data in the array after validmin/max are applied
   w = where(((scaledata gt ymax)OR(scaledata lt ymin)),wc)
    if (wc gt 0) then begin
      if keyword_set(DEBUG) then print,wc,' values outside VALIDMIN/MAX'
      w = where(((scaledata le ymax)AND(scaledata ge ymin)),wb)
      if (wb gt 0) then begin
        scaledata=scaledata(w)
      endif
    endif

  if (keyword_set(AUTO)) then begin ; autoscale based on valid data values
    if (no_fill gt 0) then begin ; cant autoscale if all fill data
      all_ymax = 0.0 & all_ymin = min(scaledata,MAX=all_ymax)
    endif
  endif

if (keyword_set(DEBUG)) then print, 'after applied to data all_ymin/max = ',all_ymin, all_ymax

  if ((all_ymax eq all_ymin) and (round(all_ymin,/L64) eq round(Yfillval,/L64))) then begin
    ylabel = ''
    a = tagindex('FIELDNAM',YTAGS)
    if (a(0) ne -1) then ylabel = Yvar.(a(0))
    print, 'STATUS=All data is fill, please select another time range for ',ylabel  
   ;TJK 11/16/2006 - add code to make a blank white plot
   ;instead of the default black gif.
    plot,[0,1],[0,1],/nodata,ystyle=8+4,xstyle=8+4
    return, -2
  endif

  ; quality check the y scales
  if (all_ymax eq all_ymin) then begin
    all_ymax = all_ymax + 1
    ; RCJ 02/15/02 'all_ymin - 1' -> 'all_ymin - 1.' in case all_ymin
    ; is unsigned number. 
    all_ymin = all_ymin - 1.
  endif

  yranger = fltarr(2) & yranger(0) = all_ymin & yranger(1) = all_ymax

  ; determine the yaxis scale type, natural or logarithmic
  yscaletype = 0L ; initialize assuming natural
  a = tagindex('SCALETYP',YTAGS)
  if (a(0) ne -1) then begin
    if (strupcase(Yvar.SCALETYP) eq 'LOG') then yscaletype = 1L
  endif
  if ((yscaletype eq 1)AND(yranger(0) le 0)) then yranger(0) = 0.00001


; clear out scaledata since its not used below
  scaledata = 0


  ; determine the proper scale for the Z axis
  zmax = 1.0 & zmin = 0.0 ; initialize to any value
  a = tagindex('VALIDMIN',ZTAGS)
  if (a(0) ne -1) then begin & b=size(Zvar.VALIDMIN)
    if (b(0) eq 0) then zmin = Zvar.VALIDMIN $
    else zmin = min(Zvar.VALIDMIN)
  endif
  a = tagindex('VALIDMAX',ZTAGS)
   if (a(0) ne -1) then begin & b=size(Zvar.VALIDMAX)
   if (b(0) eq 0) then zmax = Zvar.VALIDMAX $
   else zmax = max(Zvar.VALIDMAX)
  endif
  a = tagindex('SCALEMIN',ZTAGS)
  if (a(0) ne -1) then begin & b=size(Zvar.SCALEMIN)
    if (b(0) eq 0) then zmin = Zvar.SCALEMIN $
    else zmin = min(Zvar.SCALEMIN)
  endif
  a = tagindex('SCALEMAX',ZTAGS)
   if (a(0) ne -1) then begin & b=size(Zvar.SCALEMAX)
   if (b(0) eq 0) then zmax = Zvar.SCALEMAX $
   else zmax = max(Zvar.SCALEMAX)
  endif
  ; determine the zaxis/color scale type, natural or logarithmic

  zscaletype = 0L ; initialize assuming natural
  a = tagindex('SCALETYP',ZTAGS)
  if (a(0) ne -1) then begin
    if (strupcase(Zvar.SCALETYP) eq 'LOG') then zscaletype = 1L
  endif

;TJK 07/23/2009 - change the logic here to deal w/ record varying
;                 color arrays that may contain fill values - specific
;case of this is wi_m0_swe.

  if (keyword_set(AUTO)) then begin ; autoscale the colorbar based on valid data values
    if (colr_dims eq 2) then begin
        tmpcolor = thecolor(elist,*)
        good_color = where(tmpcolor ne Zfillval,color_fill) 
    endif else begin
        tmpcolor = thecolor(elist)
        good_color = where(tmpcolor ne Zfillval,color_fill)
    endelse
    if (color_fill gt 0) then begin ; cant autoscale if all fill data
      zmax = 0.0 & zmin = min(tmpcolor(good_color),MAX=zmax)
;      zmax = 0.0 & zmin = min(thecolor(elist),MAX=zmax)
;      if (zmin gt 0) then zmin = 0.0 ;TJK so color scale will work out...
    endif
  endif

print, 'DEBUG, plot_stack: zmin and max = ',zmin, zmax

;*****
;10/06/2004 - TJK - for log scaled plots, we need to determine the minimum 
;real value above zero that can be used for reassigning valid/non-fill values
;that are zero and below.  Need to determine this value based on all of the
;Y values requested (not line by line).  Building "gooddata" array and 
;determining "goodmin" value, which is then used below. 
goodmin = -1 ; initialize 
if (yscaletype) then begin ;if log scale
  edata = thedata(elist,*)
  w = where(edata ne Yfillval,non_fillcount)
  if (non_fillcount ne 0) then begin
    gooddata = edata(w) 
  endif else w=0

  ; screen out data outside validmin and validmax values
  if ((NOT keyword_set(NOVALIDS))AND(non_fillcount gt 0)) then begin
    ; determine validmin and validmax values
    a = tagindex('VALIDMIN',YTAGS)
    if (a(0) ne -1) then begin & b=size(Yvar.VALIDMIN)
      if (b(0) eq 0) then Yvmin = Yvar.VALIDMIN $
      else Yvmin = Yvar.VALIDMIN(elist(0))
    endif else Yvmin = 1.0e31
    a = tagindex('VALIDMAX',YTAGS)
    if (a(0) ne -1) then begin & b=size(Yvar.VALIDMAX)
      if (b(0) eq 0) then Yvmax = Yvar.VALIDMAX $
      else Yvmax = Yvar.VALIDMAX(elist(0))
    endif else Yvmax = 1.0e31
    ; proceed with screening
    w = where(((gooddata gt Yvmax)OR(gooddata lt Yvmin)),wc)
    if (wc gt 0) then begin
      if keyword_set(DEBUG) then print,wc,' values outside VALIDMIN/MAX'
      w = where(((gooddata le Yvmax)AND(gooddata ge Yvmin)),wb)
      if (wb gt 0) then begin
        gooddata=gooddata(w)
      endif
    endif
  endif

  ; screen out data outside 3 standard deviations from the mean
  if keyword_set(NONOISE) then begin
    ;semiMinMax,gooddata,Sigmin,Sigmax
    ; RCJ 05/05/2006  Replaced call to semiminmax w/ call to three_sigma
    sigminmax=three_sigma(gooddata)
    sigmin=sigminmax.(0)
    sigmax=sigminmax.(1)
    w = where(((gooddata gt Sigmax)OR(gooddata lt Sigmin)),wc)
    if (wc gt 0) then begin
      w = where(((gooddata le Sigmax)AND(gooddata ge Sigmin)),wb)
      if (wb gt 0) then begin
        gooddata=gooddata(w)
      endif
    endif
  endif

  ; determine actual min value above zero
    wle = where(gooddata le 0.0,wcle)
    if (wcle gt 0) then begin
      w = where(gooddata gt 0.0,wc)
      if (wc gt 0) then begin
	goodmin = min(gooddata(w))/2 ;****finally have goodmin - use below
        if (keyword_set(AUTO)) then yranger(0) = goodmin ;also set scalemin to this value
      endif
    endif
  gooddata = 0; 
endif ;log scale
;*****


; TJK Change variable num_panels to num_plots...

for i=0,num_plots-1 do begin

  ; extract data for a single panel from the data array
  if (thedata_size(0) eq 1) then mydata = thedata $
  else mydata = thedata((elist(i)),*)
  mydata = reform(mydata) ; remove any extraneous dimensions
  ; pad the beginning and end of data if extra time points were added
  if (pad_front) then mydata = [Yfillval,mydata] ; add fill point to front
  if (pad_end) then mydata = [mydata,Yfillval] ; add fill point to back
  ; screen out data points which are outside the plotting time range

; Check data before plotting
rrend=n_elements(mydata)

  if(rrend lt rend) then begin
    print, "STATUS=No Data Available"
    return, -1
  endif

  mytimes = times(rbegin:rend)  
  mydata = mydata(rbegin:rend)
  ; screen out fill data from the data and the times array
  w = where(mydata ne Yfillval,non_fillcount)
  if (non_fillcount ne 0) then begin
    mydata = mydata(w) & mytimes = mytimes(w) & w=0
  endif else w=0

  ; screen out data outside validmin and validmax values
  if ((NOT keyword_set(NOVALIDS))AND(non_fillcount gt 0)) then begin
    ; determine validmin and validmax values
    a = tagindex('VALIDMIN',YTAGS)
    if (a(0) ne -1) then begin & b=size(Yvar.VALIDMIN)
      if (b(0) eq 0) then Yvmin = Yvar.VALIDMIN $
      else Yvmin = Yvar.VALIDMIN(elist(i))
    endif else Yvmin = 1.0e31
    a = tagindex('VALIDMAX',YTAGS)
    if (a(0) ne -1) then begin & b=size(Yvar.VALIDMAX)
      if (b(0) eq 0) then Yvmax = Yvar.VALIDMAX $
      else Yvmax = Yvar.VALIDMAX(elist(i))
    endif else Yvmax = 1.0e31
    ; proceed with screening
    w = where(((mydata gt Yvmax)OR(mydata lt Yvmin)),wc)
    if (wc gt 0) then begin
      if keyword_set(DEBUG) then print,wc,' values outside VALIDMIN/MAX'
      w = where(((mydata le Yvmax)AND(mydata ge Yvmin)),wb)
      if (wb gt 0) then begin
        mydata=mydata(w) & mytimes=mytimes(w)
      endif else begin ;all data outside validmin/max
          ;TJK 11/26/2007 - add code to make a blank white plot
          ;instead of the default black gif, so that if there are good panels,
          ;they'll show up!
          a = tagindex('FIELDNAM',YTAGS)
          ;only print the status message once for each variable
          if(n_elements(ytlabel) eq 0) then begin
            if (a(0) ne -1) then ytlabel = Yvar.(a(0)) else ytlabel = ' '
            print, 'STATUS=All data from at least one element of ',ytlabel,' is fill'
          endif

          if (keyword_set(FIRSTPLOT) and i eq 0)then plot,[0,1],[0,1],/nodata,ystyle=8+4,xstyle=8+4
            ;TJK - don't think this is needed       return, -2

      endelse 

    endif
  endif

  ; screen out data outside 3 standard deviations from the mean
  if keyword_set(NONOISE) then begin
    ;semiMinMax,mydata,Sigmin,Sigmax
    ; RCJ 05/05/2006  Replaced call to semiminmax w/ call to three_sigma
    sigminmax=three_sigma(mydata)
    sigmin=sigminmax.(0)
    sigmax=sigminmax.(1)
    w = where(((mydata gt Sigmax)OR(mydata lt Sigmin)),wc)
    if (wc gt 0) then begin
      if keyword_set(DEBUG) then print,wc,' values outside 3-sigma...'
      w = where(((mydata le Sigmax)AND(mydata ge Sigmin)),wb)
      if (wb gt 0) then begin
        mydata=mydata(w) & mytimes=mytimes(w)
      endif
    endif
  endif

  ; screen non-positive data values if creating a logarithmic plot
  ;TJK 10/06/2004 - instead of throwing out values le 0, reassign them
  if (yscaletype eq 1) then begin
    wle = where(mydata le 0.0,wcle)
    if (wcle gt 0) then begin
      w = where(mydata gt 0.0,wc)
      if (wc gt 0) then begin
	wmin = min(mydata(w))
	mydata(wle) = goodmin ;these goodmin values will be further reassigned in 
			      ;the plotting section below
	w=0
;        if keyword_set(DEBUG) then print,'Screening non-positive values...'
;        mydata = mydata(w) & mytimes = mytimes(w) & w=0
      endif
    endif
  endif

  ; Determine the proper labeling for the y axis
  ylabel = '' & yunits = '' ; initialize
  if keyword_set(COMBINE) then begin
    a = tagindex('LOGICAL_SOURCE',YTAGS)
    if (a(0) ne -1) then yds = strupcase(Yvar.(a(0)))
  endif
  a = tagindex('FIELDNAM',YTAGS)
  if (a(0) ne -1) then ylabel = Yvar.(a(0))
  a = tagindex('LABLAXIS',YTAGS)
  if (a(0) ne -1) then ylabel = Yvar.(a(0))
;don't want these for stack plots
;  a = tagindex('LABL_PTR_1',YTAGS)
;  if (a(0) ne -1) then begin
;    if (Yvar.(a(0))(0) ne '') then ylabel = Yvar.(a(0))(elist(i))
;  endif
  a = tagindex('UNITS',YTAGS)
  if (a(0) ne -1) then yunits = Yvar.(a(0))
;don't want these for stack plots
;  a = tagindex('UNIT_PTR',YTAGS)
;  if (a(0) ne -1) then begin
;    if (Yvar.(a(0))(0) ne '') then yunits = Yvar.(a(0))(elist(i))
;  endif

  if (n_elements(yds) gt 0) then begin
    ylabel = yds + '!C' + ylabel + '!C' + yunits
  endif else ylabel = ylabel + '!C' + yunits

  ; compare the size of the yaxis label to the panel height
  ycsize = 1.0 & ylength = max([strlen(ylabel),strlen(yunits)])

;  if ((!d.y_ch_size * ylength) gt psize) then begin
;    ratio    = float(!d.y_ch_size * ylength) / float(psize)
;    ycsize = 1.0 - (ratio/8.0) + 0.1
;  endif

;TJK since this label is written vertically, you want to use the 
;characters "x" size in determining the overall size that will fit.
  if ((!d.x_ch_size * ylength) gt psize) then begin
    ratio    = float(!d.x_ch_size * ylength) / float(psize)
    ycsize = 1.0 - (ratio/8.0) + 0.1
  endif


;Determine the Color bar label
  zlabel = '' & zunits = '' ; initialize
  a = tagindex('FIELDNAM',ZTAGS)
  if (a(0) ne -1) then zlabel = Zvar.(a(0)) $
  else zlabel = 'Energy'

  a = tagindex('UNITS',ZTAGS)
  if (a(0) ne -1) then zunits = Zvar.(a(0))
  a = tagindex('UNIT_PTR',ZTAGS)
  if (a(0) ne -1) then begin
    if (Zvar.(a(0))(0) ne '') then zunits = Zvar.(a(0))
  endif
  zlabel = zlabel + '!C' + zunits
  ; compare the size of the zaxis label to the panel height
  zcsize = 1.0 & zlength = max([strlen(zlabel),strlen(zunits)])
  if ((!d.x_ch_size * zlength) gt psize) then begin
    ratio    = float(!d.x_ch_size * zlength) / float(psize)
    zcsize = 1.0 - (ratio/8.0) + 0.1
  endif

  ; search for data gaps

  if keyword_set(NOGAPS) then datagaps = -1 else datagaps = find_gaps(mytimes)

  ; produce debug output
;  if keyword_set(DEBUG) then begin
;    print,'  Yscales=',yranger & print,'  Yscaletype=',yscaletype
;  endif

  ; generate an empty plot frame
  if (i eq 0) then begin 
    ;TJK 10/12/2004 - change ystyle to force exact axis range vs. allowing
    ;IDL to pick "nice" values.
    ;    plot,mytimes,mydata,/DEVICE,/NODATA,YTITLE=ylabel,YRANGE=yranger,YSTYLE=2,$
    ;TJK 10/28/2004 - change the logic again to use the IDL "nice" ymin and max scale values
    ;to determine a better value for the log min value when values le 0.0 are in the data.
    ;so 1st do a plot w/ no data and no scales w/ ytick_get keyword and then substitute
    ;all values eq goodmin to the ytick(0) value, then make the plot w/ scales and ticks
    ;using IDLs ymin and max returned in the 1st call.

    plot,mytimes,mydata,/DEVICE,/NODATA,YTITLE=ylabel,YRANGE=yranger,YSTYLE=2+4,$
       YLOG=yscaletype,XSTYLE=4+1,XRANGE=xranger,POSITION=ppos,$
       NOERASE=clear_plot,CHARSIZE=ycsize,_EXTRA=EXTRAS,ytick_get=yticks
    if (n_elements(yticks) gt 0) then begin
      yranger(0) = min(yticks)
      yranger(1) = max(yticks)
    endif

   plot,mytimes,mydata,/DEVICE,/NODATA,YTITLE=ylabel,YRANGE=yranger,YSTYLE=1,$
       YLOG=yscaletype,XSTYLE=4+1,XRANGE=xranger,POSITION=ppos,$
       NOERASE=clear_plot,CHARSIZE=ycsize,_EXTRA=EXTRAS
    timeaxis_text,JD=julday,/NOLABELS,TICKLEN=-2.0
  endif

  if (goodmin ne -1) then begin
    wle = where(mydata eq goodmin, wcle)
    if (wcle gt 0) then begin
	mydata(wle) = yticks(0)
	if keyword_set(DEBUG) then print,'Log scaling - reassigning values le 0 to ',yticks(0)
    endif
  endif


  ; TJK - each line is represented by a color which needs to match those
  ; on the colorbar.  So need to figure out which color goes w/
  ; each index.

  ; TJK 7/21/2009 - have to look for cases where the 1st (case was in wi_m0_swe)
  ; records values have fill in them.  If this is found, then
  ; use another record that doesn't have fill
  if (colr_dims eq 2) then begin
    colr_size = size(thecolor, /dimensions)
    clr = 0
    good_index = -1
    while ((good_index eq -1) and (clr le colr_size(1)-1)) do begin
       bad_clr = where(thecolor(elist,clr) eq Zfillval, n_fill)
       if (n_fill le 0) then good_index = clr else clr = clr + 1
   endwhile
    print, 'DEBUG, stack_plot: color record being used is ',clr
    colors = thecolor(elist,clr)
    Zt = thecolor(elist,clr)
  endif else begin
    colors = thecolor(elist)
    Zt = thecolor(elist)
  endelse

  if (zscaletype) then begin ;if log scaling the Z/color axis
    wh = where(colors le 0, wc) ;only call alog10 on values above zero
    if (wc eq 0) then begin
	Zt = alog10(colors)
    endif else begin
      Zt = colors*0; all 0's
      wh = where(colors gt 0, wc)
      if (wc gt 0) then Zt(wh) = alog10(colors(wh))
    endelse

    if (zmin le 0.) then minZ1 = 0. else minZ1 = alog10(zmin)
    if (zmax le 0.) then maxZ1 = 0. else maxZ1 = alog10(zmax)

  endif else begin ; Z not log scaled
    minZ1 = zmin
    maxZ1 = zmax
  endelse


  Zt = bytscl(Zt, min=minZ1, max=maxZ1, top=!d.n_colors-3)+1B

  color = Zt(i)	
print, 'DEBUG, stack_plot: color of this line = ',color

  ; if any plottable data exists then overplot the data into the frame

  if (non_fillcount ne 0) then begin
    if (datagaps(0) eq -1) then oplot,mytimes,mydata, color=color $
    else begin
      start = 0L ; overplot each data segment
      for j=0,n_elements(datagaps)-1 do begin
        stop = datagaps(j) ; get last element of segment
        oplot,mytimes(start:stop),mydata(start:stop), color=color
        start = stop + 1; reset start element for next oplot
      endfor
      oplot,mytimes(start:*),mydata(start:*),color=color ; oplot last segment
    endelse
  endif

  ; Adjust plot position and flags for next plot
;  ppos(3) = ppos(1) & ppos(1) = ppos(1) - psize & clear_plot=1
endfor

;For stacked plots, Bob wants the colorbar reversed (smallest number on top
;largest on the bottom). So reverse cscale and use /reverse in colorbar call.
if COLORBAR then begin
  if (n_elements(cCharSize) eq 0) then cCharSize = 0.
  xwindow = !x.window
  cscale = [zmax, zmin]
  offset = 0.01
  ctitle = zlabel

  cpos=[!x.window(1)+offset,!y.window(0),$
        !x.window(1)+offset+0.03, !y.window(1)]
  colorbar, cscale, ctitle, logZ=zscaletype, cCharSize=zcsize, $
        position=cpos, fcolor=fcolor, /reverse

  !x.window = xwindow
endif ; colorbar

; draw the time axis by default or if lastplot flag is specified
if keyword_set(POSITION) then begin
  if keyword_set(LASTPLOT) then begin
    timeaxis_text,FORM=tform,JD=julday,title=subtitle,CHARSIZE=0.9
  endif
endif else begin
  timeaxis_text,FORM=tform,JD=julday,title=subtitle,CHARSIZE=0.9
  if keyword_set(GIF) then begin
    deviceclose
  endif
endelse
;Clear out the ylabel which is used when notifying users that some
;data is fill data.
ytlabel = ''

;if keyword_set(GIF) then begin
;  if keyword_set(REPORT) then print, 1, 'GIF=',GIF
;  print, 'GIF=',GIF
;endif

return,0
end



