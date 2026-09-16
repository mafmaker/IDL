pro fits_cd_fix,hdr, REVERSE = reverse
;+
;  NAME:
;	FITS_CD_FIX
;  PURPOSE:
;	Convert from the representation of the CD matrix in a FITS header
;	with an underscore (e.g. CDn_m) to that with all integers (e.g.
;	CD00n00m).    According to the proposed World Coordinate System
;	standard by Griesen and Calabretta, the CD00n00m form is to be
;	preferred and does not include the plate scale, so that CDELT* 
;	keywords are also needed.     The CD1_1 form (used in IRAF) includes 
;	the plate scale (CDELT) factor. 
;
;	Because of past confusion as to which form to use, it will sometimes
;	be necessary to convert from one form to the other.
;
;  CALLING SEQUENCE:
;	FITS_CD_FIX, Hdr, [/REVERSE]
;
;  INPUT-OUTPUT: 
;	HDR - FITS header, 80 x N string array.   If the header does not
;           contain the CDn_m keywords then it is left unmodified.  Other-
;           wise the CDn_m keywords are removed and the CD00n00m keywords
;           inserted (with the same values).
;   
;  OPTIONAL KEYWORD INPUT
;	REVERSE - If this keyword is set and non-zero, then the process is
;		reversed, i.e. CD00n00m keywords are removed from the header
;		and CDn_m keywords are inserted.
;
;  REVISION HISTORY:
;     Written   W. Landsman             Feb 1990
;     Major rewrite                     Feb 1994
;	Converted to IDL V5.0   W. Landsman   September 1997
;-
 On_error,2

 if N_params() LT 1 then begin
	print,'Syntax - FITS_CD_FIX, hdr, [/REVERSE]
	return
 endif

 cd00 = ['CD001001','CD001002','CD002001','CD002002']
 cd_ = ['CD1_1','CD1_2','CD2_1','CD2_2']
 comment = [' DL/DX',' DL/DY',' DM/DX',' DM/DY']

 if keyword_set( REVERSE ) then begin

 for i= 0 ,3 do begin
 cd = sxpar(hdr,cd00[i], COUNT = N )
 if N GE 1 then begin
	sxaddpar,hdr,cd_[i],cd,comment[i],cd00[i],format ='(E14.7)'
	sxdelpar,hdr,cd00[i]
 endif
 endfor

 endif else begin

 for i= 0 ,3 do begin
 cd = sxpar(hdr,cd_[i], COUNT = N )
 if N GE 1 then begin
	sxaddpar,hdr,cd00[i],cd,comment[i],cd_[i],format ='(E14.7)'
	sxdelpar,hdr,cd_[i]
 endif
 endfor

 endelse

 return
 end
                        	
