PRO SHIFTLONG,GLONARY,badval=badval
;*****************************************************************
;THIS PROCEDURE CHANGES THE RANGE OF LONGITUDES OF A .DAT FILE FOR A
;DE IMAGE.  VALUES ARE SHIFTED FROM A RANGE OF -180 -- 180 TO A RANGE
;OF 180 -- 540 THEN TO 0--360. ZERO LONGITUDE REMAINS AT GREENWICH.
;
;
;*****************************************************************
  if keyword_set(badval) lt 1 then badval = -300.

  change=where(glonary ne badval,tochange)
  if tochange gt 0 then glonary(change)=glonary(change)+360.0
  fixer=where(glonary gt 360.0)
  if fixer(0) ne -1 then glonary(fixer)=glonary(fixer) - 360.0
  return
END
;*****************************************************************

