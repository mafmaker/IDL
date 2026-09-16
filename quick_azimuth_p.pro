PRO THETAROT,NEWS,NEWd,NEWZ,NEWS2,NEWD2,NEWZ2,ZLAT

;PROGRAM TO ROTATE VECTORS ABOUT Y-AXIS


THETA=reform(ABS((!PI/2.0)-ZLAT))

dim3=size(news) & dim3=dim3(2)
one=fltarr(dim3) & one(*)=1.
zero=fltarr(dim3) & zero(*)=0.

ROTYAX=FLTARR(3,3,dim3)

;ROTYAX(0:2,0,*)=[COS(THETA),0,-SIN(THETA)]
;ROTYAX(0:2,1,*)=[0,1,0]
;ROTYAX(0:2,2,*)=[SIN(THETA),0,COS(THETA)]
rotyax(0,0,*)=COS(THETA)
rotyax(1,0,*)=zero
rotyax(2,0,*)=-sin(THETA)
rotyax(0,1,*)=zero
rotyax(1,1,*)=one
rotyax(2,1,*)=zero
rotyax(0,2,*)=sin(THETA)
rotyax(1,2,*)=zero
rotyax(2,2,*)=COS(THETA)
;     rotyax=[[COS(THETA),zero,-SIN(THETA)],[zero,one,zero],$
;     [SIN(THETA),zero,cos(theta)]]		;maybe useful


;looping again!  IDL is lame for real math...


ONews2=news
ONewd2=news
ONewz2=news

;for i=0,dim3-1 do begin;;
;
;  ONEWS2(*,i)=[NEWS(0,i),NEWS(1,i),NEWS(2,i)]#ROTYAX(*,*,i)
;  ONEWD2(*,i)=[NEWD(0,i),NEWD(1,i),NEWD(2,i)]#ROTYAX(*,*,i)
;  ONEWZ2(*,i)=[NEWZ(0,i),NEWZ(1,i),NEWZ(2,i)]#ROTYAX(*,*,i)
;
;endfor
;but you could try this!

trys=fltarr(3,3,dim3) & for i=0,2 do trys(*,i,*)=news ;transposes and fills
news2=total(trys * rotyax,1)	;plain matrix multiplication and total
trys(*,*,*)=0. & for i=0,2 do trys(*,i,*)=newd ;transposes and fills
newd2=total(trys * rotyax,1)    ;plain matrix multiplication and total
trys(*,*,*)=0. & for i=0,2 do trys(*,i,*)=newz ;transposes and fills
newz2=total(trys * rotyax,1)    ;plain matrix multiplication and total

checker=news2-onews2 & thingy=where(checker ne 0,counter) & print,counter

RETURN
end
;**************************************************
;**************************************************
PRO PHIROT,news,newd,newz,svec,dvec,zvec,NEWVEC

;Procedure to rotate spherical coordinates about z-axis.

PHI=reform(ATAN(Zvec(1,*),zvec(0,*)))

dim3=size(zvec) & dim3=dim3(2)
one=fltarr(dim3) & one(*)=1.
zero=fltarr(dim3) & zero(*)=0.
ROTNAX=FLTARR(3,3,DIM3)

;ROTNAX(0:2,0)=[COS(PHI),SIN(PHI),0]
;ROTNAX(0:2,1)=[-SIN(PHI),COS(PHI),0]
;ROTNAX(0:2,2)=[0,0,1]

ROTNAX(0,0,*)=COS(PHI)
ROTNAX(1,0,*)=SIN(PHI)
ROTNAX(2,0,*)=ZERO
ROTNAX(0,1,*)=-SIN(PHI)
ROTNAX(1,1,*)=COS(PHI)
ROTNAX(2,1,*)=ZERO
ROTNAX(0,2,*)=ZERO
ROTNAX(1,2,*)=ZERO
ROTNAX(2,2,*)=ONE

;NEWS= [Svec(0),Svec(1),Svec(2)] # ROTNAX
;newd= [Dvec(0),Dvec(1),Dvec(2)] # ROTNAX
;NEWZ= [Zvec(0),Zvec(1),Zvec(2)] # ROTNAX
;NEWVEC= [Dvec(0),Dvec(1),Dvec(2)] # ROTNAX

trys=fltarr(3,3,dim3) & for i=0,2 do trys(*,i,*)=svec ;transposes and fills
news=total(trys * rotnax,1)	;plain matrix multiplication and total
trys(*,*,*)=0. & for i=0,2 do trys(*,i,*)=dvec ;transposes and fills
newd=total(trys * rotnax,1)    ;plain matrix multiplication and total
trys(*,*,*)=0. & for i=0,2 do trys(*,i,*)=zvec ;transposes and fills
newz=total(trys * rotnax,1)    ;plain matrix multiplication and total

;checker=news2-onews2 & thingy=where(checker ne 0,counter) & print,counter


RETURN
end

;---end procedures begin functions

FUNCTION DEG2RAD, ARRAY
;CONVERTS AN ARRAY OF ANGLES FROM DEGREES TO RADIANS.
;CAN WORK ON ANY ARRAY!
XXX=WHERE(ARRAY NE -300.0)
if xxx(0) ne -1 then ARRAY(XXX)=ARRAY(XXX)/180.0 * !PI
RETURN,ARRAY
END
;*************************************************************************
FUNCTION ONE2RAD, ANG
;CONVERTS A SINGLE ANGLE FROM DEGREES TO RADIANS
ANG=ANG/180.0 * !PI 
RETURN,ANG
END
;*************************************************************************

;---end functions begin main

pro quick_azimuth_p,maf,azimuth,de=de


;PROGRAM QUICK_AZIMUTH_P.PRO      
;PROGRAM TO CALCULATE AZIMUTHAL ANGLE FOR DE IMAGE PIXELS via array operations!
;
;	date 3-11-98  TJI
;
; This version (originally doazimuth.pro) will give 180 degrees
; of azimuth. It does so by array operation of all pixel-angles
; at once, resulting in an ~8 fold decrease in processing time!
;
; "This is a masterful chunk of code." TJI
; " I wanna kiss myself!" JB
;
;  VERSION HISTORY 1.01 11-29-97  Incorporated directory finding from 
;					polar_azimuth code on Sunriz
;		   1.02 3-11-97   Proceduralized (no need to open/save)
;
;*************************************************************************


  LON=MAF.GLON
  LAT=MAF.GLAT
  if keyword_set(de) eq 1 then SHIFTLONG,LON
  LON=DEG2RAD(LON)
  LAT=DEG2RAD(LAT)
;***************get cartesian coordinates for 0-360 longitude array***********
;X=LAT & Y=LAT & Z=LAT
;X(*,*)=0. & Y(*,*)=0. & Z(*,*)=0.      ;THIS CALCULATES X,Y,Z COORDS FOR
;GEO2CART,LAT,LON,X,Y,Z              ;THE ENTIRE IMAGE.
;**************************extract info from filename*************************
if keyword_set(de) eq 1 then begin

  YEAR=FIX(STRMID(MAF.NAME,0,2))
  DAY=FIX(STRMID(MAF.NAME,2,3))
  HOUR=FIX(STRMID(MAF.NAME,5,2))
  MIN=FIX(STRMID(MAF.NAME,7,2))
  SEC=FIX(STRMID(MAF.NAME,9,2))

endif else begin		;assume IMAGE
  year=fix(strmid(strcompress(maf.time(0),/rem),0,4))
  day=fix(strmid(strcompress(maf.time(0),/rem),4,3))
  time_dec2clock,maf.time(1)/1000./3600.,hr,min,sec,msec
  hour=fix(hr)
  min=fix(min)
  sec=fix(sec)
endelse


;*************************FIND SECONDS IN UT DAY**************************
  UTSEC=3600.* HOUR + 60. * MIN + SEC
;*************************FIND SOLAR R.A., DEC.************************
;****************************SOLAR LAT AND LON*************************
;********************AND GREENWICH MEAN SIDEREAL TIME******************
  GST=0.0 & SLON=0.0 & RA=0.0 & DEC=0.0
  if keyword_set(de) eq 1 then SUN,MAF,GST,SLON,RA,DEC else $
    SUN3,MAF,GST,SLON,RA,DEC 

  PRINT,'Right Ascension: ' + string(RA)
  PRINT,'Declination: ' + string(DEC)
    degpersec=360./(1440. * 60.)
  UTDEG=DEGPERSEC*UTSEC
  LONGITUDE=(180.0-UTDEG)
  IF LONGITUDE LT 0.0 THEN shiftlong,longitude ;lLONGITUDE=LONGITUDE + 360.0
  PRINT,' '
  PRINT,'SUB-SOLAR POINT '
  PRINT,'LATITUDE: ' + STRING(DEC)
  PRINT,'LONGITUDE:' + STRING(LONGITUDE)
  SLAT=ONE2RAD(DEC)
  SLON=ONE2RAD(LONGITUDE)
;******************FIND LAT AND LON OF SUB-SATELLITE POINT**************
  DZA=MAF.DZA
  YYY=WHERE(DZA EQ -1)
  if yyy(0) ne -1 then begin
     DZA(YYY)=400.
  endif
  YYY=0
  VAL=MIN(DZA)
  ZZZ=WHERE(DZA EQ VAL)
  DLON=(LON(ZZZ))   ;THIS *IS* ROTATED (TO 0-360), AND *IS* IN RADIANS!!
  DLAT=(LAT(ZZZ))
  DLAT=FLOAT(DLAT(0))
  DLON=FLOAT(DLON(0))
;*********SET UP ARRAY TO HOLD CALCULATED AZIMUTHAL ANGLES*********
;*****AND NEW SOLAR AND SPACECRAFT *longitudinal* ANGLES FOR DEBUGGING*****
  AZIMUTH=LAT
  AZIMUTH(*,*)=0.0
;  ARRNEWSLON=AZIMUTH
;  ARRNEWDLON=AZIMUTH
;**********************BEGIN LOOP OF TRANSFORMS FOR PIXELS*************
;PICK A SINGLE PIXEL BUT SET UP TO DO ALL
  XXX=WHERE(MAF.GLON NE -300.0,SIZER)  ;LON ARRAY NO LONGER HAS VALUES OF -300.0
  PRINT,SIZER

;  REMOVING LOOP ON 10-3-97!!! TJI
;  FOR I=0,SIZER-1 DO BEGIN  


;  if sizer gt 0 then begin	;should not have to do this!
    ZLAT=LAT(XXX)
    ZLON=LON(XXX)
;  endif else goto , SKIP_IMAGE
;*********************ROTATE GEOGRAPHIC LONGITUDES*************************
;************SUCH THAT THE solar DIRECTION HAS 0 "LONGITUDE"*************** 
;-----THIS IS IN EFFECT THE FIRST EULER ROTATION!!!. CARTESIAN COORDS ARE NOT
;-----NECESSARY HERE. It actually is only part of the first rotation.
;LLL=WHERE(LON LT 0.0)
;NEWLON(LLL)=NEWLON(LLL) + 2.0 * !PI
  VARDLON=DLON-sLON                                   ; A VARIABLE NEW DLON
  vardlon_fix=where(vardlon lt 0.0,counter)
  if counter gt 0 then vardlon(vardlon_fix)=VARDLON(vardlon_fix) + 2.0 * !PI
;  IF VARDLON LT 0.0 THEN VARDLON=VARDLON + 2.0 * !PI
  VARZLON=ZLON-sLON                                   ; A VARIABLE NEW ZLON
  varzlon_fix=where(varzlon lt 0.0,counter)
  if counter gt 0 then varzlon(varzlon_fix)=VARzLON(varzlon_fix) + 2.0 * !PI
;  IF VARZLON LT 0.0 THEN VARZLON=VARZLON + 2.0 * !PI
  VARSLON=SLON-sLON                                   ; 0.0
;the above section worked pretty nicely...
;************************CREATE CARTESIAN COORDINATES**********************
;  DX=0.0 & DY=0.0 & DZ=0.0
;  SX=0.0 & SY=0.0 & SZ=0.0
;  ZX=0.0 & ZY=0.0 & ZZ=0.0

  dx=fltarr(sizer) & dy=dx & dz=dx
  sx=fltarr(sizer) & sy=sx & sz=sx
  zx=fltarr(sizer) & zy=zx & zz=zx

  GEO2CART,DLAT,VARDLON,DX,DY,DZ
  GEO2CART,SLAT,VARSLON,SX,SY,SZ
  GEO2CART,ZLAT,VARZLON,ZX,ZY,ZZ

  SVEC=FLTARR(3,SIZER)
  DVEC=SVEC
  ZVEC=DVEC

  SVEC(0,*)=SX & SVEC(1,*)=SY & SVEC(2,*)=SZ
  DVEC(0,*)=DX & DVEC(1,*)=DY & DVEC(2,*)=DZ
  ZVEC(0,*)=ZX & ZVEC(1,*)=ZY & ZVEC(2,*)=ZZ  

;************************BEGIN FIRST ROTATION*********************************
;procedures thetarot and phirot are in [immel.idl]

  PHIROT,news,newd,newz,svec,dvec,zvec

;******************************BEGIN 2ND ROTATION!!!**************************
;***********AS WRITTEN THIS IS A ROTATION ABOUT THE Y AXIS IN ORDER TO
;***COORDINATE THE ZENITH VECTOR AND THE NORTH POLE. THE SYSTEM OF VECTORS
;********IS ROTATED *UP* SO THE ZENITHAL VECTOR IS NOW IN THE POLE 
;****IF THE ZENITHAL VECTOR IS CORRECTLY POSITIONED ABOVE, IT WILL NOT HAVE A
;***Y-AXIS COMPONENT TO BEGIN WITH. THE X COMPONENT WILL BE ELIMINATED HERE.!!!

  THETAROT,NEWS,NEWd,NEWZ,NEWS2,NEWD2,NEWZ2,ZLAT

  newSLAT=0.0   &   newSLON=0.0  &  newDLAT=0.0   &   newDLON=0.0

  CART2GEO,newSLAT,newSLON,NEWS2(0,*),NEWS2(1,*),NEWS2(2,*)
  CART2GEO,newDLAT,newDLON,NEWD2(0,*),NEWD2(1,*),NEWD2(2,*)

;this next set of commands is crucial! It takes care of an oversight. 4-12-97
;the problem is in the newdlon, with the 0-360 discontinuity  10-4-97

AZIMUTH(XXX)=ABS(reform(NEWDLON)-reform(NEWSLON))
 thing=where(azimuth gt 180,maybenot)
 if maybenot gt 0 then azimuth(thing)=360-azimuth(thing)


;  AZIMUTH(XXX)=ABS(reform(NEWDLON)-reform(NEWSLON))
;  helper=where(ABS(reform(NEWDLON)-reform(NEWSLON)) GT 180.0,counter)
;  if counter gt 0 then begin    ; ABS(NEWDLON-NEWSLON) GT 180.0 THEN BEGIN
;    DIFF=ABS(reform(NEWDLON)-reform(NEWSLON))-180.0
;  endif
;azimuth1=azimuth
;    AZIMUTH(XXX)=180.0-DIFF
;
;  ENDFOR
;***********************SAVE THE AZIMUTH ANGLES***********************
  azimuth=fix(azimuth)                               ;save diskspace!!! 

;  aaa=extension
;  if aaa eq 'IDL' or aaa eq 'idl' then bbb='.azi'
;  if aaa eq 'ID2' or aaa eq 'id2' then bbb='.az2'
;  if aaa eq 'ID3' or aaa eq 'id3' then bbb='.az3'
;  if aaa eq 'ID4' or aaa eq 'id4' then bbb='.az4'
;  if aaa eq 'ID5' or aaa eq 'id5' then bbb='.az5'

;  SAVE,FILENAME=STRMID(MAF.NAME,0,15) + bbb,AZIMUTH
;*********************************************************************

;tvscl,azimuth

;ENDFOR
;CLOSE,2

;print,systime()

END
