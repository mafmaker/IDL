;$Author: kenb $
;$Date: 2006-10-11 13:32:51 -0700 (Wed, 11 Oct 2006) $
;$Header: /home/rumba/cdaweb/dev/control/RCS/mlt.pro,v 1.1 1996/08/09 14:14:12 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 8 $
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	MLT
;
; PURPOSE:
;
;	convert UT time to MLT
;
;	calling sequence:
;	  mt = mlt(year, ut_seconds, mag_long)
;		inputs:  year, time in seconds from Jan. 1 at 00;00:00 UT
;		         magnetic longitude of the observation point
;	
;	        the time in seconds can be found with routine "cnvtime"
;		the magnetic longitude of the obs. point can be found
;		  by using routine "cnvcoord"
;
;-----------------------------------------------------------------------------
function mlt, year, t, mlong
	year = fix(year)
;	t = long(t)
	mlong = float(mlong)
                
	mt = 0.0

;	mt = call_external(getenv ('SD_LIB_PGM'), 'mlt_idl', $
;		year, t, mlong,/f_value)
;	mt = call_external(getenv('libpgm.so.1.1'), 'mlt_idl', $
;	  	year, t, mlong,/f_value)

       mt = call_external('LIB_PGM.so', 'mlt_idl', $
               year, t, mlong,/f_value)
       
;      if check_math(1,1) ne 0 then begin
;       print, year, t, mlong, mt
;       endif

	return, mt
	end