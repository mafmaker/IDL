;$Author: jimm $ 
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/movie_images.pro,v 1.23 2006/04/13 16:08:36 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $
;+------------------------------------------------------------------------
; NAME: MOVIE_IMAGES
; PURPOSE: To plot the image data given in the input parameter astruct
;          as a mpeg movie.
; CALLING SEQUENCE:
;       out = plotmaster(astruct,vname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;       vname   = name of the variable in the structure to plot
;
; KEYWORD PARAMETERS:
;       FRAME     = individual frame to plot
;       XSIZE     = x size of single frame
;       YSIZE     = y size of single frame
;       GIF       = name of gif file to send output to
;       REPORT    = name of report file to send output to
;       TSTART    = time of frame to begin imaging, default = first frame
;       TSTOP     = time of frame to stop imaging, default = last frame
;       NONOISE   = eliminate points outside 3sigma from the mean
;       CDAWEB    = being run in cdaweb context, extra report is generated
;       LIMIT = if set, limit the number of movie frames allowed -
;       this is the default for CDAWEB
;       DEBUG    = if set, turns on additional debug output.
;       COLORBAR = calls function to include colorbar w/ image
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       Richard Baldwin, NASA/GSFC/Code 632.0, 
; MODIFICATION HISTORY:
;      09/30/98 : R. Baldwin   : Initial version 
;-------------------------------------------------------------------------
FUNCTION movie_images, astruct, vname, $
                      THUMBSIZE=THUMBSIZE, FRAME=FRAME, $
                      XSIZE=XSIZE, YSIZE=YSIZE, GIF=GIF, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                      MOVIE_FRAME_RATE=MOVIE_FRAME_RATE, $
                      MOVIE_LOOP=MOVIE_LOOP, LIMIT=LIMIT,$
                      CDAWEB=CDAWEB,DEBUG=DEBUG,COLORBAR=COLORBAR


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

Zvar = astruct.(vnum)
if keyword_set(COLORBAR) then COLORBAR=1L else COLORBAR=0L
if COLORBAR  then xco=80 else xco=0 ; No colorbar

 if keyword_set(REPORT) then reportflag=1L else reportflag=0L

;by default want to limit the number of frames in a movie
;but if explicitly set to zero, then don't apply limits
if (n_elements(LIMIT) gt 0) then begin
  if keyword_set(LIMIT) then LIMIT = 1L else LIMIT = 0L
endif else LIMIT=1L


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

; Determine the title for the window or gif file
a = tagindex('SOURCE_NAME',tag_names(astruct.(vnum)))
if (a(0) ne -1) then b = astruct.(vnum).SOURCE_NAME else b = ''
a = tagindex('DESCRIPTOR',tag_names(astruct.(vnum)))
if (a(0) ne -1) then b = b + '  ' + astruct.(vnum).DESCRIPTOR
window_title = b
if keyword_set(nonoise) then window_title=window_title+'!CConstrained values within >3-sigma from mean of all plotted values'

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

;TJK added on 4/9/2001 so that we can transpose to UVI h2 and h3 data
a = tagindex('DATA_TYPE',tag_names(astruct.(vnum)))
if (a(0) ne -1) then begin
   b = b + '  ' + astruct.(vnum).DATA_TYPE
   d_type = strupcase(str_sep((astruct.(vnum).DATA_TYPE),'>')) ;TJK added 4/9/02, used below
endif

; mpegID=mpeg_open([xs+xco,ys+40])

; Determine if data is a single image, if so then set the frame
; keyword because a single thumbnail makes no sense
isize = size(idat)
if (isize(0) eq 2) then n_images=1 else n_images=isize(isize(0))
if (n_images eq 1) then FRAME=1

if keyword_set(FRAME) then begin ; produce plot of a single frame
  if ((FRAME ge 1)AND(FRAME le n_images)) then begin ; valid frame value
   print, 'ERROR= Single movie frame found'
   print, 'STATUS= Single movie frame; select longer time range.'
   return, -1
  endif

; ******  Produce movie of all images

endif else begin ; produce thumnails of all images

; if the number of frames exceeds 60 send a error message to the user to
; reselect smaller time
; 1/26/2006 - increase the limit to 200 (new rumba)
;TJK 3/8/2006 - added check for LIMIT keyword - so that we can turn
;                this off for CDFX use and private use outside of
;                CDAWeb.

  if(n_images gt 200 and LIMIT) then begin
   print, 'ERROR= Too many movie frames '
   print, 'STATUS= You have requested ',n_images,' frames.'
   print, 'STATUS= Movies are limited to 200 frames, select a shorter time range.'
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
    if ((start_frame ne 0)OR(stop_frame ne nimages)) then begin
      idat = idat(*,*,start_frame:stop_frame)
      isize = size(idat) ; determine the number of images in the data
      if (isize(0) eq 2) then nimages = 1 else nimages = isize(isize(0))
      edat = edat(start_frame:stop_frame)
    endif
  endelse

  label_space = 12 ; TJK added constant for label spacing

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

if keyword_set(DEBUG) then begin
  print, 'Image valid min and max: ',zvmin, ' ',zvmax 
  wmin = min(idat,MAX=wmax)
  print, 'Actual min and max of data',wmin,' ', wmax
endif

;TJK - 3/19/98 - added checking for fill value.  If found, set
;the fill values to 0, otherwise, if the fill values is greater
;than zvmax, then the values will be included in the image.

    w = where((idat lt zvmin or idat eq zfill),wc)
    if wc gt 0 then begin
      print,'WARNING=setting ',wc,' fill values in image data to validmin...'
;TJK changed for Bob 12/15/2000      idat(w) = 0 ; set pixels to black
      idat(w) = zvmin ; set pixels to black
      w = 0 ; free the data space
      if wc eq npixels then print,'WARNING=All data outside min/max!!'
      if (zvmin le 0 ) then print, 'WARNING=Z validmin <= zero'
    endif

;TJK try not taking out the higher values and just scale them in.

    w = where((idat gt zvmax),wc)
    if wc gt 0 then begin
     if keyword_set(DEBUG) then print,'WARNING=setting ',wc,' fill values in image data to red...'
;TJK 6/24/2004 changed to below      idat(w) = zvmax -1; set pixels to red

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
;TJK 6/24/2004 changed to below        idat(w) = zvmax-1 ; set pixels to red
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

    idat = congrid(idat,(xs-40),(ys-50),nimages)

; scale to maximize color spread
    idmax=max(idat) & idmin=min(idat) ; RTB 10/96

if keyword_set(DEBUG) then begin
	print, '!d.n_colors = ',!d.n_colors
	print, 'min and max after filtering = ',idmin, ' ', idmax
endif

    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)

if keyword_set(DEBUG) then begin
	bytmin = min(idat, max=bytmax)
	print, 'min and max after bytscl = ',bytmin, ' ', bytmax
endif

  ; open the window or gif file
  if keyword_set(GIF) then begin
    GIF1=GIF+"junk"
    deviceopen,6,fileOutput=GIF1,sizeWindow=[xs+xco,ys+40]

      if (no_data_avail eq 0) then begin
       if(reportflag eq 1) then printf,1,'MGIF=',GIF
       print,'MGIF=',GIF
      endif else begin
       if(reportflag eq 1) then printf,1,'MGIF=',GIF ; "I_GIF"??
       print,'MGIF=',GIF
      endelse

  endif else begin ; open the xwindow
    window,/FREE,XSIZE=xs+xco,YSIZE=ys+40,TITLE=window_title
    print,'STATUS=Movie X Windows option not available, please select output to GIF.'
    return, 0
  endelse

xmargin=!x.margin
if COLORBAR then begin
 if (!x.omargin(1)+!x.margin(1)) lt 14 then !x.margin(1) = 14
 !x.margin(1) = 14
 plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
endif

; generate the movie plots

;5/7/01 - turns out the RPI images don't need to be rotated.  Left this code
;in because I'm sure we'll need to do this type of transpose/rotate for some
;other dataset that doesn't have square images...
;TJK - 2/20/97 - if viking images then rotate them 270 degrees, otherwise
; leave them as is.
if (vkluge)then for j=0,nimages-1 do idat(*,*,j) = rotate(idat(*,*,j),7)

;TJK this transpose has to be done image by image... changed on 5/4/01
;    if(descriptor(0) eq 'RPI') then idat = transpose(idat) ;TJK 3/13/01
;If images are square you can get by with using the same array, otherwise not.

;    if(descriptor(0) eq 'RPI') then begin
;	for j=0,nimages-1 do begin
;          if (j eq 0 ) then begin
;            ;set up an array to handle the "trasponsed images"
;            dims = size(idat,/dimensions)
;            idat2 = bytarr(dims(1),dims(0),dims(2))
;	    idat2(*,*,j) = transpose(idat(*,*,j))
;          endif else begin
;	    idat2(*,*,j) = transpose(idat(*,*,j))
;	  endelse
;        endfor
;	idat = idat2
;	idat2 = 0 ;clear this array out
;     endif ;if RPI

; Position each image individually to control layout
    irow=0
    icol=0
    for j=0,nimages-1 do begin

; if VIS rotate RTB
     if(descriptor(0) eq 'VIS') then $
      idat(*,*,j)=rotate(rotate(idat(*,*,j),5),2) ; TJK 2/2009 fix to be consistent w/ the mapped and non-mapped images.
;      idat(*,*,j)=rotate(rotate(idat(*,*,j),5),3) ; RTB 9/98
; UVI primary image fix for times prior to 12/96; RTB 11/98
     if(descriptor(0) eq 'UVI') then begin
      cdf_epoch, edat(j), yr,mn,dy,hr,min,sec,milli,/break
      ical,yr,doy,mn,dy,/idoy
      if(fix(yr) eq 1996) then begin
       if(doy lt 337) then begin
        temp_dat=idat(*,*,j);
        temp_dat=rotate(temp_dat,3)
        idat(*,*,j)=transpose(temp_dat)
       endif
      endif

     if ((d_type(0) eq 'H2') or (d_type(0) eq 'H3')) then begin
        if (j eq 0 ) then begin
        ;set up an array to handle the "trasponsed images"
          dims = size(idat,/dimensions)
          idat2 = bytarr(dims(1),dims(0),dims(2))
        endif
        idat2(*,*,j)=transpose(idat(*,*,j))
      endif


     endif

     xpos=10
     ypos=30
     if ((d_type(0) eq 'H2') or (d_type(0) eq 'H3')) then begin
        tv,idat2(*,*,j),xpos,ypos,/DEVICE
     endif else begin
        tv,idat(*,*,j),xpos,ypos,/DEVICE
     endelse
     edate = decode_cdfepoch(edat(j)) ;TJK get date for this record
;TJK 3/9/2006 - use the full date because we're now generating 
;movies that span many days.
;     shortdate = strmid(edate, 10, strlen(edate)) ; shorten it
;     xyouts, xpos, ypos-10, shortdate, color=!d.n_colors-1, /DEVICE ;
     xyouts, xpos, ypos-8, edate, color=!d.n_colors-1, /DEVICE ;
     icol=icol+1

; Don't need to make a sav file
;    if ((keyword_set(CDAWEB))AND(no_data_avail eq 0)) then begin
;      fname = GIF + '.sav' & save_mystruct,astruct,fname
;    endif

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
  offset = 0.01
  colorbar, cscale, ctitle, logZ=0, cCharSize=cCharSize, $ 
        position=[!x.window(1)+offset,      !y.window(0),$
                  !x.window(1)+offset+0.03, !y.window(1)],$
        fcolor=244, /image

  !x.window = xwindow
endif ; colorbar

; tvrd images into a array, then write to mpeg file and save
; device close ??
     image = tvrd()
     tvlct, r,g,b, /get

;     ii=bytarr(3,(xs+xco),(ys+40))
     ;ii=bytarr(3,640,512)
;     ii(0,*,*)=r[image]
;     ii(1,*,*)=g[image]
;     ii(2,*,*)=b[image]
     ;ii=[[ir],[ig],[ib]]
;     mpeg_put, mpegID, IMAGE=ii, FRAME=j, ORDER=1

     write_mgif, GIF, image, r, g, b, delay=(100/movie_frame_rate), loop=movie_loop

      if keyword_set(GIF) then device,/close
    endfor

    write_mgif, GIF, /close

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

