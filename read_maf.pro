
;program read_maf.pro     ;the successor to MAKEIDLII.pro


PRO MONTHDAY,YEAR,DAYOFYR,MONTH,DAY
; Given year and dayofyr, returns month and day

 NDAYS=[1,32,60,91,121,152,182,213,244,274,305,335]
LDAYS=[1,32,61,92,122,153,183,214,245,275,306,336]
IYEAR=1900+YEAR
REMAIN=IYEAR-4*FIX(FLOAT(IYEAR)/4.)
IF REMAIN EQ 0 THEN MDAYS=LDAYS ELSE MDAYS=NDAYS
FOR MO=11,0,-1 DO BEGIN
  IF DAYOFYR GE MDAYS(MO) THEN BEGIN
    MONTH=MO+1
    DAY=DAYOFYR-MDAYS(MO)+1
    RETURN
  ENDIF
ENDFOR
RETURN
END
;******************************************************************************8
FUNCTION DAYOFYR,MONTH,DAY,YEAR
NDAYS=[1,32,60,91,121,152,182,213,244,274,305,335]
LDAYS=[1,32,61,92,122,153,183,214,245,275,306,336]
IYEAR=1900+YEAR
REMAIN=IYEAR-4*FIX(FLOAT(IYEAR)/4.)
IF REMAIN EQ 0 THEN RETURN,LDAYS(MONTH-1)+DAY-1 ELSE RETURN,NDAYS(MONTH-1)+DAY-1
END
;***************************************************************************

FUNCTION LENOFYR,YEAR
IYEAR=1900+YEAR
REMAIN=IYEAR-4*FIX(FLOAT(IYEAR)/4.)
IF REMAIN EQ 0 THEN RETURN,366 ELSE RETURN,365
END
;***************************************************************************
FUNCTION  RECNUM7886,MONTH,DAY,YEAR
; Given year (78-86) and month (jan=1) and day of month returns the number of
; days from 1/1/78, which will return as zero.  This is the first record in the
; file AEMIN7886.DAT.

IF YEAR LT 78 THEN BEGIN
  PRINT,'Year given to RECNUM7886 is before 78.'
  RETURN,0
ENDIF

IF YEAR EQ 78 THEN RETURN,DAYOFYR(MONTH,DAY,YEAR)-1

DAYNUM=0
FOR JYR=78,YEAR-1 DO DAYNUM=DAYNUM+LENOFYR(JYR)
DAYNUM=DAYNUM+DAYOFYR(MONTH,DAY,YEAR)
RETURN,DAYNUM-1
END
;*****************************************************************************
PRO AEINDAY,MONTH,DAY,YEAR,AE
; Given the date (for years 78 to 86), returns 1-minute AE values for the
; whole day, as an intarr(1440).
GET_LUN,UNIT
OPENR,UNIT,'mydisk:[spacelib.ae]AEMIN7886.DAT',3120,/FIXED

AEREC=ASSOC(UNIT,INTARR(65,24))
; First record is 1,1,78

RECNUM=RECNUM7886(MONTH,DAY,YEAR)
AEDATA=AEREC(RECNUM)

AE=INTARR(1440)
IF YEAR NE AEDATA(0,0) OR MONTH NE AEDATA(1,0) OR DAY NE AEDATA(2,0) THEN BEGIN
  PRINT,'Error in Procedure AEINDDAY'
; Return with all zeros
  AE=INTARR(1440)
ENDIF ELSE BEGIN
  for HOUR=0,23 do begin
    i=60*HOUR
    AE(i)=AEDATA(4:63,HOUR)
  endfor
ENDELSE

CLOSE,UNIT
FREE_LUN,UNIT
RETURN
END
;***************************************************************************
!path = 'Disk$user1:[immel.idl],' + !path
;restore,'modelcoef.idl'              ;not going to do a model!
;restore,'modelcoef_136.idl'          ;"   "   "   "
dealt=0.0
dumname=' '
sflux=0.0

;get files
close,3
openr,3,'read_maf.dat'
readf,3,format='(i3)',xxxx
numims=fix(xxxx)
imfile=strarr(numims)
savfile=strarr(numims)
        for j=0,numims-1 do begin
           readf,3,format='(a25)',dumname
           imfile(j)=dumname
        endfor

;enter # of images
close,3

;create & save MAF structure for each file
for i=0,numims-1 do begin

        imname=imfile(i)
picker=strmid(imname,16,3)                            ;to pick between alt=200
                                                      ;and alt=400 files

;************* 'b' in extension indicates processing by read_maf.pro
;************** as opposed to makeidlII.pro!!!!!!!!!!!!!!!!!!!!!!!!

if picker eq 'dsk' or picker eq 'DSK' then begin
;  mod_arr=
  savFILE(i)=strmid(IMNAME,0,15) + '.IDLb'             ;alt = 200 km
  print,imname
  print,savfile(i)

endif
if picker eq '400' then begin
;
  savFILE(i)=strmid(IMNAME,0,15) + '.ID2b'             ;alt = 400 km.
  print,imname
  print,savfile(i)

endif
if picker eq '600' then begin                         ;alt = 600 km.
;
  savFILE(i)=strmid(IMNAME,0,15) + '.ID3b'
  print,imname
  print,savfile(i)

endif
if picker eq '800' then begin                         ;alt = 800 km.
;
  savFILE(i)=strmid(IMNAME,0,15) + '.ID4b'
  print,imname
  print,savfile(i)

endif
if picker eq '500' then begin                         ;alt = 800 km.
;
  savFILE(i)=strmid(IMNAME,0,15) + '.ID5b'
  print,imname
  print,savfile(i)

endif

;*******************************************************************************

;with the new images, counts are not set to zero out of the LDS angle!
;lately, images have been cut off just at 66 degrees DZA!
;with getdsk version 3.2, the look angles will be provided, as will the
;limb disk separation angle

;*******************************************************************************
;GET AE DATA

;
;
;
;       Extract the year,day,and UT from the start of image strings

        year=fix(strmid(IMNAME,0,2))
        dayofyr=fix(strmid(imNAME,2,3))
        shour=fix(strmid(IMNAME,5,2))
        sminute=fix(strmid(IMNAME,7,2))
        UTLB=strmid(IMNAME,5,2)+':'+strmid(IMNAME,7,2)
        YEARLB='19'+strmid(imNAME,0,2)
;       Convert UT to linear time in hours (6min=.1hr)
        stmin=sminute/60.

        stime=shour+stmin


;       Get the AE data (minute samples)
        call_procedure,'MONTHDAY',YEAR,DAYOFYR,MONTH,DAY
	print,month,day,year
        call_procedure,'AEINDAY',MONTH,DAY,YEAR,AE

;****************define variables to be read from data file

rlines=lonarr(1) 
  dealt=fltarr(1)     ;will not be resized!!!
  mirror=lonarr(1)    ;will not be resized!!!
  ldsang=fltarr(1)
rpixfix=intarr(120)
rsza=fltarr(120,150)
rdza=fltarr(120,150)
rucount=intarr(120,150)
rutmsec=lonarr(120,150)
rglat=fltarr(120,150)
rglon=fltarr(120,150)
rgmlat=fltarr(120,150)
rgmlon=fltarr(120,150)
rgmlt=fltarr(120,150)
rlkang=fltarr(120,150)

close,10
openu,10,imname,/segmented

readu,10,rlines
readu,10,dealt
readu,10,mirror
readu,10,ldsang
readu,10,rpixfix
readu,10,rsza
readu,10,rdza
readu,10,rucount
readu,10,rutmsec
readu,10,rglat
readu,10,rglon
readu,10,rgmlat
readu,10,rgmlon
readu,10,rgmlt
readu,10,rlkang

lines=rlines(0)
pixfix=temporary(rpixfix(0:lines-1))   &  rpixfix=0 
sza=temporary(rsza(0:lines-1,*))       &  rsza=0
dza=temporary(rdza(0:lines-1,*))       &  rdza=0
ucount=temporary(rucount(0:lines-1,*)) &  rucount=0
utmsec=temporary(rutmsec(0:lines-1,*)) &  rutmsec=0
glat=temporary(rglat(0:lines-1,*))     &  rglat=0
glon=temporary(rglon(0:lines-1,*))     &  rglon=0
gmlat=temporary(rgmlat(0:lines-1,*))   &  rgmlat=0
gmlon=temporary(rgmlon(0:lines-1,*))   &  rgmlon=0
gmlt=temporary(rgmlt(0:lines-1,*))     &  rgmlt=0
lkang=temporary(rlkang(0:lines-1,*))   &  rlkang=0
;---AND---
model=fltarr(lines,150)
model2=fltarr(lines,150)


;the criteria below must include the look angles!
;it must also simply define in the model array the section within
;which the model may be applied, with values greater than zero

;   if (dza ge 0.0) and (dza lt 66.) and (sza ge 0.0) and (sza lt 106)$
;                  and (counts ge 0) then begin
;                model(k,j)=sza*sza*(dza*slcd+sccd)+$
;                           sza*(dza*llcd+lccd)+$
;                           dza*clcd+cccd
;                   if (model(k,j) lt 0.0) then model(k,j)=0.0
;                mod_136(k,j)=sza*sza*(dza*slcd_136+sccd_136)+$
;                           sza*(dza*llcd_136+lccd_136)+$
;                           dza*clcd_136+cccd_136
;                   if (mod_136(k,j) lt 0.0) then mod_136(k,j)=0.0
;                endif

	for k=0,lines-1 do begin
	ucount(k,*)=shift(ucount(k,*),pixfix(k))
	model(k,*)=shift(model(k,*),pixfix(k))		
	gmlt(k,*)=shift(gmlt(k,*),pixfix(k))
	gmlon(k,*)=shift(gmlon(k,*),pixfix(k))
	gmlat(k,*)=shift(gmlat(k,*),pixfix(k))
	glat(k,*)=shift(glat(k,*),pixfix(k))
	glon(k,*)=shift(glon(k,*),pixfix(k))
	utmsec(k,*)=shift(utmsec(k,*),pixfix(k))
	SZA(K,*)=SHIFT(SZA(K,*),PIXFIX(K))
	DZA(K,*)=SHIFT(DZA(K,*),PIXFIX(K))
	lkang(k,*)=shift(lkang(k,*),pixfix(k))
endfor
	for k=0,lines-1 do begin
		for j=0,149 do begin
		   if (dza(k,j) ge 0.0) and (dza(k,j) lt 66.) and $
                   (sza(k,j) ge 0.0) and (sza(k,j) lt 106) then model(k,j)=1

		   if (lkang(k,j) lt ldsang(0)) and $
                   (sza(k,j) ge 0.0) and (sza(k,j) lt 106) then model2(k,j)=1
		endfor
	endfor
        if (mirror(0) gt 0) then begin
                ucount=rotate(ucount,2)
                model=rotate(model,2)
		model2=rotate(model2,2)
                glat=rotate(glat,2)
                glon=rotate(glon,2)
                utmsec=rotate(utmsec,2)
                gmlat=rotate(gmlat,2)
                gmlong=rotate(gmlon,2)
                gmlt=rotate(gmlt,2)
                SZA=ROTATE(SZA,2)
                DZA=ROTATE(DZA,2)
		lkang=rotate(lkang,2)
        endif
       if (mirror(0) lt 0) then begin
               ucount=rotate(ucount,7)
                model=rotate(model,7)
		model2=rotate(model2,7)
                glat=rotate(glat,7)
                glon=rotate(glon,7)
                utmsec=rotate(utmsec,7)
                gmlat=rotate(gmlat,7)
                gmlong=rotate(gmlon,7)
                gmlt=rotate(gmlt,7)
                SZA=ROTATE(SZA,7)
                DZA=ROTATE(DZA,7)
                lkang=rotate(lkang,7)
        endif
maf={name:' ',Img:fltarr(lines,150),bckgnd:fltarr(lines,150),$
        aev:intarr(1440),flux:0.0,nlines:0,glat:fltarr(lines,150),$
        glon:fltarr(lines,150),ut:LONARR(lines,150),mlt:intarr(lines,150),$
        mlat:FLtarr(lines,150),mlon:FLtarr(lines,150),bck136:fltarr(lines,150),$
        sza:fltarr(lines,150),dza:fltarr(lines,150),alt:0.0, $
        lkang:fltarr(lines,150),lds:0.0 }
        maf.name=imname
        maf.img=UCOUNT
        maf.alt=dealt(0)
        maf.bckgnd=model
        maf.bck136=MODEL2
        maf.aev=ae
        maf.flux=sflux                   ;WHAT IS THE SOURCE?!
        maf.nlines=lines(0)
        maf.glat=glat
        maf.glon=glon
        maf.ut=utMSEC
        maf.mlon=GMLON
        maf.mlat=GMLAT
        maf.mlt=GMLT
        maf.sza=sza       ;EXCLUSIVE TO MAKEidlII
        maf.dza=dza       ;EXCLUSIVE TO MAKEidlII
	maf.lkang=lkang
	maf.lds=ldsang(0)
	print,savfile(i)
        save,maf,file=savfile(i)
;        maf=0               ;added 12-1-94   TJI
endfor

CLOSE,10

end

