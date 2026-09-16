;+------------------------------------------------------------------------
; NAME: MOVIE_MAP_IMAGES
; PURPOSE: To plot the map image data given in the input parameter astruct.
;          Can plot as "thumbnails" or single frames.
; CALLING SEQUENCE:
;       out = movie_map_images(astruct,vname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;       vname   = name of the variable in the structure to plot
;
; KEYWORD PARAMETERS:
;    CENTERLATLON = 2 element array of map center [latitude,longitude]
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
FUNCTION movie_map_images, astruct, vname, CENTERLATLON=CENTERLATLON,$
                      THUMBSIZE=THUMBSIZE, FRAME=FRAME, $
                      XSIZE=XSIZE, YSIZE=YSIZE, GIF=GIF, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                      CDAWEB=CDAWEB,DEBUG=DEBUG,COLORBAR=COLORBAR

top = 255
bottom = 0
common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

; Determine the field number associated with the variable 'vname'
w = where(tag_names(astruct) eq strupcase(vname),wc)
if (wc eq 0) then begin
  print,'ERROR=No variable with the name:',vname,' in param 1!' & return,-1
endif else vnum = w(0)

projection='MLT'
Zvar = astruct.(vnum)
if keyword_set(COLORBAR) then COLORBAR=1L else COLORBAR=0L
if COLORBAR  then xco=80 else xco=0 ; No colorbar

; if(NOT keyword_set(CENTERLATLON)) then CENTERLATLON=[0.0,90.0]
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

; Find & Parse DISPLAY_TYPE FOR ancillary map image variables (lat & lon)
  a = tagindex('DISPLAY_TYPE',tag_names(astruct.(vnum)))
  if(a(0) ne -1) then display= astruct.(vnum).DISPLAY_TYPE $
  else begin
    print, 'ERROR= No DISPLAY_TYPE attribute for variable'
  endelse
; Parse DISPLAY_TYPE
  ipts=parse_display_type(display)
  keywords=str_sep(display,'>')  ; keyword 1 or greater 
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

; Assign Sun Position
 TERMINATOR=0L
 sun_name='' 
 if(n_elements(ipts) eq 3) then begin ; Make sure display type has 3 elements
  a = tagindex(strtrim(ipts(2),2),tag_names(astruct))
  if(a(0) ne -1) then begin
     snames=tag_names(astruct)
     sun_name=snames(a(0))
     a1=tagindex('DAT',tag_names(astruct.(a(0))))
      if(a1(0) ne -1) then gci_sun = astruct.(a(0)).DAT $
      else begin
       a2 = tagindex('HANDLE',tag_names(astruct.(a(0))))
       if (a2(0) ne -1) then handle_value,astruct.(a(0)).HANDLE,gci_sun $
       else begin
         print,'ERROR= 4th parameter does not have DAT or HANDLE tag'
         return,-1
       endelse
      endelse
    TERMINATOR=1L
  endif else begin
   print, 'WARNING= ',sun_name,' variable not defined in structure (plot_map_images)'
   TERMINATOR=0L
  endelse
 endif

; Check to see of any keywords are included in the display type
 if(n_elements(keywords) ge 2) then begin
;  if(keywords(1) eq 'CENTERPOLE') then CENTERPOLE=1L else CENTERPOLE = 0L
  wcn=where(keywords eq 'CENTERPOLE',wc)
  if(wcn(0) ge 0) then CENTERPOLE = 1L else CENTERPOLE = 0L
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
window_title = b
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

 mpegID=mpeg_open([xs+xco,ys+40])

; Determine if data is a single image, if so then set the frame
; keyword because a single thumbnail makes no sense
; Define indices of image mid-point
isize = size(idat)
;mid1=isize(1)/2+1
;mid2=isize(2)/2+1
; FRAME = 0 in plotmaster for each new buffer
; if NOT keyword_set(FRAME) then FRAME=0  ; Reset Frame for multiple structures
;                                        ; w/ image data RTB 4/98
if (isize(0) eq 2) then n_images=1 else n_images=isize(isize(0))
if (n_images eq 1) then FRAME=1

if keyword_set(FRAME) then begin ; produce plot of a single frame
  if ((FRAME ge 1)AND(FRAME le n_images)) then begin ; valid frame value
   print, 'ERROR= Single movie frame found'
   print, 'STATUS= Single movie frame; select longer time range.'
   return, -1
  endif

; ******  Produce thumbnails of all images

endif else begin ; produce thumnails of all images
; if the number of frames exceeds 60 send a error message to the user to
; reselect smaller time
  if(n_images gt 60) then begin
   print, 'ERROR= Too many movie frames '
   print, 'STATUS= Movies limited to 60 frames; select a shorter time range.'
   return, -1
  endif
;  if keyword_set(THUMBSIZE) then tsize = THUMBSIZE else tsize = 50
  ;if keyword_set(THUMBSIZE) then tsize = THUMBSIZE else tsize = 100
 ; 5 if(n_elements(THUMBSIZE) gt 0) then tsize = THUMBSIZE else tsize = 100
  ;if(n_elements(THUMBSIZE) gt 0) then tsize = THUMBSIZE else tsize = 166
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
      glat = glat(*,*,start_frame:stop_frame)
      glon = glon(*,*,start_frame:stop_frame)
      isize = size(idat) ; determine the number of images in the data
      if (isize(0) eq 2) then nimages = 1 else nimages = isize(isize(0))
      edat = edat(start_frame:stop_frame)
    endif
  endelse

  ; calculate number of columns and rows of images
  ;ncols = xs / tsize & nrows = (nimages / ncols) + 1
  label_space = 12 ; TJK added constant for label spacing
  ;label_space = 24 ; TJK added constant for label spacing
  ;boxsize = tsize+label_space;TJK added for allowing time labels for each image.
  ;ys = (nrows*boxsize) + 15

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
    if wc gt 0 then begin
      print,'WARNING=setting ',wc,' fill values in image data to black...'
      idat(w) = 0 ; set pixels to black
      w = 0 ; free the data space
      if wc eq npixels then print,'WARNING=All data outside min/max!!'
    endif

;TJK try not taking out the higher values and just scale them in.

    w = where((idat gt zvmax),wc)
    if wc gt 0 then begin
     if keyword_set(DEBUG) then print,'WARNING=setting ',wc,' fill values in image data to red...'
;      print, 'values are: ',idat(w)
      idat(w) = zvmax -1; set pixels to red
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
        idat(w) = zvmax-1 ; set pixels to red
        w = 0 ; free the data space
      endif
    endif

    ; scale to maximize color spread
    idmax=max(idat) & idmin=min(idat) ; RTB 10/96

if keyword_set(DEBUG) then begin
	print, '!d.n_colors = ',!d.n_colors
	print, 'min and max after filtering = ',idmin, ' ', idmax
endif

    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)
    ;idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-3) + 1B

if keyword_set(DEBUG) then begin
	bytmin = min(idat, max=bytmax)
	print, 'min and max after bytscl = ',bytmin, ' ', bytmax
endif

; end changes 12/11 RTB
  ; open the window or gif file
  if keyword_set(GIF) then begin
    GIF1=GIF+"junk"
    deviceopen,6,fileOutput=GIF1,sizeWindow=[xs+xco,ys+40]
      if (no_data_avail eq 0) then begin
       if(reportflag eq 1) then printf,1,'MPEG=',GIF
       print,'MPEG=',GIF
      endif else begin
       if(reportflag eq 1) then printf,1,'MPEG=',GIF
       print,'MPEG=',GIF
      endelse
  endif else begin ; open the xwindow
;    window,/FREE,XSIZE=xs+xco,YSIZE=ys+40,TITLE=window_title
  endelse

xmargin=!x.margin

; generate the thumbnail plots

    irow=0
    icol=0
    for j=0,nimages-1 do begin

     if COLORBAR then begin
      if (!x.omargin(1)+!x.omargin(1)) lt 14 then !x.omargin(1) = 14
;      if (!x.omargin(1)+!x.omargin(1)) lt 24 then !x.omargin(1) = 24
      !x.omargin(1) = 14
;      !x.omargin(1) = 24
      plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
     endif

     ;xpos=icol*tsize
     ;ypos=ys-(irow*tsize+30)
     ;if (irow gt 0) then ypos = ypos-(label_space*irow) ;TJK modify position for labels

; VIS images have alot of garbage 0.0's or fill values
   clat=glat(*,*,j)
   cond = (clat gt -90.1) and (clat lt 90.1)
   wgoo=where(cond,wgoon)
   if(wgoon gt 0) then clat=clat(wgoo)
   wn=where(clat gt 0.01, wzn)
   ws=where(clat lt -0.01, wzs)
   if(wzn ge wzs) then begin
    if(wzn ne 0) then centerlat=clat(wn(wzn/2)) else centerlat=glat(mid1,mid2,j)
   endif else begin
    if(wzs ne 0) then centerlat=clat(ws(wzs/2)) 
   endelse
   ;wz=where(glat(*,*,j) ne 0.0,wzn)
   ;if(wzn ne 0) then clat=clat(wz)
   ;if(wzn ne 0) then centerlat=clat(wz(wc/2)) else centerlat=glat(mid1,mid2,j)
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
          CENTERLATLON=[180.0,90.0] 
          btpole=90.0
          if(descriptor(0) eq "VIS") then btlat=30.0 else btlat=40.0 
          wlat=where(glat(li,*,j) lt btlat,wlatc)
          if(wlatc gt 0) then glat(li,wlat,j)=-1.0e+31
       endif else begin 
          CENTERLATLON=[180.0,-90.0] 
          btpole=-90.0
          if(descriptor(0) eq "VIS") then btlat=-30.0 else btlat=-40.0 
          wlat=where(glat(li,*,j) gt btlat,wlatc)
          if(wlatc gt 0) then glat(li,wlat,j)=-1.0e+31
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
    if(centerlat gt 0.0) then CENTERLATLON=[sunln,90.0] else $
                                       CENTERLATLON=[sunln,-90.0]
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
        if(descriptor(0) eq "UVI") then $
          ;if(mlat(li,lj) lt 50.0) then idat(li,lj,j)=0 & mmlat=50.0
          if(mlat(li,lj) lt 40.0) then idat(li,lj,j)=0 & mmlat=40.0
        if(descriptor(0) eq "VIS") then $
          if(mlat(li,lj) lt 40.0) then idat(li,lj,j)=0 & mmlat=40.0
       endfor
      endfor

      mag_lt=mlon-180.D0
      wcg=where(mag_lt ge 180.D0,wcgn)
      if(wcgn gt 0) then mag_lt(wcg)=mag_lt(wcg)-360.D0
      wcg=where(mag_lt lt -180.D0,wcgn)
      if(wcgn gt 0) then mag_lt(wcg)=mag_lt(wcg)+360.D0

      auroral_image, idat(*,*,j), mag_lt, mlat, method="PL",/mltgrid,$
      centerLonLat=CENTERLATLON, /nocolorbar,/CENTERPOLE,proj=6,fillValue=0B,$
      rangeLonLat=[mmlat,-180.,90.,180.],SYMSIZE=1.2,$
      mapCharSize=1.5,status=status

      if(status lt 0) then return, 0
; end MLT
   endif else begin

    auroral_image, idat(*,*,j), glon(*,*,j), glat(*,*,j),method="PL",/grid,$
                   centerLonLat=CENTERLATLON, /nocolorbar,/CENTERPOLE,proj=6,$
                   /CONTINENT,fillValue=-1.0e+31,SYMSIZE=0.5,label=2,$
                   rangeLonLat=[btlat,-180.,btpole,180.],status=status
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
        auroral_image, idat(*,*,j), glon(*,*,j), glat(*,*,j), $
        method="PL", /nogrid, centerLonLat=CENTERLATLON, $
        /nocolorbar, position=position,fillValue=-1.0e+31,SYMSIZE=0.5,$
        status=status,label=2
     endelse
    endelse

; Plot terminator
  if(NOT FIXED_IMAGE) then begin
   if(TERMINATOR) then plots,s.lon,s.lat,color=!d.n_colors-1,thick=1.0          
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
                     TCOLOR=!d.n_colors-1


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
        fcolor=!d.n_colors-1, /image

  !x.window = xwindow
endif ; colorbar

; tvrd images into a array, then write to mpeg file and save
; device close ??
     image=tvrd()
     tvlct, r,g,b, /get
     ii=bytarr(3,(xs+xco),(ys+40))
     ii(0,*,*)=r[image]
     ii(1,*,*)=g[image]
     ii(2,*,*)=b[image]
     mpeg_put, mpegID, IMAGE=ii, FRAME=j, ORDER=1
    if keyword_set(GIF) then device, /close
 endfor
     mpeg_save, mpegID, FILENAME=GIF
     mpeg_close, mpegID

;
; Add descriptive MESSAGE to for  parse.ph to parse along w/ the plot etc
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

  !x.margin=xmargin
  if keyword_set(GIF) then deviceclose

  endif else begin
    ; no data available - write message to gif file and exit
    print,'STATUS=No data in specified time period.'
    if keyword_set(GIF) then begin
      xyouts,xs/2,ys/2,/device,alignment=0.5,color=!d.n_colors-1,$
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

