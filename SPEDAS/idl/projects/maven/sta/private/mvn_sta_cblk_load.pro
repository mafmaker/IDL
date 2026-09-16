;+
;PROCEDURE:	mvn_sta_cblk_load,pathname=pathname,source=source
;PURPOSE:	
;	To generate quicklook data plots and a tplot save file
;INPUT:		
;
;KEYWORDS:
;
;CREATED BY:	J. McFadden	  13-05-07
;VERSION:	1
;LAST MODIFICATION:  13-05-07
;MOD HISTORY:
;
;NOTES:	  
;	
;-

pro mvn_sta_cblk_load,pathname=pathname,source=source

	starttime = systime(1)

;	mvn_sta_apid_handler,/reset    ; reset internal common blocks

;	mav_gse_cmnblk_file_read,realtime=realtime,pathname=pathname,file=file,last_version=1,source=source
;	mav_gse_cmnblk_file_read,realtime=realtime,pathname=pathname,last_version=1,source=source


	mvn_pfp_l0_file_read,pathname=pathname,file=file,/static	; this line replaces the above line - new davin code

	dprint,'Done in ',systime(1)-starttime,' seconds'

end