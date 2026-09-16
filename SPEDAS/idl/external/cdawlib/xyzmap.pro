;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/xyzmap.pro,v 1.47 2007/12/20 16:42:49 johnson Exp johnson $
;$Locker: johnson $
;$Revision: 7092 $
;+
; NAME: XYZMAP.PRO  
;
; PURPOSE:  Display of stations and satellite traces on a world projection 
;
; CALLING SEQUENCE:
;
;   xyzmap,lat,lon,alt,station,trace=trace,vlat=vlat,iproj=iproj,limit=limit,$
;          latdel=latdel,londel=londel,Ttitle=thetitle,$
;          pmode=pmode,rng_val=rng_val,num_int=num_int,$
;          ptype=ptype,lthik=lthik,symsiz=symsiz,symcol=symcol,$
;          charsize=charsize,xmargin=xmargin,ymargin=ymargin,$
;          xoffset=xoffset,yoffset=yoffset,lnlabel=lnlabel,_extra=extras
;
;
; VARIABLES:
;
; Input:
;
; lat(*)     - an N element array of geographic latitudes
; lon(*)     - an N element array of geographic longitudes
; alt(*)     _ an N element array of geographic altitudes
; station(*) - an N element array of station names
;  
; Keyword Parameters: 
;
; trace=trace		- if set, then plot lat,lon connected lines.
;			  if not set, just plot the map, no addition lines.
; vlat=vlat		- array of map_set argument; 
;			    (0) latitude center of map
;  			    (1) longitude center of map
;			    (2) rotation of map 
; iproj=iproj		- map_set projection
; limit=limit		- map_set limits 
; latdel=latdel		- latitude interval
; londel=londel		- longitude interval
; Ttitle=thetitle	- Title for plot
; pmode=pmode		- image number or window frame
; rng_val=rng_val       - time range
; num_int=num_int       - number of intervals over time range
; ptype=ptype		- plot type:  0 - trace; 1 - station
; lthik=lthik           - line thickness
; symsiz=symsiz         - station symbol size
; symcol=symcol         - station symbol color
; charsize=charsize     - character size
; xmargin=xmargin       - left - right margins
; ymargin=ymargin 	- top - bottom margins
; xoffset=xoffset	- caption offset from left
; yoffset=yoffset	- caption offset from bottom 
; lnlabel=lnlabel	- line labels  
; nocont=nocont         - no continent outline
;
; REQUIRED PROCEDURES:
;
;   none
;
;-------------------------------------------------------------------
; History
;
;         1.0  R. Baldwin  HSTX     12/20/95 
;		Initial version
;	  1.1  T. Kovalick HSTX
;		Modified to read allow station locations (the lat,
;		lon and station varaibles to be read in from a
;		ascii file in addition to coming from a cdf.
;		Changed some of the labeling slightly to accommodate 
;		this.
;
;         1.2  R. Baldwin HSTX
;               Added orbit labeling code
;
;-------------------------------------------------------------------

pro xyzmap,epoch,lat,lon,alt,station,vlat=vlat,iproj=iproj,$
	   limit=limit, latdel=latdel,londel=londel,Ttitle=thetitle,$
           pmode=pmode,rng_val=rng_val,num_int=num_int,$
           ptype=ptype,lthik=lthik,symsiz=symsiz,symcol=symcol,$
           charsize=charsize,xmargin=xmargin,ymargin=ymargin,$
           xoffset=xoffset,yoffset=yoffset,lnlabel=lnlabel,nocont=nocont,$
           doymark=doymark,hrtick=hrtick,hrmark=hrmark, $
	   mntick=mntick,mnmark=mnmark,lnthick=lnthick,$
           autolabel=autolabel,datelabel=datelabel,_extra=extras

alat=fltarr(num_int+1)
alon=fltarr(num_int+1) 

; set defaults 

if(n_elements(doymark) eq 0) then doymark=1
if(n_elements(hrmark) eq 0) then hrmark=24
if(n_elements(hrtick) eq 0) then hrtick=12
if(n_elements(mnmark) eq 0) then mnmark=0
if(n_elements(mntick) eq 0) then mntick=0
if(n_elements(lnthick) eq 0) then lnthick=1
if(n_elements(autolabel) eq 0) then autolabel=1L
if(n_elements(datelabel) eq 0) then datelabel=1L

if(n_elements(nocont) eq 0) then nocont=0L
if(n_elements(ptype) eq 0) then message, 'Trace or station plot undefined'
n=n_elements(lat)
if(n_elements(lon) ne n or n_elements(alt) ne n) then $
   message, ' Arrays of unequal length ' 
if((iproj eq 1) or (iproj eq 2)) then begin
  ysize=640
  xsize=ysize
  ysize=780
  xsize=620
endif

 if(!d.name eq 'X') then begin
   if(n_elements(color) eq 0) then color=254
   bkgrd=254
 endif
 if(!d.name eq 'Z') then begin
   if(n_elements(color) eq 0) then color=1
   bkgrd=1
 endif
 if(!d.name eq 'PS') then begin
   if(n_elements(color) eq 0) then color=1
   bkgrd=1
 endif

offset_int=0.02 ; TJK changed this from .05 to .03 ; RCJ changed .03 to .02
; need to include interpolation if num_int not sufficient
; pltsym=abs(pmode-1)  
 if(pmode eq 0) then pltsym=abs(pmode-1)  else pltsym=pmode-1 

tmint=double((rng_val(1)-rng_val(0))/num_int)
nlat=((n_elements(lat)-1)/num_int)
time=double(0.0)
if (strlen(lnlabel) eq 0) then lnlabel = 'line'
imode=strtrim(string(pmode),2)

 if (rng_val(0) gt 0.0 and rng_val(0) gt 0.0) then begin
;if (epoch(0) gt 0.0 and epoch(nt) gt 0.0) then begin
  cdf_epoch, epoch(0), yr0,mo0,dy0,hr0,mn0,sc0,ml0,/break
  cdf_epoch, epoch(n-1),yr1,mo1,dy1,hr1,mn1,sc1,ml1,/break
  ical,yr0,doy0,mo0,dy0,/idoy
  ical,yr1,doy1,mo1,dy1,/idoy

  sdoy0=strtrim(string(doy0),2)
  sdoy1=strtrim(string(doy1),2)
  smo0=strtrim(string(mo0),2)
  smo1=strtrim(string(mo1),2)
  sdy0=strtrim(string(dy0),2)
  sdy1=strtrim(string(dy1),2)
; yrs0=fix(yr0-1900)
; yrs1=fix(yr1-1900)
  syr0=strtrim(string(yr0),2)
  syr1=strtrim(string(yr1),2)
; syrs0=strtrim(string(yrs0),2)
; syrs1=strtrim(string(yrs1),2)
  shr0=strtrim(string(hr0),2)
  shr1=strtrim(string(hr1),2)
  smn0=strtrim(string(mn0),2)
  smn1=strtrim(string(mn1),2)
  blk=' ' 
  bl2='  ' 

  ;thetitle=thetitle+smo+'/'+sdy0+'/'+syr
  idat0=smo0+"/"+sdy0+"/"+syr0+" ("+sdoy0+") "
  idat1=smo1+"/"+sdy1+"/"+syr1+" ("+sdoy1+") "
  idate=idat0+bl2+shr0+":"+smn0+bl2+idat1+bl2+shr1+":"+smn1
  label=strtrim(lnlabel, 2)+':  Time Range '+idate

endif else begin ; no time associated w/ the data, i.e. for station
		 ; locations coming from a text file.
  label=strtrim(lnlabel, 2)+': '

endelse

; Condition block for map_set or map_set,/noerase  
   lat_max=limit(2)-limit(0)
   lon_max=limit(3)-limit(1)
   lst=min(lat_max,lon_max)

  if(pmode eq 0) then begin
  if(nocont) then begin
   map_set,vlat(0),vlat(1),vlat(2),PROJ=iproj,limit=limit,$
           /grid,/label,latdel=latdel,londel=londel,$
           xmargin=xmargin,ymargin=ymargin,title=thetitle,$
           color=bkgrd,_extra=extras
  endif else begin
   if(lst le 50) then begin ; USE HIRES CONT. OUTLINES
    print, "High Res. Outlines Used"
    map_set,vlat(0),vlat(1),vlat(2),PROJ=iproj,limit=limit,$
           /grid,/label,/cont,/hires,latdel=latdel,londel=londel,$
           xmargin=xmargin,ymargin=ymargin,title=thetitle,$
           color=bkgrd,_extra=extras
   endif else begin
    map_set,vlat(0),vlat(1),vlat(2),PROJ=iproj,limit=limit,$
           /grid,/label,/cont,latdel=latdel,londel=londel,$
           xmargin=xmargin,ymargin=ymargin,title=thetitle,$
           color=bkgrd,_extra=extras
   endelse
  endelse
; THIS should work but it doent;  if(not nocont) then map_continents
  endif else begin
   if(nocont) then begin 
     map_set,vlat(0),vlat(1),vlat(2),PROJ=iproj,limit=limit,$
           /grid,/label,latdel=latdel,londel=londel,$
           xmargin=xmargin,ymargin=ymargin,title=thetitle,$
           color=bkgrd,/noerase,_extra=extras
   endif else begin
    if(lst le 50) then begin ; USE HIRES CONT. OUTLINES
     print, "High Res. Outlines Used"
     map_set,vlat(0),vlat(1),vlat(2),PROJ=iproj,limit=limit,$
           /grid,/label,/cont,/hires,latdel=latdel,londel=londel,$
           xmargin=xmargin,ymargin=ymargin,title=thetitle,$
           color=bkgrd,/noerase,_extra=extras
    endif else begin
     map_set,vlat(0),vlat(1),vlat(2),PROJ=iproj,limit=limit,$
           /grid,/label,/cont,latdel=latdel,londel=londel,$
           xmargin=xmargin,ymargin=ymargin,title=thetitle,$
           /noerase,color=bkgrd,_extra=extras
    endelse
   endelse
;  NOTE above  if(not nocont) then map_continents
  endelse

  olon=fltarr(1) & olat=fltarr(1)
; Condition block for traces or station plots
;if(ptype eq 0 and (keyword_set(trace))) then begin
; Use of orbit date works; needs refinement for all intervals
  if(ptype eq 0) then begin
 
   dif=(epoch(n-1)-epoch(0))/1000
   ddif=dif/86400.0

   if(autolabel) then begin
    if(ddif gt 1.0) then hrtick=0 & hrmark=0
    if(ddif le 1.0) then begin
     doymark=1
     hrtick=6
     hrmark=6
     mntick=0
     mnmark=0
     if(ddif le 0.5) then begin
       doymark = 1
       hrtick = 3
       hrmark = 6
       mntick=0
       mnmark=0
       if(ddif le 0.2) then begin
        doymark = 1
        hrtick = 1
        hrmark = 2
        mntick = 30
        mnmark = 30
       endif
     endif
    endif else begin
;if(ddif lt 2.0) then doymark=1 else doymark=fix(ddif/2)
     if(ddif le 4.0) then doymark=1
     if(ddif gt 4.0) then doymark=2
     if(ddif gt 7.0) then doymark=7
     if(ddif gt 30.0) then doymark=30
     if(ddif gt 180.0) then doymark=180
     if(ddif gt 365.0) then doymark=365
   endelse
  endif
; Remove nasty values from arrays which will hang IDL
    wc=where(abs(lon) gt 360.0,wc1)
    if(wc1 gt 0) then lon(wc)=370.0
    wc=where(abs(lat) gt 90.0,wc2)
    if(wc2 gt 0) then lat(wc)=370.0
; Plot trace
    ; RCJ 01/06/02 Added []'s here because oplot plots arrays and if
    ; lon and lat are made of only one value (not an array) we get an error
    oplot,[lon],[lat],color=symcol,symsize=symsiz,max_value=360.,min_value=-360.,$
          thick=lnthick 
;   msymsiz=symsiz*25
    orbit_date,epoch,lon,lat,doymark,hrmark,hrtick,mntick,mnmark,$
      color=symcol,noclip=noclip,charsize=charsize,symsiz=symsiz,$
      date=datelabel,/map

    if(pltsym eq 0) then sym='!20C!X'
    if(pltsym eq 1) then sym='+'
    if(pltsym eq 2) then sym='*'
    if(pltsym eq 3) then sym='.'
    if(pltsym eq 4) then sym='!9V!x'
    if(pltsym eq 5) then sym='!7D!x'
    if(pltsym eq 6) then sym='!9B!x'
    if(pltsym eq 7) then sym='x'
    if(pltsym eq 8) then sym='!20I!X'
    if(pltsym eq 9) then sym='+'
    if(pltsym eq 10) then sym='*'
    if(pltsym eq 11) then sym='.'
    if(pltsym eq 12) then sym='!9V!X'

    ;oplot,[1]*lon(0),[1]*lat(0),color=symcol,symsize=symsiz,psym=pltsym 
    oplot,[1]*lon(0),[1]*lat(0),color=symcol,symsize=symsiz,psym=sym 
  endif

;if(ptype eq 0) then begin
;  olon(0)=lon(0)
;  olat(0)=lat(0)
;  oplot,lon,lat,color=symcol,symsize=symsiz 
;  oplot,olon,olat,psym=pltsym,color=symcol,symsize=symsiz
;  tlat=fltarr(2)
;  tlon=fltarr(2)
;  for i=0,num_int do begin
;   ilat=nlat*i
;   time=rng_val(0)+tmint*i
;   cdf_epoch, time, yr,mo,dy,hr,mn,sc,ml,/break
;   shr=strtrim(string(hr),2)
;   smn=strtrim(string(mn),2)
;   symlab=' '+shr+':'+smn
;   alat(i)=lat(ilat)
;   alon(i)=lon(ilat)
;  Make tick mark 
;   tlat(0)=lat(ilat)
;   if(i eq num_int) then tlat(1)=lat(ilat-1) else tlat(1)=lat(ilat+1)
;   tlon(0)=lon(ilat)
;   if(i eq num_int) then tlon(1)=lon(ilat-1) else tlon(1)=lon(ilat+1)
;   make_tick, tlat,tlon,symsiz=symsiz,symcol=symcol
; Make label
;   if(n_elements(limit) eq 0) then begin
;     xyouts,alon(i),alat(i),symlab,color=symcol,charsize=symsiz
;   endif else begin
;    if(alon(i) gt limit(1) and alon(i) lt limit(3) and $
;       alat(i) gt limit(0) and alat(i) lt limit(2)) then begin 
;      xyouts,alon(i),alat(i),symlab,color=symcol,charsize=symsiz
;    endif
;   endelse
;  endfor
;   olon(0)=alon(0)
;   olat(0)=alat(0)
; ; oplot,alon,alat,psym=pltsym,color=symcol
;;    oplot,alon,alat,color=symcol,symsize=symsiz,psym=pltsym
;   oplot,olon,olat,psym=pltsym,color=symcol,symsize=symsiz
;endif
 if(ptype eq 1) then begin
;TJK changed this so that if we actually have an array of
;stations labels they will be used.
;  if(n_elements(station(0)) le 1) then begin
  if(n_elements(station) le 1) then begin
     ; RCJ 01/06/02 Added []'s here because oplot plots arrays and if
     ; lon and lat are made of only one value (not an array) we get an error
     oplot,[lon],[lat],psym=5,color=symcol,symsize=symsiz
  endif else begin
   for i=0,n-1 do begin
;    xyouts,lon(i),lat(i),station(i),color=symcol
     if(n_elements(limit) ne 0) then begin
	if (lat(i) ge limit(0) and lat(i) le limit(2) and $
	    lon(i) ge limit(1) and lon(i) le limit(3)) then begin
          xyouts,lon(i),lat(i),station(i),charsize=symsiz,color=symcol
        endif
     endif else begin
	xyouts,lon(i),lat(i),station(i),charsize=symsiz,color=symcol
     endelse
     
   endfor
  endelse

 endif
;
; generate labels for each line or type of data
;

xtmp=xoffset+0.03
xyouts, xtmp,yoffset,label,/norm,color=symcol,charsize=charsize      
; Modify for normal coord.
;if(pltsym eq 0) then sym='!20C!X'
;if(pltsym eq 1) then sym='+'
;if(pltsym eq 2) then sym='*'
;if(pltsym eq 3) then sym='.'
;if(pltsym eq 4) then sym='!9V!x'
;if(pltsym eq 5) then sym='!7D!x'
;if(pltsym eq 6) then sym='!9B!x'
;if(pltsym eq 7) then sym='x'
;if(pltsym eq 8) then sym='!20I!X'
xyouts, xoffset,yoffset,sym,/norm,color=symcol,charsize=symsiz
;oplot,xoffset,yoffset,color=symcol,psym=pltsym,symsize=symsiz

; Iterate line label
pmode=pmode-1
yoffset=yoffset-offset_int
;symcol=symcol-pmode*10
; RCJ 02/17/2006 Commented out line below. Colors come from plotmaster.
;symcol=symcol+30
; Attempt to scale and center labels
; col=10
;sym=100.0*(charsize^3)
;xd=(strlen(thetitle)+charsize)/sym
;xxd=0.5-xd
; title works in 5.0 xyouts, 0.1,0.975,thetitle,/norm,color=col,charsize=charsize
end
