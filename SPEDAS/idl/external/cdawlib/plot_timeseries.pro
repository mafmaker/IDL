;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/plot_timeseries.pro,v 1.106 2009/10/20 13:15:00 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $
;+------------------------------------------------------------------------
; NAME: PLOT_TIMESERIES
; PURPOSE: To generate a time series plot given the anonymous structures
;          returned by the read_mycdf function.
; CALLING SEQUENCE:
;       out = read_mycdf(Xstruct,Ystruct)
; INPUTS:
;       Xstruct = structure containing the Epoch variable structure of the
;                 type returned by the read_mycdf structure.
;       Ystruct = structure containing the variable to be plotted against
;                 the Epoch variable in the Xstruct parameter
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
;	NOSUBTITLE = if set, will not print 'time range = ' subtitle even after
;                       the last graph. Needed for timetext case. RCJ
;	ONLYLABEL = if set, graph position is calculated but graph is not
;			plotted. However, the x-axis label *is* plotted.
;			Utilized by timetext case. RCJ 
;	SCATTER = if set, display a scatter plot (each point is plotted as a
;		  dot, no lines connect the dots. added on 5/14/2001 TJK
;	COMBINE = if set, need to add the dataset name to the y axis label
;		  added 10/14/2003 - TJK.	
;       DEBUG    = if set, turns on additional debug output.
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 22, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;       8/13/96 : R. Burley    : Add NONOISE capability
;-------------------------------------------------------------------------
FUNCTION plot_timeseries, Xvar, Yvar, $
                          TSTART=TSTART,TSTOP=TSTOP,ELEMENTS=ELEMENTS,$
                          POSITION=POSITION,PANEL_HEIGHT=PANEL_HEIGHT,$
                          FIRSTPLOT=FIRSTPLOT,LASTPLOT=LASTPLOT,$
                          CDAWEB=CDAWEB,GIF=GIF,NOSUBTITLE=NOSUBTITLE,$
                          XSIZE=XSIZE,YSIZE=YSIZE, ONLYLABEL=ONLYLABEL,$
                          AUTO=AUTO,NOGAPS=NOGAPS,NOVALIDS,$
			  err_plus=err_plus,err_minus=err_minus, $
                          IGNORE_DISPLAY_TYPE=IGNORE_DISPLAY_TYPE,$
                          NONOISE=NONOISE,DEBUG=DEBUG,REPORT=REPORT,$
                          SCATTER=SCATTER,COMBINE=COMBINE,_EXTRA=EXTRAS

; Open report file if keyword is set

status = 0

;TJK added scatter plot capability on 5/14/2001
; RCJ 02/25/2005  Moved this to here because if 1 point then psym=4 (see
;                 somewhere below)
if keyword_set(SCATTER) then psym = 3 else psym = 0

;print, 'scatter is set if psym is 3, psym = ', psym

if keyword_set(REPORT) then begin & reportflag=1L
  a=size(REPORT) & if (a(n_elements(a)-2) eq 7) then $
  OPENW,1,REPORT,132,WIDTH=132
endif else reportflag=0L

; Verify that both Xvar and Yvar are present
if (n_params() ne 2) then begin
  print,'ERROR=Missing parameter to plot_timeseries function' & return,-1
endif

; Verify the type of the first parameter and retrieve the data
a = size(Xvar)
if (a(n_elements(a)-2) ne 8) then begin
  print,'ERROR=1st parameter to plot_timeseries not a structure' & return,-1
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
;    help, /struct, b
;TJK 6/27/2006 - added check for "9" - cdf_epoch16, "5" is cdf_epoch
    if ((b(n_elements(b)-2) eq 5) or (b(n_elements(b)-2) eq 9)) then begin
        ;print, 'Epoch parameter ok' 
     endif else begin 
        print,'ERROR=1st parameter datatype not CDF EPOCH' & return,-1
    endelse
  endelse
endelse

tszck=size(times)
if(tszck(tszck(0)+2) ne 1) then $ ; RTB added to prevent reform(scalar)
       times = reform(times) ; eliminate any redundant dimensions

; Verify the type of the second parameter and retrieve the data
a = size(Yvar)
if (a(n_elements(a)-2) ne 8) then begin
  print,'ERROR=2nd parameter to plot_timeseries not a structure' & return,-1
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

; Verify type of data and determine the number of panels that will be plotted
; and which elements of the data array are to be plotted.
a = size(thedata) & b = a(n_elements(a)-2) & thedata_size = a

;help, thedata, times
;stop;

;TJK changed the following line on 5/26/2000 so that unisigned datatypes are
;also acceptable.
;if ((b eq 0) OR (b gt 5)) then begin
if ((b eq 0) OR (b gt 6 and b lt 12)) then begin
  print,'STATUS=datatype indicates that data is not plottable' & return,-1
endif else begin
  case a(0) of
  0   : begin
           ; what follows is a little trick to allow us to plot 
           ; one single point. RCJ 02/2001
           thedata=[thedata,thedata]
           a = size(thedata)
           b = a(n_elements(a)-2) & thedata_size = a
           times=[times,times]
           psym=4
           symsize=2
           ;print,'ERROR=Single data points are not plottable' & return,-1
           ;print,'STATUS=Re-select longer time interval. Single data points are not plottable' 
	   print,'STATUS: Found one single point.....'
	   num_panels = 1L & elist=0
           ;return,-1
           end
  1   : begin
           
           num_panels = 1L & elist=0

	   ;TJK 2/10/2004 - put this check in, so that we're not trying to plot unequal arrays
	   ;print, n_elements(thedata), n_elements(times)
	   if (n_elements(thedata) ne n_elements(times)) then begin

             print,'STATUS=Re-select longer time interval; one value found for ',Yvar.varname,' and not plottable.' 
;TJK 9/24/2007
;Don't return, otherwise we're getting black plots for datasets
;like th(a-e)_l2_fgm.
;             return, -1

	   endif
        end
  2   : begin ; #panels determined by dimensionality or by display type
           elist=indgen(a(1))
           ;TJK change to check if elements is defined
           ;        if keyword_set(ELEMENTS) then elist = ELEMENTS $
           if (n_elements(ELEMENTS) gt 0) then elist = ELEMENTS $
           else begin
              if NOT keyword_set(IGNORE_DISPLAY_TYPE) then begin
                 b = tagindex('DISPLAY_TYPE',YTAGS)
                 if (b(0) ne -1) then begin ; evaluate the display type
                    c = strupcase(Yvar.(b(0))) & c = break_mystring(c,delimiter='>')
                    if ((c(0) eq 'TIME_SERIES')AND(n_elements(c) gt 1)) then begin
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
num_panels = n_elements(elist)
;print, 'num_panels set to n_elements(elist) = ',num_panels

nogood_counter = num_panels

; Determine the proper start and stop times of the plot
tbegin = times(0) & tend = times(n_elements(times)-1) ; default to data

if keyword_set(TSTART) then begin ; set tbegin
  tbegin = TSTART & tbegin16 = TSTART & a = size(TSTART)
  if (a(n_elements(a)-2) eq 7) then begin ;if tstart is a string, convert it
      split_ep=strsplit(TSTART,'.',/extract)
      tbegin = encode_CDFEPOCH(TSTART)
      tbegin16 = encode_CDFEPOCH(TSTART,/EPOCH16,msec=split_ep[1]);TJK added for use when data is epoch16 
  endif
endif
if keyword_set(TSTOP) then begin ; set tend
  tend = TSTOP & tend16 = TSTOP & a = size(TSTOP)
  if (a(n_elements(a)-2) eq 7) then begin ;if tstop is a string, convert it
    split_ep=strsplit(TSTOP,'.',/extract)
    tend = encode_CDFEPOCH(TSTOP)
    tend16 = encode_CDFEPOCH(TSTOP,/EPOCH16,msec=split_ep[1]);TJK added for use when data is epoch16 
  endif
endif

; Compare the range of the time data to the requested start and stop times
pad_front = 0L & pad_end = 0L
;print, tbegin, tend
;print, '1st time val from data ',times(0)
;print, 'last time val from data ',times(n_elements(times)-1)
;TJK 7/20/2006 test to see if time values are standard epoch or
;epoch16, set flag and change the tend and tbegin values to their
;epoch16 counterparts so we don't have to change so much code down
;below

ep16 = 0
if (size(times(0),/tname) eq 'DCOMPLEX')then begin 
    ep16 = 1
    tend = tend16 
    tbegin = tbegin16
;print, 'data is dcomplex, ',tend, ' and ',tbegin
endif

if (!version.release ge '6.2' and ep16) then begin
  if (cdf_epoch_compare(times(0), tbegin)) then begin
    if keyword_set(DEBUG) then print,'Padding front of times...'
    times = [tbegin,times] & pad_front = 1L
  endif
  if (cdf_epoch_compare(tend, times(n_elements(times)-1))) then begin
    if keyword_set(DEBUG) then print,'Padding end of times...'
    times = [times,tend] & pad_end = 1L
  endif
endif else begin
  if (tbegin lt times(0)) then begin
    if keyword_set(DEBUG) then print,'Padding front of times...'
    times = [tbegin,times] & pad_front = 1L
  endif
  if (tend gt times(n_elements(times)-1)) then begin
    if keyword_set(DEBUG) then print,'Padding end of times...'
    times = [times,tend] & pad_end = 1L
  endif
endelse

; Determine the first and last data time points to be plotted
rbegin = 0L & w = where(times ge tbegin,wc)
if (wc gt 0) then rbegin = w(0)
;print,rbegin
rend = n_elements(times)-1 & w = where(times le tend,wc)
if (wc gt 0) then rend = w(n_elements(w)-1)
if (rbegin ge rend) then begin
  print,'STATUS=No data within specified time range.' ;& return,-1
endif

if not (keyword_set(nosubtitle)) then begin
   ; Create a subtitle for the plots showing the data start and stop times
   CDF_EPOCH,tbegin,year,month,day,hour,minute,second,milli,/BREAK
   ical,year,doy,month,day,/idoy
   subtitle = 'TIME RANGE='+strtrim(string(year),2)+'/'+strtrim(string(month),2)
   subtitle = subtitle + '/' + strtrim(string(day),2)  
   subtitle = subtitle + ' (' + strtrim(string(doy),2) + ') to '
   CDF_EPOCH,tend,year,month,day,hour,minute,second,milli,/BREAK
   ical,year,doy,month,day,/idoy
   subtitle = subtitle + strtrim(string(year),2)+'/'+strtrim(string(month),2)
   subtitle = subtitle + '/' + strtrim(string(day),2)
   subtitle = subtitle + ' (' + strtrim(string(doy),2) + ')'
endif else subtitle=''   

; Convert the time array into seconds since tbegin
CDF_EPOCH,tbegin,year,month,day,hour,minute,second,milli,/BREAK
CDF_EPOCH,a,year,month,day,0,0,0,0,/COMPUTE_EPOCH
temp = make_array(n_elements(times),/dcomplex)

;TJK 7/20/2006 - new section to "do the math" on the epoch16 values
if (ep16)then begin 
    for i = 0L, n_elements(times)-1 do begin
;TJK 10/19/2009 - need more precision for TH*_L2_SCM variables
;      ep_diff = cdf_epoch_diff (times(i), a)
;      help, ep_diff, a
;      print, 'base date = ',a, ' Epoch16 time ',times(i), ' Diff after cdf_epoch_diff = ', ep_diff
;      temp(i) = ep_diff/1000.d0

      ep_diff = cdf_epoch_diff (times(i), a, /micro_seconds)
;      help, ep_diff, a
;      print, 'base date = ',a, ' Epoch16 time ',times(i), ' Diff after cdf_epoch_diff = ', ep_diff
      temp(i) = ep_diff/1000000.d0
    endfor
    times = temp

endif else begin
    times  = (times - a) / 1000.d0 ; double in seconds from first of day
endelse

julday = ymd2jd(year,month,day)

; Determine label for time axis based on time range
;10/29/2009 - TJK change from lonarr to double array to support
;             millisecond time scales
;xranger = lonarr(2)
xranger = dblarr(2)
;TJK 7/18/2006 - if ep16, replace w/ the "real parts" of the 1st and last element
;of the times array, which was already "converted" (reduced by a and /1000) above.
if (ep16) then begin
  xranger(0) = real_part(times(0))
  xranger(1) = real_part(times(n_elements(times)-1))
endif else begin
  xranger(0) = (tbegin-a)/1000
  xranger(1) = (tend-a)/1000
endelse
trange = xranger(1) - xranger(0)
print, 'time range = ',trange
;help, trange
;stop
;if (trange le 60.0) then tform='h$:m$:s$.f$@y$ n$ d$' $
; RCJ 08/06/2007  Changed above to below, not sure it's best combination.
if (trange le 1.0) then tform='h$:m$:s$.f$@y$ n$ d$' $
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
      psize = PANEL_HEIGHT & ys = (psize * num_panels) + 100
    endif else psize = ((ys-100) / num_panels)
  endif else begin ; generating an X-window
    a = lonarr(2) & DEVICE,GET_SCREEN_SIZE=a ; get device resolution
    xs = (a(0)*0.66) & ys = (a(1)*0.66) ; compute defaults
    if keyword_set(XSIZE) then xs = XSIZE ; override if keyword present
    if keyword_set(YSIZE) then ys = YSIZE ; override if keyword present
    if keyword_set(PANEL_HEIGHT) then begin
      psize = PANEL_HEIGHT
      ys = (psize * num_panels) + 100
      if (ys gt a(1)) then begin
        print,'ERROR=Computed window Ysize greater than device resolution'
        return,-1
      endif
    endif else psize = ((ys-100) / num_panels)
  endelse
  if (psize lt 50) then begin ; sanity check for #pixels per panel
    print,'ERROR=Insufficient resolution for a ',num_panels,' panel plot'
    return,-1
  endif
endif


; Initialize plotting position arrays and flags

if keyword_set(POSITION) then ppos = POSITION $
else begin
  ppos    = fltarr(4)         ; create position array
  ppos(0) = 100               ; default plot x origin
  ppos(2) = (xs - 40)         ; default plot x corner
  ppos(1) = (ys - 30) - psize ; 1st plot y origin
  ppos(3) = (ys - 30)         ; 1st plot y corner
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
;  print,'#of PANELS=',num_panels
;  print,'ELEMENT LIST=',elist+1
;  print,'pad_front=',pad_front,' pad_end=',pad_end
;endif

; Create the new window or the gif file
if (new_window eq 1) then begin
  if keyword_set(GIF) then begin
    a = size(GIF) & if (a(n_elements(a)-2) ne 7) then GIF = 'idl.gif'
    deviceopen,6,fileOutput=GIF,sizeWindow=[xs,ys]
  endif else begin ; open x-window display
    window,/FREE,XSIZE=xs,YSIZE=ys,TITLE=window_title
    clear_plot = 0L ; initialize clear plot flag
  endelse
endif

; Determine the fill value for the Y data and valid min and valid max values
a = tagindex('FILLVAL',YTAGS)
Yfillval = 1.0e31
if (a(0) ne -1) then begin
    if (Yvar.FILLVAL ne '') then Yfillval = Yvar.FILLVAL
endif
;print, 'TJK DEBUG Yfillval = ',Yfillval

if keyword_set(err_plus) and keyword_set(err_minus) then begin
   if (n_elements(err_plus) ne n_elements(thedata) or $
      n_elements(err_minus) ne n_elements(thedata)) then begin
      err_plus=0
      err_minus=0
      print,'Plot_timeseries: Could not plot error bars'
   endif 
endif

; EXTRACT THE DATA FOR EACH PANEL AND PLOT
for i=0,num_panels-1 do begin
  ; extract data for a single panel from the data array
  if (thedata_size(0) eq 1) then begin
     mydata = thedata 
     if keyword_set (err_plus) then myerr_plus = err_plus
     if keyword_set (err_minus) then myerr_minus = err_minus
  endif else begin
     mydata = thedata((elist(i)),*)
     if keyword_set (err_plus) then myerr_plus = err_plus((elist(i)),*)
     if keyword_set (err_minus) then myerr_minus = err_minus((elist(i)),*)
  endelse	
  mydata = reform(mydata) ; remove any extraneous dimensions
  if keyword_set (err_plus) then myerr_plus=reform(myerr_plus)
  if keyword_set (err_minus) then myerr_minus=reform(myerr_minus)
  ; pad the beginning and end of data if extra time points were added
  if (pad_front) then begin
     mydata = [Yfillval,mydata] ; add fill point to front
     if keyword_set (err_plus) then myerr_plus=[myerr_plus(0),myerr_plus]
     if keyword_set (err_minus) then myerr_minus=[myerr_minus(0),myerr_minus]
  endif   
  if (pad_end) then begin
     mydata = [mydata,Yfillval] ; add fill point to back
     if keyword_set (err_plus) then myerr_plus=[myerr_plus,myerr_plus(n_elements(myerr_plus)-1)]
     if keyword_set (err_minus) then myerr_minus=[myerr_minus,myerr_minus(n_elements(myerr_minus)-1)]
  endif   
  ; screen out data points which are outside the plotting time range
; Check data before plotting
rrend=n_elements(mydata)

;  if(rrend lt rend) then begin
;    print, "STATUS=No Data Available"
;    return, -1
;  endif
;TJK modified this so that it will just produce a blank plot
;in the case where there's data for some variables in this
;dataset but not all.  It was too hard to figure out how to
;make the s/w "skip" a variable since the size of the window
;and whatnot is done in plotmaster w/ no knowledge of the data found
;for each variable.

;TJK added 1/29/99 setting of flag
  nogood = 0; FALSE

if(rrend lt rend) then rend = rrend-1

  mydata = mydata(rbegin:rend)
  if keyword_set (err_plus) then myerr_plus = myerr_plus(rbegin:rend) 
  if keyword_set (err_minus) then myerr_minus = myerr_minus(rbegin:rend) 
  mytimes = times(rbegin:rend)
  ; screen out fill data from the data and the times array
  w = where(mydata ne Yfillval,non_fillcount)
;TJK 8/5/2004 - add this check for inifinite or NaN "values" since
;we now have datasets that have whole arrays of NaN, e.g. wi_phsp_3dp
;print, min(mydata)
;print, max(mydata)
;print, mydata
;print, w
;stop;TJK
  n_goodvals = 0 ; need to initialize
  if (non_fillcount ne 0) then n = where(finite(mydata(w)) eq 1,n_goodvals)
;
;stop;TJK
  if (non_fillcount ne 0 and n_goodvals gt 0) then begin
    mydata = mydata(w) & mytimes = mytimes(w)  
    if keyword_set (err_plus) then myerr_plus=myerr_plus(w)
    if keyword_set (err_minus) then myerr_minus=myerr_minus(w)
    w=0
  endif else begin
	 w=0
	 nogood = 1
         nogood_counter = nogood_counter - 1
  endelse

  ; screen out data outside validmin and validmax values
  if ((NOT keyword_set(NOVALIDS))AND(non_fillcount gt 0)and $
	(n_goodvals gt 0)) then begin
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
        if keyword_set (err_plus) then myerr_plus=myerr_plus(w)
        if keyword_set (err_minus) then myerr_minus=myerr_minus(w)
      endif else begin
	a = tagindex('FIELDNAM',YTAGS)
	if (a(0) ne -1) then ylabel = Yvar.(a(0))
        print,'STATUS=No data for at least one component of ',ylabel,' variable.'
        ;TJK want to continue since this might be one of several panels - instead
        ;lets set a flag and check it below.
        ;       return,0
	nogood = 1; TRUE
        nogood_counter = nogood_counter - 1
      endelse
    endif
  endif

; RCJ 10/16/02 If this is the first plot and the data is not good, at least create
; and invisible plot so subsequent graphs won't fall on a black graph area. 
; In the case where this is the only graph requested
; at least the user won't end up looking at a black graph area.
; TJK 8/5/2004 added check for i eq 0 which means 1st of multiple panels
if (nogood and firstplot and (i eq 0)) then begin
   plot,[0,1],[0,1],/nodata,ystyle=8+4,xstyle=8+4
endif


if (nogood eq 0) then begin
  ; screen out data outsize 3 standard deviations from the mean
  if keyword_set(NONOISE) then begin
    ;semiMinMax,mydata,Sigmin,Sigmax
    ; RCJ 05/01/2006  Replaced call to semiminmax w/ call to three_sigma
    sigminmax=three_sigma(mydata)
    sigmin=sigminmax.(0)
    sigmax=sigminmax.(1)
    w = where(((mydata gt Sigmax)OR(mydata lt Sigmin)),wc)
    if (wc gt 0) then begin
      if keyword_set(DEBUG) then print,wc,' values outside 3-sigma...'
      w = where(((mydata le Sigmax)AND(mydata ge Sigmin)),wb)
      if (wb gt 0) then begin
        mydata=mydata(w) & mytimes=mytimes(w)
        if keyword_set (err_plus) then myerr_plus=myerr_plus(w)
        if keyword_set (err_minus) then myerr_minus=myerr_minus(w)
      endif
    endif
  endif


  ; determine the yaxis scale type, natural or logarithmic
  yscaletype = 0L ; initialize assuming natural
  a = tagindex('SCALETYP',YTAGS)
  if (a(0) ne -1) then begin
    if (strupcase(Yvar.SCALETYP) eq 'LOG') then yscaletype = 1L
  endif
  ; screen non-positive data values if creating a logarithmic plot
  if (yscaletype eq 1) then begin
    wle = where(mydata le 0.0,wcle)
    if (wcle gt 0) then begin
      w = where(mydata gt 0.0,wc)
      if (wc gt 0) then begin ;if there are good values
	;TJK 10/01/2004 - change from just throwing out values <=0 to reassigning them
	wmin = min(mydata(w));get smallest real value above zero
	wmin = wmin/2 ; make it less than the real smallest value - TJK 10/22/2004
	mydata(wle) = wmin ;assign all valid values zero and below to a really small value
			   ;above zero
	;SAVE wle and wcle for use in the plot command below

;TJK 10/01/2004 - remove this and do above        mydata = mydata(w) & mytimes = mytimes(w)  

        w = where(mydata gt 0.0,wc)
        if (wc gt 0) then begin ;if there are good values
          if keyword_set (err_plus) then myerr_plus=myerr_plus(w)
          if keyword_set (err_minus) then myerr_minus=myerr_minus(w)
	endif
	w=0
      endif
    endif
  endif

  ; determine the proper scale for the Y axis
  ;TJK initialize to scales based on the real data.  Because we're now enabling
  ; a "noauto" keyword in the time_series synax for display_type, we want to 
  ; initialize ymin and max to more realistic values just in case the scalemin
  ; and max attributes aren't set.
  ;
  goodvals = where(finite(mydata) eq 1, ngoodvals)
  ymin = min(mydata(goodvals),MAX=ymax) 

  ;TJK replaced w/ above  ymax = 1.0 & ymin = 0.0 ; initialize to any value
  a = tagindex('SCALEMIN',YTAGS)
  if (a(0) ne -1) then begin & b=size(Yvar.SCALEMIN)
    if (b(0) eq 0) then ymin = Yvar.SCALEMIN $
    else ymin = Yvar.SCALEMIN(elist(i))
  endif
  a = tagindex('SCALEMAX',YTAGS)
   if (a(0) ne -1) then begin & b=size(Yvar.SCALEMAX)
   if (b(0) eq 0) then ymax = Yvar.SCALEMAX $
   else ymax = Yvar.SCALEMAX(elist(i))
  endif
  if (keyword_set(AUTO)) then begin ; autoscale based on valid data values
    if (non_fillcount gt 0) then begin ; cant autoscale if all fill data
      ymax = 0.0
; replace this with next 2 lines to ignore NaN values ymin = min(mydata,MAX=ymax)
      goodvals = where(finite(mydata) eq 1, ngoodvals)
      ymin = min(mydata(goodvals),MAX=ymax) 
    endif
  endif

;  print, 'TJK debug - data ymin and max ',ymin, ymax

  ; quality check the y scales
  if (ymax eq ymin) then begin  
     ;ymax = ymax + 1 
     ;ymin = ymin - 1 
     ; RCJ 02/25/2005  10% of the value is probably better. 
     ymax = ymax + (ymax * .1) 
     ymin = ymin - (ymin * .1)
     ; RCJ 05/02/2006  If ymin=ymax=0. (case found after removing noise
     ; from AC_H1_EPM data) then we don't really want a log plot:
     if ymax eq 0. and ymin eq 0. then begin
        yscaletype=0
        ymin=-.1 & ymax=.1
     endif
  endif
;print, 'DEBUG, ymin and max = ',ymin,ymax ;TJK DEBUG
  yranger=[ymin,ymax]
  ; RCJ 11/15/02  Adjusting graph yrange according to error bars.
  ; The graphs were not improved if the y-axis was in log scale so no correction
  ; is made for those cases.
  if (yscaletype ne 1) then begin
     if keyword_set(err_minus) or keyword_set(err_plus) then $
        print,'Adjusting ymin and ymax according to error bars...'
     if keyword_set (err_minus) then  begin
        q=where(mydata eq ymin)
	; if q ne -1, than ymin exists in mydata and I only need its index number.
	; if q=-1, when ymin=ymax, then just take ymin
        if q[0] ne -1 then yranger[0]= ymin-max(myerr_minus[q]) $
	   else yranger[0]= ymin
     endif   
     if keyword_set (err_plus) then begin
        q=where(mydata eq ymax)
        if q[0] ne -1 then yranger[1] = ymax+max(myerr_plus[q]) $
	   else yranger[1] = ymax
     endif
  endif
  if ((yscaletype eq 1)AND(yranger(0) le 0)) then yranger(0) = 0.00001


;print, 'DEBUG, yranger = ', yranger ;TJK DEBUG
  ; Determine the proper labeling for the y axis
  ylabel = '' & yunits = '' & yds = '' ; initialize

  if keyword_set(COMBINE) then begin
    a = tagindex('LOGICAL_SOURCE',YTAGS)
    if (a(0) ne -1) then yds = strupcase(Yvar.(a(0)))
  endif

;TJK 1/10/2007 - added check for new variable attribute called
; augment_labl, if set to true, then use this VARNAME in the y
; axis label.
  a = tagindex('AUGMENT_LABL',YTAGS)
  if (a(0) ne -1) then begin
      if (strupcase(yvar.(a(0))) eq 'TRUE') then begin
          a = tagindex('VARNAME',YTAGS)
          if (a(0) ne -1) then begin
              if (n_elements(yds) gt 0) then yds = yds + Yvar.(a(0)) else $
                yds = Yvar.(a(0))
              endif
      endif
  endif

  a = tagindex('FIELDNAM',YTAGS)
  if (a(0) ne -1) then ylabel = Yvar.(a(0))
  a = tagindex('LABLAXIS',YTAGS)
  if (a(0) ne -1) then ylabel = Yvar.(a(0))
  a = tagindex('LABL_PTR_1',YTAGS)
  if (a(0) ne -1) then begin
    if (Yvar.(a(0))(0) ne '') then ylabel = Yvar.(a(0))(elist(i))
  endif
  a = tagindex('UNITS',YTAGS)
  if (a(0) ne -1) then yunits = Yvar.(a(0))
  a = tagindex('UNIT_PTR',YTAGS)
  if (a(0) ne -1) then begin
    if (Yvar.(a(0))(0) ne '') then yunits = Yvar.(a(0))(elist(i))
  endif
  ;
  ; should add a condition here: only do the next 2 lines if sscweb??????
  ;
  coord=str_sep(yvar.varname,'_')
  if (n_elements(coord) gt 1) and (coord(0) eq 'XYZ') then ylabel=ylabel+' ('+coord(1)+')'

  if (n_elements(yds) gt 0) then begin
    ylabel = yds + '!C' + ylabel + '!C' + yunits ;TJK removed for space 10/12/2006 + '!C'
  endif else ylabel = ylabel + '!C' + yunits ;same as above + '!C'

  ; compare the size of the yaxis label to the panel height
  ycsize = 1.0 & ylength = strlen(ylabel)

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

  ; search for data gaps
  if keyword_set(NOGAPS) then datagaps = -1 else datagaps = find_gaps(mytimes)

  ; produce debug output
  if keyword_set(DEBUG) then begin
    print,'  Yscales=',yranger & print,'  Yscaletype=',yscaletype
  endif

  ; generate an empty plot frame
  ; rtb added 12/98
  ;!p.charsize=1.0

  if keyword_set(onlylabel) then begin
     plot,mytimes,mydata,XSTYLE=4+1,ystyle=4+1,/NODATA,$
        XRANGE=xranger,POSITION=ppos,/DEVICE,NOERASE=clear_plot
     !y.crange(0)=!y.crange(1)
     timeaxis_text,JD=julday,form=tform,/onlylabel
     goto, skipped_graph  
  endif else begin
;TJK 10/22/2004 - changed ystyle from 2 to 1 - 1 forces exact range which 
;is what I thought we were doing long ago!
;     plot,mytimes,mydata,/NODATA,YTITLE=ylabel,YRANGE=yranger,YSTYLE=2,$
;TJK 10/26/2004 - try something different to get better labeling
;
     if (yscaletype) then begin ;log scaling - 
		;10/28/2004 - TJK - get the nice y range that IDL 
		;would use and set
		;any values le 0.0 to the bottom scale value and
		;call plot again forcing the exact scale ranges to
		;the min and max returned in ytick_get
       plot,mytimes,mydata,/NODATA,YTITLE=ylabel,YRANGE=yranger,YSTYLE=2+4,$
          YLOG=yscaletype,XSTYLE=4+1,XRANGE=xranger,POSITION=ppos,/DEVICE,$
          NOERASE=clear_plot,CHARSIZE=ycsize,_EXTRA=EXTRAS,ytick_get=yticks
	  ;reassign the values originally le 0.0 to the scale min (returned by IDL)
	  if (wcle gt 0) then begin
	    mydata(wle) = yticks(0) 
            if keyword_set(DEBUG) then print,'Log scaling - reassigning values le 0 to ',yticks(0)
	  endif
	  if (n_elements(yticks) gt 0) then begin
	    yranger(0) = min(yticks)
	    yranger(1) = max(yticks)
	  endif
	;use exact yscale values for log plots (ystyle=1).
       plot,mytimes,mydata,/NODATA,YTITLE=ylabel,YRANGE=yranger,YSTYLE=1,$
        YLOG=yscaletype,XSTYLE=4+1,XRANGE=xranger,POSITION=ppos,/DEVICE,$
        NOERASE=clear_plot,CHARSIZE=ycsize,_EXTRA=EXTRAS

     endif else begin ;linear scaling - use the IDL defined yscales (ystyle=2)

       ;TJK 7/17/2006 - check for values that IDL likes to label in exponential
       ;form - force them to just F notation, otherwise the variable labels
       ;get forced off the left side.  Leave the really large numbers to IDL for now.
       
         if (abs(yranger(1)) gt 999 and abs(yranger(1)) lt 99999) then begin
         plot,mytimes,mydata,/NODATA,YTITLE=ylabel,YRANGE=yranger,YSTYLE=2,$
          YLOG=yscaletype,XSTYLE=4+1,ytickformat='(F11.1)',XRANGE=xranger,POSITION=ppos,/DEVICE,$
          NOERASE=clear_plot,CHARSIZE=ycsize,_EXTRA=EXTRAS
	  
        ;TJK 7/28/2006 - check for small values where psize is ge 200 (our
        ;large panels) use a ytickformat that won't push the labels off the left side
        
	;endif else if ((abs(yranger(1)) lt 1.0) and (psize ge 200)) then begin
	;  RCJ 03/07/2007  This is ugly but I'm trying to avoid having
	; to pass a 'postscript' keyword to this routine. At least for now.
        ;TJK 4/29/2008 reduce the value from 1.0 to 0.01 so that values like
        ;1.0 don't end up looking like 1.000000 - problem d.s. it timed_l3a_see
;	endif else if ((abs(yranger(1)) lt 1.0) and (psize ge 200 and psize lt 5000)) then begin
	endif else if ((abs(yranger(1)) lt 0.01) and (psize ge 200 and psize lt 5000)) then begin
          plot,mytimes,mydata,/NODATA,YTITLE=ylabel,YRANGE=yranger,YSTYLE=2,$
           YLOG=yscaletype,XSTYLE=4+1,ytickformat='(F9.6)',XRANGE=xranger,POSITION=ppos,/DEVICE,$
           NOERASE=clear_plot,CHARSIZE=ycsize,_EXTRA=EXTRAS
       endif else begin
         plot,mytimes,mydata,/NODATA,YTITLE=ylabel,YRANGE=yranger,YSTYLE=2,$
          YLOG=yscaletype,XSTYLE=4+1,XRANGE=xranger,POSITION=ppos,/DEVICE,$
          NOERASE=clear_plot,CHARSIZE=ycsize,_EXTRA=EXTRAS
       endelse

     endelse


	;help,mydata,err_minus,err_plus
     if keyword_set(err_plus) and keyword_set(err_minus) then $
        cdaweb_errplot,mytimes,mydata-myerr_minus,mydata+myerr_plus

     timeaxis_text,JD=julday,/NOLABELS,TICKLEN=-2.0
  endelse   

  ; if any plottable data exists then overplot the data into the frame


  if (non_fillcount ne 0) then begin

    if (datagaps(0) eq -1) then oplot,mytimes,mydata,psym=psym,symsize=symsize $

    else begin
      start = 0L ; overplot each data segment
      for j=0L,n_elements(datagaps)-1 do begin
        stop = datagaps(j) ; get last element of segment
        ;TJK 4/29/2008 Add in a check for a single point in the gap
        ;if found, then plot a period, else connect the points.
        if (not (keyword_set(SCATTER)) and (n_elements(mydata(start:stop)) eq 1)) then psym = 3 else psym = 0
        if (keyword_set(SCATTER)) then psym = 3

        oplot,mytimes(start:stop),mydata(start:stop), psym=psym
        start = stop + 1; reset start element for next oplot
      endfor
      ;TJK 4/29/2008 Add in a check for a single point in the gap
      ;if found, then plot a period, else connect the points.
      if (not (keyword_set(SCATTER)) and (n_elements(mydata(start:*)) eq 1)) then psym = 3 else psym = 0
      if (keyword_set(SCATTER)) then psym = 3

      oplot,mytimes(start:*),mydata(start:*), psym=psym ; oplot last segment
    endelse
  endif

  ;endif else print, "STATUS=No Data Available" & status = -2

  ; Adjust plot position and flags for next plot
  ppos(3) = ppos(1) & ppos(1) = ppos(1) - psize & clear_plot=1

endif ;nogood
endfor

if keyword_set(DEBUG) then print, 'Total possible panels ',num_panels,' number of good data panels = ', nogood_counter

; RCJ 10/16/02  If this data is good and it's not the first plot then
; we are guaranteed not to have a black graph area and we can go ahead with
; the timeaxis_text calls.
; RCJ 11/18/02 It looks like 'and firstplot' is not needed. Will test
; in dev and bring it back if needed.
;if not (nogood and firstplot) then begin
time_written = 0L

if not (nogood) then begin
   ; draw the time axis by default or if lastplot flag is specified
   if keyword_set(POSITION) then begin
      if keyword_set(LASTPLOT) then begin
         timeaxis_text,FORM=tform,JD=julday,title=subtitle,CHARSIZE=0.9
         time_written = 1L
      endif
   endif else begin
      timeaxis_text,FORM=tform,JD=julday,title=subtitle,CHARSIZE=0.9
      time_written = 1L
      if keyword_set(GIF) then begin
         print,'not yet titling gifs from within plot_timeseries'
         deviceclose
      endif
   endelse
endif

;TJK 9/21/2007 - w/ the themis l2 fgm data in particular, we have many
;cases where the last variable on a given timeseries 
;gif, doesn't have any data and so we're getting white
;space, but no time axis.  So hopefully this will take care of that 
;situation.  We don't want to write the time label if we have no good panels 
;at all (when nogood_counter = 0).

if (keyword_set(LASTPLOT) and nogood and not(time_written) and (nogood_counter gt 0)) then begin ;still need to write the time axis
      timeaxis_text,FORM=tform,JD=julday,title=subtitle,CHARSIZE=0.9
endif

skipped_graph:
return,status
end



