;$Author: kovalick $
;$Date: 1996/08/09 14:06:43 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/eccmlt.pro,v 1.1 1996/08/09 14:06:43 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.1 $
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
