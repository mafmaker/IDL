;$Author: horrocks $
;$Date: 1996/08/19 14:47:28 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/compile_dbase.pro,v 1.11 1996/08/19 14:47:28 horrocks Exp horrocks $
;$Locker: horrocks $
;$Revision: 1.11 $
;Database utility routines:
.run decode_CDFEPOCH
.run encode_CDFEPOCH
.run getdirs
.run find_myfiles
.run Validate_myPath.pro
.run DeviceOpen.pro
.run DeviceClose.pro
.run timeaxis_text.pro
.run bar_chart.pro
;Compile the cdf read routines
.run break_mySTRING.pro
.run read_myCDF
.run compare_struct
.run split_filename
;overnight.pro contains all routines related to creating the "database".
;and the overnight program...
.run overnight
