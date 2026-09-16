;$Author: leckner $
;$Date: 2001/04/17 18:10:39 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/generate_inventory2.pro,v 1.8 2001/04/17 18:10:39 leckner Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.8 $
;---------------------------------------------------------------------------
;Modifications: 2/4/98 - T. Kovalick - modified this to do what the inventory function
;in inventory.pro use to do, so that I can free up memory w/ delvar (has to be
;done at the main program level).

@compile_inventory.pro

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/iacg_public_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='IACG PUBLIC DATA',GIF='/home/rumba/cdaweb/metadata/iacg_public_cdfmetafile.gif',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/mpause_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='SKIMMING CAMPAIGN',GIF='/home/rumba/cdaweb/metadata/mpause_cdfmetafile.gif',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/bowshock_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='BOWSHOCK',GIF='/home/rumba/cdaweb/metadata/bowshock_cdfmetafile.gif',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/cdaw9_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='CDAW-9 CAMPAIGN',GIF='/home/rumba/cdaweb/metadata/cdaw9_cdfmetafile.gif',/debug)
delvar, a

; Read the metadata file...
;a = ingest_database('/home/rumba/cdaweb/metadata/solar_cdaw_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
;s=draw_inventory(a,TITLE='SOLAR CDAW DATA',GIF='/home/rumba/cdaweb/metadata/solar_cdaw_cdfmetafile.gif',$
;START_TIME='1997/03/01 00:00:00', STOP_TIME='1998/08/01 00:00:00', /debug)
;delvar, a

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/cluster_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='CLUSTER DATA',GIF='/home/rumba/cdaweb/metadata/cluster_cdfmetafile.gif', $
START_TIME='2000/10/01 00:00:00', STOP_TIME='2001/10/31 00:00:00', /debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/radiation_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='TRAPPED RADIATION STUDIES',GIF='/home/rumba/cdaweb/metadata/radiation_cdfmetafile.gif', /debug)
delvar, a

exit



