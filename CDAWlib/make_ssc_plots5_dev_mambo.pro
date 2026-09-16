; Add journal command write to a file
; Use in error message mailed to developers
;TJK change to tmp2 for mambo journal, '/home/cdaweb/tmp/ssc_journal_dev'
 journal, '/home/cdaweb/tmp2/ssc_journal_dev'
ON_ERROR, 1
; s = execute("restore, '/home/rumba/cdaweb/lib/spdflib5.dat'") ; this was ops
 s = execute("restore, '/home/cdaweb/dev/lib/spdflib.dat'") ; this is dev
if s ne 1  then journal
if s ne 1  then  exit
print, version()
print, 'from within LATEST make_ssc_plots5_dev_mambo on waltz...'
print, 'IDL_DLM_PATH is: ',getenv('IDL_DLM_PATH')
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
help, /files
 journal
exit
