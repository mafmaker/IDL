;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/cnvtime.pro,v 1.1 1996/08/09 14:04:14 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 8 $
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