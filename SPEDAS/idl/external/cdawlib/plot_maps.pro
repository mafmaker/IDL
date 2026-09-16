;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/plot_maps.pro,v 1.27 2006/02/22 22:14:59 johnson Exp johnson $
;$Locker: johnson $
;$Revision: 7092 $
;+------------------------------------------------------------------------
; NAME: PLOT_MAPS
; PURPOSE: To plot the geographic maps in various map projections.
;
; CALLING SEQUENCE:
;       out = plot_maps(a,vlat=vlat,iproj=iproj,limit=limit,$
;          latdel=latdel,londel=londel,Ttitle=thetitle,$
;          pmode=pmode,rng_val=rng_val,num_int=num_int,$
;          ptype=ptype,lthik=lthik,symsiz=symsiz,symcol=symcol,$
;          charsize=charsize,xmargin=xmargin,ymargin=ymargin,$
;          xoffset=xoffset,yoffset=yoffset,lnlabel=lnlabel,$
;          _extra=extras)
; INPUTS:
;       a = structure returned by the read_mycdf procedure.
; projections:
; aitoff (15), az. equid. (6), cyl (8), gnom (5), lamb eq area (4)
; merc (9), molle (10), ortho (2), sinsusoidal (14), stero. (1)
  
FUNCTION plot_maps,a,station=station,vlat=vlat,iproj=iproj,lim=lim,$
           latdel=latdel,londel=londel,Ttitle=thetitle,$
           pmode=pmode,rng_val=rng_val,num_int=num_int,$
           ptype=ptype,lthik=lthik,symsiz=symsiz,symcol=symcol,$
           charsize=charsize,xmargin=xmargin,ymargin=ymargin,$
           xoffset=xoffset,yoffset=yoffset,lnlabel=lnlabel,nocont=nocont,$
           SSCWEB=SSCWEB,doymark=doymark,hrmark=hrmark,hrtick=hrtick,$
	   mntick=mntick,mnmark=mnmark,lnthick=lnthick,$
           autolabel=autolabel,datelabel=datelabel,_extra=extras

status=0
if(n_elements(station) eq 0) then station=create_struct('NUM',0)
; Begin Here w/ plotmaster mods.
if(station.num ne 0) then begin
   stations=station.station
   lats=station.lat
   lons=station.lon
endif
 
if(n_elements(thetitle) eq 0) then thetitle=a.(0).title
if(n_elements(lnlabel) eq 0) then lnlabel=""
if(n_elements(xoffset) eq 0) then xoffset=0.05 ; 0.01
if(n_elements(yoffset) eq 0) then yoffset=0.15 ; 0.15
if(n_elements(vlat) eq 0) then vlat = [0.0,0.0,0.0]
if(n_elements(iproj) eq 0) then iproj=8
;if(n_elements(ymargin) eq 0) then ymargin=[8.0,2.0]
if(n_elements(ymargin) eq 0) then ymargin=[15.0,2.0]
if(n_elements(ptype) eq 0) then ptype=0
if(n_elements(pmode) eq 0) then pmode=0
if(n_elements(num_int) eq 0) then num_int=4
if(n_elements(symsiz) eq 0) then symsiz = 1.6 else symsiz=symsiz
if(n_elements(symcol) eq 0) then symcol = 83 
if(n_elements(latdel) eq 0) then latdel = 30.0
if(n_elements(londel) eq 0) then londel = 30.0
;if(n_elements(trace) eq 0) then trace=1
;if(n_elements(SSCWEB) eq 0) then SSCWEB = 0L else SSCWEB = 1L 
if(n_elements(SSCWEB) eq 0) then SSCWEB = 0L 

symsiz2=symsiz*2.0
; IDL limits set for CDAWEB; for SSCWEB limits null by default
if(SSCWEB) then begin
   if(n_elements(lim) ne 0) then begin
      ; IF LIM is defined  (let idl set valid limits for each projection
      ;   if((lim(0) eq lim(1)) and (lim(1) eq lim(2)) and $
      ;(lim(2) eq lim(3))) then begin
      ;     lim(0)=-90.0
      ;     lim(1)=-180.0
      ;     lim(2)=90.0
      ;     lim(3)=180.0
      ;   endif
      limit = [lim(0), lim(1), lim(2), lim(3)]
      londel = fix((lim(3)-lim(1))/6)
      latdel = fix((lim(2)-lim(0))/6)
   endif
endif else begin
   limit = [-90., -180., 90., 180.]
endelse

if(iproj eq 1) then proj_nm="Stereographic"
if(iproj eq 2) then proj_nm="Orthographic"
if(iproj eq 6) then proj_nm="Azimuthal"
if(iproj eq 10) then proj_nm="Molleweide"
if(iproj eq 9) then proj_nm="Mercator"
if(iproj eq 8) then proj_nm="Cylindrical"
if((iproj eq 1) or (iproj eq 2) or (iproj eq 6)) then xmargin=[33.0,33.0]
a=orb_handle(a)  ; Convert handles to data

; Mods. required when variable name determined
;if(n_elements(a.geo_alt.dat) ne 0) then alt=a.geo_alt.dat
;if(n_elements(a.geo_stations.dat) ne 0) then cstation=a.geo_stations.dat
; Hard code color 
; symcol=83  ; Commented out for overplots
atags=tag_names(a)
b = tagindex('GEO_LAT',atags)
if (b(0) ne -1) then begin
   vfil=a.geo_lat.fillval
   epoch=a.epoch.dat
   lat=a.geo_lat.dat
   lon=a.geo_lon.dat
   lnlabel=strtrim(a.geo_lat.source_name,2)
   ; Remove fill-vals form array
   ;  q=where(lat ne vfil,count)
   ;  epoch=epoch(q)
   ;  lat=lat(q)
   ;  lon=lon(q)
   count=n_elements(lon)
   alt=fltarr(count)
   cstation=strarr(count)
   ;  label=lnlabel+"Radial_GEO "
   label=lnlabel+" Radial Trace in Geographic Coordinates"
   if count le 0 then message, 'No data selected'
   ; plot cdf generated traces
   xyzmap,epoch,lat,lon,alt,cstation,vlat=vlat,iproj=iproj,limit=limit,$
      latdel=latdel,londel=londel,Ttitle=thetitle,$
      pmode=pmode,rng_val=rng_val,num_int=num_int,$
      ptype=ptype,lthik=lthik,symsiz=symsiz2,symcol=symcol,$
      charsize=charsize,xmargin=xmargin,ymargin=ymargin,$
      xoffset=xoffset,yoffset=yoffset,lnlabel=label,nocont=nocont,$
      doymark=doymark,hrmark=hrmark,hrtick=hrtick, $
      mntick=mntick,mnmark=mnmark,lnthick=lnthick,$
      autolabel=autolabel,datelabel=datelabel,_extra=extras
endif

b = tagindex('NorthBtrace_GEO_LAT',atags)
if (b(0) ne -1) then begin
   vfil=a.NorthBtrace_GEO_LAT.fillval
   epoch=a.epoch.dat
   lat=a.NorthBtrace_GEO_LAT.dat
   lon=a.NorthBtrace_GEO_LON.dat
   lnlabel=strtrim(a.NorthBtrace_GEO_LAT.source_name,2)
   ; Remove fill-vals form array
   ;  q=where(lat ne vfil,count)
   ;  epoch=epoch(q)
   ;  lat=lat(q)
   ;  lon=lon(q)
   count=(n_elements(lon))
   alt=fltarr(count)
   cstation=strarr(count)
   ;  label=lnlabel+" NorthBtrace_GEO "
   label=lnlabel+" North B Trace in Geographic Coordinates"
   if count le 0 then message, 'No data selected'
   ; plot cdf generated traces
   xyzmap,epoch,lat,lon,alt,cstation,vlat=vlat,iproj=iproj,limit=limit,$
      latdel=latdel,londel=londel,Ttitle=thetitle,$
      pmode=pmode,rng_val=rng_val,num_int=num_int,$
      ptype=ptype,lthik=lthik,symsiz=symsiz2,symcol=symcol,$
      charsize=charsize,xmargin=xmargin,ymargin=ymargin,$
      xoffset=xoffset,yoffset=yoffset,lnlabel=label,nocont=nocont,$
      doymark=doymark,hrmark=hrmark,hrtick=hrtick, $
      mntick=mntick,mnmark=mnmark,lnthick=lnthick,$
      autolabel=autolabel,datelabel=datelabel,_extra=extras
endif                  

b = tagindex('SouthBtrace_GEO_LAT',atags)
if (b(0) ne -1) then begin
   vfil=a.SouthBtrace_GEO_LAT.fillval
   epoch=a.epoch.dat
   lat=a.SouthBtrace_GEO_LAT.dat
   lon=a.SouthBtrace_GEO_LON.dat
   lnlabel=strtrim(a.SouthBtrace_GEO_LAT.source_name,2)
   ; Remove fill-vals form array
   ;  q=where(lat ne vfil,count)
   ;  epoch=epoch(q)
   ;  lat=lat(q)
   ;  lon=lon(q)
   count=n_elements(lon)
   alt=fltarr(count)
   cstation=strarr(count)
   ;  label=lnlabel+" SouthBtrace_GEO "
   label=lnlabel+" South B Trace in Geographic Coordinates"
   if count le 0 then message, 'No data selected'
   ; plot cdf generated traces
   xyzmap,epoch,lat,lon,alt,cstation,vlat=vlat,iproj=iproj,limit=limit,$
      latdel=latdel,londel=londel,Ttitle=thetitle,$
      pmode=pmode,rng_val=rng_val,num_int=num_int,$
      ptype=ptype,lthik=lthik,symsiz=symsiz2,symcol=symcol,$
      charsize=charsize,xmargin=xmargin,ymargin=ymargin,$
      xoffset=xoffset,yoffset=yoffset,lnlabel=label,nocont=nocont,$
      doymark=doymark,hrmark=hrmark,hrtick=hrtick, $
      mntick=mntick,mnmark=mnmark,lnthick=lnthick,$
      autolabel=autolabel,datelabel=datelabel,_extra=extras
endif                   

b = tagindex('GM_LAT',atags)
if (b(0) ne -1) then begin
   vfil=a.GM_LAT.fillval
   epoch=a.epoch.dat
   lat=a.GM_LAT.dat
   lon=a.GM_LON.dat
   lnlabel=strtrim(a.GM_LAT.source_name,2)
   ; Remove fill-vals form array
   ;  q=where(lat ne vfil,count)
   ;  epoch=epoch(q)
   ;  lat=lat(q)
   ;  lon=lon(q)
   count=n_elements(lon)
   alt=fltarr(count)
   cstation=strarr(count)
   ;  label=lnlabel+" Radial_GM "
   label=lnlabel+" Radial Trace in Geomagnetic Coordinates"
   if count le 0 then message, 'No data selected'
   ; plot cdf generated traces
   xyzmap,epoch,lat,lon,alt,cstation,vlat=vlat,iproj=iproj,limit=limit,$
      latdel=latdel,londel=londel,Ttitle=thetitle,$
      pmode=pmode,rng_val=rng_val,num_int=num_int,$
      ptype=ptype,lthik=lthik,symsiz=symsiz2,symcol=symcol,$
      charsize=charsize,xmargin=xmargin,ymargin=ymargin,$
      xoffset=xoffset,yoffset=yoffset,lnlabel=label, /nocont, $
      doymark=doymark,hrmark=hrmark,hrtick=hrtick, $
      mntick=mntick,mnmark=mnmark,lnthick=lnthick,$
      autolabel=autolabel,datelabel=datelabel,_extra=extras
endif

b = tagindex('NorthBtrace_GM_LAT',atags)
if (b(0) ne -1) then begin
   vfil=a.NorthBtrace_GM_LAT.fillval
   epoch=a.epoch.dat
   lat=a.NorthBtrace_GM_LAT.dat
   lon=a.NorthBtrace_GM_LON.dat
   lnlabel=strtrim(a.NorthBtrace_GM_LAT.source_name,2)
   ; Remove fill-vals form array
   ;  q=where(lat ne vfil,count)
   ;  epoch=epoch(q)
   ;  lat=lat(q)
   ;  lon=lon(q)
   count=n_elements(lon)
   alt=fltarr(count)
   cstation=strarr(count)
   ;  label=lnlabel+" NorthBtrace_GM "
   label=lnlabel+" North B Trace in Geomagnetic Coordinates"
   if count le 0 then message, 'No data selected'
   ; plot cdf generated traces
   xyzmap,epoch,lat,lon,alt,cstation,vlat=vlat,iproj=iproj,limit=limit,$
      latdel=latdel,londel=londel,Ttitle=thetitle,$
      pmode=pmode,rng_val=rng_val,num_int=num_int,$
      ptype=ptype,lthik=lthik,symsiz=symsiz2,symcol=symcol,$
      charsize=charsize,xmargin=xmargin,ymargin=ymargin,$
      xoffset=xoffset,yoffset=yoffset,lnlabel=label, /nocont, $
      doymark=doymark,hrmark=hrmark,hrtick=hrtick, $
      mntick=mntick,mnmark=mnmark,lnthick=lnthick,$
      autolabel=autolabel,datelabel=datelabel,_extra=extras
endif                   

b = tagindex('SouthBtrace_GM_LAT',atags)
if (b(0) ne -1) then begin
   vfil=a.SouthBtrace_GM_LAT.fillval
   epoch=a.epoch.dat
   lat=a.SouthBtrace_GM_LAT.dat
   lon=a.SouthBtrace_GM_LON.dat
   lnlabel=strtrim(a.SouthBtrace_GM_LAT.source_name,2)
   ; Remove fill-vals form array
   ;  q=where(lat ne vfil,count)
   ;  epoch=epoch(q)
   ;  lat=lat(q)
   ;  lon=lon(q)
   count=n_elements(lon)
   alt=fltarr(count)
   cstation=strarr(count)
   ;  label=lnlabel+" SouthBtrace_GM "
   label=lnlabel+" South B Trace in Geomagnetic Coordinates"
   if count le 0 then message, 'No data selected'
   ; plot cdf generated traces
   xyzmap,epoch,lat,lon,alt,cstation,vlat=vlat,iproj=iproj,limit=limit,$
      latdel=latdel,londel=londel,Ttitle=thetitle,$
      pmode=pmode,rng_val=rng_val,num_int=num_int,$
      ptype=ptype,lthik=lthik,symsiz=symsiz2,symcol=symcol,$
      charsize=charsize,xmargin=xmargin,ymargin=ymargin,$
      xoffset=xoffset,yoffset=yoffset,lnlabel=label, /nocont, $
      doymark=doymark,hrmark=hrmark,hrtick=hrtick, $
      mntick=mntick,mnmark=mnmark,lnthick=lnthick,$
      autolabel=autolabel,datelabel=datelabel,_extra=extras
endif                   

b = tagindex('SM_LAT',atags)
if (b(0) ne -1) then begin
   vfil=a.sm_lat.fillval
   epoch=a.epoch.dat
   lat=a.sm_lat.dat
   lon=a.sm_lon.dat
   lnlabel=strtrim(a.sm_lat.source_name,2)
   ; Remove fill-vals form array
   ;  q=where(lat ne vfil,count)
   ;  epoch=epoch(q)
   ;  lat=lat(q)
   ;  lon=lon(q)
   count=n_elements(lon)
   alt=fltarr(count)
   cstation=strarr(count)
   ;  label=lnlabel+" Radial_SM "
   label=lnlabel+" Radial Trace in Solar Magnetic Coordinates"
   if count le 0 then message, 'No data selected'
   ; plot cdf generated traces
   xyzmap,epoch,lat,lon,alt,cstation,vlat=vlat,iproj=iproj,limit=limit,$
      latdel=latdel,londel=londel,Ttitle=thetitle,$
      pmode=pmode,rng_val=rng_val,num_int=num_int,$
      ptype=ptype,lthik=lthik,symsiz=symsiz2,symcol=symcol,$
      charsize=charsize,xmargin=xmargin,ymargin=ymargin,$
      xoffset=xoffset,yoffset=yoffset,lnlabel=label, /nocont, $
      doymark=doymark,hrmark=hrmark,hrtick=hrtick, $
      mntick=mntick,mnmark=mnmark,lnthick=lnthick,$
      autolabel=autolabel,datelabel=datelabel,_extra=extras
endif               

xyouts, 0.8,0.975,proj_nm,/norm,color=1,charsize=charsize

; apply limits to station data if they exist
if(station.num ne 0) then begin
   statcnt=station.num-1
   if(n_elements(limit) ne 0) then begin
      wco=where((lats ge limit(0)) and (lats le limit(2)) and (lons ge limit(1)) and (lons le limit(3)),wcn)
      if(wcn gt 0) then begin
         stations=stations(wco)
         lats=lats(wco)
         lons=lons(wco)
         statcnt=wcn-1
         ; RCJ 01/09/02 Added the 'else statcnt=-1' below. Note that if wco=-1
         ; then lats, lons and stations would not change and would be plotted
         ; when they shouldn't be.
      endif else statcnt=-1
   endif
   ;RCJ 01/09/02 Moved the call to xyouts a few lines down. Loop is not needed.
   ;for i=0,statcnt do begin
      ;;  xyouts,lons(i),lats(i),stations(i),color=symcol
      ;xyouts,lons(i),lats(i),stations(i),charsize=charsize,color=1
   ;endfor
   ;if(n_elements(lats) ne 0) then $
   ;RCJ 01/09/02 Test the value of statcnt too
   if(n_elements(lats) ne 0) and (statcnt ne -1) then begin
      ; RCJ 01/06/02 We need []'s here because oplot plots arrays and if
      ; lons and lats are made of only one value (not an array) we get an error.
      oplot,[lons],[lats],psym=6,symsize=symsiz,color=1
      xyouts,lons,lats,stations,charsize=charsize,color=1
   endif   
endif

if(!D.name eq 'Z') then begin
   ; set background
   top = 255
   bottom = 0
   tvlct, r_curr, g_curr, b_curr, /get
   r_curr(0) = bottom & g_curr(0) = bottom & b_curr(0) = bottom
   r_curr(!d.n_colors-1) = top & g_curr(!d.n_colors-1) = top
   b_curr(!d.n_colors-1) = top
   r_curr(!p.color) = top & g_curr(!p.color) = top
   b_curr(!p.color) = top
   tvlct, r_curr, g_curr, b_curr
endif

return, status
end
