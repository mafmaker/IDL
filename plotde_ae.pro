;****************************************************************************
;*                                                                          *
;*       This IDL program plots AE vs Time for the day of the input          *
;*	 DE-1 image. It prompts the user to input the .SAI00 filename       *
;*	 for two images. The first of which is the beginning of the         *
;*	 scanning period, the second corresponding to the last image from   *
;*	 the scanning period. The program assumes the last image is a full  *
;*	 length 12 minute image. The data spans 1978-1987.                  *
;*                                                                          *
;*                                                                          *
;*       Program   :     PLOTDE_AE.PRO                                      *
;*       Version   :     2.1                                                *
;*       Date      :     1/27/93                                            *
;*       Programmer:     Andy Nicholas                                      *
;****************************************************************************

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
;***************************************************************************

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
;***************************************************************************
;***************************************************************************
;        MAIN PROGRAM

;	Create time array & xaxis labels
        aetime=findgen(1440)*24./1440.
	xhours=['00:00','06:00','12:00','18:00','24:00']
        xval=[0.,6.,12.,18.,24.]  

;	Set image0 & image1 as string variables
        image0=' '
	image1=' '
;
;	Read in filenames as 21 character strings	
   print,'Enter the filename of the first image (eg "82005172806_c2f.sai00")'
        readf,0,format='(a21)',image0 ;start image
	
   print,'Enter the filename of the last image (eg "82005213731_c2f.sai00")'
        readf,0,format='(a21)',image1 ; end image
;
;	Extract the year,day,and UT from the start and end image strings	

	year=fix(strmid(image0,0,2))
	dayofyr=fix(strmid(image0,2,3))
	shour=fix(strmid(image0,5,2))
	sminute=fix(strmid(image0,7,2))
	ehour=fix(strmid(image1,5,2))
        eminute=fix(strmid(image1,7,2))

;	Convert UT to linear time in hours (6min=.1hr)     
        stmin=sminute/60.
	endmin=eminute/60.
	stime=shour+stmin
	endtime=ehour+endmin+.2	
	
;	Gert the AE data (minute samples)
        call_procedure,'MONTHDAY',YEAR,DAYOFYR,MONTH,DAY
        call_procedure,'AEINDAY',MONTH,DAY,YEAR,AE
    
;	Plot the data	
	plot,aetime,ae,xtitle='!6UT (Hours)',ytitle='AE (nT)',$
	title='Year/Day '+strmid(image0,0,5),$
	xtickname=xhours,xticks=4,xminor=6,xtickv=xval,ticklen=.03

;	Plot verticle dashed lines at time of imaging start & finish
        plots,[stime,stime],[!y.crange(0),!y.crange(1)],linestyle=2
        plots,[endtime,endtime],[!y.crange(0),!y.crange(1)],linestyle=2
	end
