;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/generate_inventory2.pro,v 1.16 2006/01/11 16:27:08 kovalick Exp johnson $
;$Locker: johnson $
;$Revision: 7092 $
;---------------------------------------------------------------------------
;Modifications: 2/4/98 - T. Kovalick - modified this to do what the inventory function
;in inventory.pro use to do, so that I can free up memory w/ delvar (has to be
;done at the main program level).
; 5/1/2003 - removed IACG and Mpause generation - TJK 

@compile_inventory.pro

; Read the metadata file...
a = ingest_database('/home/cdaweb/metadata/bowshock_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='BOWSHOCK',GIF='/home/cdaweb/metadata/bowshock_cdfmetafile.gif',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/cdaweb/metadata/cdaw9_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='CDAW-9 CAMPAIGN',GIF='/home/cdaweb/metadata/cdaw9_cdfmetafile.gif',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/cdaweb/metadata/cluster_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='CLUSTER DATA',GIF='/home/cdaweb/metadata/cluster_cdfmetafile.gif', $
START_TIME='2000/10/01 00:00:00', STOP_TIME='2010/12/31 23:59:59', /debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/cdaweb/metadata/radiation_cdfmetafile.txt',DEBUG=DEBUG)
; Draw inventory graph...
s=draw_inventory(a,TITLE='TRAPPED RADIATION STUDIES',GIF='/home/cdaweb/metadata/radiation_cdfmetafile.gif', /debug)
delvar, a

exit


end

