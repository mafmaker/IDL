;$Author: kovalick $
;$Date: 1996/08/09 14:04:14 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/cnvtime.pro,v 1.1 1996/08/09 14:04:14 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.1 $
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	CNVTIME
;
; PURPOSE:
; 	This provides an alternate entry point to CNV_MDHMS_SEC
;
;----------------------------------------------------------------
;
function cnvtime,yr,mo,dy,hr,mn,sc
return,cnv_mdhms_sec(yr,mo,dy,hr,mn,sc)
end