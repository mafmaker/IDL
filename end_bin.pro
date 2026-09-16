PRO END_BIN, ARRAY
;Program END_BIN.PRO
;************************************************************
; 	Created : 11-27-94
;	By      : Thomas Immel
;	Location: disk$user1:[immel.idl]
;
;************************************************************
;Notes--- This procedure is written to be called by general programs
;         dealing with half full bins of counts(DZA). The procedure
;         adds all the data to the adjacent bins and then puts -that-
;         data into the last (extra) bin. The data is therefore repeated
;         such that the last bin is expanded to cover more angles!!!!
;------------------------------------------------------------------------
;  Begin Procedure

XXX=SIZE(ARRAY)
IF (FIX(XXX(0)) EQ 2) THEN BEGIN
  WORKER=ARRAY
  WORKER(*,XXX(2)-2) = WORKER(*,XXX(2)-2) + WORKER(*,XXX(2)-1)
  WORKER(*,XXX(2)-1) = WORKER(*,XXX(2)-2)
  ARRAY=WORKER
  PRINT,XXX(2)
  WORKER=0
ENDIF 

IF (FIX(XXX(0)) EQ 3) THEN BEGIN
  WORKER=ARRAY
  FOR I = 0,XXX(3) - 1 DO BEGIN
    PRINT,I
    WORKER(*,XXX(2)-2,I) = WORKER(*,XXX(2)-2,I) + WORKER(*,XXX(2)-1,I)
    WORKER(*,XXX(2)-1,I) = WORKER(*,XXX(2)-2,I)
    ARRAY(*,*,I)=WORKER(*,*,I)
  ENDFOR
ENDIF 

end     ;end procedure
