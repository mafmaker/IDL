pro tvim,a,scale=scale,range=range,$
	   xrange=xrange,yrange=yrange,aspect=aspect,$
           title=title,xtitle=xtitle,ytitle=ytitle,noframe=noframe,$
           interp=interp,c_map=c_map,stitle=stitle,rmarg=rmarg,clip=clip,$
	   noerase=noerase,xann=xann,yann=yann,charsize=charsize,$
	   ycharsize=ycharsize,xcharsize=xcharsize

;+
; ROUTINE   tvim
;
; USEAGE:   tvim,a
;
;           tvim,a,title=title,xtitle=xtitle,ytitle=ytitle,stitle=stitle,$
;             xrange=xrange,yrange=yrange,scale=scale,range=range,$
;             noframe=noframe,aspect=aspect,interp=interp,c_map=c_map,$
;             rmarg=rmarg,clip=clip
;
; PURPOSE:  Display an image with provisions for
;               
;            1. numbered color scale 
;            2. plot title
;            3. annotated x and y axis 
;            4. simplified OPLOT capability
;
; INPUT    
;   a           image quantity
;
; Optional keyword input:
;
;   title       plot title
;
;   xtitle      x axis title
; 
;   ytitle      y axis title
;
;   stitle      color key title (drawn to the right of color scale)
;
;   rmarg       right margin expansion factor to provide more room 
;               for extra wide color scale annotation (default=1)
;
;   xrange      array spanning entire x axis range.  
;               NOTE:  TVIM only uses min(XRANGE) and max(XRANGE).
;
;   yrange      array spanning entire y axis range.  
;               NOTE:  TVIM only uses min(YRANGE) and max(YRANGE).
;
;   scale       if set draw color scale.  SCALE=2 causes steped
;               color scale
;
;   range       two or three element vector indicating physical
;               range over which to map the color scale.  The
;               third element of RANGE, if specified, sets the
;               step interval of the displayed color scale.  It
;               has no effect when SCALE is not set. E.g.,
;               RANGE=[0., 1., 0.1] will cause the entire color
;               scale to be mapped between the physical values
;               of zero and one; the step size of the displayed 
;               color scale will be set to 0.1. 
;
;   clip        specifies a set percentage of pixels which will be left
;               outside the color scale.  Larger values of CLIP yield
;               images with greater contrast. For example if clip=2
;               then the color scale range will be set to include 98%
;               of the pixels and to exclude the brightest 1% and the
;               dimmest 1% of the pixel brightness distribution.
;               Keyword RANGE overides the effect of CLIP.
;
;   aspect      the x over y aspect ratio of the output image
;               if not set aspect is set to (size_x/size_y) of the
;               input image.  
;
;   noframe     if set do not draw axis box around image
;
;   interp      TVIM normally uses nearest neighbor sampling to resize
;               the image to fill the data window area. If INTERP is
;               set the resizing operation uses bilinear interpolation
;
;               NOTE: When writing to a Postscript file the resizing
;               operation is accomplished by changing the pixel size.
;               Thus the INTERP parameter has no effect on Postscript
;               output.
;
;   c_map       TVIM normally rescales the input image to span the
;               entire color table range. If the input image is a byte
;               array setting C_MAP disables scaling even if the number
;               of IDL color table entries is less than 256.  This is 
;               useful when the image byte values correspond to a
;               particular color mapping that could be destroyed by
;               the rescaling process.  For example to plot a GIF
;               image which comes with its own preset RGB table 
;               (perhaps from a digitized video image) use the 
;               following:
;
;                read_gif,file,im,r,g,b
;                tvlct,r,g,b
;                tvim,im,/c_map
;
;
;               When the number of IDL color table entries is less
;               than 256 some colors will be lost. Use a private color
;               map to avoid this.
;               
;               NOTE: When C_MAP is set the color scale range displayed
;                     to the right of the image (when SCALE is set) 
;                     ranges from 0 to the  available color table entry.
;
; SIDE EFFECTS: Setting SCALE=2 changes the color scale using the
;               STEP_CT procedure.  The color scale may be returned
;               to its original state by the command, STEP_CT,/OFF
;
; PROCEDURE     TVIM first determins the size of the plot data 
;               window with a dummy call to PLOT.  When the
;               output device is "X", CONGRID is used to scale
;               the image to the size of the available data
;               window.  Otherwise, if the output device is
;               Postscript, scaleable pixels are used in the
;               call to TV.
;
;               If the input image quantity is not of type
;               byte, TVIM converts them to byte by scaleing
;               the input between 0 and !d.n_colors-1.  If the
;               input is already a byte array and if either the 
;               number of color table entries is 256 or if C_MAP 
;               is set,  then no scaling is done.  This is to ensure 
;               consistency with specially defined private color
;               tables.
;
;               After the the image is drawn TVIM calls PLOT
;               again to draw the x and y axis and titles.
;               Finally if scale is set, TVIM calls the
;               COLOR_KEY procedure to draw the color scale
;               just to the right of the data window.
;
; RESTRICTIONS: A stepped color scale (SCALE = 2 option) is not
;               available when writing to a black & white postscript
;               file (i.e., when the DEVICE color option is not
;               enabled).
;
; DEPENDENCIES: COLOR_KEY, STEP_CT
;
; AUTHOR:       Paul Ricchiazzi    oct92 
;               Earth Space Research Group, UCSB
;
; REVISIONS:
; 28jan93: switched from PUT_COLOR_SCALE to COLOR_KEY
; 11feb93: added INTERP keyword
; 11feb93: added C_MAP keyword
; 11feb93: added STITLE keyword
; 20apr93: added RMARG keyword, centered image in plot window
; 23apr93: call COLOR_KEY before TV. Now stepped color scales copy to PS file
; 10sep93: deal with perfectly flat images. No more math error when a=0
; 14sep93: added CLIP keyword
; 27jan95: fixed RMARG keyword, to work without scale keyword (A. Nicholas)
;-

if n_params() eq 0 then begin
  doc_library,'tvim'
  return
endif  

sz=size(a)
nx=sz(1)
ny=sz(2)
nxm=nx-1
nym=ny-1

IF keyword_set(noerase) eq 0 then $
	plot, [0,1],[0,1],/nodata,xstyle=4,ystyle=4 $
    else plot, [0,1],[0,1],/nodata,xstyle=4,ystyle=4,/noerase

px=!x.window*!d.x_vsize
py=!y.window*!d.y_vsize
xsize=px(1)-px(0)
ysize=py(1)-py(0)
if keyword_set(rmarg) eq 0 then rmarg=1.

if (keyword_set(scale) OR keyword_set(rmarg)) then begin
  xmarg=8*!d.x_ch_size
  if keyword_set(stitle) then xmarg=xmarg+2*!d.x_ch_size
  xsize=xsize-rmarg*xmarg
endif

oxs=xsize
oys=ysize
if keyword_set(aspect) eq 0 then aspect=float(nx)/ny
if xsize gt ysize*aspect then xsize=ysize*aspect else ysize=xsize/aspect 
if xsize lt oxs then px(0)=px(0)+.5*(oxs-xsize)
if ysize lt oys then py(0)=py(0)+.5*(oys-ysize)
px(1)=px(0)+xsize
py(1)=py(0)+ysize
pos=[px(0),py(0),px(1),py(1)]
;
max_color=!d.n_colors-1
;
if keyword_set(title) eq 0 then title=''

amax=float(max(a))
amin=float(min(a))
;print, 'a      min and max  ',   amin,amax

if keyword_set(range) eq 0 then begin
  if amin eq amax then begin
    case 1 of
      amax eq 0.: range=[-1,1.]
      amax gt 0.: range=[0,2*amax]
      amax lt 0.: range=[2*amax,0]
    endcase
  endif else begin
    if keyword_set(clip) then begin
      range=[prank(a,clip),prank(a,clip,/top)]
    endif else begin
      range=[amin,amax]
    endelse
  endelse
endif 

isbyte=sz(n_elements(sz)-2) eq 1 
if isbyte and keyword_set(c_map) then begin
  aa=a             
  range(0)=0
  range(1)=max_color
endif else begin
  aa=max_color*((float(a)-range(0))/(range(1)-range(0)) > 0. < 1.)
endelse
;
if keyword_set(interp) eq 0 then sample=0
;
posbar=[px(1)+!d.x_ch_size,py(0)]
if keyword_set(scale) then begin
  if scale eq 2 then step=1 else step=0
  if n_elements(range) eq 3 then begin
    inc=range(2)
    rng=range(0:1)
    color_key,pos=posbar,ysize=ysize,range=rng,inc=inc,step=step,title=stitle
  endif else begin
    color_key,pos=posbar,ysize=ysize,range=range,step=step,title=stitle
  endelse
endif
;
if !d.name eq 'X' then begin
  tv,congrid(aa,xsize,ysize,interp=interp),px(0),py(0)
endif else begin
  tv,aa,px(0),py(0),xsize=xsize,ysize=ysize,/device
endelse

;
if (keyword_set(xtitle) eq 0) then xtitle=''
if (keyword_set(ytitle) eq 0) then ytitle=''
if (keyword_set(xrange) eq 0) then $
  xrng=[0,nxm] else xrng=[min(xrange), max(xrange)]
if (keyword_set(yrange) eq 0) then $
  yrng=[0,nym] else yrng=[min(yrange), max(yrange)]
if keyword_set(xann) eq 0 then xann=''
if keyword_set(yann) eq 0 then yann=''
if keyword_set(charsize) eq 0 then charsize=0
if keyword_set(xcharsize) eq 0 then xcharsize=0
if keyword_set(ycharsize) eq 0 then ycharsize=0

if keyword_set(noframe) then begin
  plot,[0,0],[0,0],xstyle=5,ystyle=5,title=title,xtitle=xtitle,ytitle=ytitle, $
       xrange=xrng,yrange=yrng,position=pos,/noerase,/device,/nodata,$
	charsize=charsize,xcharsize=xcharsize,ycharsize=ycharsize
endif else begin
  plot,[0,0],[0,0],xstyle=1,ystyle=1,title=title,xtitle=xtitle,ytitle=ytitle, $
       xrange=xrng,yrange=yrng,position=pos,/noerase,/device,/nodata,$
	xtickname=xann,ytickname=yann,charsize=charsize,xcharsize=xcharsize,$
	ycharsize=ycharsize
endelse
;
end





