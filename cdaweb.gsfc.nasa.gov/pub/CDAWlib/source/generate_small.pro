@compile_inventory.pro
;
;TJK added cdaw9new - 3/2/2000
;TJK added map - 7/16/2001
;
; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/mpeg_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,TITLE='MPEG Polar Test files',GIF='/home/rumba/cdaweb/metadata/mpeg_cdfmetafile.gif',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/sp_phys_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,TITLE='SPACE PHYSICS',GIF='/home/rumba/cdaweb/metadata/sp_phys_cdfmetafile.gif', $
START_TIME='1970/01/01 00:00:00',STOP_TIME='2001/12/31 23:59:59',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/sp_test_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,TITLE='SPACE PHYSICS TEST DATA',GIF='/home/rumba/cdaweb/metadata/sp_test_cdfmetafile.gif',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/image_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,TITLE='IMAGE TEST DATA',GIF='/home/rumba/cdaweb/metadata/image_cdfmetafile.gif', $
START_TIME='1973/10/30 15:00:33',STOP_TIME='2001/12/31 23:59:59',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/map_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,TITLE='MAP TEST DATA',GIF='/home/rumba/cdaweb/metadata/map_cdfmetafile.gif', $
START_TIME='2001/06/30 15:00:33',STOP_TIME='2001/12/31 23:59:59',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/rumba/cdaweb/metadata/cdaw9new_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,TITLE='CDAW9 NEW DATA',GIF='/home/rumba/cdaweb/metadata/cdaw9new_cdfmetafile.gif',/debug)
delvar, a

exit
