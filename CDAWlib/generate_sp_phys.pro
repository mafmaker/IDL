@compile_inventory.pro
;
; TJK - 11/6/2002 - split sp_phys catalog out since it takes so long to run.
;
; Read the metadata file...
a = ingest_database('/home/cdaweb/metadata/sp_phys_cdfmetafile.txt',DEBUG=DEBUG)
; Draw the inventory graph...
;s=draw_inventory(a,TITLE='SPACE PHYSICS',GIF='/home/cdaweb/metadata/sp_phys_cdfmetafile.gif', $
;START_TIME='1970/01/01 00:00:00',STOP_TIME='2002/12/31 23:59:59',/debug)

aa=a

s=draw_inventory(a,TITLE='SPACE PHYSICS 1960-2020', /BIGPLOT,$
GIF='/home/cdaweb/metadata/sp_phys_cdfmetafile.gif', $
/long_line, /wide_margin, $
START_TIME='1960/01/01 00:00:00',STOP_TIME='2020/12/31 23:59:59',debug=debug)
;
;   Now every 5 years:
;
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 1960-1964', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_1960-1964.gif', $
 /wide_margin, $
START_TIME='1960/01/01 00:00:00',STOP_TIME='1964/12/31 23:59:59',debug=debug)
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 1965-1969', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_1965-1969.gif', $
 /wide_margin, $
START_TIME='1965/01/01 00:00:00',STOP_TIME='1969/12/31 23:59:59',debug=debug)
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 1970-1974', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_1970-1974.gif', $
 /wide_margin, $
START_TIME='1970/01/01 00:00:00',STOP_TIME='1974/12/31 23:59:59',debug=debug)
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 1975-1979', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_1975-1979.gif', $
 /wide_margin, $
START_TIME='1975/01/01 00:00:00',STOP_TIME='1979/12/31 23:59:59',debug=debug)
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 1980-1984', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_1980-1984.gif', $
 /wide_margin, $
START_TIME='1980/01/01 00:00:00',STOP_TIME='1984/12/31 23:59:59',debug=debug)
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 1985-1989', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_1985-1989.gif', $
 /wide_margin, $
START_TIME='1985/01/01 00:00:00',STOP_TIME='1989/12/31 23:59:59',debug=debug)
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 1990-1994', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_1990-1994.gif', $
 /wide_margin, $
START_TIME='1990/01/01 00:00:00',STOP_TIME='1994/12/31 23:59:59',debug=debug)
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 1995-1999', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_1995-1999.gif', $
 /wide_margin, $
START_TIME='1995/01/01 00:00:00',STOP_TIME='1999/12/31 23:59:59',debug=debug)
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 2000-2004', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_2000-2004.gif', $
 /wide_margin, $
START_TIME='2000/01/01 00:00:00',STOP_TIME='2004/12/31 23:59:59',debug=debug)
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 2005-2009', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_2005-2009.gif', $
 /wide_margin, $
START_TIME='2005/01/01 00:00:00',STOP_TIME='2009/12/31 23:59:59',debug=debug)
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 2005-2009', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_2005-2009.gif', $
 /wide_margin, $
START_TIME='2005/01/01 00:00:00',STOP_TIME='2009/12/31 23:59:59',debug=debug)
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 2010-2014', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_2010-2014.gif', $
 /wide_margin, $
START_TIME='2010/01/01 00:00:00',STOP_TIME='2014/12/31 23:59:59',debug=debug)
a=aa
s=draw_inventory(a,TITLE='SPACE PHYSICS 2015-2020', /FIVEYEAR,$
GIF='/var/www/cdaweb/htdocs/sp_phys/avail_2015-2020.gif', $
 /wide_margin, $
START_TIME='2015/01/01 00:00:00',STOP_TIME='2020/12/31 23:59:59',debug=debug)
;
delvar, a,aa

exit




