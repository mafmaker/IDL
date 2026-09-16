;+------------------------------------------------------------------------
; NAME: MOVIE_MAP_IMAGES
; PURPOSE: To plot a sequence of mapped images into a movie file.
;          
; CALLING SEQUENCE:
;       out = movie_map_images(astruct,vname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;       vname   = name of the variable in the structure to plot
;
; KEYWORD PARAMETERS:
;    CENTERLONLAT = 2 element array of map center [longitude,latitude]
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
;	LIMIT = if set, limit the number of movie frames allowed - this is
;		the default for CDAWEB 
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       Rich Baldwin,  Raytheon STX 
;
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 22, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;       1/21/98 : R. Baldwin   : Initial version modified from plot_images.pro
;-------------------------------------------------------------------------
FUNCTION movie_map_images, astruct, vname, CENTERLONLAT=CENTERLONLAT,$
                           THUMBSIZE=THUMBSIZE, FRAME=FRAME, $
                           XSIZE=XSIZE, YSIZE=YSIZE, GIF=GIF, REPORT=REPORT,$
                           TSTART=TSTART, TSTOP=TSTOP, NONOISE=NONOISE,$
                           MOVIE_FRAME_RATE=MOVIE_FRAME_RATE, MOVIE_LOOP=MOVIE_LOOP, $
                           CDAWEB=CDAWEB, DEBUG=DEBUG, COLORBAR=COLORBAR, LIMIT=LIMIT

top = 255
bottom = 0
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

if n_elements(movie_frame_rate) eq 0 then movie_frame_rate = 3
if n_elements(movie_loop) eq 0 then movie_loop = 1 ; default is "on"

; Determine the field number associated with the variable 'vname'
w = where(tag_names(astruct) eq strupcase(vname),wc)
if (wc eq 0) then begin
  print,'ERROR=No variable with the name:',vname,' in param 1!' & return,-1
endif else vnum = w(0)

projection='MLT'
Zvar = astruct.(vnum)
if keyword_set(COLORBAR) then COLORBAR=1L else COLORBAR=0L
if COLORBAR  then xco=80 else xco=0 ; No colorbar

;by default want to limit the number of frames in a movie 
;but if explicitly set to zero, then don't apply limits
if (n_elements(LIMIT) gt 0) then begin
  if keyword_set(LIMIT) then LIMIT = 1L else LIMIT = 0L
endif else LIMIT=1L

if (keyword_set(CDAWEB)) then CDAWEB = 1L else CDAWEB=0L

print, 'In movie_map_images, LIMIT = ',LIMIT

;TJK - 4/8/2004 - look for function "convert_log10" - this means data has already been
;converted to log 10 and we need to do some special things for the min. val for colorbar.
a = tagindex('FUNCTION',tag_names(astruct.(vnum)))
func = ''
log10Z = 0
if(a(0) ne -1) then begin
	func= astruct.(vnum).(a(0)) ;normally would use the tag name
				  ; but the name is "function" which is
				  ; an IDL reserved word...
	if (strupcase(func) eq 'CONVERT_LOG10') then log10Z = 1 
endif

; if(NOT keyword_set(CENTERLONLAT)) then CENTERLONLAT=[0.0,90.0]
 if keyword_set(REPORT) then reportflag=1L else reportflag=0L

;Define a foreground color (one to be used for labeling and axes, etc.
foreground = !d.n_colors-1 ;this is the default

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

; Find & Parse DISPLAY_TYPE FOR ancillary map image variables (lat & lon)
  a = tagindex('DISPLAY_TYPE',tag_names(astruct.(vnum)))
  if(a(0) ne -1) then display= astruct.(vnum).DISPLAY_TYPE $
  else begin
    print, 'ERROR= No DISPLAY_TYPE attribute for variable'
  endelse
; Parse DISPLAY_TYPE
  ipts=parse_display_type(display)
  keywords=str_sep(display,'>')  ; keyword 1 or greater 

;TJK - added new section here to deal w/ additional IDL projections and special
;setups for TIMED data... 2/25/2004

;Added map_proj into the syntax for the display_type
;Prompted by the arrival of TIMED data. Look for the value and then
;set the appropriate projection name

map_proj = 6 ;default map projection algorithm = azimuthal (for this routine)
fill_cont = 0 ; default not to fill the continents w/ solid color

wc=where(keywords eq 'MAP_PROJ')
if(wc[0] ne -1) then map_proj = fix(keywords(wc(0)+1))

proj_names =["", "stereographic projection","orthographic projection","lambertconic projection",$
             "lambertazimuthal projection", "gnomic projection", "azimuthal equidistant projection",$
             "satellite projection", "cylindrical projection", "mercator projection", $
             "molleweide projection",  "sinusoidal projection", "aitoff projection", "hammeraitoff projection", $
             "albers equal area conic projection", "transverse mercator projection", $
             "miller cylindrical projection", "robinson projection", "lambertconic ellipsoid projection", $
             "goodes homolosine projection"]

;TJK testing filled globe for vis lab...
;if (map_proj eq 2) then fill_cont = 1 ; this will fill the continents white

if (n_elements(map_proj) gt 0) then begin
  projection = proj_names(map_proj)
  if keyword_set(DEBUG) then print, 'Requested ',projection
endif

; Check Project name, if "TIMED" then produce special projections
tip = tagindex('PROJECT',tag_names(astruct.(vnum)))
if (tip ne -1) then project=astruct.(vnum).project else project = ' '

proj = strmid(project,0,3)

;TJK 1/14/2003, set special "cassini like" projection for TIMED and mercator projection
if (project eq 'TIMED') then begin
   white_background = 1
   if(map_proj eq 9) then central_azimuth = 90 else central_azimuth = 0
endif

;TJK 3/15/2004 - add the capability to switch the background from black to
;white.  Also have to switch for foreground color (one to be used for 
;labeling and axes, etc.)
if keyword_set(WHITE_BACKGROUND) then begin
	foreground = 2 
	white_background = 1
endif else begin
	foreground = !d.n_colors-1 
	white_background = 0
endelse

;End of new section related to TIMED (more changes scattered below though)

; Assign latitude variable 
  a = tagindex(strtrim(ipts(0),2),tag_names(astruct))
  if(a(0) ne -1) then begin
     a1=tagindex('DAT',tag_names(astruct.(a(0)))) 
      if(a1(0) ne -1) then glat = astruct.(a(0)).DAT $
      else begin
       a2 = tagindex('HANDLE',tag_names(astruct.(a(0))))
       if (a2(0) ne -1) then handle_value,astruct.(a(0)).HANDLE,glat $
       else begin
         print,'ERROR= 2nd parameter does not have DAT or HANDLE tag' 
         return,-1
       endelse
      endelse
  endif else begin
    print, 'ERROR= GLAT variable missing from structure in map image' 
    return, -1
  endelse

; Assign longitude variable
  a = tagindex(strtrim(ipts(1),2),tag_names(astruct))
  if(a(0) ne -1) then begin
     a1=tagindex('DAT',tag_names(astruct.(a(0))))
      if(a1(0) ne -1) then glon = astruct.(a(0)).DAT $
      else begin
       a2 = tagindex('HANDLE',tag_names(astruct.(a(0))))
       if (a2(0) ne -1) then handle_value,astruct.(a(0)).HANDLE,glon $
       else begin
         print,'ERROR= 3rd parameter does not have DAT or HANDLE tag'
         return,-1
       endelse
      endelse
  endif else begin
    print, 'ERROR= GLON variable missing from structure in map image'
    return, -1
  endelse

; Check that  lons are b/w -180 and 180
  wcg=where(glon gt 180.0,wcgn)
  if(wcgn gt 0) then glon(wcg)=glon(wcg)-360.0

;TJK 2/25/2004 - comment out this next section (so that it matched plot_map_images.pro
; Assign Sun Position
; TERMINATOR=0L
; sun_name='' 
; if(n_elements(ipts) eq 3) then begin ; Make sure display type has 3 elements
;  a = tagindex(strtrim(ipts(2),2),tag_names(astruct))
;  if(a(0) ne -1) then begin
;     snames=tag_names(astruct)
;     sun_name=snames(a(0))
;     a1=tagindex('DAT',tag_names(astruct.(a(0))))
;      if(a1(0) ne -1) then gci_sun = astruct.(a(0)).DAT $
;      else begin
;       a2 = tagindex('HANDLE',tag_names(astruct.(a(0))))
;       if (a2(0) ne -1) then handle_value,astruct.(a(0)).HANDLE,gci_sun $
;       else begin
;         print,'ERROR= 4th parameter does not have DAT or HANDLE tag'
;         return,-1
;       endelse
;      endelse
;    TERMINATOR=1L
;  endif else begin
;   print, 'WARNING= ',sun_name,' variable not defined in structure (plot_map_images)'
;   TERMINATOR=0L
;  endelse
; endif

;TJK 2/25/2004, replace this section w/ section below that allows
;for NORTH, SOUTH and CENTERPOLE
; Check to see of any keywords are included in the display type
; if(n_elements(keywords) ge 2) then begin
;;  if(keywords(1) eq 'CENTERPOLE') then CENTERPOLE=1L else CENTERPOLE = 0L
;  wcn=where(keywords eq 'CENTERPOLE',wc)
;  if(wcn(0) ge 0) then CENTERPOLE = 1L else CENTERPOLE = 0L

;TJK 2/25/2004 - new section
; Check to see of any keywords are included in the display type
if(n_elements(keywords) ge 2) then begin
   ;TJK 1/22/2004 added to allow specification of North or South
   ;pole for TIMED data.
   wc=where(strupcase(keywords) eq 'NORTH')
   if(wc[0] ne -1) then begin
        NORTH = 1 & CENTERPOLE = 1
   endif else begin
        NORTH = 0 & CENTERPOLE = 0
   endelse
   wc=where(strupcase(keywords) eq 'SOUTH')
   if(wc[0] ne -1) then begin
        SOUTH = 1 & CENTERPOLE = 1
   endif else begin
     SOUTH = 0 & CENTERPOLE = 0
   endelse

   if (NORTH or SOUTH)then begin
        CENTERPOLE = 1
   endif else begin
     wc=where(strupcase(keywords) eq 'CENTERPOLE')
     if(wc[0] ne -1) then CENTERPOLE = 1 else CENTERPOLE = 0
   endelse
;TJK end of new section

  ;wcn=where(strupcase(keywords) eq sun_name,wc)
  ;wcn=where(keywords eq 'GCI_SUN',wc)
  wcn=where(strupcase(keywords) eq 'SUN',wc)
  if(wcn(0) ge 0) then SUN = 1L else SUN = 0L 
  wcn=where(strupcase(keywords) eq 'TERMINATOR',wc)
  if(wcn(0) ge 0) then TERMINATOR = 1L else TERMINATOR = 0L 
  wcn=where(keywords eq 'FIXED_IMAGE',wc)
  if(wcn(0) ge 0) then FIXED_IMAGE = 1L else FIXED_IMAGE = 0L
  wcn=where(keywords eq 'MLT_IMAGE',wc)
  if(wcn(0) ge 0) then MLT_IMAGE = 1L else MLT_IMAGE = 0L
 endif

  if(MLT_IMAGE) then TERMINATOR=0L
     
; If Sun position is to be used; create instance 
; if(SUN) then begin
;  a0=tagindex(tag_names(astruct),sun_name)
;  if(a0 ne -1) then handle_value, astruct.(a0).handle, sun_data 
; endif

; Check Descriptor Field for Instrument Specific Settings
tip = tagindex('DESCRIPTOR',tag_names(astruct.(vnum)))
if (tip ne -1) then begin
  descriptor=str_sep(astruct.(vnum).descriptor,'>')
endif

; Get ancillary data if FIXED_IMAGE flag is set in DISPLAY_TYPE for UVI
 if((FIXED_IMAGE) and (descriptor(0) eq "UVI")) then begin
    handle_value,astruct.system.HANDLE,sys
    handle_value,astruct.dsp_angle.handle, dsp
    handle_value,astruct.filter.handle, filt
    handle_value,astruct.gci_position.handle, gpos
    handle_value,astruct.attitude.handle, attit
 endif

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

; Determine the title for the window or gif file
a = tagindex('SOURCE_NAME',tag_names(astruct.(vnum)))
if (a(0) ne -1) then b = astruct.(vnum).SOURCE_NAME else b = ''

a = tagindex('DESCRIPTOR',tag_names(astruct.(vnum)))
if (a(0) ne -1) then b = b + '  ' + astruct.(vnum).DESCRIPTOR

a = tagindex('DATA_TYPE',tag_names(astruct.(vnum)))
if (a(0) ne -1) then begin
   b = b + '  ' + astruct.(vnum).DATA_TYPE
   d_type = strupcase(str_sep((astruct.(vnum).DATA_TYPE),'>'))
endif

;TJK added FIELDNAM as part of the title since we now have multiple image
;variables per datatype.
a = tagindex('FIELDNAM',tag_names(astruct.(vnum)))
if (a(0) ne -1) then b = b + ' ' + astruct.(vnum).FIELDNAM

window_title = b
if keyword_set(nonoise) then window_title=window_title+'!CContsrained values within >3-sigma from mean of all plotted values'

; Determine title for colorbar
if(COLORBAR) then begin
 a=tagindex('UNITS',tag_names(astruct.(vnum)))
 if(a(0) ne -1) then ctitle = astruct.(vnum).UNITS else ctitle=''
endif

if keyword_set(XSIZE) then xs=XSIZE else xs=512
if keyword_set(YSIZE) then ys=YSIZE else ys=512

; Perform special case checking...
;vkluge=0 ; initialize
;tip = tagindex('PLATFORM',tag_names(astruct.(vnum)))
;if (tip ne -1) then begin
;  if (astruct.(vnum).platform eq 'Viking') then vkluge=1
;endif

;CAK: MPEG code now defunct.  Using animated GIFs instead.
;mpegID = mpeg_open([xs+xco,ys+40])

isize= size(idat) ; determine the number of images in the data
if (isize(0) eq 2) then n_images=1 else n_images=isize(isize(0))
if (n_images eq 1) then FRAME=1

if keyword_set(FRAME) then begin ; error - not appropriate for a movie file
  if ((FRAME ge 1)AND(FRAME le n_images)) then begin ; valid frame value
   print, 'ERROR= Single movie frame found'
   print, 'STATUS= Single movie frame; select longer time range.'
   return, -1
  endif

endif else begin ; produce movie of all images
; if the number of frames exceeds 60 send a error message to the user to
; reselect smaller time
;TJK 3/16/2004 - added check for LIMIT keyword - so that we can turn this off
;for CDFX use and private use outside of CDAWeb.
;TJK 1/26/2005 - increase from 60 to 200 due to new rumba machine
  if(n_images gt 200 and LIMIT) then begin
   print, 'ERROR= Too many movie frames '
   print, 'STATUS= Movies limited to 200 frames; select a shorter time range.'
   return, -1
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



;TJK 12/15/2008 add check for dimension sizes for glat and glon - for
;GPS are non-record varying variables, so they don't have the 
;dimensions expected below
;    if ((start_frame ne 0)OR(stop_frame ne nimages)) then begin
;      idat = idat(*,*,start_frame:stop_frame)
;      glat = glat(*,*,start_frame:stop_frame)
;      glon = glon(*,*,start_frame:stop_frame)
; Replaced the above 4 lines w/ the following

      if ((start_frame ne 0)OR(stop_frame ne nimages)) then begin
         idat = idat(*,*,start_frame:stop_frame)
         if (size(glat, /n_dimensions) eq 3) then begin
           glat = glat(*,*,start_frame:stop_frame)
         endif else begin ; have only one record worth of glat, 
                          ;need to create more
           gsize = size(glat)
           tmplat = make_array(gsize(1),nimages, type=gsize(2))
           for recs = 0, nimages-1 do tmplat(*,recs)=glat
           glat = tmplat
         endelse


         if (size(glon, /n_dimensions) eq 3) then begin
           glon = glon(*,*,start_frame:stop_frame)
         endif else begin ; have only one record worth of glon, 
                          ;need to create more
           gsize = size(glon)
           tmplon = make_array(gsize(1),nimages, type=gsize(2))
           for recs = 0, nimages-1 do tmplon(*,recs)=glon
           glon = tmplon
         endelse


      isize = size(idat) ; determine the number of images in the data
      if (isize(0) eq 2) then nimages = 1 else nimages = isize(isize(0))
      edat = edat(start_frame:stop_frame)
    endif
  endelse

  ; calculate number of columns and rows of images
  label_space = 12 ; TJK added constant for label spacing

  ; Perform data filtering and color enhancement it any data exists
  if (no_data_avail eq 0) then begin

; Set all pixels in idat to 0 if position invalid  RTB 1/99
     wlat=where(glat lt -90.0, wlatc)
     if(wlatc gt 0) then idat(wlat) = 0;
     wlon=where(glon lt -180.0, wlonc)
     if(wlonc gt 0) then idat(wlon) = 0;

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

if keyword_set(DEBUG) then begin
  print, 'Image valid min and max: ',zvmin, ' ',zvmax 
  wmin = min(idat,MAX=wmax)
  print, 'Actual min and max of data',wmin,' ', wmax
endif

    w = where((idat lt zvmin),wc)
    white = w ;save off the indices below vmin - need this lower down if white_background
    if wc gt 0 then begin
      print,'WARNING=setting ',wc,' fill values in image data to background...'
;      idat(w) = 0 ; set pixels to black
;4/12/2004 TJK change to lowest value ge zvmin   idat(w) = 0 ; set pixels to black
      good = where (idat ge zvmin, gc)
      if (gc gt 0) then idat(w) = min(idat(good)) else idat(w) = zvmin
      w = 0 ; free the data space
      if wc eq npixels then print,'WARNING=All data outside min/max!!'
    endif

;TJK don't take out the higher values, just scale them in.

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

      if (log10Z) then begin
	above1 = where(idat gt 1.0, wc)
	if(wc gt 0) then idmin = min(idat(above1)) else idmin = zvmin ;TJK 4/8/2004 - add for log scaling
      endif

        idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-2)


    if(white_background and n_elements(white) gt 0) then idat(white) = !d.n_colors-1
    ;idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-3) + 1B

if keyword_set(DEBUG) then begin
	bytmin = min(idat, max=bytmax)
	print, 'min and max after bytscl = ',bytmin, ' ', bytmax
endif

; end changes 12/11 RTB
  ; open the window or gif file
  if keyword_set(GIF) then begin

    GIF1 = GIF + "junk"
    deviceopen,6,fileOutput=GIF1,sizeWindow=[xs+xco,ys+40]
    if white_background then begin
        mapcolor = foreground
        erase                ; erases background and makes it white 
    endif

; Temporary hack: change the file's 'mpg' suffix to 'gif'.
; (Caller should really pass us a 'gif' filename to begin with.)
;    sp = strsplit(gif, '.', /extract)
;    sp[n_elements(sp) - 1] = 'gif'
;    gif = strjoin(sp, '.')
    print, 'MGIF=', gif

;    if no_data_avail eq 0 then begin
;       if reportflag eq 1 then printf,1,'MPEG=',GIF
;       print,'MPEG=',GIF
;    endif else begin
;       if reportflag eq 1 then printf,1,'MPEG=',GIF
;       print,'MPEG=',GIF
;    endelse

  endif else begin ; open the xwindow
;    window,/FREE,XSIZE=xs+xco,YSIZE=ys+40,TITLE=window_title
  endelse

xmargin=!x.margin

; generate the movie sized plots

    irow=0
    icol=0
    for j=0,nimages-1 do begin
      if(white_background) then begin
        erase ;make the background white for each frame in the movie
      endif

     if COLORBAR then begin
      if (!x.omargin(1)+!x.omargin(1)) lt 14 then !x.omargin(1) = 14
      !x.omargin(1) = 14
      plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
     endif

; VIS images have alot of garbage 0.0's or fill values

   if (size(glat, /n_dimensions) eq 3) then clat=glat(*,*,j) else clat = glat
;   clat=glat(*,*,j)
   cond = (clat gt -90.1) and (clat lt 90.1)
   wgoo=where(cond,wgoon)
   if(wgoon gt 0) then clat=clat(wgoo)
   wn=where(clat gt 0.01, wzn)
   ws=where(clat lt -0.01, wzs)
   if(wzn ge wzs) then begin
     if(wzn ne 0) then begin
       centerlat=clat(wn(wzn/2))
     endif else begin
       if (size(glat, /n_dimensions) eq 3) then centerlat=glat(mid1,mid2,j)
     endelse
   endif else begin
    if(wzs ne 0) then centerlat=clat(ws(wzs/2)) 
   endelse
   ;wz=where(glat(*,*,j) ne 0.0,wzn)
   ;if(wzn ne 0) then clat=clat(wz)
   ;if(wzn ne 0) then centerlat=clat(wz(wc/2)) else centerlat=glat(mid1,mid2,j)

;2/25/04 TJK added NORTH and SOUTH to the list of keywords that can be specified in the DISPLAY_TYPE,
;these are not IDL keywords
      if (NORTH) then centerlat = 90.0 ;TJK added for TIMED - need to override CENTERLONLAT
      if (SOUTH) then centerlat = -90.0 ;TJK added for TIMED - need to override CENTERLONLAT

; Set Fixed Geo. position
  if(CENTERPOLE) then begin
;
; The following code flags points which will fall outside the map area.
;
    oosz=size(glat)
    xdim=oosz(1)
    ydim=oosz(2)

      for li=0,xdim-1 do begin
       if(centerlat gt 0.0) then begin
          CENTERLONLAT=[180.0,90.0] 
          btpole=90.0
          if(descriptor(0) eq "VIS") then btlat=30.0 else btlat=40.0 
          if (proj eq 'GPS') then btlat = 0.0
;TJK 12/18/2008 add check for dimensionality of glat (because GPS data
;is NRV and thus doesn't have 3 dimensions
            if (size(glat, /n_dimensions) eq 3) then begin
               wlat=where(glat(li,*,j) lt btlat,wlatc)
               if(wlatc gt 0) then glat(li,wlat,j)=-1.0e+31
            endif
       endif else begin 
          CENTERLONLAT=[180.0,-90.0] 
          btpole=-90.0
          if(descriptor(0) eq "VIS") then btlat=-30.0 else btlat=-40.0 
          if (proj eq 'GPS') then btlat = 0.0
            if (size(glat, /n_dimensions) eq 3) then begin
              wlat=where(glat(li,*,j) gt btlat,wlatc)
              if(wlatc gt 0) then glat(li,wlat,j)=-1.0e+31
            endif
       endelse
    endfor

  endif
; Compute Fixed Sun position
 if(SUN) then begin 
  SUN,IYR,IDAY,IHOUR,MIN,ISEC,GST,SLONG,SRASN,SDEC,epoch=edat(j)
  p=[cos(sdec)*cos(srasn),cos(sdec)*sin(srasn),sin(sdec)]
  geigeo,p(0),p(1),p(2),xgeo,ygeo,zgeo,1,epoch=edat(j)
  sunln=atan2d(ygeo,xgeo)
  sunlt=atan2d(zgeo,sqrt(xgeo*xgeo+ygeo*ygeo))
  sunln=sunln+180
  if(sunln gt 180.0) then sunln = sunln - 360.0
    if(centerlat gt 0.0) then CENTERLONLAT=[sunln,90.0] else $
                                       CENTERLONLAT=[sunln,-90.0]
 endif

; Derive day-night terminator
 if(TERMINATOR) then begin
  SUN,IYR,IDAY,IHOUR,MIN,ISEC,GST,SLONG,SRASN,SDEC,epoch=edat(j)
  p=[cos(sdec)*cos(srasn),cos(sdec)*sin(srasn),sin(sdec)]
  geigeo,p(0),p(1),p(2),xgeo,ygeo,zgeo,1,epoch=edat(j)
  sunlon=atan2d(ygeo,xgeo)
  sunlat=atan2d(zgeo,sqrt(xgeo*xgeo+ygeo*ygeo))
  s=terminator(sunlat,sunlon)
 endif

;     position=[x0,y0,x1,y1]
    if(CENTERPOLE) then begin
     if(MLT_IMAGE) then begin
;; Convert to MLT
      msz=size(glat)
      xdim=msz(1)
      ydim=msz(2)
      mlat=fltarr(xdim,ydim)
      mlon=fltarr(xdim,ydim)
      galt=120.0+6378.16
      cdf_epoch, edat(j), yr,mn,dy,hr,min,sec,milli,/break
      ical,yr,doy,mn,dy,/idoy
      sod=long(hr*3600.0+min*60.+sec)

      for li=0,xdim-1 do begin
       for lj=0,ydim-1 do begin
        dum2 =  float(glat(li,lj,j))
        dum3 =  float(glon(li,lj,j))
        opos = eccmlt(yr,doy,sod,galt,dum2,dum3)
        ;opos = eccmlt(yr,doy,sod,galt,glat(li,lj,j),glon(li,lj,j))
        mlat(li,lj)=opos(1)
        mlon(li,lj)=opos(2)*15.0
;TJK - the following code was  replaced - made consistent w/ plot_map_images
;which Rita corrected earlier in the year... 7/30/2003
;        if(descriptor(0) eq "UVI") then $
;          ;if(mlat(li,lj) lt 50.0) then idat(li,lj,j)=0 & mmlat=50.0
;          if(mlat(li,lj) lt 40.0) then idat(li,lj,j)=0 & mmlat=40.0
;        if(descriptor(0) eq "VIS") then $
;          if(mlat(li,lj) lt 40.0) then idat(li,lj,j)=0 & mmlat=40.0

         if(descriptor(0) eq "UVI" or descriptor(0) eq "VIS") then begin
	   if (centerlat gt 0) then begin
	     CENTERLONLAT=[180.0,90.0]
	     if (mlat(li,lj) lt 40.0) then idat(li,lj,j)=0
	   endif else begin
	     CENTERLONLAT=[180.0,-90.0]
	     if (mlat(li,lj) gt -40.0) then idat(li,lj,j)=0
	   endelse
	 endif
       endfor
      endfor

;TJK 7/30/2003 added this next if/endif section to be consistent w/ 
;plot_map_images

      if(descriptor(0) eq "UVI" or descriptor(0) eq "VIS") then begin
	if centerlat gt 0 then thisrangelonlat=[40.,-180.,90.,180.] else $
	thisrangelonlat=[-90.,-180.,-40.,180.]
      endif

      mag_lt=mlon-180.D0
      wcg=where(mag_lt ge 180.D0,wcgn)
      if(wcgn gt 0) then mag_lt(wcg)=mag_lt(wcg)-360.D0
      wcg=where(mag_lt lt -180.D0,wcgn)
      if(wcgn gt 0) then mag_lt(wcg)=mag_lt(wcg)+360.D0
;TJK - 7/31/2003 - changed some of the keyword values to match what's done
;in plot_map_images
;      auroral_image, idat(*,*,j), mag_lt, mlat, method="PL",/mltgrid,$
;      centerLonLat=CENTERLONLAT, /nocolorbar,/CENTERPOLE,proj=6, $
;      fillValue=0B, $
;      rangeLonLat=[mmlat,-180.,90.,180.], $
;      SYMSIZE=1.2, mapCharSize=1.5, status=status
;print, 'calling 1st auroral_image w/ no continents ****'
;TJK 3/30/2004 added use of Mlinethick and glinethick keywords - they are
;passed from "xtra" keyword and used by the map_continent and map_grid
;routines to increase the line thickness.
      auroral_image, idat(*,*,j), mag_lt, mlat, method="PL",/mltgrid,$
      centerLonLat=CENTERLONLAT, /nocolorbar,/CENTERPOLE,proj=map_proj, $
      fillValue=-1.0e+31,$
      rangeLonLat=thisrangelonlat,mapcolor=mapcolor,$
      SYMSIZE=0.5, mapCharSize=0.5, status=status, MLINETHICK=2, GLINETHICK=1.5

;TJK - not sure we need to return below, seems to me we should just keep going
; and generate the next valid image...
      if(status lt 0) then begin
	print, 'MLT Auroral_image failed, status = ',status ;TJK debug 
	return, -1 ; TJK changed from 0 to -1
      endif
; end MLT
   endif else begin

;print, 'calling 2nd auroral_image w/ continents ****'
;TJK 3/30/2004 added use of Mlinethick and glinethick keywords - they are
;passed from "xtra" keyword and used by the map_continent and map_grid
;routines to increase the line thickness.

;TJK 1/30/2009 add a bit of code to handle the GPS data
;we want the data smoothed so use method PO
;and the longs and lats are NRV variables so they don't
;have the traditional 3 dimensions
    method = "PL"
    proj = strmid(project,0,3)
    imagedata = idat(*,*,j)
    if (proj eq 'GPS') then begin
       method = "PO" 
       longitude = glon(*,j)
       latitude = glat(*,j)
    endif else begin
       longitude = glon(*,*,j)
       latitude = glat(*,*,j)
    endelse

    auroral_image, imagedata, longitude, latitude, method=method,/grid,$
             centerLonLat=CENTERLONLAT, /nocolorbar,/CENTERPOLE,proj=map_proj,$
             /CONTINENT,fillValue=-1.0e+31,SYMSIZE=0.5,label=2,mapcolor=mapcolor,$
             rangeLonLat=[btlat,-180.,btpole,180.],status=status, MLINETHICK=2, GLINETHICK=1.5
   projection='azimuthal projection'

; end pole-centered
   endelse
    endif else begin
; Test section of code for static image map display w/ distorted continental
; boundries
     if(FIXED_IMAGE) then begin
; 
      if(descriptor(0) eq 'UVI') then begin
       att=double(attit(*,j))
       orb=double(gpos(*,j))
       if(sys(j) lt 0) then system=sys(j)+3 else system=sys(j)
       filter=fix(filt(j))-1
       dsp_angle=double(dsp(j))
       xpos1=30.
       ypos1=60.
       nxpix=200
       nypix=228
       xpimg = nypix*1.6
       ypimg = nypix*1.6
       x_img_org = xpos1 + ( (xs - xpimg)/6 )
       x_img_org = xpos1+30.
       y_img_org = ypos1 + ( (ys - ypimg)/6 )
       y_img_org = ypos1

       pos = [x_img_org, y_img_org,x_img_org+xpimg, y_img_org+ypimg]

      grid_uvi,orb,att,dsp_angle,filter,system,idat(*,*,j),pos,xpimg,ypimg,$
             edat(j),s,nxpix,nypix,/GRID,/CONTINENT,/POLE,/TERMINATOR,$
             /LABEL,SYMSIZE=1.0,/device

;
; Two other lines that were here
;      ypimg=ythb-label_space
; Use device coordinates for Map overlay thumbnails
;      xspm=float(xthb)  
;      yspm=float(ythb-label_space)  
;      yi= (ys+30) - label_space ; initial y point
;      x0i=2.5         ; initial x point 
;      y0i=yi-yspm         
;      x1i=2.5+xspm       
;      y1i=yi
;; Set new positions for each column and row
;      ;x0=x0i+icol*xspm
;;      x0=x0i+xspm
;      ;y0=y0i-(irow*yspm+irow*label_space)
;;      y0=y0i-(yspm+label_space)
;      ;x1=x1i+icol*xspm
;;      x1=x1i+xspm
;      ;y1=y1i-(irow*yspm+irow*label_space)
;      y1=y1i-(yspm+label_space)
;      x0=30.
;      y0=45.
;      x1=xs-x0
;      y1=ys-y0
;;      position=[x0,y0,x1,y1]
;;
;      pos=position
;
   endif else begin ; VIS and everything else
 
      ;xpos1=30.
      xpos1=40.
      ypos1=40.
      xpimg=xs-60 ;isize(1)-40
      ypimg=ys-60 ;isize(2)-40
      ;x_img_org = xpos1+30.
      x_img_org = xpos1
      y_img_org = ypos1

      pos = [x_img_org, y_img_org,x_img_org+xpimg, y_img_org+ypimg]

; Must add POLE_S and POLE_N keywords
      if(centerlat gt 0.0) then begin
        grid_map,glat(*,*,j),glon(*,*,j),idat(*,*,j),pos,s,xpimg,ypimg,$ 
                 /LABEL,/GRID,c_thick=1.0,/POLE_N,/device,c_charsize=1.5
      endif else begin
        grid_map,glat(*,*,j),glon(*,*,j),idat(*,*,j),pos,s,xpimg,ypimg,$
                /LABEL,/GRID,c_thick=1.0,/POLE_S,/device,c_charsize=1.5
      endelse
     endelse ; descriptor condition

      projection='rendered projection'

;end new test section FIXED_IMAGE
     endif else begin
        if (map_proj eq 8 and project eq 'TIMED') then begin
             CenterLonLat=[0.,-90] ;show whole earth w/ both poles
        endif

;print, 'calling 3rd auroral_image w/ continents ****'
;TJK 3/30/2004 added use of Mlinethick and glinethick keywords - they are
;passed from "xtra" keyword and used by the map_continent and map_grid
;routines to increase the line thickness.

;TJK added /continents below on 2/25/2004

;TJK 12/18/2008 add a bit of code to handle the GPS data
;we want the data smoothed so use method PO
;and the longs and lats are NRV variables so they don't
;have the traditional 3 dimensions

           method = "PL"
           proj = strmid(project,0,3)
           imagedata = idat(*,*,j)
           if (proj eq 'GPS') then begin
               method = "PO" 
               longitude = glon(*,j)
               latitude = glat(*,j)
               nogrid = 1 ;grids for the GPS data in movies doesn't work well, so removed.
           endif else begin
               longitude = glon(*,*,j)
               latitude = glat(*,*,j)
               nogrid = 0 ;we want the grid
           endelse


;TJK 12/18/2008 send in either a 3-d or 2-d array and allow a differnt
;method to be passed in.
;        auroral_image, idat(*,*,j), glon(*,*,j), glat(*,*,j), $
;        method="PL", /nogrid, centerLonLat=CENTERLONLAT, proj=map_proj,$

        auroral_image, imagedata, longitude, latitude, $
        method=method, nogrid=nogrid, centerLonLat=CENTERLONLAT, proj=map_proj,$
        /nocolorbar, position=position,fillValue=-1.0e+31,SYMSIZE=0.5,$
        status=status,label=2, central_azimuth=central_azimuth, $
	rangelonlat=thisrangelonlat, mapcolor=mapcolor, /continents, $
	MLINETHICK=2, GLINETHICK=1.5
     endelse
    endelse

; Plot terminator
  if(NOT FIXED_IMAGE) then begin
   if(TERMINATOR) then plots,s.lon,s.lat,color=foreground,thick=1.0          
  endif

; Print pole descriptor 
;  lab_pos=tsize-35.0
;  lab_pos1=tsize-25.0
; if(centerlat gt 0.0) then pole='N' else pole='S'
  ;xyouts, xpos, ypos-2, pole, color=!d.n_colors-1, /DEVICE ;
; xyouts, xpos, ypos-lab_pos, pole, color=!d.n_colors-1, charsize=1.2, /DEVICE 

; Print time tag
     edate = decode_cdfepoch(edat(j)) ;TJK get date for this record
     shortdate = strmid(edate, 10, strlen(edate)) ; shorten it

    project_subtitle,astruct.(0),window_title,/IMAGE,TIMETAG=edat(j),$
                     TCOLOR=foreground


; RTB 10/96 add colorbar
if COLORBAR then begin
  if (n_elements(cCharSize) eq 0) then cCharSize = 0.
   cscale = [idmin, idmax]  ; RTB 12/11
  xwindow = !x.window
  !y.window(1)=!y.window(1)
 
  !x.window(1)=0.858
  !y.window=[0.1,0.9]
  offset = 0.01
  colorbar, cscale, ctitle, logZ=0, cCharSize=cCharSize, $ 
        position=[!x.window(1)+offset,      !y.window(0),$
                  !x.window(1)+offset+0.02, !y.window(1)],$
        fcolor=foreground, /image

  !x.window = xwindow
endif ; colorbar

; tvrd images into a array, then write to mpeg file and save
; device close ??

     image = tvrd()
     tvlct, r,g,b, /get ; It's redundant to do this inside the for-loop!!

; MPEG code now defunct; using animated GIFs instead.
;     ii = bytarr(3,(xs+xco),(ys+40))
;     ii(0,*,*) = r[image]
;     ii(1,*,*) = g[image]
;     ii(2,*,*) = b[image]
;     mpeg_put, mpegID, IMAGE=ii, FRAME=j, ORDER=1
     write_mgif, GIF, image, r, g, b, delay=(100/movie_frame_rate), loop=movie_loop

     if keyword_set(GIF) then device, /close
  endfor

  write_mgif, GIF, /close

; Add descriptive MESSAGE to for  parse.ph to parse along w/ the plot etc
; TJK 5/14/2004 - only have this text for non-cassini like projections

if (map_proj ne 9) then begin
    if(CENTERPOLE) then begin
     if(SUN) then $
     print, 'MESSAGE= POLE CENTERED MAP IMAGES - Fixed Sun (Geo. pole = white dot; N or S = hemisphere)'  else $
     print, 'MESSAGE= MLT MAP IMAGES (GM pole = white dot; N or S = hemisphere)'
     ;print, 'MESSAGE= POLE CENTERED MAP IMAGES (Geo. pole = white dot; N or S =hemisphere)'
    endif else begin
     if(FIXED_IMAGE) then $
     print, 'MESSAGE= MAP OVERLAY (Geo. pole = white dot; N or S = hemisphere)'$
     else $
     print, 'MESSAGE= MAP IMAGES (Geo. pole = white dot; N or S = hemisphere)'
    endelse
endif

  !x.margin=xmargin
  if keyword_set(GIF) then deviceclose

  endif else begin
    ; no data available - write message to gif file and exit
    print,'STATUS=No data in specified time period.'
    if keyword_set(GIF) then begin
      xyouts,xs/2,ys/2,/device,alignment=0.5,color=foreground,$
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
