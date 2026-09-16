pro binstdev,modwt,modtot,modsqr,modaz,modsqraz,szasize,dzasize,azasize,$
           binmodsigma,binmodsmean,binmodsigaz
;Program BINstdev.PRO
;;author:Thomas Immel
;;location:sunriz::disk$user1:[immel.jatp2

;---spare arrays such that the arrays sent will not be adjusted!!!
modwt2=modwt
modtot2=modtot
modsqr2=modsqr
modaz2=modaz
modsqraz2=modsqraz




;This program is written to calculate the standard deviation of the 
;counts sampled in each bin
;variables are as follows
;     modwt : the total # of samples that went into each bin
;     modtot : the total # of counts in each bin
;     modsqr : the sum of the square of each sample of counts in a bin
;     szasize,dzasize : the sizes of the bins in this particular idl file!!!
;     azasize, too!
;;---------------------------NOTES-------------------------------
;11-27-94 : Procedure END_BIN.PRO in [immel.idl] is to be called.
;           This procedure will fill the data bin at high DZA after adding
;           the data to the next lower bin. This will only need to be done to 
;           the *RAW DATA*.
;4-5-95   : This end-bin procedure may have problems where the max DZA
;           has become much smaller, as in the case here with images at 600km 
;
;restore,'azimodelbin.idl' 
;filer='azmodbin_s3d5a30.id2'
;filer='wmodel_subset.idl'
;filer='wmodel_sub172.idlb'
;restore,filer


 !path = 'mydisk:[immel.idl],' + !path

;for multiplier arrays where szasize and dzasize > 1
BINMODSIGMA=fltarr(110/szasize+1,66/dzasize+1,6)
BINMODSIGMA(*,*,*)=0.
binmodsigaz=fltarr(110/szasize+1,66/dzasize+1,6)
binmodsigaz(*,*,*)=0.
;-------------------------------------------------------------------
print,dzasize
if dzasize lt 65 then begin

  END_BIN,MODTOT2                ;COMBINE LAST TWO BINS OF SPACECRAFT ZENITH ANGLE!
  END_BIN,MODWT2                 ;MUST BE DONE ON RAW DATA ONLY!!!!
  END_BIN,MODSQR2                ;MUST BE DONE FOR AZIMUTH ARRAYS AS WELL
  END_BIN,MODAZ2                 ;arrays must not be returned differently!
  END_BIN,MODSQRAZ2

endif
;-------------------------------------------------------------------

BINNED=modtot2/modwt2
avgaz=modaz2/modwt2
;*****THE FOLLOWING SHOULD HANDLE ALL 6 AZIMUTH LEVELS
YYY=WHERE (modWT GT 0,sizer)
print,sizer
;print,modsqr
;--------------
binmodSIGMA(YYY)=((modsqr2(yyy) - (modwt2(yyy) * binned(YYY)^2)) / $
	                  (MODwt2(yyy) - 1))^0.5
binmodSMEAN=binmodsigma/sqrt(modwt2-1)                    
;--------------Now calculate standard deviation of azimuth in each bin!!!
binmodsigaz(YYY)=((modsqraz2(yyy) - (modwt2(yyy) * avgaz(YYY)^2)) / $
                          (MODwt2(yyy) - 1))^0.5
;--------------
END
