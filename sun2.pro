PRO SUN2,MAF,GST,SLON,RA_arr,DEC_arr

;PROGRAM TO CALCULATE GREENWICH MEAN SIDEREAL TIME(GST) AND POSITION OF SUN
;IN GEOCENTRIC INERTIAL COORDINATES GIVEN YEAR, DAY AND UT:

; ---Sun Version 2 : SUN2.pro
; ---Calculates solar positions for an array of UT
; ---Should flag data with -1 long integers where calculation is not needed!
; ---Or since the whole maf is sent, can do it for all points on the earth here

YEAR=FIX(STRMID(MAF.NAME,0,2)) + 1900
DAY=FIX(STRMID(MAF.NAME,2,3))
HOUR=FIX(STRMID(MAF.NAME,5,2))
MIN=FIX(STRMID(MAF.NAME,7,2))
SEC=FIX(STRMID(MAF.NAME,9,2))
;UTSEC=3600.* HOUR + 60. * MIN + SEC

utsec_arr=maf.ut/1000           ;array of seconds UT for every pixel
on_earth=where(maf.sza ne -1)
utsec=utsec_arr(on_earth)       ;this is now just a long array

pi=double(!pi)

FDAY=UTSEC/864E02        ;will be a large array
fday=double(fday)        ;make double precision
DJ=365. *long(YEAR-1900) + (YEAR-1901)/4 + DAY + FDAY - .5
DJ=double(dj)            ;make double precision
T=DJ/36525.
VL=((DOUBLE(279.696678) + DOUBLE(0.9856473354) * DJ) MOD 360.0)
GST=((DOUBLE(279.690983) + DOUBLE(0.9856473354)*DJ +360* FDAY + 180) MOD 360.0)
G=((DOUBLE(358.475845) + DOUBLE(0.985600267*DJ)) MOD 360.)
SLON= VL + (1.91946 - 0.004789 * T) * SIN(G/180. * PI) + 0.020094 $
      * SIN(2.0*G * PI/180.)
OBLIQ = (23.45229 - 0.0130125 * T)
SLP= ( SLON- 0.005686)
SINE= SIN(OBLIQ * PI/180.) * SIN(SLP * PI/180.)
COSINE= (1.0 -SINE^2)^.5
DEC= ATAN(SINE/COSINE) * 180/!PI
COTOB = COS(OBLIQ*PI/180.)/SIN(OBLIQ*PI/180.)
RA = 180. -( ATAN( COTOB*SINE/COSINE,   $
         -1*COS(SLP*PI/180.)/COSINE)  *180./PI)
;---To this point, arrays are 1-D and calculated for all points
;---rearrange arrays to 2-D for use in azimuth code

slon_arr=fltarr(maf.nlines,150)
ra_arr=fltarr(maf.nlines,150)
dec_arr=fltarr(maf.nlines,150)
slon_arr(on_earth)=slon
ra_arr(on_earth)=ra
dec_arr(on_earth)=dec

;---That should do it


END
