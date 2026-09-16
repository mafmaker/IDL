;$author: $ 
;$Date: 2014-07-10 10:01:21 -0700 (Thu, 10 Jul 2014) $
;$Header: /home/cdaweb/dev/control/RCS/plot_enaflux5.pro,v 1.13 2006/04/05 14:47:06 klipsch Exp $
;$Locker:  $
;$Revision: 15545 $;
;
;------------------------------------------------------------------------- 
; NAME: plot_enaflux 
; PURPOSE: 
;       Plot a given image that is assumed to be square and be centered 
;       on the Earth.  Spacecraft spin axis orientation and orbit data 
;       are used to scale the Earth and rotate the image so that the 
;       Earth's north is up.  Dipole field lines are also drawn. 
;       Note that the original input image is scaled (modified) 
;       by this routine. 
; 
; CALLING SEQUENCE: 
;       out = plot_enaflux(etime,image,fov,resolution,sc_pos_gci, 
;                          sc_spinaxis_gci,nadir) 
; INPUTS: 
;       etime = time of the image, in cdf_epoch units 
;       image = 2d image to be plotted.  Must be square image. 
;       fov   = total width of field of view, in degrees. 
;       resolution = resolution of each pixel in image, in degrees. 
;       sc_pos_gci = spacecraft position vector [3] in ECI coords. 
;       sc_spinaxis_gci = spacraft spinaxis uvector [3] in ECI coords. 
;       nadir = 1=earthpointing, 0=anti-earthpointing 
; 
; KEYWORD PARAMETERS: 
;	REFORMER : If image is not perfectly square and this keyword 
;                  is set, the image will be streched to be square. 
;       ORBIT    : In the event that the spacecraft spin axis unit vector  
;                  is not available to the user of this function, and 
;                  given that this plotting code makes the assumption  
;                  that the spin axis is normal to the orbit plane, setting 
;                  this keyword to the [RAAN,INCLINATION] of the orbit  
;                  will cause this routine to compute the sc_spinaxis_gci 
;                  input parameter for the user. 
;       REVERSEORDER :  The 2d image is assumed to be [spinangle (i.e. time)
;                  by elevation], and that the spinangle and elevation are
;                  in increasing order.  Setting this keyword executes
;                  the idl reverse,1 which can be used if the spinangle is
;                  decreasing rather than increasing.  Setting this keyword
;                  to 2 will cause the image to be transposed and reversed.
;       GIF      : Creates GIF file instead of Xwindow.  If set to a string, 
;                  this will be the name of the gif, if set to 1, the gif 
;                  will be named idl.gif. 
;       WSIZE    : Causes the plotcode to apply IDL's CONGRID function 
;                  to change the image size.  Example, WSIZE=[200,200] 
;       NOCIRCLES: If set, equatorial cirlces at 3.3 and 6 Re won't be drawn. 
;       NODIPOLES: If set, magfield dipoles won't be drawn. 
;       NOEARTH  : If set, the Earth won't be overlaid onto image. 
;       EDGES    : If set to 1, roberts edge enhancement will be applied. 
;                  If set to 2, sobel edge enhancement will be applied. 
;       NOBORDER : If set, no extra border space will be made around image. 
;       NOCOLORBAR : If set, no colorbar will be added to window. 
;       SMOOTH   : If set, boxcar average smoothing will be applied. 
;       SCALEMIN : If set, will be used as the minimum scale instead of 1. 
;       SCALEMAX : If set, will be used as the maximum scale instead of max(image) 
;       DEBUG    : If set, additional output is printed. 
; OUTPUTS: 
;       out = string array 
; AUTHOR: 
;       Mei-Ching Fok    NASA/GSFC     Original version December,1999. 
; MODIFICATION HISTORY: 
;       Richard Burley   NASA/GSFC/632 plot_enaflux wrapper put around Mei-Chings 
;                        5/24/2001     original code.  Keywords added. 
;	Tami Kovalick	 Raytheon ITSS has re-integrated new releases of this software
;				       into the CDAWeb version of the s/w.
;			 4/24/2001 and again 6/19/2001
;       Richard Burley   NASA/GSFC/632 Enhanced reverseorder keyword to use
;                        6/22/2001     multiple values to apply multiple reversals.

;-----------------------------------------------------------------------------

FUNCTION plot_enaflux3,etime,image,spin_angle,polar_angle,np,sc_pos_sm, $
sc_spin_axis_sm,sc_pos_geo,geo_N_sm,nadir,GIF=GIF,WSIZE=WSIZE,$
                  NOCIRCLES=NOCIRCLES,NODIPOLES=NODIPOLES,NOEARTH=NOEARTH,$
                  NOCOLORBAR=NOCOLORBAR,EDGES=EDGES,NOBORDER=NOBORDER,$
                  SMOOTH=SMOOTH,SCALEMAX=SCALEMAX,SCALEMIN=SCALEMIN,$
                  REVERSEORDER=REVERSEORDER,DEBUG=DEBUG

; Convert time from cdf-epoch to year, day, hour and minute
year=0 & month=0 & day=0 & hour=0 & minute=0 & sec=0
cdf_epoch,etime,year,month,day,hour,minute,sec,/break

; Make sure a square image
for i=0,np-1 do begin
   if (spin_angle(i) ne polar_angle(i)) then begin
      print,' Error: spin angles and polar angles are not the same.'
      return,-1
   endif
endfor

; The rotation code in this routine expects the image array order to be
; [spinangle(i.e. time),elevation].  If the image is in the reverse order
; the /REVERSEORDER keyword should be set, and this code will correct.
if keyword_set(REVERSEORDER) then begin
  if REVERSEORDER eq 1 then image = reverse(image,1)
  if REVERSEORDER eq 2 then image = reverse(transpose(image),2)
endif

; Set min/max dimension sizes

pix_size=spin_angle(1)-spin_angle(0)
x_min=spin_angle(0)-0.5*pix_size
x_max=spin_angle(np-1)+0.5*pix_size
y_min=x_min & y_max=x_max

; Make sure sc_pos_sm is perpendicular to sc_spin_axis_sm
dotproduct=0.
for i=0,2 do dotproduct=dotproduct+sc_pos_sm(i)*sc_spin_axis_sm(i)
; Note, RB loosened up the normal requirement from 1.e-4 to 1.e-3
if (abs(dotproduct) gt 1.e-3) then begin
   print,' Error: spin axis not normal to the spacecraft position vector. Dotp=',dotproduct
   return,-1
endif

; Find the SM components of x-axis (azimuthal angle) of the satellite frame, in
; which y-axis is along the spin axis and z-axis is along the satellite pos
; vector.  For image looking outward from Earth, z-axis is pointed from the
; satellite to the Earth.
x_sat=fltarr(3) & y_sat=fltarr(3) & z_sat=fltarr(3)
rspin=sqrt(sc_spin_axis_sm(0)*sc_spin_axis_sm(0)+sc_spin_axis_sm(1)*  $
           sc_spin_axis_sm(1)+sc_spin_axis_sm(2)*sc_spin_axis_sm(2))
rs2=(sc_pos_sm(0)*sc_pos_sm(0)) + (sc_pos_sm(1)*sc_pos_sm(1)) + $
    (sc_pos_sm(2)*sc_pos_sm(2))
rs=sqrt(rs2) & rs_tst=sqrt(rs2-1.)
z_sat(*)=nadir*sc_pos_sm(*)/rs
; changed to -1 * sc_spin_axis on 2/16 by MC & RB
;y_sat(*)=sc_spin_axis_sm(*)/rspin
y_sat(*)= (-1.0 * sc_spin_axis_sm(*))/rspin

x_sat(0)=y_sat(1)*z_sat(2)-y_sat(2)*z_sat(1)       ; x_sat = y_sat x z_sat
x_sat(1)=y_sat(2)*z_sat(0)-y_sat(0)*z_sat(2)
x_sat(2)=y_sat(0)*z_sat(1)-y_sat(1)*z_sat(0)

; Rotate satellite frame such that magnetic dipole axis is up (along y-axis)
ang_rotate=atan(y_sat(2),x_sat(2))-!pi/2 ; angle between dipole axis & y_sat
;RB commented the following several lines out
;x_sat_new=fltarr(3) & y_sat_new=fltarr(3) & z_sat_new=fltarr(3)
;z_sat_new(*)=z_sat(*)
;x_sat_new(0)=-z_sat(1) 
;x_sat_new(1)=z_sat(0) 
;x_sat_new(2)=0.
;y_sat_new(0)=z_sat_new(1)*x_sat_new(2)-z_sat_new(2)*x_sat_new(1)
;y_sat_new(1)=z_sat_new(2)*x_sat_new(0)-z_sat_new(0)*x_sat_new(2)
;y_sat_new(2)=z_sat_new(0)*x_sat_new(1)-z_sat_new(1)*x_sat_new(0)

; Rotate and scale the image
c_ang_rotate=cos(ang_rotate) & s_ang_rotate=sin(ang_rotate)
new_image=fltarr(np,np)
;
; Scale the image - Scaling business added by RB - integrated by TJK on 4/23/01
; Determine the proper scale for the image
flx_min=1.0 & if keyword_set(SCALEMIN) then flx_min=SCALEMIN
flx_max=max(image) & if keyword_set(SCALEMAX) then flx_max=SCALEMAX
if keyword_set(DEBUG) then print, 'FLX min and max = ',flx_min, flx_max
if (flx_max lt flx_min) then begin
  if keyword_set(DEBUG) then print,'ERROR>plot_enaflux>flx_max < flx_min!'
  return,-1
endif

if (flx_max - flx_min) lt 1.0 then flx_max = flx_max + 1.0 ; make sure enough range

log_min=alog10(flx_min) & log_max=alog10(flx_max)

if keyword_set(DEBUG) then begin
  print,'INFO>plot_enaflux>flx_min =',flx_min,'  log_min=',log_min
  print,'INFO>plot_enaflux>flx_max =',flx_max,' log_max=',log_max
endif
; THE FOLLOWING 2 LINES WERE COMMENTED OUT ON 2/8 BY RB SO THAT GIFS 
; COULD BE AUTOSCALED TO HELP MEI-CHING FIGURE OUT THE ROTATION PROBLEM.
;flx_min=1.   & log_min=alog10(flx_min) ; min. flux will be plotted
;flx_max=1.e3 & log_max=alog10(flx_max) ; max. flux will be plotted
; THE FOLLOWING 2 LINES WERE ADDED ON 2/8 BY RB TO AUTOSCALE
;flx_min=1.   & log_min=alog10(flx_min) ; min. flux will be plotted
;flx_max=max(image) & log_max=alog10(flx_max) ; max. flux will be plotted
;print,'FLUX_MIN/MAX = ',flx_min,' ',flx_max
;print,'LOG__MIN/MAX = ',log_min,' ',log_max

if !d.window ge 0 then loadct, 13, ncolors=240
;ncolor = !d.table_size - 2
ncolor = 240 - 2
fcolor = float(ncolor)

for i=0,np-1 do begin
   for j=0,np-1 do begin
; --- MCF begin comment out ---
;      xn=spin_angle(i)*c_ang_rotate-spin_angle(j)*s_ang_rotate
;      xni=(xn-spin_angle(0))/pix_size
;      yn=spin_angle(i)*s_ang_rotate+spin_angle(j)*c_ang_rotate
;      xnj=(yn-spin_angle(0))/pix_size
;      result=interpolate(image,[xni,xni],[xnj,xnj],missing=flx_min)
;      if (result(0,0) lt flx_min) then result(0,0)=flx_min
;      if (result(0,0) gt flx_max) then result(0,0)=flx_max
;      log_flx=alog10(result(0,0)) ; log (flux)
;      ; scale the flux to from 1 - fcolor
;      new_image(i,j)=1.+(fcolor-1.)*(log_flx-log_min)/(log_max-log_min)

      value = image[i,j]
      if value lt flx_min then value = flx_min
      if value gt flx_max then value = flx_max
      log_flx = alog10(value)
      ; scale the flux to from 1 - fcolor
      image[i,j] = 1.+(fcolor-1.)*(log_flx-log_min)/(log_max-log_min)

   endfor
endfor

; Determine the window size based on keyword or default
x_wsize=600 & y_wsize=650 ; original sizes from meiching
if keyword_set(WSIZE) then begin ; validate the keyword
  valid=1 & s=size(WSIZE) & ns=n_elements(s)
  if (s(0) ne 1) or (s(1) ne 2) then valid = 0
  if (s(ns-2) lt 2) or (s(ns-2) gt 3) then valid = 0
  if valid eq 1 then begin
    if (min(wsize) lt 40) or (max(wsize) gt 800) then valid = 0
  endif
  if valid eq 1 then begin x_wsize=wsize(0) & y_wsize=wsize(1) & endif
endif
if keyword_set(NOBORDER) then begin
   im_size=fix(x_wsize/np)*np    ; make sure im_size is multiple of np
   x_wsize=im_size    &   y_wsize=im_size
endif


; Plot image to Xwindow or GIF
if keyword_set(GIF) then begin
  s = size(GIF)
  if (s(n_elements(s)-2) ne 7) then GIF='idl.gif'
  set_plot,'z'
  tvlct,red,green,blue,/get
;  loadct, 13

;Rick changed and integrated by TJK 6/19/2001
;  red[0]=255 & green[0]=255 & blue[0]=255 ; make color=0 white
;TJK, change hardcoded array value to !d.n_colors-1
;  red[254]=255 & green[254]=255 & blue[254]=255 & mywhite=254 ; make color=254 white
  mywhite = !d.table_size-1
  red  [mywhite] = 255
  green[mywhite] = 255
  blue [mywhite] = 255
 
  tvlct, red, green, blue
  device,set_resolution=[x_wsize,y_wsize],set_char=[6,11],z_buffering=0
  ;Rick changed and integrated by TJK 6/19/2001 mywhite=0 &
  myblack=1
  ; deviceopen,6,fileOutput=GIF,sizeWindow=[x_wsize,y_wsize]

endif else begin ; open x-window display
; loadct, 13
  tvlct, red, green, blue, /get
;TJK - not sure about this change...
;  red[0]=255 & green[0]=255 & blue[0]=255 ; make color=0 white
  red[254]=255 & green[254]=255 & blue[254]=255 & mywhite=254 ; make color=254 white

  tvlct, red, green, blue
  window,/FREE,xpos=420,ypos=10,xsize=x_wsize,ysize=y_wsize
;TJK not sure about this either  mywhite=0 & myblack=1
  myblack=0
endelse


; Size and display the image
;This new section was added on 4/23/01 by TJK - this is from RB's latest
;version that he sent to us...
x0i=0.1*x_wsize & y0i=0.2*y_wsize                           ; MCF begin add
if keyword_set(NOBORDER) then begin
   x0i=0.   &    y0i=0.
endif
x0=x0i/x_wsize  & y0=y0i/y_wsize ; scale image size to 0-1
x1=(x0i+im_size)/x_wsize & y1=(y0i+im_size)/y_wsize        
ang_rotate_d=ang_rotate*180./!pi   ; rotation angle in degree 
;print,'INFO>plot_enaflux3>ang_rotate_d=',ang_rotate_d
;print,'ang_rotate_d=',ang_rotate_d ; RBDEBUG
map_set,0.,0.,ang_rotate_d,/azimuth,/iso,position=[x0,y0,x1,y1], $
        limit=[y_min,x_min,y_max,x_max],/noborder
new_image=map_image(image,sx,sy,x_size,y_size,latmin=y_min,$
                    latmax=y_max,lonmin=x_min,lonmax=x_max)  ; MCF end add

if not keyword_set(NOBORDER) then im_size=fix(0.8*x_wsize/np)*np
c_image=congrid(new_image,im_size,im_size)
if keyword_set(EDGES) then begin ; apply edge enhancement
  if EDGES eq 1 then c_image=roberts(c_image)
  if EDGES eq 2 then c_image=sobel(c_image)
endif
;RB added w/ second version of this s/w

;Rick's version of smoothing that has artifacts... doesn't smooth the whole
;image...
if keyword_set(SMOOTH) then begin ; apply boxcar average smoothing
  if SMOOTH eq 1 then begin ; compute smoothing parameter
     SMOOTH = ceil(im_size / 7.0) & if (SMOOTH mod 2) eq 0 then SMOOTH=SMOOTH+1
  endif
print, 'Images being SMOOTHED by a factor of, ',smooth
 c_image = smooth(c_image,smooth,/edge_truncate) ; smooth factor changes based on the 
				       ; image size
endif

;TJK my version follows, which doesn't have artifacts (no unsmoothed blocks
;around the edges.
;if keyword_set(SMOOTH) then begin ; apply boxcar average smoothing
;  if SMOOTH eq 1 then begin ; compute smoothing parameter
;    SMOOTH = ceil(im_size / 10.0) & if (SMOOTH mod 2) eq 0 then SMOOTH=SMOOTH+1
;  endif
;  c_image = smooth(c_image,10) ;changed to a hard number 
;  print, 'Images being SMOOTHED by a factor of 10'
;endif

;MCF commented out in second version
;x0i=0.1*x_wsize & y0i=0.2*y_wsize
;if keyword_set(NOBORDER) then begin
;   x0i=0.   &    y0i=0.
;endif
;x0=x0i/x_wsize  & y0=y0i/y_wsize ; scale image size to 0-1
;x1=(x0i+im_size)/x_wsize & y1=(y0i+im_size)/y_wsize
;npt=480 ; no. of points in draw fieldline, circle..
;End of MCF comment out
npt=1000 ; no. of points in draw fieldline, circle.. ;MCF add
e_rad = asin(1.0/rs) * 180.0 / !pi   ; angle subtaned by the Earth
e_x = fltarr(npt+1) & e_y = fltarr(npt+1)
x = fltarr(2) & y = fltarr(2)
;MCF changed tv,c_image,x0i,y0i ; display the image  

tv,c_image,sx/200,sy/200   ; display the image    ; MCF add ; RB, added division 
						  ; by 200 for Z-buffer

; Add color bar and label
if not keyword_set(NOCOLORBAR) and not keyword_set(NOBORDER) then begin
  tempvar = bytarr(ncolor,2)
  for i=0,ncolor-1 do begin
    tempvar(i,0) = i+1 & tempvar(i,1) = i+1
  endfor
  color_bar=congrid(tempvar,ncolor,30)
  tv,color_bar,x0i,0.32*y0i
  xyouts,x0,0.2*y0,string(log_min,'(f3.1)'),$
              alignment=0.5,size=1.5,/normal,color=myblack
  xlab = x0+float(ncolor)/x_wsize
  xyouts,xlab,0.2*y0,string(log_max,'(f3.1)'),$
              alignment=0.5,size=1.5,/normal,color=myblack
  xyouts,0.5*(xlab+x0),0.1*y0,'log (particle/cm2/sr/s)',$
              alignment=0.5,size=1.5,/normal,color=myblack
endif

;x1=(x0i+im_size)/x_wsize
;y1=(y0i+im_size)/y_wsize
;npt=480 ; no. of points in draw fieldline, circle..
;e_rad = asin(1.0/rs) * 180.0 / !pi   ; angle subtaned by the Earth
;e_x = fltarr(npt+1) & e_y = fltarr(npt+1)
;x = fltarr(2) & y = fltarr(2)


; Calculate and draw circles at 3 and 6.6 Re at the equator and
; draw connections between them
r=fltarr(3)      &   rp=r        ; MCF add
three_hr=!pi/4. & ang0=atan(sc_pos_sm(1),sc_pos_sm(0))+!pi
del = 2.0 * !pi / npt & ncpt=16
xc=fltarr(ncpt) & yc=fltarr(ncpt) & lt_lab=strarr(ncpt)
for i=1,2 do begin & localtime0=0 ; init
    if (i eq 1) then rc=3. & if (i eq 2) then rc=6.6
    icn=i-1 & ic=-1
    for ii = 0,npt do begin & ibehind=nadir ; init
        ang = ang0+ii*del 
;  	 xe = rc * cos(ang)			;MCF begin comment out
;        ye = rc * sin(ang) & r2=xe*xe+ye*ye
;        re2=(sc_pos_sm(0)-xe)^2+(sc_pos_sm(1)-ye)^2+sc_pos_sm(2)^2
;        re=sqrt(re2) ; dist. ./. satellite. & equator
;        cosa=nadir*(rs2+re2-r2)/(2.*rs*re)
;        angl=acos(cosa)*180./!pi ;angle subtended in deg
;        xd=xe*x_sat_new(0)+ye*x_sat_new(1)
;        yd=xe*y_sat_new(0)+ye*y_sat_new(1)
;        rd=sqrt(xd*xd+yd*yd)			;MCF end comment out
        r(0) = rc * cos(ang)                            ; MCF begin add
        r(1) = rc * sin(ang)
        r(2) = 0.
        rp(*)=r(*)-sc_pos_sm(*)
        re=sqrt(total(rp*rp))               ; dist. ./. satellite. & equator
        xp=total(rp*x_sat)
        yp=total(rp*y_sat)
        zp=total(rp*z_sat)
        xd=atan(xp,-zp)*180./!pi
        yd=asin(yp/re)*180./!pi
        angl=sqrt(xd*xd+yd*yd)     ;angle subtended in deg  ; MCF edd add

        if (angl gt e_rad or re lt rs_tst or nadir eq -1) then begin
           ibehind=-1 ; this point can be seen
;           ic=ic+1 & e_x(ic)=xd*angl/rd & e_y(ic)=yd*angl/rd	;MCF comment out
           ic=ic+1 & e_x(ic)=xd   & e_y(ic)=yd                ; MCF add
        endif

        ang_o_3=fix(ang/three_hr) & test=three_hr*ang_o_3
        if ((ang-test) lt del and icn le (ncpt-1)) then begin ; 3hr Label
           localtime=ang_o_3*3-12 ; -12 cause 180 deg -> 00 LT
           if (localtime lt 0)  then localtime=localtime+24
           if (localtime gt 24) then localtime=localtime-24
           if (icn eq (i-1) or localtime ne localtime0) then begin ;avoid reps
              lt_lab(icn)=string(localtime,'(i2.2)')
              if (ibehind eq -1) then begin
                 xc(icn)=e_x(ic) & yc(icn)=e_y(ic)
              endif else begin ; if behind earth, put point on earth rim
;                 xc(icn)=xd*e_rad/rd & yc(icn)=yd*e_rad/rd replaced w/ following
                 ; line on 12/28 based on email from mei-ching.
                 xc(icn)=xd*e_rad/angl & yc(icn)=yd*e_rad/angl
              endelse
              icn=icn+2
           endif
           localtime0=localtime
        endif
    endfor
;TJK, change color keyword value below to !d.n_colors-1 instead of zero
;change all "color=0" to color=!d.n_colors-1
;change all settings of xticks=8,yticks=8 to xticks=1,yticks=1 to suppress 
;tick marks.  Change the x/ystyle to +4 so that the axis won't be drawn.

;MCF commented this section out and replaced it w/ one line...
;    if (i eq 1) then begin
;      if not keyword_set(NOCIRCLES) then begin
;        plot,e_x(0:ic),e_y(0:ic),position=[x0,y0,x1,y1],$
;               xrange=[x_min,x_max],yrange=[y_min,y_max],xticks=1,yticks=1,$
;               xstyle=1+4,ystyle=1+4,color=!d.n_colors-1,/noerase
;      endif
;    endif
;    if (i eq 2) then if not keyword_set(NOCIRCLES) then $
;                                      oplot,e_x(0:ic),e_y(0:ic),color=!d.n_colors-1
;TJK - mywhite is set to 0 above, MCF had color set to mywhite - I would prefer
; the use of !d.n_colors-1 instead

;if not keyword_set(NOCIRCLES) then oplot,e_x(0:ic),e_y(0:ic),color=mywhite  ; MCF add
if not keyword_set(NOCIRCLES) then $
  oplot, e_x(0:ic), e_y(0:ic), color=!d.table_size-1 

endfor

for i=0,14,2 do begin
   if not keyword_set(NOCIRCLES) then $
     oplot, xc(i:i+1), yc(i:i+1), color=!d.table_size-1
   labx=1.1*xc(i+1) & laby=1.1*yc(i+1)
   if (abs(labx) le x_max and abs(laby) le x_max) then begin
       if not keyword_set(NOCIRCLES) then $
         xyouts, labx, laby, lt_lab(i+1), color=!d.table_size-1
   endif
endfor


; Calculate and draw dipole fieldlines at L=3, 6.6, MLT=0, 6, 12, 18
for i=1,2 do begin
    if (i eq 1) then rc=3. & if (i eq 2) then rc=6.6
    sinang0=sqrt(1./rc) & ang0=asin(sinang0) ; draw from earth surface
    del=(!pi-2.*ang0)/npt
    for j=0,270,90 do begin
        phi=j*!pi/180. ; azimuthal angle in radian
        cphi=cos(phi) & sphi=sin(phi)
        for n=0,1 do begin ; do 2 hemispheres separately
            i1=n*npt/2 & i2=i1+npt/2 & ic=-1
            for ii=i1,i2 do begin
                ang=ang0+ii*del & sang=sin(ang)
;MCF commented out
;                r=rc*sang*sang  & r2=r*r
;                xe=r*sang*cphi  & ye=r*sang*sphi & ze=r*cos(ang)
;                re2=(sc_pos_sm(0)-xe)^2+(sc_pos_sm(1)-ye)^2+(sc_pos_sm(2)-ze)^2
;                re=sqrt(re2)  ;dist. ./. sat. & fieldline
;                cosa=nadir*(rs2+re2-r2)/(2.*rs*re)
;                angl=acos(cosa)*180./!pi  ;angle subtended in deg
;                xd=xe*x_sat_new(0)+ye*x_sat_new(1)+ze*x_sat_new(2)
;                yd=xe*y_sat_new(0)+ye*y_sat_new(1)+ze*y_sat_new(2)
;                rd=sqrt(xd*xd+yd*yd)
                r1=rc*sang*sang   ; dipole fieldline equation  ; MCF begin add
                r2=r1*r1
                r(0)=r1*sang*cphi
                r(1)=r1*sang*sphi
                r(2)=r1*cos(ang)
                rp(*)=r(*)-sc_pos_sm(*)
                re=sqrt(total(rp*rp))    ; dist. ./. satellite.&fieldlines
                xp=total(rp*x_sat)
                yp=total(rp*y_sat)
                zp=total(rp*z_sat)
                xd=atan(xp,-zp)*180./!pi
                yd=asin(yp/re)*180./!pi
                angl=sqrt(xd*xd+yd*yd) ;angle subtended in deg  ; MCF end add
                if (angl gt e_rad or re lt rs_tst or nadir eq -1) then begin
                   ic=ic+1 ; fieldline point can be seen
;                   e_x(ic)=xd*angl/rd & e_y(ic)=yd*angl/rd	;MCF comment out
                   e_x(ic)=xd   & e_y(ic)=yd                ; MCF add
                endif
            endfor
;TJK, change color keyword value below to !d.n_colors-1 instead of zero
;change all "color=0" to color=!d.n_colors-1
;change all settings of xticks=8,yticks=8 to xticks=1,yticks=1 to suppress 
;tick marks. Change the x/ystyle to +4 so that the axis won't be drawn.
            if not keyword_set(NODIPOLES) then begin
              if (ic gt 0)  then begin
                if keyword_set(NOCIRCLES) then begin ; need to call plot
                  plot,e_x(0:ic),e_y(0:ic),position=[x0,y0,x1,y1],$
                         xrange=[x_min,x_max],yrange=[y_min,y_max],xticks=1+4,$
                         yticks=1+4,xstyle=1,ystyle=1,$
                         color=!d.table_size-1,/noerase
                endif else oplot, e_x(0:ic),e_y(0:ic), color=!d.table_size-1
              endif
            endif
        endfor
    endfor
endfor



; Add direction and label of the dipole axis when nadir = 1
if (nadir eq 1) then begin
   x[0] = 0.   & y[0] = 0. & x[1] = x[0] & y[1] = 0.8*x_max
   ;oplot, x,y, color=0
   ;xyouts,x[1],y[1], 'MagDipole', color=0
endif

;TJK, change all settings of xticks=8,yticks=8 to xticks=1,yticks=1 to 
;suppress tick marks.
;change color keyword value below to !d.n_colors-1 instead of zero
;change all "color=0" to color=!d.n_colors-1
;Change the x/ystyle to +4 so that the axis won't be drawn.

; Label the image
if (keyword_set(NOCIRCLES)) and (keyword_set(NODIPOLES)) then begin
  ; Need to call plot with /nodata to set the plot scale since it hasn't been done yet.
  plot,[x_min,x_max],[y_min,y_max],/nodata,xstyle=1+4,ystyle=1+4,$
         xticks=1,yticks=1,color=!d.table_size-1,/noerase,$
         position=[x0,y0,x1,y1]
endif

;xy outs were commented out on 2/21 by RB
;dang=x_max/2 & base=-1.055*x_max
;for i=-2,2 do begin
;    angle=i*dang
;    xyouts,angle,base,string(abs(angle),'(i2)'),alignment=0.5,color=1
;    xyouts,base,angle,string(abs(angle),'(i2)'),alignment=0.5,color=1
;endfor
;xyouts,0.,1.07*base,'degree',alignment=0.5,color=1
;xyouts,1.07*base,-0.07*x_max,'degree',orientation=90,color=1


;TJK, change color keyword value below to !d.n_colors-1 instead of zero
;change all "color=0" to color=!d.n_colors-1
;change all settings of xticks=8,yticks=8 to xticks=1,yticks=1 to suppress 
;tick marks. Change the x/ystyle to +4 so that the axis won't be drawn.

; Add Earth outline and continents when nadir = 1
del = 2.0 * !pi / npt
if (nadir eq 1) then begin
   for ii = 0,npt do begin
      ang = float(ii) * del
      e_x(ii) = e_rad * cos(ang) & e_y(ii) = e_rad * sin(ang)
   endfor
   if not keyword_set(NOEARTH) then begin
     if keyword_set(NOCIRCLES) then begin ; must call plot instead of oplot
        plot,e_x,e_y,position=[x0,y0,x1,y1],$
             xrange=[x_min,x_max],yrange=[y_min,y_max],xticks=1,yticks=1,$
             xstyle=1+4,ystyle=1+4,color=!d.table_size-1,/noerase
     endif else oplot,e_x,e_y,color=!d.table_size-1
   endif
;MCF commented out
;   xm=(x1+x0)/2. & e_radx=e_rad*(x1-x0)/(x_max-x_min)
;   ym=(y1+y0)/2. & e_rady=e_rad*(y1-y0)/(y_max-y_min)
   xm=(x1+x0)/2. & e_radx=e_rad*(x1-x0)*2/(180.+x_max-x_min)     ; MCF begin add
   ym=(y1+y0)/2. & e_rady=e_rad*(y1-y0)*2/(180.+y_max-y_min)     ; MCF end add
   geo_lat=asin(sc_pos_geo(2)/rs)*180./!pi ; geographic lat (deg)
   geo_lon=atan(sc_pos_geo(1),sc_pos_geo(0))*180./!pi ; geographic lon (deg)
;MCF commented out
;   xN=geo_N_sm(0)*x_sat_new(0)+geo_N_sm(1)*x_sat_new(1)+geo_N_sm(2)*x_sat_new(2)
;   yN=geo_N_sm(0)*y_sat_new(0)+geo_N_sm(1)*y_sat_new(1)+geo_N_sm(2)*y_sat_new(2)
;   gamma=90. - atan(yN,xN)*180./!pi ; rotation in deg, clockwise from north
   xN=geo_N_sm(0)*x_sat(0)+geo_N_sm(1)*x_sat(1)+geo_N_sm(2)*x_sat(2) ;MCF begin add
   yN=geo_N_sm(0)*y_sat(0)+geo_N_sm(1)*y_sat(1)+geo_N_sm(2)*y_sat(2) 
   gamma=ang_rotate_d+90.-atan(yN,xN)*180./!pi ; rotation(deg), clockwise from N
                                                                     ;MCF end add
   if not keyword_set(NOEARTH) then begin
      map_set,geo_lat,geo_lon,$
        position=[xm-e_radx,ym-e_rady,xm+e_radx,ym+e_rady],$
        /satellite,sat_p=[rs,0.,gamma],/continents,$
        con_color=!d.table_size-1,/noborder,/noerase
   endif
endif

; Close the GIF file if writing to GIF
if keyword_set(GIF) then begin
  xscale=!x.s & yscale=!y.s & bytemap=tvrd() & tvlct,r,g,b,/get
  s = size(GIF) & ns = n_elements(s)
  if s(ns-2) eq 7 then gname = GIF else gname = 'idl.gif'
  write_gif,gname,bytemap,r,g,b
  device,/close & set_plot,'X'
endif

return,0
end






PRO testplot_enaflux3,imgfile,GIF=GIF,WSIZE=WSIZE,NOCIRCLES=NOCIRCLES,$
NODIPOLES=NODIPOLES,NOEARTH=NOEARTH,$
NOCOLORBAR=NOCOLORBAR,EDGES=EDGES,NOBORDER=NOBORDER
m=0 & d= 0 & monday,2000,100,m,d
cdf_epoch,etime,2000,m,d,/compute & etime=etime+48600000
np=32 & image=fltarr(np,np)
spin_angle=intarr(np) & polar_angle=intarr(np)
for i=0,31 do begin ; compute centers of 4x4 pixels
   spin_angle(i)=-62+i*4 & polar_angle(i)=spin_angle(i)
endfor
nadir=1 ; 1=earthward view, 0=anti-earthward view
openr,1,imgfile
sc_pos_sm=fltarr(3)         & s='' & readf,1,s & reads,s,sc_pos_sm
sc_spin_axis_sm=fltarr(3)   & s='' & readf,1,s & reads,s,sc_spin_axis_sm
sc_pos_geo=fltarr(3)        & s='' & readf,1,s & reads,s,sc_pos_geo
geo_N_sm=fltarr(3)          & s='' & readf,1,s & reads,s,geo_N_sm
np=32 & image=fltarr(np,np) & s=strarr(205)    & readf,1,s & close,1
s2='' & for i=0,204 do s2=s2+s(i)  & reads,s2,image
s=plot_enaflux3(etime,image,spin_angle,polar_angle,np,sc_pos_sm,$
                sc_spin_axis_sm,sc_pos_geo,geo_N_sm,nadir,$
                GIF=GIF,WSIZE=WSIZE,NOCIRCLES=NOCIRCLES,NODIPOLES=NODIPOLES,$
                NOEARTH=NOEARTH,NOCOLORBAR=NOCOLORBAR,EDGES=EDGES,$
                NOBORDER=NOBORDER)
end







FUNCTION plot_enaflux,etime,image,fov,resolution,sc_pos_gci,sc_spinaxis_gci,$
                      nadir,REFORMER=REFORMER,ORBIT=ORBIT,GIF=GIF,WSIZE=WSIZE,$
                      NOCIRCLES=NOCIRCLES,NODIPOLES=NODIPOLES,NOEARTH=NOEARTH,$
                      NOCOLORBAR=NOCOLORBAR,EDGES=EDGES,NOBORDER=NOBORDER,$
                      SMOOTH=SMOOTH,SCALEMIN=SCALEMIN,SCALEMAX=SCALEMAX,$
	              REVERSEORDER=REVERSEORDER,DEBUG=DEBUG

; Convert spacecraft position vector (GCI) and spinaxis (GCI) to SM coords.
year=0 & month=0 & day=0 & hour=0 & minute=0 & sec=0 ; init params for recalc
recalc,year,day,hour,min,sec,epoch=etime ; setup conversion values
; Create scalar variables required when calling geopack routines
xgci=sc_pos_gci(0) & ygci=sc_pos_gci(1) & zgci=sc_pos_gci(2)
xgse=0.0 & ygse=0.0 & zgse=0.0 & xgsm=0.0 & ygsm=0.0 & zgsm=0.0
xsm=0.0 & ysm=0.0 & zsm=0.0 & xgeo=0.0 & ygeo = 0.0 & zgeo=0.0
;
; Perform conversions
geigse,xgci,ygci,zgci,xgse,ygse,zgse,1,etime
gsmgse,xgsm,ygsm,zgsm,xgse,ygse,zgse,-1
smgsm,xsm,ysm,zsm,xgsm,ygsm,zgsm,-1
geigeo,xgci,ygci,zgci,xgeo,ygeo,zgeo,1,epoch=etime
sc_pos_sm = [xsm,ysm,zsm] / 6378.14 ; convert to Re
sc_pos_geo = [xgeo,ygeo,zgeo] / 6378.14 ; convert to Re

; In the event that the spacecraft spin axis unit vector is was not
; available to the user of this function, and given that the plotting code
; makes the assumption that the spin axis is normal to the orbit plane,
; compute what spin_axis should be given the orbit described with right
; ascension of the ascending node and inclination.
if keyword_set(ORBIT) then begin
  raan = orbit(0) * !dtor & incl = orbit(1) * !dtor
  target_ra  = raan - (90.0 * !dtor) & target_dec = (90.0 * !dtor) - incl
  x  = cos(target_dec) * cos(target_ra)
  y  = cos(target_dec) * sin(target_ra)
  z  = sin(target_dec)
  m  = (x^2 + y^2 + Z^2)^0.5
  sc_spinaxis_gci = [x/m,y/m,z/m] * !radeg
endif

; Convert spacecraft spin axis unit vector from gci to sm.
xgci=sc_spinaxis_gci(0) & ygci=sc_spinaxis_gci(1) & zgci=sc_spinaxis_gci(2)
xgse=0.0 & ygse=0.0 & zgse=0.0 & xgsm=0.0 & ygsm=0.0 & zgsm=0.0
xsm=0.0 & ysm=0.0 & zsm=0.0
; Convert spacecraft position vector from gci to sm
geigse,xgci,ygci,zgci,xgse,ygse,zgse,1,etime
gsmgse,xgsm,ygsm,zgsm,xgse,ygse,zgse,-1
smgsm,xsm,ysm,zsm,xgsm,ygsm,zgsm,-1
; Convert units from kilometers to earth_radii
re = 6378.14 & sc_spinaxis_sm = [xsm/re,ysm/re,zsm/re]

; if producing debug output then output a dot product analysis
if keyword_set(DEBUG) then begin
  dot=fltarr(3) & for i=0,2 do dot(i) = sc_spinaxis_sm(i) * sc_pos_sm(i)
  print,'INFO>plot_enaflux>DOT(pos,spin)=',dot,' = ',total(dot)
endif
 
; Compute geographic northpole in solar magnetospheric coordinates
geogsm,0.0,0.0,1.0,xgsm,ygsm,zgsm,1 ; convert northpole to gsm
smgsm,xsm,ysm,zsm,xgsm,ygsm,zgsm,-1 ; convert to sm
geo_N_sm = [xsm,ysm,zsm] / re

; Determine the size of the image and verify that it is square
s = size(image) & ns = n_elements(s)
if s(0) ne 2 then begin
  print,'ERROR>image parameter is not two dimensional' & return,-1
endif

if s(1) ne s(2) then begin
  if not keyword_set(REFORMER) then begin
    print,'ERROR>image parameter is not square and /REFORMER keyword not set'
    return,-1
  endif else begin
    np = max([s(1),s(2)]) & image = reform(image,np,np)
  endelse
endif else np = s(1)

; Given the field of view and angular resolution (both degrees) of the
; instrument which took the image, and assuming that the image is centered
; on the earth, derive the viewing angles in X (spin) and Y (polar).
;spin_angle = intarr(np) & polar_angle = intarr(np)
;start_spin_angle = -1 * fix(0.5 * fov)
;for i=0,np-1 do begin
;  spin_angle(i) = start_spin_angle  + (i*resolution) + (0.5 * resolution)
;  polar_angle(i) = spin_angle(i) ; valid estimate because of square image
;endfor
spin_angle = fltarr(np) & polar_angle = fltarr(np)
start_spin_angle = -1. * fix(0.5 * fov)
for i=0,np-1 do begin
  spin_angle(i) = start_spin_angle + (i * resolution) + (0.5 * resolution)
  polar_angle(i) = spin_angle(i) ; valid estimate because of square image
endfor

;
; Generate debug output for MeiChing
if keyword_set(DEBUG) then begin
  print,'INFO>plot_enaflux3>sc_pos_sm=',sc_pos_sm
  print,'INFO>plot_enaflux3>sc_spinaxis_sm=',sc_spinaxis_sm
  print,'INFO>plot_enaflux3>sc_pos_geo=',sc_pos_geo
  print,'INFO>plot_enaflux3>geo_N_sm=',geo_N_sm
endif
;
; Generate the plot
s = plot_enaflux3(etime,image,spin_angle,polar_angle,np,sc_pos_sm,$
                            sc_spinaxis_sm,sc_pos_geo,geo_N_sm,nadir,GIF=GIF,$
                            WSIZE=WSIZE,NOCIRCLES=NOCIRCLES,NODIPOLES=NODIPOLES,$
                            NOEARTH=NOEARTH,NOCOLORBAR=NOCOLORBAR,EDGES=EDGES,$
                            NOBORDER=NOBORDER,SMOOTH=SMOOTH,DEBUG=DEBUG,$
                            SCALEMAX=SCALEMAX,SCALEMIN=SCALEMIN,REVERSEORDER=REVERSEORDER)
return,s
end

pro plot_enaflux5
end








