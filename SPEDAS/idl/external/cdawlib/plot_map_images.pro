;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/plot_map_images.pro,v 1.140 2009/01/30 19:36:18 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $
;
;--------------------------------------------------------------
FUNCTION vec_norm,v
    RETURN, SQRT(DOUBLE(v(0)*v(0) + v(1)*v(1) + v(2)*v(2)))
END
;--------------------------------------------------------------

FUNCTION unit_vec,v                                                            
    RETURN, v/vec_norm(v)
END

;--------------------------------------------------------------

PRO rot_con,system,xcon,ycon,nxpix,nypix,roti_val

;COMMON STATIC,nxpix,nypix,border,ylabl,xcbar,charsiz,xwin,ywin

CASE system OF
   1: BEGIN
      ;xcon = 1.14*(200. - xcon)
      xcon = 1.14*(nxpix - xcon)
      ;ycon = 228. - ycon
      ycon = nypix - ycon
      END
   ;2: xcon = 1.14*(200. - xcon)
   2: xcon = 1.14*(nxpix - xcon)
   ELSE: print, 'ERROR=No System variable found'
ENDCASE

tempx = xcon
tempy = ycon
CASE roti_val OF
   0: ;do nothing
   1: BEGIN
      xcon = nypix - tempy
      ycon = tempx
      END
   2: BEGIN
      xcon = nypix - tempx
      ycon = nypix - tempy
      END
   3: BEGIN
      xcon = tempy
      ycon = nypix - tempx
      END
ENDCASE

END

;+------------------------------------------------------------------------
; Procedure Name:       lltodr
;       Author:  J. M. O'Meara
; Purpose:  Convert latitude/longitude to  3-D position vector   
;
; INPUTS:
;   lat                   Latitude of the point on the earth
;   lon                   Longitude of the point on the earth
;   r                     Radius scalar
;
; Outputs:
;               x,y,z                 3-D position vector
;------------------------------------------------------------------------
PRO lltodr,lat,lon,r,x,y,z

dtor = !DPI/180.D
theta = (90D - lat)*dtor
phi = lon*dtor
x = r*SIN(theta)*COS(phi)
y = r*SIN(theta)*SIN(phi)
z = r*COS(theta)

END
;+------------------------------------------------------------------------
; PROGRAM NAME:  lltopix
; Purpose:  Calculate the row,col pixel locations of a point, given
;           the latitude and longitude of the point on the earth
;           and the spacecraft's orbit and attitude
;
; INPUTS:
;          lat           Latitude of the point on the earth
;          lon           Longitude of the point on the earth
;          emis_hgt      Radiation emission height (km)
;          xax           X axis: direction of l0
;          yax           Y axis: zax X xax
;          zax           Z axis: direction in plane of xax and att perp to xax
;          orb           GCI orbital postion (km)
;          epoch         CDF time
;
; OUTPUTS:
;          row           Pixel row location
;          col           Pixel column location
;          angle         Angle between Lpix and pos
;
; PROGRAM CALLS:
;          geigeo
; AUTHOR:
;       Rich Baldwin,  Raytheon STX
;-------------------------------------------------------------------------
PRO lltopix,lat,lon,emis_hgt,xax,yax,zax,orb,system,$
          row_arr,col_arr,angle,epoch

fov =   DOUBLE(8.0)
ncols = 200
nrows = 228
pc =    DOUBLE(fov/ncols)
pr =    DOUBLE(fov/nrows)
dtor =  !DPI/180.D
rtod =  180.D/!DPI

;radius of the earth (km)
r = 6371.D + emis_hgt

;convert latitude,longitude to p_geo vector
lltodr,lat,lon,r,x,y,z

; RTB replace  MSFC GEO to GEI routine w/ geopack
j=0
geigeo,posx,posy,posz,x,y,z,j,epoch=epoch

tmpx = posx - orb(0)
tmpy = posy - orb(1)
tmpz = posz - orb(2)

Ntmp = SQRT(tmpx*tmpx + tmpy*tmpy + tmpz*tmpz)
Npos = SQRT(posx*posx + posy*posy + posz*posz)

; obtain unit vector in look direction for this pixel
lpixx = tmpx/Ntmp
lpixy = tmpy/Ntmp
lpixz = tmpz/Ntmp

; Determine angle between Lpix and pos
angle = ACOS((lpixx*posx + lpixy*posy + lpixz*posz)/Npos)

; Determine projections of lpix on the x, y and z axes
lx = lpixx*xax(0) + lpixy*xax(1) + lpixz*xax(2)
ly = lpixx*yax(0) + lpixy*yax(1) + lpixz*yax(2)
lz = lpixx*zax(0) + lpixy*zax(1) + lpixz*zax(2)

yrot = rtod*ATAN(lz,lx)
zrot = rtod*ATAN(ly,lx)

CASE system OF
   1: BEGIN
      row_arr = -yrot/pr +  113.5
      col_arr = zrot/pc + 99.5
      END
   2: BEGIN
      row_arr = yrot/pr + 113.5
      col_arr = zrot/pc + 99.5
      END
   ELSE: BEGIN
      PRINT,'Failure in system variable [pro: lltopix]'
      RETURN
      END
ENDCASE

END

;+------------------------------------------------------------------------
; NAME: GRID_MAP 
; PURPOSE: To overlay a map grid on top of an image 
; CALLING SEQUENCE:
;        out = grid_map( )
; INPUTS:
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       Rich Baldwin,  Raytheon STX
;
;-------------------------------------------------------------------------
; testing continent outline option; need sat_pos
;PRO grid_map,alat,alon,idat,pos,sun_term,sat_pos,xpimg,ypimg, $
PRO grid_map,alat,alon,idat,pos,sun_term,xpimg,ypimg, $
             CONTINENT=CONTINENT, GRID=GRID, POLE_N=POLE_N, POLE_S=POLE_S,$
             TERMINATOR=TERMINATOR, LABEL=LABEL, _Extra=extra
rad=!pi/180.0

if NOT keyword_set(CONTINENT) then CONTINENT=0
if NOT keyword_set(GRID) then GRID=0
if NOT keyword_set(LABEL) then LABEL=0
if NOT keyword_set(POLE_N) then POLE_N=0
if NOT keyword_set(POLE_S) then POLE_S=0
if NOT keyword_set(TERMINATOR) then TERMINATOR=0
;
; Determine boundry of lat and lon arrays

ncd= where(alon gt 180.0,ncdn) 
if(ncdn ne 0) then alon(ncd)=alon(ncd)-360.0

idat=congrid(idat,xpimg,ypimg)
alat=congrid(alat,xpimg,ypimg)
alon=congrid(alon,xpimg,ypimg)

cond = (alat lt -90.) or (alat gt 90.0) or (alon lt -180.) or (alon gt 180.)
wBad = where(cond, wBadn);
;print, wBadn
;if(wBadn gt 0) then begin
wGood = where(cond ne 1,wGoodn)
; if(wGoodn le 0) then message, 'No good values to display'
if(wGoodn le 0) then begin
   print, "ERROR= No good values to display"
   print, "STATUS= No good values to display. Select another time interval."
   return
endif
; 
asize=size(alat)
glat=alat(wGood)
glon=alon(wGood)
latmin=min(glat,max=latmax)
lonmin=min(glon,max=lonmax)
; 
; print, latmin,latmax,lonmin,lonmax
;
;endif
; Regrid input arrays and tv image

;    idat=congrid(idat,xpimg,ypimg)
;    alat=congrid(alat,xpimg,ypimg)
;    alon=congrid(alon,xpimg,ypimg)
if(NOT CONTINENT) then tv,idat,pos(0),pos(1),_Extra=extra
;tv,idat,pos(0),pos(1),/device   
;tv,idat,pos(0),pos(1),/normal   

; plot window

xrange=[0,xpimg]
;xrange=[0,228]
yrange=[0,ypimg]
;yrange=[0,228]
  
plot,[0.0],[0.0],/nodata, XRANGE=xrange, YRANGE=yrange, POSITION=pos, $
   /noerase, xstyle=13, ystyle=13, _Extra=extra
   ;/noerase, xstyle=13, ystyle=13, /device 
   ;/noerase, xstyle=13, ystyle=13, /normal

if(CONTINENT) then begin
   ; Test case for continent outlines
   junk=where(idat ge 255)
   cols=junk MOD asize(1)
   rows=junk / asize(2)
   bbox= [min(cols),min(rows),max(cols),max(rows)]
   bbcenter=[(bbox[2]-bbox[0])*0.5 + bbox[0], (bbox[3]-bbox[1])*0.5 + bbox[1]]
   bbcenter = fix(bbcenter)
   center = where(glat EQ max(glat))
   center = center[0]
   c_col = center MOD size(1)
   c_row = center / size(2)
   gamma = atan(bbcenter[0]-c_col, bbcenter[1]-c_row)*!RADEG
   gamma = 360.0 - gamma
   print, gamma
   print, bbox
   print, bbcenter
   map_set, /satellite, sat_p=[norm(sat_pos)/6371.0, 0, gamma], $
      glat[bbcenter[0]],glon[bbcenter[1]],/continents,/noborder
   junk = tvrd()
   subi = idat(bbox[0]:bbox[2],bbox[1]:bbox[3])
   j = where(junk gt 0)
   subi(j) = 255
   idat(bbox[0]:bbox[2],bbox[1]:bbox[3]) = subi
   tv,idat,pos(0),pos(1),_Extra=extra
 
   ; Extremely CPU intesive
   ; Restore continent outline   
   ;    restore, '/home/rumba/cdaweb/lib/ciamap.sav'
   ;    cond1 = (clat le latmax) and (clat ge latmin) and (clon le lonmax) and (clon ge lonmin)
   ;    wgc= where(cond1, wgn)
   ;
   ;    gclat=clat(wgc)
   ;    gclon=clon(wgc)
   ;
   ;
   ;          OPLOT,xcon(i:i+1),ycon(i:i+1), $
   ;               COLOR=!d.n_colors-1
   ;          i = i + 1
endif

; add pole
if(POLE_N) then begin
   ; N pole
   contour, alat, levels=[89.0,90.0],COLOR=!d.n_colors-1,xstyle=13,ystyle=13,$
      XRANGE=xrange, YRANGE=yrange,POSITION=pos,/noerase,max_value=90.0,$
      _Extra=extra
endif 

if(POLE_S) then begin
   ; S pole
   contour, alat, levels=[-90.0,-89.0],COLOR=!d.n_colors-1,xstyle=13,ystyle=13,$
      XRANGE=xrange, YRANGE=yrange,POSITION=pos,/noerase,min_value=-90.0$
      ,_Extra=extra
endif

; add grid lines and labels
if(GRID) then begin
   ; draw latitude and longitude lines
   lon_levels=[-180,-135,-90,-45,0.,45,90,135]
   ;lat_levels=[-80,-70,-60,-50,-40,-30,-20,-10,10,20,30,40,50,60,70,80]
   lat_levels=[-80,-60,-40,-20,20,40,60,80]
   if(LABEL) then begin
      ;      lat_labels=[1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1] 
      lat_labels=[1,1,1,0,0,1,1,1] 
      lon_labels=[1,1,1,1,1,1,1,1]
   endif else begin
      lat_labels=[0,0]
      lon_labels=[0,0]
   endelse
   contour, alat,levels=lat_levels,COLOR=!d.n_colors-1,xstyle=13,ystyle=13,$
      XRANGE=xrange, YRANGE=yrange,POSITION=pos,/noerase,max_value=90.0,$
      min_value=-90.0, c_labels=lat_labels, _Extra=extra

   contour, alon,levels=lon_levels,COLOR=!d.n_colors-1,xstyle=13,ystyle=13,$
      XRANGE=xrange, YRANGE=yrange,POSITION=pos,/noerase,max_value=180.0,$
      min_value=-180.0, c_labels=lon_labels,_Extra=extra
endif

; add terminator 
if(TERMINATOR) then begin
   ;  sun_term structure of latitude and longitudes of terminator position
   slat=sun_term.lat
   slon=sun_term.lon
   num=n_elements(slat)
   plat=fltarr(num)
   plon=fltarr(num)
   cond1 = (slat le latmax) and (slat ge latmin) and (slon le lonmax) and (slon ge lonmin)
   wgc= where(cond1, wgn)
   slat=slat(wgc)                                                             
   slon=slon(wgc)
   r=1.0 
   ; Loop through each terminator position
   for l=0,n_elements(slat)-1 do begin
      ; Convert position from spherical to rectangular coordinates
      ;    ssph=[slat(l),slon(l),r] 
      x=r*cos(slat(l)*rad)*sin(slon(l)*rad)
      y=r*sin(slat(l)*rad)*sin(slon(l)*rad)
      z=r*cos(slon(l)*rad)
      srec=[x,y,z] 
      ;    srec=cv_coord(FROM_SPHERE=ssph,/TO_RECT,/DEGREES)
      ; Set default distance
      dis=100000.0
      ; Evaluate each lat,lon position determining the 
      for i=0,asize(1)-1 do begin
         last_dist=alat(i,0) 
         for j=0,asize(2)-1 do begin
            cond = (alat(i,j) ge -90.) and (alat(i,j) le 90.0) and $
	       (alon(i,j) ge -180.) and (alon(i,j) le 180.)
            if(cond) then begin
               x=r*cos(alat(i,j)*rad)*sin(alon(i,j)*rad)
               y=r*sin(alat(i,j)*rad)*sin(alon(i,j)*rad)
               z=r*cos(alon(i,j)*rad)
               arec=[x,y,z]
               ;        asph=[alat(i,j),alon(i,j),r] 
               ;        arec=cv_coord(FROM_SPHERE=ssph,/TO_RECT,/DEGREES)
               dot=srec*arec
               dot_prod=dot(0)+dot(1)+dot(2)
               theta=acos(dot_prod/(r*r))
               arc_dist=r*theta
               if(arc_dist lt dis) then begin
                  dis=arc_dist
                  xpixel=i
                  ypixel=j
                  if(j eq 0) then pp_dist=2.0 else pp_dist=alat(i,j)-lastdist
               endif
               lastdist=alat(i,j)
            endif
         endfor
      endfor
      latdif=alat(xpixel,ypixel)-slat(l)
      londif=alon(xpixel,ypixel)-slon(l)
      dxpixel=latdif/pp_dist
      dypixel=londif/pp_dist
      ; fine adjustment of pixel location; not working 8/26/98
      if(abs(dxpixel) gt 1.0) then dxpixel=0.0 
      if(abs(dypixel) gt 1.0) then dypixel=0.0 
      plat(l)=xpixel+dxpixel
      plon(l)=ypixel+dypixel
   endfor
   ; plot points
   WHILE i LE n_elements(plat)-2 DO BEGIN
      ;    OPLOT,plat,plon, COLOR=!d.n_colors-1, thick=1.2
      OPLOT,plat(i:i+1),plon(i:i+1), COLOR=!d.n_colors-1, thick=1.2
      i = i + 1
   ENDWHILE
endif

END

;+------------------------------------------------------------------------
; NAME: GRID_UVI 
; PURPOSE: To overlay a map grid on top of image polar uvi images
; CALLING SEQUENCE:
;        out = grid_uvi( )
; INPUTS:
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       Rich Baldwin,  Raytheon STX
;
;-------------------------------------------------------------------------
PRO grid_uvi,orb,att,dsp_angle,filter,system,idat,pos,$
         xpimg,ypimg,epoch,sun_term,nxpix,nypix,$
         CONTINENT=CONTINENT,GRID=GRID,POLE=POLE,TERMINATOR=TERMINATOR,$
         LABEL=LABEL,_Extra=extra
    
if NOT keyword_set(CONTINENT) then CONTINENT=0
if NOT keyword_set(GRID) then GRID=0
if NOT keyword_set(LABEL) then LABEL=0
if NOT keyword_set(POLE) then POLE=0
if NOT keyword_set(TERMINATOR) then TERMINATOR=0

roti_val=3
emis_hgt=120.0
pi2 = 0.5*!DPI

; Compute look direction
cdf_epoch, epoch, yr,mn,dy,hr,min,sec,milli,/break
ical,yr,doy,mn,dy,/idoy
time=fltarr(2)
time(0)=yr*1000+doy
time(1)=(hr*(3600)+min*60+sec)*1000+milli
; UVI primary image fix for times prior to 12/96; RTB 11/10/98
if(fix(yr) eq 1996) then begin
   if(doy lt 337) then begin
      idat=rotate(idat,3) 
      idat=transpose(idat)
   endif
endif

uvilook,time,orb,att,dsp_angle,filter,dummy,L0,system=system

xax = unit_vec(L0)
yax = unit_vec(CROSSP(att,L0))
zax = unit_vec(CROSSP(xax,yax))

idat=congrid(idat,xpimg,ypimg)
tv,idat,pos(0),pos(1),_Extra=extra
;tv,idat,pos(0),pos(1),/device   
;tv,idat,pos(0),pos(1),/normal   

; plot window

;xrange=[0,xpimg]
xrange=[0,228]
;yrange=[0,ypimg]
yrange=[0,228]
  
;plot,[0.0],[0.0],/nodata, XRANGE=xrange, YRANGE=yrange, POSITION=pos, $
plot,[0.0],[0.0], XRANGE=xrange, YRANGE=yrange, POSITION=pos, $
   /noerase, xstyle=13, ystyle=13, _Extra=extra
   ;/noerase, xstyle=13, ystyle=13, /device 
   ;/noerase, xstyle=13, ystyle=13, /normal

if(CONTINENT) then begin
   ; Resotore continent outline   
;   restore, '/home/rumba/cdaweb/lib/ciamap.sav'
   restore, '/home/cdaweb/lib/ciamap.sav'
   ; draw continents
   lltopix,clat,clon,emis_hgt,xax,yax,zax, $
      orb,system,ycon,xcon,acon,epoch

   andx = WHERE(acon GT pi2 AND xcon GE 0. AND ycon GE 0. AND $
      xcon LT 228. AND ycon LT 228.,npts)
   IF (npts GT 1) THEN BEGIN
      xcon = xcon(andx)
      ycon = ycon(andx)
      rot_con,system,xcon,ycon,nxpix,nypix,roti_val
      i = 0
      clim =   5.0
      WHILE i LE npts-2 DO BEGIN
         IF (ABS(xcon(i+1)-xcon(i)) LT clim) AND $
            (ABS(ycon(i+1)-ycon(i)) LT clim) THEN $
            OPLOT,xcon(i:i+1),ycon(i:i+1),COLOR=!d.n_colors-1
            i = i + 1
      ENDWHILE
   ENDIF
endif

; add pole
if(POLE) then begin
   nsides = 6
   avec = findgen(nsides) * (!pi*2/nsides)
   usersym, cos(avec), sin(avec), /fill
   ; N pole
   lltopix,[90.0,90.0],[0.0,0.0],emis_hgt,xax,yax,zax, $
      orb,system,ycon,xcon,acon,epoch

   andx = WHERE(acon GT pi2 AND xcon GE 0. AND ycon GE 0. AND $
                   xcon LT 228. AND ycon LT 228.,npts)
   IF (npts GT 1) THEN BEGIN
      xcon = xcon(andx)
      ycon = ycon(andx)
      rot_con,system,xcon,ycon,nxpix,nypix,roti_val
      if((xcon(0) ne xcon(1)) and (ycon(0) ne ycon (1))) then $ 
         OPLOT,[xcon],[ycon],psym=8,COLOR=!d.n_colors-1,SYMSIZE=symsize,nsum=2
   ENDIF

   ; S pole
   lltopix,[-90.0,-90.0],[0.0,0.0],emis_hgt,xax,yax,zax, $
      orb,system,ycon,xcon,acon,epoch

   andx = WHERE(acon GT pi2 AND xcon GE 0. AND ycon GE 0. AND $
                   xcon LT 228. AND ycon LT 228.,npts)
   IF (npts GT 1) THEN BEGIN
      xcon = xcon(andx)
      ycon = ycon(andx)
      rot_con,system,xcon,ycon,nxpix,nypix,roti_val
      OPLOT,[xcon],[ycon],psym=8,COLOR=!d.n_colors-1,SYMSIZE=symsize
   ENDIF
endif 

; add grid lines and labels
if(GRID) then begin
   ; draw latitude and longitude lines
   latdel=10.
   londel=45.
   ; draw latitude circles
   nlat = FIX((180.)/latdel)
   nlon = 180
   dlon = 360./(nlon-1)
   FOR i=1,nlat-1 DO BEGIN
      latv = 90. - i*latdel
      glat = REPLICATE(latv,nlon)
      glon = dlon*FINDGEN(nlon)
      lltopix,glat,glon,emis_hgt,xax,yax,zax,orb,system,$
         ycon,xcon,acon,epoch
      andx = WHERE(acon GT pi2 AND xcon GE 0. AND ycon GE 0. AND $
                  xcon LT 228. AND ycon LT 228.,npts)
      IF (npts GT 1) THEN BEGIN
         xcon = xcon(andx)
         ycon = ycon(andx)
         rot_con,system,xcon,ycon,nxpix,nypix,roti_val
         j = 0
         clim =   50.0
         WHILE j LE npts-2 DO BEGIN
            IF (ABS(xcon(j+1)-xcon(j)) LT clim) AND $
               (ABS(ycon(j+1)-ycon(j)) LT clim) THEN $
               OPLOT,xcon(j:j+1),ycon(j:j+1),COLOR=!d.n_colors-1
               j = j + 1
         ENDWHILE
         ;      if(LABEL) then begin
         ;       xyouts,xcon(0),ycon(0),strtrim(fix(latv),2),charsize=1.2,$
         ;             color=!d.n_colors-1
         ;      endif
      ENDIF
   ENDFOR

   ; draw longitude lines
   nlat = 90.
   nlon = FIX(360./londel)
   dlat = 180./(nlat-1.)
   FOR i=0,nlon-1 DO BEGIN
      lonv = i*londel
      glon = REPLICATE(lonv,nlat)
      glat = -90. + dlat*FINDGEN(nlat)
      lltopix,glat,glon,emis_hgt,xax,yax,zax,orb,system,$
         ycon,xcon,acon,epoch
      andx = WHERE(acon GT pi2 AND xcon GE 0. AND ycon GE 0. AND $
         xcon LT 228. AND ycon LT 228.,npts)
      IF (npts GT 1) THEN BEGIN
         xcon = xcon(andx)
         ycon = ycon(andx)
         rot_con,system,xcon,ycon,nxpix,nypix,roti_val
         j = 0
         clim =   100.0
         WHILE j LE npts-2 DO BEGIN
            OPLOT,xcon(j:j+1),ycon(j:j+1),COLOR=!d.n_colors-1
            j = j + 1
         ENDWHILE
         ;      if(LABEL) then begin
         ;        xyouts,xcon(0),ycon(0),strtrim(fix(lonv),2),charsize=1.2,$
         ;              color=!d.n_colors-1
         ;       endif
      ENDIF
   ENDFOR
endif

; new testing
if(LABEL) then begin
   ; Do latitudes 
   alat=-90.0+30.0*findgen(7)
   alon=[0.0,180.0]
   FOR i=0,6 DO BEGIN
      FOR j=0,1 DO BEGIN
         ;lltopix,[-90.0,-90.0],[0.0,0.0],emis_hgt,xax,yax,zax, $
         lltopix,[alat(i),alat(i)],[alon(j),alon(j)],emis_hgt,xax,yax,zax, $
            orb,system,ycon,xcon,acon,epoch
         andx = WHERE(acon GT pi2 AND xcon GE 0. AND ycon GE 0. AND $
            xcon LT 228. AND ycon LT 228.,npts)
         IF (npts GT 1) THEN BEGIN
            xcon = xcon(andx)
            ycon = ycon(andx)
            rot_con,system,xcon,ycon,nxpix,nypix,roti_val
            ;OPLOT,[xcon],[ycon],psym=8,COLOR=!d.n_colors-1,SYMSIZE=symsize
            xyouts,[xcon],[ycon],strtrim(fix(alat(i)),2),charsize=1.2,$
               color=!d.n_colors-1
         ENDIF
      ENDFOR
   ENDFOR
   ; DO longitudes
   alon=-180.0+45.0*findgen(9)
   alat=[-70.0,-20.0,20.0,70.0]
   FOR i=0,8 DO BEGIN
      FOR j=0,3 DO BEGIN
         ;lltopix,[-90.0,-90.0],[0.0,0.0],emis_hgt,xax,yax,zax, $
         lltopix,[alat(j),alat(j)],[alon(i),alon(i)],emis_hgt,xax,yax,zax, $
            orb,system,ycon,xcon,acon,epoch

         andx = WHERE(acon GT pi2 AND xcon GE 0. AND ycon GE 0. AND $
            xcon LT 228. AND ycon LT 228.,npts)
         IF (npts GT 1) THEN BEGIN
            xcon = xcon(andx)
            ycon = ycon(andx)
            rot_con,system,xcon,ycon,nxpix,nypix,roti_val
            ;OPLOT,[xcon],[ycon],psym=8,COLOR=!d.n_colors-1,SYMSIZE=symsize
            xyouts,[xcon],[ycon],strtrim(fix(alon(i)),2),charsize=1.2,$
               color=!d.n_colors-1
         ENDIF
      ENDFOR
   ENDFOR
endif

; add terminator 
if(TERMINATOR) then begin
   ;ws=where(sun_term.lat gt 0.0,wsn)
   ;if(wsn ne 0) then slat=sun_term.lat(ws) else slat=sun_term.lat
   ;if(wsn ne 0) then slon=sun_term.lon(ws) else slon=sun_term.lon
   slat=sun_term.lat
   slon=sun_term.lon
   lltopix,slat,slon,emis_hgt,xax,yax,zax, $
      orb,system,ycon,xcon,acon,epoch

   andx = WHERE(acon GT pi2 AND xcon GE 0. AND ycon GE 0. AND $
      xcon LT 228. AND ycon LT 228.,npts)
   IF (npts GT 1) THEN BEGIN
      xcon = xcon(andx)
      ycon = ycon(andx)
      rot_con,system,xcon,ycon,nxpix,nypix,roti_val
      i = 0
      clim =   20.0 ;5.0
      WHILE i LE npts-2 DO BEGIN
         IF (ABS(xcon(i+1)-xcon(i)) LT clim) AND $
            (ABS(ycon(i+1)-ycon(i)) LT clim) THEN $
            OPLOT,xcon(i:i+1),ycon(i:i+1), COLOR=!d.n_colors-1, thick=1.2 
            i = i + 1
      ENDWHILE
   ENDIF
endif

END
;+------------------------------------------------------------------------
; NAME: PLOT_MAP_IMAGES
; PURPOSE: To plot the map image data given in the input parameter astruct.
;          Can plot as "thumbnails" or single frames.
; CALLING SEQUENCE:
;       out = plot_map_images(astruct,vname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;       vname   = name of the variable in the structure to plot
;
; KEYWORD PARAMETERS:
;    CENTERLONLAT = 2 element array of map center [longitude, latitude]
;       THUMBSIZE = size (pixels) of thumbnails, default = 40 (i.e. 40x40)
;       FRAME     = individual frame to plot
;       XSIZE     = x size of single frame
;       YSIZE     = y size of single frame
;       GIF       = name of gif file to send output to
;       REPORT    = name of report file to send output to
;       TSTART    = time of frame to begin imaging, default = first
;       frame
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
FUNCTION plot_map_images, astruct, vname, CENTERLONLAT=CENTERLONLAT,$
                      THUMBSIZE=THUMBSIZE, FRAME=FRAME, $
                      XSIZE=XSIZE, $
		      ;YSIZE=YSIZE, 
		      GIF=GIF, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                      CDAWEB=CDAWEB,DEBUG=DEBUG,COLORBAR=COLORBAR


; Determine the field number associated with the variable 'vname'
w = where(tag_names(astruct) eq strupcase(vname))
if (w[0] eq -1) then begin
   print,'ERROR=No variable with the name:',vname,' in param 1!' & return,-1
endif else vnum = w[0]

projection='MLT'  ; this is the default
; Zvar = astruct.(vnum) ;  not used anywhere

;TJK - 3/3/2004 - add code to set up log scaling.

a = tagindex('SCALETYP',tag_names(astruct.(vnum)))
if(a(0) ne -1) then begin
	logZ= astruct.(vnum).SCALETYP
	if (logZ eq '') then logZ = 0 ;the attribute might exist but not have a value
endif else logZ = 0

;TJK - 4/8/2004 - look for function "convert_log10" - this means data has already been
;converted to log 10 and we need to do some special things for the min. val for colorbar.
;TJK - 11/5/2004 - change FUNCTION to FUNCT for compatibility w/ IDL6.*
;a = tagindex('FUNCTION',tag_names(astruct.(vnum)))
a = tagindex('FUNCT',tag_names(astruct.(vnum)))
func = ''
log10Z = 0
if(a(0) ne -1) then begin
	func= astruct.(vnum).(a(0)) 
	if (strupcase(func) eq 'CONVERT_LOG10') then log10Z = 1 
endif

if keyword_set(COLORBAR) then begin
   COLORBAR=1 
   xco=80
endif else begin
   COLORBAR=0
   xco=0 
endelse    
;if(NOT keyword_set(CENTERLONLAT)) then CENTERLONLAT=[90.0,0.0]

if keyword_set(REPORT) then reportflag=1 else reportflag=0

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

; The DISPLAY_TYPE attribute may contain the THUMBSIZE  RTB
; The THUMBSIZE must be followed by the size in pixels of the images
wc=where(keywords eq 'THUMBSIZE')
if(wc[0] ne -1) then THUMBSIZE = fix(keywords(wc(0)+1))

;TJK 01/09/2004 - added map_proj into the syntax for the display_type
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

if (n_elements(map_proj) gt 0) then begin
  projection = proj_names(map_proj)	
  if keyword_set(DEBUG) then print, 'Requested ',projection
endif

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

; Check that lons are b/w -180 and 180
wcg=where(glon gt 180.0)
if(wcg[0] ne -1) then glon(wcg)=glon(wcg)-360.0

; Assign Sun Position
;TERMINATOR=0L
;sun_name='' 
;if(n_elements(ipts) eq 3) then begin ; Make sure display type has 3 elements
; a = tagindex(strtrim(ipts(2),2),tag_names(astruct))
; if(a(0) ne -1) then begin
;    snames=tag_names(astruct)
;    sun_name=snames(a(0))
;    a1=tagindex('DAT',tag_names(astruct.(a(0))))
;     if(a1(0) ne -1) then gci_sun = astruct.(a(0)).DAT $
;     else begin
;      a2 = tagindex('HANDLE',tag_names(astruct.(a(0))))
;      if (a2(0) ne -1) then handle_value,astruct.(a(0)).HANDLE,gci_sun $
;      else begin
;        print,'ERROR= 4th parameter does not have DAT or HANDLE tag'
;        return,-1
;      endelse
;     endelse
;   TERMINATOR=1L
; endif else begin
;  print, 'WARNING= ',sun_name,' variable not defined in structure (plot_map_images)'
;  TERMINATOR=0L
; endelse
;endif

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

   ;wcn=where(strupcase(keywords) eq sun_name,wc)
   wc=where(strupcase(keywords) eq 'SUN')
   if(wc[0] ne -1) then SUN = 1 else SUN = 0 
   wc=where(strupcase(keywords) eq 'TERMINATOR')
   if(wc[0] ne -1) then TERMINATOR = 1 else TERMINATOR = 0
   wc=where(strupcase(keywords) eq 'FIXED_IMAGE')
   if(wc[0] ne -1) then FIXED_IMAGE = 1 else FIXED_IMAGE = 0
   wc=where(strupcase(keywords) eq 'MLT_IMAGE')
   if(wc[0] ne -1) then MLT_IMAGE = 1 else MLT_IMAGE = 0
endif

if (MLT_IMAGE) then TERMINATOR=0
     
; If Sun position is to be used; create instance 
;  if(SUN) then begin
;   a0=tagindex(tag_names(astruct),sun_name)
;   if(a0 ne -1) then handle_value, astruct.(a0).handle, sun_data 
;  endif

; Check Descriptor Field for Instrument Specific Settings
tip = tagindex('DESCRIPTOR',tag_names(astruct.(vnum)))
if (tip ne -1) then begin
   descriptor=str_sep(astruct.(vnum).descriptor,'>')
endif

; Get ancillary data if FIXED_IMAGE flag is set in DISPLAY_TYPE for UVI
if((FIXED_IMAGE) and (descriptor(0) eq 'UVI')) then begin
   handle_value,astruct.system.HANDLE,sys
   handle_value,astruct.dsp_angle.handle, dsp
   handle_value,astruct.filter.handle, filt
   handle_value,astruct.gci_position.handle, gpos
   handle_value,astruct.attitude.handle, attit
endif

; Determine which variable in the structure is the 'Epoch' data and retrieve it
b = astruct.(vnum).DEPEND_0  
c = tagindex(b(0),tag_names(astruct))
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
if keyword_set(nonoise) then window_title=window_title+'!CConstrained values within >3-sigma from mean of all plotted values'

; Determine title for colorbar
if(COLORBAR) then begin
   a=tagindex('UNITS',tag_names(astruct.(vnum)))
   if(a(0) ne -1) then ctitle = astruct.(vnum).UNITS else ctitle=''
endif

if keyword_set(XSIZE) then xs=XSIZE else xs=512 ;xs is overwritten for 1 image
; ys is overwritten for 1 or many images
;if keyword_set(YSIZE) then ys=YSIZE else ys=512 

; Perform special case checking...
;vkluge=0 ; initialize
;tip = tagindex('PLATFORM',tag_names(astruct.(vnum)))
;if (tip ne -1) then begin
;  if (astruct.(vnum).platform eq 'Viking') then vkluge=1
;endif

; Determine if data is a single image, if so then set the frame
; keyword because a single thumbnail makes no sense
; Define indices of image mid-point
isize = size(idat)
mid1=isize(1)/2+1
mid2=isize(2)/2+1
; FRAME = 0 in plotmaster for each new buffer
; if NOT keyword_set(FRAME) then FRAME=0  ; Reset Frame for multiple structures
;                                        ; w/ image data RTB 4/98
if (isize(0) eq 2) then n_images=1 else n_images=isize(isize(0))
if (n_images eq 1) then FRAME=1

if keyword_set(FRAME) then begin ; produce plot of a single frame
   if ((FRAME ge 1)AND(FRAME le n_images)) then begin ; valid frame value

      idat = idat(*,*,(FRAME-1)) ; grab the frame
      if (size(glat, /n_dimensions) eq 3) then $
        glat = glat(*,*,(FRAME-1)) 
      if (size(glon, /n_dimensions) eq 3) then $
        glon = glon(*,*,(FRAME-1)) 
      ;;;    idat = reform(idat) ; remove extraneous dimensions
      ;    if (vkluge)then idat = rotate(idat,7) ; TJK - this rotation desired for viking only.
      ;isize = size(idat) ; already calculated above.   get the dimensions of the image
      ; 
      r1 = 450./isize(1) ; determine ratio for first dimension
      r2 = 450./isize(2) ; determine ratio for second dimension
      ;r1 =ceil(500/isize(1)) ; determine ratio for first dimension
      ;r2 = ceil(500/isize(2)) ; determine ratio for second dimension
      if keyword_set(XSIZE) then begin 
	xs=XSIZE
      endif else begin
        xs = ceil(isize(1)*r1)+50 ; determine xsize of window
        ys = ceil(isize(2)*r2)+15 ; determine ysize of window
      endelse
      if (project eq 'TIMED') then begin; setting larger size for TIMED displays
	xs = 600 & ys = 600
      endif
	  

      ; This causes idat to go from 180x180 to 360x360 why do I need it?:
      ; This has been commented out; rebin causing stray marks to be generated in
      ; mapped images.  RTB  4/98
      ; congrid ??? should be able to use.
      ;    idat = congrid(idat,(isize(1)*r1),(isize(2)*r2)) ; resize the image
      ;    glat = congrid(glat,(isize(1)*r1),(isize(2)*r2)) ; resize the image
      ;    glon = congrid(glon,(isize(1)*r1),(isize(2)*r2)) ; resize the image

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
   
      ; Set all pixels in idat to 0 if position invalid  RTB 1/99 
      wlat=where(glat lt -90.0, wlatc)
      if(wlatc gt 0) then idat(wlat) = 0;
      wlon=where(glon lt -180.0, wlonc)
      if(wlonc gt 0) then idat(wlon) = 0;
   
      if keyword_set(DEBUG) then begin
         print, 'Image valid min and max: ',zvmin, ' ',zvmax 
         wmin = min(idat,MAX=wmax)
         print, 'Actual min and max of data',wmin,' ', wmax
      endif

      w = where((idat lt zvmin),wc)
      white = w ;save off the indices below zvmin - need this lower down if white_background
      if wc gt 0 then begin
         if keyword_set(DEBUG) then print, 'Number of values below the valid min = ',wc
         print,'WARNING=setting ',wc,' fill values in image data to background...'
;4/12/2004 TJK change to lowest value ge zvmin	 idat(w) = 0 ; set pixels to black
	 good = where (idat ge zvmin, gc)
	 if (gc gt 0) then idat(w) = min(idat(good)) else idat(w) = zvmin
	 w = 0 ; free the data space
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
         idat(w) = zvmax - coffset; set pixels to red
         w = 0 ; free the data space
      endif

;TJK 3/2/2004 - if log scaling add call to shiftdata_above zero, so all of the
;low values aren't lost.

      if (logZ) then begin
	fillval = -1.0e31
        idat = shiftdata_above_zero(idat, fillval)
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

;6/25/2004 see below         idat(w) = zvmax -1; set pixels to red
	 ;TJK 6/25/2004 - added red_offset function to determine offset 
	 ;(to red) because of cases like log scaled timed guvi data 
	 ;where the diff is less than 1.
	    diff = zvmax - zvmin
	    coffset = red_offset(GIF=GIF,diff)
            idat(w) = zvmax - coffset; set pixels to red
            w = 0 ; free the data space
         endif
      endif

      ;TJK original code follows:
      ; filter out data values outside 3-sigma for better color spread
      ;    if keyword_set(NONOISE) then begin
      ;      semiMinMax,idat,zvmin,zvmax
      ;      w = where(((idat lt zvmin)OR(idat gt zvmax)),wc)
      ;      if wc gt 0 then begin
      ;        print,'WARNING=filtering values outside 3-sigma from image data...'
      ;        idat(w) = 0 ; set pixels to black
      ;        w = 0 ; free the data space
      ;      endif
      ;    endif

      ; scale to maximize color spread
      idmax=max(idat) 
      idmin=min(idat) ; RTB 10/96

      if keyword_set(DEBUG) then begin
         print, '!d.n_colors = ',!d.n_colors
         print, 'min and max after filtering = ',idmin, ' ', idmax
      endif

      ; Move this below after day-glow filtering  RTB 1/99
      ;     idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)
      ;if keyword_set(DEBUG) then begin
      ;	bytmin = min(idat, max=bytmax)
      ;	print, 'min and max after bytscl = ',bytmin, ' ', bytmax
      ; endif

      ;; RCJ 03/25/2003  Moved this piece of code (between ;;) from below to here.
      ; VIS images have alot of garbage 0.0's
      cond = (glat gt -90.1) and (glat lt 90.1)
      wgoo=where(cond,wgoon) 
      ;if(wgoon gt 0) then clat=glat(wgoo)
      ; RCJ 03/24/2003 added the 'else clat=glat' because if wgoon=0 clat is not
      ; defined, causing an error
      if(wgoon gt 0) then clat=glat(wgoo) else clat=glat
      ;if(wgoon gt 0) then clat=glat(wgoo) else begin
      ;   print, 'STATUS=No valid latitude points for plot; Select a new time range.'
      ;   print, 'ERROR=No valid latitude points'
	; return,-1
      ;endelse
      wn=where(clat gt 0.01, wzn)
      ws=where(clat lt -0.01, wzs)
      if(wzn ge wzs) then begin
         if(wzn ne 0) then centerlat=clat(wn(wzn/2)) else centerlat=glat(mid1,mid2)
      endif else begin
         if(wzs ne 0) then centerlat=clat(ws(wzs/2))
      endelse
;1/16/04 TJK added NORTH and SOUTH to the list of keywords that can be specified in the DISPLAY_TYPE, 
;these are not IDL keywords
      if (NORTH) then centerlat = 90.0 ;TJK added for TIMED - need to override CENTERLONLAT
      if (SOUTH) then centerlat = -90.0 ;TJK added for TIMED - need to override CENTERLONLAT
      ;;

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

         ; This is being duplicated in plotmaster; do we really need it?? 
         ; RCJ 02/21/2003  This part creates the unique name for the individual images.
	 ; If we took the input GIF name we would override the thumbnail image.
         GIF=strmid(GIF,0,(strpos(GIF,'.gif')))+'_f000.gif'
         if(FRAME lt 100) then gifn='0'+strtrim(string(FRAME),2) 
         if(FRAME lt 10) then gifn='00'+strtrim(string(FRAME),2) 
         if(FRAME ge 100) then gifn=strtrim(string(FRAME),2)
         GIF=strmid(GIF,0,(strpos(GIF,'.gif')-3))+gifn+'.gif'
 
         deviceopen,6,fileOutput=GIF,sizeWindow=[xs+xco,ys+30]
 	 if(white_background) then begin
	   mapcolor = foreground
	   erase ; erases background and makes it white 
	 endif

         if (reportflag eq 1) then begin
            printf,1,'I_GIF=',GIF & close,1
         endif
         print,'I_GIF=',GIF 
      endif else begin ; open the xwindow
         window,/FREE,XSIZE=xs+xco,YSIZE=ys+30,TITLE=window_title
      endelse


      ;12/22/2008 TJK For the GPS data, we want to use the "PO" method 
      ;to smooth out the sparse data
      method = "PL"
      proj = strmid(project,0,3)
      if (proj eq 'GPS') then method = "PO" 

      xmargin=!x.margin

;TJK 1/12/2009 - set x.margin wider for cylindrical, "PO" plots (for
;                GPS data) because we want labels along the edges
;                (box_axes)
      if (map_proj eq 8 and method eq "PO") then begin
          !x.omargin(0) = 1
      endif

      if COLORBAR then begin 
         if (!x.omargin(1)+!x.margin(1)) lt 14 then !x.margin(1) = 14
         !x.omargin(1) = 8 ;TJK change from 4 to 8 on 2/3/2004 
         plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
      endif
      !y.omargin(0) = 2

      ;;  RCJ moved 'clat' piece of code from here. Look for RCJ 03/25/2003.
      ;;
      ; Define Fixed Geo. position
      if(CENTERPOLE) then begin
         if(NOT MLT_IMAGE) then begin
         if(centerlat gt 0.0) then begin
            CENTERLONLAT=[180.0,90.0]
            btpole=90.0
            if(descriptor(0) eq 'VIS') then btlat=30.0 else btlat=40.0 
            if (proj eq 'GPS') then btlat = 0.0
            wlat=where(glat lt btlat,wlatc)
	    ; RCJ 02/21/2003 This line does not exist for thumbnails. Should this be done here?
            ;if(wlatc gt 0) then idat(wlat)=0 
           ;TJK don't want to fill w/ the fill value if using method PO -
           ;convert_coord doesn't like values outside -90-90
            ;if(wlatc gt 0) then glat(wlat)=-1.0e+31
            if (method ne 'PO' and wlatc gt 0) then glat(wlat)=-1.0e+31
         endif else begin
            CENTERLONLAT=[180.0,-90.0]
            btpole=-90.0
            if(descriptor(0) eq 'VIS') then btlat=-30.0 else btlat=-40.0 
            if (proj eq 'GPS') then btlat = 0.0
            wlat=where(glat gt btlat,wlatc)
	    ; RCJ 02/21/2003 This line does not exist for thumbnails. Should this be done here?
            ;if(wlatc gt 0) then idat(wlat)=0
           ;TJK don't want to fill w/ the fill value if using method PO -
           ;convert_coord doesn't like values outside -90-90
            ;if(wlatc gt 0) then glat(wlat)=-1.0e+31
            if (method ne 'PO' and wlatc gt 0) then glat(wlat)=-1.0e+31 
         endelse
	 endif
      endif

      ; Grabbed from thumbnail section
      ;      for li=0,xdim-1 do begin
      ;       if(centerlat gt 0.0) then begin
      ;          CENTERLONLAT=[180.0,90.0]
      ;          btpole=90.0
      ;          if(descriptor(0) eq "VIS") then btlat=30.0 else btlat=40.0
      ;          wlat=where(glat(li,*,j) lt btlat,wlatc)
      ;          if(wlatc gt 0) then glat(li,wlat,j)=-1.0e+31
      ;       endif else begin
      ;          CENTERLONLAT=[180.0,-90.0]
      ;          btpole=-90.0
      ;          if(descriptor(0) eq "VIS") then btlat=-30.0 else btlat=-40.0
      ;          wlat=where(glat(li,*,j) gt btlat,wlatc)
      ;          if(wlatc gt 0) then glat(li,wlat,j)=-1.0e+31
      ;       endelse
      ;      endfor


      ; Compute Noon Sun position
      if(SUN) then begin
;	if keyword_set(DEBUG) then print, '***TJK SETTING CENTERLONLAT due to SUN setting request'
         SUN,IYR,IDAY,IHOUR,MIN,ISEC,GST,SLONG,SRASN,SDEC,epoch=edat((FRAME-1))
         p=[cos(sdec)*cos(srasn),cos(sdec)*sin(srasn),sin(sdec)]
         geigeo,p(0),p(1),p(2),xgeo,ygeo,zgeo,1,epoch=edat((FRAME-1))
         sunln=atan2d(ygeo,xgeo)
         sunlt=atan2d(zgeo,sqrt(xgeo*xgeo+ygeo*ygeo))
         sunln=sunln+180
         if(sunln gt 180.0) then sunln = sunln - 360.0
         if(centerlat gt 0.0) then CENTERLONLAT=[sunln,90.0] else $
            CENTERLONLAT=[sunln,-90.0]
         ;  endif else begin
         ;   geigeo,sun_data(0,(FRAME-1)),sun_data(1,(FRAME-1)),sun_data(2,(FRAME-1)),xgeo,ygeo,zgeo,1,epoch=edat((FRAME-1))
         ;   sunln=atan2d(ygeo,xgeo)
         ;   sunlt=atan2d(zgeo,sqrt(xgeo*xgeo+ygeo*ygeo))
         ;   sunln=sunln+180
         ;   if(sunln gt 180.0) then sunln = sunln - 360.0
         ;    if(centerlat gt 0.0) then CENTERLONLAT=[sunln,90.0] else $
         ;                                    CENTERLONLAT=[sunln,-90.0]
         ;  endelse
      endif

      ; Derive day-night terminator
      if(TERMINATOR) then begin
         ;  if(descriptor(0) eq 'PIX') then begin
         ; NOTE: gci_sun and sun_data often will be the same data. Treated differently.
         ; Need to clean this up!
         ;   i1=gci_sun(0,(FRAME-1))
         ;   i2=gci_sun(1,(FRAME-1))
         ;   sunlat=glat(i1,i2,(FRAME-1))  
         ;   sunlon=glon(i1,i2,(FRAME-1))
         SUN,IYR,IDAY,IHOUR,MIN,ISEC,GST,SLONG,SRASN,SDEC,epoch=edat((FRAME-1))
         p=[cos(sdec)*cos(srasn),cos(sdec)*sin(srasn),sin(sdec)]
         geigeo,p(0),p(1),p(2),xgeo,ygeo,zgeo,1,epoch=edat((FRAME-1))
         sunlon=atan2d(ygeo,xgeo)
         sunlat=atan2d(zgeo,sqrt(xgeo*xgeo+ygeo*ygeo))
         s=terminator(sunlat,sunlon)
         ;   save,s,filename="term_info.idl"
         ;  endif else begin
         ;   geigeo,gci_sun(0,(FRAME-1)),gci_sun(1,(FRAME-1)),gci_sun(2,(FRAME-1)),xgeo,ygeo,zgeo,1,epoch=edat(FRAME-1)
         ;   sunlon=atan2d(ygeo,xgeo)
         ;   sunlat=atan2d(zgeo,sqrt(xgeo*xgeo+ygeo*ygeo))
         ;   s=terminator(sunlat,sunlon)
         ;  endelse
      endif

      ;TJK added this section to print out some statistics about the data distribution. 
      if keyword_set(DEBUG) then begin
         print, 'Statistics about the data distribution before filtering'
         w = where(((idat lt idmax) and (idat ge (idmax-10))),wc)
         if wc gt 0 then print, 'Number of values between     ',idmax,' and ',idmax-10,' = ',wc
         w = where(((idat lt idmax-10) and (idat ge (idmax-20))),wc)
         if wc gt 0 then print, 'Number of values between ',idmax-10,' and ',idmax-20,' = ',wc
         w = where(((idat lt idmax-20) and (idat ge (idmax-30))),wc)
         if wc gt 0 then print, 'Number of values between ',idmax-20,' and ',idmax-30,' = ',wc
         w = where(((idat lt idmax-30) and (idat ge (idmax-40))),wc)
         if wc gt 0 then print, 'Number of values between ',idmax-30,' and ',idmax-40,' = ',wc
         w = where(((idat lt idmax-40) and (idat ge (idmax-50))),wc)
         if wc gt 0 then print, 'Number of values between ',idmax-40,' and ',idmax-50,' = ',wc
         w = where(((idat lt idmax-50) and (idat ge (idmax-60))),wc)
         if wc gt 0 then print, 'Number of values between ',idmax-50,' and ',idmax-60,' = ',wc
      endif

      if keyword_set(NONOISE) then begin
         if(descriptor(0) eq 'VIS') then begin
            ; Find geo position of sun 
            SUN,IYR,IDAY,IHOUR,MIN,ISEC,GST,SLONG,SRASN,SDEC,epoch=edat((FRAME-1))
            p=[cos(sdec)*cos(srasn),cos(sdec)*sin(srasn),sin(sdec)]
            geigeo,p(0),p(1),p(2),xgeo,ygeo,zgeo,1,epoch=edat((FRAME-1))
            slnr=atan2d(ygeo,xgeo)
            sltr=atan2d(zgeo,sqrt(xgeo*xgeo+ygeo*ygeo))
            slmag=sqrt(xgeo*xgeo+ygeo*ygeo+zgeo*zgeo) ; sun vector magnetude
            ; Compute dot product b/w unit sun geo vector and position vector.
            ; If angle b/w sun vector and position vector is less than 60.0 degrees
            ; filter out pixel value by setting it to black.  This is a rough day-glow
            ; filter for VIS images.  RTB  1/99
            for i0=0, isize(1)-1 do begin
               for j0=0, isize(2)-1 do begin
                  lat_tmp=90.0-glat(i0,j0)
                  lon_tmp=glon(i0,j0)
                  ;if(lon_tmp gt 180.0) then lon_tmp=lon_tmp-360.0  
                  if(lon_tmp lt 0.0) then lon_tmp=lon_tmp+360.0  
                  xprm= cos(lon_tmp*(!dtor))*sin(lat_tmp*(!dtor))
                  yprm= sin(lon_tmp*(!dtor))*sin(lat_tmp*(!dtor))
                  zprm= cos(lat_tmp*(!dtor))
                  lmag=sqrt(xprm*xprm+yprm*yprm+zprm*zprm) ; position vector magnetude
                  ;angle1=acos((xprm*xgeo+yprm*ygeo+zprm*zgeo)/(lmag*slmag))*(!radeg)
                  angle1=acos((xprm*xgeo+yprm*ygeo+zprm*zgeo))*(!radeg)
                  ;if((angle1 lt 60.0) or (angle1 gt 120.0)) then idat(i0,j0)= 0
                  if(angle1 lt 70.0) then idat(i0,j0)= 0
                  ;if((glon(i0,j0) gt 90.0) and (glon(i0,j0) lt 135.0)) then begin
                  ;if(lon_tmp lt 135.0) then begin
                  ;  if(glat(i0,j0) lt 60.0) then $
                  ;      print, i0,j0,glat(i0,j0),glon(i0,j0),angle1,idat(i0,j0)
                  ;endif
               endfor
            endfor
            ; Re-establish min and max colors
            idmax=max(idat)
            idmin=min(idat) 
         endif
      endif

      ;TJK added this section to print out some statistics about the data distribution. 
      if keyword_set(DEBUG) then begin
         print, 'Statistics about the data distribution after filtering'
         w = where(((idat lt idmax) and (idat ge (idmax-10))),wc)
         if wc gt 0 then print, 'Number of values between     ',idmax,' and ',idmax-10,' = ',wc
         w = where(((idat lt idmax-10) and (idat ge (idmax-20))),wc)
         if wc gt 0 then print, 'Number of values between ',idmax-10,' and ',idmax-20,' = ',wc
         w = where(((idat lt idmax-20) and (idat ge (idmax-30))),wc)
         if wc gt 0 then print, 'Number of values between ',idmax-20,' and ',idmax-30,' = ',wc
         w = where(((idat lt idmax-30) and (idat ge (idmax-40))),wc)
         if wc gt 0 then print, 'Number of values between ',idmax-30,' and ',idmax-40,' = ',wc
         w = where(((idat lt idmax-40) and (idat ge (idmax-50))),wc)
         if wc gt 0 then print, 'Number of values between ',idmax-40,' and ',idmax-50,' = ',wc
         w = where(((idat lt idmax-50) and (idat ge (idmax-60))),wc)
         if wc gt 0 then print, 'Number of values between ',idmax-50,' and ',idmax-60,' = ',wc
      endif

      ; Scale colors before plotting
      ; Moved from above   RTB 1/99

      if (log10Z) then begin
;TJK - shouldn't need - fixed the problem for both log and linear above
;	above1 = where(idat gt 1.0, wc)
;	if(wc gt 0) then idmin = min(idat(above1)) else idmin = zvmin ;TJK 4/8/2004 - add for log scaling
;	print, 'idmin being redefined to ',idmin
        idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-2)
      endif else begin
;        idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)
;TJK 6/21/04 change to try to stop high colors from going to white (instead 
;of red) once and for all!
        idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-2)
      endelse
      if(white_background and n_elements(white) gt 0) then idat(white) = !d.n_colors-1

      if keyword_set(DEBUG) then begin
         bytmin = min(idat, max=bytmax)
         print, 'min and max after bytscl = ',bytmin, ' ', bytmax
      endif


      if(CENTERPOLE) then begin
         if(MLT_IMAGE) then begin
            ;TERMINATOR=0L  ;already set to 0 above: if (MLT_IMAGE) then TERMINATOR=0
            ;; Convert to MLT
            msz=size(glat)
            xdim=msz(1) 
            ydim=msz(2) 
            mlat=fltarr(xdim,ydim)
            mlon=fltarr(xdim,ydim)
            galt=120.0+6378.16  ; UVI and VIS presumed emission height
            cdf_epoch, edat(FRAME-1), yr,mn,dy,hr,min,sec,milli,/break
            ical,yr,doy,mn,dy,/idoy
            sod=long(hr*3600.0+min*60.+sec)
            doy=fix(doy)
            for li=0,xdim-1 do begin
               for lj=0,ydim-1 do begin
                  if((glat(li,lj) lt 90.1) and (glat(li,lj) gt -90.1) and $
		     (glon(li,lj) lt 180.1) and (glon(li,lj) gt -180.1)) then begin 
                     dum2 =  float(glat(li,lj)) 
                     dum3 =  float(glon(li,lj)) 
                     ;print, yr,doy,sod,galt,glat(li,lj),glon(li,lj)
                     opos = eccmlt(yr,doy,sod,galt,dum2,dum3)
                     ;print, opos
                  endif else begin
                     opos=[99999.0,99999.0,99999.0]
                  endelse
                  ;      mglon(li,lj)=opos(0)
                  mlat(li,lj)=opos(1)
                  mlon(li,lj)=opos(2)*15.0
                  ;      if(mlat(li,lj) lt 50.0) then idat(li,lj,0)=0
                  ; RCJ 02/05/2003 Confusing story here: the line below was not commented out but the
                  ; 2 lines below it were which was causing the line below to continue - because of the $ -
                  ; on the next uncommented line - the 'if(descriptor(0) eq 'VIS'". Of course that
                  ; line was never executed for VIS data because the descriptor(0) was 'VIS', not
                  ;'UVI'. This was causing some plots - PO_K1_VIS, var=Mapped_ImageM - to show
                  ; data past the 40 degree lat limit. Since it looks like nothing is to be done
                  ; to UVI data then I commented out the line below. (This comment is repeated below)
                  ;     if(descriptor(0) eq "UVI") then $
                  ;       if(mlat(li,lj) lt 40.0) then idat(li,lj,0)=0 & mmlat=40.0
                  ;if (descriptor(0) eq 'VIS') then begin
		  ; RCJ 02/21/2003  Now we decided that UVI images should also be cropped at 
		  ; 40 degrees lat:
                  if (descriptor(0) eq 'VIS') or (descriptor(0) eq 'UVI') then begin
                     ;if(mlat(li,lj) lt 40.0) then idat(li,lj,FRAME-1)=0 & mmlat=40.0
                     ;if(mlat(li,lj) lt 40.0) then idat(li,lj)=0  
                     ; RCJ 03/03/2003 Working on PO_K1_VIS var=Mapped_ImageM 
	             ; Dealing w/ north and south hemisph.should be different
		     ; and CENTERLONLAT should be included. If this works add
		     ; similar code to the individual frame section.
                     ; (This comment is repeated in the 'thumbnail' section)
	             if centerlat gt 0 then begin ; north:
                        CENTERLONLAT=[180.0,90.0] 
                        if(mlat(li,lj) lt 40.0) then idat(li,lj)=0
	             endif else begin ; south:
                        CENTERLONLAT=[180.0,-90.0] 
                        if(mlat(li,lj) gt -40.0) then idat(li,lj)=0
		     endelse   
                  endif  
               endfor
            endfor
            ; RCJ 02/05/2003. I'm not sure why mmlat was being set inside the 'for' loop
            ; above. I hope this line is ok here.
            ;if (descriptor(0) eq 'UVI') or (descriptor(0) eq 'VIS') then mmlat=40.0
	    ; RCJ 03/03/2003 Rangelonlat input to auroral_image should be
	    ; different for north and south hemispheres. Shouldn't this also be
	    ; valid for 'pix' data?
            if (descriptor(0) eq 'UVI') or (descriptor(0) eq 'VIS') then begin
	       if centerlat gt 0 then thisrangeLonLat=[40.,-180.,90.,180.] else $
                  thisrangeLonLat=[-90.,-180.,-40.,180.]
            endif

            mag_lt=mlon-180.0
            wcg=where(mag_lt ge 180.0)
            if(wcg[0] ne -1) then mag_lt(wcg)=mag_lt(wcg)-360.0
            wcg=where(mag_lt lt -180.0)
            if(wcg[0] ne -1) then mag_lt(wcg)=mag_lt(wcg)+360.0

            idmin=min(idat,max=idmax)
            if (log10Z) then idmin = zvmin ;TJK 4/8/2004 - add for log scaling
            wcg=where(idat gt 0)
            if(wcg[0] eq -1) then begin
               print, 'STATUS=No valid points for MLT plot; Select a new time range.'
               print, 'ERROR=No valid image, mlat or mlon points'
	       ; RCJ 03/24/2003 Make an empty graph w/ white background and close device:
	       if keyword_set(GIF) then begin
                  plot,[0],[0],background=255,color=0,xsty=4,ysty=4
		  xyouts,0.3,0.5,'[No valid points for MLT plot; Select a new time range]',/normal,color=0
		  deviceclose
	       endif  
	       ; RCJ 03/24/2003 Changed the return to -1 (from 0) 
               return, -1
            endif
;	    if keyword_set(DEBUG) then print, 'Calling 1st auroral_image'
            auroral_image, idat, mag_lt, mlat, method="PL",/mltgrid,$
              centerLonLat=CENTERLONLAT, /nocolorbar,/CENTERPOLE,proj=map_proj,fillValue=-1.0e+31,$
               ;rangeLonLat=[mmlat,-180.,90.,180.],$
               rangeLonLat=thisrangelonlat,mapcolor=mapcolor,$
	       status=status,charsize=2.0, logZ=logZ
         endif else begin

;	    if keyword_set(DEBUG) then print, 'Calling 2nd auroral_image'
;            auroral_image, idat, glon, glat, /continents,/label,fill_cont=fill_cont, $
;            method="PL", /grid, centerLonLat=CENTERLONLAT, /nocolorbar,/CENTERPOLE,proj=map_proj,$
            auroral_image, idat, glon, glat, /continents,/label,fill_cont=fill_cont, $
            method=method, /grid, centerLonLat=CENTERLONLAT, /nocolorbar,/CENTERPOLE,proj=map_proj,$
            fillValue=-1.0e+31,rangeLonLat=[btlat,-180.,btpole,180.],status=status,charsize=2.0,$
	    mapcolor=mapcolor, logZ=logZ

            if(TERMINATOR) then plots,s.lon,s.lat,color=foreground,thick=2.0
         endelse
      endif else begin
         ; Test section of code for static image map display w/ distorted continental
         ; boundries
         if(FIXED_IMAGE) then begin
            if(descriptor(0) eq 'UVI') then begin
               att=double(attit(*,(FRAME-1)))
               orb=double(gpos(*,(FRAME-1)))
               if(sys(FRAME-1) lt 0) then system=sys(FRAME-1)+3 else system=sys(FRAME-1)
               filter=fix(filt(FRAME-1))-1
               dsp_angle=double(dsp(FRAME-1))
               xpos1=30. 
               ypos1=60. 
               nxpix = 200
               nypix = 228
               xpimg = nypix*1.6
               ypimg = nypix*1.6
               x_img_org = xpos1 + ( (xs - xpimg)/6 )
               x_img_org = xpos1+30.
               y_img_org = ypos1 + ( (ys - ypimg)/6 )
               y_img_org = ypos1
               pos = [x_img_org, y_img_org,x_img_org+xpimg, y_img_org+ypimg]
               grid_uvi,orb,att,dsp_angle,filter,system,idat,pos,xpimg,ypimg,$
                  edat((FRAME-1)),s,nxpix,nypix,/CONTINENT,/GRID,/POLE,$
		  /TERMINATOR,/LABEL,SYMSIZE=1.0,/device
            endif else begin ; VIS and everything else
               xpos1=30. 
               ypos1=60. 
               xpimg=isize(1)*r1-40
               ypimg=isize(2)*r2-40
               x_img_org = xpos1+30. 
               y_img_org = ypos1 
               pos = [x_img_org, y_img_org,x_img_org+xpimg, y_img_org+ypimg]
               ; Include sat position here temporarily
               ;    handle_value,astruct.SC_POS_GCI.handle, sat_pos 
               if(descriptor(0) eq 'VIS') then begin
                  glat=rotate(glat,3)
                  glon=rotate(glon,3)
                  idat=rotate(idat,3)
               endif
               if(centerlat gt 0.) then begin
                  ;grid_map,glat(*,*,0),glon(*,*,0),idat,pos,s,xpimg,ypimg,/GRID,$
                  grid_map,glat,glon,idat,pos,s,xpimg,ypimg,/GRID,$
	             /LABEL,/POLE_N, /device, c_charsize=1.5
                  ; test for continent outlining
                  ;grid_map,glat(*,*,0),glon(*,*,0),idat,pos,s,sat_pos,xpimg,ypimg,/GRID,$
	          ;/POLE_N, /CONTINENT,/device
               endif else begin
                  ;grid_map,glat(*,*,0),glon(*,*,0),idat,pos,s,xpimg,ypimg,/GRID,$
                  grid_map,glat,glon,idat,pos,s,xpimg,ypimg,/GRID,$
                     /LABEL,/POLE_S, /device, c_charsize=1.5
                  ; test for continent outlining
                  ;grid_map,glat(*,*,0),glon(*,*,0),idat,pos,s,sat_pos,xpimg,ypimg,/GRID,$
                  ;/POLE_S, /CONTINENT,/device
               endelse
            endelse ; descriptor condtion
            ;
            ; turn terminator off for now
            TERMINATOR=0 
            projection='rendered projection'
            ;end new test section FIXED_IMAGE
         endif else begin

;	   if keyword_set(DEBUG) then print, 'Calling 3rd auroral_image'
           if (map_proj eq 8 and project eq 'TIMED') then begin
		CenterLonLat=[0.,-90] ;show whole earth w/ both poles
            endif

           method = "PL"
           proj = strmid(project,0,3)
           if (proj eq 'GPS') then method = "PO" 

            auroral_image, idat, glon, glat, $
;               method="PL",/continents, /grid, centerLonLat=CENTERLONLAT,fill_cont=fill_cont,$
               method=method,/continents, /grid, centerLonLat=CENTERLONLAT,fill_cont=fill_cont,$
               /nocolorbar,fillValue=-1.0e+31,status=status,charsize=2.0,/label,$
               proj=map_proj, central_azimuth=central_azimuth, rangelonlat=thisrangelonlat,$
	       mapcolor=mapcolor, logZ=logZ
	       ;TJK use to be hardcoded to  - projection='satellite projection'

            if(TERMINATOR) then plots,s.lon,s.lat,color=foreground,thick=2.0
         endelse
      endelse
      ;  if(TERMINATOR) then plots,s.lon,s.lat,color=!d.n_colors-1,thick=2.0          
      ; subtitle the plot
      ; project_subtitle,astruct.(0),'',/IMAGE,TIMETAG=edat(FRAME-1)
      project_subtitle,astruct.(0),window_title,/IMAGE,TIMETAG=edat(FRAME-1),$
         TCOLOR=foreground
      ; Print orientation
      xyouts, 0.06, 0.08, projection ,color=foreground,/normal

      ; RTB 10/96 add colorbar
      if COLORBAR then begin
         if (n_elements(cCharSize) eq 0) then cCharSize = 0.
         cscale = [idmin, idmax] ; RTB 12/11
         ; cscale = [zvmin, zvmax]
         xwindow = !x.window
         if(FIXED_IMAGE) then offset=0.05 else offset = 0.01
         offset = 0.01
         colorbar, cscale, ctitle, logZ=logZ, cCharSize=cCharSize, $
            position=[!x.window(1)+offset,!y.window(0),$
            !x.window(1)+offset+0.03, !y.window(1)],$
            fcolor=foreground, /image
         !x.window = xwindow
      endif ; colorbar

      if keyword_set(GIF) then deviceclose
   endif ; valid frame value

   ; moved to end of routine:
   ;; Add descriptive MESSAGE to for  parse.ph to parse along w/ the plot etc 

   ; ******  Produce thumbnails of all images

endif else begin ; produce thumnails of all images
   ;if keyword_set(THUMBSIZE) then tsize = THUMBSIZE else tsize = 50
   ;if keyword_set(THUMBSIZE) then tsize = THUMBSIZE else tsize = 100
   ; 5 if(n_elements(THUMBSIZE) gt 0) then tsize = THUMBSIZE else tsize = 100
   if(n_elements(THUMBSIZE) gt 0) then tsize = THUMBSIZE else tsize = 166
   ;isize = size(idat) ; already calculated above   ;determine the number of images in the data
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
   if (start_frame gt stop_frame) then no_data_avail = 1 $
   else begin
      no_data_avail = 0

;TJK 12/15/2008 add check for dimension sizes for glat and glon - for
;GPS are non-record varying variables, so they don't have the 
;dimensions expected below

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
   ncols = xs / tsize & nrows = (nimages / ncols) + 1
   ;label_space = 12 ; TJK added constant for label spacing
   label_space = 24 ; TJK added constant for label spacing
   boxsize = tsize+label_space;TJK added for allowing time labels for each image.
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

      ; Set all pixels in idat to 0 if position invalid  RTB 1/99 
      wlat=where(glat lt -90.0, wlatc)
      if(wlatc gt 0) then idat(wlat) = 0
      wlon=where(glon lt -180.0, wlonc)
      if(wlonc gt 0) then idat(wlon) = 0

      if keyword_set(DEBUG) then begin
         print, 'Image valid min and max: ',zvmin, ' ',zvmax 
         wmin = min(idat,MAX=wmax)
         print, 'Actual min and max of data',wmin,' ', wmax
      endif

      w = where((idat lt zvmin),wc)
      white = w ;save off the indices below vmin - need this lower down if white_background

      if wc gt 0 then begin
         print,'WARNING=setting ',wc,' fill values in image data to background...'
;4/12/2004 TJK change to lowest value ge zvmin	 idat(w) = 0 ; set pixels to black
	 good = where (idat ge zvmin, gc)
	 if (gc gt 0) then idat(w) = min(idat(good)) else idat(w) = zvmin
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
      ;   if (nimages eq 1) then begin
      ;      idat = congrid(idat,tsize,tsize) 
      ;      glat = congrid(glat,tsize,tsize) 
      ;      glon = congrid(glon,tsize,tsize) 
      ;   endif else begin
      ;      idat = congrid(idat,tsize,tsize,nimages)
      ;      glat = congrid(glat,tsize,tsize,nimages)
      ;      glon = congrid(glon,tsize,tsize,nimages)
      ;   endelse


;TJK 3/2/2004 - if log scaling add call to shiftdata_above zero, so all of the
;low values aren't lost.

      if (logZ) then begin
	fillval = -1.0e31
        idat = shiftdata_above_zero(idat, fillval)
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

      if keyword_set(DEBUG) then begin
	 if (log10Z) then begin
	   w = where((idat lt 1) and (idat gt 0), wc)
	   if wc gt 0 then print, 'Number of values gt0, lt1 ',wc
	   w = where((idat lt 2) and (idat ge 1), wc)
	   if wc gt 0 then print, 'Number of values ge1, lt2 ',wc
	   w = where((idat lt 3) and (idat ge 2), wc)
	   if wc gt 0 then print, 'Number of values ge2, lt3 ',wc
	   w = where((idat lt 4) and (idat ge 3), wc)
	   if wc gt 0 then print, 'Number of values ge3, lt4 ',wc
	   w = where((idat gt 4), wc)
	   if wc gt 0 then print, 'Number of values gt 4  ',wc
	 endif
      endif

      if (log10Z) then begin
;TJK - removed this - shouldn't need it, fixed the problem for both log and linear above
;	above1 = where(idat gt 1.0, wc)
;	if(wc gt 0) then idmin = min(idat(above1)) else idmin = zvmin ;TJK 4/8/2004 - add for log scaling
;	print, 'idmin being redefined to ',idmin
        idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-2)
      endif else begin
;TJK 6/21/04 change to try to stop high colors from going to white (instead 
;of red) once and for all!
;        idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)
        idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-2)
      endelse

      if(white_background and n_elements(white) gt 0) then idat(white) = !d.n_colors-1

      ;idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-3) + 1B

      if keyword_set(DEBUG) then begin
         bytmin = min(idat, max=bytmax)
	 print, 'min and max after bytscl = ',bytmin, ' ', bytmax
      endif
      ;;   idat = bytscl(idat,max=max(idat),min=min(idat),top=!d.n_colors-1)

      ;  idat=bytscl(idat,max=idmax,min=idmin,top=!d.n_colors-3)+1B
      ; Bobby; why isn't this bidat instead of idat
      ;  w=where(idat gt idmax,wc)
      ;  if(wc gt 0) then idat(w)=!d.n_colors-1
      ;  w=where(idat lt idmin,wc)
      ;  if(wc gt 0) then idat(w)=0B
      ; end changes 12/11 RTB
      ; open the window or gif file
      if keyword_set(GIF) then begin
         deviceopen,6,fileOutput=GIF,sizeWindow=[xs+xco,ys+40]
	 if(white_background) then begin
	   mapcolor = foreground
	   erase ; erases background and makes it white 
	 endif
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
         if (!x.omargin(1)+!x.omargin(1)) lt 14 then !x.omargin(1) = 14
         !x.omargin(1) = 14
         plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4  
      endif
      ; !y.omargin = [6,0.5]  ; rtb added 1/98
      
      ; generate the thumbnail plots

      irow=0
      icol=0
      for j=0,nimages-1 do begin
         if(icol eq ncols) then begin
            icol=0 
            irow=irow+1
         endif
         xpos=icol*tsize
         ypos=ys-(irow*tsize+30)
         if (irow gt 0) then ypos = ypos-(label_space*irow) ;TJK modify position for labels

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
         ; Set centerlat for each frame in the thumbnails
         ;   clat=extrac(glat(*,*,j),mid1-5,mid2-5,10,10)
         ;   wz=where(clat ne 0.0,wzn)
         ; VIS images have alot of garbage 0.0's or fill values
         if (size(glat, /n_dimensions) eq 3) then clat=glat(*,*,j) else clat = glat
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

;1/16/04 TJK added NORTH and SOUTH to the list of keywords that can be specified in the DISPLAY_TYPE, 
;these are not IDL keywords
        if (NORTH) then centerlat = 90.0 ;TJK added for TIMED - need to override CENTERLONLAT
        if (SOUTH) then centerlat = -90.0 ;TJK added for TIMED - need to override CENTERLONLAT
         ;wz=where(glat(*,*,j) ne 0.0,wzn)
         ;if(wzn ne 0) then clat=clat(wz)
         ;if(wzn ne 0) then centerlat=clat(wz(wc/2)) else centerlat=glat(mid1,mid2,j)
         ; Set Fixed Geo. position
         ; The following code segment causes stray marks to appear in the mlt plots
         ; It doesn't appear from preliminary testing that overlay plots or 
         ; registered image plots are effected by removing this segment.
         ;  RTB  5/99
         if(CENTERPOLE) then begin
            if(NOT MLT_IMAGE) then begin
               ; The following code flags points which will fall outside the map area.
               oosz=size(glat)
               xdim=oosz(1)
               ydim=oosz(2)
               for li=0,xdim-1 do begin
                  if(centerlat gt 0.0) then begin
                     CENTERLONLAT=[180.0,90.0] 
                     btpole=90.0
                     if(descriptor(0) eq 'VIS') then btlat=30.0 else btlat=40.0 
                     if (proj eq 'GPS') then btlat = 0.0
;TJK 12/11/2008 add check for dimensionality of glat (because GPS data
;is NRV and thus doesn't have 3 dimensions
                     if (size(glat, /n_dimensions) eq 3) then begin
                         wlat=where(glat(li,*,j) lt btlat,wlatc)
                         if(wlatc gt 0) then glat(li,wlat,j)=-1.0e+31
                     endif
                  endif else begin 
                     CENTERLONLAT=[180.0,-90.0] 
                     btpole=-90.0
                     if(descriptor(0) eq 'VIS') then btlat=-30.0 else btlat=-40.0 
                     if (proj eq 'GPS') then btlat = 0.0
                     if (size(glat, /n_dimensions) eq 3) then begin
                         wlat=where(glat(li,*,j) gt btlat,wlatc)
                         if(wlatc gt 0) then glat(li,wlat,j)=-1.0e+31
                     endif
                  endelse
               endfor
            endif
         endif
         ; Compute Fixed Sun position
         if(SUN) then begin 
;	    if keyword_set(DEBUG) then print, '***TJK SETTING CENTERLONLAT due to SUN setting request'
            ; If the descriptor is pixie (PIX) get sub-solar point location from the
            ; geo lat and long
            ;  if(descriptor(0) eq 'PIX') then begin
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
            ; If the descriptor is pixie (PIX) get sub-solar point location from the
            ; geo lat and long
            SUN,IYR,IDAY,IHOUR,MIN,ISEC,GST,SLONG,SRASN,SDEC,epoch=edat(j)
            p=[cos(sdec)*cos(srasn),cos(sdec)*sin(srasn),sin(sdec)]
            geigeo,p(0),p(1),p(2),xgeo,ygeo,zgeo,1,epoch=edat(j)
            sunlon=atan2d(ygeo,xgeo)
            sunlat=atan2d(zgeo,sqrt(xgeo*xgeo+ygeo*ygeo))
            s=terminator(sunlat,sunlon)
         endif

         if keyword_set(NONOISE) then begin
            if(descriptor(0) eq 'VIS') then begin
               ; Find geo position of sun
               SUN,IYR,IDAY,IHOUR,MIN,ISEC,GST,SLONG,SRASN,SDEC,epoch=edat(j)
               p=[cos(sdec)*cos(srasn),cos(sdec)*sin(srasn),sin(sdec)]
               geigeo,p(0),p(1),p(2),xgeo,ygeo,zgeo,1,epoch=edat(j)
               slnr=atan2d(ygeo,xgeo)
               sltr=atan2d(zgeo,sqrt(xgeo*xgeo+ygeo*ygeo))
               slmag=sqrt(xgeo*xgeo+ygeo*ygeo+zgeo*zgeo) ; sun vector magnetude
               ; Compute dot product b/w unit sun geo vector and position vector.
               ; If angle b/w sun vector and position vector is less than 60.0 degrees
               ; filter out pixel value by setting it to black.  This is a rough day-glow
               ; filter for VIS images.  RTB  1/99
               for i0=0, isize(1)-1 do begin
                  for j0=0, isize(2)-1 do begin
                     lat_tmp=90.0-glat(i0,j0,j)
                     lon_tmp=glon(i0,j0,j)
                     ;if(lon_tmp gt 180.0) then lon_tmp=lon_tmp-360.0
                     if(lon_tmp lt 0.0) then lon_tmp=lon_tmp+360.0
                     xprm= cos(lon_tmp*(!dtor))*sin(lat_tmp*(!dtor))
                     yprm= sin(lon_tmp*(!dtor))*sin(lat_tmp*(!dtor))
                     zprm= cos(lat_tmp*(!dtor))
                     lmag=sqrt(xprm*xprm+yprm*yprm+zprm*zprm) ; position vector magnetude
                     ;angle1=acos((xprm*xgeo+yprm*ygeo+zprm*zgeo)/(lmag*slmag))*(!radeg)
                     angle1=acos((xprm*xgeo+yprm*ygeo+zprm*zgeo))*(!radeg)
                     ;if((angle1 lt 60.0) or (angle1 gt 120.0)) then idat(i0,j0)= 0
                     if(angle1 lt 60.0) then idat(i0,j0,j)= 0
                  endfor
               endfor
               ; Color not reset on thumbnail b/c scale reflects all thumbnail images
               ; not just current image
               ;
               ; Re-setting the color below for each frame doesn't work right. IDL has
               ; a bug.
               ;     temp=idat(*,*,j)
               ;     itmin=min(temp)
               ;     itmax=min(temp)
               ; Could do the following
               ;    for im=0, isize(1)-1 do begin
               ;     itmin(im)=min(idat(im,*,j),max=itmax(im)
               ;      ...
               ;      ...
               ;   Build array of min & max for each row then determine final min, max
               ;    then use below.
               ; Scale colors before plotting
               ; Moved from above   RTB 1/99
               ;     temp1 = bytscl(temp,min=itmin, max=itmax, top=!d.n_colors-8)
               ;     if keyword_set(DEBUG) then begin
               ;       bytmin = min(temp1, max=bytmax)
               ;       print, 'Frame ',j,': hhmin and max after bytscl = ',bytmin, ' ', bytmax
               ;     endif
               ;     idat(*,*,j)=temp1
            endif
         endif
         position=[x0,y0,x1,y1]
         if(CENTERPOLE) then begin
            if(MLT_IMAGE) then begin
               ;TERMINATOR=0  ;  already set to 0 above
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
                     ; RCJ 02/05/2003 Confusing story here: the line below was not commented out but the
                     ; 2 lines below it were which was causing the line below to continue - because of the $ -
                     ; on the next uncommented line - the 'if(descriptor(0) eq 'VIS'". Of course that
                     ; line was never executed for VIS data because the descriptor(0) was 'VIS', not
                     ;'UVI'. This was causing some plots - PO_K1_VIS, var=Mapped_ImageM - to show
                     ; data past the 40 degree lat limit. Since it looks like nothing is to be done
                     ; to UVI data then I commented out the line below. (This comment is repeated above)
                     ;if(descriptor(0) eq "UVI") then $
                     ;if(mlat(li,lj) lt 50.0) then idat(li,lj,j)=0 & mmlat=50.0
                     ;if(mlat(li,lj) lt 40.0) then idat(li,lj,j)=0 & mmlat=40.0
                     ;if (descriptor(0) eq 'VIS') then begin
		     ; RCJ 02/21/2003  Now we decided that UVI images should also be cropped at 
		     ; 40 degrees lat:
                     if (descriptor(0) eq 'VIS') or (descriptor(0) eq 'UVI') then begin
                        ;if(mlat(li,lj) lt 40.0) then idat(li,lj,j)=0  
                        ; RCJ 03/03/2003 Working on PO_K1_VIS var=Mapped_ImageM 
			; Dealing w/ north and south hemisph.should be different
			; and CENTERLONLAT should be included. If this works add
			; similar code to the individual frame section.
                        ; (This comment is repeated in the 'individual frame' section)
			if centerlat gt 0 then begin
                           CENTERLONLAT=[180.0,90.0] 
			   ;if li eq 0 and lj eq 0 then print,'NORTH !!!!! ', centerlat
                           if(mlat(li,lj) lt 40.0) then idat(li,lj,j)=0
			endif else begin
                           CENTERLONLAT=[180.0,-90.0] 
			   ;if li eq 0 and lj eq 0 then print,'SOUTH !!!!! ', centerlat
                           if(mlat(li,lj) gt -40.0) then idat(li,lj,j)=0
			endelse   
	             endif  
                  endfor
               endfor
               ; RCJ 02/05/2003. I'm not sure why mmlat was being set inside the 'for' loop
               ; above. I hope this line is ok here.
               ;if (descriptor(0) eq 'UVI') or (descriptor(0) eq 'VIS') then mmlat=40.0
               ;if (descriptor(0) eq 'UVI') or (descriptor(0) eq 'VIS') then begin
	          ;if centerlat gt 0 then mmlat=40.0 else mmlat=-40.0
               ;endif
	       ; RCJ 03/03/2003 Rangelonlat input to auroral_image should be
	       ; different for north and south hemispheres. Shouldn't this also be
	       ; valid for 'pix' data?
               if (descriptor(0) eq 'UVI') or (descriptor(0) eq 'VIS') then begin
	          if centerlat gt 0 then thisrangeLonLat=[40.,-180.,90.,180.] else $
		     thisrangeLonLat=[-90.,-180.,-40.,180.]
               endif

               mag_lt=mlon-180.D0
               wcg=where(mag_lt ge 180.D0)
               if(wcg[0] ne -1) then mag_lt(wcg)=mag_lt(wcg)-360.D0
               wcg=where(mag_lt lt -180.D0)
               if(wcg[0] ne -1) then mag_lt(wcg)=mag_lt(wcg)+360.D0
               ;
	       ; RCJ 03/24/2003 This test was captured from the individual frame part
	       ; and changed the return to -1 (from 0)
               idmin=min(idat,max=idmax)
	       if (log10Z) then idmin = zvmin ;TJK 4/8/2004 - add for log scaling
               wcg=where(idat gt 0)
               if(wcg[0] eq -1) then begin
                  print, 'STATUS=No valid points for MLT plot; Select a new time range.'
                  print, 'ERROR=No valid image, mlat or mlon points' 
	          ; RCJ 03/24/2003 Make an empty graph w/ white background and close device:
	          if keyword_set(GIF) then begin
                     plot,[0],[0],background=255,color=0,xsty=4,ysty=4
		     xyouts,0.3,0.5,'[No valid points for MLT plot; Select a new time range]',/normal,color=0
		     deviceclose
		  endif   
	          ; RCJ 03/24/2003 Changed the return to -1 (from 0) 
                  return, -1
               endif
	       ;

;	       if keyword_set(DEBUG) then print, 'Calling 4th auroral_image'

               auroral_image, idat(*,*,j), mag_lt, mlat, method="PL",/mltgrid,$
                  centerLonLat=CENTERLONLAT,/nocolorbar,/CENTERPOLE,proj=map_proj,fillValue=-1.0e+31,$
                  ;rangeLonLat=[mmlat,-180.,90.,180.],mapcolor=mapcolor,$
                  rangeLonLat=thisrangeLonLat,$
		  position=position,SYMSIZE=0.5,$
                  mapCharSize=0.5,status=status, logZ=logZ

               ;     if(status lt 0) then return, 0
               ; end MLT
            endif else begin

;TJK 12/16/2008 add a bit of code to handle the GPS data
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

;               if keyword_set(DEBUG) then print, 'Calling 5th auroral_image'

;TJK 12/16/2008 allow another method and non 3-d glon and glat
;               auroral_image, idat(*,*,j), glon(*,*,j), glat(*,*,j),method="PL",/grid,$

               auroral_image, idat(*,*,j), longitude, latitude, method=method,/grid,$
                  centerLonLat=CENTERLONLAT, /nocolorbar,/CENTERPOLE,proj=map_proj,$
                  position=position,fillValue=-1.0e+31,SYMSIZE=0.5,$;label=2,$
                  /CONTINENTS,rangeLonLat=[btlat,-180.,btpole,180.],status=status,$
		  fill_cont=fill_cont,mapcolor=mapcolor, logZ=logZ
;TJK removed, this value should be set above ;projection='azimuthal projection'
               ; end pole-centered
            endelse
            ;     auroral_image, idat(*,*,j), glon(*,*,j), glat(*,*,j), $ 
            ;       /nogrid, centerLonLat=CENTERLONLAT, /CENTERPOLE,$
            ;       /nocolorbar, position=position 
            ;       /continent, /nogrid, minV=idmin, maxV=idmax, centerLonLat=CENTERLONLAT,$
            ;       title=shortdate,/nocolorbar,position=position, $ 
            ;;     /continent, /grid, minV=0., maxV=50., centerLonLat=CENTERLONLAT
         endif else begin  ; end if centerpole
            ; Test section of code for static image map display w/ distorted continental
            ; boundries
            if(FIXED_IMAGE) then begin
               if(descriptor(0) eq 'UVI') then begin
                  att=double(attit(*,j))
                  orb=double(gpos(*,j))
                  if(sys(j) lt 0) then system=sys(j)+3 else system=sys(j)
                  filter=fix(filt(j))-1
                  dsp_angle=double(dsp(j))
                  nxpix=200
                  nypix=228
               endif

               ; Map Image has registration problems w/o square image RTB 5/98
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
               pos=position
               if(descriptor(0) eq 'UVI') then begin
                  ;      grid_uvi,orb,att,dsp_angle,filter,system,idat(*,*,j),pos,xpimg,$
                  ;               ypimg,edat(j),s,nxpix,nypix,/POLE,/TERMINATOR,$
                  ;               SYMSIZE=0.5,/device
                  grid_uvi,orb,att,dsp_angle,filter,system,idat(*,*,j),pos,xpimg,ypimg,$
                     edat(j),s,nxpix,nypix,/GRID,/POLE,/TERMINATOR,/CONTINENT,$
                     SYMSIZE=0.5,/device
               endif else begin
                  if(descriptor(0) eq 'VIS') then begin
                     glatt=rotate(glat(*,*,j),3)
                     glont=rotate(glon(*,*,j),3)
                     idatt=rotate(idat(*,*,j),3)
                  endif else begin
                     glatt=glat(*,*,j)
                     glont=glon(*,*,j)
                     idatt=idat(*,*,j)
                  endelse
                  ; Must add POLE_S and POLE_N keywords
                  if(centerlat gt 0.0) then begin
                     ;grid_map,glat(*,*,j),glon(*,*,j),idat(*,*,j),pos,s,xpimg,ypimg,$ 
                     grid_map,glatt,glont,idatt,pos,s,xpimg,ypimg,$ 
                        /LABEL,/GRID,c_thick=1.0,/POLE_N,/device,c_charsize=1.5
                  endif else begin
                     ;grid_map,glat(*,*,j),glon(*,*,j),idat(*,*,j),pos,s,xpimg,ypimg,$
                     grid_map,glatt,glont,idatt,pos,s,xpimg,ypimg,$
                     /LABEL,/GRID,c_thick=1.0,/POLE_S,/device,c_charsize=1.5
                  endelse
               endelse ; descriptor condition
               projection='rendered projection'
               ;end new test section FIXED_IMAGE
            endif else begin

;	    if keyword_set(DEBUG) then print, 'Calling 6th auroral_image'
            if (map_proj eq 8 and project eq 'TIMED') then begin
		CenterLonLat=[0.,-90] ;show whole earth w/ both poles
	    endif
;TJK 12/10/2008 add a bit of code to handle the GPS data
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

;TJK               auroral_image, idat(*,*,j), glon(*,*,j), glat(*,*,j), $
;TJK                  method="PL",/continents, /grid,
;centerLonLat=CENTERLONLAT, $

               auroral_image, imagedata, longitude, latitude, $
                  method=method,/continents, /grid, centerLonLat=CENTERLONLAT, $
                  /nocolorbar, position=position,fillValue=-1.0e+31,SYMSIZE=0.5,$
                  status=status, proj=map_proj,fill_cont=fill_cont,isotropic=isotropic,$
		  central_azimuth=central_azimuth, rangelonlat=thisrangelonlat,$
		  mapcolor=mapcolor, logZ=logZ
            endelse
         endelse

         ; Plot terminator
         if(NOT FIXED_IMAGE) then begin
            if(TERMINATOR) then plots,s.lon,s.lat,color=foreground,thick=1.0   
         endif

         ; Print pole descriptor 
         lab_pos=tsize-35.0
         lab_pos1=tsize-25.0
         if(centerlat gt 0.0) then pole='N' else pole='S'
         ;xyouts, xpos, ypos-2, pole, color=!d.n_colors-1, /DEVICE ;

         if (map_proj ne 9) then begin ;TJK 5/14/2004 only label for non-cassini proj.
           xyouts, xpos, ypos-lab_pos, pole, color=foreground, charsize=1.2, /DEVICE 
	 endif

         ; Print time tag
         if (j eq 0) then begin
             prevdate = decode_cdfepoch(edat(j)) ;TJK get date for this record
         endif else prevdate = decode_cdfepoch(edat(j-1)) ;TJK get date for this record
         edate = decode_cdfepoch(edat(j)) ;TJK get date for this record
         shortdate = strmid(edate, 10, strlen(edate)) ; shorten i
         yyyymmdd = strmid(edate, 0,10) ; yyyymmdd portion of current
         prev_yyyymmdd = strmid(prevdate, 0,10) ; yyyymmdd portion of previous

         ;xyouts, xpos, ypos-10, shortdate, color=!d.n_colors-1, charsize=1.5, $
         ;xyouts, xpos, ypos-lab_pos1, shortdate, color=foreground, charsize=1.2,/DEVICE   
;TJK 11/10/2005 - use the longer date on these thumbnails since w/ new
;                 rumba machine, one can easly plot several days worth
;                 of plots
         if (((yyyymmdd ne prev_yyyymmdd) or (j eq 0)) and tsize gt 50 ) then begin
           xyouts, xpos, ypos-lab_pos1, edate, color=foreground, charsize=1.0,/DEVICE   
         endif else xyouts, xpos, ypos-lab_pos1, shortdate, color=foreground, charsize=1.2,/DEVICE

         icol=icol+1
      endfor
      ;
      ; done with the image
      if ((reportflag eq 1)AND(no_data_avail eq 0)) then begin
         PRINTF,1,'VARNAME=',astruct.(vnum).varname 
         PRINTF,1,'NUMFRAMES=',nimages
         PRINTF,1,'NUMROWS=',nrows & PRINTF,1,'NUMCOLS=',ncols
         PRINT,1,'THUMB_HEIGHT=',tsize+label_space
         PRINT,1,'THUMB_WIDTH=',tsize
         PRINTF,1,'START_REC=',start_frame
         PRINTF,1,'MAP_IMAGE=1'
      endif
      if (no_data_avail eq 0) then begin
         PRINT,'VARNAME=',astruct.(vnum).varname
         PRINT,'NUMFRAMES=',nimages
         PRINT,'NUMROWS=',nrows & PRINT,'NUMCOLS=',ncols
         PRINT,'THUMB_HEIGHT=',tsize+label_space
         PRINT,'THUMB_WIDTH=',tsize
         PRINT,'START_REC=',start_frame
         PRINT,'MAP_IMAGE=1'
      endif

      ; moved to end of routine:
      ; Add descriptive MESSAGE to for  parse.ph to parse along w/ the plot etc

      if ((keyword_set(CDAWEB))AND(no_data_avail eq 0)) then begin
         fname = GIF + '.sav' & save_mystruct,astruct,fname
      endif
      ; subtitle the plot
      ;  project_subtitle,astruct.(0),'',/IMAGE,TIMETAG=[edat(0),edat(nimages-1)]
      project_subtitle,astruct.(0),window_title,/IMAGE, $
         TIMETAG=[edat(0),edat(nimages-1)],TCOLOR=foreground

      ; RTB 10/96 add colorbar
      if COLORBAR then begin
         if (n_elements(cCharSize) eq 0) then cCharSize = 0.
         cscale = [idmin, idmax]  ; RTB 12/11
         ;  cscale = [zvmin, zvmax]
         xwindow = !x.window
         !y.window(1)=!y.window(1)
         ;  !y.window(1)=!y.window(1)+0.8
 
         !x.window(1)=0.858
         !y.window=[0.1,0.9]
         offset = 0.02 ;TJK 1/15/2009 - change from .01 to .02
         ;and changed below from .02 to 0.015 just to shift the
         ;the colorbar to the right for the thumbnails just a tad.
         ;This also narrows the colorbar just a tad (need room for labels).
         colorbar, cscale, ctitle, logZ=logZ, cCharSize=cCharSize, $ 
            position=[!x.window(1)+offset,!y.window(0),$
            !x.window(1)+offset+0.015, !y.window(1)],$
            fcolor=foreground, /image
         !x.window = xwindow
      endif ; colorbar

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
 
; Add descriptive MESSAGE to for  parse.ph to parse along w/ the plot etc
; TJK 5/14/2004 - only have this text for non-cassini like projections

if (map_proj ne 9) then begin
  if(CENTERPOLE) then begin
   if(SUN) then print, 'MESSAGE= POLE CENTERED MAP IMAGES - Fixed Sun (Geo. pole = white dot; N or S = hemisphere)' 
   if(MLT_IMAGE) then print, 'MESSAGE= MLT MAP IMAGES (GM pole = white dot; N or S = hemisphere)'
   if((NOT SUN) and (NOT MLT_IMAGE)) then print, 'MESSAGE= MAP IMAGE '
  endif else begin
   if(FIXED_IMAGE) then $
      print, 'MESSAGE= MAP OVERLAY (Geo. pole = white dot; N or S = hemisphere)'$
      else $
      print, 'MESSAGE= MAP IMAGES (Geo. pole = white dot; N or S = hemisphere)'
  endelse
endif

   if(n_elements(CENTERLONLAT) gt 0) then CENTERLONLAT=[-1,-1] ;set this to unrealistic numbers so that they
	;can be caught in auroral_image

return,0
end

