;$author: $ 
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/cdaweb/dev/control/RCS/plot_fluximages.pro,v 1.24 2006/05/08 14:52:29 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 8 $
;+------------------------------------------------------------------------
; NAME: PLOT_FLUXIMAGES
; PURPOSE: To plot the image data given in the input parameter astruct.
;          Can plot as "thumbnails" or single frames.
;
; CALLING SEQUENCE:
;       out = plot_fluximages(astruct,vname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;       vname   = name of the variable in the structure to plot
;
; KEYWORD PARAMETERS:
;       THUMBSIZE = size (pixels) of thumbnails, default = 140 (i.e. 140x140) - due to restrictions
;			in the underlying code.
;       FRAME     = individual frame to plot
;       XSIZE     = x size of single frame
;       YSIZE     = y size of single frame
;       GIF       = name of gif file to send output to
;       REPORT    = name of report file to send output to
;       TSTART    = time of frame to begin imaging, default = first frame
;       TSTOP     = time of frame to stop imaging, default = last frame
;       NONOISE   = eliminate points outside 3sigma from the mean
;       CDAWEB    = being run in cdaweb context, extra report is generated
;       DEBUG    = if set, turns on additional debug output.
;       COLORBAR = calls function to include colorbar w/ image
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;	Tami Kovalick, Raytheon ITSS, July 25, 2000 - this program is based on the plot_images
;	program originally written by R. Burley.  It is being modified for use w/ Rick's new
;	plot_enaflux5 plotting code.
;
; MODIFICATION HISTORY:
;
;-------------------------------------------------------------------------
FUNCTION plot_fluximages, astruct, vname, $
                      THUMBSIZE=THUMBSIZE, FRAME=FRAME, $
                      XSIZE=XSIZE, YSIZE=YSIZE, GIF=GIF, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                      CDAWEB=CDAWEB,DEBUG=DEBUG,COLORBAR=COLORBAR, $
		      SMOOTH=SMOOTH

; Determine the field number associated with the variable 'vname'
w = where(tag_names(astruct) eq strupcase(vname),wc)
if (wc eq 0) then begin
  print,'ERROR=No variable with the name:',vname,' in param 1!' & return,-1
endif else vnum = w(0)

Zvar = astruct.(vnum)
if keyword_set(COLORBAR) then COLORBAR=1L else COLORBAR=0L
if COLORBAR  then xco=100 ;changed from 80 else xco=0 ; No colorbar

;TJK for now we're not going to use the "SMOOTH" keyword, so turn it off
if keyword_set(SMOOTH) then SMOOTH=1L else SMOOTH=0L

; Find & Parse DISPLAY_TYPE for keyword inclusion. 
  a = tagindex('DISPLAY_TYPE',tag_names(astruct.(vnum)))
  if(a(0) ne -1) then display= astruct.(vnum).DISPLAY_TYPE $
  else begin
    print, 'ERROR= No DISPLAY_TYPE attribute for variable'
  endelse
; Parse DISPLAY_TYPE
  ipts=parse_display_type(display)
  keywords=str_sep(display,'>')  ; keyword 1 or greater

; The DISPLAY_TYPE attribute may contain the THUMBSIZE  RTB
; The THUMBSIZE must be followed by the size in pixels of the images
  wc=where(keywords eq 'THUMBSIZE',wcn)
  if(wcn ne 0) then THUMBSIZE = fix(keywords(wc(0)+1))

; Open report file if keyword is set
;if keyword_set(REPORT) then begin & reportflag=1L
; a=size(REPORT) & if (a(n_elements(a)-2) eq 7) then $
; OPENW,1,REPORT,132,WIDTH=132
;endif else reportflag=0L
 if keyword_set(REPORT) then reportflag=1L else reportflag=0L

; Verify the type of the first parameter and retrieve the data
a = size(astruct.(vnum))
if (a(n_elements(a)-2) ne 8) then begin
  print,'ERROR= 1st parameter to plot_images not a structure' & return,-1
endif else begin
  a = tagindex('DAT',tag_names(astruct.(vnum)))
  if (a(0) ne -1) then idat = astruct.(vnum).DAT $
  else begin
    a = tagindex('HANDLE',tag_names(astruct.(vnum)))
    if (a(0) ne -1) then handle_value,astruct.(vnum).HANDLE,idat $
    else begin
      print,'ERROR= 1st parameter does not have DAT or HANDLE tag' & return,-1
    endelse
  endelse
endelse

; Determine which variable in the structure is the 'Epoch' data and retrieve it
b = astruct.(vnum).DEPEND_0 & c = tagindex(b(0),tag_names(astruct))
d = tagindex('DAT',tag_names(astruct.(c)))
if (d(0) ne -1) then edat = astruct.(c).DAT $
else begin
  d = tagindex('HANDLE',tag_names(astruct.(c)))
  if (d(0) ne -1) then handle_value,astruct.(c).HANDLE,edat $
  else begin
    print,'ERROR= Time parameter does not have DAT or HANDLE tag' & return,-1
  endelse
endelse

; Determine which variable in the structure is the GCI_POS data and retrieve it
var_names = tag_names(astruct)
found = where('GCI_POS' eq var_names, fnd_cnt)
if (fnd_cnt ge 1) then begin
 var_index = found(0)
 d = tagindex('DAT',tag_names(astruct.(var_index)))
 if (d(0) ne -1) then pos_dat = astruct.(var_index).DAT $
 else begin
  d = tagindex('HANDLE',tag_names(astruct.(var_index)))
  if (d(0) ne -1) then handle_value,astruct.(var_index).HANDLE,pos_dat $
  else begin
    print,'ERROR= GCI_POS parameter does not have DAT or HANDLE tag' & return,-1
  endelse
 endelse
endif

; Determine which variable in the structure is the GCI_SPINAXIS data and retrieve it
var_names = tag_names(astruct)
found = where('GCI_SPINAXIS' eq var_names, fnd_cnt)
if (fnd_cnt ge 1) then begin
  var_index = found(0)
  d = tagindex('DAT',tag_names(astruct.(var_index)))
  if (d(0) ne -1) then spin_dat = astruct.(var_index).DAT $
  else begin
    d = tagindex('HANDLE',tag_names(astruct.(var_index)))
    if (d(0) ne -1) then handle_value,astruct.(var_index).HANDLE,spin_dat $
    else begin
      print,'ERROR= GCI_SPINAXIS parameter does not have DAT or HANDLE tag' & return,-1
    endelse
  endelse
endif

; Determine the title for the window or gif file

a = tagindex('SOURCE_NAME',tag_names(astruct.(vnum)))
if (a(0) ne -1) then begin
  sn = break_mystring(astruct.(vnum).SOURCE_NAME,delimiter='>')
  b = sn(0)
endif else b = ''
a = tagindex('DESCRIPTOR',tag_names(astruct.(vnum)))
if (a(0) ne -1) then b = b + '  ' + astruct.(vnum).DESCRIPTOR

a = tagindex('DATA_TYPE',tag_names(astruct.(vnum)))
if (a(0) ne -1) then b = b + '  ' + astruct.(vnum).DATA_TYPE

;TJK added FIELDNAM as part of the title since we now have multiple image
;variables per datatype.
a = tagindex('FIELDNAM',tag_names(astruct.(vnum)))
if (a(0) ne -1) then b = b + ' ' + astruct.(vnum).FIELDNAM


window_title = b

; Determine title for colorbar
if(COLORBAR) then begin
 a=tagindex('UNITS',tag_names(astruct.(vnum)))
 if(a(0) ne -1) then ctitle = astruct.(vnum).UNITS else ctitle=''
endif

if keyword_set(XSIZE) then xs=XSIZE else xs=512
if keyword_set(YSIZE) then ys=YSIZE else ys=512

; Perform special case checking...
vkluge=0 ; initialize
tip = tagindex('PLATFORM',tag_names(astruct.(vnum)))
if (tip ne -1) then begin
  if (astruct.(vnum).platform eq 'Viking') then vkluge=1
endif
; Check Descriptor Field for Instrument Specific Settings
tip = tagindex('DESCRIPTOR',tag_names(astruct.(vnum)))
if (tip ne -1) then begin
  descriptor=str_sep(astruct.(vnum).descriptor,'>')
endif


; Determine if data is a single image, if so then set the frame
; keyword because a single thumbnail makes no sense

; Making LARGE single IMAGES here...

isize = size(idat)
if (isize(0) eq 2) then n_images=1 else n_images=isize(isize(0))

if (n_images eq 1) then FRAME=1

if keyword_set(FRAME) then begin ; produce plot of a single frame
  if ((FRAME ge 1)AND(FRAME le n_images)) then begin ; valid frame value
    idat = idat(*,*,(FRAME-1)) ; grab the frame
    idat = reform(idat) ; remove extraneous dimensions
    if (vkluge)then idat = rotate(idat,7) ; TJK - this rotation desired for viking only.

    isize = size(idat) ; get the dimensions of the image
    r1 = 450./isize(1) ; determine ratio for first dimension
    r2 = 450./isize(2) ; determine ratio for second dimension
    xs = ceil(isize(1)*r1)+50 ; determine xsize of window
    ys = ceil(isize(2)*r2)+15 ; determine ysize of window
    ;idat = rebin(idat,(isize(1)*r1),(isize(2)*r2)) ; resize the image

; Begin changes 12/11 RTB
    ; determine validmin and validmax values
    a = tagindex('VALIDMIN',tag_names(astruct.(vnum)))
    if (a(0) ne -1) then begin & b=size(astruct.(vnum).VALIDMIN)
      if (b(0) eq 0) then zvmin = astruct.(vnum).VALIDMIN $
      else begin
        zvmin = 0 ; default for image data
        print,'WARNING=Unable to determine validmin for ',vname
      endelse
    endif
    a = tagindex('VALIDMAX',tag_names(astruct.(vnum)))
    if (a(0) ne -1) then begin & b=size(astruct.(vnum).VALIDMAX)
      if (b(0) eq 0) then zvmax = astruct.(vnum).VALIDMAX $
      else begin
        zvmax = 2000 ; guesstimate
        print,'WARNING=Unable to determine validmax for ',vname
      endelse
    endif
    a = tagindex('FILLVAL',tag_names(astruct.(vnum)))
    if (a(0) ne -1) then begin & b=size(astruct.(vnum).FILLVAL)
      if (b(0) eq 0) then zfill = astruct.(vnum).FILLVAL $
      else begin
        zfill = 2000 ; guesstimate
        print,'WARNING=Unable to determine Image fill value for ',vname
      endelse
    endif

; bc   zvmin=min(idat) & zvmax=max(idat)

if keyword_set(DEBUG) then begin
  print, 'Image valid min and max: ',zvmin, ' ',zvmax 
  wmin = min(idat,MAX=wmax)
  print, 'Actual min and max of data',wmin,' ', wmax
endif

;TJK - 3/19/98 - added checking for fill value.  If found, set
;the fill values to 0, otherwise, if the fill values are greater
;than zvmax, then the values will be included in the image.
;    w = where((idat lt zvmin),wc)

    w = where((idat lt zvmin or idat eq zfill),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Number of values below the valid min = ',wc
      print,'WARNING=setting ',wc,' fill values in image data to zvmin...'
;TJK change this to zvmin instead of 0      idat(w) = 0 ; set pixels to black
      idat(w) = zvmin ; set pixels to zvmin
      w = 0 ; free the data space
    endif

;TJK added for IMAGE data - checking for when all data is below 1. 
;Since the plot_enaflux s/w tries to generate a log scaled plot, all 
;data needs to be at 1 or above in order to produce a plot (even a 
;blank/black one).
    wmin = min(idat,MAX=wmax)

    if (wmax lt 1.0 ) then begin
	w = where(idat le wmax, wc)
	if wc gt 0 then begin
	  idat(w) = 1.0
	  if keyword_set(DEBUG) then print, 'valid max lt 1, setting data le to vmax to 1.0'
	endif
    endif

;TJK try not taking out the higher values and just scale them in.

    w = where((idat gt zvmax),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Number of values above the valid max = ',wc
      if keyword_set(DEBUG) then print,'WARNING=setting ',wc,' fill values in image data to red...'
;      print, 'values are: ',idat(w)
;6/25/2004 see below         idat(w) = zvmax -1; set pixels to red
       ;TJK 6/25/2004 - added red_offset function to determine offset
       ;(to red) because of cases like log scaled timed guvi data
       ;where the diff is less than 1.
       diff = zvmax - zvmin
       coffset = red_offset(GIF=GIF,diff)
       print, 'diff = ',diff, ' coffset = ',coffset
       idat(w) = zvmax - coffset; set pixels to red
      w = 0 ; free the data space
    endif

;TJK added this section to print out some statistics about the data distribution. 
    if keyword_set(DEBUG) then begin
      print, 'Statistics about the data distribution'
      w = where(((idat lt zvmax) and (idat ge (zvmax-10))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax,' and ',zvmax-10,' = ',wc
      w = where(((idat lt zvmax-10) and (idat ge (zvmax-20))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-10,' and ',zvmax-20,' = ',wc
      w = where(((idat lt zvmax-20) and (idat ge (zvmax-30))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-20,' and ',zvmax-30,' = ',wc
      w = where(((idat lt zvmax-30) and (idat ge (zvmax-40))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-30,' and ',zvmax-40,' = ',wc
      w = where(((idat lt zvmax-40) and (idat ge (zvmax-50))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-40,' and ',zvmax-50,' = ',wc
      w = where(((idat lt zvmax-50) and (idat ge (zvmax-60))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-50,' and ',zvmax-60,' = ',wc

    endif


    ; filter out data values outside 3-sigma for better color spread
    if keyword_set(NONOISE) then begin
      semiMinMax,idat,zvmin,zvmax,/MODIFIED
      w = where((idat lt zvmin),wc)
      if wc gt 0 then begin
        print,'WARNING=filtering values less than 3-sigma from image data...'
        idat(w) = zvmin ; set pixels to black
        w = 0 ; free the data space
      endif
      w = where((idat gt zvmax),wc)
      if wc gt 0 then begin
        print,'WARNING=filtering values greater than 3-sigma from image data...'
;TJK 6/25/2004 - replace w/ code below        idat(w) = zvmax -2; set pixels to red
         ;TJK 6/25/2004 - added red_offset function to determine offset
         ;(to red) because of cases like log scaled timed guvi data
         ;where the diff is less than 1.
         diff = zvmax - zvmin
         coffset = red_offset(GIF=GIF,diff)
         print, 'diff = ',diff, ' coffset = ',coffset
         idat(w) = zvmax - coffset; set pixels to red
        w = 0 ; free the data space
      endif
     endif


    ; scale to maximize color spread
    idmax=max(idat) 
    idmin=min(idat) ; RTB 10/96


    if keyword_set(GIF) then begin
      ; RTB 9/96 Retrieve the Data set name from the Logical source or
      ;          the Logical file id
      atags=tag_names(astruct.(vnum))
      b = tagindex('LOGICAL_SOURCE',atags)
      b1 = tagindex('LOGICAL_FILE_ID',atags)
      b2 = tagindex('Logical_file_id',atags)
      if (b(0) ne -1) then psrce = strupcase(astruct.(vnum).LOGICAL_SOURCE)
      if (b1(0) ne -1) then $
        psrce = strupcase(strmid(astruct.(vnum).LOGICAL_FILE_ID,0,9))
      if (b2(0) ne -1) then $
        psrce = strupcase(strmid(astruct.(vnum).Logical_file_id,0,9))

    ;print, 'DATASET=',psrce

      GIF=strmid(GIF,0,(strpos(GIF,'.gif')))+'_f000.gif'

      if(FRAME lt 100) then gifn='0'+strtrim(string(FRAME),2) 
      if(FRAME lt 10) then gifn='00'+strtrim(string(FRAME),2) 
      if(FRAME ge 100) then gifn=strtrim(string(FRAME),2)

      GIF=strmid(GIF,0,(strpos(GIF,'.gif')-3))+gifn+'.gif'
    endif

xmargin=!x.margin

if COLORBAR then begin 
 if (!x.omargin(1)+!x.margin(1)) lt 14 then !x.margin(1) = 14
 !x.margin(1) = 14
endif

    temp_gif = gif + strtrim(string(frame-1),2)

;add case statement to set different spin and polar angles depending on
;which dataset we have - also smooth the HENA data here. TJK 1/29/01
;And make the lena and mena image arrays square. 
;7/20/2001 - take out the mena adjustment since the images now come square.

;TJK - 4/24/01 - take the smoothing out of here since Rick has now added
;a keyword to plot_enaflux for smoothing...  CDAWeb sets the smooth keyword
;so we'll just pass it through.

;TJK - 7/13/01 - change smoothing again - use the smoothing for HENA only
;and use what Rick coded in plot_enaflux... at least for this go around.
;
    case descriptor(0) of
	'EUV' : begin
		  spin = 84.0
		  polar = 0.6
		  nocircles = 1
		  nodipole = 1
		  nocolorbar = 1
		  noborder = 1
		  reverseorder = 1 ;put back in TJK 9/6/2002 (5/8/2006 - this is still in question)
		  smooth = 0L
    		end
        'HENA': begin 
		  spin = 120.0
		  polar = 6.0
;Leave smoothing in here for hena since smoothing for euv doesn't produce
;nice looking plots.
;		  print, 'smoothing hena image data'
;		  itmp = idat
;	          idat = smooth(itmp,5)
		  nocolorbar = 1
		  noborder = 1
		  nocircles = 0
		  nodipole = 0
		  reverseorder = 0
		  smooth = 1L
		end
        'MENA': begin 
		  spin = 128.0
		  polar = 4.0
		  nocolorbar = 1
		  noborder = 1
		  nocircles = 0
		  nodipole = 0
		  reverseorder = 2
		  smooth = 0L
		end
        'LENA': begin 
		  ;lena data has to be made into a square image array
		  ;this is how Rick Burley creates his images so,... TJK
		  itmp = idat
		  idat = fltarr(12,12)
		  idat = itmp(18:29,*)
		  spin = 96.0
		  polar = 8.0
		  nocolorbar = 1
		  noborder = 1
		  nocircles = 0
		  nodipole = 0
		  reverseorder = 0
		  smooth = 0L
		end
	else : begin
		print, 'setting spin and polar angles to default'
		spin = 84.0
		polar = 0.6
		smooth = 0L
	       end
	endcase

;TJK - changed how the window size is determined - 02/01/2001

    twin=make_array(2, /integer, value=512)
    win=make_array(2, /integer, value=512)

    ;determine the window size of just the image portion - it has to be square...

    twin(0) = xs - (!x.margin(0)+!x.margin(1)) & twin(1) = ys - (!y.margin(0) + !y.margin(1))
    tmax = max(twin)
    np = size(idat)
    win(0)=fix(tmax/np(1))*np(1)    ; make sure win is multiple of the image
    win(1) = win(0)
print, 'asking for image size of ',win

    stat = plot_enaflux(edat(FRAME-1),idat, spin, polar, pos_dat(*,FRAME-1), $
	   spin_dat(*,FRAME-1), 1, wsize=win, DEBUG=DEBUG,$
  	   noborder=noborder, nocircles=nocircles, nodipole=nodipole, $
	   nocolorbar=nocolorbar, smooth=smooth, gif=temp_gif, reverseorder=reverseorder)	
;TJK added smooth keyword because Rick added it in plot_enaflux 4/24/01
;original euv settings	/noborder, /nocircles, /nodipole, /nocolorbar, gif=temp_gif)	

    if (stat ge 0) then begin

      read_gif,temp_gif,a,r,g,b ;read the gif file

; set the device to be the zbuffer

;open the final gif file
       if (gif) then begin
          deviceopen,6,fileOutput=GIF,sizeWindow=[win(0)+xco,win(1)+35]
          if (reportflag eq 1) then begin
            printf,1,'I_GIF=',GIF & close,1
          endif
          print,'I_GIF=',GIF 
       endif else begin ; open the xwindow
          window,/FREE,XSIZE=xs+xco,YSIZE=ys+30,TITLE=window_title
       endelse

;now write out the image.
;	tvlct,r,g,b  ; load colors from the gif file
;TJK changed this to center images more in window tv, a, 35, 35, /DEVICE
          tv, a, 10, 25 ,/device

    if COLORBAR then begin
     plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
      if (n_elements(cCharSize) eq 0) then cCharSize = 0.
      cscale = [idmin, idmax] ; RTB 12/11
; cscale = [zvmin, zvmax]
      xwindow = !x.window
      offset = 0.01
      colorbar, cscale, ctitle, logZ=logZ, cCharSize=cCharSize, $
          position=[!x.window(1)+offset,      !y.window(0),$
                    !x.window(1)+offset+0.03, !y.window(1)],$
          fcolor=244, /image
      !x.window = xwindow
    endif ; colorbar

      acolor = !d.n_colors ; pick color for contouring


    ; subtitle the plot
    ; project_subtitle,astruct.(0),'',/IMAGE,TIMETAG=edat(FRAME-1)
      project_subtitle,astruct.(0),window_title,/IMAGE,TIMETAG=edat(FRAME-1)

  endif else begin ;if plot_enaflux returned a good image, else...
    print, 'plot_enaflux failed'
  endelse

    if keyword_set(GIF) then begin
	  deviceclose
	  ;TJK added - delete temporary gif file
	  cmd = strarr(2)
	  cmd(0) = "rm"
	  cmd(1) = temp_gif
	  spawn, cmd, /noshell
    endif

  endif ; valid frame value
;
; THUMBNAILS
;
endif else begin ; produce thumnails of all images

; Need a special check for the size of the thumbnail, the underlying plotting
; software (plot_enaflux) will not currently make an image smaller than 140x140.
; So set this appropriately.

  tsize = 140
  if (keyword_set(THUMBSIZE)) then begin 
	tsize = THUMBSIZE
	if tsize lt 140 then tsize = 140 else tsize = THUMBSIZE
  endif

  isize = size(idat) ; determine the number of images in the data
  if (isize(0) eq 2) then begin
    nimages = 1 & npixels = double(isize(1)*isize(2))
  endif else begin
    nimages = isize(isize(0)) & npixels = double(isize(1)*isize(2)*nimages)
  endelse

  ; screen out frames which are outside time range, if any
  if NOT keyword_set(TSTART) then start_frame = 0 $
  else begin
    w = where(edat ge TSTART,wc)
    if wc eq 0 then begin
      print,'ERROR=No image frames after requested start time.' & return,-1
    endif else start_frame = w(0)
  endelse
  if NOT keyword_set(TSTOP) then stop_frame = nimages $
  else begin
    w = where(edat le TSTOP,wc)
    if wc eq 0 then begin
      print,'ERROR=No image frames before requested stop time.' & return,-1
    endif else stop_frame = w(wc-1)
  endelse
  if (start_frame gt stop_frame) then no_data_avail = 1L $
  else begin
    no_data_avail = 0L
    if ((start_frame ne 0)OR(stop_frame ne nimages)) then begin
      idat = idat(*,*,start_frame:stop_frame)
      isize = size(idat) ; determine the number of images in the data
      if (isize(0) eq 2) then nimages = 1 else nimages = isize(isize(0))
      edat = edat(start_frame:stop_frame)
    endif
  endelse


  ; calculate number of columns and rows of images
  ncols = xs / tsize & nrows = (nimages / ncols) + 1
  label_space = 12 ; TJK added constant for label spacing
  if(tsize > 60) then label_space = 24 ; 
  boxsize = tsize+label_space;TJK added for allowing time labels for each image.
  ys = (nrows*boxsize) + 15

  ; Perform data filtering and color enhancement if any data exists
  if (no_data_avail eq 0) then begin
; Begin changes 12/11 RTB
;   ; determine validmin and validmax values
    a = tagindex('VALIDMIN',tag_names(astruct.(vnum)))
    if (a(0) ne -1) then begin & b=size(astruct.(vnum).VALIDMIN)
      if (b(0) eq 0) then zvmin = astruct.(vnum).VALIDMIN $
      else begin
        zvmin = 0 ; default for image data
        print,'WARNING=Unable to determine validmin for ',vname
      endelse
    endif
    a = tagindex('VALIDMAX',tag_names(astruct.(vnum)))
    if (a(0) ne -1) then begin & b=size(astruct.(vnum).VALIDMAX)
      if (b(0) eq 0) then zvmax = astruct.(vnum).VALIDMAX $
      else begin
        zvmax = 2000 ; guesstimate
        print,'WARNING=Unable to determine validmax for ',vname
      endelse
    endif
    a = tagindex('FILLVAL',tag_names(astruct.(vnum)))
    if (a(0) ne -1) then begin & b=size(astruct.(vnum).FILLVAL)
      if (b(0) eq 0) then zfill = astruct.(vnum).FILLVAL $
      else begin
        zfill = 2000 ; guesstimate
        print,'WARNING=Unable to determine Image fill value for ',vname
      endelse
    endif
;   ; filter out data values outside validmin/validmax limits

;this is the original code
;    w = where(((idat lt zvmin)OR(idat gt zvmax)),wc)
;    if wc gt 0 then begin
;      print,'WARNING=filtering ',wc,' bad values from image data...'
;      idat(w) = 0 ; set pixels to black
;      w = 0 ; free the data space
;      if wc eq npixels then print,'WARNING=All data outside min/max!!'
;    endif

if keyword_set(DEBUG) then begin
  print, 'Image valid min and max: ',zvmin, ' ',zvmax 
  wmin = min(idat,MAX=wmax)
  print, 'Actual min and max of data',wmin,' ', wmax
endif

;TJK - 3/19/98 - added checking for fill value.  If found, set
;the fill values to 0, otherwise, if the fill values is greater
;than zvmax, then the values will be included in the image.
;    w = where((idat lt zvmin),wc)

    w = where((idat lt zvmin or idat eq zfill),wc)
    if wc gt 0 then begin
      print,'WARNING=setting ',wc,' fill values in image data to black...'
;      idat(w) = 0 ; set pixels to black - TJK changed this on 12/21/2000 for IMAGE data
      idat(w) = zvmin ; set pixels to validmin
      w = 0 ; free the data space
      if wc eq npixels then print,'WARNING=All data outside min/max!!'
    endif

;TJK added for IMAGE data - checking for when all data is below 1. 
;Since the plot_enaflux s/w tries to generate a log scaled plot, all 
;data needs to be at 1 or above in order to produce a plot (even a 
;blank/black one).

    for t = 0, nimages-1 do begin
      image = idat(*,*,t)
      image_max = max(image)
      if (image_max lt 1.0 ) then begin
	w = where(image le image_max, wc)
	if wc gt 0 then begin
	  image(w) = 1.0
	  if keyword_set(DEBUG) then print, 'image max lt 1, setting data le to the image max to 1.0 for IMAGE # ',t
	endif
      endif
      idat(*,*,t) = image
    endfor


;TJK try not taking out the higher values and just scale them in.

    w = where((idat gt zvmax),wc)
    if wc gt 0 then begin
     if keyword_set(DEBUG) then print,'WARNING=setting ',wc,' fill values in image data to red...'
;      print, 'values are: ',idat(w)
;6/25/2004 see below         idat(w) = zvmax -1; set pixels to red
      ;TJK 6/25/2004 - added red_offset function to determine offset
      ;(to red) because of cases like log scaled timed guvi data
      ;where the diff is less than 1.
      diff = zvmax - zvmin
      coffset = red_offset(GIF=GIF,diff)
      print, 'diff = ',diff, ' coffset = ',coffset
      idat(w) = zvmax - coffset; set pixels to red
      w = 0 ; free the data space
      if wc eq npixels then print,'WARNING=All data outside min/max!!'
   endif

;TJK added this section to print out some statistics about the data distribution. 
    if keyword_set(DEBUG) then begin
      print, 'Statistics about the data distribution'
      w = where(((idat lt zvmax) and (idat ge (zvmax-10))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax,' and ',zvmax-10,' = ',wc
      w = where(((idat lt zvmax-10) and (idat ge (zvmax-20))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-10,' and ',zvmax-20,' = ',wc
      w = where(((idat lt zvmax-20) and (idat ge (zvmax-30))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-20,' and ',zvmax-30,' = ',wc
      w = where(((idat lt zvmax-30) and (idat ge (zvmax-40))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-30,' and ',zvmax-40,' = ',wc
      w = where(((idat lt zvmax-40) and (idat ge (zvmax-50))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-40,' and ',zvmax-50,' = ',wc
      w = where(((idat lt zvmax-50) and (idat ge (zvmax-60))),wc)
      if wc gt 0 then print, 'Number of values between ',zvmax-50,' and ',zvmax-60,' = ',wc
    endif

    ; rebin image data to fit thumbnail size
; RTB commented these out for large format
;   if (nimages eq 1) then idat = congrid(idat,tsize,tsize) $
;    else idat = congrid(idat,tsize,tsize,nimages)
;     idat = congrid(idat,tsize,tsize)

    ; filter out data values outside 3-sigma for better color spread
    if keyword_set(NONOISE) then begin
      print, 'before semiminmax min and max = ', zvmin, zvmax
      semiMinMax,idat,zvmin,zvmax,/MODIFIED
      w = where((idat lt zvmin),wc)
      if wc gt 0 then begin
        print,'WARNING=filtering values less than 3-sigma from image data...'
        idat(w) = zvmin ; set pixels to black
        w = 0 ; free the data space
      endif
      w = where((idat gt zvmax),wc)
      if wc gt 0 then begin
        print,'WARNING=filtering values greater than 3-sigma from image data...'
;6/25/2004 see below         idat(w) = zvmax -1; set pixels to red
         ;TJK 6/25/2004 - added red_offset function to determine offset
         ;(to red) because of cases like log scaled timed guvi data
         ;where the diff is less than 1.
         diff = zvmax - zvmin
         coffset = red_offset(GIF=GIF,diff)
         print, 'diff = ',diff, ' coffset = ',coffset
         idat(w) = zvmax - coffset; set pixels to red
        w = 0 ; free the data space
      endif
    endif

    ; scale to maximize color spread
    idmax=max(idat) & idmin=min(idat) ; RTB 10/96

if keyword_set(DEBUG) then begin
	print, '!d.n_colors = ',!d.n_colors
	print, 'min and max after filtering = ',idmin, ' ', idmax
endif

;TJK commented out for flux image    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)

;The following is code that had to be written with a different methodology than any of 
;our other image display plottypes in order to get the enaflux code integrated easily...
;We're going to cycle through all of the images and create a little gif file for each, then
;we read them back in and place them on the "big" gif file lower down in the code...
;This method is a lot easier than trying to re-write plot_enaflux to work the way we'd want it
;to...  This may perform horribly!  TJK 12/21/2000


;add case statement to set different spin and polar angles depending on
;which dataset we have - also smooth the HENA data here. TJK 1/29/01
;And make the lena and mena image arrays square.
;7/20/2001 - take out mena array adjustment - images are provided square.

;TJK - 4/24/01 - take the smoothing out of here since Rick has now added
;a keyword to plot_enaflux for smoothing...  CDAWeb sets the smooth keyword
;so we'll just pass it through.

   case descriptor(0) of
	'EUV' : begin	
		  spin = 84.0
		  polar = 0.6
		  nocircles = 1
		  nodipole = 1
		  nocolorbar = 1
		  noborder = 1
;try no reverse		  reverseorder = 1 ;put back in - TJK 9/6/2002
		  reverseorder = 0 
    		end
        'HENA': begin 	
;TJK - 7/20-2001 - don't need to smooth here, figured out the problem w/ Rick's
;smoothing in plot_enaflux.
;TJK leave smoothing in here for hena since the generic "smooth" isn't working
;well for EUV.
;		  print, 'smoothing hena image data'
;		  for numgif = 0, nimages-1 do begin
;		    itmp = idat(*,*,numgif)
;		    idat(*,*,numgif) = smooth(itmp,5)
;		  endfor
		  spin = 120.0
		  polar = 6.0
		  nocolorbar = 1
		  noborder = 1
		  nocircles = 0
		  nodipole = 0
		  reverseorder = 0
		end
        'MENA': begin 	
		  spin = 128.0
		  polar = 4.0
		  nocolorbar = 1
		  noborder = 1
		  nocircles = 0
		  nodipole = 0
		  reverseorder = 2
		end
        'LENA': begin 	
		  ;lena data has to be made into a square 12x12 image array
		  ;this is how Rick Burley creates his images so,... TJK
		  itmp = idat
	    	  idat = fltarr(12,12,nimages)
 		  for numgif = 0, nimages-1 do begin
		    idat(*,*,numgif) = itmp(18:29,*,numgif)
		  endfor
		  spin = 96.0
		  polar = 8.0
		  nocolorbar = 1
		  noborder = 1
		  nocircles = 0
		  nodipole = 0
		  reverseorder = 0
		end
	else : begin
		print, 'setting spin and polar angles to default'
		spin = 84.0
		polar = 0.6
	       end
	endcase


for numgif = 0, nimages-1 do begin
  win=make_array(2, /integer, value=tsize)
  temp_gif = gif + strtrim(string(numgif),2)
;  print, 'Creating temp gif = ',temp_gif

  stat = plot_enaflux(edat(numgif),idat(*,*,numgif), spin, polar, $
	 pos_dat(*,numgif), spin_dat(*,numgif), 1, wsize=win, DEBUG=DEBUG,$
	 noborder=noborder, nocircles=nocircles, nodipole=nodipole, $
	 nocolorbar=nocolorbar, smooth=smooth, gif=temp_gif, reverseorder=reverseorder)	

;TJK added smooth keyword because Rick added it in plot_enaflux 4/24/01
;original euv settings /noborder, /nocircles, /nodipole, /nocolorbar, gif=temp_gif)	

  if (stat ge 0) then begin ;good image found and put in temp_gif gif file.
    ;store these temporary gif file names into a string array
    if (n_elements(temp_gifs) eq 0) then temp_gifs = temp_gif else temp_gifs = [temp_gifs,temp_gif]
  endif else begin
    print, 'Gif not generated for gif number ',numgif,' and date ',edat(numgif) 
  endelse
endfor

;have to determine the size of the BIG window again since its possible that not
;all time records had a gif produced for them. TJK added on 7/5/2001
  nimages = n_elements(temp_gifs)
  nrows = (nimages / ncols) + 1
  ys = (nrows*boxsize) + 15

  ; open the BIG window or gif file, that will contain all the thumbnails
  if keyword_set(GIF) then begin
    deviceopen,6,fileOutput=GIF,sizeWindow=[xs+xco,ys+40]
      if (no_data_avail eq 0) then begin
       if(reportflag eq 1) then printf,1,'IMAGE=',GIF
       print,'IMAGE=',GIF
      endif else begin
       if(reportflag eq 1) then printf,1,'I_GIF=',GIF
       print,'I_GIF=',GIF
      endelse
  endif else begin ; open the xwindow
    window,/FREE,XSIZE=xs+xco,YSIZE=ys+40,TITLE=window_title
  endelse

xmargin=!x.margin
if COLORBAR then begin
 if (!x.omargin(1)+!x.margin(1)) lt 14 then !x.margin(1) = 14
 !x.margin(1) = 14
 plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
endif

;print, '!x.margin = ',!x.margin



; generate the thumbnail plots

;TJK - 2/20/97 - if viking images then rotate them 270 degrees, otherwise
; leave them as is.

if (vkluge)then for j=0,nimages-1 do idat(*,*,j) = rotate(idat(*,*,j),7)


; Position each image individually to control layout
    irow=0
    icol=0

;Now go through the images/small gifs and correctly place them on the big gif

  for j=0,nimages-1 do begin

    if(icol eq ncols) then begin
       icol=0 
       irow=irow+1
    endif
    xpos=icol*tsize
    ypos=ys-(irow*tsize+30)
    if (irow gt 0) then ypos = ypos-(label_space*irow) ;TJK modify position for labels
;# Test code for Large Format
; Scale images  RTB 3/98
      xthb=tsize
      ythb=tsize+label_space
      xsp=float(xthb)/float(xs+80)  ; size of x frame in normalized units
      ysp=float(ythb)/float(ys+30)  ; size of y frame in normalized units
      yi= 1.0 - 10.0/ys             ; initial y point in normalized units
      x0i=0.0095                    ; initial x point in normalized units
      y0i=yi-ysp         ;y0i=0.65
      x1i=0.0095+xsp             ;x1i=.10
      y1i=yi
; Set new positions for each column and row
      x0=x0i+icol*xsp
      y0=y0i-irow*ysp
      x1=x1i+icol*xsp
      y1=y1i-irow*ysp

; 2nd test rescale
      xpimg=xthb
      ypimg=ythb-label_space
; Use device coordinates for Map overlay thumbnails
      xspm=float(xthb)
      yspm=float(ythb-label_space)
      yi= (ys+30) - label_space ; initial y point
      x0i=2.5         ; initial x point
      y0i=yi-yspm
      x1i=2.5+xspm
      y1i=yi
; Set new positions for each column and row
      x0=x0i+icol*xspm
      y0=y0i-(irow*yspm+irow*label_space)
      x1=x1i+icol*xspm
      y1=y1i-(irow*yspm+irow*label_space)
      position=[x0,y0,x1,y1]

      xpos=x0
      ypos=y0
;# End LF test

;TJK read in the individual gif files and place them into the final gif.

	
;     print, 'now read small image out of gif file named ',temp_gifs(j),' and put in the final file called',gif
     read_gif,temp_gifs(j),a,r,g,b ; & tvlct,r,g,b  ; read the gif and load colors from it
     tv, a, xpos, ypos, /DEVICE
     foreground = !d.n_colors-1

     ; Print time tag
     if (j eq 0) then begin
         prevdate = decode_cdfepoch(edat(j)) ;TJK get date for this record
     endif else prevdate = decode_cdfepoch(edat(j-1)) ;TJK get date for this record

     edate = decode_cdfepoch(edat(j)) ;TJK get date for this record
;
;TJK 3/10/2006 for large thumbnails, always print the longer date -
;Bob's request.

     shortdate = strmid(edate, 10, strlen(edate)) ; shorten it
;     yyyymmdd = strmid(edate, 0,10) ; yyyymmdd portion of current
;     prev_yyyymmdd = strmid(prevdate, 0,10) ; yyyymmdd portion of previous

;     xyouts, xpos, ypos-10, shortdate, color=!d.n_colors-1, /DEVICE ; display w/ image
;TJK 11/10/2005 - use the longer date on these thumbnails since w/ new
;                 rumba machine, one can easly plot several days worth
;                 of plots

;     if (((yyyymmdd ne prev_yyyymmdd) or (j eq 0)) and tsize gt 50 ) then begin
     if ( tsize gt 50 ) then begin
           xyouts, xpos, ypos-10, edate, color=foreground, charsize=1.0,/DEVICE
     endif else xyouts, xpos, ypos-10, shortdate, color=foreground, charsize=1.2,/DEVICE

     icol=icol+1
     ;TJK - delete temporary gif files as they are written out to the big gif
     cmd = strarr(2)
     cmd(0) = "rm"
     cmd(1) = temp_gifs(j)
     spawn, cmd, /noshell

  endfor

;End loop for THUMBNAILS

    ; done with the image
    if ((reportflag eq 1)AND(no_data_avail eq 0)) then begin
      PRINTF,1,'VARNAME=',astruct.(vnum).varname 
      PRINTF,1,'NUMFRAMES=',nimages
      PRINTF,1,'NUMROWS=',nrows & PRINTF,1,'NUMCOLS=',ncols
      PRINT,1,'THUMB_HEIGHT=',tsize+label_space
      PRINT,1,'THUMB_WIDTH=',tsize
      PRINTF,1,'START_REC=',start_frame
      PRINTF,1,'FLUX_IMAGE=1'
    endif
    if (no_data_avail eq 0) then begin
      PRINT,'VARNAME=',astruct.(vnum).varname
      PRINT,'NUMFRAMES=',nimages
      PRINT,'NUMROWS=',nrows & PRINT,'NUMCOLS=',ncols
      PRINT,'THUMB_HEIGHT=',tsize+label_space
      PRINT,'THUMB_WIDTH=',tsize
      PRINT,'START_REC=',start_frame
      PRINT,'FLUX_IMAGE=1'
    endif

    if ((keyword_set(CDAWEB))AND(no_data_avail eq 0)) then begin
      fname = GIF + '.sav' & save_mystruct,astruct,fname
    endif
    ; subtitle the plot
 ;  project_subtitle,astruct.(0),'',/IMAGE,TIMETAG=[edat(0),edat(nimages-1)]
    project_subtitle,astruct.(0),window_title,/IMAGE, $
       TIMETAG=[edat(0),edat(nimages-1)]

; RTB 10/96 add colorbar
if COLORBAR then begin
  if (n_elements(cCharSize) eq 0) then cCharSize = 0.
   cscale = [idmin, idmax]  ; RTB 12/11
;  cscale = [zvmin, zvmax]
  xwindow = !x.window
  !x.window(1)=0.858   ; added 10/98 RTB
  !y.window=[0.1,0.9]
  offset = 0.01
  colorbar, cscale, ctitle, logZ=0, cCharSize=cCharSize, $ 
        position=[!x.window(1)+offset,      !y.window(0),$
                  !x.window(1)+offset+0.03, !y.window(1)],$
        fcolor=244, /image

  !x.window = xwindow
endif ; colorbar

!x.margin=xmargin

    if keyword_set(GIF) then deviceclose

  endif else begin
    ; no data available - write message to gif file and exit
    print,'STATUS=No data in specified time period.'
    if keyword_set(GIF) then begin
      xyouts,xs/2,ys/2,/device,alignment=0.5,color=244,$
             'NO DATA IN SPECIFIED TIME PERIOD'
      deviceclose
    endif else begin
      xyouts,xs/2,ys/2,/device,alignment=0.5,'NO DATA IN SPECIFIED TIME PERIOD'
    endelse
  endelse
endelse
; blank image (Try to clear)
if keyword_set(GIF) then device,/close

return,0
end
