;PROGRAM (DO)NEWAZIMUTH.PRO      
;PROGRAM TO CALCULATE AZIMUTHAL ANGLE FOR DE IMAGE PIXELS
;*************************************************************************
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
NUM=0
NAME=' '
!path='disk$user1:[immel.idl],'+ !path 
OPENR,2,'AZIMUTH.DAT'
READF,2,NUM
X=STRARR(NUM)
FOR I=0,NUM-1 DO BEGIN
  READF,2,NAME
  X(I)=NAME
ENDFOR
CLOSE,2
FOR F=0,NUM-1 DO BEGIN
  RESTORE,'[immel.quiet]' + X(F)
  extension=strmid(x(f),16,3)
  print,f+1
  LON=MAF.GLON
  LAT=MAF.GLAT
  off_earth=where(lat eq -300,sizer)
  SHIFTLONG,LON
  LON=DEG2RAD(LON)
  LAT=DEG2RAD(LAT)

;***************get cartesian coordinates for 0-360 longitude array***********
;X=LAT & Y=LAT & Z=LAT
;X(*,*)=0. & Y(*,*)=0. & Z(*,*)=0.      ;THIS CALCULATES X,Y,Z COORDS FOR
;GEO2CART,LAT,LON,X,Y,Z              ;THE ENTIRE IMAGE.
;**************************extract info from filename*************************
  YEAR=FIX(STRMID(MAF.NAME,0,2))
  DAY=FIX(STRMID(MAF.NAME,2,3))
  HOUR=FIX(STRMID(MAF.NAME,5,2))
  MIN=FIX(STRMID(MAF.NAME,7,2))
  SEC=FIX(STRMID(MAF.NAME,9,2))
;*************************FIND SECONDS IN UT DAY**************************
  UTSEC=3600.* HOUR + 60. * MIN + SEC
;*************************FIND SOLAR R.A., DEC.************************
;****************************SOLAR LAT AND LON*************************
;********************AND GREENWICH MEAN SIDEREAL TIME******************
;  GST=0.0 & SLON=0.0 & RA=0.0 & DEC=0.0
  SUN2,MAF,GST,SLON_arr,RA_arr,DEC_arr     ;arrays are now returned!
  PRINT,'Right Ascension: ' + string(RA_arr(0,0))
  PRINT,'Declination: ' + string(DEC_arr(0,0))
    degpersec=360./(1440. * 60.)
  UTDEG=DEGPERSEC*float(maf.ut/1000)           ;array of 'degrees' UT
  LONGITUDE=(180.0-UTDEG)		       ;array of longitudes

;  IF LONGITUDE LT 0.0 THEN LONGITUDE=LONGITUDE + 360.0
;---cant do above, do the following:
  correct_lon=where(longitude lt 0.0)
  if correct_lon(0) ne -1 then  $
           longitude(correct_lon)=Longitude(correct_lon) + 360.0
  if off_earth(0) ne -1 then begin
    longitude(off_earth)=-300.0
;---also, for the function:
    dec_arr(off_earth)=-300.0
  endif

;  SLAT=ONE2RAD(DEC)
;  SLON=ONE2RAD(LONGITUDE)
;---can no longer do the above, do the following:
  SLAT_arr=DEG2RAD(DEC_arr)
  SLON_arr=deg2RAD(LONGITUDE)

;******************FIND LAT AND LON OF SUB-SATELITE POINT**************
;---this will need to be redone in the Fortran, and a new array put in
;---the maf! The sub solar point is corrected here in IDL
  DZA=MAF.DZA
  if off_earth(0) ne -1 then DZA(off_earth)=400.
  VAL=MIN(DZA)
  ZZZ=WHERE(DZA EQ VAL)
  DLON=(LON(ZZZ))   ;THIS *IS* ROTATED (TO 0-360), AND *IS* IN RADIANS!!
  DLAT=(LAT(ZZZ))
  DLAT=FLOAT(DLAT(0))
  DLON=FLOAT(DLON(0))
;*********SET UP ARRAY TO HOLD CALCULATED AZIMUTH ANGLES*********
;*****AND NEW SOLAR AND SPACECRAFT *longitudinal* ANGLES FOR DEBUGGING*****
  AZIMUTH=LAT
  AZIMUTH(*,*)=0.0
;  ARRNEWSLON=AZIMUTH
;  ARRNEWDLON=AZIMUTH
;**********************BEGIN LOOP OF TRANSFORMS FOR PIXELS*************
;PICK A SINGLE PIXEL BUT SET UP TO DO ALL
  XXX=WHERE(MAF.GLON NE -300.0,SIZER)  ;LON ARRAY NO LONGER HAS VALUES OF -300.0
  PRINT,SIZER
  FOR I=0,SIZER-1 DO BEGIN  
  ZLAT=LAT(xxx(I))
  ZLON=LON(XXX(I))
;---New for arrays of solar lat and lon
  SLAT=SLAT_ARR(XXX(I))
  SLON=SLON_ARR(XXX(I))
;*********************ROTATE GEOGRAPHIC LONGITUDES*************************
;************SUCH THAT THE solar DIRECTION HAS 0 "LONGITUDE"*************** 
;-----THIS IS IN EFFECT THE FIRST EULER ROTATION!!!. CARTESIAN COORDS ARE NOT
;-----NECESSARY HERE. It actually is only part of the first rotation.
;LLL=WHERE(LON LT 0.0)
;NEWLON(LLL)=NEWLON(LLL) + 2.0 * !PI
  VARDLON=DLON-sLON                                   ; A VARIABLE NEW DLON
  IF VARDLON LT 0.0 THEN VARDLON=VARDLON + 2.0 * !PI
  VARZLON=ZLON-sLON                                   ; A VARIABLE NEW ZLON
  IF VARZLON LT 0.0 THEN VARZLON=VARZLON + 2.0 * !PI
  VARSLON=SLON-sLON                                   ; 0.0
;the above section worked pretty nicely...
;************************CREATE CARTESIAN COORDINATES**********************
  DX=0.0 & DY=0.0 & DZ=0.0
  SX=0.0 & SY=0.0 & SZ=0.0
  ZX=0.0 & ZY=0.0 & ZZ=0.0
  GEO2CART,DLAT,VARDLON,DX,DY,DZ
  GEO2CART,SLAT,VARSLON,SX,SY,SZ
  GEO2CART,ZLAT,VARZLON,ZX,ZY,ZZ
  svec=[sx,sy,sz]
  dvec=[dx,dy,dz]
  zvec=[zx,zy,zz]
;************************BEGIN FIRST ROTATION*********************************

  PHIROT,news,newd,newz,svec,dvec,zvec

;******************************BEGIN 2ND ROTATION!!!**************************
;***********AS WRITTEN THIS IS A ROTATION ABOUT THE Y AXIS IN ORDER TO
;***COORDINATE THE ZENITH VECTOR AND THE NORTH POLE. THE SYSTEM OF VECTORS
;********IS ROTATED *UP* SO THE ZENITHAL VECTOR IS NOW IN THE POLE 
;****IF THE ZENITHAL VECTOR IS CORRECTLY POSITIONED ABOVE, IT WILL NOT HAVE A
;***Y-AXIS COMPONENT TO BEGIN WITH. THE X COMPONENT WILL BE ELIMINATED HERE.!!!

  THETAROT,NEWS,NEWd,NEWZ,NEWS2,NEWD2,NEWZ2,ZLAT

  newSLAT=0.0   &   newSLON=0.0  &  newDLAT=0.0   &   newDLON=0.0

  CART2GEO,newSLAT,newSLON,NEWS2(0),NEWS2(1),NEWS2(2)
  CART2GEO,newDLAT,newDLON,NEWD2(0),NEWD2(1),NEWD2(2)
  AZIMUTH(XXX(I))=ABS(NEWDLON-NEWSLON)
  IF ABS(NEWDLON-NEWSLON) GT 180.0 THEN BEGIN
  DIFF=ABS(NEWDLON-NEWSLON)-180.0
  AZIMUTH(XXX(I))=180.0-DIFF
  ENDIF

  ENDFOR
;***********************SAVE THE AZIMUTH ANGLES***********************
  azimuth=fix(azimuth)                               ;save memory!!! 
  aaa=extension
  if aaa eq 'IDL' or aaa eq 'idl' then bbb='.azib'
  if aaa eq 'ID2' or aaa eq 'id2' then bbb='.az2b'
  if aaa eq 'ID3' or aaa eq 'id3' then bbb='.az3b'
  if aaa eq 'ID4' or aaa eq 'id4' then bbb='.az4b'

  SAVE,FILENAME=STRMID(MAF.NAME,0,15) + bbb ,AZIMUTH
;*********************************************************************
ENDFOR
CLOSE,2

END
