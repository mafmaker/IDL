@compile_inventory.pro
;
;TJK added cdaw9new - 3/2/2000
;TJK added map - 7/16/2001
;TJK split the sp_phys catalog out - its now in generate_sp_phys.pro - 11/6/02
;TJK increased the end date to 2003/06/01 (Jan. 9, 2003)
;TJK deleted mpeg generation 5/1/2003

; Read the metadata file...
a = ingest_database('/home/cdaweb/metadata/sp_2012_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,TITLE='SPACE PHYSICS TEST DATA',GIF='/home/cdaweb/metadata/sp_2012_cdfmetafile.gif',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/cdaweb/metadata/lunar_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,TITLE='Apollo Era DATA',GIF='/home/cdaweb/metadata/lunar_cdfmetafile.gif',/debug)
delvar, a

; Read the metadata file...
; RCJ 02/2012  image no longer there.
;a = ingest_database('/home/cdaweb/metadata/image_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
;s=draw_inventory(a,TITLE='IMAGE ERA DATA',GIF='/home/cdaweb/metadata/image_cdfmetafile.gif', $
;START_TIME='2000/03/01 00:00:00',STOP_TIME='2005/12/31 23:59:59',/debug)
;delvar, a

; Read the metadata file...
a = ingest_database('/home/cdaweb/metadata/map_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,TITLE='MAP TEST DATA',GIF='/home/cdaweb/metadata/map_cdfmetafile.gif', /debug)
;TJK removed 1/8/2004, let s/w determine start/stop 
;START_TIME='2001/06/30 15:00:33',STOP_TIME='2004/12/01 23:59:59',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/cdaweb/metadata/pre_istp_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,TITLE='Public data from missions before 1992', $
/long_line, /wide_margin, GIF='/home/cdaweb/metadata/pre_istp_cdfmetafile.gif',/debug)
delvar, a

; Read the metadata file...
a = ingest_database('/home/cdaweb/metadata/test_rbsp_j_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
s=draw_inventory(a,/wide_margin, TITLE='RBSP data',GIF='/home/cdaweb/metadata/test_rbsp_j_cdfmetafile.gif',/debug)
delvar, a

exit
















