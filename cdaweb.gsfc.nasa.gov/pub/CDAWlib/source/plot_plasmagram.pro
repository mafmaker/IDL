;$Author: kovalick $ 
;$Date: 2001/05/04 18:31:52 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/plot_plasmagram.pro,v 1.6 2001/05/04 18:31:52 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.6 $
;+------------------------------------------------------------------------
; NAME: PLOT_PLASMAGRAM
; PURPOSE: To plot the image as a plasmagram given the data structure
;	   as returned from read_myCDF.pro
;          Can plot as "thumbnails" or single frames.
; CALLING SEQUENCE:
;       out = plotmaster(astruct,zname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;	zname = name of z variable to plot as a plasmagram.
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
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;	Tami Kovalick, RSTX, March 3, 1998
;	Based on plot_images.pro 
; MODIFICATION HISTORY:
;
;-------------------------------------------------------------------------
FUNCTION evaluate_plasmastruct, a, atags
; determine if there's an display_type attribute for this structure
; and if so, whether it is defined as "plasmagram" or not.  If so, whether
; additional label variables were defined, ie. plasmagram>l1=SM_position,
; l2=mode, etc.  Return a structure w/ these variable names.

; Verify that the input variable is a structure
b = size(a)
if (b(n_elements(b)-2) ne 8) then begin
  print,'ERROR=Input parameter is not a valid structure.' & return,-1
endif

; Attempt to determine the coordinate system based on the display_type 
; attribute values.

b = tagindex('DISPLAY_TYPE',atags)
if (b(0) ne -1) then begin
  c = break_mystring(a.(b(0)),delimiter='>')
  csize = size(c)
  if (csize(1) eq 2)then begin
    d = break_mystring(c(1), delimiter=',')
    if (n_elements(d) ge 1)then begin
      vars = make_array(n_elements(d),/string,value=' ')
      num_found = -1
      for i=0, n_elements(d)-1 do begin
      ;look for all "labl" keywords
        e = break_mystring(d(i), delimiter='=')
        if (n_elements(e) ge 1) then begin
 	  if (strpos(e(0),'labl',0) ne -1) then begin
	    num_found=num_found+1
            vars(num_found) =  e(1)
	  endif
	endif
      endfor

    endif
  endif 
endif 
if (num_found ge 0) then begin
  t = where(vars ne ' ', t_cnt) ; take out the possible blanks
  if (t_cnt ge 1) then vars = vars(t) ; redefine vars
endif

return, vars ;return the list of variables to be used as labels
end  


FUNCTION plot_plasmagram, astruct, zname, $
                      THUMBSIZE=THUMBSIZE, FRAME=FRAME, $
                      XSIZE=XSIZE, YSIZE=YSIZE, GIF=GIF, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                      CDAWEB=CDAWEB,DEBUG=DEBUG,COLORBAR=COLORBAR


; Determine default x, y and z variables from depend attributes
atags = tag_names(astruct)
z_ax = tagindex(zname,atags) ;z axis
b = astruct.(z_ax).DEPEND_0 & epoch = tagindex(b(0),atags) ;epoch
b = astruct.(z_ax).DEPEND_1 & x_ax = tagindex(b(0),atags) ;x axis
b = astruct.(z_ax).DEPEND_2 & y_ax = tagindex(b(0),atags) ;y axis
estruct = astruct.(epoch)
xstruct = astruct.(x_ax)
ystruct = astruct.(y_ax)
zstruct = astruct.(z_ax)

;Look at the display_type to see if there are any special settings.
; Determine if the display type variable attribute is present for Z.
b = tagindex('DISPLAY_TYPE',tag_names(astruct.(z_ax)))
if (b(0) ne -1) then begin
; examine_spectrogram_dt looks at the DISPLAY_TYPE structure member in detail.
; for spectrograms and stacked time series the DISPLAY_TYPE can contain syntax
; like the following: SPECTROGRAM>y=flux(1),y=flux(3),y=flux(5),z=energy
; where this indicates that we only want to plot the 1st, 3rd and 5th energy 
; channel for the flux variable. This routine returns a structure of the form 

e = examine_spectrogram_dt(astruct.(z_ax).DISPLAY_TYPE) & esize=size(e)

  if (esize(n_elements(esize)-2) eq 8) then begin ; results confirmed
    if (e.x ne '') then x_ax = tagindex(e.x,atags)
    if (e.y ne '') then y_ax = tagindex(e.y,atags)
  endif
endif


vname = zstruct.VARNAME ; get the name of the image variable

 ;TJK 3/15/01 - added the check for the descriptor
; Check Descriptor Field for Instrument Specific Settings
tip = tagindex('DESCRIPTOR',tag_names(zstruct))
if (tip ne -1) then begin
  descriptor=str_sep(zstruct.descriptor,'>')
endif

if keyword_set(COLORBAR) then COLORBAR=1L else COLORBAR=0L
if COLORBAR  then xco=80 else xco=0 ; No colorbar

; Open report file if keyword is set
;if keyword_set(REPORT) then begin & reportflag=1L
; a=size(REPORT) & if (a(n_elements(a)-2) eq 7) then $
; OPENW,1,REPORT,132,WIDTH=132
;endif else reportflag=0L
 if keyword_set(REPORT) then reportflag=1L else reportflag=0L

; Verify the type of the first parameter and retrieve the data
a = size(zstruct)
if (a(n_elements(a)-2) ne 8) then begin
  print,'ERROR= Z parameter to plot_plasmagram not a structure' & return,-1
endif else begin
  a = tagindex('DAT',tag_names(zstruct))
  if (a(0) ne -1) then idat = zstruct.DAT $
  else begin
    a = tagindex('HANDLE',tag_names(zstruct))
    if (a(0) ne -1) then handle_value,zstruct.HANDLE,idat $
    else begin
      print,'ERROR= Z parameter does not have DAT or HANDLE tag' & return,-1
    endelse
  endelse
endelse
;print, 'IDAT before transpose'
;help, idat
;transpose_flag = 0L
;if(descriptor(0) eq 'RPI') then begin  ;TJK 3/15/01
;  transpose_flag = 1L
;  print, 'in plot_plasmagram, transposing rpi image array'
;  isize = size(idat) ; determine the number of images in the data
;  if (isize(0) eq 2) then nimages = 1 else nimages = isize(isize(0))
;  if (nimages eq 1) then begin 
;	idat(idat) = transpose(idat)
;  endif else begin
;    for j = 0, nimages-1 do begin
;          if (j eq 0 ) then begin
;            ;set up an array to handle the "transposed images"
;	    ;because these images aren't square you have to use an 
;	    ;intermmediate array.
;            dims = size(idat,/dimensions)
;            idat2 = bytarr(dims(1),dims(0),dims(2))
;	    idat2(*,*,j) = transpose(idat(*,*,j))
;          endif else begin
;	    idat2(*,*,j) = transpose(idat(*,*,j))
;	  endelse
;        endfor
;	idat = idat2
;	idat2 = 0 ;clear this array out
;TJK changed to the above 5/4/01 idat(*,*,j) = transpose(idat(*,*,j))
;  endelse
;endif
;print, 'IDAT after transpose'
;help, idat

; Get 'Epoch' data and retrieve it

d = tagindex('DAT',tag_names(estruct))
if (d(0) ne -1) then edat = estruct.DAT $
else begin
  d = tagindex('HANDLE',tag_names(estruct))
  if (d(0) ne -1) then handle_value,estruct.HANDLE,edat $
  else begin
    print,'ERROR= Time parameter does not have DAT or HANDLE tag' & return,-1
  endelse
endelse

; Get 'X variable' data and retrieve it

xtags = tag_names(xstruct)
d = tagindex('DAT',xtags)
if (d(0) ne -1) then xdat = xstruct.DAT $
else begin
  d = tagindex('HANDLE',xtags)
  if (d(0) ne -1) then handle_value,xstruct.HANDLE,xdat $
  else begin
    print,'ERROR= X variable does not have DAT or HANDLE tag' & return,-1
  endelse
endelse

xlog = 1L ; initialize assuming logarithmic
a = tagindex('SCALETYP',xtags)
if (a(0) ne -1) then begin
   if (strupcase(Xstruct.SCALETYP) eq 'LINEAR') then xlog = 0L
endif

; determine validmin and validmax values for the x variable
a = tagindex('VALIDMIN',xtags)
if (a(0) ne -1) then begin & b=size(xstruct.VALIDMIN)
  if (b(0) eq 0) then xvmin = xstruct.VALIDMIN $
  else begin
    xvmin = 0 ; default for x data
    print,'WARNING=Unable to determine validmin for ',xstruct.varname
  endelse
endif

a = tagindex('VALIDMAX',xtags)
if (a(0) ne -1) then begin & b=size(xstruct.VALIDMAX)
  if (b(0) eq 0) then xvmax = xstruct.VALIDMAX $
  else begin
    xvmax = 2000 ; guesstimate
    print,'WARNING=Unable to determine validmax for ',xstruct.varname
  endelse
endif

;determine x axis label
a = tagindex('LABLAXIS',xtags)
if (a(0) ne -1) then begin & b=size(xstruct.LABLAXIS)
  if (b(0) eq 0) then xtitle = xstruct.LABLAXIS $
  else begin
    xtitle = ' x axis' ; default for x data
    print,'WARNING=Unable to determine xtitle for ',xstruct.varname
  endelse
endif
;determine x axis units
a = tagindex('UNITS',xtags)
if (a(0) ne -1) then begin & b=size(xstruct.UNITS)
  if (b(0) eq 0) then xtitle = xtitle + ' in '+ xstruct.UNITS $
  else begin
    xtitle = xtitle  ; default for x data
    print,'WARNING=Unable to determine units for ',xstruct.varname
  endelse
endif


; Get 'Y variable' data and retrieve it

ytags = tag_names(ystruct)
d = tagindex('DAT',ytags)
if (d(0) ne -1) then ydat = ystruct.DAT $
else begin
  d = tagindex('HANDLE',ytags)
  if (d(0) ne -1) then handle_value,ystruct.HANDLE,ydat $
  else begin
    print,'ERROR= Y variable does not have DAT or HANDLE tag' & return,-1
  endelse
endelse

ylog = 1L ; initialize assuming logarithmic
a = tagindex('SCALETYP',ytags)
if (a(0) ne -1) then begin
   if (strupcase(Ystruct.SCALETYP) eq 'LINEAR') then ylog = 0L
endif

; determine validmin and validmax values for the y variable
a = tagindex('VALIDMIN',ytags)
if (a(0) ne -1) then begin & b=size(ystruct.VALIDMIN)
  if (b(0) eq 0) then yvmin = ystruct.VALIDMIN $
  else begin
    yvmin = 0 ; default for y data
    print,'WARNING=Unable to determine validmin for ',ystruct.varname
  endelse
endif

a = tagindex('VALIDMAX',ytags)
if (a(0) ne -1) then begin & b=size(ystruct.VALIDMAX)
  if (b(0) eq 0) then yvmax = ystruct.VALIDMAX $
  else begin
    yvmax = 2000 ; guesstimate
    print,'WARNING=Unable to determine validmax for ',ystruct.varname
  endelse
endif


;determine y axis label
a = tagindex('LABLAXIS',ytags)
if (a(0) ne -1) then begin & b=size(ystruct.LABLAXIS)
  if (b(0) eq 0) then ytitle = ystruct.LABLAXIS $
  else begin
    ytitle = ' y axis' ; default for x data
    print,'WARNING=Unable to determine ytitle for ',ystruct.varname
  endelse
endif
;determine y axis units
a = tagindex('UNITS',ytags)
if (a(0) ne -1) then begin & b=size(ystruct.UNITS)
  if (b(0) eq 0) then ytitle = ytitle + ' in '+ ystruct.UNITS $
  else begin
    ytitle = ytitle  ; default for y data
    print,'WARNING=Unable to determine units for ',ystruct.varname
  endelse
endif


; Determine the title for the window or gif file
ztags = tag_names(zstruct)
a = tagindex('CATDESC',ztags)
if (a(0) ne -1) then fn = '> ' + zstruct.CATDESC else fn = ''
a = tagindex('SOURCE_NAME',ztags)
if (a(0) ne -1) then b = zstruct.SOURCE_NAME else b = ''
a = tagindex('DESCRIPTOR',ztags)
if (a(0) ne -1) then b = b + '  ' + zstruct.DESCRIPTOR
window_title = b + fn

; Get extra labels from the display type - if it exists

label_vars = evaluate_plasmastruct(zstruct, ztags)
if (n_elements(label_vars) ge 1) then begin ; get all of the extra label data
  for l = 0, n_elements(label_vars)-1 do begin
    l_str = strtrim(string(l),2);convert the index to string
    lab = tagindex(label_vars(l),atags) ;find label variable in astruct
    comm=execute('lstruct'+l_str+' = astruct.(lab)')
    
    comm=execute('ltags = tag_names(lstruct'+l_str+')')
    d = tagindex('DAT',ltags)
    if (d(0) ne -1) then comm=execute('ldat = lstruct'+l_str+'.DAT') $
    else begin
      d = tagindex('HANDLE',ltags)
      if (d(0) ne -1) then comm=execute('handle_value,lstruct'+l_str+'.HANDLE,ldat'+l_str) $
      else begin
        print,'ERROR= Label variable does not have DAT or HANDLE tag' & return,-1
      endelse
    endelse

    if (not comm) then print, 'Error=execute for labels failed'

    ;now get the fieldname that goes w/ this data
    comm = execute('ltitle'+l_str+'=''')
    a = tagindex('FIELDNAM',ltags)
    if (a(0) ne -1) then comm = execute('ltitle'+l_str+' = lstruct'+l_str+'.FIELDNAM')

    a = tagindex('LABLAXIS',ltags)
    if (a(0) ne -1) then begin
	comm = execute('temp = lstruct'+l_str+'.LABLAXIS')
	if(temp(0) ne '') then comm = execute('ltitle'+l_str+' = lstruct'+l_str+'.LABLAXIS')
    endif

    a = tagindex('LABL_PTR_1',ltags)
    if (a(0) ne -1) then begin
	comm = execute('temp = lstruct'+l_str+'.LABL_PTR_1')
        if (temp(0) ne '') then comm = execute('ltitle'+l_str+' = lstruct'+l_str+'.LABL_PTR_1')
    endif

  endfor
endif ;getting label data

; Determine title for colorbar
if(COLORBAR) then begin
 ctitle=''
 a = tagindex('LABLAXIS',ztags)
 if (a(0) ne -1) then ctitle = zstruct.LABLAXIS
 a=tagindex('UNITS',ztags)
 if(a(0) ne -1) then ctitle = ctitle + ' in ' + zstruct.UNITS 
endif

if keyword_set(XSIZE) then xs=XSIZE else xs=512
if keyword_set(YSIZE) then ys=YSIZE else ys=512

; Determine if data is a single image, if so then set the frame
; keyword because a single thumbnail makes no sense
isize = size(idat)
if (isize(0) eq 2) then n_images=1 else n_images=isize(isize(0))

if (n_images eq 1) then FRAME=1

;Produce blown up single image plot

if keyword_set(FRAME) then begin ; produce plot of a single frame
  if ((FRAME ge 1)AND(FRAME le n_images)) then begin ; valid frame value
    idat = idat(*,*,(FRAME-1)) ; grab the frame
    idat = reform(idat) ; remove extraneous dimensions
    xdat = xdat(*,(FRAME-1)) ; grab just the one frame
    xdat = reform(xdat) ; remove extraneous dimensions
    ydat = ydat(*,(FRAME-1)) ; grab just the one frame
    ydat = reform(ydat) ; remove extraneous dimensions
    isize = size(idat) ; get the dimensions of the image
;TJK commented this section out since we really don't want the dimensions of
;the window changing based on the dimensions of the data...  Just use 
;either what the XSIZE/YSIZE keywords are set to, or default of 512x512
;
;    r1 = ceil(500/isize(1)) ; determine ratio for first dimension
;    r2 = ceil(500/isize(2)) ; determine ratio for second dimension
;    xs = ceil(isize(1)*r1)+100 ; determine xsize of window (changed additional from 50 to 100)
;    ys = ceil(isize(2)*r2)+5 ; determine ysize of window (changed from 15 to 5)
;TJK - dont' want to change the size
;    idat = rebin(idat,(isize(1)*r1),(isize(2)*r2)) ; resize the image

; screen x axis non-positive data values if creating a logarithmic plot
if (xlog eq 1L) then begin
  if (xvmin gt 0.0) then amin = xvmin else amin = 0.0
  w = where(xdat le amin,wc)
  if (wc gt 0) then begin
    w = where(xdat gt amin,wc)
    if (wc gt 0) then begin
     if keyword_set(DEBUG) then print,'Screening ',wc, 'non-positive values.'
;     xdat = xdat(w) & idat = idat(*,w,*) & w=0
     ;get the actual min value
     amin = min(xdat(w), max=xvmax) ;determine min/max w/o negative out of
				   ;range values
     if (xlog eq 1L and xvmin le 0) then xvmin = amin ;xvmin can't be zero
    endif
  endif
endif else begin
  w = where((xdat gt xvmin and xdat lt xvmax), wc)
  if (wc gt 0) then xvmin = min(xdat(w), max=xvmax)
  if (wc le 0) then begin
	xvmin = 0 & xvmax = 1
  endif
endelse

print, 'DEBUG, X min and max scales = ',xvmin, xvmax

; screen y axis non-positive data values if creating a logarithmic plot
if (ylog eq 1L) then begin
  if (yvmin gt 0.0) then amin = yvmin else amin = 0.0
  w = where(ydat le amin,wc)
  if (wc gt 0) then begin
    w = where(ydat gt amin,wc)
    if (wc gt 0) then begin
     if keyword_set(DEBUG) then print,'Screening ',wc, 'non-positive values.'
       ;get the actual min value
       amin = min(ydat(w), max=yvmax)
       if (ylog eq 1L and yvmin le 0) then yvmin = amin ;yvmin can't be zero
;     ydat = ydat(w) & idat = idat(*,w,*) & w=0
    endif
  endif
endif else begin
  w = where((ydat gt yvmin and ydat lt yvmax), wc)
  if (wc gt 0) then yvmin = min(ydat(w), max=yvmax)
  if (wc le 0) then begin
	yvmin = 0 & yvmax = 1
  endif
endelse

print, 'DEBUG, Y min and max scales = ',yvmin, yvmax


; Begin changes 12/11 RTB
    ; determine validmin and validmax values for the image
    a = tagindex('VALIDMIN',ztags)
    if (a(0) ne -1) then begin & b=size(zstruct.VALIDMIN)
      if (b(0) eq 0) then zvmin = zstruct.VALIDMIN $
      else begin
        zvmin = 0 ; default for image data
        print,'WARNING=Unable to determine validmin for ',vname
      endelse
    endif
    a = tagindex('VALIDMAX',ztags)
    if (a(0) ne -1) then begin & b=size(zstruct.VALIDMAX)
      if (b(0) eq 0) then zvmax = zstruct.VALIDMAX $
      else begin
        zvmax = 2000 ; guesstimate
        print,'WARNING=Unable to determine validmax for ',vname
      endelse
    endif
    a = tagindex('FILLVAL',tag_names(zstruct))
    if (a(0) ne -1) then begin & b=size(zstruct.FILLVAL)
      if (b(0) eq 0) then zfill = zstruct.FILLVAL $
      else begin
        zfill = -1 ; guesstimate
        print,'WARNING=Unable to determine the fillval for ',vname
      endelse
    endif
; bc   zvmin=min(idat) & zvmax=max(idat)

if keyword_set(DEBUG) then begin
  print, 'Image valid min and max: ',zvmin, ' ',zvmax 
  wmin = min(idat,MAX=wmax)
  print, 'Actual min and max of data',wmin,' ', wmax
  print, 'Image fill value = ',zfill
endif

    w = where((idat lt zvmin or idat eq zfill),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Number of values below the valid min = ',wc
      print,'WARNING=setting ',wc,' fill values in image data to black...'
      idat(w) = 0 ; set pixels to black
      w = 0 ; free the data space
    endif

;TJK try not taking out the higher values and just scale them in.

    w = where((idat gt zvmax and idat ne zfill),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Number of values above the valid max = ',wc
      if keyword_set(DEBUG) then print,'WARNING=setting ',wc,' fill values in image data to red...'
;      print, 'values are: ',idat(w)
      idat(w) = zvmax -1; set pixels to red
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
      semiMinMax,idat,zvmin,zvmax
      w = where((idat lt zvmin),wc)
      if wc gt 0 then begin
        print,'WARNING=filtering values less than 3-sigma from image data...'
        idat(w) = zvmin ; set pixels to black
        w = 0 ; free the data space
      endif
      w = where((idat gt zvmax),wc)
      if wc gt 0 then begin
        print,'WARNING=filtering values greater than 3-sigma from image data...'
        idat(w) = zvmax -2; set pixels to red
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


    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)

if keyword_set(DEBUG) then begin
	bytmin = min(idat, max=bytmax)
	print, 'min and max after bytscl = ',bytmin, ' ', bytmax
endif


    if keyword_set(GIF) then begin
; RTB 9/96 Retrieve the Data set name from the Logical source or
;          the Logical file id
atags=tag_names(zstruct)
b = tagindex('LOGICAL_SOURCE',atags)
b1 = tagindex('LOGICAL_FILE_ID',atags)
b2 = tagindex('Logical_file_id',atags)
if (b(0) ne -1) then psrce = strupcase(zstruct.LOGICAL_SOURCE)
if (b1(0) ne -1) then $
  psrce = strupcase(strmid(zstruct.LOGICAL_FILE_ID,0,9))
if (b2(0) ne -1) then $
  psrce = strupcase(strmid(zstruct.Logical_file_id,0,9))

    print, 'DATASET=',psrce

    GIF=strmid(GIF,0,(strpos(GIF,'.gif')))+'_f000.gif'

    if(FRAME lt 100) then gifn='0'+strtrim(string(FRAME),2) 
    if(FRAME lt 10) then gifn='00'+strtrim(string(FRAME),2) 
    if(FRAME ge 100) then gifn=strtrim(string(FRAME),2)

    GIF=strmid(GIF,0,(strpos(GIF,'.gif')-3))+gifn+'.gif'
 
    print, 'OPENING window of size ',xs+xco,' by ',ys+30
      deviceopen,6,fileOutput=GIF,sizeWindow=[xs+xco,ys+30]
      if (reportflag eq 1) then begin
        printf,1,'GIF=',GIF & close,1
      endif
      print,'GIF=',GIF 
    endif else begin ; open the xwindow
      window,/FREE,XSIZE=xs+xco,YSIZE=ys+30,TITLE=window_title
    endelse

;save off the margins before mucking w/ them.
xmargin=!x.margin
ymargin=!y.margin
if COLORBAR then begin 
 if (!x.omargin(1)+!x.margin(1)) lt 14 then !x.margin(1) = 14
 !x.margin(1) = 14
 !x.margin(0) = 10 ;TJK make room for yaxis scales and lables
 !y.margin(0) = 12 ;TJK make room for xaxis scales and lables
 !y.margin(1) = 2 ;TJK make room for xaxis scales and lables
 plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
endif

;      tv,idat,0,30,/DEVICE

axis, yaxis=0, color=!d.n_colors,ylog=ylog, /nodata, $
yrange=[yvmin,yvmax], ytitle=ytitle, ystyle=1+8, /save
axis, xaxis=0, color=!d.n_colors, xlog=xlog, $
/nodata, xrange=[xvmin,xvmax], xtitle=xtitle, xstyle=8, /save

;Note: using the following instead of the two calls to axis messed
; up the colors used for the axes and labels for writting to gif files...
;plot, xdat, ydat, /nodata, ylog=ylog, $
;yrange=[yvmin,yvmax], ytitle=ytitle, ystyle=8, $
;xlog=xlog, xrange=[xvmin,xvmax], xtitle=xtitle, xstyle=8
symsize = .15
if (ylog eq 0) then symsize= .30

txmin = xdat(0) & txmax = xdat(0)
tymin = ydat(0) & tymax = ydat(0)

for x=0, n_elements(xdat)-1 do begin
  for y=0, n_elements(ydat)-1 do begin
    if ((idat(x,y) gt 0) and (xdat(x) ge xvmin) and (ydat(y) ge yvmin)) then begin
	usersym, [-.4,.4,.4,-.4,-.4],[-.4,-.4,.4,.4,-.4],color=idat(x,y),/fill
	plots, xdat(x),ydat(y), psym=8
	if (xdat(x) lt txmin) then txmin = xdat(x)
 	if (xdat(x) gt txmax) then txmax = xdat(x)
	if (ydat(y) lt tymin) then tymin = ydat(y)
 	if (ydat(y) gt tymax) then tymax = ydat(y)
    endif
  endfor
endfor

print, 'x min/max = ',txmin, txmax
print, 'y min/max = ',tymin, tymax
;redraw the axes

axis, yaxis=0, color=!d.n_colors,ylog=ylog, /nodata, $
yrange=[yvmin,yvmax], ytitle=ytitle, ystyle=1+8, /save
axis, xaxis=0, color=!d.n_colors, xlog=xlog, $
/nodata, xrange=[xvmin,xvmax], xtitle=xtitle, xstyle=8, /save

num_columns=1
x_fourth = !d.x_size/4
extra_labels = 5 ;number of extra labels in each column
if (n_elements(label_vars) ge 1) then begin ; print all of the extra label data
  if (n_elements(label_vars) ge extra_labels) then num_columns=2

  for l = 0, n_elements(label_vars)-1 do begin

    l_str = strtrim(string(l),2);convert the index to string
    comm = execute('labl_val = ldat'+l_str)
    l_size = size(labl_val)
    if (l_size(0) eq 2) then comm = execute('labl_val = ldat'+l_str+'(*,FRAME-1)')
    if (l_size(0) eq 1) then comm = execute('labl_val = ldat'+l_str+'(FRAME-1)')
    if (not comm) then print, 'Error=execute for labels failed'
    
    ;now get the lablaxis that goes w/ this data
    comm = execute('title = strtrim(ltitle'+l_str+',2)')
    new_title=''
;TJK changed of 3/16/01 because there's only one title at a time and we need to
;be able to convert the whole value of labl_val at once...
;
;    for t=0,n_elements(title)-1 do begin
;      new_title = new_title +' '+title(t)+': '+strtrim(string(labl_val(t)),2)
;    endfor

;TJK 5/7/01 - added special check for "byte" data 

    l_struct = size(labl_val, /structure)

    if (l_struct.type eq 1 and l_struct.n_elements eq 1) then begin ; int byte data found
      new_title = new_title +' '+title+': '+strtrim(string(labl_val,/print),2)
    endif else begin
       new_title = new_title +' '+title+': '+strtrim(string(labl_val),2)
    endelse

    line = l+1
    alignment = 0.0
    if (num_columns eq 2) then begin
	if (l le extra_labels-1) then begin
          xl = 0.0 ;was x_fourth
	endif else begin
          xl = !d.x_size/2 ;was x_fourth*3
	  line = l - (extra_labels-1)
	  alignment = 0.0
	endelse
    endif

    xyouts,xl, (!d.y_ch_size*(line+2)), new_title,/DEVICE,ALIGNMENT=alignment, color=244
  endfor
endif ;printing label data

    ; subtitle the plot
  ; project_subtitle,astruct.(0),'',/IMAGE,TIMETAG=edat(FRAME-1)
    project_subtitle,zstruct,window_title,/IMAGE,TIMETAG=edat(FRAME-1)

; RTB 10/96 add colorbar
if COLORBAR then begin
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

;reset the margins
!x.margin=xmargin
!y.margin=ymargin

    if keyword_set(GIF) then deviceclose
  endif ; valid frame value

endif else begin ; Else, produce thumnails of all images

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
  boxsize = tsize+label_space;TJK added for allowing time labels for each image.
  ys = (nrows*boxsize) + 15

  ; Perform data filtering and color enhancement it any data exists
  if (no_data_avail eq 0) then begin
; Begin changes 12/11 RTB
;   ; determine validmin and validmax values
    a = tagindex('VALIDMIN',tag_names(zstruct))
    if (a(0) ne -1) then begin & b=size(zstruct.VALIDMIN)
      if (b(0) eq 0) then zvmin = zstruct.VALIDMIN $
      else begin
        zvmin = 0 ; default for image data
        print,'WARNING=Unable to determine validmin for ',vname
      endelse
    endif
    a = tagindex('VALIDMAX',tag_names(zstruct))
    if (a(0) ne -1) then begin & b=size(zstruct.VALIDMAX)
      if (b(0) eq 0) then zvmax = zstruct.VALIDMAX $
      else begin
        zvmax = 2000 ; guesstimate
        print,'WARNING=Unable to determine validmax for ',vname
      endelse
    endif
    a = tagindex('FILLVAL',tag_names(zstruct))
    if (a(0) ne -1) then begin & b=size(zstruct.FILLVAL)
      if (b(0) eq 0) then zfill = zstruct.FILLVAL $
      else begin
        zfill = 2000 ; guesstimate
        print,'WARNING=Unable to determine the fillval for ',vname
      endelse
    endif

;   ; filter out data values outside validmin/validmax limits



if keyword_set(DEBUG) then begin
  print, 'Image valid min and max: ',zvmin, ' ',zvmax 
  wmin = min(idat,MAX=wmax)
  print, 'Actual min and max of data',wmin,' ', wmax
  print, 'Image fill values = ',zfill
endif

    w = where((idat lt zvmin or idat eq zfill),wc)
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
    if (nimages eq 1) then idat = congrid(idat,tsize,tsize) $
    else idat = congrid(idat,tsize,tsize,nimages)

    ; filter out data values outside 3-sigma for better color spread
    if keyword_set(NONOISE) then begin
      print, 'before semiminmax min and max = ', zvmin, zvmax
      semiMinMax,idat,zvmin,zvmax
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

    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)

if keyword_set(DEBUG) then begin
	bytmin = min(idat, max=bytmax)
	print, 'min and max after bytscl = ',bytmin, ' ', bytmax
endif

  ; open the window or gif file
  axis_size = 0 ;add extra space on bottom and left for x/y axes - TJK

  if keyword_set(GIF) then begin
    deviceopen,6,fileOutput=GIF,sizeWindow=[xs+xco+axis_size,ys+40+axis_size]
      if (no_data_avail eq 0) then begin
       if(reportflag eq 1) then printf,1,'IMAGE=',GIF
       print,'IMAGE=',GIF
      endif else begin
       if(reportflag eq 1) then printf,1,'GIF=',GIF
       print,'GIF=',GIF
      endelse
  endif else begin ; open the xwindow
    window,/FREE,XSIZE=xs+xco+axis_size,YSIZE=ys+40+axis_size,TITLE=window_title
  endelse

xmargin=!x.margin
ymargin=!y.margin

if COLORBAR then begin
 if (!x.omargin(1)+!x.margin(1)) lt 14 then !x.margin(1) = 14
 !x.margin(1) = 14
 plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
endif

; generate the thumbnail plots

; Position each image individually to control layout
    irow=0
    icol=0
    for j=0,nimages-1 do begin
     if(icol eq ncols) then begin
       icol=0 
       irow=irow+1
     endif
     xpos=icol*tsize+axis_size
     ypos=ys-(irow*tsize+30)
     if (irow gt 0) then ypos = ypos-(label_space*irow) ;TJK modify position for labels

     tv,idat(*,*,j),xpos,ypos,/DEVICE

;TJK attempt at plasmagrams for the thumbnails - not successful yet.
;thus the reason this is all commented out and we're still just TV'ing the
;image.

;attempt to define a plot window w/in the whole window...

;!p.position(0) = xpos & !p.position(1) = ypos
;!p.position(2) = xpos + tsize & !p.position(3) = ypos + tsize+label_space

;print, !p.position
;stop;TJK
;print, 'xpos, ypos, icol, irow, tsize ', xpos, ypos, icol, irow, tsize

;axis, yaxis=0, color=!d.n_colors,ylog=ylog, /nodata, $
;yrange=[yvmin,yvmax], ytitle=ytitle, ystyle=1+8, /save, /device

;axis, xaxis=0, color=!d.n_colors, xlog=xlog, /nodata, $
;xrange=[xvmin,xvmax], xtitle=xtitle, xstyle=1+8, /save, /device

;      for x=0, n_elements(xdat)-1 do begin
;        for y=0, n_elements(ydat)-1 do begin
;	  if (idat(x,y) gt 0) then $
;	  plots, xdat(x),ydat(y), color=idat(x,y,j), psym=6, $
;	  symsize=.5, /device
;        endfor
;      endfor

     edate = decode_cdfepoch(edat(j)) ;TJK get date for this record
     shortdate = strtrim(strmid(edate, 10, strlen(edate)), 2) ; shorten it
							      ;& remove blanks

     xyouts, xpos, ypos-10, shortdate, color=!d.n_colors-1, /DEVICE ;

     icol=icol+1
    endfor


    ; done with the image
    if ((reportflag eq 1)AND(no_data_avail eq 0)) then begin
      PRINTF,1,'VARNAME=',zstruct.varname 
      PRINTF,1,'NUMFRAMES=',nimages
      PRINTF,1,'NUMROWS=',nrows & PRINTF,1,'NUMCOLS=',ncols
      PRINT,1,'THUMB_HEIGHT=',tsize+label_space
      PRINT,1,'THUMB_WIDTH=',tsize
      PRINTF,1,'START_REC=',start_frame
      PRINTF,1,'PLASMAGRAM=1'
    endif
    if (no_data_avail eq 0) then begin
      PRINT,'VARNAME=',zstruct.varname
      PRINT,'NUMFRAMES=',nimages
      PRINT,'NUMROWS=',nrows & PRINT,'NUMCOLS=',ncols
      PRINT,'THUMB_HEIGHT=',tsize+label_space
      PRINT,'THUMB_WIDTH=',tsize
      PRINT,'START_REC=',start_frame
      PRINT,'PLASMAGRAM=1'
    endif


    if ((keyword_set(CDAWEB))AND(no_data_avail eq 0)) then begin
      fname = GIF + '.sav' & save_mystruct,astruct,fname
    endif
    ; subtitle the plot
    project_subtitle,zstruct,window_title,/IMAGE, $
       TIMETAG=[edat(0),edat(nimages-1)]

; RTB 10/96 add colorbar
if COLORBAR then begin
  if (n_elements(cCharSize) eq 0) then cCharSize = 0.
   cscale = [idmin, idmax]  ; RTB 12/11
;  cscale = [zvmin, zvmax]
  xwindow = !x.window
  !x.window(1)=0.858   ; TJK added these window sizes 5/4/01
  !y.window=[0.13,0.9]
  offset = 0.01
  colorbar, cscale, ctitle, logZ=0, cCharSize=cCharSize, $ 
        position=[!x.window(1)+offset,      !y.window(0),$
                  !x.window(1)+offset+0.03, !y.window(1)],$
        fcolor=244, /image

  !x.window = xwindow
endif ; colorbar

!x.margin=xmargin
!y.margin=ymargin

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

