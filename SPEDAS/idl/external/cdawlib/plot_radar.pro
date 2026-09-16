;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/plot_radar.pro,v 1.13 1998/10/01 12:03:51 baldwin Exp johnson $
;$Locker: johnson $
;$Revision: 7092 $
FUNCTION plot_radar, astruct, vnum, XYSIZE=XYSIZE,TSTART=TSTART,TSTOP=TSTOP,$
                     MINTIME=MINTIME,GIF=GIF,GCOUNT=GCOUNT,$
		     ps=ps, pcount=pcount,$
                     REPORT=REPORT,DEBUG=DEBUG

; Establish error handler
  catch, error_status
  if(error_status ne 0) then begin
   if((error_status eq -133) OR (error_status eq -142) OR (error_status eq -146)) then $
    print, 'STATUS= No data available for this time range.  Re-select variable(s) or time range. ' else $
   print, 'STATUS= No valid data selected. '
   print, 'ERROR=Error number: ',error_status,' in plot_radar.'
   print, 'ERROR=Error Message: ', !ERR_STRING
   close, 1
   return, -1
  endif

; Initialize
thetitle = ' '

; Open report file if keyword is set
;if keyword_set(REPORT) then begin & reportflag=1L & a=size(REPORT)
; if (a(n_elements(a)-2) eq 7) then OPENW,1,REPORT,132,WIDTH=132
;endif else reportflag=0L
if keyword_set(REPORT) then reportflag=1L else reportflag=0L 

if keyword_set(XYSIZE) then xs = XYSIZE else xs = 400
if keyword_set(GCOUNT) then gif_number = GCOUNT else gif_number = 0L
if keyword_set(pCOUNT) then ps_number = pCOUNT else ps_number = 0L
if keyword_set(MINTIME) then min_t = MINTIME else min_t = 3600.0 ; 1hr in secs

; Determine the source and station of the radar data 
radar=strmid(astruct.epoch.source_name,0,4) ; Determine source of radar data
station=astruct.epoch.descriptor ; Determine radar station
 rot=0.0
; Set plot limits based on the station providing the data
if(strmid(station,0,4) eq 'PACE') then begin
  limit=[-90,-180,-60,180] & p0lat=-90.0 & p0lon=180.0
endif else begin
   limit=[60.,-180.,90.,180.] & p0lat=90.0 & p0lon=180.0
endelse
station = strmid(station,5,strlen(station)-5) ; reduce to station name


; Get the time, position and velocity data from the structure
velocity = handle_check(astruct.vel)
position = handle_check(astruct.position)
times    = handle_check(astruct.epoch)
qflgs    = handle_check(astruct.qflag)


; Unfortunately, much of the DARN radar data has backward time steps.
; Search for this and repair the data arrays where it occurs.
i = lindgen(n_elements(times)-1) & w = where(times(i) gt times(i+1),wc)
if (wc gt 0) then begin
  if keyword_set(DEBUG) then print,'WARNING=Repairing',wc,' backward time steps'
  for j=0,wc-1 do begin ; process each back step
    ; locate where the data after the break overlaps the data before the break
    ; and flag the overlapped times by zeroing out the times fields
    b = where(times ge times(w(j)+1),bc) & times(b(0):w(j)) = 0.0D0
  endfor
  ; Scrub out the data where the times array was set to zero
  w = where(times ne 0.0D0) & times=times(w) & qflgs=qflgs(*,w)
  position=position(*,*,w) & velocity=velocity(*,*,w)
endif

; Separate the positions and velocities into their components
mlats = position(0,*,*) & mlats = reform(mlats)
mlons = position(1,*,*) & mlons = reform(mlons)
vest  = velocity(0,*,*) & vest  = reform(vest)
vnrt  = velocity(1,*,*) & vnrt  = reform(vnrt)
malts = mlats

; Expand the times array to match the dimensionality of the mlats and mlons
; arrays, so that fill data may be screened correctly with like-sized arrays.
a = n_elements(times) & b = size(mlats)
times = rebin(reform(times,1,a,/overwrite),b(1),a,/sample)

; Screen out data where the quality flag indicates fill data
w = where(qflgs ne astruct.qflag.fillval,wc)
if (wc eq 0) then begin
  print,'ERROR=All data is fill data.  Unable to plot.' & return,-1
endif else begin
  mlats = mlats(w) & mlons = mlons(w) &  malts = malts(w)
  vest = vest(w) &  vnrt = vnrt(w) & times = times(w)
endelse

; Screen out data where the velocity data indicates fill data
w = where(vest ne astruct.vel.fillval,wc)
if (wc eq 0) then begin
  print,'ERROR=All data is fill data.  Unable to plot.' & return,-1
endif else begin
 mlats = mlats(w) & mlons = mlons(w) &  malts = malts(w)
 vest = vest(w) &  vnrt = vnrt(w) & times = times(w)
endelse
w = where(vnrt ne astruct.vel.fillval,wc)
if (wc eq 0) then begin
  print,'ERROR=All data is fill data.  Unable to plot.' & return,-1
endif else begin
 mlats = mlats(w) & mlons = mlons(w) &  malts = malts(w)
 vest = vest(w) &  vnrt = vnrt(w) & times = times(w)
endelse

; Screen out velocities outside the validmin/validmax range
vm = astruct.vel.validmin(0) & vx = astruct.vel.validmax(0)
w = where(((vest ge vm)AND(vest le vx)),wc)
if (wc eq 0) then begin
  print,'ERROR=No vest data within validmin/max limits'
endif else begin
  mlats = mlats(w) & mlons = mlons(w) &  malts = malts(w)
  vest = vest(w) &  vnrt = vnrt(w) & times = times(w)
endelse
vm = astruct.vel.validmin(1) & vx = astruct.vel.validmax(1)
w = where(((vnrt ge vm)AND(vnrt le vx)),wc)
if (wc eq 0) then begin
  print,'ERROR=No vnrt data within validmin/max limits'
endif else begin
  mlats = mlats(w) & mlons = mlons(w) &  malts = malts(w)
  vest = vest(w) &  vnrt = vnrt(w) & times = times(w)
endelse

; Screen out positions outside validmin/max limits
vm = astruct.position.validmin(0) & vx = astruct.position.validmax(0)
w = where(((mlats ge vm)AND(mlats le vx)),wc)
if (wc eq 0) then begin
  print,'STATUS=No valid data found. Re-select time interval.'
  print,'ERROR=No mlat data within validmin/max limits'
endif else begin
  mlats = mlats(w) & mlons = mlons(w) &  malts = malts(w)
  vest = vest(w) &  vnrt = vnrt(w) & times = times(w)
endelse
vm = astruct.position.validmin(1) & vx = astruct.position.validmax(1)
w = where(((mlons ge vm)AND(mlons le vx)),wc)
if (wc eq 0) then begin
  print,'STATUS=No valid data found. Re-select time interval.'
  print,'ERROR=No mlon data within validmin/max limits'
endif else begin
  mlats = mlats(w) & mlons = mlons(w) &  malts = malts(w)
  vest = vest(w) &  vnrt = vnrt(w) & times = times(w)
endelse

; Determine the proper start and stop times of the plot
tbegin = times(0) & tend = times(n_elements(times)-1) ; default to data
if keyword_set(TSTART) then begin ; set tbegin
  tbegin = TSTART & a = size(TSTART)
  if (a(n_elements(a)-2) eq 7) then tbegin = encode_CDFEPOCH(TSTART)
endif
if keyword_set(TSTOP) then begin ; set tend
  tend = TSTOP & a = size(TSTOP)
  if (a(n_elements(a)-2) eq 7) then tend = encode_CDFEPOCH(TSTOP)
endif


; Reduce the data arrays to within tbegin to tend if needed.
if (tbegin gt times(0)) then begin
  w = where(times ge tbegin)
  mlats = mlats(w) & mlons = mlons(w) &  malts = malts(w)
  vest = vest(w) &  vnrt = vnrt(w) & times = times(w)
endif
if (tend lt times(n_elements(times)-1)) then begin
  w = where(times le tend)
  mlats = mlats(w) & mlons = mlons(w) &  malts = malts(w)
  vest = vest(w) &  vnrt = vnrt(w) & times = times(w)
endif


; Radar plots are daily plots.  Determine indices where day boundaries occur.
; Also, drop any data fragments less than an amount of time given by MINTIME,
; and convert the times from CDF_EPOCH to seconds of day.
jds = lonarr(n_elements(times)) ; create an array to hold julian days
sod = lonarr(n_elements(times)) ; create an array to hold seconds of days
for i=0L,n_elements(times)-1 do begin ; compute julian day of each data point
  CDF_EPOCH,times(i),y,m,d,h,n,s,ms,/BREAK & jds(i) = julday(m,d,y)
  sod(i) = float((h*60+n)*60+s+(ms/1000))
endfor & u = uniq(jds)

us=size(u)
; patch for no data 
if(us(0) eq 0) then begin
 if(u lt 12) then begin
  print, "STATUS=No data for the selected time range"
  return, -1
 endif
endif

for i=0L,n_elements(u)-1 do begin ; validate minimum amount of data per day
  if i eq 0 then a = times(0) else a = times(u(i-1)+1) & b = times(u(i))
  if ((b - a) gt min_t) then begin ; enough data in the day for plot
    if i eq 0 then a = 0 else a = u(i-1)+1 & b = u(i)
    if n_elements(ib) eq 0 then begin & ib=a & ie=b & endif $
    else begin & ib=[ib,a] & ie=[ie,b] & endelse
  endif
endfor


; Generate a radar vector plot for each day of data
for i=0L,n_elements(ib)-1 do begin

  ; Open an X-window or GIF or ps file depending on keywords
  if keyword_set(GIF) then begin
    ; Determine name for new gif file
    if(gif_number lt 100) then gifn='0'+strtrim(string(gif_number),2)
    if(gif_number lt 10) then gifn='00'+strtrim(string(gif_number),2) 
    if(gif_number ge 100) then gifn=strtrim(string(gif_number),2) 
    GIF=strmid(GIF,0,(strpos(GIF,'.gif')-3))+gifn+'.gif'

    deviceopen,6,fileOutput=GIF,sizeWindow=[xs,xs]
    if (reportflag eq 1) then printf,1,'GIF=',GIF
    print,'GIF=',GIF
    gif_number = gif_number + 1
  endif
  if keyword_set(ps) then begin
    ; Determine name for new ps file
    if(ps_number lt 100) then psn='0'+strtrim(string(ps_number),2)
    if(ps_number lt 10) then psn='00'+strtrim(string(ps_number),2) 
    if(ps_number ge 100) then psn=strtrim(string(ps_number),2) 
    ps=strmid(ps,0,(strpos(ps,'.eps')-3))+psn+'.eps'

    deviceopen,1,fileOutput=ps,/portrait,sizeWindow=[xs,xs]
    if (reportflag eq 1) then printf,1,'PS=',ps
    print,'PS=',ps
    ps_number = ps_number + 1
  endif  
  if (not keyword_set(GIF)  and not keyword_set(ps)) then begin
    window,/FREE,XSIZE=xs,YSIZE=xs,TITLE='DARN RADAR PLOT'
  endif
;  ; Open an X-window or GIF or ps file depending on keywords
;  if keyword_set(GIF) then begin
;    ; Determine name for new gif file
;;   if (gif_number gt 0) then begin
;;     c = strpos(GIF,'.gif') ; search for .gif suffix
;;     if (c ne -1) then begin
;;       c = strmid(GIF,0,c) & GIF=c+strtrim(string(gif_number),2)+'.gif'
;;     endif else GIF=GIF+strtrim(string(gif_number),2)
;;   endif
;    if(gif_number lt 100) then gifn='0'+strtrim(string(gif_number),2)
;    if(gif_number lt 10) then gifn='00'+strtrim(string(gif_number),2) 
;    if(gif_number ge 100) then gifn=strtrim(string(gif_number),2) 
;    GIF=strmid(GIF,0,(strpos(GIF,'.gif')-3))+gifn+'.gif'
;
;    deviceopen,6,fileOutput=GIF,sizeWindow=[xs,xs]
;    if (reportflag eq 1) then printf,1,'GIF=',GIF
;    print,'GIF=',GIF
;    gif_number = gif_number + 1
;  endif else begin
;    window,/FREE,XSIZE=xs,YSIZE=xs,TITLE='DARN RADAR PLOT'
;  endelse

  ; construct structure containing required time data
  CDF_EPOCH,times(ib(i)),y,m,d,h,n,s,ms,/BREAK & monday,y,doy,m,d,/yearday
  mytimes = create_struct('year',y,'doy',doy,'mon',m,'day',d,$
                          'times',sod(ib(i):ie(i)))

  ; extract data from arrays for plotting
  lats = mlats(ib(i):ie(i))
  lons = mlons(ib(i):ie(i))
  ves  = vest (ib(i):ie(i))
  vnr  = vnrt (ib(i):ie(i))
  alts = malts(ib(i):ie(i))
  qfls = qflgs(ib(i):ie(i))

;print, "TIMES", size(mytimes), mytimes(0), mytimes(n_elements(mytimes)-1)

 s=vectplt(lats,lons,alts,ves,vnr,mytimes,qfls,$
          Stitle=station,mcors=mltin,Qmin=qmin,Qmax=qmax,nopolar=nop,$
          Scale=scale,nobin=nob,p0lat=p0lat,p0lon=p0lon,rot=rot,$
          binlat=bin_lat,binlon=bin_lon,limit=limit,latdel=latdel,$
          londel=londel,Alt=alt,xmargin=[6,6],ymargin=[4,4],Ttitle=thetitle,$
          lthik=lthik,symsiz=symsiz,symcol=symcol,$
          _extra=extras)

  ; Close any open GIF file
  ;if keyword_set(GIF) then deviceclose
  if ( keyword_set(GIF) or keyword_set(ps)) then deviceclose
endfor

;return,gif_number
if keyword_set(ps) then return,ps_number 
if keyword_set(gif) then return,gif_number 
end
