;$author: baldwin $
;$Date: 2001/04/25 18:04:53 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/plotmaster.pro,v 1.132 2001/04/25 18:04:53 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.132 $
;+------------------------------------------------------------------------
; NAME: PLOTMASTER
; PURPOSE: To plot the data given in 1 to 10 anonymous structure of the type
;          returned by the read_mycdf function.  This function determines
;          the plot type for each variable, and generates the plot.
; CALLING SEQUENCE:
;       out = plotmaster(a,[more_structures])
; INPUTS:
;       a = structure returned by the read_mycdf procedure.
;
; KEYWORD PARAMETERS:
;   TSTART =  String of the form '1996/01/02 12:00:00' or a DOUBLE CDF_EPOCH
;   time that is the desired start time of the plots. Data is clipped or 
;   padded to conform to this time. Default is the start time of the 
;   earliest data.
;
;   TSTOP = String of the form '1996/01/02 12:00:00' or a DOUBLE 
;   CDF_EPOCH time that is the desired stop time of the plots. Data is 
;   clipped or padded to conform to this time. Default is the stop time of 
;   the latest data.
;
;   GIF
;    Set to send plot(s) to a gif file, ie. /GIF or GIF=1L. If set a file 
;    will be produced in the current working directory (see OUTDIR keyword), 
;    using the following naming conventions: Spacecraft_instrument_pid_# (see 
;    the PID keyword for customization). If GIF is not set then the plot(s) 
;    will be put into an x-window.
;
;    PID
;    May be used to customize part of the name of a gif file. The value of 
;    PID may be either a number or a string and will be inserted in the gif 
;    file name as follows: Spacecraft_instrument_pid_#.gif. If GIF is not 
;    set then the plot(s) will be put into an x-window and this keyword is 
;    ignored.
;
;    OUTDIR
;    This keyword indiates the output directory where a gif file will be 
;    placed. If GIF is set but OUTDIR is not, then the gif file will be put 
;    in the user's current working directory.GIF
;
;    AUTO
;    Set this keyword to use autoscaling instead of the variables SCALEMIN 
;    and SCALEMAX attribute values. The scales will be set to the min and 
;    max values of the data, after fill values have been filtered from the 
;    data (see also NONOISE keyword). If the user wishes to modify variable 
;    scale values for plotting purposes, you may do so by changing the 
;    appropriate data structure values, ie. struct.variable.scalemin = 0.0.
;    Please use great care in modifying the data structures values since
;    they will greatly influence what your plots or listings may look like.
;
;    CDAWEB
;    Set this keyword to force the margin on the right side of time series 
;    plots to be 100 pixels. This is the same margin used for spectrograms 
;    for the color bar. By default, PLOTMASTER will examine the data, and if 
;    ANY spectrograms will be produced, then it will align the margins 
;    properly. This keyword is only necessary for use in the CDAWeb system.
;
;    SLOW
;    Set this keyword to have spectrogram plotted using the POLYFILL method.
;    This method is slower but more accurate than TV (used in the QUICK method).
;
;    SMOOTH
;    Set this keyword to have spectrogram data reduced prior to plotting. 
;    This will increase plotting speed significantly.
;
;    QUICK
;    Set this keyword to have spectrograms plotted using the TV method. 
;    This method is very fast, but will produce inaccurate spectrograms 
;    if scales are non-linear or if fill data or data gaps are present
;    in the data.
;
;    THUMBSIZE
;    Set this to change the "thumbnail" size of each image when plotting 
;    a series of images. The default is 50w x 62h. 12 pixels is added to 
;    the height to allow for the time stamps under each image. So, if
;    you specify a thumsize of 70 pixels, each will actually be 70x82.
;
;    FRAME
;    Used to indicate the frame number within a series of images. If you 
;    specify FRAME = 2, then plotmaster will produce a "full size" version 
;    of the 3rd image in a sequence of images.
;
;       COMBINE  = if set, all time series and spectrogram plots will be
;                  combined into a single window or gif file.
;       NONOISE  = if set, filter values outside 3-sigma from the mean
;       DEBUG    = if set, turns on additional debug output.
;       ELEMENTS = if set, then only these elements of a dimensional variable
;                  will be plotted for stack_plot use only (right now).
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occurred.
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 22, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;       8/13/96 : R. Burley    : Add NONOISE keyword
;       8/30/96 : R. Baldwin   : Add error handling STATUS,DATASET,IMAGE,GIF 
;       8/30/96 : R. Baldwin   : Add orbit plotting 
;	1/7/97  ; T. Kovalick  : Modified many of the code that goes w/ the 
;				 keywords; GIF, CDAWEB, TSTART,	TSTOP and added
;				 the header documentation for them. Still more
;				 work to do...
;       2/10/97 ; R. Baldwin   : Add SSCWEB keyword and map_keywords.pro
;				 function
;	6/6/97  ; T. Kovalick  : Added the Stacked time series plot type.
;
;	9/4/97	; T. Kovalick  : Added the ELEMENTS keyword for stack_plot
;				 usage, it could also be used in time_series.
;        4/98   ; R. Baldwin   : Added virtual variable plot types; 
;				 plot_map_images.pro
;       11/98   ; R. Baldwin   : Added movie_images and movie_map_images
;-------------------------------------------------------------------------
FUNCTION plotmaster, a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,$
                     COMBINE=COMBINE,PANEL_HEIGHT=PANEL_HEIGHT,$
                     XSIZE=XSIZE,CDAWEB=CDAWEB,DEBUG=DEBUG,FILLER=FILLER,$
                     AUTO=AUTO,QUICK=QUICK,SLOW=SLOW,SMOOTH=SMOOTH,$
                     GIF=GIF,TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                     COLORTAB=COLORTAB,THUMBSIZE=THUMBSIZE,FRAME=FRAME,$
                     REPORT=REPORT,PID=PID,STATUS=STATUS,OUTDIR=OUTDIR, $
                     SSCWEB=SSCWEB, ELEMENTS=ELEMENTS

; Verify that number of parameters is acceptable
if ((n_params() le 0)OR(n_params() gt 10)) then begin
  print, 'STATUS= No data selected for plotting'
  print,'ERROR=Number of parameters must be from 1 to 10' & return,-1
endif

; Initialize window state structure
WS = {snum:0L,xs:0L,ys:0L,pos:lonarr(4),xmargin:[100L,40L],ymargin:[30L,100L]}
PS = 0 ; Initialize plot script structure
; RTB Test for Z-buffer use of carriage returns in labels
;!P.Charsize=1

; Initialize other local variables
a          = 0       ; create variable to be filled via the execute function
a_id       = -1      ; initialize the current structure number
p_template = {PLOTDESC,snum:0,vname:'',vnum:0,ptype:0,npanels:0,$
              iwidth:0,iheight:0,btime:0.0D0,etime:0.0D0,title:'',source:''}

; Verify proper keyword parameters
;  9/96 RTB added STATUS, OUTDIR, PID
; statusflag is not currently checked before printing
if keyword_set(STATUS) then statusflag= 1L else statusflag= 0L 

;TJK took out the following and replaced with one line below.
;if keyword_set(OUTDIR) then outdir=OUTDIR else begin
;   if keyword_set(CDAWEB) then outdir='/home/rumba/cdaweb/html/tmp/' $ 
;    else outdir='tmp'
;endelse

if keyword_set(OUTDIR) then outdir=OUTDIR else outdir=' '

; TJK take out the relationship between CDAWEB and GIF keywords...
;if keyword_set(CDAWEB) then GIF=1L else GIF=0L     

if keyword_set(PID) then pid=strtrim(string(PID),2) else pid=''

if keyword_set(PANEL_HEIGHT) then pheight=PANEL_HEIGHT else pheight=100
if n_params() eq 1 then COMBINE=1 ; single structure must be combined
gifopen = 0L ; initialize flag indicating no gif is currently open
if keyword_set(GIF) then begin
  max_xsize=640
  ; a = size(GIF) & b = n_elements(a) ; validate gif keyword
  ; if (a(b-2) ne 7) then GIF='idl00.gif'
  noclipflag = 1
endif else begin ; determine xwindow resolution
  GIF = 0L ; set gif keyword to no gif
  a = lonarr(2) & DEVICE,GET_SCREEN_SIZE=a ; get device resolution
  max_xsize = (a(0) * 0.9) & max_ysize = (a(1) * 0.9)
  noclipflag = 0
endelse
; Open report file if keyword is set
;if keyword_set(REPORT) then begin & reportflag=1L & a=size(REPORT)
;  if (a(n_elements(a)-2) ne 7) then REPORT='idl.rep'
if keyword_set(REPORT) then begin 
   reportflag=1L &  OPENW,1,REPORT,132,WIDTH=132
endif else reportflag=0L
if keyword_set(XSIZE) then WS.xs=XSIZE else WS.xs=max_xsize
if keyword_set(AUTO) then autoscale = 1L else autoscale = 0L
if keyword_set(SMOOTH) then smoothflag = 1L else smoothflag = 0L
if keyword_set(QUICK) then quickflag = 1L else quickflag = 0L
if keyword_set(SLOW) then slowflag = 1L else slowflag = 0L
if keyword_set(FILLER) then fillflag = 1L else fillflag = 0L
if keyword_set(DEBUG) then debugflag = 1L else debugflag = 0L
if keyword_set(SSCWEB) then SSCWEB=1L else SSCWEB=0L

; Evaluate each dataset structure, and each variable within each dataset,
; in order to determine the plot type for each variable, as well as the total
; number of panels to be plotted so that the windows (or Z-buffer) can be
; created with the proper size.
plottable_found = 0 ; initialize flag
for i=0,n_params()-1 do begin ; process each structure parameter
   w = execute('a=a'+strtrim(string(i),2))
   if w ne 1 then begin
      if (reportflag eq 1) then begin
         printf, 1, 'STATUS= A plotting error has occurred' & close,1
      endif
      print,'ERROR= Error in EXECUTE function' 
      print, 'STATUS= A plotting error has occurred' 
      return, -1
   endif
   ; RTB Add code to trap a=-1 bad structures 
   ibad=0
   str_tst=size(a)
   if(str_tst(str_tst(0)+1) ne 8) then begin
      ibad=1
      v_data='DATASET=UNDEFINED'
      v_err='ERROR=a'+strtrim(string(i),2)+' not a structure.'
      v_stat='STATUS=Cannot plot this data'
      a=create_struct('DATASET',v_data,'ERROR',v_err,'STATUS',v_stat)
   endif else begin  
      ; Test for errors trapped in read_myCDF
      atags=tag_names(a)
      rflag=tagindex('DATASET',atags)
      if(rflag(0) ne -1) then ibad=1 
   endelse
   ;
   if(ibad) then begin
      atags=tag_names(a)
      aw=where(atags eq 'ERROR',awc)
      print,a.DATASET
      if(awc gt 0) then print,a.ERROR
      print,a.STATUS
      p=p_template
      ;TJK 1/24/01 - change the ptype to -1 so that the plotting s/w lower down
      ;won't bother trying to do anything w/ this variables data (since it won't
      ;be there).  I believe, the main reason we end up here is that the data
      ;is fill and indicates that the instrument was off.
      ;      p(0).ptype=0
      p(0).ptype=-1
      p(0).snum=i
   endif else begin
      vnames = tag_names(a) & p = replicate(p_template,n_elements(vnames))
      for j=0,n_elements(tag_names(a))-1 do begin
         b = evaluate_varstruct(a.(j)) & c = size(b)
         if (c(n_elements(c)-2) eq 8) then begin ; record the evaluation results
            p(j).snum   = i        & p(j).vnum    = j
            p(j).ptype  = b.ptype  & p(j).npanels = b.npanels
            p(j).iwidth = b.iwidth & p(j).iheight = b.iheight
            p(j).btime  = b.btime  & p(j).etime   = b.etime
            p(j).title  = b.title  & p(j).source   = b.source
            if (b.vname ne '') then p(j).vname=b.vname else p(j).vname=vnames(j)
            if b.ptype ne 0 then plottable_found = 1; set flag
         endif else begin ; fatal error during evaluation
            if (reportflag eq 1) then $
            printf,1,'STATUS=A plotting error has occurred' & close,1
            print,'STATUS=A plotting error has occurred'
            print,'ERROR=FATAL error during eval' 
            return,-1
         endelse
      endfor ; for every variable
   endelse
   ; append the plot evaluations of the current structure to any previous ones
   if (i eq 0) then PS = p else PS = [PS,p]
   ; RTB changed from a_id = i 
   ; a_id = i 
   ; if (i eq 0) then a_id=-1 else a_id = i ; set parameter id variable
endfor ; evaluate every data structure

; Check flag to determine if any plottable variables were found.
;TJK changed the two status messages to be a little more descriptive - 
;basically, no data was found that could be plotted.
if plottable_found eq 0 then begin
   print,'STATUS=No plottable data found for selected variables.'
   print,'STATUS=Please select another time range. Either your time range was too short (no data found for the interval) or'
   print,'STATUS=too long (your session timed out before all of the data you requested could be read).'
   if (reportflag eq 1) then begin
      printf,1,'STATUS=A plotting error has occurred'
      close,1
   endif 
   return,-1 
endif 

; make sure timetexts will be displayed last in gif/window:
if keyword_set(combine) then begin
   q12 = where(ps.ptype eq 12 or ps.ptype eq 0)
   if q12(0) ne -1 then begin
      qnot12=where(ps.ptype ne 12 and ps.ptype ne 0)
      if qnot12(0) ne -1 then begin
         ps_tmp=[ps(qnot12),ps(q12)]
      endif else begin
         ps_tmp=[ps(q12(0)),ps(q12)]
         ps_tmp(0).vname='CDAWeb_created_variable' & ps_tmp(0).ptype=1 & ps_tmp(0).npanels=1
      endelse 
   endif else begin
      ps_tmp=ps
   endelse
   ps=ps_tmp     
endif else begin
   min_snum=min(ps.snum,max=max_snum)
   psd=[ps(0)]
   psd.ptype=-99
   for i=min_snum,max_snum do begin
      q_snum=where(ps.snum eq i)
      ps_snum=ps(q_snum)
      ;q12=where(ps_snum.ptype eq 12 or ps_snum.ptype eq 0) ; support data (0) goes
      q12=where(ps_snum.ptype eq 12 or ps_snum.ptype eq 0) ; support data (0) goes
   							; after plot types
      q_zero=where(ps_snum.ptype eq 0,count)
      ;if q12(0) ne -1 then begin
      if (q12(0) ne -1) and (count ne n_elements(ps_snum.ptype)) then begin
         qnot12=where(ps_snum.ptype ne 12 and ps_snum.ptype ne 0)
         if qnot12(0) ne -1 then begin
            ps_tmp=[ps_snum(qnot12),ps_snum(q12)]
         endif else begin
            ps_tmp=[ps_snum(q12(0)),ps_snum(q12)]
            ps_tmp(0).vname='CDAWeb_created_variable' & ps_tmp(0).ptype=1 & ps_tmp(0).npanels=1
         endelse      
      endif else begin
         ps_tmp=[ps_snum]
      endelse   
      psd=[psd,ps_tmp]
   endfor
   ps=psd(where(psd.ptype ne -99))
endelse   
;
; n_q12 and q12 to be used later, if keyword 'combine' is set. RCJ
q12 = where(ps.ptype eq 12,n_q12)
;
; For SSCWEB read keyword file
if(SSCWEB) then begin
   REPORT=OUTDIR+'idl_'+PID+'.rep' 
   reportflag=1L 
   OPENW,1,REPORT,132,WIDTH=132
   station=create_struct('NUM',0)
   status=map_keywords(ORB_VW=orb_vw, XUMN=xumn, XUMX=xumx, YUMN=yumn, $
              YUMX=yumx,ZUMN=zumn,ZUMX=zumx,RUMN=rumn,RUMX=rumx,  $
              DOYMARK=doymark, HRMARK=hrmark, HRTICK=hrtick, $
	      MNTICK=mntick,MNMARK=mnmark,LNTHICK=lnthick,$
              CHTSIZE=chtsize, BZ=bz, PRESS=press, STATION=station, $
              IPROJ=iproj,LIM=lim,LATDEL=latdel, LONDEL=londel, $
              Ttitle=thetitle,SYMSIZ=symsiz, SYMCOL=symcol, POLAT=polat, $
              POLON=polon, ROT=rot, LNLABEL=lnlabel,BSMP=bsmp,ATLB=autolabel,$
              DTLB=datelabel,XSIZE=xs_ssc,YSIZE=ys_ssc, NOCONT=nocont,$
              EQLSCL=eqlscl,PANEL=panel,$
              REPORT=reportflag,PID=PID,OUTDIR=OUTDIR,US=us,_extra=extras)
              
   if(n_elements(xs_ssc) ne 0) then WS.xs=xs_ssc
   if(n_elements(ys_ssc) ne 0) then WS.ys=ys_ssc
endif

; Need to determine GIF naming method, which depends on whether only a single ; GIF file or multiple ones.  Currently, only a single GIF can be produced
; by this routine, but this will have to change, and this will involve the
; other plot types, which will have to be in separate gifs.
multiple_gifs = 0L & gif_counter = 0L ; initialize assuming single
if keyword_set(GIF) then begin
   if ((NOT keyword_set(COMBINE))AND(n_params() gt 1)) then multiple_gifs=1L
endif

; If we are combining variables from different megastructures, then we must
; determine the start time and stop time of the data so that they can be
; plotted along a common axis.  This is overridden by TSTART/TSTOP keywords

; TJK commented out start_time = 0.0D0 ; initialize
; need to set default values for start_time and stop_time
; if min in p.btime = [0,0,epoch] then min epoch will be missed RTB
btime=ps.btime                                ; RTB
we=where(btime ne 0.D0,wc)                   ; RTB
min_ep=btime(we)                             ; RTB
start_time = min(min_ep)
;start_time = min(p.btime)
stop_time = max(ps.etime)

if keyword_set(TSTART) then begin ; determine datatype and process if needed
   b = size(TSTART) & c = n_elements(b)
   if (b(c-2) eq 5) then start_time = TSTART $ ; double float already
   else if (b(c-2) eq 7) then start_time = encode_cdfepoch(TSTART) $ ; string
   else begin
      if (reportflag eq 1) then $ 
      printf,1,'STATUS= Time Range Error' & close, 1
      print,'STATUS= Time Range Error'
      print,'ERROR= TSTART parameter must be STRING or DOUBLE' & return,-1
   endelse
endif else begin
   if keyword_set(COMBINE) then begin
      ; first find all structures with variable plotted as t/s or spectrum
      if keyword_set(DEBUG) then print,'Computing combined axis start time...'
      w = where(((PS.ptype eq 1)OR(PS.ptype eq 2)),wc)
      if (wc gt 0) then begin ; now find earliest time of these structures
         b = PS(w).snum & bs = size(b) ; determine structure numbers
         if (bs(0) gt 0) then begin & c=uniq(b) & b=b(c) & endif ; make list
         c = where(PS.btime ne 0.0D0,wc) ; find list of all start times
         if (wc gt 0) then begin ;TJK added
            w = where(PS(c).snum eq b) ; find which times belong to t/s & spectro
            start_time = min(PS(c(w)).btime) & b = decode_cdfepoch(start_time)
            if keyword_set(DEBUG) then print,'Combined axis start time=',b
         endif else $
         if keyword_set(DEBUG) then print,'Combined axis start time=',start_time
      endif
   endif
endelse


; If we are combining variables from different megastructures, then we must
; determine the stop time of the data so that they can be plotted along a
; common axis.  This is overridden by TSTOP keyword.
; TJK commented out stop_time = 0.0D0 ; initialize

if keyword_set(TSTOP) then begin ; determine datatype and process if needed
   b = size(TSTOP) & c = n_elements(b)
   if (b(c-2) eq 5) then stop_time = TSTOP $ ; double float already
   else if (b(c-2) eq 7) then stop_time = encode_cdfepoch(TSTOP) $ ; string
   else begin
      if (reportflag eq 1) then $
      printf,1,'STATUS= Time range error.' & close,1
      print,'ERROR= TSTOP parameter must be STRING or DOUBLE' & return,-1
      print, 'STATUS= Time range error.'
   endelse
endif else begin
   if keyword_set(COMBINE) then begin
      ; first find all structures with variable plotted as t/s or spectrum
      if keyword_set(DEBUG) then print,'Computing combined axis stop time...'
      w = where(((PS.ptype eq 1)OR(PS.ptype eq 2)),wc)
      if (wc gt 0) then begin ; now find latest time of these structures
         b = PS(w).snum & bs = size(b) ; determine structure numbers
         if (bs(0) gt 0) then begin & c=uniq(b) & b=b(c) & endif ; make list
         c = where(PS.etime ne 0.0D0,wc) ; find list of all stop times
         if (wc gt 0) then begin ;TJK added
            w = where(PS(c).snum eq b) ; find which times belong to t/s & spectro
            stop_time = max(PS(c(w)).etime) & b = decode_cdfepoch(stop_time)
            if keyword_set(DEBUG) then print,'Combined axis stop time=',b
         endif else $
         if keyword_set(DEBUG) then print,'Combined axis stop time=',stop_time
      endif
   endif
endelse

; Modify the window margin if ordered or required for spectrogram plots
if keyword_set(CDAWEB) then begin ; leave space for colorbar
   ; TJK change this allow more space on the right  WS.xmargin=[100,100] & cdawebflag = 1L
   WS.xmargin=[90,110] & cdawebflag = 1L
endif else begin ; determine if extra space for spectrogram colorbar is needed
   w = where(PS.ptype eq 2,wc)
   if (wc gt 0) then WS.xmargin=[89,110]
   cdawebflag = 0L
endelse

if ((NOT keyword_set(GIF)) and keyword_set(CDAWEB)) then begin
   CDAWEB = 0L ; turn CDAWEB off if no gif.
   cdawebflag = 0L
endif

; Make a pass thru the plot script and generate all timeseries and
; spectrogram plots.  Create windows or gif files as needed.

; gather some info to be used if there is ptype = 12. RCJ
pheight_12=10 ; 10 is the ysize of each line of label
labeloffset=-40
prev_snum=ps(0).snum
;

for i=0,n_elements(PS)-1 do begin
   ; Prepare for plotting by creating window and last_plot flag
   if ((PS(i).ptype eq 1)OR(PS(i).ptype eq 2)OR(PS(i).ptype eq 7)OR $
      (PS(i).ptype eq 12)) then begin
      ;
      q12snum=where(ps.snum eq ps(i).snum and ps.ptype eq 12,n_q12snum)
      if not keyword_set(combine) and (q12snum(0) ne -1) and (ps(i).snum ne prev_snum) then begin
         labeloffset=-40  ; reset offset for next timetext
         prev_snum=ps(i).snum
      endif
      ;if q12snum(0) ne -1 then print,ps(q12snum).vname,ps(q12snum).ptype,ps(q12snum).npanels
      ;
      ; Determine if this plot will fit within current window/gif
      if (PS(i).ptype eq 12) then b = WS.pos(3) - (PS(i).npanels * pheight_12) $
    	     else b = WS.pos(3) - (PS(i).npanels * pheight)
      ;if (b lt WS.ymargin(1)) then new_window = 1 else new_window = 0
      ; the above statement was valid when we only had graphs
      ; but now we have labels too. RCJ 03/10/00
      if (b lt 50) then new_window = 1 else new_window = 0
      
      ; if nonoise is set, make title say so
      if keyword_set(nonoise) then ps(i).title=ps(i).title+'!CFiltered to remove values >3-sigma from mean of all plotted values'

      ; Create a window/gif file if current plot will not fit
      if (new_window eq 1) then begin
         if keyword_set(DEBUG) then print,'Creating new window...'
         if keyword_set(GIF) then begin ; writing to gif file
            ; Close the currently open gif file - if any
            if (gifopen eq 1) then begin
               project_subtitle,a.(0),mytitle,SSCWEB=SSCWEB ; title/subtitle the gif
               deviceclose & gifopen=0 ; close it
            endif
            ; Determine the size for the next gif file
            if keyword_set(COMBINE) then begin
               ; compute size to fit t/s and spectrograms for ALL variables
               w = where((PS.ptype eq 1)OR(PS.ptype eq 2)OR(PS.ptype eq 7))
               if (w(0) ne -1) then b = (total(PS(w).npanels) * pheight) else b = 0
               if (q12(0) ne -1) then b = b +(total(ps(q12).npanels)* pheight_12)
               if (n_params() eq 1) then mytitle = PS(i).title else mytitle=''
            endif else begin
               ; compute size to fit t/s and spectrograms for THIS structure
               w = where((PS.snum eq PS(i).snum) and ((PS.ptype eq 1)OR(PS.ptype eq 2)OR(PS.ptype eq 7)))
               if (w(0) ne -1) then b = (total(PS(w).npanels) * pheight) else b = 0
               if (q12snum(0) ne -1) then b = b + (total(ps(q12snum).npanels) * pheight_12)
               mytitle = PS(i).title
            endelse
            ; Determine name for new gif file and create GIF/window
            ;if (gif_counter gt 0) then begin
            ;c = strpos(GIF,'.gif') ; search for .gif suffix
            ;if (c ne -1) then begin
            ;c = strmid(GIF,0,c) & GIF=c+strtrim(string(gif_counter),2)+'.gif'
            ;endif else GIF=GIF+strtrim(string(gif_counter),2)
            ;endif
            if(gif_counter lt 100) then gifn='0'+strtrim(string(gif_counter),2) 
            if(gif_counter lt 10) then gifn='00'+strtrim(string(gif_counter),2) 
            if(gif_counter ge 100) then gifn=strtrim(string(gif_counter),2)
            GIF=outdir+PS(i).source+'_'+pid+'_'+gifn+'.gif'
            ; Initialize window state and open the gif file
            WS.ys = b + WS.ymargin(0) + WS.ymargin(1) ; add room for timeaxis
            ;
            deviceopen,6,fileOutput=GIF,sizeWindow=[WS.xs,WS.ys]
            gifopen=1L & gif_counter = gif_counter + 1
            ; RTB test p.charsize for carriage returns in labels
            ;!P.Charsize=1 
        
            ; Modify source name for SSCWEB DATASET label 
            if(SSCWEB) then begin
               if (PS(i).snum ne a_id) then begin
                  s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
               endif
               satname=strtrim(a.epoch.source_name,2)
               PS(i).source= PS(i).source + '_' + satname
            endif

            if (reportflag eq 1) then begin 
               printf, 1, 'DATASET=',PS(i).source
               printf,1,'GIF=',GIF
            endif
            print, 'DATASET=',PS(i).source
            print,'GIF=',GIF
         endif  ; end if keyword_set(GIF)

         if NOT keyword_set(GIF) then begin ; producing XWINDOWS
            if keyword_set(COMBINE) then begin ; size for as many vars as possible
               b=0 & c=0 ; initialize loop
               for j=i,n_elements(PS)-1 do begin & d = PS(j).ptype
                  ;if ((d eq 1)OR(d eq 2)) then begin
                  if ((d eq 1)OR(d eq 2)OR(d eq 7)OR(d eq 12)) then begin
                     if (d eq 12) then b = PS(j).npanels * pheight_12 $
              		else b = PS(j).npanels * pheight
                     if ((c+b) le (max_ysize - WS.ymargin(1))) then c=c+b
                  endif
               endfor
               if (n_params() eq 1) then mytitle = PS(i).title else mytitle=''
            endif else begin ; size only for variables from current structure
               b=0 & c=0 ; initialize loop
               for j=i,n_elements(PS)-1 do begin
                  if (PS(j).snum eq PS(i).snum) then begin & d = PS(j).ptype
                     if ((d eq 1)OR(d eq 2)OR(d eq 7)OR(d eq 12)) then begin
                        ;if ((d eq 1)OR(d eq 2)) then begin
                        if (d eq 12) then b = PS(j).npanels * pheight_12 $
              		   else b = PS(j).npanels * pheight
                        if ((c+b) le (max_ysize - WS.ymargin(1))) then c=c+b
                     endif
                  endif
               endfor
               mytitle = PS(i).title
            endelse

            ; Verify that the height of the new window is valid
            if (c eq 0) then begin
               if (reportflag eq 1) then begin 
                  printf,1,'STATUS=An error occurred plotting this variable
                  close, 1
               endif
               print,'STATUS=An error occurred plotting this variable
               print,'ERROR=Single variable does not fit in window' & return,-1
            endif else begin ; create the window and initialize window_state
               WS.ys = c + WS.ymargin(0) + WS.ymargin(1) ; add room for timeaxis
	       deviceopen, 0 ;TJK added so that labels will come out on stacked and spectrogram
               window,/FREE,XSIZE=WS.xs,YSIZE=WS.ys,TITLE=mytitle
               if (reportflag eq 1) then printf,1,'WINDOW=',mytitle
            endelse
         endif  ; end if not keyword_set(GIF)

         ; Reinitialize window state
         WS.snum = PS(i).snum
         WS.pos(0) = WS.xmargin(0)                     ; x origin
         WS.pos(2) = WS.xs - WS.xmargin(1)             ; x corner
         WS.pos(3) = WS.ys - WS.ymargin(0)             ; y corner
         if (PS(i).ptype eq 12) then WS.pos(1) = (WS.ys - WS.ymargin(0)) - pheight_12 $
      	     else WS.pos(1) = (WS.ys - WS.ymargin(0)) - pheight ; y origin

      endif  ; end if new_window eq 1

      ; Determine if this plot will be the first/last in the window
      first_plot = new_window ; it is first if this is a new window
      if (PS(i).ptype eq 12) then b = WS.pos(1) - (PS(i).npanels * pheight_12) $
      			else b = WS.pos(1) - (PS(i).npanels * pheight)
      			
      ; Life was simple before the time_text plots:    RCJ			
      ;if (b lt WS.ymargin(1)) then last_plot = 1 else last_plot = 0
      ; Now this is what we have to do to determine last_plot:
      if (PS(i).ptype ne 12) then begin
         if (b lt WS.ymargin(1)) then last_plot = 1 else last_plot = 0
         if (q12(0) ne -1) and ((PS(i+1).ptype eq 12) or (PS(i+1).ptype eq 0)) then last_plot=1 
      endif else last_plot=1
      if (PS(i).ptype eq 12) then begin
         if keyword_set(combine) then begin
            if (n_q12 eq 1) then last_plot = 1 else last_plot = 0
            n_q12=n_q12-1
         endif else begin
            if (n_q12snum eq 1) then last_plot = 1 else last_plot = 0
            n_q12snum=n_q12snum-1
         endelse
      endif      
      ;print,' ps.type =  ',PS(i).ptype
      ;print,' b, ws.ymargin(1), last_plot = ',b, ws.ymargin(1), last_plot			
   endif   ; end if ps.ptype eq 1,2,7 or 12

   ; Generate TIME SERIES plots
   if (PS(i).ptype eq 1) then begin
      ; Ensure that 'a' holds the correct data structure
      SCATTER = 0L  ; turn off by default
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
      endif
      ; Get the index of the time variable associated with variable to be plotted
      b = a.(PS(i).vnum).DEPEND_0 & c = tagindex(b(0),tag_names(a))
      ; Produce debug output if requested
      if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' as time series.'
      ;****** TJK adding code for handling the parsing of the DISPLAY_TYPE attribute 
      ; 	for time series plots.  In this plot types case, we are looking for a
      ;        a syntax like time_series>y=flux(1) (July 30, 1999).
      ; determine how many dimensions are in the data by looking at
      ; the data - unfortunately I have to get it out of either the plain
      ; structure or a handle.

      Yvar = (a.(PS(i).vnum))
      t = size(Yvar)
      if (t(n_elements(t)-2) ne 8) then begin
         print,'ERROR=input to plotmaster not a structure' & return,-1
      endif else begin
	 YTAGS = tag_names(Yvar) ; avoid multiple calls to tag_names
         t = tagindex('DAT',YTAGS)
         if (t(0) ne -1) then THEDATA = Yvar.DAT $
  	 else begin
    	    t = tagindex('HANDLE',YTAGS)
     	    if (t(0) ne -1) then handle_value,Yvar.HANDLE,THEDATA $
    	    else begin
      	       print,'ERROR=Yvariable does not have DAT or HANDLE tag' & return,-1
	    endelse
         endelse
      endelse
      datasize = size(thedata)
      ; Determine if the display type variable attribute is present
      d = tagindex('DISPLAY_TYPE',tag_names(a.(PS(i).vnum)))
      if (d(0) ne -1) then begin
	;TJK 5/14/2001 - added two "keywords" to the display_type syntax for time_series, scatter and noauto
	; to allow for scatter plots vs. line plots and no auto scaling (use the values specified in
	; the scalemin/max attributes.
	  keywords=str_sep(a.(PS(i).vnum).display_type,'>')  ; keyword 1 or greater  
	  scn=where(strupcase(keywords) eq 'SCATTER',sn)
	  ;turn scatter plot on if "scatter" is set
	  if (sn gt 0) then SCATTER = 1L else SCATTER = 0L

	  acn=where(strupcase(keywords) eq 'NOAUTO',an)
	  ;turn autoscaling off if "noauto" is set
	  if (an gt 0) then autoscale = 0L else autoscale = 1L 

         ; examine_spectrogram_dt looks at the DISPLAY_TYPE structure member in 
         ; detail. for spectrograms and stacked time series the DISPLAY_TYPE 
         ; can contain syntax like the following: stack_plot>y=flux(1),y=flux(3),
         ; y=flux(5),z=energy where this indicates that we only want to plot 
         ; the 1st, 3rd and 5th energy channel for the flux variable. This 
         ; routine returns a structure of the form e = {x:xname,y:yname,z:zname,
         ; npanels:npanels,dvary:dvary,elist:elist,lptrn:lptrn,igram:igram}, 

         e = examine_spectrogram_dt(a.(PS(i).vnum).DISPLAY_TYPE) & esize=size(e)
         if keyword_set(ELEMENTS) then begin
	    datasize = size(ELEMENTS)
            ;rebuild e structure and set the e.elist to contain the index values for
            ;all elements in the y variable.
	    elist = lonarr(datasize(1))
	    elist = ELEMENTS
	    e = {x:e.x,y:e.y,z:e.z,npanels:datasize(1),$
                      dvary:e.dvary,elist:elist,lptrn:e.lptrn,igram:e.igram}
	    esize=size(e) ; since I rebuild e, then need to determine the size again.
         endif else begin
            if (esize(n_elements(esize)-2) eq 8) then begin ; results confirmed
  	       if (e.npanels eq 0) then begin
                  ;rebuild e structure and set the e.elist to contain the index values for
                  ;all elements in the y variable.
                  elist = lindgen(datasize(1)) ;TJK changed this from a for loop
	          e = {x:e.x,y:e.y,z:e.z,npanels:datasize(1),$
                          dvary:e.dvary,elist:elist,lptrn:e.lptrn,igram:e.igram}
	          esize=size(e) ; since I rebuild e, then need to determine the size again.
	       endif
	    endif else begin ;no arguments to time_series display_type
               ;build an e structure and set the e.elist to contain the index values for
               ;all elements in the y variable.
               elist = lindgen(datasize(1)) ;TJK changed this from a for loop
	       e = {elist:elist}
	       esize=size(e) ; since I rebuild e, then need to determine the size again.
	    endelse
         endelse ;else looking for the element information through the display_type 
	 ;attribute vs. the direct IDL use of the ELEMENTS keyword

      endif else begin ;else if no display_type exists
         ;build an e structure and set the e.elist to contain the index values for
         ;all elements in the y variable.
         elist = lindgen(datasize(1)) ;TJK changed this from a for loop
         e = {elist:elist}
         esize=size(e) ; since I build e, then need to determine the size again.
      endelse

      ;****** end of added section for picking out single array elements to
      ;be plotted.
      ;q12snum is where(PS(current_snum).ptype eq 12). if there are extra x-axis labels do not print
    	 			; subtitle after the last graph:
      if keyword_set(combine) then begin
         if (q12(0) ne -1) then nosubtitle=1 else nosubtitle=0
      endif else begin
         if (q12snum(0) ne -1) then nosubtitle=1 else nosubtitle=0
      endelse 
      if ps(i).vname eq 'CDAWeb_created_variable' then onlylabel=1
      ; Produce the time series plot with specific time axis range
     if ((start_time ne 0.0D0)AND(stop_time ne 0.0D0)) then begin
         s = plot_timeseries(a.(c(0)),a.(PS(i).vnum),POSITION=WS.pos,/CDAWEB,$
                          PANEL_HEIGHT=pheight,AUTO=autoscale, ELEMENTS=e.elist,$
                          TSTART=start_time,TSTOP=stop_time,$
                          NOSUBTITLE=nosubtitle, ONLYLABEL=onlylabel,$
                          FIRSTPLOT=first_plot,LASTPLOT=last_plot,$
                          NONOISE=NONOISE,SCATTER=SCATTER,DEBUG=debugflag)
         if(s eq -1) then begin
            if(reportflag) then printf, 1, 'STATUS=Time-series plot failed' & close, 1
            print, 'STATUS=Time-series plot failed'
            return, -1
         endif
      endif else begin ; Produce the time series plot normally
         s = plot_timeseries(a.(c(0)),a.(PS(i).vnum),POSITION=WS.pos,/CDAWEB,$
                         PANEL_HEIGHT=pheight,AUTO=autoscale, ELEMENTS=e.elist,$
                          FIRSTPLOT=first_plot,LASTPLOT=last_plot,$
                          NOSUBTITLE=nosubtitle, ONLYLABEL=onlylabel,$
                          NONOISE=NONOISE,SCATTER=SCATTER,DEBUG=debugflag)
         if(s eq -1) then begin
            if(reportflag) then printf, 1, 'STATUS=Time-series plot failed' & close, 1
            print, 'STATUS=Time-series plot failed'
            return, -1
         endif
      endelse
      onlylabel=0
      ; Update the state of the window
      WS.pos(3) = WS.pos(3) - (pheight * PS(i).npanels) ; update Y corner
      WS.pos(1) = WS.pos(1) - (pheight * PS(i).npanels) ; update Y origin
   endif   ; end if ps(i).ptype eq 1

   ; Generate SPECTROGRAM plots
   if (PS(i).ptype eq 2) then begin
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
      endif
      ; Determine default x and y variable from depend attributes
      b = a.(PS(i).vnum).DEPEND_0 & c = tagindex(b(0),tag_names(a))
      b = a.(PS(i).vnum).DEPEND_1 & d = tagindex(b(0),tag_names(a))
      ; Determine if the display type variable attribute is present
      b = tagindex('DISPLAY_TYPE',tag_names(a.(PS(i).vnum)))
      if (b(0) ne -1) then begin
         ; examine_spectrogram_dt looks at the DISPLAY_TYPE structure member in detail.
         ; for spectrograms and stacked time series the DISPLAY_TYPE can contain syntax
         ; like the following: SPECTROGRAM>y=flux(1),y=flux(3),y=flux(5),z=energy
         ; where this indicates that we only want to plot the 1st, 3rd and 5th energy 
         ; channel for the flux variable. This routine returns a structure of the form 
         ;	e = {x:xname,y:yname,z:zname,npanels:npanels,dvary:dvary,elist:elist,
         ;	lptrn:lptrn,igram:igram}, 
         e = examine_spectrogram_dt(a.(PS(i).vnum).DISPLAY_TYPE) & esize=size(e)

         if (esize(n_elements(esize)-2) eq 8) then begin ; results confirmed
            if (e.x ne '') then c = tagindex(e.x,tag_names(a))
            if (e.y ne '') then d = tagindex(e.y,tag_names(a))
         endif
      endif
      ; Produce debug output if requested.
      if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' as spectrogram.'
      ; Generate the spectrogram
      if NOT keyword_set(GIF) then deviceopen,0 ; producing XWINDOWS

      ;q12snum is where(PS(current_snum).ptype eq 12)  if there are extra x-axis labels do not print
    				; subtitle after the last graph:
      if keyword_set(combine) then begin
         if (q12(0) ne -1) then nosubtitle=1 else nosubtitle=0
      endif else begin
         if (q12snum(0) ne -1) then nosubtitle=1 else nosubtitle=0
      endelse  

      s = plot_spectrogram(a.(c(0)),a.(d(0)),a.(PS(i).vnum),$
                   POSITION=WS.pos,/CDAWEB,QUICK=quickflag,$
                   PANEL_HEIGHT=pheight,AUTO=autoscale,NOCLIP=noclipflag,$
                   TSTART=start_time,TSTOP=stop_time,FILLER=fillflag,$
                   FIRSTPLOT=first_plot,LASTPLOT=last_plot,$
                   NOSUBTITLE=nosubtitle, $
                   SLOW=slowflag,SMOOTH=smoothflag,DEBUG=debugflag)
      if(s eq -1) then begin
         if(reportflag) then printf, 1, 'STATUS=Spectrogram plot failed' & close, 1
         print, 'STATUS=Spectrogram plot failed'
         return, -1
      endif
      ; Update the state of the window
      WS.pos(3) = WS.pos(3) - (pheight * PS(i).npanels) ; update Y corner
      WS.pos(1) = WS.pos(1) - (pheight * PS(i).npanels) ; update Y origin
   endif

   ; Make a pass thru the plot script and generate all stacked time series plots
   ; Generate STACKED TIME SERIES plot
   if (PS(i).ptype eq 7) then begin
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
      endif
      ; Get the index of the time variable associated with variable to be plotted
      ; Determine default x, y and z variables from depend attributes
      b = a.(PS(i).vnum).DEPEND_0 & c = tagindex(b(0),tag_names(a))
      b = a.(PS(i).vnum).DEPEND_1 & z = tagindex(b(0),tag_names(a))
    
      ; Determine if the display type variable attribute is present
      b = tagindex('DISPLAY_TYPE',tag_names(a.(PS(i).vnum)))
      if (b(0) ne -1) then begin
         ; examine_spectrogram_dt looks at the DISPLAY_TYPE structure member in 
         ; detail. for spectrograms and stacked time series the DISPLAY_TYPE 
         ; can contain syntax like the following: stack_plot>y=flux(1),y=flux(3),
         ; y=flux(5),z=energy where this indicates that we only want to plot 
         ; the 1st, 3rd and 5th energy channel for the flux variable. This 
         ; routine returns a structure of the form e = {x:xname,y:yname,z:zname,
         ; npanels:npanels,dvary:dvary,elist:elist,lptrn:lptrn,igram:igram}, 

         e = examine_spectrogram_dt(a.(PS(i).vnum).DISPLAY_TYPE) & esize=size(e)

         ; determine how many dimensions are in the data by looking at
         ; the data - unfortunately I have to get it out of either the plain
         ; structure or a handle.

         Yvar = (a.(PS(i).vnum))
         t = size(Yvar)
	 if (t(n_elements(t)-2) ne 8) then begin
	    print,'ERROR=input to plotmaster not a structure' & return,-1
	 endif else begin
	    YTAGS = tag_names(Yvar) ; avoid multiple calls to tag_names
  	    t = tagindex('DAT',YTAGS)
  	    if (t(0) ne -1) then THEDATA = Yvar.DAT $
  	    else begin
    	       t = tagindex('HANDLE',YTAGS)
     	       if (t(0) ne -1) then handle_value,Yvar.HANDLE,THEDATA $
    	       else begin
      	          print,'ERROR=Yvariable does not have DAT or HANDLE tag' & return,-1
	       endelse
            endelse
         endelse
         datasize = size(thedata)

         ;TJK shouldn't need here as well as above
         ;if keyword_set(PANEL_HEIGHT) then pheight=PANEL_HEIGHT else pheight=100

         if keyword_set(ELEMENTS) then begin
	    datasize = size(ELEMENTS)
            ;rebuild e structure and set the e.elist to contain the index values for
            ;all elements in the y variable.
	    elist = lonarr(datasize(1))
	    elist = ELEMENTS
	    e = {x:e.x,y:e.y,z:e.z,npanels:datasize(1),$
                   dvary:e.dvary,elist:elist,lptrn:e.lptrn,igram:e.igram}
	    esize=size(e) ; since I rebuild e, then need to determine the size again.
         endif else begin
	    if (e.npanels eq 0) then begin
               ;rebuild e structure and set the e.elist to contain the index values for
               ;all elements in the y variable.
	       elist = lonarr(datasize(1))
               for j = 0, datasize(1)-1 do elist(j) = j
               ;TJK	pheight = pheight*(n_elements(elist))
	       e = {x:e.x,y:e.y,z:e.z,npanels:datasize(1),$
                   dvary:e.dvary,elist:elist,lptrn:e.lptrn,igram:e.igram}
	       esize=size(e) ; since I rebuild e, then need to determine the size again.
	    endif
         endelse

         if (esize(n_elements(esize)-2) eq 8) then begin ; results confirmed
            if (e.x ne '') then c = tagindex(e.x,tag_names(a))
            if (e.y ne '') then d = tagindex(e.y,tag_names(a))
            if (e.z ne '') then f = tagindex(e.z,tag_names(a)) $
	    else f = z
         endif

         ;if (reportflag eq 1) then printf, 1, 'DATASET=',PS(i).source
         ;print, 'DATASET=',PS(i).source
		
         ; Produce debug output if requested
         if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' as stacked time series.'

         ;q12snum is where(PS(current_snum).ptype eq 12) ; if there are extra x-axis labels do not print
    				; subtitle after the last graph:
         if keyword_set(combine) then begin
            if (q12(0) ne -1) then nosubtitle=1 else nosubtitle=0
         endif else begin
            if (q12snum(0) ne -1) then nosubtitle=1 else nosubtitle=0
         endelse  

         ; Produce the stacked time series plot with specific time axis range
         if ((start_time ne 0.0D0)AND(stop_time ne 0.0D0)) then begin
            s = plot_stack(a.(c(0)),a.(PS(i).vnum),a.(f(0)),/CDAWEB,$
       	                  ELEMENTS = e.elist, $ ;XSIZE = 400,$
       			  ;YSIZE = 700, $
			  PANEL_HEIGHT=pheight,$
			  POSITION=WS.pos, NOSUBTITLE=nosubtitle,$
       		          AUTO=autoscale,GIF=GIF,$
               	          TSTART=start_time,TSTOP=stop_time,$
                       	  FIRSTPLOT=first_plot,LASTPLOT=last_plot,$
                       	  NONOISE=NONOISE,DEBUG=debugflag, /COLORBAR);,$/NOGAPS)
	
            if(s eq -1) then begin
               if(reportflag) then printf, 1, 'STATUS=Stack plot failed' & close, 1
               print, 'STATUS=Stack plot failed'
               ;return, -1 RTB; Allows remaining structures to plot
            endif else begin
               if(s eq -2) then begin ;all fill data found - status being printed from plot_stack
                  ; return, -1  RTB; Allows remaining structures to plot
               endif
            endelse
         endif else begin ; Produce the stack plot normally
            s = plot_stack(a.(c(0)),a.(PS(i).vnum),a.(f(0)),/CDAWEB,$
                          ELEMENTS = e.elist, $ ;XSIZE = 400,$
       			 ;YSIZE = 700, $
			 POSITION=WS.pos, NOSUBTITLE=nosubtitle,$
			 PANEL_HEIGHT=pheight,$
 			 AUTO=autoscale, GIF=GIF,$
                         FIRSTPLOT=first_plot,LASTPLOT=last_plot,$
                         NONOISE=NONOISE,DEBUG=debugflag, /COLORBAR);,$/NOGAPS)
            if(s eq -1) then begin
               if(reportflag) then printf, 1, 'STATUS=Stack plot failed' & close, 1
               print, 'STATUS=Stack plot failed'
               deviceclose ; close any open gif
               ;return, -1 RTB; Allows remaining structures to plot
            endif else begin
               if(s eq -2) then begin ;all fill data found - status being printed from plot_stack
                  deviceclose ; close any open gif
                  ;return, -1 RTB; Allows remaining structures to plot
               endif
            endelse

            ; if keyword_set(GIF) then begin
            ;if (reportflag) then printf, 1, 'GIF=',GIF else print,'GIF=',GIF
            ;endif

         endelse ; end stacked time series plot w/o start and stop time specs.
      endif ;   if (b(0) ne -1) 
      ; Update the state of the window
      WS.pos(3) = WS.pos(3) - (pheight * PS(i).npanels) ; update Y corner
      WS.pos(1) = WS.pos(1) - (pheight * PS(i).npanels) ; update Y origin

   endif ; if plottype eq stacked time series

   ;  Generate PLOT_TIMETEXT plot
   ;
   if (PS(i).ptype eq 12) then begin
      ; the following was copied/pasted from the time series section above
      ; and modified
      ;
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
      endif
      ; Get the index of the time variable associated with variable to be plotted
      b = a.(PS(i).vnum).DEPEND_0 & c = tagindex(b(0),tag_names(a))
      ; Produce debug output if requested
      if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' as time text.'
      ;
      ; TJK added code for handling the parsing of the DISPLAY_TYPE attribute 
      ; for time series plots.  In this plot types case, we are looking for a
      ; a syntax like time_series>y=flux(1) (July 30, 1999).
      ; determine how many dimensions are in the data by looking at
      ; the data - unfortunately I have to get it out of either the plain
      ; structure or a handle.

      Yvar = (a.(PS(i).vnum))
      t = size(Yvar)
      if (t(n_elements(t)-2) ne 8) then begin
         print,'ERROR=input to plotmaster not a structure' & return,-1
      endif else begin
	 YTAGS = tag_names(Yvar) ; avoid multiple calls to tag_names
         t = tagindex('DAT',YTAGS)
         if (t(0) ne -1) then THEDATA = Yvar.DAT $
  	 else begin
    	    t = tagindex('HANDLE',YTAGS)
     	    if (t(0) ne -1) then handle_value,Yvar.HANDLE,THEDATA $
    	    else begin
      	       print,'ERROR=Yvariable does not have DAT or HANDLE tag' & return,-1
	    endelse
         endelse
      endelse
      datasize = size(thedata)
      ; Determine if the display type variable attribute is present
      d = tagindex('DISPLAY_TYPE',tag_names(a.(PS(i).vnum)))
      if (d(0) ne -1) then begin
         ; examine_spectrogram_dt looks at the DISPLAY_TYPE structure member in 
         ; detail. for time series, time text, spectrograms and 
         ; stacked time series the DISPLAY_TYPE 
         ; can contain syntax like the following: stack_plot>y=flux(1),y=flux(3),
         ; y=flux(5),z=energy where this indicates that we only want to plot 
         ; the 1st, 3rd and 5th energy channel for the flux variable. This 
         ; routine returns a structure of the form e = {x:xname,y:yname,z:zname,
         ; npanels:npanels,dvary:dvary,elist:elist,lptrn:lptrn,igram:igram}, 
         e = examine_spectrogram_dt(a.(PS(i).vnum).DISPLAY_TYPE) & esize=size(e)
         if keyword_set(ELEMENTS) then begin
	    datasize = size(ELEMENTS)
            ;rebuild e structure and set the e.elist to contain the index values for
            ;all elements in the y variable.
	    elist = lonarr(datasize(1))
	    elist = ELEMENTS
	    e = {x:e.x,y:e.y,z:e.z,npanels:datasize(1),$
                      dvary:e.dvary,elist:elist,lptrn:e.lptrn,igram:e.igram}
	    esize=size(e) ; since I rebuild e, then need to determine the size again.
         endif else begin
            if (esize(n_elements(esize)-2) eq 8) then begin ; results confirmed
  	       if (e.npanels eq 0) then begin
                  ;rebuild e structure and set the e.elist to contain the index values for
                  ;all elements in the y variable.
                  elist = lindgen(datasize(1)) ;TJK changed this from a for loop
	          e = {x:e.x,y:e.y,z:e.z,npanels:datasize(1),$
                          dvary:e.dvary,elist:elist,lptrn:e.lptrn,igram:e.igram}
	          esize=size(e) ; since I rebuild e, then need to determine the size again.
	       endif
	    endif else begin ;no arguments to time_series display_type
               ;build an e structure and set the e.elist to contain the index values for
               ;all elements in the y variable.
               elist = lindgen(datasize(1)) ;TJK changed this from a for loop
	       e = {elist:elist}
	       esize=size(e) ; since I rebuild e, then need to determine the size again.
	    endelse
         endelse ;else looking for the element information through the display_type 
	 ;attribute vs. the direct IDL use of the ELEMENTS keyword

      endif else begin ;else if no display_type exists
         ;build an e structure and set the e.elist to contain the index values for
         ;all elements in the y variable.
         elist = lindgen(datasize(1)) ;TJK changed this from a for loop
         e = {elist:elist}
         esize=size(e) ; since I build e, then need to determine the size again.
      endelse
      if keyword_set(combine) then begin
         if (last_plot eq 1) then nosubtitle=0 else nosubtitle=1
      endif else begin
         if ps(i).ptype ne ps(i+1).ptype then nosubtitle=0 else nosubtitle=1
      endelse   
      ; Produce the time text with specific time axis range
      if ((start_time ne 0.0D0)AND(stop_time ne 0.0D0)) then begin
         ; warning: Plot_timetext assumes there's no need to open a new window.
         qv=where(ps.vname eq 'CDAWeb_created_variable')
         if (qv(0) ne -1) then onlylabel=1
         s = plot_timetext(a.(c(0)),a.(PS(i).vnum),notime=1, $ 
     			  PANEL_HEIGHT=pheight_12,AUTO=autoscale, ELEMENTS=e.elist,$
     			  plabeloffset=labeloffset, nosubtitle=nosubtitle, $
                          TSTART=start_time,TSTOP=stop_time, GIF=GIF,$
                          FIRSTPLOT=first_plot,LASTPLOT=last_plot,$
                           DEBUG=debugflag, onlylabel=onlylabel)
         if(s eq -1) then begin
            if(reportflag) then printf, 1, 'STATUS=Time-text plot failed' & close, 1
            print, 'STATUS=Time-text plot failed'
            return, -1
         endif
      endif else begin ; Produce the time text plot normally
         s = plot_timetext(a.(c(0)),a.(PS(i).vnum),notime=1, $ 
     			  PANEL_HEIGHT=pheight_12,AUTO=autoscale, ELEMENTS=e.elist,$
     			  plabeloffset=labeloffset, nosubtitle=nosubtitle, $
                          GIF=GIF,$
                          FIRSTPLOT=first_plot,LASTPLOT=last_plot,$
                           DEBUG=debugflag, onlylabel=onlylabel)
         if(s eq -1) then begin
            if(reportflag) then printf, 1, 'STATUS=Time-text plot failed' & close, 1
            print, 'STATUS=Time-text plot failed'
            return, -1
         endif
      endelse
      onlylabel=0
      labeloffset=labeloffset-(ps(i).npanels * 10) ; this is in number of pixels                         
      ; Update the state of the window
      WS.pos(3) = WS.pos(3) - (pheight_12 * PS(i).npanels) ; update Y corner
      WS.pos(1) = WS.pos(1) - (pheight_12 * PS(i).npanels) ; update Y origin
   endif ; if plottype eq time_text    
       
endfor

if (gifopen eq 1) then begin
   project_subtitle,a.(0),mytitle,SSCWEB=SSCWEB ; subtitle the gif
   deviceclose ; close any open gif
endif

a_id=-1 ; Reset structure id
; Make a pass thru the plot script and generate all image plots
for i=0,n_elements(PS)-1 do begin
   if (PS(i).ptype eq 4) then begin
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
      endif
      ; Determine name for new gif file and create GIF/window
      if keyword_set(GIF) then begin
         ;if (gif_counter gt 0) then begin
         ;c = strpos(GIF,'.gif') ; search for .gif suffix
         ;if (c ne -1) then begin
         ;c = strmid(GIF,0,c) & GIF=c+strtrim(string(gif_counter),2)+'.gif'
         ;endif else GIF=GIF+strtrim(string(gif_counter),2)
         ;endif
         if(gif_counter lt 100) then gifn='0'+strtrim(string(gif_counter),2)
         if(gif_counter lt 10) then gifn='00'+strtrim(string(gif_counter),2)
         if(gif_counter ge 100) then gifn=strtrim(string(gif_counter),2)
         GIF=outdir+PS(i).source+'_'+pid+'_'+gifn+'.gif'
         gif_counter = gif_counter + 1
      endif
      ; Produce debug output if requested
      if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' as images...'

      ; Modify source name for SSCWEB DATASET label                                  
      if(SSCWEB) then begin
         satname=strtrim(a.epoch.source_name,2)
         PS(i).source= PS(i).source + '_' + satname
      endif

      if (reportflag eq 1) then printf, 1, 'DATASET=',PS(i).source
      print, 'DATASET=',PS(i).source
      ; For CDAWEB set the FRAME=0. This will allow multiple structures w/ image
      ; data to be processed otherwise keyword_set(FRAME) is true even for structures
      ; where it shouldn't be  RTB  4/98
      if(cdawebflag) then FRAME=0
      ; Produce the images
      s = plot_images(a,PS(i).vname,THUMBSIZE=THUMBSIZE,FRAME=FRAME,$
                    CDAWEB=cdawebflag,GIF=GIF,REPORT=reportflag,$
                    TSTART=start_time,TSTOP=stop_time,NONOISE=NONOISE,$
                    DEBUG=debugflag,/COLORBAR)

      if(s eq -1) then begin
         if(reportflag) then printf, 1, 'STATUS=Image plot failed' & close, 1
         print, 'STATUS=Image plot failed'
         return, -1
      endif

   endif
endfor


;S/W to create Rick Burley's new flux images w/ an earth superimposed on the image.

a_id=-1 ; Reset structure id
; Make a pass thru the plot script and generate all flux_image plots
for i=0,n_elements(PS)-1 do begin
   if (PS(i).ptype eq 13) then begin
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
      endif
      ; Determine name for new gif file and create GIF/window
      if keyword_set(GIF) then begin
         if(gif_counter lt 100) then gifn='0'+strtrim(string(gif_counter),2)
         if(gif_counter lt 10) then gifn='00'+strtrim(string(gif_counter),2)
         if(gif_counter ge 100) then gifn=strtrim(string(gif_counter),2)
         GIF=outdir+PS(i).source+'_'+pid+'_'+gifn+'.gif'
         gif_counter = gif_counter + 1
      endif
      ; Produce debug output if requested
      if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' as flux images...'

      ; Modify source name for SSCWEB DATASET label                                  
      if(SSCWEB) then begin
         satname=strtrim(a.epoch.source_name,2)
         PS(i).source= PS(i).source + '_' + satname
      endif

      if (reportflag eq 1) then printf, 1, 'DATASET=',PS(i).source
      print, 'DATASET=',PS(i).source
      ; For CDAWEB set the FRAME=0. This will allow multiple structures w/ image
      ; data to be processed otherwise keyword_set(FRAME) is true even for structures
      ; where it shouldn't be  RTB  4/98

      ;No matter what size thumbnail you specifiy you can't get one smaller
      ;than 140x140

      if(cdawebflag) then FRAME=0
      ; Produce the images
      ;TJK 4/25/01 set smoothflag to false because it doesn't work well for euv yet
      smoothflag = 0
      s = plot_fluximages(a,PS(i).vname,THUMBSIZE=THUMBSIZE,FRAME=FRAME,$
                    CDAWEB=cdawebflag,GIF=GIF,REPORT=reportflag,$
                    TSTART=start_time,TSTOP=stop_time,NONOISE=NONOISE,$
                    DEBUG=debugflag, SMOOTH=smoothflag,/COLORBAR)

      if(s eq -1) then begin
         if(reportflag) then printf, 1, 'STATUS=Image plot failed' & close, 1
         print, 'STATUS=Image plot failed'
         return, -1
      endif

   endif
endfor

a_id=-1 ; Reset structure id
; Make a pass thru the plot script and generate all image plots for flux movies
for i=0,n_elements(PS)-1 do begin
   if (PS(i).ptype eq 14) then begin
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
      endif
      ; Determine name for new gif file and create GIF/window
      if keyword_set(GIF) then begin
         if(gif_counter lt 100) then gifn='0'+strtrim(string(gif_counter),2)
         if(gif_counter lt 10) then gifn='00'+strtrim(string(gif_counter),2)
         if(gif_counter ge 100) then gifn=strtrim(string(gif_counter),2)
         GIF=outdir+PS(i).source+'_'+pid+'_'+gifn+'.mpg'
         gif_counter = gif_counter + 1
      endif
      ; Produce debug output if requested
      if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' as flux movie...'

      ; Modify source name for SSCWEB DATASET label                                  
      if(SSCWEB) then begin
         satname=strtrim(a.epoch.source_name,2)
         PS(i).source= PS(i).source + '_' + satname
      endif

      if (reportflag eq 1) then printf, 1, 'DATASET=',PS(i).source
      print, 'DATASET=',PS(i).source
      ; Produce the images
      ;TJK 4/25/01 set smoothflag to false because it doesn't work well for euv yet
      smoothflag = 0
      s = flux_movie(a,PS(i).vname,$
                    CDAWEB=cdawebflag,GIF=GIF,REPORT=reportflag,$
                    TSTART=start_time,TSTOP=stop_time,NONOISE=NONOISE,$
                    DEBUG=debugflag,/COLORBAR,SMOOTH=smoothflag)


      if(s eq -1) then begin
         if(reportflag) then printf, 1, 'STATUS=Image flux movie failed' & close, 1
         print, 'STATUS=Image flux movie failed'
         return, -1
      endif

   endif
endfor


a_id=-1 ; Reset structure id
; Make a pass thru the plot script and generate all image plots for movies
for i=0,n_elements(PS)-1 do begin
   if (PS(i).ptype eq 10) then begin
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
      endif
      ; Determine name for new gif file and create GIF/window
      if keyword_set(GIF) then begin
         if(gif_counter lt 100) then gifn='0'+strtrim(string(gif_counter),2)
         if(gif_counter lt 10) then gifn='00'+strtrim(string(gif_counter),2)
         if(gif_counter ge 100) then gifn=strtrim(string(gif_counter),2)
         GIF=outdir+PS(i).source+'_'+pid+'_'+gifn+'.mpg'
         gif_counter = gif_counter + 1
      endif
      ; Produce debug output if requested
      if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' as images...'

      ; Modify source name for SSCWEB DATASET label                                  
      if(SSCWEB) then begin
         satname=strtrim(a.epoch.source_name,2)
         PS(i).source= PS(i).source + '_' + satname
      endif

      if (reportflag eq 1) then printf, 1, 'DATASET=',PS(i).source
      print, 'DATASET=',PS(i).source
      ; For CDAWEB set the FRAME=0. This will allow multiple structures w/ image
      ; data to be processed otherwise keyword_set(FRAME) is true even for structures
      ; where it shouldn't be  RTB  4/98
      if(cdawebflag) then FRAME=0
      ; Produce the images
      ;s = plot_images(a,PS(i).vname,THUMBSIZE=THUMBSIZE,FRAME=FRAME,$
      s = movie_images(a,PS(i).vname,THUMBSIZE=THUMBSIZE,FRAME=FRAME,$
                    CDAWEB=cdawebflag,GIF=GIF,REPORT=reportflag,$
                    TSTART=start_time,TSTOP=stop_time,NONOISE=NONOISE,$
                    DEBUG=debugflag,/COLORBAR)


      if(s eq -1) then begin
         if(reportflag) then printf, 1, 'STATUS=Image movie failed' & close, 1
         print, 'STATUS=Image movie failed'
         return, -1
      endif

   endif
endfor


a_id=-1 ; Reset structure id
; Make a pass thru the plot script and generate all image plots for map movies
for i=0,n_elements(PS)-1 do begin
   if (PS(i).ptype eq 11) then begin
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
      endif
      ; Determine name for new gif file and create GIF/window
      if keyword_set(GIF) then begin
         if(gif_counter lt 100) then gifn='0'+strtrim(string(gif_counter),2)
         if(gif_counter lt 10) then gifn='00'+strtrim(string(gif_counter),2)
         if(gif_counter ge 100) then gifn=strtrim(string(gif_counter),2)
         GIF=outdir+PS(i).source+'_'+pid+'_'+gifn+'.mpg'
         gif_counter = gif_counter + 1
      endif
      ; Produce debug output if requested
      if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' as images...'

      ; Modify source name for SSCWEB DATASET label
      if(SSCWEB) then begin
         satname=strtrim(a.epoch.source_name,2)
         PS(i).source= PS(i).source + '_' + satname
      endif

      if (reportflag eq 1) then printf, 1, 'DATASET=',PS(i).source
      print, 'DATASET=',PS(i).source
      ; For CDAWEB set the FRAME=0. This will allow multiple structures w/ image
      ; data to be processed otherwise keyword_set(FRAME) is true even for structures
      ; where it shouldn't be  RTB  4/98
      if(cdawebflag) then FRAME=0
      ; Produce the images
      ;s = plot_images(a,PS(i).vname,THUMBSIZE=THUMBSIZE,FRAME=FRAME,$
      s = movie_map_images(a,PS(i).vname,THUMBSIZE=THUMBSIZE,FRAME=FRAME,$
                    CDAWEB=cdawebflag,GIF=GIF,REPORT=reportflag,$
                    TSTART=start_time,TSTOP=stop_time,NONOISE=NONOISE,$
                    DEBUG=debugflag,/COLORBAR)

      if(s eq -1) then begin
         if(reportflag) then printf, 1, 'STATUS=Image movie failed' & close, 1
         print, 'STATUS=Image movie failed'
         return, -1
      endif
   endif
endfor


; Make a pass thru the plot script and generate all radar plots
a_id=-1 ; Reset structure id
for i=0,n_elements(PS)-1 do begin
   if (PS(i).ptype eq 3) then begin
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
      endif
      ; Only DARN radar data is currently plottable.  Verify that the source
      ; of this variable is DARN.
      proceed = 1L & b = tagindex('SOURCE_NAME',tag_names(a.(PS(i).vnum)))
      if (b(0) eq -1) then begin
         proceed = 0L & print,'ERROR=Unable to determine source for radar plot...'
      endif
      if (strpos(strupcase(a.(PS(i).vnum).SOURCE_NAME),'DARN') eq -1) then begin
         proceed = 0L & print,'ERROR=Source of radar plot not equal to DARN...'
      endif
      if (proceed eq 1) then begin
         if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' as Radar...'
         if keyword_set(GIF) then begin
            ;if (gif_counter gt 0) then begin
            ;c = strpos(GIF,'.gif') ; search for .gif suffix
            ; if (c ne -1) then begin
            ; c = strmid(GIF,0,c) & GIF=c+strtrim(string(gif_counter),2)+'.gif'
            ;endif else GIF=GIF+strtrim(string(gif_counter),2)
            ;endif
            if(gif_counter lt 100) then gifn='0'+strtrim(string(gif_counter),2) 
            if(gif_counter lt 10) then gifn='00'+strtrim(string(gif_counter),2) 
            if(gif_counter ge 100) then gifn=strtrim(string(gif_counter),2)
            GIF=outdir+PS(i).source+'_'+pid+'_'+gifn+'.gif'
         endif
         ; Modify source name for SSCWEB DATASET label                                  
         if(SSCWEB) then begin
            satname=strtrim(a.epoch.source_name,2)
            PS(i).source= PS(i).source + '_' + satname
         endif

         if (reportflag eq 1) then printf, 1, 'DATASET=',PS(i).source
         print, 'DATASET=',PS(i).source

         ; Produce the radar plots
         s = plot_radar(a,PS(i).vnum,XYSIZE=XYSIZE,GIF=GIF,GCOUNT=gif_counter,$
                     TSTART=start_time,TSTOP=stop_time,$
                     REPORT=reportflag,DEBUG=debugflag)
         if(s eq -1) then begin
            print, 'STATUS=Radar Plot Failed'
            if(reportflag) then printf, 1, 'STATUS=Radar Plot Error'
         endif else gif_counter=s 
      endif 
   endif
endfor


a_id=-1 ; Reset structure id
; Make a pass thru the plot script and generate all mapped plots
pwc=where(PS.ptype eq 6,pwcn)
for i=0,n_elements(PS)-1 do begin
   if (PS(i).ptype eq 6) then begin
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
         ; Determine name for new gif file and create GIF/window
         if keyword_set(GIF) then begin
            ; Write dataset name for each structure processed for overplotting s/c on
            ; 1 plot
            ; Modify source name for SSCWEB DATASET label
            if(SSCWEB) then begin
               satname=strtrim(a.epoch.source_name,2)
               PS(i).source= PS(i).source + '_' + satname
            endif
            if(reportflag) then begin
               printf, 1, 'DATASET=',PS(i).source
            endif
            print, 'DATASET=',PS(i).source

            if(i eq pwc(0)) then begin ; Remove this condition blk for single gifs
               ; This condition will allow multiple s/c to be overploted
               if(gif_counter lt 100) then gifn='0'+strtrim(string(gif_counter),2)
               if(gif_counter lt 10) then gifn='00'+strtrim(string(gif_counter),2)
               if(gif_counter ge 100) then gifn=strtrim(string(gif_counter),2)
               GIF=outdir+PS(i).source+'_'+pid+'_'+gifn+'.gif'
               gif_counter = gif_counter + 1
 
               ; Control size for projection
               ; pmode=0 ;For mulitple gif files
               xs=790 & ys=512
               yoffset=0.15 ; For mulitple gif files
               symcol=63
               ; User control of window size will likely cause map scale distortions to occur
               ;if(SSCWEB) then begin
               ;if(n_elements(xs_ssc) ne 0) then xs=xs_ssc 
               ;if(n_elements(ys_ssc) ne 0) then ys=ys_ssc  
               ;endif
               ;if((iproj eq 1) or (iproj eq 2) or (iproj eq 6)) then xs=460 & ys=520

               deviceopen,6,fileOutput=GIF,sizeWindow=[xs,ys]
               ; COMMENTED OUT THIS SECTION FOR OVERPLOTS   RTB 1/98
               ; Modify source name for SSCWEB DATASET label                                  
               ;if(SSCWEB) then begin
               ;satname=strtrim(a.epoch.source_name,2)
               ;PS(i).source= PS(i).source + '_' + satname
               ;endif
               ;
               ;if(reportflag) then begin
               ;printf, 1, 'DATASET=',PS(i).source 
               ;printf, 1, 'GIF=',GIF
               ;endif
               ;print, 'DATASET=',PS(i).source
               ;print,'GIF=',GIF
            endif  ; Remove this condition for single gifs.
            ; This condition will allow multiple s/c to be overploted
         endif else begin
            window,/FREE,XSIZE=xs,YSIZE=ys,TITLE='MAPPED PLOT'
         endelse
         ; Produce debug output if requested
         if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' ... as MAPPED.'
         rng_val=[start_time,stop_time]

         ; Produce the mapped plots
         ;For overplot on single gif file 
         if(i eq pwc(0)) then pmode=0 else if(pmode eq -1) then pmode=7 ;
         if((n_elements(polon) ne 0) and (n_elements(polat) ne 0) and $
         (n_elements(rot) ne 0)) then begin
            vlat=fltarr(3)
            vlat(0)=polat
            vlat(1)=polon
            vlat(2)=rot
         endif
         s = plot_maps(a,station=station,vlat=vlat,iproj=iproj,lim=lim,$
              latdel=latdel,londel=londel,Ttitle=thetitle,$
              pmode=pmode,rng_val=rng_val,num_int=num_int,$
              lthik=lthik,symsiz=symsiz,symcol=symcol,$
              charsize=chtsize,xmargin=xmargin,ymargin=ymargin,$
              xoffset=xoffset,yoffset=yoffset,lnlabel=lnlabel,nocont=nocont,$
              SSCWEB=SSCWEB,doymark=doymark,hrmark=hrmark,hrtick=hrtick,$
  	      mntick=mntick,mnmark=mnmark,lnthick=lnthick,$
              autolabel=autolabel,datelabel=datelabel,_extra=extras)

         if(s eq -1) then begin
            if(reportflag) then printf, 1, 'STATUS=Mapped plot failed' & close, 1
            print, 'STATUS=Mapped plot failed'
            return, -1
         endif
      endif
   endif
   ; The following condition should be removed for separate single gif files  
   ; This will allow multiple s/c to be overploted
   if(pwcn gt 0) then begin
      if(i eq pwc(pwcn-1)) then begin
         if(reportflag) then begin
            printf, 1, 'GIF=',GIF
         endif
         print, 'GIF=',GIF
         deviceclose ; close any open gif
      endif
   endif
endfor

; Make a pass thru the plot script, select all structures for orbit plots,
; submit all structures to orb_mgr to plot satellites by coordinate system
; chosen.
iorb=0
orbit_trip=0
a_id=-1 ; Reset structure id
for i=0,n_elements(PS)-1 do begin
   if (PS(i).ptype eq 5) then begin
      orbit_trip=1
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         aa_lab='aa'+strtrim(string(iorb),2)
         s=execute(aa_lab+'=a'+strtrim(string(PS(i).snum),2))
         if(iorb eq 0) then begin
            mega_aa=create_struct(aa_lab,aa0)
         endif else begin
            if(iorb eq 1) then temp_mg=create_struct(aa_lab,aa1)
            if(iorb eq 2) then temp_mg=create_struct(aa_lab,aa2)
            if(iorb eq 3) then temp_mg=create_struct(aa_lab,aa3)
            if(iorb eq 4) then temp_mg=create_struct(aa_lab,aa4)
            if(iorb eq 5) then temp_mg=create_struct(aa_lab,aa5)
            if(iorb eq 6) then temp_mg=create_struct(aa_lab,aa6)
            if(iorb eq 7) then temp_mg=create_struct(aa_lab,aa7)
            if(iorb eq 8) then temp_mg=create_struct(aa_lab,aa8)
            if(iorb eq 9) then temp_mg=create_struct(aa_lab,aa9)
            mega_aa=create_struct(mega_aa,temp_mg)
         endelse
         a_id = PS(i).snum
         iorb=iorb+1
         ; Modify source name for SSCWEB DATASET label                                  
         if(SSCWEB) then begin
            if(n_elements(xs_ssc) ne 0) then xsize=xs_ssc 
            if(n_elements(ys_ssc) ne 0) then ysize=ys_ssc ; Orbits xsize=ysize
            ;   satname=strtrim(temp_mg.epoch.source_name,2)
            x1=execute('satname='+aa_lab+'.epoch.source_name')
            PS(i).source= PS(i).source + '_' + satname
         endif

         if (reportflag eq 1) then printf, 1, 'DATASET=',PS(i).source
         print, 'DATASET=',PS(i).source

      endif
   endif
endfor
if(orbit_trip eq 1) then begin
   out_name=strarr(10)
   if(n_elements(start_time) ne 0) then tstart=start_time
   if(n_elements(stop_time) ne 0) then tstop=stop_time
   if keyword_set(GIF) then begin
      ;if (gif_counter gt 0) then begin
      ; c = strpos(GIF,'.gif') ; search for .gif suffix
      ;if (c ne -1) then begin  
      ;c = strmid(GIF,0,c) & GIF=c+strtrim(string(gif_counter),2)+'.gif'
      ;endif else GIF=GIF+strtrim(string(gif_counter),2)
      ; endif
      ; For orbit 1 image can have multiple sources
      ; GIF=outdir+PS(i).source+'_'+pid+'_'+string(gif_counter)+'.gif'
      if(gif_counter lt 100) then gifn='0'+strtrim(string(gif_counter),2)
      if(gif_counter lt 10) then gifn='00'+strtrim(string(gif_counter),2)
      if(gif_counter ge 100) then gifn=strtrim(string(gif_counter),2)
      GIF=outdir+'ORBIT_'+pid+'_'+gifn+'.gif'
   endif

   out_strc=orb_mgr(mega_aa,$
                tstart=tstart,tstop=tstop,xsize=xsize,ysize=ysize, $
                orb_vw=orb_vw,press=press,bz=bz,xmar=xmar,$
                ymar=ymar,doymark=doymark,hrmark=hrmark,hrtick=hrtick, $
 		mntick=mntick,mnmark=mnmark,xumn=xumn,xumx=xumx,yumn=yumn,$
                yumx=yumx,zumn=zumn,zumx=zumx,rumn=rumn,rumx=rumx,labpos=labpos,$
                chtsize=chtsize,GIF=GIF,SSC=SSCWEB,REPORT=reportflag,$
                DEBUG=debugflag,GCOUNT=gif_counter,us=us,bsmp=bsmp, $
                symsiz=symsiz,lnthick=lnthick,autolabel=autolabel,datelabel=datelabel,$
                eqlscl=eqlscl,panel=panel)

   s=out_strc
   if(s eq -1) then begin
      if(reportflag) then begin
         printf, 1, 'STATUS=Orbit Plot Failed' 
         close, 1
      endif
      print, 'STATUS=Orbit Plot Failed'
      return, -1
   endif
endif

; Display of map images will be accomplished through calls to plotmaster
; where the DISPLAY_TYPE for map image variables will be set to "MAP_IMAGE"  
; These variables will be passed to a new function called plot_map_images.pro
; which will process and display each image in a fashion similar to plot_images
; (ie. an image of thumbnails will initially be produced w/ an option to 
; select & displays individual thumbnails).  The auroral_image.pro function will
; be incorporated into plot_map_images.  Uviptg.pro used to generate lats and 
; lons for polar uvi display will be incorporated into the virtual variables
; scheme.

; AT THIS POINT SETTING UP CASE SPECIFIC CODE. WIll NEED TO GO BACK
; AND INCORPORATE SOME OF THIS INTO VIRTUAL VARIABLES
; 
a_id=-1 ; Reset structure id
; Make a pass thru the plot script and generate all auroral image map plots
for i=0,n_elements(PS)-1 do begin
   if (PS(i).ptype eq 8) then begin
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
      endif
      ; Determine name for new gif file and create GIF/window
      if keyword_set(GIF) then begin
         if(gif_counter lt 100) then gifn='0'+strtrim(string(gif_counter),2)
         if(gif_counter lt 10) then gifn='00'+strtrim(string(gif_counter),2)
         if(gif_counter ge 100) then gifn=strtrim(string(gif_counter),2)
         GIF=outdir+PS(i).source+'_'+pid+'_'+gifn+'.gif'
         gif_counter = gif_counter + 1
      endif
      ; Produce debug output if requested
      if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' as map images...'

      ; Modify source name for SSCWEB DATASET label                                  
      if(SSCWEB) then begin
         satname=strtrim(a.epoch.source_name,2)
         PS(i).source= PS(i).source + '_' + satname
      endif

      if (reportflag eq 1) then printf, 1, 'DATASET=',PS(i).source
      print, 'DATASET=',PS(i).source

      ; For CDAWEB set the FRAME=0. This will allow multiple structures w/ image
      ; data to be processed otherwise keyword_set(FRAME) is true even for structures
      ; where it shouldn't be  RTB  4/98
      if(cdawebflag) then FRAME=0
      ; Produce the images
      s = plot_map_images(a,PS(i).vname,CENTERLATLON=CENTERLATLON,$
                 THUMBSIZE=THUMBSIZE,FRAME=FRAME,$
                 CDAWEB=cdawebflag,GIF=GIF,REPORT=reportflag,$
                 TSTART=start_time,TSTOP=stop_time,NONOISE=NONOISE,$
                 DEBUG=debugflag,/COLORBAR)

      if(s eq -1) then begin
         if(reportflag) then printf, 1, 'STATUS=Map Image plot failed' & close, 1
         print, 'STATUS=Map Image plot failed'
         return, -1
      endif
   endif
endfor ;for all mapped image plots

;Generate all Plasmagram plots
a_id=-1
for i=0,n_elements(PS)-1 do begin  
   if (PS(i).ptype eq 9) then begin ;look for all plasmagrams
      ; Ensure that 'a' holds the correct data structure
      if (PS(i).snum ne a_id) then begin
         s=execute('a=a'+strtrim(string(PS(i).snum),2)) & a_id = PS(i).snum
      endif

      ; Produce debug output if requested.
      if keyword_set(DEBUG) then print,'Plotting ',PS(i).vname,' as plasmagram.'

      ; Generate the plasmagram
      ; Determine name for new gif file and create GIF/X-window
      if keyword_set(GIF) then begin
         if(gif_counter lt 100) then gifn='0'+strtrim(string(gif_counter),2)
         if(gif_counter lt 10) then gifn='00'+strtrim(string(gif_counter),2)
         if(gif_counter ge 100) then gifn=strtrim(string(gif_counter),2)
         GIF=outdir+PS(i).source+'_'+pid+'_'+gifn+'.gif'
         gif_counter = gif_counter + 1
      endif else deviceopen,0 ; producing XWINDOWS

      if (reportflag eq 1) then printf, 1, 'DATASET=',PS(i).source
      print, 'DATASET=',PS(i).source

      s = plot_plasmagram(a,PS(i).vname,$
                   GIF=GIF, /CDAWEB, TSTART=start_time,TSTOP=stop_time, $
		   /colorbar, DEBUG=debugflag, thumbsize=thumbsize,$
		   FRAME=FRAME, REPORT=reportflag, NONOISE=NONOISE)

      if(s eq -1) then begin
         if(reportflag) then printf, 1, 'STATUS=Plasmagram plot failed' & close, 1
         print, 'STATUS=Plasmagram plot failed'
         return, -1
      endif
      ; Update the state of the window
      WS.pos(3) = WS.pos(3) - (pheight * PS(i).npanels) ; update Y corner
      WS.pos(1) = WS.pos(1) - (pheight * PS(i).npanels) ; update Y origin
   endif
endfor

a_id=-1 ; Reset structure id


; If generating a log/report file then close it.
if (reportflag eq 1) then close,1

; Set plot back to native method
case !VERSION.OS of
   'MacOS'   : set_plot,'MAC' ; return to interactive on Mac
   'windows' : set_plot,'WIN' ; return to interactive on Windows
   else      : set_plot,'X'   ; return to interactive on Unix/X
endcase

return,0
end
