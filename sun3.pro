PRO SUN3,imageinfo,GST,SLON,RA,DEC

;PROGRAM TO CALCULATE GREENWICH MEAN SIDEREAL TIME(GST) AND POSITION OF SUN
;IN GEOCENTRIC INERTIAL COORDINATES GIVEN YEAR, DAY AND UT:
; 10-5-97  --- TJI - added polar filename support
; 6-29-2000 v3 --- TJI now specifically for IMAGE imageinfo structure
; notes: GST is in degrees
;
time=imageinfo(0).time
utsec=time(1)/1000.
year=time(0)/1000
day=time(0) mod 1000
;print,'Sun3.pro - running'
;print,time,utsec,year,day

pi=double(!pi)

FDAY=UTSEC/864E02
fday=double(fday)        ;make double precision
dj=0.
DJ=double(dj)            ;make double precision
DJ=365. *long(YEAR-1900) + (YEAR-1901)/4 + DAY + FDAY - .5
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
END
