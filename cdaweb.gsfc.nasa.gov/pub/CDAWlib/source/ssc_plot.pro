;$Author: baldwin $
;$Date: 1997/05/20 20:15:31 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/ssc_plot.pro,v 1.14 1997/05/20 20:15:31 baldwin Exp baldwin $
;$Locker: baldwin $
;$Revision: 1.14 $
;
;+
; NAME: ssc_plot.pro
;
; PURPOSE: Calls read_myCDF and plotmaster for SSCWEB plots
;

FUNCTION ssc_plot, cdfnames, PID, OUTDIR

; Establish error handler 
  catch, error_status
  if(error_status ne 0) then begin
   print, 'STATUS= SSCWEB PLOT failed.'
   print, 'ERROR=Error number: ',error_status,' in ssc_plot.'
   print, 'ERROR=Error Message: ', !ERR_STRING
;   printf, 1, 'STATUS= SSCWEB PLOT failed.'
;   printf, 1, 'ERROR=Error number: ',error_status,' in ssc_plot.'
;   printf, 1, 'ERROR=Error Message: ', !ERR_STRING
    close, 1
   return, -1
  endif

nbufs=n_elements(cdfnames)
print, nbufs
for i=0, nbufs-1 do begin 
 print, cdfnames(i) 
 vnames = ' ' 
 buf = read_myCDF(vnames, cdfnames(i), /ALL, /NODATASTRUCT)
help, buf
 w=execute('buf'+strtrim(string(i),2)+'=buf')
  if w ne 1 then begin
      print,' Error in EXECUTE function'
      print, 'ssc_plot: A plotting error has occurred'
   return, -1
  endif

endfor
 
if n_elements(OUTDIR) eq 0 then OUTDIR = '/tmp/'
if n_elements(PID) eq 0 then PID = 1L
print, outdir, pid

if(nbufs eq 1) then s = plotmaster(buf0, /AUTO, PID=PID, /GIF, /SSCWEB, $
                                 OUTDIR=OUTDIR,/SMOOTH, /SLOW, /DEBUG)
if(nbufs eq 2) then s = plotmaster(buf0,buf1, /AUTO, PID=PID, /GIF, /SSCWEB, $
                                 OUTDIR=OUTDIR,/SMOOTH, /SLOW, /DEBUG)         
if(nbufs eq 3) then s = plotmaster(buf0,buf1,buf2, /AUTO, PID=PID, /GIF, $
                          /SSCWEB,OUTDIR=OUTDIR,/SMOOTH, /SLOW, /DEBUG)         
if(nbufs eq 4) then s = plotmaster(buf0,buf1,buf2,buf3, /AUTO, PID=PID, /GIF, $
                         /SSCWEB, OUTDIR=OUTDIR,/SMOOTH, /SLOW, /DEBUG)         
if(nbufs eq 5) then s = plotmaster(buf0,buf1,buf2,buf3,buf4, /AUTO, PID=PID, $
                    /GIF, /SSCWEB, OUTDIR=OUTDIR,/SMOOTH, /SLOW, /DEBUG) 
if(nbufs eq 6) then s = plotmaster(buf0,buf1,buf2,buf3,buf4,buf5, /AUTO, $
             PID=PID, /GIF, /SSCWEB, OUTDIR=OUTDIR,/SMOOTH, /SLOW, /DEBUG) 
if(nbufs eq 7) then s = plotmaster(buf0,buf1,buf2,buf3,buf4,buf5,buf6, /AUTO, $
             PID=PID, /GIF, /SSCWEB, OUTDIR=OUTDIR,/SMOOTH, /SLOW, /DEBUG)
if(nbufs eq 8) then s = plotmaster(buf0,buf1,buf2,buf3,buf4,buf5,buf6,buf7, $
         /AUTO, PID=PID, /GIF, /SSCWEB, OUTDIR=OUTDIR,/SMOOTH, /SLOW, /DEBUG)
if(nbufs gt 8) then begin 
   reportf=strtrim(string(OUTDIR),2)+"idl_"+strtrim(string(PID),2)+".rep"
   openw,1,reportf 
   printf, 1, "STATUS=Select fewer than 8 satellites. "
   printf, 1, "ERROR=Number of bufs for plotmaster exceeds 8. NBUF=",nbuf 
   close, 1
   return, -1
endif
 
if(s ne 0) then begin
   printf, 1, "STATUS=Plot failed  "
   printf, 1, "ERROR=Plotmaster called in SSC_PLOT failed " 
   close, 1
   return, -1
endif
   
   close, 1

return, s
end
