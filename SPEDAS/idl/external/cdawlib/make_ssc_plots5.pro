; Add journal command write to a file
; Use in error message mailed to developers
; journal, '/home/rumba/cdaweb/tmp/ssc_journal'
 journal, '/home/cdaweb/tmp/ssc_journal'
ON_ERROR, 1
; s = execute("restore, '/home/rumba/cdaweb/lib/spdflib.new'")
; s = execute("restore, '/home/rumba/cdaweb/lib/spdflib.dat5'")
;TJK 4/27/99 s = execute("restore, '/home/rumba/cdaweb/lib/spdflib51.dat'")
;restore the debug version that contains more of the jhuapl routines
;for now - can change this to spdflib5.dat after spectrograms are up to
;snuff and that lib is made operational
;s = execute("restore, '/home/rumba/cdaweb/lib/spdflib5.dat'")
 s = execute("restore, '/home/cdaweb/lib/spdflib.dat'")
if s ne 1  then journal
if s ne 1  then  exit
print, version()
print, 'from within make_ssc_plots...'
print, 'IDL_PATH is: ',getenv('IDL_PATH')
print, 'IDL_DIR is: ',getenv('IDL_DIR')
print, cdfnames

s = ssc_plot(cdfnames,PID,OUTDIR)

!p.noerase=0
!p.multi=0
!p.background=0
!p.position=0
!p.region=0

;to gif files.
print, 'Status of ssc_plot = ',s
print, 'Make_ssc_plots finished'
 journal
exit
