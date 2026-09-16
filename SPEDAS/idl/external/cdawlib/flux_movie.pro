;$author: $ 
;$Date: 2014-07-10 10:01:21 -0700 (Thu, 10 Jul 2014) $
;$Header: /home/cdaweb/dev/control/RCS/flux_movie.pro,v 1.20 2006/05/08 14:55:51 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 15545 $
;+------------------------------------------------------------------------
; NAME: FLUX_MOVIE
; PURPOSE: To generate mpeg "flux" IMAGE movie files given in the 
; input parameter, astruct.
;
; CALLING SEQUENCE:
;       out = flux_movie(astruct,vname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;       vname   = name of the variable in the structure to plot
;
; KEYWORD PARAMETERS:
;       XSIZE     = x size of single frame
;       YSIZE     = y size of single frame
;       GIF       = name of mpeg file to send output to
;       REPORT    = name of report file to send output to
;       TSTART    = time of frame to begin imaging, default = first frame
;       TSTOP     = time of frame to stop imaging, default = last frame
;       NONOISE   = eliminate points outside 3sigma from the mean
;       CDAWEB    = being run in cdaweb context, extra report is generated
;       DEBUG    = if set, turns on additional debug output.
;       COLORBAR = calls function to include colorbar w/ image
;       LIMIT = if set, limit the number of movie frames allowed -
;       this is the default for CDAWEB
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;	Tami Kovalick, Raytheon ITSS, Jan. 2, 2001 - this program is based on the plot_images
;	program originally written by R. Burley.  It is being modified to generate an mpeg movie
;	file.
;
; MODIFICATION HISTORY:
;
;-------------------------------------------------------------------------
FUNCTION flux_movie, astruct, vname, $
                      XSIZE=XSIZE, YSIZE=YSIZE, GIF=GIF, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                      CDAWEB=CDAWEB,DEBUG=DEBUG,COLORBAR=COLORBAR, $
                      MOVIE_FRAME_RATE=MOVIE_FRAME_RATE, MOVIE_LOOP=MOVIE_LOOP, $
		      LIMIT=LIMIT, SMOOTH=SMOOTH

; Determine the field number associated with the variable 'vname'
w = where(tag_names(astruct) eq strupcase(vname),wc)
if (wc eq 0) then begin
  print,'ERROR=No variable with the name:',vname,' in param 1!' & return,-1
endif else vnum = w(0)

if n_elements(movie_frame_rate) eq 0 then movie_frame_rate = 3
if n_elements(movie_loop) eq 0 then movie_loop = 1 ; default is "on"

Zvar = astruct.(vnum)
if keyword_set(COLORBAR) then COLORBAR=1L else COLORBAR=0
;changed xco from 80 to 100 TJK - 7/16/2001 - so color bar isn't so close to
;image.

if COLORBAR  then xco=100 else xco=0 ; No colorbar

if keyword_set(SMOOTH) then SMOOTH=1L else SMOOTH=0L

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


if keyword_set(XSIZE) then xs=XSIZE else xs=512
if keyword_set(YSIZE) then ys=YSIZE else ys=512

;by default want to limit the number of frames in a movie
;but if explicitly set to zero, then don't apply limits
if (n_elements(LIMIT) gt 0) then begin
  if keyword_set(LIMIT) then LIMIT = 1L else LIMIT = 0L
endif else LIMIT=1L

; The DISPLAY_TYPE attribute may contain the THUMBSIZE  RTB
; The THUMBSIZE must be followed by the size in pixels of the images
; If THUMBSIZE is present in the display_type attribute, its value will
; override xsize and ysize keywords specified in the code.
  wc=where(keywords eq 'THUMBSIZE',wcn)
  if(wcn ne 0) then begin
	THUMBSIZE = fix(keywords(wc(0)+1))
	xs = thumbsize & ys = thumbsize
  endif
;special check for the size - the underlying s/w cannot generate an image
;for the euv IMAGE data smaller than 140x140.
if (xs lt 140) then xs = 140
if (ys lt 140) then ys = 140

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
  sn = break_mystring(astruct.(vnum).SOURCE_NAME,'>')
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

isize = size(idat)
if (isize(0) eq 2) then n_images=1 else n_images=isize(isize(0))

if (n_images eq 1) then FRAME=1

if keyword_set(FRAME) then begin ; produce plot of a single frame
  if ((FRAME ge 1)AND(FRAME le n_images)) then begin ; valid frame value
    print, 'ERROR= Single movie frame found'
    print, 'STATUS= Single movie frame; select longer time range.'
    return, -1
  endif

endif else begin ; produce gifs of all images

;if the number of frames requested exceeds 200 send an error message to the user.
if keyword_set(DEBUG) then begin
  print, 'Number of images requested = ',n_images
endif

;TJK 4/20/2006 - added check for LIMIT keyword - so that we can turn
;                this off for CDFX use and private use outside of
;                CDAWeb.

if (n_images gt 200 and LIMIT) then begin
    print, 'ERROR= Too many movie frames requested.'
    print, 'STATUS= Too many movie frames requested (over 200); select shorter time range.'
    return, -1
endif

;Open movie file.

;mpegID = mpeg_open([xs+xco,ys+40])


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

;TJK try not taking out the higher values and just scale them in.

    w = where((idat gt zvmax),wc)
    if wc gt 0 then begin
     if keyword_set(DEBUG) then print,'WARNING=setting ',wc,' fill values in image data to red...'
;      print, 'values are: ',idat(w)
      idat(w) = zvmax -1; set pixels to red
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
      semiMinMax,idat,zvmin,zvmax,/MODIFIED
      w = where((idat lt zvmin),wc)
      if wc gt 0 then begin
        print,'WARNING=filtering values less than 3-sigma from image data...'
        idat(w) = zvmin ; set pixels to zvmin
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

;TJK commented out for flux image    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)

;The following is code that had to be written with a different methodology than any of 
;our other image display plottypes in order to get the enaflux code integrated easily...
;We're going to cycle through all of the images and create a little gif file for each, then
;we read them back in and place them into one big mpeg file lower down in the code...
;This method is a lot easier than trying to re-write plot_enaflux to work the way we'd want it
;to...  This may perform horribly!  TJK 1/2/2001


win=make_array(2, /integer, value=xs)
win(0) = xs & win(1) = ys


;add case statement to set different spin and polar angles depending on
;which dataset we have - also smooth the HENA data here. TJK 1/29/01
;And make the lena and mena image arrays square.
;TJK 7/20/2001 - remove mena code for making the images square - they
;now come square.

;TJK - 4/24/01 - take the smoothing out of here since Rick has now added
;a keyword to plot_enaflux for smoothing...  CDAWeb sets the smooth keyword
;so we'll just pass it through.

;TJK - 07/13/01 - change to smoothing again.  HENA is the only instrument 
;that has requested smoothing.  So we'll turn it on for them, thus 
;overriding any system setting above.

    case descriptor(0) of
	'EUV' : begin	
		  spin = 84.0
		  polar = 0.6
		  nocircles = 1
		  nodipole = 1
		  nocolorbar = 1
		  noborder = 1
		  reverseorder = 1 ; put back in 9/6/2002 TJK
		  smooth = 0L
    		end
        'HENA': begin 	
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
                  smooth = 1L ;HENA only 
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
	    	  idat = fltarr(12,12,nimages)
 		  for numgif = 0, nimages-1 do begin
		    idat(*,*,numgif) = itmp(18:29,*,numgif)
		  endfor
;TJK 9/6/2002 - Rick changed this...  spin = 98.0
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


for numgif = 0, nimages-1 do begin
  temp_gif = gif + strtrim(string(numgif),2)

;  stat = plot_enaflux(edat(numgif),idat(*,*,numgif), spin, polar, $
;	 pos_dat(*,numgif), spin_dat(*,numgif), 1,win, $
;	 noborder, nocircles, nodipole, $
;	 nocolorbar=nocolorbar, smooth=smooth, temp_gif, reverseorder)	

;TJK added smooth keyword because Rick added it in plot_enaflux 4/24/01
;original settings for EUV	 /noborder, /nocircles, /nodipole, /nocolorbar, gif=temp_gif)	

  if (stat ge 0) then begin ;good image found and put in temp_gif gif file.
    ;store these temporary gif file names into a string array
    if (numgif eq 0) then temp_gifs = temp_gif else temp_gifs = [temp_gifs,temp_gif]
;    print, 'Generated temp gif file w/ just image ',temp_gif
  endif
endfor

; Write out Movie filename, that will contain all the images
  if (no_data_avail eq 0) then begin
   if(reportflag eq 1) then printf,1,'MGIF=',GIF
     print,'MGIF=',GIF
  endif else begin
     if(reportflag eq 1) then printf,1,'MGIF=',GIF ; "I_GIF"??
       print,'MGIF=',GIF
  endelse


;TJK In a loop - read each gif file, then write the image back out to the same gif file
;in order to add the color bar and labeling.  Then read the gif file again and output the 

;print, 'number of images actually created = ',n_elements(temp_gifs)
;4/29/2004 - TJK - since images aren't always successfully created above,
;need to use the number of files created by looking at temp_gifs instead
;of using nimages
;for j = 0, nimages-1 do begin
for j = 0, n_elements(temp_gifs)-1 do begin
	
;  print, 'read image out of gif file named ',temp_gifs(j)
;read the gif file that just contains the image (no labeling)

  read_gif,temp_gifs(j),a ; read the gif 

;  print, '*1 Remove the temporary gif file ',temp_gifs(j)
  cmd = strarr(2)
  cmd(0) = "rm"
  cmd(1) = temp_gifs(j)
  spawn, cmd, /noshell

  ;now use this same name and open it anew, write the image and the colorbar/labels

  deviceopen,6,fileOutput=temp_gifs(j),sizeWindow=[xs+xco,ys+30] 

;change x location from 35 to 30 - TJK 7/17/2001

  tv, a, 30, 30, /DEVICE

  xmargin=!x.margin

  if COLORBAR then begin
    if (!x.omargin(1)+!x.margin(1)) lt 14 then !x.margin(1) = 14
    !x.margin(1) = 14
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

  ; subtitle the plot
  project_subtitle,astruct.(0),window_title,/IMAGE,TIMETAG=edat(j)

; Read the gif file which should now contain labels/colorbar, etc.
; tvrd images into a array, then write to mpeg file and save

;  print, 'now the whole image w labels should be there, read it and write to mpeg'
     image=tvrd()
     tvlct, r,g,b, /get

;     ii=bytarr(3,(xs+xco),(ys+30))
;     ii(0,*,*)=r[image]
;     ii(1,*,*)=g[image]
;     ii(2,*,*)=b[image]
;     mpeg_put, mpegID, IMAGE=ii, FRAME=j, ORDER=1
     write_mgif, GIF, image, r, g, b, delay=(100/movie_frame_rate), loop=movie_loop

     if keyword_set(GIF) then begin 
	deviceclose
	device,/close
     endif

;    print, '*2 Remove the temporary gif file ',temp_gifs(j)
    cmd = strarr(2)
    cmd(0) = "rm"
    cmd(1) = temp_gifs(j)
    spawn, cmd, /noshell

  endfor ;for each image

  write_mgif, GIF, /close

  !x.margin=xmargin


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

  endelse ; if (no_data_avail eq 0)
endelse ; if keyword_set(FRAME)

  ; blank image (Try to clear)
  if keyword_set(GIF) then device,/close

return,0
end
