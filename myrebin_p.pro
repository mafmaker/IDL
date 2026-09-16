pro myrebin_p,r_arr,w_arr,binsize0,binsize1,r_bin,w_bin
;PROGRAM MYREBIN.PRO TO REBIN THE MODEL INTO BINS OF THE SIZE OF MY CHOOSING
;   Location 		: disk$user1:[immel.alt_400]
;   Creation date     	: 04-09-95                    
;   Revision History	: 06-10-98 'Procedurized' 
;   			  
;   Notes               : 12 years later, my first actual, useful
;   comment on this code. DO NOT REBIN WITH ANYTHING OTHER THAN
;   INTEGERS. I REALLY THINK THIS DOES NOT WORK IN THAT CASE!!!
;
;
;thinger='onemodel2.id2'    ;stored here will be szamax!
;base=strmid(thinger,0,9)
;RESTORE,thinger   ;altitude = 400km
MODCOUNTS=r_arr
  help,r_arr
ONEWT=w_arr
SZASIZE=binsize0 & DZASIZE=binsize1            ;are part of onemodel2.id2,but need new values!

arr_size=size(r_arr)

;print,format='("Enter Solar Zenith Angle bin size: ",$)'
;read,szasize
;print,format='("Enter Spacecraft Zenith Angle bin size: ",$)'
;read,dzasize

szamax=arr_size(1)
dzamax=arr_size(2)
print,dzasize

BINCOUNT=FLTARR((szamax/SZASIZE) + 1,(dzamax/DZASIZE) + 1)  ;PLUS ONE TO GET ZERO VALUES TOO

;print,dzasize
;print,66/dzasize
;print,66/dzasize + 1

BINCOUNT(*,*)=0
BINSAMP=BINCOUNT
BINSAMP(*,*)=-1

FOR I=0,szamax-1 DO BEGIN
  FOR J=0,dzamax-1 DO BEGIN
      COUNTS=MODCOUNTS(I,J)
      SAMPLES=ONEWT(I,J)
      IF SAMPLES GT 0 THEN BEGIN
        if BINSAMP(I/SZASIZE,J/DZASIZE) eq -1 then begin
          BINSAMP(I/SZASIZE,J/DZASIZE)=SAMPLES
          BINCOUNT(I/SZASIZE,J/DZASIZE)=COUNTS
        endif else begin
          BINSAMP(I/SZASIZE,J/DZASIZE)=BINSAMP(I/SZASIZE,J/DZASIZE)+SAMPLES
          BINCOUNT(I/SZASIZE,J/DZASIZE)=BINCOUNT(I/SZASIZE,J/DZASIZE)+COUNTS
        endelse
      ENDIF
  ENDFOR
ENDFOR

R_bin=bincount
W_bin=binsamp
;stop

end
