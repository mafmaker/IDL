; Add journal command write to a file
; Use in error message mailed to developers
 journal, '/home/rumba/cdaweb/tmp/ssc_journal'
ON_ERROR, 1
; s = execute("restore, '/home/rumba/cdaweb/lib/spdflib.new'")
 s = execute("restore, '/home/rumba/cdaweb/lib/spdflib.dat'")
if s ne 1  then journal
if s ne 1  then  exit
print, version()
print, 'from within make_ssc_plots...'
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
