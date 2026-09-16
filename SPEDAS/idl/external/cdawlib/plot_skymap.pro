;$Author: jimm $ 
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/plot_skymap.pro,v 1.15 2009/12/03 18:39:24 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $
;+------------------------------------------------------------------------
; NAME: PLOT_SKYMAP
; PURPOSE: To plot the image data with the TWINS project provided
;          skymap software.
;
;          Can plot as "thumbnails" or single frames.
;
; CALLING SEQUENCE:
;       out = plotmaster(astruct,vname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;       vname   = name of the variable in the structure to plot
;
; KEYWORD PARAMETERS:
;       THUMBSIZE = size (pixels) of thumbnails, default = 40 (i.e. 40x40)
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
;       MOVIE = If this routine is being called to produce an mpeg
;       then we don't want the 'frame' number in the output
;       filename. This keyword takes care of that.
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       Tami Kovalick October, 2009
;
; MODIFICATION HISTORY: Held in RCS
;
;-------------------------------------------------------------------------
FUNCTION plot_skymap, astruct, vname, $
                      THUMBSIZE=THUMBSIZE, FRAME=FRAME, $
                      XSIZE=XSIZE, YSIZE=YSIZE, GIF=GIF, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                      CDAWEB=CDAWEB,DEBUG=DEBUG,COLORBAR=COLORBAR, MOVIE=MOVIE

; Determine the field number associated with the variable 'vname'
w = where(tag_names(astruct) eq strupcase(vname),wc)
if (wc eq 0) then begin
  print,'ERROR=No variable with the name:',vname,' in param 1!' & return,-1
endif else vnum = w(0)

Zvar = astruct.(vnum)
if keyword_set(COLORBAR) then COLORBAR=1L else COLORBAR=0L
if COLORBAR  then xco=80 else xco=0 ; No colorbar

; 
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

;for the skymap code need several additional variables in order place
;the pixels on the map... need sc_posv_re_eci, spin_axis_eci,
;sun_posv_eci, mag_eci and prime_meridian_eci 
; I've set these a depend_1 through depend_5 - in the above order.

b = astruct.(vnum).DEPEND_1 & c = tagindex(b(0),tag_names(astruct))
d = tagindex('DAT',tag_names(astruct.(c)))
if (d(0) ne -1) then sc_posv_re_eci_dat = astruct.(c).DAT $
else begin
  d = tagindex('HANDLE',tag_names(astruct.(c)))
  if (d(0) ne -1) then handle_value,astruct.(c).HANDLE,sc_posv_re_eci_dat $
  else begin
    print,'ERROR= No sc_posv_re_eci_dat DAT or HANDLE tag' & return,-1
  endelse
endelse

b = astruct.(vnum).DEPEND_2 & c = tagindex(b(0),tag_names(astruct))
d = tagindex('DAT',tag_names(astruct.(c)))
if (d(0) ne -1) then spin_axis_eci_dat = astruct.(c).DAT $
else begin
  d = tagindex('HANDLE',tag_names(astruct.(c)))
  if (d(0) ne -1) then handle_value,astruct.(c).HANDLE,spin_axis_eci_dat $
  else begin
    print,'ERROR= No spin_axis_eci_dat DAT or HANDLE tag' & return,-1
  endelse
endelse

b = astruct.(vnum).DEPEND_3 & c = tagindex(b(0),tag_names(astruct))
d = tagindex('DAT',tag_names(astruct.(c)))
if (d(0) ne -1) then sun_posv_eci_dat = astruct.(c).DAT $
else begin
  d = tagindex('HANDLE',tag_names(astruct.(c)))
  if (d(0) ne -1) then handle_value,astruct.(c).HANDLE,sun_posv_eci_dat $
  else begin
    print,'ERROR= No sun_posv_eci_dat DAT or HANDLE tag' & return,-1
  endelse
endelse

b = astruct.(vnum).DEPEND_4 & c = tagindex(b(0),tag_names(astruct))
d = tagindex('DAT',tag_names(astruct.(c)))
if (d(0) ne -1) then prime_meridian_eci_dat = astruct.(c).DAT $
else begin
  d = tagindex('HANDLE',tag_names(astruct.(c)))
  if (d(0) ne -1) then handle_value,astruct.(c).HANDLE,prime_meridian_eci_dat $
  else begin
    print,'ERROR= No prime_meridian_eci_dat DAT or HANDLE tag' & return,-1
  endelse
endelse

b = astruct.(vnum).DEPEND_5 & c = tagindex(b(0),tag_names(astruct))
d = tagindex('DAT',tag_names(astruct.(c)))
if (d(0) ne -1) then mag_eci_dat = astruct.(c).DAT $
else begin
  d = tagindex('HANDLE',tag_names(astruct.(c)))
  if (d(0) ne -1) then handle_value,astruct.(c).HANDLE,mag_eci_dat $
  else begin
    print,'ERROR= No mag_eci_dat DAT or HANDLE tag' & return,-1
  endelse
endelse

b = astruct.(vnum).DEPEND_6 ;check for image_title
if (b ne '') then begin
 c = tagindex(b(0),tag_names(astruct))
 d = tagindex('DAT',tag_names(astruct.(c)))
 if (d(0) ne -1) then image_title = astruct.(c).DAT $
 else begin
   d = tagindex('HANDLE',tag_names(astruct.(c)))
   if (d(0) ne -1) then handle_value,astruct.(c).HANDLE,image_title $
   else begin
     print,'ERROR= No image_title specified in the DAT or HANDLE tag' & return,-1
   endelse
 endelse
endif ;if depend_6 (image_title) exists

; Determine the title for the window or gif file

a = tagindex('SOURCE_NAME',tag_names(astruct.(vnum)))
if (a(0) ne -1) then begin
  sn = break_mystring(astruct.(vnum).SOURCE_NAME,delimiter='>')
  b = sn(0)
endif else b = ''
a = tagindex('DESCRIPTOR',tag_names(astruct.(vnum)))
if (a(0) ne -1) then b = b + '  ' + astruct.(vnum).DESCRIPTOR

a = tagindex('DATA_TYPE',tag_names(astruct.(vnum)))
if (a(0) ne -1) then begin
   b = b + '  ' + astruct.(vnum).DATA_TYPE
   d_type = strupcase(str_sep((astruct.(vnum).DATA_TYPE),'>')) ;TJK added 4/2/02, used below
endif

;TJK added FIELDNAM as part of the title since we now have multiple image
;variables per datatype.
a = tagindex('FIELDNAM',tag_names(astruct.(vnum)))
if (a(0) ne -1) then b = b + ' ' + astruct.(vnum).FIELDNAM


window_title = b
if keyword_set(nonoise) then window_title=window_title+'!CConstrained values within >3-sigma from mean of all plotted values'

; Determine title for colorbar

if(COLORBAR) then begin
 a=tagindex('UNITS',tag_names(astruct.(vnum)))
 if(a(0) ne -1) then ctitle = astruct.(vnum).UNITS else ctitle=''
endif

if keyword_set(XSIZE) then xs=XSIZE else xs=512
if keyword_set(YSIZE) then ys=YSIZE else ys=512

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
isize = size(idat)
if (isize(0) eq 2) then n_images=1 else n_images=isize(isize(0))

if (n_images eq 1) then FRAME=1

if keyword_set(FRAME) then begin ; produce plot of a single frame
  if ((FRAME ge 1)AND(FRAME le n_images)) then begin ; valid frame value
    idat = idat(*,*,(FRAME-1)) ; grab the frame
    idat = reform(idat) ; remove extraneous dimensions

;5/7/01 - turns out the RPI images don't need to be rotated.  Left this code
;in because I'm sure we'll need to do this type of transpose/rotate for some
;other dataset that doesn't have square images...
;    if(descriptor(0) eq 'RPI') then idat = transpose(idat) ;TJK 3/13/01

; Vis images as sent to us are a reflection and a rotation from how the images
; are displayed on the vis home page.  RTB
    ;if(descriptor(0) eq 'VIS') then idat=rotate(rotate(idat,5),3) ; RTB 9/98
    if(descriptor(0) eq 'VIS') then idat=rotate(rotate(idat,5),2) ; RTB 9/98
; Fix UVI primary image orientation prior to 12/96;  RTB 11/10/98
    if(descriptor(0) eq 'UVI') then begin
     cdf_epoch, edat(FRAME-1), yr,mn,dy,hr,min,sec,milli,/break
     ical,yr,doy,mn,dy,/idoy
;TJK change to following per Bob's request 4/02/01 if (doy lt 337) then begin  

     if ((fix(yr) eq 1996) and (doy lt 337)) then begin
      print, 'Found UVI yr=1996 and doy lt 337 - rotate/trans.'
      idat=rotate(idat,3)
      idat=transpose(idat)
     endif
     if ((d_type(0) eq 'H2') or (d_type(0) eq 'H3')) then begin
      idat=transpose(idat)
     endif
    endif
; end UVI primary image fix

    isize = size(idat) ; get the dimensions of the image
    r1 = 450./isize(1) ; determine ratio for first dimension
    r2 = 450./isize(2) ; determine ratio for second dimension
    ;r1 = ceil(500/isize(1)) ; determine ratio for first dimension
    ;r2 = ceil(500/isize(2)) ; determine ratio for second dimension
    xs = ceil(isize(1)*r1)+50 ; determine xsize of window
    ys = ceil(isize(2)*r2)+15 ; determine ysize of window
    ;idat = rebin(idat,(isize(1)*r1),(isize(2)*r2)) ; resize the image
    idat = congrid(idat,(isize(1)*r1),(isize(2)*r2)) ; resize the image

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
;the fill values to 0, otherwise, if the fill values is greater
;than zvmax, then the values will be included in the image.
;    w = where((idat lt zvmin),wc)

    w = where((idat lt zvmin or idat eq zfill),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Number of values below the valid min = ',wc
      print,'WARNING=setting ',wc,' fill values in image data to z validmin... ',zvmin
;TJK change to zvmin instead of 0 12/14/2000      idat(w) = 0 ; set pixels to the black
      idat(w) = zvmin ; set pixels to the zvmin (used to be 0)
      if (zvmin le 0) then print, 'WARNING: Z validmin is <= zero '
      w = 0 ; free the data space
    endif

;TJK try not taking out the higher values and just scale them in.
    w = where((idat gt zvmax),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Number of values above the valid max = ',wc
      if keyword_set(DEBUG) then print,'WARNING=setting ',wc,' fill values in image data to red...'
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

       ;6/24/2004idat(w) = zvmax -2; set pixels to red
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

if keyword_set(DEBUG) then begin
	print, '!d.n_colors = ',!d.n_colors
	print, 'min and max after filtering = ',idmin, ' ', idmax
endif

if keyword_set(DEBUG) then begin
	bytmin = min(idat, max=bytmax)
	print, 'min and max after bytscl = ',bytmin, ' ', bytmax
endif

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

        if not keyword_set(movie) then begin
            GIF=strmid(GIF,0,(strpos(GIF,'.gif')))+'_f000.gif'

            if(FRAME lt 100) then gifn='0'+strtrim(string(FRAME),2) 
            if(FRAME lt 10) then gifn='00'+strtrim(string(FRAME),2) 
            if(FRAME ge 100) then gifn=strtrim(string(FRAME),2)

            GIF=strmid(GIF,0,(strpos(GIF,'.gif')-3))+gifn+'.gif'
            print,'I_GIF=',GIF 
        endif    

        deviceopen,6,fileOutput=GIF,sizeWindow=[xs+xco,ys+30]
        if (reportflag eq 1) then begin
            printf,1,'I_GIF=',GIF & close,1
        endif 
    endif else begin ;if not gif open the xwindow
      window,/FREE,XSIZE=xs+xco,YSIZE=ys+30,TITLE=window_title
    endelse


xmargin=!x.margin
if COLORBAR then begin 
 if (!x.omargin(1)+!x.margin(1)) lt 14 then !x.margin(1) = 14
 !x.margin(1) = 14
 plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
endif


    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-2)
    
    if (vkluge eq 0) then begin ; blow up the image
        ; TJK don't use skymap colorbar for now

        cdaweb_skymap, transpose(idat), sc_pos = sc_posv_re_eci_dat(*,(frame-1)), $
          spin_axis=spin_axis_eci_dat(*,(frame-1)), sun_pos=sun_posv_eci_dat(*,(frame-1)), $
          prime_meridian=prime_meridian_eci_dat(*,(frame-1)), mag = mag_eci_dat(*,(frame-1)), $
          lonmin=-88, lonmax=268,latmin=4, latmax=88, colorbar=0, grid = 1,  $
          field=1, limb=1, sphere = 1, term=1, log=0, norotate=1, noerase=1,ctab=39, exobase=0,thumb=0

    endif else begin ; special case kluge for viking
        tv,idat,0,30,/DEVICE
        acolor = !d.n_colors ; pick color for contouring
    endelse
    ; subtitle the plot
    ; for skymaps don't use the image start time, but instead use the
    ; image_title (see below).
    ;    project_subtitle,astruct.(0),window_title,/IMAGE,TIMETAG=edat(FRAME-1)

    project_subtitle,astruct.(0),window_title;,/IMAGE,TIMETAG=edat(FRAME-1)

; RTB 10/96 add colorbar
if COLORBAR then begin
  if (n_elements(cCharSize) eq 0) then cCharSize = 0.
  cscale = [idmin, idmax] ; RTB 12/11
; cscale = [zvmin, zvmax]
  xwindow = !x.window
  offset = 0.01

  colorbar, cscale, ctitle, logZ=logZ, cCharSize=cCharSize, $
        position=[!x.window(1)+offset,      !y.window(0),$
                  !x.window(1)+offset+0.025, !y.window(1)],$
;try a little narrower to get the label in place
;                  !x.window(1)+offset+0.03, !y.window(1)],$
        fcolor=244, /image
  !x.window = xwindow
endif ; colorbar

;print a label for the skymap; image_title should be the time range
if (strlen(image_title(frame-1)) gt 10) then begin
  xyouts,!d.x_size/2,((!d.y_ch_size*2)+10),image_title(frame-1),/DEVICE,ALIGNMENT=0.5,CHARSIZE=1.4,COLOR=244
endif
tsky = 'Polar res. 4 deg. Red=X=noon, Yellow=Y=dusk.'
xyouts,!d.x_size/2,((!d.y_ch_size*2)+22),tsky,/DEVICE,ALIGNMENT=0.5,CHARSIZE=1.4,COLOR=244

    if keyword_set(GIF) then deviceclose
  endif ; valid frame value
;
; THUMBNAILS
;
endif else begin ; produce thumnails of all images

  if keyword_set(THUMBSIZE) then tsize = THUMBSIZE else tsize = 50
  
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
  boxsize =tsize+label_space;TJK added for allowing time labels for each image.
  ys = (nrows*boxsize) + 15

  ; Perform data filtering and color enhancement it any data exists
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
;      print,'WARNING=setting ',wc,' fill values in image data to black...'
      print,'WARNING=setting ',wc,' fill values in image data to z validmin... ',zvmin
      idat(w) = zvmin ; set pixels to the zvmin (used to be 0)
      if (zvmin le 0) then print, 'WARNING: Z validmin is <= zero '
      w = 0 ; free the data space
      if wc eq npixels then print,'WARNING=All data outside min/max!!'
    endif

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
; Moved this block
;   ; rebin image data to fit thumbnail size
;   if (nimages eq 1) then idat = congrid(idat,tsize,tsize) $
;   else idat = congrid(idat,tsize,tsize,nimages)

    ; scale to maximize color spread
    idmax=max(idat) & idmin=min(idat) ; RTB 10/96

if keyword_set(DEBUG) then begin
	print, '!d.n_colors = ',!d.n_colors
	print, 'min and max after filtering = ',idmin, ' ', idmax
endif

if keyword_set(DEBUG) then begin
	bytmin = min(idat, max=bytmax)
	print, 'min and max after bytscl = ',bytmin, ' ', bytmax
endif

  ; open the window or gif file
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

 idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-2)

; generate the thumbnail plots

;TJK - 2/20/97 - if viking images then rotate them 270 degrees, otherwise
; leave them as is.

if (vkluge)then for j=0,nimages-1 do idat(*,*,j) = rotate(idat(*,*,j),7)


; Position each image individually to control layout
    irow=0
    icol=0

    for j=0,nimages-1 do begin

; see above    if(descriptor(0) eq 'RPI') then idat(*,*,j) = transpose(idat(*,*,j)) ;TJK 3/13/01

; if VIS rotate RTB 
; Vis images as sent to us are a reflection and a rotation from how the images
; are displayed on the vis home page. RTB
     if(descriptor(0) eq 'VIS') then $ 
      ;idat(*,*,j)=rotate(rotate(idat(*,*,j),5),3) ; RTB 9/98
      idat(*,*,j)=rotate(rotate(idat(*,*,j),5),2) ; RTB 9/98
; UVI primary image fix for times prior to 12/96; RTB 11/98
     if(descriptor(0) eq 'UVI') then begin 
      cdf_epoch, edat(j), yr,mn,dy,hr,min,sec,milli,/break
      ical,yr,doy,mn,dy,/idoy

      ;TJK change to following per Bob's request 4/02/01 if (doy lt 337) then begin  
      if ((fix(yr) eq 1996) and (doy lt 337)) then begin
        temp_dat=idat(*,*,j);
        temp_dat=rotate(temp_dat,3)
        idat(*,*,j)=transpose(temp_dat)
      endif

      if ((d_type(0) eq 'H2') or (d_type(0) eq 'H3')) then begin
	if (j eq 0 ) then begin
	;set up an array to handle the "transposed images"
  	  dims = size(idat,/dimensions)
  	  if n_elements(dims) gt 2 then $
	     idat2 = bytarr(dims(1),dims(0),dims(2)) else $
	     idat2 = bytarr(dims(1),dims(0))
        endif
        idat2(*,*,j)=transpose(idat(*,*,j))
      endif
 
     endif ;if UVI data

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
;TJK added the following to deal with UVI data that had to be put in array idat2 instead of idat
;4/9/2001
    if ((d_type(0) eq 'H2') or (d_type(0) eq 'H3')) then begin
     tmp_img=congrid(idat2(*,*,j),xpimg,ypimg) 
    endif else begin
     tmp_img=congrid(idat(*,*,j),xpimg,ypimg) 
    endelse


     if(strupcase(descriptor(0)) eq 'TEC2HR') then begin
;       if keyword_set(DEBUG) then print, 'reversing data in the latitude dimension for GPS data'
       tmp_img = reverse(tmp_img,2)
    endif

;remove for skymap     tv,tmp_img,xpos,ypos,/DEVICE
;help, idat
    if (j eq 0 ) then begin
    ;set up an array to handle the "transposed images"
        dims = size(idat,/dimensions)
        if n_elements(dims) gt 2 then $
          idat2 = bytarr(dims(1),dims(0),dims(2)) else $
	  idat2 = bytarr(dims(1),dims(0))
    endif
    idat2(*,*,j)=transpose(idat(*,*,j))

    cdaweb_skymap, idat2(*,*,j), sc_pos = sc_posv_re_eci_dat(*,j), $
      spin_axis=spin_axis_eci_dat(*,j), sun_pos=sun_posv_eci_dat(*,j), $
      prime_meridian=prime_meridian_eci_dat(*,j), mag = mag_eci_dat(*,j), $
      lonmin=-88, lonmax=268,latmin=4, latmax=88, colorbar=0, grid = 1,  $
      field=1, limb=1, sphere = 1, term=1, log=0, norotate=1, noerase=1,$
      ctab=39, exobase=0, position=position, /thumb ;TJK added last two


     foreground = !d.n_colors-1
     white_background = 0

     ;tv,idat(*,*,j),xpos,ypos,/DEVICE
     ; Print time tag
     if (j eq 0) then begin
        prevdate = decode_cdfepoch(edat(j)) ;TJK get date for this record
     endif else prevdate = decode_cdfepoch(edat(j-1)) ;TJK get date for this record
     edate = decode_cdfepoch(edat(j)) ;TJK get date for this record
     shortdate = strmid(edate, 10, strlen(edate)) ; shorten it
     yyyymmdd = strmid(edate, 0,10) ; yyyymmdd portion of current
     prev_yyyymmdd = strmid(prevdate, 0,10) ; yyyymmdd portion of previous


;     xyouts, xpos, ypos-10, shortdate, color=247, /DEVICE ;display w/ image
;     xyouts, xpos, ypos-10, shortdate, color=!d.n_colors-1, /DEVICE ;
;TJK 11/10/2005 - use the longer date on these thumbnails since w/ new
;                 rumba machine, one can easly plot several days worth
;                 of plots
     if (((yyyymmdd ne prev_yyyymmdd) or (j eq 0)) and tsize gt 50 ) then begin
         xyouts, xpos, ypos-10, edate, color=foreground, charsize=1.0,/DEVICE
     endif else xyouts, xpos, ypos-10, shortdate, color=foreground,/DEVICE
 
    icol=icol+1
    endfor

    ; done with the image
    if ((reportflag eq 1)AND(no_data_avail eq 0)) then begin
      PRINTF,1,'VARNAME=',astruct.(vnum).varname 
      PRINTF,1,'NUMFRAMES=',nimages
      PRINTF,1,'NUMROWS=',nrows & PRINTF,1,'NUMCOLS=',ncols
      PRINT,1,'THUMB_HEIGHT=',tsize+label_space
      PRINT,1,'THUMB_WIDTH=',tsize
      PRINTF,1,'START_REC=',start_frame
      PRINTF,1,'SKYMAP=1'
    endif
    if (no_data_avail eq 0) then begin
      PRINT,'VARNAME=',astruct.(vnum).varname
      PRINT,'NUMFRAMES=',nimages
      PRINT,'NUMROWS=',nrows & PRINT,'NUMCOLS=',ncols
      PRINT,'THUMB_HEIGHT=',tsize+label_space
      PRINT,'THUMB_WIDTH=',tsize
      PRINT,'START_REC=',start_frame
      PRINT,'SKYMAP=1'
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
                  !x.window(1)+offset+0.025, !y.window(1)],$
;Try a little narrower to fit in the units
;                 !x.window(1)+offset+0.03, !y.window(1)],$
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



