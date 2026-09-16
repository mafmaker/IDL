;$Author: kovalick $
;$Date: 1999/12/10 15:02:16 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/generate_inventory.pro,v 1.8 1999/12/10 15:02:16 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.8 $
;---------------------------------------------------------------------------
;Modifications: 2/4/98 - T. Kovalick - modified this to do what the inventory function
;in inventory.pro use to do, so that I can free up memory w/ delvar (has to be
;done at the main program level).

@compile_inventory.pro

;debug = 1

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/istp_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='ISTP PROPRIETARY DATA',GIF='/home/rumba/cdaweb/metadata/istp_cdfmetafile.gif',$
START_TIME='1992/07/01 00:00:00',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/istp_public_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='ISTP PUBLIC DATA',GIF='/home/rumba/cdaweb/metadata/istp_public_cdfmetafile.gif',$
START_TIME='1992/07/01 00:00:00', STOP_TIME='2001/12/31 23:59:59', /debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/iacg_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='IACG PROPRIETARY DATA',GIF='/home/rumba/cdaweb/metadata/iacg_cdfmetafile.gif',/debug)
delvar, a

; Read the metadata file... Added this back in w/ release of IDL 5.1 (won't work w/ previous versions)
a = ingest_database('/home/rumba/cdaweb/metadata/full_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='FULL CDAWEB HOLDINGS',GIF='/home/rumba/cdaweb/metadata/full_cdfmetafile.gif',/debug)
delvar, a

;generation of the iacg_public, mpause, bowshock and cdaw9 being done in generate_inventory2.pro. TJK 6/3/98
;generation of the two space physics and one image files is done in generate_small.pro
;because we run out of memory at this point...TJK 2/11/98

exit







