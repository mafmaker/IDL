;$Author: jimm $ 
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/plot_plasmagram.pro,v 1.49 2006/06/15 14:27:27 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $
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
;       THUMBSIZE = size (pixels) of thumbnails, default = 50 (i.e. 50x50)
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
;	MOVIE = if set, don't override the filename specified in the GIF 
;		keyword.
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;	Tami Kovalick, RSTX, March 3, 1998
;	Based on plot_images.pro 
; MODIFICATION HISTORY:
;
;-------------------------------------------------------------------------
;
;
;
; FUNCTION evaluate_plasmastruct, a, atags, labels=labels, symsize=symsize,$
; thumbsize=thumbsize
; PURPOSE: To evaluate the DISPLAY_TYPE attribute for the given variable
;	   if keyword labels is set, and if so find the label variables, 
;	   e.g. syntax will be plasmagram>labl=SM_position, labl=mode, etc.  
; Return a structure w/ these variable names.
; If not labels are set, then the string "none" is returned.
;	   If the keyword symsize is set, then look for the syntax:
;	   plasmagram>symsize=1	
;	   if set, then return the value of symsize
;	   if no symsize is found, the value of 2 is returned.
; CALLING SEQUENCE:
;       out = evaluate_plasmastruct, a, atags, /labels, /symsize, /thumbsize
; INPUTS:
;       a = structure returned by the read_mycdf procedure (of the plasmagram
;	variable).
;
; KEYWORD PARAMETERS:
;	lables - indicates the routine should return the lables
;	symsize - indicates the routine should return the value of symsize
;	thumsize - indicates the routine should return the thumbsize value
;
FUNCTION evaluate_plasmastruct, a, atags, labels=labels, symsize=symsize,$
thumbsize=thumbsize
; determine if there's an display_type attribute for this structure
; and if so find the label variables, e.g. syntax will be 
; plasmagram>labl=SM_position, labl=mode, etc.  
;Return a structure w/ these variable names.
;
;If symsize is set, return the symsize or default of 2.
;
; Verify that the input variable is a structure
b = size(a)
if (b(n_elements(b)-2) ne 8) then begin
  print,'ERROR=Input parameter is not a valid structure.' & return,-1
endif


; evaluate the display_type attribute values.
if (keyword_set(symsize)) then sym_size = 2 ;set default
;TJK - 8/19/2003 changed from 40 to 50 to match thumbnail settings in 
;plotmaster... if (keyword_set(THUMBSIZE)) then thumb_size = 40; set default
if (keyword_set(THUMBSIZE)) then thumb_size = 50; set default

b = tagindex('DISPLAY_TYPE',atags)
if (b(0) ne -1) then begin
  c = break_mystring(a.(b(0)),delimiter='>')
  csize = size(c)
  rest = 1
  wc=where(c eq 'THUMBSIZE',wcn)
  if(wcn ne 0) then begin
    thumb_size = fix(c(wc(0)+1))
    rest = 3
    if (keyword_set(THUMBSIZE)) then return, thumb_size
  endif

  ;TJK 5/29/2003 add in "rest" variable, if THUMBSIZE is set, then the "rest"
  ;of the key=val values are shifted down by two

  if (csize(1) ge 2)then begin
    d = break_mystring(c(rest), delimiter=',')
    if (n_elements(d) ge 1)then begin
      vars = make_array(n_elements(d),/string,value=' ')
      num_found = -1
      for i=0L, n_elements(d)-1 do begin
      ;look for all "labl" keywords
        e = break_mystring(d(i), delimiter='=')
        if (n_elements(e) ge 1) then begin

	  if keyword_set(labels) then begin
 	    if (strpos(e(0),'labl',0) ne -1) then begin
	      num_found=num_found+1
              vars(num_found) =  e(1)
	    endif
	  endif else begin
	    if keyword_set(symsize) then begin
	      if (strpos(e(0),'symsize',0) ne -1) then sym_size = e(1)
	    endif
	  endelse

	endif
      endfor

    endif
  endif 
endif 
if keyword_set(symsize) then return, sym_size
if keyword_set(thumbsize) then return, thumb_size

if (num_found ge 0) then begin
  t = where(vars ne ' ', t_cnt) ; take out the possible blanks
  if (t_cnt ge 1) then vars = vars(t) ; redefine vars
endif else begin
  vars = 'none'
endelse


return, vars ;return the list of variables to be used as labels
end  


FUNCTION plot_plasmagram, astruct, zname, $
                      THUMBSIZE=THUMBSIZE, FRAME=FRAME, $
                      XSIZE=XSIZE, YSIZE=YSIZE, GIF=GIF, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                      CDAWEB=CDAWEB,DEBUG=DEBUG,COLORBAR=COLORBAR, $
		      MOVIE=MOVIE

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

;If RPI, then get the programspecs variable and use some of the values
;for labeling and determining the symbol size (since some of this data
;was recorded in log vs. linear scales. TJK 2/24/2003
rpi = 0 ; clear flag
if (descriptor(0) eq "RPI") then begin
  a = tagindex('COMPONENT_1',tag_names(astruct.(z_ax)))
  if(a(0) ne -1) then begin
    rpi = 1 ;set flag 
    d = astruct.(z_ax).COMPONENT_1 & p_ax = tagindex(d(0),atags) ;programspecs
    pstruct = astruct.(p_ax)
    a = tagindex('DAT',tag_names(pstruct))
    if (a(0) ne -1) then pdat = pstruct.DAT $
    else begin
      a = tagindex('HANDLE',tag_names(pstruct))
      if (a(0) ne -1) then handle_value,pstruct.HANDLE,pdat $
      else begin
        print,'ERROR= ProgramSpecs variable does not have DAT or HANDLE tag' & return,-1
      endelse
    endelse
   endif ;component_1 variable doesn't exist for this RPI variable (use defaults)
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
;a = tagindex('CATDESC',ztags)
;if (a(0) ne -1) then fn = '> ' + zstruct.CATDESC else fn = ''
;TJK - change from using CATDESC to FIELDNAM, the former is too long
a = tagindex('FIELDNAM',ztags)
if (a(0) ne -1) then fn = '> ' + zstruct.FIELDNAM else fn = ''
a = tagindex('SOURCE_NAME',ztags)
if (a(0) ne -1) then begin
sn = break_mystring(zstruct.SOURCE_NAME,delimiter='>')
b = sn(0)
endif else b = ''
a = tagindex('DESCRIPTOR',ztags)
if (a(0) ne -1) then b = b + '  ' + zstruct.DESCRIPTOR
window_title = b + fn

; Get extra labels from the display type - if it exists

idx = -1 ;initialize idx
label_vars = evaluate_plasmastruct(zstruct, ztags, /labels)
thumbsize = evaluate_plasmastruct(zstruct, ztags, /thumbsize)
if (n_elements(label_vars) ge 1 and label_vars(0) ne 'none') then begin ; get all of the extra label data
  for l = 0L, n_elements(label_vars)-1 do begin
    ;TJK insert code here to look for an "indexed" label variable, e.g. 3/20/2003
    ;ProgramSpecs(0), so we need to look for "("
    idx_flag = 0 ;initialize flag
    d = break_mystring(label_vars(l),delimiter='(')
    if (n_elements(d) eq 2) then begin
      idx_flag = 1 ;set flag, we have an index variable
      label_vars(l) = d(0)
      c = strmid(d(1),0,(strlen(d(1))-1)) ; remove closing quote
      idx = long(c)
    endif  

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

    ;Need to add code here to deal w/ indexed label values - TJK - 3/20/2003
    if (idx_flag and (idx ge 0)) then begin
      comm = execute('title = strtrim(ltitle'+l_str+',2)')
      comm = execute('ltitle'+l_str+' = title(idx)')
      comm = execute('ldata = strtrim(ldat'+l_str+',2)')
      if (size(ldata, /n_dimensions) eq 2) then begin
  	  comm = execute('ldat'+l_str+' = ldata(idx,*)')
          comm = execute('ldat'+l_str+' = reform(ldat'+l_str+')')
      endif else begin
	  comm = execute('ldat'+l_str+' = ldata(idx)')
      endelse
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

if keyword_set(XSIZE) then xs=XSIZE else xs=560
if keyword_set(YSIZE) then ys=YSIZE else ys=560

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
    if (size(xdat, /n_dimensions) eq 2) then begin
	 xdat = xdat(*,(FRAME-1)) ; grab just the one frame
    endif ;otherwise assume its only one dimension
    xdat = reform(xdat) ; remove extraneous dimensions
    if (size(ydat, /n_dimensions) eq 2) then begin
    	ydat = ydat(*,(FRAME-1)) ; grab just the one frame
    endif ;otherwise assume its only one dimension
    ydat = reform(ydat) ; remove extraneous dimensions
    isize = size(idat) ; get the dimensions of the image

; screen x axis non-positive data values if creating a logarithmic plot

if (xlog eq 1L) then begin
  if (xvmin gt 0.0) then amin = xvmin else amin = 0.0
  w = where(xdat le amin,wc)
  if (wc gt 0) then begin
    w = where(xdat gt amin,wc)
    if (wc gt 0) then begin
     if keyword_set(DEBUG) then print,'Screening X ',wc, 'non-positive values.'
;     xdat = xdat(w) & idat = idat(*,w,*) & w=0
     ;get the actual min value
;     amin = min(xdat(w), max=xvmax) ;determine min/max w/o negative out of
;TJK - Jan 23, 2003 corrected the lines below because the xvmin wasn't getting
;	set to the correct value.
     xvmin = min(xdat(w), max=xvmax) ;TJK corrected - determine min/max w/o negative out of
				   ;range values
;     if (xlog eq 1L and xvmin le 0) then xvmin = amin ;xvmin can't be zero
     if (xlog eq 1L and xvmin le 0) then xvmin = .00001 ;TJK corrected  - xvmin can't be zero
    endif
  endif
endif else begin
  w = where((xdat gt xvmin and xdat lt xvmax), wc)
  if (wc gt 0) then xvmin = min(xdat(w), max=xvmax)
  if (wc le 0) then begin
	xvmin = 0 & xvmax = 1
  endif
endelse

if keyword_set(DEBUG) then print, 'DEBUG,X min and max scales = ',xvmin, xvmax

; screen y axis non-positive data values if creating a logarithmic plot
if (ylog eq 1L) then begin
  if (yvmin gt 0.0) then amin = yvmin else amin = 0.0
  w = where(ydat le amin,wc)
  if (wc gt 0) then begin
    w = where(ydat gt amin,wc)
    if (wc gt 0) then begin
     if keyword_set(DEBUG) then print,'Screening Y ',wc, 'non-positive values.'
       ;get the actual min value
;TJK - Jan 23, 2003 corrected the lines below because the xvmin wasn't getting
;	set to the correct value.
;       amin = min(ydat(w), max=yvmax)
       yvmin = min(ydat(w), max=yvmax)
;       if (ylog eq 1L and yvmin le 0) then yvmin = amin ;yvmin can't be zero
       if (ylog eq 1L and yvmin le 0) then yvmin = .0001 ;yvmin can't be zero
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

if keyword_set(DEBUG) then print, 'DEBUG, Y min and max scales = ',yvmin, yvmax


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
;TJK added checking of the image scale type 6/2/2003 since we're now
;trying to use this for other datasets, e.g. wind 3dp...
   logz = 0L ; initialize assuming linear
   a = tagindex('SCALETYP',ztags)
   if (a(0) ne -1) then begin
      if (strupcase(Zstruct.SCALETYP) eq 'LOG') then logz = 1L
   endif



if keyword_set(DEBUG) then begin
  print, 'Defined in CDF/master, valid min and max: ',zvmin, ' ',zvmax 
  wmin = min(idat,MAX=wmax)
  print, 'Actual min and max of image data',wmin,' ', wmax
  print, 'Image fill value = ',zfill
endif

;TJK 8/19/2003 - new section of code added to deal w/ fill values and log scaling and low "valid" values
;a little differently than in the past...

  fdat = where(idat ne zfill, fc)
  if (fc gt 0) then begin
    wmin = min(idat(fdat),MAX=wmax) ;do not include the fill value when determining the min/max
  endif else begin
    if keyword_set(DEBUG) then print,'WARNING=No data found - all data is fill!!'
    wmin=1 & wmax = 1.1
  endelse     


; special check for when Z log scaling - set all values
; less than or equal to 0, to the next lowest actual value.

    if (logz and (wmin le 0.0)) then begin
	w = where((idat le 0.0 and idat ne zfill), wc)
	z = where((idat gt 0.0 and idat ne zfill), zc)
	if (wc gt 0 and zc gt 0) then begin
	  if keyword_set(DEBUG) then print, 'Z log scaling and min values being adjusted, '
	  idat(w) = min(idat(z))
	endif
    endif
	  
    w = where(((idat lt zvmin) and (idat ne zfill)),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Setting ',wc,' out of range values in image data to lowest data value= ', wmin
      idat(w) = wmin ; set pixels to the lowest real value (for the current image)
      w = 0 ; free the data space
    endif

    w = where((idat eq zfill),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Number of fill values found, Setting ',wc, ' values to 0(black)'
      idat(w) = 0 ; set pixels to black
      w = 0 ; free the data space
    endif
;TJK - end of 8/19/2003 mods.

;Don't take out the higher values, just scale them in.

    w = where((idat gt zvmax and idat ne zfill),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Number of values above the valid max = ',wc, '. Setting them to red...'
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
      semiMinMax,idat,zvmin,zvmax
      w = where((idat lt zvmin),wc)
      if wc gt 0 then begin
        if keyword_set(DEBUG) then print,'WARNING=filtering values less than 3-sigma from image data...'
        idat(w) = zvmin ; set pixels to black
        w = 0 ; free the data space
      endif
      w = where((idat gt zvmax),wc)
      if wc gt 0 then begin
        if keyword_set(DEBUG) then print,'WARNING=filtering values greater than 3-sigma from image data...'
;6/25/2004 see below        idat(w) = zvmax -2; set pixels to red
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

;TJK - moved bytscl code down below the deviceopen block, so that the number of colors
; is set BEFORE we use it...

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


;TJK added MOVIE keyword so that the GIF name will not be overriden when
;generating mpg files, since the gif file generated here is just a temp.

;8/3/2001
 	if not keyword_set(MOVIE) then begin	
	    print, 'DATASET=',psrce

	    GIF=strmid(GIF,0,(strpos(GIF,'.gif')))+'_f000.gif'

	    if(FRAME lt 100) then gifn='0'+strtrim(string(FRAME),2) 
	    if(FRAME lt 10) then gifn='00'+strtrim(string(FRAME),2) 
	    if(FRAME ge 100) then gifn=strtrim(string(FRAME),2)

	    GIF=strmid(GIF,0,(strpos(GIF,'.gif')-3))+gifn+'.gif'
	endif

      deviceopen,6,fileOutput=GIF,sizeWindow=[xs+xco,ys+30]

      if not keyword_set(MOVIE) then begin ;don't print out GIF name if MOVIE
        if (reportflag eq 1) then begin
          printf,1,'GIF=',GIF & close,1
        endif
        print,'GIF=',GIF
      endif
    endif else begin ; open the xwindow
      window,/FREE,XSIZE=xs+xco,YSIZE=ys+30,TITLE=window_title
    endelse

;can't have these print statements here - they'll mess up the perl scripts that
;decipher the output between thumbnails and blowups
;if keyword_set(DEBUG) then begin
;	print, '!d.n_colors = ',!d.n_colors
;	print, 'min and max after filtering = ',idmin, ' ', idmax
;endif

;TJK - 6/28/04 - shouldn't need -8 anymore due to the better logic 
;for determining the offset 
;    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)
    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-2)

if keyword_set(DEBUG) then begin
	bytmin = min(idat, max=bytmax)
;can't have this print statement here - they'll mess up the perl scripts that
;decipher the output between thumbnails and blowups
;	print, 'min and max after bytscl = ',bytmin, ' ', bytmax
endif


;save off the margins before mucking w/ them.
xmargin=!x.margin
ymargin=!y.margin
default_right = 14 
if (logz) then default_right = 20 ;TJK 8/19/2003 allow more room for log color scale label
if COLORBAR then begin 
 if (!x.omargin(1)+!x.margin(1)) lt default_right then !x.margin(1) = default_right
 !x.margin(1) = default_right
 !x.margin(0) = 10 ;TJK make room for yaxis scales and lables
 !y.margin(0) = 6 ;TJK make room for xaxis bottom scales 

 if (label_vars(0) ne 'none') then begin ; there are labels, set margins to allow 
				  ; for them.
   !y.margin(0) = 13 ;TJK make room for xaxis scales and lables
   !y.margin(1) = 2 ;TJK make room for xaxis scales and top title
 endif
 plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
endif


;TJK add in code to explicitly define the labels when doing log scales
if (ylog eq 1) then begin
  lblv = loglevels([yvmin,yvmax])
  ;do not plot labels lt or gt min/max 
  if (n_elements(lblv) ge 3) then begin
    if (lblv(0) lt yvmin) then lblv=lblv[1:*]
    if (lblv(n_elements(lblv)-1) gt yvmax) then lblv=lblv[0:n_elements(lblv)-2]
  endif
  axis, yaxis=0, color=!d.n_colors,ylog=ylog, /nodata, yrange=[yvmin,yvmax], $
  ytitle=ytitle, ystyle=1+8, yticks=n_elements(lblv)-1, ytickv=lblv, /save
endif else begin
  axis, yaxis=0, color=!d.n_colors,ylog=ylog, /nodata, yrange=[yvmin,yvmax], $
  ytitle=ytitle, ystyle=1+8, /save
endelse

if (xlog eq 1) then begin
  lblv = loglevels([xvmin,xvmax])
  ;do not plot labels lt or gt min/max 
  if (n_elements(lblv) ge 3) then begin
    if (lblv(0) lt xvmin) then lblv=lblv[1:*]
    if (lblv(n_elements(lblv)-1) gt xvmax) then lblv=lblv[0:n_elements(lblv)-2]
  endif
  axis, xaxis=0, color=!d.n_colors, xlog=xlog, /nodata, xrange=[xvmin,xvmax], $
  xtitle=xtitle, xstyle=1+8, xticks=n_elements(lblv)-1, xtickv=lblv, /save
endif else begin
  axis, xaxis=0, color=!d.n_colors, xlog=xlog, $
  /nodata, xrange=[xvmin,xvmax], xtitle=xtitle, xstyle=1+8, /save
endelse

txmin = xdat(0) & txmax = xdat(0)
tymin = ydat(0) & tymax = ydat(0)

;TJK make the symbol sizing adjustable.9/24/2001
symbol = evaluate_plasmastruct(zstruct, ztags, /symsize)

if (ylog eq 1L) then symbol = 2 ;TJK 2/27/2003 change from 1 to 2
noclip=1
case (symbol) of
  '1': begin
	 xsym = [-.4,.4,.4,-.4,-.4] & ysym = [-.4,-.4,.4,.4,-.4]
       end
  '2': begin
	 xsym = [-1.2,1.2,1.2,-1.2,-1.2] & ysym = [-1.4,-1.4,1.4,1.4,-1.4]
	 noclip = 0
       end
  '3': begin
	 xsym = [-1.8,1.8,1.8,-1.8,-1.8] & ysym = [-1.8,-1.8,1.8,1.8,-1.8]
	 noclip = 0
       end
  '4': begin
	 xsym = [-3.2,3.2,3.2,-3.2,-3.2] & ysym = [-3.2,-3.2,3.2,3.2,-3.2]
	 noclip = 0 ; setting no clip so that these really large boxes don't
		    ; fall outside the axes.
       end
  else:begin
	xsym = [-.4,.4,.4,-.4,-.4] 
	ysym = [-.4,-.4,.4,.4,-.4]
       end
endcase

log_lin = 0 ;set a default
if (rpi) then begin ;if rpi flag is set then use the programspecs variable 
		    ;(pdat) data to help define the symbol sizes used below.
  log_lin = pdat(3,(frame-1))
  xsym_temp = xsym
  ysym_temp = ysym
endif

for x=0L, n_elements(xdat)-1 do begin
  for y=0L, n_elements(ydat)-1 do begin

    if ((idat(x,y) gt 0) and (xdat(x) ge xvmin) and (ydat(y) ge yvmin)) then begin
;Adjust size of symbol in the x direction
	if((rpi) and (log_lin gt 0) and (xdat(x) ge 20) and (xdat(x) lt 30)) then begin
	  xsym = xsym_temp*1.4
	endif
	if((rpi) and (log_lin gt 0) and (xdat(x) ge 30) and (xdat(x) lt 40)) then begin
	  xsym = xsym_temp*1.6
	endif
	if((rpi) and (log_lin gt 0) and (xdat(x) ge 40) and (xdat(x) lt 50)) then begin
	  xsym = xsym_temp*2.1
	endif
	if((rpi) and (log_lin gt 0) and (xdat(x) ge 50) and (xdat(x) lt 60)) then begin
	  xsym = xsym_temp*2.5
	endif

;Adjust size of symbol in the y direction
	if((rpi) and (log_lin gt 0) and (ydat(y) ge 40) and (ydat(y) lt 50)) then begin
	  ysym = ysym_temp*2.1
	endif
	if((rpi) and (log_lin gt 0) and (ydat(y) ge 50) and (ydat(y) lt 60)) then begin
	  ysym = ysym_temp*2.5
	endif

	usersym, xsym, ysym, color=idat(x,y), /fill
	plots, xdat(x),ydat(y), psym=8, noclip=noclip
	if (xdat(x) lt txmin) then txmin = xdat(x)
 	if (xdat(x) gt txmax) then txmax = xdat(x)
	if (ydat(y) lt tymin) then tymin = ydat(y)
 	if (ydat(y) gt tymax) then tymax = ydat(y)
    endif
  endfor
endfor

;redraw the axes

;TJK add in code to explicitly define the labels when doing log scales
if (ylog eq 1) then begin
  lblv = loglevels([yvmin,yvmax])
  ;do not plot labels lt or gt min/max 
  if (n_elements(lblv) ge 3) then begin
    if (lblv(0) lt yvmin) then lblv=lblv[1:*]
    if (lblv(n_elements(lblv)-1) gt yvmax) then lblv=lblv[0:n_elements(lblv)-2]
  endif
  axis, yaxis=0, color=!d.n_colors,ylog=ylog, /nodata, yrange=[yvmin,yvmax], $
  ytitle=ytitle, ystyle=1+8, yticks=n_elements(lblv)-1, ytickv=lblv, /save
endif else begin
  axis, yaxis=0, color=!d.n_colors,ylog=ylog, /nodata, yrange=[yvmin,yvmax], $
  ytitle=ytitle, ystyle=1+8, /save
endelse

if (xlog eq 1) then begin
  lblv = loglevels([xvmin,xvmax])
  ;do not plot labels lt or gt min/max 
  if (n_elements(lblv) ge 3) then begin
    if (lblv(0) lt xvmin) then lblv=lblv[1:*]
    if (lblv(n_elements(lblv)-1) gt xvmax) then lblv=lblv[0:n_elements(lblv)-2]
  endif
  axis, xaxis=0, color=!d.n_colors, xlog=xlog, /nodata, xrange=[xvmin,xvmax], $
  xtitle=xtitle, xstyle=1+8, xticks=n_elements(lblv)-1, xtickv=lblv, /save
endif else begin
  axis, xaxis=0, color=!d.n_colors, xlog=xlog, $
  /nodata, xrange=[xvmin,xvmax], xtitle=xtitle, xstyle=1+8, /save
endelse

;original axis generation code - replaced by above by TJK on 1/24/2003
;axis, yaxis=0, color=!d.n_colors,ylog=ylog, /nodata, $
;yrange=[yvmin,yvmax], ytitle=ytitle, ystyle=1+8, /save
;;TJK try forcing the axis scales - for some reason this wasn't being
;;done on the x axis...
;;axis, xaxis=0, color=!d.n_colors, xlog=xlog, $
;;/nodata, xrange=[xvmin,xvmax], xtitle=xtitle, xstyle=8, /save
;axis, xaxis=0, color=!d.n_colors, xlog=xlog, $
;/nodata, xrange=[xvmin,xvmax], xtitle=xtitle, xstyle=1+8, /save

num_columns=1
x_fourth = !d.x_size/4
extra_labels = 6 ;number of extra labels in each column
if (n_elements(label_vars) ge 1 and label_vars(0) ne 'none') then begin ; print all of the extra label data
  if (n_elements(label_vars) ge extra_labels) then num_columns=2

  for l = 0L, n_elements(label_vars)-1 do begin

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
    xyouts,xl, (!d.y_ch_size*(line+2)+3), new_title,/DEVICE,ALIGNMENT=alignment, color=244
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

;TJK - 8/20/2003 add check for number of images gt 300 and large thumbnails - the
; web browsers don't seem to be able to handle gif's much larger than this.
  if((nimages gt 300) and (tsize gt 50)) then begin
   print, 'ERROR= Too many plasmagram frames '
   print, 'STATUS= Plasmagrams limited to 300 frames; select a shorter time range.'
   return, -1
  endif

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

  ; Perform data filtering and color enhancement if any data exists
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
;TJK added checking of the image scale type 6/2/2003 since we're now
;trying to use this for other datasets, e.g. wind 3dp...
   logz = 0L ; initialize assuming linear
   a = tagindex('SCALETYP',ztags)
   if (a(0) ne -1) then begin
      if (strupcase(zstruct.SCALETYP) eq 'LOG') then logz = 1L
   endif

;   ; filter out data values outside validmin/validmax limits


  wmin = min(idat,MAX=wmax)

if keyword_set(DEBUG) then begin
  print, 'Image valid min and max: ',zvmin, ' ',zvmax 
  print, 'Actual min and max of data',wmin,' ', wmax
  print, 'Image fill values = ',zfill
endif
;*****
;TJK 8/19/2003 - new section of code added to deal w/ fill values and log scaling and low "valid" values
;a little differently than in the past...

  fdat = where(idat ne zfill, fc)
  if (fc gt 0) then begin
    wmin = min(idat(fdat),MAX=wmax) ;do not include the fill value when determining the min/max
  endif else begin
    if keyword_set(DEBUG) then print,'WARNING=No data found - all data is fill!!'
    wmin=1 & wmax = 1.1
  endelse     

; special check for when Z log scaling - set all values
; less than or equal to 0, to the next lowest actual value.

    if (logz and (wmin le 0.0)) then begin
	w = where((idat le 0.0 and idat ne zfill), wc)
	z = where((idat gt 0.0 and idat ne zfill), zc)
	if (wc gt 0 and zc gt 0) then begin
	  if keyword_set(DEBUG) then print, 'Z log scaling and min values being adjusted, ', wc
	  idat(w) = min(idat(z))
	endif
    endif
	  
    w = where(((idat lt zvmin) and (idat ne zfill)),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Setting ',wc,' out of range values in image data to lowest data value= ', wmin
      idat(w) = wmin ; set pixels to the lowest real value (for the current image)
      w = 0 ; free the data space
    endif

    w = where((idat eq zfill),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Number of fill values found, Setting ',wc, ' values to 0(black)'
      idat(w) = 0 ; set pixels to black
      w = 0 ; free the data space
    endif

;TJK - end of 8/19/2003 changes
;****

;TJK try not taking out the higher values and just scale them in.

    w = where((idat gt zvmax),wc)
    if wc gt 0 then begin
      if keyword_set(DEBUG) then print, 'Number of values above the valid max = ',wc, '. Setting them to red...'
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

;TJK - 8/1/2003 - for images that we'd like to enlarge to e.g. 160x160
;the congrid function that we're using to resize also does interpolation
;by default... use the cubic keyword to turn this off.
    ; rebin image data to fit thumbnail size
;    if (nimages eq 1) then idat = congrid(idat,tsize,tsize) $
;    else idat = congrid(idat,tsize,tsize,nimages)

    if (nimages eq 1) then idat = congrid(idat,tsize,tsize,cubic=0) $
    else begin
       sidat=idat
       idat=fltarr(tsize,tsize,nimages)
       for ii=0L,nimages-1 do $
          idat[*,*,ii] = congrid(sidat[*,*,ii],tsize,tsize,cubic=0)
    endelse


    ; filter out data values outside 3-sigma for better color spread
    if keyword_set(NONOISE) then begin
;      print, 'before semiminmax min and max = ', zvmin, zvmax
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

;TJK - moved bytscl code down below the deviceopen block, so that the number of colors
; is set BEFORE we use it...

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

;can't have these print statements here - they'll mess up the perl scripts that
;decipher the output between thumbnails and blowups
;if keyword_set(DEBUG) then begin
;	print, '!d.n_colors = ',!d.n_colors
;	print, 'min and max after filtering = ',idmin, ' ', idmax
;endif

;TJK shouldn't need -8 due to the better logic for determining the color
;offset (at the top of the scale)
;    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)
    idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-2)

if keyword_set(DEBUG) then begin
	bytmin = min(idat, max=bytmax)
;can't have this print statement here - it will mess up the perl scripts that
;decipher the output between thumbnails and blowups
;	print, 'min and max after bytscl = ',bytmin, ' ', bytmax
endif

xmargin=!x.margin
ymargin=!y.margin

if COLORBAR then begin
 if (!x.omargin(1)+!x.margin(1)) lt 10 then !x.margin(1) = 10
 !x.margin(1) = 3
 plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
endif

; generate the thumbnail plots

; Position each image individually to control layout
    irow=0
    icol=0
    for j=0L,nimages-1 do begin
     if(icol eq ncols) then begin
       icol=0 
       irow=irow+1
     endif
     xpos=icol*tsize+axis_size
     ypos=ys-(irow*tsize+30)
     if (irow gt 0) then ypos = ypos-(label_space*irow) ;TJK modify position for labels


;Added Rich's code for dealing w/ large thumbnails, below...


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

;end of Rich's code for larger thumbnails

     tv,idat(*,*,j),xpos,ypos,/DEVICE

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
  if (logZ) then offset = -0.03

;TJK changed logz to take log scaling if specified in the master
;6/9/2003  colorbar, cscale, ctitle, logZ=0, cCharSize=cCharSize, $ 

  colorbar, cscale, ctitle, logZ=logz, cCharSize=cCharSize, $ 
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

