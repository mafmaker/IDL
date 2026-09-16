;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/cdaweb/dev/control/RCS/eccmlt.pro,v 1.2 1996/08/09 18:28:21 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 8 $
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;       ECCMLT  
;
; PURPOSE:
;       Convert coordinates from geographic to geomagnetic and computes
;       eccentric dipole MLT 
;
;       calling sequence:
;
;       pos = eccmlt(year,doy,sod,r,lat,lon)
;
;----------------------------------------------------------------------------
function eccmlt,year,doy,sod,r,lat,lon 
;
        ierr=0
        outpos=fltarr(3)
        year=fix(year)
        ierr = call_external('LIB_PGM.so','L_mlat_mlt_idl',$
              year,doy,sod,r,lat,lon,outpos,ierr)
        return,outpos
        end
