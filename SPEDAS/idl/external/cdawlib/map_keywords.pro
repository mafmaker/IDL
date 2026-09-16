;$author: baldwin $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/map_keywords.pro,v 1.30 2000/08/15 19:05:24 johnson Exp johnson $
;$Locker: johnson $
;$Revision: 8 $
;+------------------------------------------------------------------------
; NAME: MAP_KEYWORDS.PRO 
;
; PURPOSE:  Read in a file of keyword values pairs and assign these to 
;           IDL keywords
;
; KEYWORD PARAMETERS:
;   ORB_VW    Orbit plot keyword for orbit view up to an array (xy, xz, yz, xr) 
;   XMIN      Orbit plot keyword for minimum x axis value
;   YMIN      Orbit plot keyword for minimum y axis value
;   YMAX      Orbit plot keyword for maximum y axis value
;   XMAX      Orbit plot keyword for maximum x axis value
;   DOYMARK   Orbit plot keyword for interval along the orbit on which the 
; 	        day of year is plotted
;   HRMARK    Orbit plot keyword for interval along the orbit on which the 
;   		hour of day is plotted
;   HRTICK    Orbit plot keyword for tick interval along the orbit 
;   MNTICK    Minute tick interval
;   MNMARK    Minute mark interval
;   BZ        Orbit plot keyword for BZ component 
;   PRESS     Orbit plot keyword for solar wind pressure
;   STATION   Mapped plot keyword for an array of stations 
;   IPROJ     Mapped plot keyword for map projection
; aitoff (15), az. equid. (6), cyl (8), gnom (5), lamb eq area (4)
; merc (9), molle (10), ortho (2), sinsusoidal (14), stero. (1)
;   LIM       Mapped plot keyword for map_set limits
;   LATDEL    Mapped plot keyword for latitude interval 
;   LONDEL    Mapped plot keyword for longitude interval
;   Ttitle    Mapped plot keyword for title
;   SYMSIZ    Mapped plot keyword for symbol size
;   LNTHICK   Plot keyword for line thickness.
;   SYMCOL    Mapped plot keyword for symbol color
;   LNLABEL   Mapped plot keyword for line labels
;   CHTSIZE   Character size of text
;   REPORT    Flag to write to the REPORT file opened in plotmaster
;   PID       Process id
;   OUTDIR    This keyword indiates the output directory where a gif file 
;             will be placed. If GIF is set but OUTDIR is not, then the gif 
;             file will be put in the user's current working directory.
;   US        Position of the Sun convention; left U.S.(1); right EUR.-JAP.(0)
;             (Default; US=1) 
;
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occurred.
; AUTHOR:
;       Richard Baldwin, HSTX NASA/GSFC Code 632.0, Feb 2, 1997
;       baldwin@nssdca.gsfc.nasa.gov    (301)286-7220
; MODIFICATION HISTORY:
;       8/30/96 : R. Baldwin   : Add error handling STATUS,DATASET,IMAGE,GIF 
;-------------------------------------------------------------------------
FUNCTION map_keywords, ORB_VW=ORB_VW, XUMN=XUMN, XUMX=XUMX, YUMN=YUMN, $
  YUMX=YUMX,ZUMN=ZUMN,ZUMX=ZUMX,RUMN=RUMN,RUMX=RUMX, DOYMARK=DOYMARK, $
  HRMARK=HRMARK, HRTICK=HRTICK, MNTICK=MNTICK,MNMARK=MNMARK,LNTHICK=LNTHICK,$
             CHTSIZE=CHTSIZE, BZ=BZ, PRESS=PRESS, STATION=station, $
             IPROJ=IPROJ,LIM=LIM,LATDEL=LATDEL, LONDEL=LONDEL, $
             Ttitle=TITLE,SYMSIZ=SYMSIZ,SYMCOL=SYMCOL,POLAT=POLAT,POLON=POLON,$
             ROT=ROT, LNLABEL=LNLABEL, BSMP=BSMP, ATLB=ATLB, DTLB=DTLB,$
             XSIZE=XSIZE,YSIZE=YSIZE,NOCONT=NOCONT,EQLSCL=EQLSCL,PANEL=PANEL,$
             REPORT=reportflag, PID=PID,OUTDIR=OUTDIR, US=US,_extra=extras

status=0
; Establish error handler
  catch, error_status                                                             
  if(error_status ne 0) then begin
    if (reportflag eq 1) then begin
      printf, 1, 'STATUS=Error reading keyword file; Use defaults'
;     printf, 1, 'ERROR=Error number: ',error_status,' in map_keywords.'
;     printf, 1, 'ERROR=Error Message: ', !ERR_STRING
;     close, 1
   endif else begin 
      print, 'STATUS=Error reading keyword file; Use defaults'
;     print, 'ERROR=Error number: ',error_status,' in map_keywords.'
;     print, 'ERROR=Error Message: ', !ERR_STRING
   endelse
   return, -1
  endif

; Open keyword file
 get_lun, lun
filename=OUTDIR+'idl_'+strtrim(string(PID),2)+'.key'
print, "filename=",filename
OPENR,lun, filename 

str_val=''
stations=strarr(150)
lats=fltarr(150)
lons=fltarr(150)

iscn=0
 while(NOT EOF(lun)) do begin 
  readf, lun, str_val
  parts = str_sep(str_val,'=')
  key=strupcase(parts(0))
  value=parts(1)
  if(key eq 'LATMIN') then LIM=fltarr(4)
;  if(key eq 'STATION ') then begin
  case key of 
   'STATION' : begin
     stations(iscn)=value
     readf, lun, str_val
     parts = str_sep(str_val,'=')
     key1=strupcase(parts(0))
     val1=parts(1)
     if(key1 eq 'LAT') then lats(iscn)=float(val1) else begin 
      printf, 1, 'STATUS=keyword file error'
      printf, 1, 'ERROR=Missing keyword in file error LAT'
     endelse

     readf, lun, str_val
     parts = str_sep(str_val,'=')
     key2=strupcase(parts(0))
     val2=parts(1)
     if(key2 eq 'LON') then lons(iscn)=float(val2) else begin 
      printf, 1, 'STATUS=keyword file error'
      printf, 1, 'ERROR=Missing keyword in file error LON'
     endelse

     iscn=iscn+1
   end
   'ORB_VW' : begin
      orbs=str_sep(value,' ')
      orbs=strlowcase(orbs)
      ORB_VW=strarr(n_elements(orbs)+1)
      ORB_VW=[orbs]
   end
   'CHARSIZE' : CHTSIZE=value
   'TITLE' : TITLE=value
   'LATMIN' : LIM(0)=value
   'LONMIN' : LIM(1)=value
   'LATMAX' : LIM(2)=value
   'LONMAX' : LIM(3)=value
 ; endif else begin
    else: x1=execute(key+'='+value)
  endcase 
 endwhile

 if(iscn ne 0) then begin
  station.num=iscn
  ws=where(stations ne '',wsn)
  fstat=stations(ws)
  flat=lats(ws)
  flon=lons(ws) 
  temp=create_struct('STATION',fstat,'LAT',flat,'LON',flon)
  station=create_struct(station,temp)
 endif
   
 free_lun, lun 

; Check map parameters
; if(LIM(0) eq LIM(2)) then LIM(0)=-90. & LIM(2)=90.
; if(LIM(1) eq LIM(3)) then LIM(1)=-180. & LIM(3)=180.
if((n_elements(POLAT) ne 0) and (n_elements(ROT) eq 0)) then ROT=0
if((n_elements(POLAT) ne 0) and (n_elements(POLON) eq 0)) then POLON=0
if((n_elements(POLON) ne 0) and (n_elements(ROT) eq 0)) then ROT=0
if((n_elements(POLON) ne 0) and (n_elements(POLAT) eq 0)) then POLAT=0
if((n_elements(ROT) ne 0) and (n_elements(POLON) eq 0)) then POLON=0
if((n_elements(ROT) ne 0) and (n_elements(POLAT) eq 0)) then POLAT=0

; Print out set variables
 if(n_elements(ORB_VW) ne 0) then print,'ORB_VW=',ORB_VW
 if(n_elements(XUMN) ne 0) then print,'XUMN=',XUMN
 if(n_elements(YUMN) ne 0) then print,'YUMN=',YUMN
 if(n_elements(ZUMN) ne 0) then print,'ZUMN=',ZUMN
 if(n_elements(RUMN) ne 0) then print,'RUMN=',RUMN
 if(n_elements(XUMX) ne 0) then print,'XUMX=',XUMX
 if(n_elements(YUMX) ne 0) then print,'YUMX=',YUMX
 if(n_elements(ZUMX) ne 0) then print,'ZUMX=',ZUMX
 if(n_elements(RUMX) ne 0) then print,'RUMX=',RUMX
 if(n_elements(DOYMARK) ne 0) then print,'DOYMARK=',DOYMARK
 if(n_elements(HRMARK) ne 0) then print,'HRMARK=',HRMARK
 if(n_elements(HRTICK) ne 0) then print,'HRTICK=',HRTICK
 if(n_elements(MNMARK) ne 0) then print,'MNMARK=',MNMARK
 if(n_elements(MNTICK) ne 0) then print,'MNTICK=',MNTICK
 if(n_elements(CHTSIZE) ne 0) then print,'CHTSIZE=',CHTSIZE
 if(n_elements(BZ) ne 0) then print,'BZ=', BZ
 if(n_elements(PRESS) ne 0) then print,'PRESS=',PRESS
 if(n_elements(station) ne 0) then print,'station=',station
 if(n_elements(IPROJ) ne 0) then print,'IPROJ=',IPROJ
 if(n_elements(LIM) ne 0) then print,'LIM=',LIM
 if(n_elements(LATDEL) ne 0) then print,'LATDEL=',LATDEL
 if(n_elements(LONDEL) ne 0) then print,'LONDEL=',LONDEL
 if(n_elements(TITLE) ne 0) then print,'TITLE=',TITLE
 if(n_elements(SYMSIZ) ne 0) then print,'SYMSIZ=',SYMSIZ
 if(n_elements(SYMCOL) ne 0) then print,'SYMCOL=',SYMCOL
 if(n_elements(LNLABEL) ne 0) then print,'LNLABEL=',LNLABEL
 if(n_elements(LNTHICK) ne 0) then print,'LNTHICK=',LNTHICK
 if(n_elements(reportflag) ne 0) then print,'reportflag=',reportflag
 if(n_elements(PID) ne 0) then print,'PID=',PID
 if(n_elements(OUTDIR) ne 0) then print,'OUTDIR=',OUTDIR
 if(n_elements(US) ne 0) then print,'US=',US
 if(n_elements(BSMP) ne 0) then print,'BSMP=',BSMP
 if(n_elements(ATLB) ne 0) then print,'ATLB=',ATLB
 if(n_elements(DTLB) ne 0) then print,'DTLB=',DTLB
 if(n_elements(POLAT) ne 0) then print, 'POLAT=',POLAT
 if(n_elements(POLON) ne 0) then print, 'POLON=',POLON 
 if(n_elements(ROT) ne 0) then print, 'ROT=',ROT
 if(n_elements(NOCONT) ne 0) then print, 'NOCONT=',NOCONT 
 if(n_elements(EQLSCL) ne 0) then print, 'EQLSCL=',EQLSCL 
 if(n_elements(PANEL) ne 0) then print, 'PANEL=',PANEL
 if(n_elements(XSIZE) ne 0) then print, 'XSIZE=',XSIZE
 if(n_elements(YSIZE) ne 0) then print, 'YSIZE=',YSIZE
 if(n_elements(extras) ne 0) then print,'extras=',extras
 
return, status 
end 
