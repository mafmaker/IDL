;$Author: gallap $
;$Date: 1997/11/03 19:07:06 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/compile_inventory.pro,v 1.1 1997/11/03 19:07:06 gallap Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.1 $
;---------------------------------------------------------------------------

;Database utility routines:
.run decode_CDFEPOCH
.run encode_CDFEPOCH
.run DeviceOpen.pro
.run DeviceClose.pro
.run timeaxis_text.pro
.run bar_chart.pro
;Compile the cdf read routines
.run break_mySTRING.pro
.run print_inv_stats.pro
.run inventory
