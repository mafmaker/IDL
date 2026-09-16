
PRO SUN,year,day,time,GST,SLON,RA,DEC

;PROGRAM TO CALCULATE GREENWICH MEAN SIDEREAL TIME(GST) AND POSITION OF SUN
;IN GEOCENTRIC INERTIAL COORDINATES GIVEN YEAR, DAY AND UT:

;;YEAR=FIX(STRMID(MAF.NAME,0,2)) + 1900
;DAY=FIX(STRMID(MAF.NAME,2,3))
;HOUR=FIX(STRMID(MAF.NAME,5,2))
;MIN=FIX(STRMID(MAF.NAME,7,2))
;SEC=FIX(STRMID(MAF.NAME,9,2))
;UTSEC=3600.* HOUR + 60. * MIN + SEC

utsec=double(time) * 3600.d          ;time is given in decimal hours
thinger=size(time)  ;create array of size of number of data samples
if n_elements(thinger) gt 3 then begin
  ra=dblarr(thinger(1))
  dec=dblarr(thinger(1))
  gst=fltarr(thinger(1))
  count_to=thinger(1)
endif else begin
  ra=dblarr(1)
  dec=dblarr(1)
  gst=dblarr(1)
  count_to=1
endelse

year=double(year)
day=double(day)
pi=(!dpi)
;print,year
for i=0,count_to-1 do begin
  FDAY=UTSEC(i)/864d02

  DJ=365.d *double(YEAR-1900) + (YEAR-1901)/4d + DAY + FDAY - .5d

  T=DJ/36525.d
  VL=((DOUBLE(279.696678) + DOUBLE(0.9856473354) * DJ) MOD 360.0d)
GST(i)=((DOUBLE(279.690983) + DOUBLE(0.9856473354)*DJ +360* FDAY + 180) MOD 360.0d)
  G=((DOUBLE(358.475845) + DOUBLE(0.985600267*DJ)) MOD 360.)
  SLON= VL + (1.91946 - 0.004789 * T) * SIN(G/180. * PI) + 0.020094 $
      * SIN(2.0*G * PI/180.)
  OBLIQ = (23.45229 - 0.0130125 * T)
  SLP= ( SLON- 0.005686)
  SINE= SIN(OBLIQ * PI/180.) * SIN(SLP * PI/180.)
  COSINE= (1.0 -SINE^2)^.5
  DEC(i)= ATAN(SINE(i)/COSINE(i)) * 180/!PI
  COTOB = COS(OBLIQ(i)*PI/180.)/SIN(OBLIQ(i)*PI/180.)
  RA(i) = 180. -( ATAN( COTOB*SINE(i)/COSINE(i),   $
         -1*COS(SLP(i)*PI/180.)/COSINE(i))  *180./PI)
endfor

;help

return
END
;---------------------------------:----------------------------------

;begin main procedure!!!
pro GSE_GSM,BX,BY,BZ,YeaR,DAY,TIME,SDPANG

;stop

;--------------------------------------------------
;ADAPTED FROM GSEGSM.FOR AND BGSM.FOR WRITTEN BY JDC
;
;
;
;
;
;-------------------------------------------------
;DEFINE VARIABLES HERE JUST AS IN CAVETRAN
MX=0. & MY=0. & MZ=0.         ;REAL VARIABLES
MXSE=0. & MYSE=0. & MZSE=0.
JYSE=0. & JZSE=0. & JN=0.
MXO=0.06859                   ;UNIT VECTORS For magnetic dipole
MYO=-0.18602		      ;in what coords??? Fixed body geocentric?
MZO=0.98015
Rad=!radeg                     ;degrees per radian
epx=0.0                        ;more unit vectors, Earth rotation axis
epy=-0.398
epz=0.917

sun,year,day,time,gst,slon,srasn,sdec     ;time in decimal 

;if time gt 16 and time lt 17 then print,'***',gst,slon,srasn,sdec,'***'

;Transform magnetic dipole from GEO to GEI
sgmst=sin(gst/rad)               ;array
cgmst=cos(gst/rad)               ;array
	MX=MXO*CGMST -MYO*SGMST  ;array
	MY=MXO*SGMST -MYO*CGMST  ;array
	MZ=MZO                   ;float

;	print,'jdc dipole gei ',mx,my,mz

;GEI position of sun
	CSRA=COS(SRASN/RAD)     ;array
	SSRA=SIN(SRASN/RAD)     ;array
	CSD= COS(SDEC/RAD)      ;array
	SX=CSD*CSRA             ;array
	SY=CSD*SSRA             ;array
	SZ=SIN(SDEC/RAD)        ;array

;	print,'jdc sun gei ',sx,sy,sz




;GEI position of ecliptic pole, position vector normal to plane of sun
;and ecliptic pole
	TX=EPY*SZ-EPZ*SY        ;array
	TY=EPZ*SX - EPX*SZ      ;
        TZ=EPX*SY - EPY*SX      ;
        TN=(TX*TX+TY*TY+TZ*TZ)^(0.5)  ;should work to give an array
        TX=TX/TN
        TY=TY/TN
        TZ=TZ/TN

;	everything to here is the same between jdc and tsyg


;rotation from GEI to GSE
;
;
;Magnetic Dipole 
        MXSE=MX*SX + MY*SY + MZ*SZ
        MYSE=MX*TX + MY*TY + MZ*TZ
        MZSE=MX*EPX+ MY*EPY+ MZ*EPZ
;construct GSE to GSM rotation
;Magnetic dipole
        JN= SQRT(MYSE*MYSE+MZSE*MZSE)
        JYSE= MZSE/JN
        JZSE=-MYSE/JN
;Angle between sun and dipole axis
  sdpang=acos(mxse)
;transform IMF B(GSE) to IMF B(GSM)
        BYSM=  BY*JYSE + BZ*JZSE
        BZSM= -BY*JZSE + BZ*JYSE
        BY=BYSM
        BZ=BZSM

;stop

return

end