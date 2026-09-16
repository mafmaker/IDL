PRO HPRECESS, HDR, YEARF                                      
;+
; NAME:
;	HPRECESS
; PURPOSE:
;	Precess the astrometry in a FITS header to a new equinox
;
; CALLING SEQUENCE:
;	HPRECESS, HDR, [ yearf ]      
;
; INPUT-OUTPUT:
;	HDR - FITS Header, must contain the CRVAL astrometry keywords,
;		and either an EPOCH or EQUINOX keyword.
;		HDR will be modified to contain the precessed astrometry
;
; OPTIONAL INPUT:
;	YEARF - Scalar, giving the year of the new (Final) equinox.
;		If not supplied, user will be prompted for this value.
;
; METHOD:
;	The CRVAL and CD (or CROTA) keywords are extracted from the header 
;	and precessed to the new equinox.  The EPOCH or EQUINOX keyword in 
;	the header is  updated.  A HISTORY record is added
;
; RESTRICTIONS:
;	The FK5 reference frame is assumed for both equinoxes.
;
; PROCEDURES USED:
;	ZPARCHECK, GET_EQUINOX(), EXTAST, SXADDPAR, SXADDHIST, PRECESS,
;	PRECESS_CD, PUTAST
; REVISION HISTORY:                                               
;	Written  W. Landsman        STX              July, 1988
;	CD matrix precessed -                        February, 1989
;	Update EQUINOX keyword when CROTA2 present   November, 1992
;	Recognize a GSSS header                      June, 1994
;  Additional Noparams value recognize for storing CDs.  RSH, 6 Apr 95
;	Converted to IDL V5.0   W. Landsman   September 1997
;-     
 On_error, 2   

 if N_params() EQ 0 then begin       
 	print,'Syntax - HPRECESS, hdr, [ yearf]'
        return   
 endif else zparcheck, 'HPRECESS', hdr, 1, 7, 1, 'FITS Header Array'

 yeari = GET_EQUINOX( hdr, code)    ;YEAR of Initial equinox
 if code EQ -1 then $     
       message,'Header does not contain EPOCH or EQUINOX keyword'

 if N_params() LT 2 then begin 
   print, 'HPRECESS: Astrometry in supplied header is in equinox ', $
   strtrim(yeari,2)      
   read, 'Enter year of new equinox: ',yearf 
 endif                                             

 if yeari EQ yearf then $                                           
    message,'Astrometry in header is already in Equinox ' + strtrim(YEARF,2)

 extast, hdr, astr, noparams        ;Extract astrometry from header

 if noparams EQ -1 THEN $
    message,'FITS Header does not contain CRVAL keywords'
	
 if strmid(astr.ctype[0],5,3) EQ 'GSS' then begin
        gsss_stdast, hdr
	extast, hdr, astr, noparams
 endif
	
 crval = astr.crval
 a = crval[0] & d = crval[1]
 cd = astr.cd
 precess, a, d, yeari, yearf              ;Precess the CRVAL coordinates
 precess_cd, cd, yeari, yearf, crval,[ a, d]    ;Precess the CD matrix

 sxaddpar, hdr, 'CRVAL1', double(a)             ;Update CRVAL values
 sxaddpar, hdr, 'CRVAL2', double(d)    

 if (noparams EQ 0) or (noparams EQ 2) then $
       putast, hdr, cd, EQUINOX = float(yearf)    $       ;Update CD values
 else begin
       getrot, hdr, ROT                               ;or CROTA2 value
       sxaddpar,hdr, 'EQUINOX', yearf, ' Equinox of Ref. Coord.', 'HISTORY'
       sxaddpar, hdr, 'CROTA2', rot
 endelse        

 sxaddhist, 'HPRECESS: ' + STRMID(systime(),4,20) +  $ 
   ' Astrometry Precessed From Year' + string(form='(f7.1)',float(yeari)),hdr
 message, 'Header astrometry has been precessed to ' + strtrim(yearf,2),/INF

 return
 end                                                        
