;+------------------------------------------------------------------------
; NAME: GRID_MAP 
; PURPOSE: To overlay a map grid on top of an image 
; CALLING SEQUENCE:
;        out = grid_map( )
; INPUTS:
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       Rich Baldwin,  Raytheon STX
;
;-------------------------------------------------------------------------
; testing continent outline option; need sat_pos
PRO grid_map,alat,alon,idat,pos,sun_term,xpimg,ypimg, $
             CONTINENT=CONTINENT, GRID=GRID, POLE_N=POLE_N, POLE_S=POLE_S,$
             TERMINATOR=TERMINATOR, LABEL=LABEL, _Extra=extra
    
rad=!pi/180.0

if NOT keyword_set(CONTINENT) then CONTINENT=0L
if NOT keyword_set(GRID) then GRID=0L
if NOT keyword_set(LABEL) then LABEL=0L
if NOT keyword_set(POLE_N) then POLE_N=0L
if NOT keyword_set(POLE_S) then POLE_S=0L
if NOT keyword_set(TERMINATOR) then TERMINATOR=0L
;
; Determine boundry of lat and lon arrays

ncd= where(alon gt 180.0,ncdn) 
if(ncdn ne 0) then alon(ncd)=alon(ncd)-360.0

idat=congrid(idat,xpimg,ypimg)
alat=congrid(alat,xpimg,ypimg)
alon=congrid(alon,xpimg,ypimg)

cond = (alat lt -90.) or (alat gt 90.0) or (alon lt -180.) or (alon gt 180.)
wBad = where(cond, wBadn);
wGood = where(cond ne 1,wGoodn)
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

if(NOT CONTINENT) then tv,idat,pos(0),pos(1),_Extra=extra

; plot window

xrange=[0,xpimg]
yrange=[0,ypimg]
  
plot,[0.0],[0.0],/nodata, XRANGE=xrange, YRANGE=yrange, POSITION=pos, $
     /noerase, xstyle=13, ystyle=13, _Extra=extra

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
   lat_levels=[-80,-60,-40,-20,20,40,60,80]
   if(LABEL) then begin
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
            cond = (alat(i,j) ge -90.) and $
               (alat(i,j) le 90.0) and $
               (alon(i,j) ge -180.) and $
               (alon(i,j) le 180.)
            if(cond) then begin
               x=r*cos(alat(i,j)*rad)*sin(alon(i,j)*rad)
               y=r*sin(alat(i,j)*rad)*sin(alon(i,j)*rad)
               z=r*cos(alon(i,j)*rad)
               arec=[x,y,z]
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
      OPLOT,plat(i:i+1),plon(i:i+1), COLOR=!d.n_colors-1, thick=1.2
      i = i + 1
   ENDWHILE
endif

END

;+------------------------------------------------------------------------
; NAME: PLOT_FUV_IMAGES
; PURPOSE: To plot FUV image data given in the input parameter astruct.
;          Can plot as "thumbnails" or single frames.
; CALLING SEQUENCE:
;       out = plot_FUV_images(astruct,vname)
; INPUTS:
;       astruct = structure returned by the read_mycdf procedure.
;       vname   = name of the variable in the structure to plot
;
; KEYWORD PARAMETERS:
;    CENTERLATLON = 2 element array of map center [latitude,longitude]
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
;	MOVIE = If this routine is being called to produce an mpeg then
;		we don't want the 'frame' number in the output filename.
;		This keyword takes care of that.
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
;
; MODIFICATION HISTORY:
;      12/08/00 : R. Burley    : Collaborated with H.Frey of UCB to process for
;                                IMAGE/FUV instrument.  Renamed plot_fuv_images
;                                to avoid conflict with original plot_map_images.
;      10/11/01 : RCJ : Made it work with CDAWeb s/w.
;-------------------------------------------------------------------------
FUNCTION plot_fuv_images, astruct, vname, $
                      XSIZE=XSIZE, YSIZE=YSIZE,FRAME=FRAME, $
                      GIF=GIF, REPORT=REPORT,$
                      TSTART=TSTART,TSTOP=TSTOP,NONOISE=NONOISE,$
                      CDAWEB=CDAWEB,DEBUG=DEBUG,COLORBAR=COLORBAR,$
                      MOVIE=MOVIE

if keyword_set(COLORBAR) then COLORBAR=1L else COLORBAR=0L
if keyword_set(REPORT) then reportflag=1L else reportflag=0L
if keyword_set(XSIZE) then xs=XSIZE else xs=512
if keyword_set(YSIZE) then ys=YSIZE else ys=512

if COLORBAR then xco=80 else xco=0 ; will add or not 80 columns to window size

; Determine the field number associated with the variable 'vname'
w = where(tag_names(astruct) eq strupcase(vname),wc)
if (wc eq 0) then begin
   print,'ERROR=No variable with the name:',vname,' in param 1!' & return,-1
endif else vnum = w(0)
   
; Verify the type of the first parameter and retrieve the data
;PRINT,'RETRIEVING DATA'
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

;Find & Parse DISPLAY_TYPE FOR ancillary map image variables
a = tagindex('DISPLAY_TYPE',tag_names(astruct.(vnum)))
if(a(0) ne -1) then display= astruct.(vnum).DISPLAY_TYPE $
else begin
   print, 'ERROR= No DISPLAY_TYPE attribute for variable'
endelse

;Parse DISPLAY_TYPE
keywords=str_sep(display,'>')  ; keyword 1 or greater 

; The DISPLAY_TYPE attribute may contain the THUMBSIZE  RTB
; The THUMBSIZE must be followed by the size in pixels of the images
wc=where(keywords eq 'THUMBSIZE',wcn)
if(wcn ne 0) then THUMBSIZE = fix(keywords(wc(0)+1))
; Check to see if any keywords are included in the display type
;if(n_elements(keywords) ge 2) then begin
   wcn=where(keywords eq 'CENTERPOLE',wc)
   if(wcn(0) ge 0) then CENTERPOLE = 1L else CENTERPOLE = 0L
   wcn=where(strupcase(keywords) eq 'SUN',wc)
   if(wcn(0) ge 0) then SUN = 1L else SUN = 0L 
   wcn=where(keywords eq 'TERMINATOR',wc)
   if(wcn(0) ge 0) then TERMINATOR = 1L else TERMINATOR = 0L
   wcn=where(keywords eq 'FIXED_IMAGE',wc)
   if(wcn(0) ge 0) then FIXED_IMAGE = 1L else FIXED_IMAGE = 0L
   wcn=where(keywords eq 'MLT_IMAGE',wc)
   if(wcn(0) ge 0) then MLT_IMAGE = 1L else MLT_IMAGE = 0L
;endif
if(MLT_IMAGE) then TERMINATOR=0L


; get 'instrument' from the descriptor...  RCJ
tip = tagindex('DESCRIPTOR',tag_names(astruct.(vnum)))
if (tip ne -1) then begin
   descrip=str_sep(astruct.(vnum).descriptor,'>')
endif else begin
   print,'ERROR= Structure is missing attribute DESCRIPTOR' & return,-1
endelse
instrument=strupcase(descrip(0))
if (instrument ne 'WIC') and (instrument ne 'SIP') $
   and (instrument ne 'SIE') then begin
   print,'Instrument is not WIC, SIP or SIE, or we simply do not have'
   print,' this information in epoch.descriptor.'
   print,' See plot_fuv_images.pro.'
   return,-1
endif   

;Determine which variable in the structure is the 'Epoch' data and retrieve it
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


if (instrument eq 'WIC') then begin   
   if keyword_set(FRAME) then begin
      start_frame = FRAME-1 & stop_frame = FRAME-1
      glat=fltarr(256,256)
      glon=fltarr(256,256)
      ;PRINT,'FRAME KEYWORD IS SET!' ; RBDEBUG
   endif else begin
      start_frame = 0L & stop_frame = n_elements(edat)-1
      glat=fltarr(256,256,n_elements(edat))
      glon=fltarr(256,256,n_elements(edat))
      ;PRINT,'FRAME KEYWORD IS NOT SET' ; RBDEBUG
   endelse
endif else begin      ;  ie if instrument is SIE or SIP
   if keyword_set(FRAME) then begin
      start_frame = FRAME-1 & stop_frame = FRAME-1
      glat=fltarr(128,128)
      glon=fltarr(128,128)
      ;PRINT,'FRAME KEYWORD IS SET!' ; RBDEBUG
   endif else begin
      start_frame = 0L & stop_frame = n_elements(edat)-1
      glat=fltarr(128,128,n_elements(edat))
      glon=fltarr(128,128,n_elements(edat))
      ;PRINT,'FRAME KEYWORD IS NOT SET' ; RBDEBUG
   endelse
endelse    

;print,'STARTFRAME=',start_frame,'  STOPFRAME=',stop_frame ;REDEBUG

;for record_number=start_frame,stop_frame do begin

;   time=LONARR(2)
;   fuv_read_epoch, edat[record_number], year, month, day, hr, min, sec $
;               , ms, ut, doy
;   time[0] = 1000*year + doy
;   time[1] = hr*60*60*1000 + min*60*1000 + sec*1000 + ms

d = tagindex('DAT',tag_names(astruct.orb_x))
if (d(0) ne -1) then oxdat = astruct.orb_x.DAT $
else begin
   d = tagindex('HANDLE',tag_names(astruct.orb_x))
   if (d(0) ne -1) then handle_value,astruct.orb_x.HANDLE,oxdat $
   else begin
      print,'ERROR= astruct.orb_x does not have DAT or HANDLE tag' & return,-1
   endelse
endelse
d = tagindex('DAT',tag_names(astruct.orb_y))
if (d(0) ne -1) then oydat = astruct.orb_y.DAT $
else begin
   d = tagindex('HANDLE',tag_names(astruct.orb_y))
   if (d(0) ne -1) then handle_value,astruct.orb_y.HANDLE,oydat $
   else begin
      print,'ERROR= astruct.orb_y does not have DAT or HANDLE tag' & return,-1
   endelse
endelse 

d = tagindex('DAT',tag_names(astruct.orb_z))
if (d(0) ne -1) then ozdat = astruct.orb_z.DAT $
else begin
   d = tagindex('HANDLE',tag_names(astruct.orb_z))
   if (d(0) ne -1) then handle_value,astruct.orb_z.HANDLE,ozdat $
   else begin
      print,'ERROR= astruct.orb_z does not have DAT or HANDLE tag' & return,-1
   endelse
endelse 
   
;   o_gci=fltarr(3)
;   o_gci(0)=oxdat[record_number]
;   o_gci(1)=oydat[record_number]
;   o_gci(2)=ozdat[record_number]

;   emis_hgt=120.
;   fuv_ptg_mod,astruct, vname, time, $
;          emis_hgt, glats, glons, l0, ras, decl, $
;          posX=posX, posY=posY, posZ=posZ, /geodetic, orbpos=o_gci,$
;          record_number=record_number,earthlat=earthlat,earthlon=earthlon
;   centerlatlon=[earthlon,earthlat] 

;   if keyword_set(frame) then begin
;      glat[*,*] = reverse(glats,1)  
;      glon[*,*] = reverse(glons,1)
;      idat[*,*] = rotate(idat[*,*,record_number],3)
;   endif else begin
;      glat[*,*,record_number] = reverse(glats,1)  
;      glon[*,*,record_number] = reverse(glons,1)
;      idat[*,*,record_number] = rotate(idat[*,*,record_number],3)
;   endelse   
;endfor  ; end for record_number

;centerpole=0l
;sun=0l
;mlt_image=0l
;terminator=0l
;fixed_image=0l
;
;; Check that  lons are b/w -180 and 180
;wcg=where(glon gt 180.0,wcgn)
;if(wcgn gt 0) then glon(wcg)=glon(wcg)-360.0
     
; I NEEDED TO ADD THE FOLLOWING STATEMENT IN ORDER TO GET A CORRECT FRAME TIMETAG
; IN THE WINDOW.  BECAUSE I TRIM IDAT MYSELF, THE FRAME HANDLING CODE BELOW THINKS
; THERE IS ONLY 1 IMAGE INPUT, AND SO IT ALWAYS TAKES THE FIRST EPOCH
;if (instrument eq 'WIC') and keyword_set(FRAME) then begin
;   d = tagindex('DAT',tag_names(astruct.(vnum)))
;   if (d(0) ne -1) then edat = astruct.(vnum).DAT $
;   else begin
;      d = tagindex('HANDLE',tag_names(astruct.(vnum)))
;      if (d(0) ne -1) then handle_value,astruct.(vnum).HANDLE,edat $
;      else begin
;         print,'ERROR= astruct.(vnum) does not have DAT or HANDLE tag' & return,-1
;      endelse
;   endelse 
;   ;edat = astruct.(c).DAT(FRAME-1) ; RBDEBUG 
;   edat=edat(*,*,frame-1)  
;endif

; Determine the title for the window or gif file
a = tagindex('SOURCE_NAME',tag_names(astruct.(vnum)))
if (a(0) ne -1) then b = astruct.(vnum).SOURCE_NAME else b = ''
; we've already proved that astruct.(vnum).descriptor exists.
b = b + '  ' + astruct.(vnum).DESCRIPTOR
window_title = b
; Determine title for colorbar
if(COLORBAR) then begin
   a=tagindex('UNITS',tag_names(astruct.(vnum)))
   if(a(0) ne -1) then ctitle = astruct.(vnum).UNITS else ctitle=''
endif

; Determine if data is a single image, if so then set the frame
; keyword because a single thumbnail makes no sense
; Define indices of image mid-point
isize = size(idat)
mid1=isize(1)/2+1
mid2=isize(2)/2+1
if (isize(0) eq 2) then n_images=1 else n_images=isize(isize(0))
if (n_images eq 1) then FRAME=1

   ; ******  Produce single frame

if keyword_set(FRAME) then begin ; produce plot of a single frame

   if ((FRAME ge 1)AND(FRAME le n_images)) then begin ; valid frame value
      ;
      ;
      time=LONARR(2)
      ;fuv_read_epoch, edat[record_number], year, month, day, hr, min, sec $
      fuv_read_epoch, edat[frame-1], year, month, day, hr, min, sec $
               , ms, ut, doy
      time[0] = 1000*year + doy
      time[1] = hr*60*60*1000 + min*60*1000 + sec*1000 + ms
      
      o_gci=fltarr(3)
      ;o_gci(0)=oxdat[record_number]
      ;o_gci(1)=oydat[record_number]
      ;o_gci(2)=ozdat[record_number]
      o_gci(0)=oxdat[frame-1]
      o_gci(1)=oydat[frame-1]
      o_gci(2)=ozdat[frame-1]

      emis_hgt=120.
      fuv_ptg_mod,astruct, vname, time, $
          emis_hgt, glats, glons, l0, ras, decl, $
          posX=posX, posY=posY, posZ=posZ, /geodetic, orbpos=o_gci,$
          ;record_number=record_number,earthlat=earthlat,earthlon=earthlon
          record_number=frame-1,earthlat=earthlat,earthlon=earthlon
	 ; RCJ 08/09/04  Added this test (same test for multiple images). 
	 ; I'm setting the lat and lon so that
	 ; the user gets something back (black images) not just an error.	
      if n_elements(earthlat) eq 0. then begin	
         print,'WARNING>Projection center not defined. Setting latitude and longitude to 0.'
	 earthlat = 0. & earthlon = 0.
      endif  	
      centerlatlon=[earthlon,earthlat] 

      ;if keyword_set(frame) then begin
         glat[*,*] = reverse(glats,1)  
         glon[*,*] = reverse(glons,1)
         ;idat[*,*] = rotate(idat[*,*,record_number],3)
         ;idat[*,*] = rotate(idat[*,*,frame-1],3)
      ;endif else begin
      ;   glat[*,*,record_number] = reverse(glats,1)  
      ;   glon[*,*,record_number] = reverse(glons,1)
      ;   idat[*,*,record_number] = rotate(idat[*,*,record_number],3)
      ;endelse   
      ; 
      ; Check that  lons are b/w -180 and 180
      wcg=where(glon gt 180.0,wcgn)
      if(wcgn gt 0) then glon(wcg)=glon(wcg)-360.0
      ;
      ;idat = idat(*,*,(FRAME-1)) ; grab the frame
      ; RCJ 02/27/02  After comparing to Rick's version of the code
      ; we found out we needed to rotate idat.
      idat = rotate(idat[*,*,frame-1],3) ; grab the frame
      ; SI has additional mirror and image should be reversed:
      if instrument eq 'SIE' or instrument eq 'SIP' then idat=reverse(idat,1)
      ;;glat = glat(*,*,(FRAME-1)) ; grab the frame
      ;;glon = glon(*,*,(FRAME-1)) ; grab the frame
      ;glat = glat(*,*) ; grab the frame
      ;glon = glon(*,*) ; grab the frame
      isize = size(idat) ; get the dimensions of the image
      ; 
      r1 = 450./isize(1) ; determine ratio for first dimension
      r2 = 450./isize(2) ; determine ratio for second dimension
      xs = ceil(isize(1)*r1)+50 ; determine xsize of window
      ys = ceil(isize(2)*r2)+15 ; determine ysize of window
      ;xs=300 - TJK commented these two out and uncommented the above two lines.
      ;ys=300 - 300x300 is too small for the large images, titles, etc. don't fit

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
      if wc gt 0 then begin
         if keyword_set(DEBUG) then print, 'Number of values below the valid min = ',wc
         print,'WARNING=setting ',wc,' fill values in image data to black...'
         idat(w) = 0 ; set pixels to black
         w = 0 ; free the data space
      endif

      ;TJK try not taking out the higher values and just scale them in.
      w = where((idat gt zvmax),wc)
      if wc gt 0 then begin
         if keyword_set(DEBUG) then print, 'Number of values above the valid max = ',wc
         if keyword_set(DEBUG) then print,'WARNING=setting ',wc,' fill values in image data to red...'
         ;    print, 'values are: ',idat(w)
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
;6/25/2004 replace w/ code below            idat(w) = zvmax -2; set pixels to red
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
      idmax=max(idat) 
      idmin=min(idat) ; RTB 10/96

      if keyword_set(DEBUG) then begin
         print, '!d.n_colors = ',!d.n_colors
	 print, 'min and max after filtering = ',idmin, ' ', idmax
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
            ; The next line is absolutely necessary or parse.ph
            ; won't find 'I_GIF=' and will give you a 
            ; 'no images specified' error msg
            print,'I_GIF=',GIF
         endif

         deviceopen,6,fileOutput=GIF,sizeWindow=[xs+xco,ys+30]
         ;print,'In plot_fuv_images. Gif size =',xs+xco,ys+30
         if (reportflag eq 1) then begin
            printf,1,'I_GIF=',GIF & close,1
         endif
      endif else begin ; open the xwindow
         window,/FREE,XSIZE=xs+xco,YSIZE=ys+30,TITLE=window_title
      endelse

      xmargin=!x.margin
      if COLORBAR then begin 
         if (!x.omargin(1)+!x.margin(1)) lt 14 then !x.margin(1) = 14
         !x.omargin(1) = 10
	;TJK changed omargin from 4 to 10 to allow more room for the label
         plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
      endif
      !y.omargin(0) = 2
      cond = (glat gt -90.1) and (glat lt 90.1)
      wgoo=where(cond,wgoon)
      if (wgoon eq 0) then return,-1 else clat=glat(wgoo) 
      wn=where(clat gt 0.01, wzn)
      ws=where(clat lt -0.01, wzs)
      if(wzn ge wzs) then begin
         if(wzn ne 0) then centerlat=clat(wn(wzn/2)) else centerlat=glat(mid1,mid2)
      endif else begin
         if(wzs ne 0) then centerlat=clat(ws(wzs/2))
      endelse

      ; Define Fixed Geo. position
      if(CENTERPOLE) then begin
         if(centerlat gt 0.0) then begin
            CENTERLATLON=[180.0,90.0]
            btpole=90.0
            wlat=where(glat lt btlat,wlatc)
            if(wlatc gt 0) then idat(wlat)=0 
            if(wlatc gt 0) then glat(wlat)=-1.0e+31
         endif else begin
            CENTERLATLON=[180.0,-90.0]
            btpole=-90.0
            wlat=where(glat gt btlat,wlatc)
            if(wlatc gt 0) then idat(wlat)=0
            if(wlatc gt 0) then glat(wlat)=-1.0e+31
         endelse
      endif

      ; Compute Noon Sun position
      if(SUN) then begin
         SUN,IYR,IDAY,IHOUR,MIN,ISEC,GST,SLONG,SRASN,SDEC,epoch=edat(FRAME-1)
         p=[cos(sdec)*cos(srasn),cos(sdec)*sin(srasn),sin(sdec)]
         geigeo,p(0),p(1),p(2),xgeo,ygeo,zgeo,1,epoch=edat(FRAME-1)
         sunln=atan2d(ygeo,xgeo)
         sunlt=atan2d(zgeo,sqrt(xgeo*xgeo+ygeo*ygeo))
         sunln=sunln+180
         if(sunln gt 180.0) then sunln = sunln - 360.0
         if(centerlat gt 0.0) then CENTERLATLON=[sunln,90.0] else $
				CENTERLATLON=[sunln,-90.0]
      endif

      ; Derive day-night terminator
      if(TERMINATOR) then begin
         SUN,IYR,IDAY,IHOUR,MIN,ISEC,GST,SLONG,SRASN,SDEC,epoch=edat(FRAME-1)
         p=[cos(sdec)*cos(srasn),cos(sdec)*sin(srasn),sin(sdec)]
         geigeo,p(0),p(1),p(2),xgeo,ygeo,zgeo,1,epoch=edat(FRAME-1)
         sunlon=atan2d(ygeo,xgeo)
         sunlat=atan2d(zgeo,sqrt(xgeo*xgeo+ygeo*ygeo))
         s=terminator(sunlat,sunlon)
      endif


      ; Scale colors before plotting
      ; Moved from above   RTB 1/99
      idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)
      if keyword_set(DEBUG) then begin
         bytmin = min(idat, max=bytmax)
         print, 'min and max after bytscl = ',bytmin, ' ', bytmax
      endif

      if(CENTERPOLE) then begin
         if(MLT_IMAGE) then begin
            ;Convert to MLT
            msz=size(glat)
            xdim=msz(1) 
            ydim=msz(2) 
            mlat=fltarr(xdim,ydim)
            mlon=fltarr(xdim,ydim)
            galt=120.0+6378.16  ; UVI and VIS presumed emission height. 
            cdf_epoch, edat(FRAME-1), yr,mn,dy,hr,min,sec,milli,/break
            ical,yr,doy,mn,dy,/idoy
            sod=long(hr*3600.0+min*60.+sec)
            doy=fix(doy)
            for li=0,xdim-1 do begin
               for lj=0,ydim-1 do begin
                  if((glat(li,lj) lt 90.1) and (glat(li,lj) gt -90.1) and (glon(li,lj) lt 180.1) and (glon(li,lj) gt -180.1)) then begin 
                     dum2 =  float(glat(li,lj)) 
                     dum3 =  float(glon(li,lj)) 
                     ;print, yr,doy,sod,galt,glat(li,lj),glon(li,lj)
                     opos = eccmlt(yr,doy,sod,galt,dum2,dum3)
                  endif else begin
                     opos=[99999.0,99999.0,99999.0]
                  endelse
                  mlat(li,lj)=opos(1)
                  mlon(li,lj)=opos(2)*15.0
                  if(mlat(li,lj) lt 40.0) then idat(li,lj)=0 & mmlat=40.0
               endfor
            endfor
            mag_lt=mlon-180.0
            wcg=where(mag_lt ge 180.0,wcgn)
            if(wcgn gt 0) then mag_lt(wcg)=mag_lt(wcg)-360.0
            wcg=where(mag_lt lt -180.0,wcgn)
            if(wcgn gt 0) then mag_lt(wcg)=mag_lt(wcg)+360.0
            ;idmin=min(idat,max=idmax)
            wcg=where(idat gt 0,wcgn)
            if(wcgn eq 0) then begin
               print, 'STATUS=No valid points for MLT plot; Select a new time range.'
               print, 'ERROR=No valid image, mlat or mlon points' 
               return, -1
            endif

            auroral_image, idat, mag_lt, mlat, method="PL",/mltgrid,$
               centerLonLat=CENTERLATLON, /nocolorbar,/CENTERPOLE,proj=6,$
               fillValue=-1.0e+31,rangeLonLat=[mmlat,-180.,90.,180.],$
               status=status,charsize=2.0
         endif else begin
            auroral_image, idat, glon, glat, /continent,/label,$
               method="PL",/grid, centerLonLat=CENTERLATLON, /nocolorbar,/CENTERPOLE,proj=6,$
               fillValue=-1.0e+31,rangeLonLat=[btlat,-180.,btpole,180.],status=status,charsize=2.0
            projection='azimuthal projection'
           if(TERMINATOR) then plots,s.lon,s.lat,color=!d.n_colors-1,thick=2.0
         endelse & stop
      endif else begin
         ; Test section of code for static image map display w/ distorted continental
         ; boundries
         if(FIXED_IMAGE) then begin
            xpos1=30. 
            ypos1=60. 
            xpimg=isize(1)*r1-40
            ypimg=isize(2)*r2-40
            x_img_org = xpos1+30. 
            y_img_org = ypos1 
            pos = [x_img_org, y_img_org,x_img_org+xpimg, y_img_org+ypimg]
            if(centerlat gt 0.) then begin
               grid_map,glat,glon,idat,pos,s,xpimg,ypimg,/GRID,$
	       /LABEL,/POLE_N, /device, c_charsize=1.5
            endif else begin
               grid_map,glat,glon,idat,pos,s,xpimg,ypimg,/GRID,$
               /LABEL,/POLE_S, /device, c_charsize=1.5
            endelse
            ; turn terminator off for now
            TERMINATOR=0L 
            projection='rendered projection'
         endif else begin
            ; RBDEBUG, THIS IS THE CALL TO AURORAL IMAGE USED BY FUV/WIC
            ; RBDEBUG, charsize changed from 2.0 to 1.0
            ; RBDEBUG, projection changed from 'satellite projection' to null
            ;print,'going to auroral image.......',!d.name
            ;help,idat,glon,glat
            auroral_image, idat, glon, glat, $
               method="PL",/continents, /grid , centerLonLat=CENTERLATLON,$
               /nocolorbar,fillValue=-1.0e+31,status=status,charsize=1.0,/label
            projection=''
            if(TERMINATOR) then plots,s.lon,s.lat,color=!d.n_colors-1,thick=2.0
         endelse
      endelse

      project_subtitle,astruct.(0),window_title,/IMAGE,$
			TIMETAG=edat(FRAME-1), TCOLOR=!d.n_colors-1
      ; Print orientation
      xyouts, 0.06, 0.08, projection ,color=!d.n_colors-1,/normal

      ; RTB 10/96 add colorbar
      if COLORBAR then begin
         if (n_elements(cCharSize) eq 0) then cCharSize = 0.
         cscale = [idmin, idmax] ; RTB 12/11
         ; cscale = [zvmin, zvmax]
         xwindow = !x.window
         if(FIXED_IMAGE) then offset=0.05 else offset = 0.01
         offset = 0.01
         colorbar, cscale, ctitle, logZ=logZ, cCharSize=cCharSize, $
         position=[!x.window(1)+offset,      !y.window(0),$
                  !x.window(1)+offset+0.03, !y.window(1)],$
                  fcolor=!d.n_colors-1, /image
         !x.window = xwindow
      endif ; colorbar
      if keyword_set(GIF) then deviceclose

      ;print,'Finished one frame!!!!!!!!!!!!!'     

   endif ; valid frame value. 

   ; ******  Produce thumbnails of all images

endif else begin ; produce thumbnails of all images
   if(n_elements(THUMBSIZE) gt 0) then tsize = THUMBSIZE else tsize = 166
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
      if ((start_frame ne 0) OR (stop_frame ne nimages)) then begin
         idat = idat(*,*,start_frame:stop_frame)
         isize = size(idat) ; determine the number of images in the data
	 ; RCJ 02/27/02  After comparing to Rick's version of the code
         ; we found out we needed to rotate idat.
	 for b=0,isize(3)-1 do begin
            idat[*,*,b] = rotate(idat[*,*,b],3)
	    if instrument eq 'SIP' or instrument eq 'SIE' then $
	       idat[*,*,b]=reverse(idat[*,*,b],1)
	 endfor   
         glat = glat(*,*,start_frame:stop_frame)
         glon = glon(*,*,start_frame:stop_frame)
         if (isize(0) eq 2) then nimages = 1 else nimages = isize(isize(0))
         edat = edat(start_frame:stop_frame)
      endif
   endelse

   ; calculate number of columns and rows of images
   ncols = xs / tsize & nrows = (nimages / ncols) + 1
   label_space = 24 ; TJK added constant for label spacing
   boxsize = tsize+label_space;TJK added for allowing time labels for each image.
   ys = (nrows*boxsize) + 15

   ; Perform data filtering and color enhancement if any data exists
   if (no_data_avail eq 0) then begin
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
   
      ;; Set all pixels in idat to 0 if position invalid  RTB 1/99 
      ;wlat=where(glat lt -90.0, wlatc)
      ;if(wlatc gt 0) then idat(wlat) = 0;
      ;wlon=where(glon lt -180.0, wlonc)
      ;if(wlonc gt 0) then idat(wlon) = 0;
   
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
   
      idat = bytscl(idat,min=idmin, max=idmax, top=!d.n_colors-8)
   
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
         if (!x.omargin(1)+!x.omargin(1)) lt 14 then !x.omargin(1) = 14
         !x.omargin(1) = 14
	 ;print, '****set x.ormargin(1) to 14 instead of 4'
         plot,[0,1],[0,1],/noerase,/nodata,xstyle=4,ystyle=4
      endif
   
      ; generate the thumbnail plots
   
      irow=0
      icol=0
      for j=0,nimages-1 do begin
         ;
         ;
         time=LONARR(2)
         ;fuv_read_epoch, edat[record_number], year, month, day, hr, min, sec $
         fuv_read_epoch, edat[j], year, month, day, hr, min, sec $
               , ms, ut, doy
         time[0] = 1000*year + doy
         time[1] = hr*60*60*1000 + min*60*1000 + sec*1000 + ms

         o_gci=fltarr(3)
         ;o_gci(0)=oxdat[record_number]
         ;o_gci(1)=oydat[record_number]
         ;o_gci(2)=ozdat[record_number]
         o_gci(0)=oxdat[j]
         o_gci(1)=oydat[j]
         o_gci(2)=ozdat[j]

         emis_hgt=120.
         
         fuv_ptg_mod,astruct, vname, time, $
                emis_hgt, glats, glons, l0, ras, decl, $
                posX=posX, posY=posY, posZ=posZ, /geodetic, orbpos=o_gci,$
                ;record_number=record_number,earthlat=earthlat,earthlon=earthlon
                record_number=j,earthlat=earthlat,earthlon=earthlon
	 ; RCJ 08/09/04  Added this test (same test for one image). 
	 ; I'm setting the lat and lon so that
	 ; the user gets something back (black images) not just an error.	
         if n_elements(earthlat) eq 0. then begin	
            print,'WARNING>Projection center not defined. Setting latitude and longitude to 0.'
	    earthlat = 0. & earthlon = 0.
         endif  	
         centerlatlon=[earthlon,earthlat] 
         ;glat[*,*,record_number] = reverse(glats,1)  
         ;glon[*,*,record_number] = reverse(glons,1)
         ;idat[*,*,record_number] = rotate(idat[*,*,record_number],3)
         glat[*,*,j] = reverse(glats,1)  
         glon[*,*,j] = reverse(glons,1)
         ;idat[*,*,j] = rotate(idat[*,*,j],3)
         
         ; Check that  lons are b/w -180 and 180
         wcg=where(glon gt 180.0,wcgn)
         if(wcgn gt 0) then glon(wcg)=glon(wcg)-360.0

         ;
         ;
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
         if(CENTERPOLE) then begin
            if(NOT MLT_IMAGE) then begin
               ; The following code flags points which will fall outside the map area.
               oosz=size(glat)
               xdim=oosz(1)
               ydim=oosz(2)
               for li=0,xdim-1 do begin
                  if(centerlat gt 0.0) then begin
                     CENTERLATLON=[180.0,90.0] 
                     btpole=90.0
                     wlat=where(glat(li,*,j) lt btlat,wlatc)
                     if(wlatc gt 0) then glat(li,wlat,j)=-1.0e+31
                  endif else begin 
                     CENTERLATLON=[180.0,-90.0] 
                     btpole=-90.0
                     wlat=where(glat(li,*,j) gt btlat,wlatc)
                     if(wlatc gt 0) then glat(li,wlat,j)=-1.0e+31
                  endelse
               endfor
            endif
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
            ; If the descriptor is pixie (PIX) get sub-solar point location from the
            ; geo lat and long
            SUN,IYR,IDAY,IHOUR,MIN,ISEC,GST,SLONG,SRASN,SDEC,epoch=edat(j)
            p=[cos(sdec)*cos(srasn),cos(sdec)*sin(srasn),sin(sdec)]
            geigeo,p(0),p(1),p(2),xgeo,ygeo,zgeo,1,epoch=edat(j)
            sunlon=atan2d(ygeo,xgeo)
            sunlat=atan2d(zgeo,sqrt(xgeo*xgeo+ygeo*ygeo))
            s=terminator(sunlat,sunlon)
         endif
      
         position=[x0,y0,x1,y1]
         if(CENTERPOLE) then begin
            if(MLT_IMAGE) then begin
               ;TERMINATOR=0L
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
                     mlat(li,lj)=opos(1)
                     mlon(li,lj)=opos(2)*15.0
                  endfor
               endfor
               mag_lt=mlon-180.D0
               wcg=where(mag_lt ge 180.D0,wcgn)
               if(wcgn gt 0) then mag_lt(wcg)=mag_lt(wcg)-360.D0
               wcg=where(mag_lt lt -180.D0,wcgn)
               if(wcgn gt 0) then mag_lt(wcg)=mag_lt(wcg)+360.D0
               ;
               auroral_image, idat(*,*,j), mag_lt, mlat, method="PL",/mltgrid,$
                  centerLonLat=CENTERLATLON, /nocolorbar,/CENTERPOLE,proj=6,fillValue=-1.0e+31,$
                  rangeLonLat=[mmlat,-180.,90.,180.],position=position,SYMSIZE=0.5,$
                  mapCharSize=0.5,status=status
               ; end MLT
            endif else begin
               auroral_image, idat(*,*,j), glon(*,*,j), glat(*,*,j),method="PL",/grid,$
                  centerLonLat=CENTERLATLON, /nocolorbar,/CENTERPOLE,proj=6,$
                  position=position,fillValue=-1.0e+31,SYMSIZE=0.5,$;label=2,$
                  /CONTINENT,rangeLonLat=[btlat,-180.,btpole,180.],status=status
               projection='azimuthal projection'
   
               ; end pole-centered
            endelse
         endif else begin
            ; Test section of code for static image map display w/ distorted continental
            ; boundries
            if(FIXED_IMAGE) then begin
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
               ;
               pos=position
               glatt=glat(*,*,j)
               glont=glon(*,*,j)
               idatt=idat(*,*,j)
               if(centerlat gt 0.0) then begin
                  grid_map,glatt,glont,idatt,pos,s,xpimg,ypimg,$ 
                     /LABEL,/GRID,c_thick=1.0,/POLE_N,/device,c_charsize=1.5
               endif else begin
                  grid_map,glatt,glont,idatt,pos,s,xpimg,ypimg,$
                     /LABEL,/GRID,c_thick=1.0,/POLE_S,/device,c_charsize=1.5
               endelse
               projection='rendered projection'
            endif else begin
               auroral_image, idat(*,*,j), glon(*,*,j), glat(*,*,j), $
                  method="PL",/continents, /grid , centerLonLat=CENTERLATLON,$
                  /nocolorbar,fillValue=-1.0e+31,status=status,position=position,$
                  symsize=0.5
               projection=''

               ;auroral_image, idat(*,*,j), glon(*,*,j), glat(*,*,j), $
               ;   method="PL",/continent, /grid, centerLonLat=CENTERLATLON, $
               ;   /nocolorbar, position=position,fillValue=-1.0e+31,SYMSIZE=0.5,$
               ;   status=status ;,label=2
            endelse
         endelse
   
         ; Plot terminator
         if(NOT FIXED_IMAGE) then begin
            if(TERMINATOR) then plots,s.lon,s.lat,color=!d.n_colors-1,thick=1.0   
         endif
   
         ; Print pole descriptor 
         lab_pos=tsize-35.0
         lab_pos1=tsize-25.0
         if(centerlat gt 0.0) then pole='N' else pole='S'
         xyouts, xpos, ypos-lab_pos, pole, color=!d.n_colors-1, charsize=1.2, /DEVICE ;
   
         ; Print time tag
         foreground = !d.n_colors-1

         if (j eq 0) then begin
             prevdate = decode_cdfepoch(edat(j)) ;TJK get date for this record
         endif else prevdate = decode_cdfepoch(edat(j-1)) ;TJK get date for this record
 
         edate = decode_cdfepoch(edat(j)) ;TJK get date for this record
         shortdate = strmid(edate, 10, strlen(edate)) ; shorten it
         yyyymmdd = strmid(edate, 0,10) ; yyyymmdd portion of current
         prev_yyyymmdd = strmid(prevdate, 0,10) ; yyyymmdd portion of previous
 
;        xyouts, xpos, ypos-lab_pos1, shortdate, color=!d.n_colors-1, charsize=1.2, $
;            /DEVICE   
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
         PRINTF,1,'FUV_IMAGE=1'
      endif
      if (no_data_avail eq 0) then begin
         PRINT,'VARNAME=',astruct.(vnum).varname
         PRINT,'NUMFRAMES=',nimages
         PRINT,'NUMROWS=',nrows & PRINT,'NUMCOLS=',ncols
         PRINT,'THUMB_HEIGHT=',tsize+label_space
         PRINT,'THUMB_WIDTH=',tsize
         PRINT,'START_REC=',start_frame
         PRINT,'FUV_IMAGE=1'
      endif
   
      ; Add descriptive MESSAGE to for  parse.ph to parse along w/ the plot etc
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
   
      if ((keyword_set(CDAWEB))AND(no_data_avail eq 0)) then begin
         fname = GIF + '.sav' & save_mystruct,astruct,fname
      endif
      ; subtitle the plot
      ;  project_subtitle,astruct.(0),'',/IMAGE,TIMETAG=[edat(0),edat(nimages-1)]
      project_subtitle,astruct.(0),window_title,/IMAGE, $
         TIMETAG=[edat(0),edat(nimages-1)],TCOLOR=!d.n_colors-1
    
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

