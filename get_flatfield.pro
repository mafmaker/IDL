;
; The following procedure is required to do cdf_epoch properly
;
;---------------------------------------------------------------------
; NAME:
;       YDN2MD
; PURPOSE:
;       Convert from year and day number of year to month and day of month.
; CATEGORY:
; CALLING SEQUENCE:
;       ydn2md,yr,dy,m,d
; INPUTS:
;       yr = year (like 1988).               in
;       dy = day number in year (like 310).  in
; KEYWORD PARAMETERS:
; OUTPUTS:
;       m = month number (like 11 = Nov).    out
;       d = day of month (like 5).           out
; COMMON BLOCKS:
; NOTES:
;       Note: On error returns m = d = -1.
; MODIFICATION HISTORY:
;       R. Sterner 20 June, 1985 (for budget workspace).
;       Johns Hopkins University Applied Physics Laboratory.
;       RES 18 Sep, 1989 --- converted to SUN
;       TJI 13 Jul, 2000 --- Y2K compliant
;       TJI 17 Jan, 2002 --- accepts vectors
; Copyright (C) 1985, Johns Hopkins University/Applied Physics Laboratory
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.  Other limitations apply as described in the file disclaimer.txt.
;-
;-------------------------------------------------------------
 
        PRO YDN2MD,YR,DY,M,D, help=hlp
 
        IF (N_PARAMS(0) LT 4) or keyword_set(hlp) THEN BEGIN
          PRINT,' Convert from year and day number of year to month '+$
            'and day of month.'
          PRINT,' ydn2md,yr,dy,m,d'
          PRINT,'   yr = year (like 1988).               in'
          PRINT,'   dy = day number in year (like 310).  in'
          PRINT,'   m = month number (like 11 = Nov).    out'
          PRINT,'   d = day of month (like 5).           out'
          PRINT,' Note: On error returns m = d = -1.'
          RETURN
        ENDIF
 

 
        ; Correct YDAYS for leap-year.
	sizer=size(yr)
        if sizer(0) gt 0 then begin
          jtop=sizer(1)
	  m=intarr(jtop)
 	  d=intarr(jtop)
	endif else jtop = 1

	for j=0,jtop-1 do begin
;	print,j
        ; Days before start of each month.
          YDAYS = [0,31,59,90,120,151,181,212,243,273,304,334,366]
	
	  yr_=yr(j)
	  dy_=dy(j)
          IF (((YR_ MOD 4) EQ 0) AND ((YR_ MOD 100) NE 0)) $
            OR ((YR_ MOD 400) EQ 0) or ((YR_ MOD 1000) eq 0) $
                 THEN YDAYS(2) = YDAYS(2:*) + 1
 
          FOR I = 1, 12 DO BEGIN
            IF DY_ LE YDAYS(I) THEN GOTO, NEXT
          ENDFOR
  
          PRINT,' ydn2md: error in day number.'
          M = -1
          D = -1
          RETURN
 
  NEXT:   
	  
	  if jtop eq 1 then begin
	    M = I
            D = DY_ - YDAYS(M-1)
	  endif else begin
	    M(j)=i
	    D(j)=dy_ - ydays(M(j)-1)
	  endelse
        endfor
        RETURN


        END

;-------------------------------------------------------------------
;
; Program : get_flatfield.pro
; Author  : Thomas Immel
;
; new proggie that will return a properly sized flatfield
; given year and date, since the flatfield seems to change
; all the time, whether or not the field of view gets tweaked.
;
; INPUTS
;
;  Year - 4 or more digits please
;  Day - day of year
;  inst - 0 - wic
;         1 - wic low res   ;never happens.
;	  2 - si13
;	  3 - si12
; 
;   attention : In FUVIEW, 0=wic, 1=s12, 2=s13
;
;  uses flatfields in si_flatfield2.idl where the variables restored here 
;  are the string arrays yearlist and daylist, as well as flatfields.
;
;  proper application of flatfield is newimage=flatfield * image
;
;  New version! Have to use cdf_epoch to do times. The thing I had
;  devised is just not so good.
;  
;  5-23-02, in order to stop messing with different versions for
;  fuview (which uses a different numbering scheme and directory
;  structure), add an fuview flag, which will use fuview indexing for
;  the different instruments


function get_flatfield,year,day,inst, fuview = fuview




if keyword_set(fuview) gt 0 then begin

  if inst eq 0 then $
    restore,'$FUVIEW_HOME/support/wic_flatfield_dbase.idl'
  if inst eq 2 then $
    restore,'$FUVIEW_HOME/support/si_flatfield_dbase.idl'
  if inst eq 1 then $
    restore,'$FUVIEW_HOME/support/si12_flatfield_dbase.idl'


endif else begin

  if inst lt 0 or inst gt 3 or inst eq 1 then begin
    print,'You did not select a proper instrument for flatfielding'
    print,'Flatfield set to 0'
    flatfield=0
  endif

  if inst eq 0 then $
    restore,'$FUV_HOME/flatfield/wic_flatfield_dbase.idl'
  if inst eq 2 then $
    restore,'$FUV_HOME/flatfield/si_flatfield_dbase.idl'
  if inst eq 3 then $
    restore,'$FUV_HOME/flatfield/si12_flatfield_dbase.idl'

  if inst eq 0 then $
    print,'WIC flatfield requested'
  if inst eq 2 then $
    print,'SI-13 flatfield requested'
  if inst eq 3 then $
    print,'SI-12 flatfield requested'

endelse


;  yr=long(year)
;  dy=long(day)
;  time=yr* 1000 + dy
  ydn2md,year,day,month,dom
  cdf_epoch,imgtime,year,month,dom,/compute
  ydn2md,yearlist,daylist,monthlist,domlist

;--- My code accept arrays, why can't cdf_epoch accept arrays. LAME
  sizer=size(yearlist)
  listtime=dblarr(sizer(1))
  for i=0,sizer(1)-1 do begin
    cdf_epoch,spare,yearlist(i),monthlist(i),domlist(i),/compute
    listtime(i)=spare
  endfor

;  yearlist=long(yearlist)
;  daylist=long(daylist)
;  list=yearlist * 1000 + daylist


;  daydiff=abs(time - list)	;abs would be nice, but since the 
				;antenna flew off, you really want
				;a negative number here, check for
				;that first
  daydiff=sqrt((imgtime-listtime)^2)
				;if the day is before 278, always grab the
				;flatfield before 278. Otherwise, always
				;go forward. That will do it.

;  print,daydiff;,list

  wboom=where(listtime lt 6.3137836800e+13)	;the CDF epoch for day 278, 2000
  woboom=where(listtime ge 6.3137836800e+13)

  if imgtime lt 6.3137836800e+13 then begin
	thing=where(daydiff(wboom) eq min(daydiff(wboom))) 
	newdays=wboom
  endif else begin
	thing=where(daydiff(woboom) eq min(daydiff(woboom)))
        newdays=woboom
  endelse

  print,thing(0)



;--- day 278, 2000 was boom loss. Deal with that!

  print,yearlist(newdays(thing(0))), daylist(newdays(thing(0))), $
	'Would use this flatfield'

  flatfield=reform(flatfields(newdays(thing(0)),*))
  fsize=size(flatfield) & xsize=fsize(1)
  thing=fltarr(xsize) & thing(*)=1	;recycle thing
  flatfield=thing#reform(flatfield)

;  alpha_angle=0
  if imgtime gt 6.3137836800e+13 then begin
	alpha_angle=(-1.85)
    	flatfield=rot(flatfield,alpha_angle,/interp)
	flatfield=shift(flatfield,0,2) ;;;this shift works for wic, too
  endif  


;--- if si 12 just ignore the above calculation and do the following
;--- (as soon as I have a s12 background and low-alt dbase, it'll be similar)
;  if inst eq 3 then restore,'$FUV_HOME/flatfield/flat_s12_2000_255_mod.sav'
;
;endif else begin
;  restore,'$FUV_HOME/flatfield/wic_flatfield.idl'
;  flatfield=flat_arr
;endelse

;  stop

;print,daydiff
return,flatfield

end
