;
;	This IDL program plots AE vsTime for the variables input
; 
;       Program:	PLOTAE.PRO
;       Version:	1.0
;       Date   :	1/25/93	
;
           
;**************************************************************************
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
;************************************************************************8
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
;************************************************************************
PRO AEINDAY,MONTH,DAY,YEAR,AE
; Given the date (for years 78 to 86), returns 1-minute AE values for the
; whole day, as an intarr(1440).
GET_LUN,UNIT
OPENR,UNIT,'DISK$SPACE:[SPACELIB.AE]AEMIN7886.DAT',3120,/FIXED

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
	year=0
	dayofyr=0
	print,' Enter the year (e.g. 81=1981)'
	read,year
	print,year
	print,''
	print,' Enterthe day of the year(jan. 1 = 1)'
	read,dayofyr
	print,dayofyr
	print,''

	call_procedure,MONTHDAY,YEAR,DAYOFYR,MONTH,DAY
;	call_procedure,AEINDAY,MONTH,DAY,YEAR,AE
;        print,month,day
	end
