;$Author$
;$Date$
;$Header$
;$Locker$
;$Revision$
FUNCTION getdirs
IF (!VERSION.OS EQ "vms") THEN BEGIN ; ".dir" extension
  retval = ['[-]']
  results = findfile("*.DIR") 
  IF(KEYWORD_SET(results)) THEN BEGIN
    endpath = STRPOS(results(0), "]", 0) + 1
    results = strmid(results, endpath, 100)
    dirs = WHERE(STRPOS(results, ".DIR", 0) NE -1, found)
    IF (found GT 0) THEN BEGIN
      results = results(dirs)
      retval = [retval, results]
    ENDIF
  ENDIF
ENDIF ELSE IF !VERSION.OS EQ "windows" THEN BEGIN
  message,"Unsupported on this platform"
ENDIF ELSE BEGIN
  retval = ['../']
  SPAWN, "ls -laL", results ,/sh   ;use /sh and added -a switch to get .* dirs
  numfound = N_ELEMENTS(results)
  IF(KEYWORD_SET(results)) THEN BEGIN ;extension of ".dir"
    firsts = STRUPCASE(STRMID(results, 0, 1))
    dirs = (where(firsts EQ "D", found))
    IF (found GT 0) THEN BEGIN
      results = results(dirs)
      spaceinds = WHERE(BYTE(results(0)) EQ 32)
      spaceindex = spaceinds(N_ELEMENTS(spaceinds)-1)
      retval = [retval, STRMID(results, spaceindex + 1, 100)]
      ; get rid of "." and ".." that ls -laL picks up
      retval = retval(WHERE( (retval ne '.')and(retval ne '..')) )
    ENDIF
  ENDIF
ENDELSE
RETURN, retval
END


