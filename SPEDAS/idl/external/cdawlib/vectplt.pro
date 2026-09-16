;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/vectplt.pro,v 1.12 2001/11/26 18:32:30 johnson Exp johnson $
;$Locker: johnson $
;$Revision: 8 $
;+
; NAME: VECTPLT.PRO 
;
; PURPOSE:  Multi-purpose vector plotting routine for CDF data file 
;	    representation
;
; CALLING SEQUENCE:
;
;   vectplt,mlats,mlons,malts,vest,vnrt,mytimes,qflgs,Stitle=station,$
;           mcors=mltin,Qmin=qmin,Qmax=qmax,nopolar=nop,Scale=scale,nobin=nob,$
;           p0lat=p0lat,p0lon=p0lon,rot=rot,binlat=bin_lat,binlon=bin_lon,$
;           limit=limit,latdel=latdel,londel=londel,Alt=alt,Ttitle=thetitle,$
;           lthik=lthik,symsiz=symsiz,symcol=symcol,_extra=extras
;
; VARIABLES:
;
; Input:
;
; mlats(*)    - an N element array of geographic latitudes
; mlons(*)    - an N element array of geographic longitudes
; malts(*)    _ an N element array of geographic altitudes
; vest(*)     - an N element array of the eastward component velocity vector
; vnrt(*)     - an N element array of the northward component velocity vector
; mytimes     - an IDL structure comprised of the following: year, day of year,
;	        month, day of month, and an N element array of seconds of day
; qflgs       - an N element array of the quality flag
;  
; Keyword Parameters: 
;
; Stitle=station  	- Observing Station Name
; mcors=mltin		- Coordinate Transformation Flag 
;				0 - Eccentric Dipole Magnetic Local Time
;				1 - Altitude Adjusted Corrected Geomagnetic
;				    Coordinates (AACGC) MLT
;				2 - Geographic Coordinates
; Qmin=qmin		- Minimum exceptable quality flag
; Qmax=qmax		- Maximum exceptable quality flag
; nopolar=nop		- Disables clockdial display; enables user defined 
;			  projections  
; Scale=scale		- Set the size of vectors plotted (1000 default)
; nobin=nob		- turns off binning and averaging of vectors
; binlat=bin_lat	- latitude bin interval  
; binlon=bin_lon	- longitude bin interval
; p0lat=p0lat		- map_set argument; latitude center of map
; p0lon=p0lon		- map_set argument; longitude center of map
; rot=rot		- map_set argument; rotation of map
; limit=limit		- map_set limits 
; latdel=latdel		- latitude interval
; londel=londel		- longitude interval
; Alt=alt		- Altitude of coordinate transformation
; Ttitle=thetitle	- Title for plot
; lthik=lthik           - vector line thickness
; symsiz=symsiz         - vector position marker
; symcol=symcol         - vector position marker color
;   
;
; REQUIRED PROCEDURES:
;	This procedure requires the routine  GENLIB.PRO
;       and a shared object module, LIB_PGM.so, of C and fortran source.
;
;-------------------------------------------------------------------
; History
;
; Revision 1.1  94/10/31  09:49:24  09:49:24  baker (Kile Baker S1G)
;
; Initial version: Based on dn_cdf.pro  
;
;         1.0  R. Baldwin  HSTX     9/28/95 
;                 Initial version: Based on dn_cdf.pro 10/31/94 (Kile Baker)
;         1.1  R. Baldwin  HSTX    10/23/95
;                 Options included for eccentric & AACGC MLT coordinate
;		  transformation; geographic coordinates; polar and non-polar
;		  representations; vector magnitude; quality flag bounds;
;		  option for binning;  
;          1.2 R. Baldwin HSTX     11/15/95
;                 Title, margin options added; londel & latdel variables
;                 revised
; 	   1.3 R. Baldwin HSTX     12/18/95
; 		  Rotation of vectors is a magnetic system from
;		  geographic to geomagnetic
;
;-------------------------------------------------------------------

function vectplt,mlats,mlons,malts,vest,vnrt,mytimes,qflgs,Stitle=station,$
    mcors=mltin,Qmin=qmin,Qmax=qmax,nopolar=nop,Scale=scale,nobin=nob,$
    p0lat=p0lat,p0lon=p0lon,rot=rot,binlat=bin_lat,binlon=bin_lon,$
    limit=limit,latdel=latdel,londel=londel,Alt=alt,xmargin=xmargin,$
    ymargin=ymargin,Ttitle=thetitle,lthik=lthik,symsiz=symsiz,symcol=symcol,$
    _extra=extras

; Establish error handler
  catch, error_status 
  if(error_status ne 0) then begin
   if((error_status eq -108) or (error_status eq -133)) then begin
    print, 'STATUS= No plottable data.'
    print, 'ERROR=Error number: ',error_status,' in vectplt.'
    print, 'ERROR=Error Message: ', !ERR_STRING
   endif else begin
    print, 'STATUS= Data cannot be plotted.'
    print, 'ERROR=Error number: ',error_status,' in vectplt.'
    print, 'ERROR=Error Message: ', !ERR_STRING
   endelse
   return,-1 
  endif


icnt=n_elements(mlats)

if (n_elements(mlons) ne icnt or n_elements(malts) ne icnt or $
    n_elements(vest) ne icnt or n_elements(vnrt) ne icnt or $
    n_elements(mytimes.times) ne icnt or n_elements(qflgs) ne icnt) then $
            message, 'Arrays have incorrect size.'

if(n_elements(nop) eq 0) then nop=0
if(n_elements(lthik) eq 0)then lthik = 1.7
if(n_elements(symcol) eq 0)then symcol = 100 
if(n_elements(symsiz) eq 0)then symsiz = 0.5 
; Set Scale
if(n_elements(scale) ne 0) then Scale=scale else scale=1000 
; Set Title
yrst=strmid(strcompress(string(mytimes.year),/remove_all),2,2)
monst=string(mytimes.mon)
if mytimes.mon lt 10 then monst = '0'+monst
dayst=string(mytimes.day)
if mytimes.day lt 10 then dayst = '0'+dayst

; patch
 if(!d.name eq 'X') then bkgrd=255 & dtxt=0.5
 if(!d.name eq 'Z') then bkgrd=0 & dtxt=1.0

; new code 

 if n_elements(mltin) eq 0 then mltin=0
 if mltin eq 2 then nop=1   
 if(keyword_set(qmin)) then Qmin=qmin else qmin=0 
 if(keyword_set(qmax)) then Qmax=qmax else qmax=4 

 if(n_elements(limit) ne 0) then begin
      ymin=limit(0) & xmin=limit(1) & ylim=limit(2) & xlim=limit(3) 
 endif else begin
     ymin=60. & xmin=-180. & ylim=90. & xlim=180. 
 endelse
; Check for S polar plot
spole=0
if(ymin eq -90. and nop eq 0) then spole=1 
 if(n_elements(latdel) eq 0) then latdel=10.0
 if(n_elements(londel) eq 0) then londel=45.0
; Set Binning intervals
if keyword_set(nobin) then begin
 if(n_elements(bin_lat) ne 0) then bin_lat=bin_lat else bin_lat=1.
 if(n_elements(bin_lon) ne 0) then bin_lon=bin_lon else bin_lon=2.
endif
; Set Altitude
 if(n_elements(alt) ne 0) then Alt=alt else alt=400.

;if(mltin eq 1) then begin
;for i=0,icnt-1 do begin
;       malts(i)=alt
;opos=cnvcoord(mlats(i),mlons(i),malts(i))
;mlats(i) = opos(0)
;mlons(i) = opos(1)
;endfor
;endif

	mglons=mlons
	vcount=0
	if mltin eq 1 then begin
           print, 'AACGC ', mltin
		isoy=0L
		FOR I=0,ICNT-1 DO BEGIN

                 malts(i)=alt
	         opos=cnvcoord(mlats(i),mlons(i),malts(i))
		 mlats(i) = opos(0)
		 mlons(i) = opos(1)
		 mglons(i) = opos(1)

  		  temp = mytimes.times(i)+(mytimes.doy-1)*24*3600
               	  isoy = long(temp)
                  if( spole eq 0) then begin
                    mlons(i) = 180.0 + 15.*mlt(mytimes.year,isoy,mlons(i))
                  endif else begin
                    mlons(i) =  15.*mlt(mytimes.year,isoy,mlons(i))
                  endelse
		  if mlons(i) gt 180. then mlons(i)=mlons(i)-360.
; printf,4, mytimes.year,isoy,mytimes.times(i),mytimes.doy,mlons(i)
		endfor
                utalon = (mytimes.times(0)/3600.0)*15.0
		zlon = mlons(0) - utalon 
                print, zlon,'0 UT',utalon
		noonstr='0 UT'
        endif
	if mltin eq 0 then begin
;               print, 'ECC ', mltin
                sod=0L
		for i=0,icnt-1 do begin
                   malts(i)=malts(i)+6371.2
                   sod = long(mytimes.times(i))
;printf, 4, mytimes.year,mytimes.doy,sod,malts(i),mlats(i),mlons(i),vest(i),$
;         vnrt(i),qflgs(i)
         opos = eccmlt(mytimes.year,mytimes.doy,sod,malts(i),mlats(i),mlons(i))
		   mglons(i) = opos(0)
		   mlats(i) = opos(1)
        	   mlons(i) = opos(2)
                        if( spole eq 0) then begin
			  mlons(i)= 180.0 + mlons(i)*15.0
                        endif else begin
			  mlons(i)= mlons(i)*15.0
    			endelse
			iF mlons(i) gt 180. then mlons(i)=mlons(i)-360.
		endfor
                utalon = (mytimes.times(0)/3600.0)*15.0
                zlon = mlons(0) - utalon
;               print, zlon,'0 UT',utalon
                noonstr='0 UT'
	endif

       if(keyword_set(nob)) then begin
         b_vest=vest
         b_vnrt=vnrt
         angs = b_vest
         lats = mlats
         lons = mlons
         b_cont=vnrt
         b_cont(*)=1
         b_data=b_cont 
         b_data(*)=0
         nvects = icnt
         b_mlat=mlats
         b_mlon=mglons
	 b_malt=malts 
        
       endif else begin

	bin_lat = 1.
	bin_lon = 2.
	nbin_lat = abs(ylim-ymin)/bin_lat
	nbin_lon = abs(xlim-xmin)/bin_lon
	lats = fltarr(nbin_lat*nbin_lon)
	lons = fltarr(nbin_lat*nbin_lon)

;       print, ylim,ymin,xlim,xmin,nbin_lat,nbin_lon
;       print, nop,mltin,qmin,qmax

	for j = 0,nbin_lat-1 do begin
		lat = float(j)*bin_lat + ymin + bin_lat/2.
		for i=0,nbin_lon-1 do begin
			lon = float(i)*bin_lon + bin_lon/2.
			lats(i+j*nbin_lon) = lat
			lons(i+j*nbin_lon) = lon - 180.
		endfor
	endfor

	nvects = nbin_lat*nbin_lon

	b_vest = fltarr(nvects)
	b_vnrt = fltarr(nvects)
	b_cont = lonarr(nvects)
	b_data = lonarr(nvects)
	b_mlat = fltarr(nvects)
        b_mlon = fltarr(nvects)
    	b_malt = fltarr(nvects)
	b_rot =  fltarr(nvects)

;patch
;       print, ymin, bin_lat, bin_lon, nbin_lon   

	for i = 0,icnt-1 do begin
		lat_bin = abs(fix((mlats(i)-ymin)/bin_lat))
		lon_bin = fix((mlons(i)+180.)/bin_lon)
		indx = fix(lon_bin + lat_bin*nbin_lon)
		if qflgs(i) ge qmin and qflgs(i) le qmax then begin
;               printf,4, indx,i,b_vest(indx),vest(i)
			b_vest(indx) = b_vest(indx) + vest(i)
			b_vnrt(indx) = b_vnrt(indx) + vnrt(i)
			b_cont(indx) = b_cont(indx) + 1
 			b_mlat(indx) = mlats(i)
			b_mlon(indx) = mglons(i)
			b_malt(indx) = malts(i)
		endif

		if qflgs(i) gt qmax then b_data(indx)=1

	endfor

	angs = fltarr(nvects)
        
        w = where(b_cont ne 0,wc)
        if( wc gt 0) then begin  
             b_vest(w) = b_vest(w)/b_cont(w)
             b_vnrt(w) = b_vnrt(w)/b_cont(w)
        endif
        
      endelse
; Compute angles
        w = where(b_vnrt ne 0,wc)
        angs(w) = atan(b_vest(w),b_vnrt(w))

; Compute vector rotation angles for desired coordinate system
;       print, 'Computing angle adjustment'
        for i=0, nvects-1 do begin
         if(b_cont(i) ne 0) then begin
           b_rot(i)=angadj(mltin,mytimes.year,b_mlat(i),b_mlon(i),b_malt(i))
           b_rot(i)=b_rot(i)*(3.141592/180.)
         endif
        endfor
        w=where(b_rot ne 0, wc)
	if(wc gt 0) then angs(w)=angs(w)-b_rot(w)

; Compute magnitudes
	mags = sqrt(b_vest^2 + b_vnrt^2)

 if keyword_set(nop) then begin

    map_set,p0lat,p0lon,rot,limit=[ymin,xmin,ylim,xlim],/GRID,$
            xmargin=xmargin,ymargin=ymargin,glinethick=0.5,/cyl,$
            color=bkgrd,$
            /noborder,latdel=latdel,londel=londel,_extra=extras

if(mltin eq 2) then begin
    axis,xmin,ymin,xax=0,xrange=[xmin,xlim],xsty=1
    axis,xmin,ymin,yax=0,yrange=[ymin,ylim],ysty=1
endif else begin
    axis,xmin,ymin,xax=0,xrange=[0,24],xsty=1
    axis,xmin,ymin,yax=0,yrange=[ymin,ylim],ysty=1
endelse

 endif else begin

    map_set,p0lat,p0lon,rot,limit=[ymin,xmin,ylim,xlim],/GRID,$
            xmargin=xmargin,ymargin=ymargin,glinethick=0.5,/stereo,$
            color=bkgrd,$
           /noborder,latdel=latdel,londel=londel,_extra=extras

;     MLT scale
        for j=0,3 do begin
            tstr = strtrim(string(6*j),2)
            if( spole eq 0) then begin
               lon=-180+j*90 
               xyouts,lon,ymin-2,tstr,alignment=0.5
            endif else begin 
               lon=0-j*90 
               xyouts,lon,ylim+2,tstr,alignment=0.5
            endelse
        endfor
;     Invariant Latitude scale
        for j=0,3 do begin
                lat= fix(ymin) + 10*j
                tstr = strtrim(string(lat),2)
                lon=zlon
                xyouts,lon,lat,tstr,alignment=0.5
        endfor
;     UT  scale
       for j=0,7 do begin
            utstr=strtrim(string(3*j),2)
            lon=zlon+j*45.0
            if( spole eq 0) then lat=78. else lat=-78.
            xyouts,lon,lat,utstr,alignment=0.5
       endfor
;    Make tick marks on both UT and MLT scales
       for j=0,23 do begin
        lon=zlon+j*15.
        olon=j*15
        if( spole eq 0) then begin
         plots,[lon,lon],[79.5,80.5]
         plots,[olon,olon],[ymin,(ymin+0.5)]
        endif else begin
         plots,[lon,lon],[-79.5,-80.5]
         plots,[olon,olon],[ylim,(ylim-0.5)]
        endelse
       endfor
; Axis
         if( spole eq 0) then begin
           utlat=replicate(80.0,360)
         endif else begin
           utlat=replicate(-80.0,360)
         endelse
          utlon=zlon+findgen(360.0)
          oplot,utlon,utlat,line=0
; Axis      
        plots,[zlon,zlon],[ymin,ylim],thick=1.7
; Labels
         xyouts,0.48,0.07,'MLT',/normal
         xyouts,0.50,0.53,'UT',/normal

 endelse

; vectors determined

	S = findgen(16)*(!PI*2/16.)
	usersym,cos(S),sin(S),/FILL

	Re    = 6362.

	clon = (xlim+xmin)/2.
	clat = (ylim+ymin)/2.

	side_scale = 120./scale

	cside = (90. - clat)*3.141592/180.
	bside = scale/Re*side_scale
	ang  = 90.*3.141592/180.
	
	arg = cos(bside)*cos(cside) + sin(bside)*sin(cside)*cos(ang)

	if( arg lt -1)then arg=-1.
	if(arg gt 1)then arg=1.

	aside = acos(arg)
	tlat = 90. - aside*180./3.141592

	arg = (cos(bside)-cos(aside)*cos(cside))/(sin(aside)*sin(cside))

	if( arg lt -1)then arg=-1.
	if(arg gt 1)then arg=1.

	bang = acos(arg)*180./3.141592

	tlon = clon + bang

	nx = convert_coord(clon,clat,/data,/to_normal)
	ndx = convert_coord(tlon,tlat,/data,/to_normal)
	delta = sqrt((ndx(0)-nx(0))^2+(ndx(1)-nx(1))^2)

	side_scale = side_scale*.08/delta

	cside = (90. - lats)*3.141592/180.
	bside = mags/Re*side_scale
	
	arg = cos(bside)*cos(cside) + sin(bside)*sin(cside)*cos(angs)

        arg = arg < 1. > (-1.) 

	aside = acos(arg)
	tlat = 90. - aside*180./3.141592

	arg = (cos(bside)-cos(aside)*cos(cside))/(sin(aside)*sin(cside))

        arg = arg < 1. > (-1.) 

	bang = acos(arg)*180./3.141592

	q = where (angs lt 0,icnt)
		if icnt ne 0 then bang(q) = -1.*bang(q)
	tlon = lons + bang

	for i = 0,nvects-1 do begin
		if lons(i) gt xmin and lons(i) lt xlim and $
			lats(i) gt ymin and lats(i) lt ylim and $
				b_cont(i) ne 0 then begin

;			ind    =  max(where(LVL le mags(i))) + 1
	
			plots,lons(i),lats(i),psym=8,symsize=symsiz,color=symcol
			plots,[lons(i),tlon(i)],[lats(i),tlat(i)]$
				,thick=lthik

		endif
		if lons(i) gt xmin and lons(i) lt xlim and $
			lats(i) gt ymin and lats(i) lt ylim and $
				b_data(i) ne 0 then begin

			plots,lons(i),lats(i),psym=3

		endif
	endfor

	plots,.84,.92,psym=8,symsize=symsiz,/normal,color=symcol
	plots,[.84,.92],[.92,.92],thick=lthik,/normal

	scstring = strtrim(string(scale),2)+'m/s'

	xyouts,.84,.88,scstring,/normal
	if(thetitle eq ' ') then begin
	 if mltin eq 0 then begin
	  thetitle='Velocity vs Eccentric MLT/UT and Magnetic Latitude'
         endif
         if mltin eq 1 then begin
          thetitle='Velocity vs AACGC MLT/UT and Magnetic Latitude'            
         endif
         if mltin eq 2 then begin
          thetitle='Geographic Velocity '
         endif
        endif

       xyouts,0.15,0.95,thetitle,/normal
       if(spole eq 1) then station=strmid(station,0,14)
       xyouts,0.05,0.85,station,/normal

       date = strcompress(string(fix(mytimes.mon))+'/'$'
              +string(fix(mytimes.day))+$
              '/'+string(fix(mytimes.year)),/remove_all)
       xyouts,0.05, 0.9,date,/normal

       time_string=systime()
       disclaimer="Key Parameter and Survey data (labels K0,K1,K2) are preliminary data."
       disclaimer1="Generated by CDAWeb on: "+time_string
   
       xyouts,0.01,0.035,disclaimer,charsize=dtxt,/normal
       xyouts,0.01,0.01,disclaimer1,charsize=dtxt,/normal

end
