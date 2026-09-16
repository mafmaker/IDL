;+
;NAME:
;rerun_sta_L2gen
;PURPOSE:
;Designed to run from a cronjob, after the original L2 processing,
;reprocesses, using the current L2 files as input.
;CALLING SEQUENCE:
; run_sta_l2gen, noffset_sec = noffset_sec
;INPUT:
; none
;OUTPUT:
; none
;KEYWORDS:
; none
;HISTORY:
; 20-oct-2014, jmm, jimm@ssl.berkeley.edu
; 18-oct-2016, single call to mvn_call_l2l2, jmm
; $LastChangedBy: jimm $
; $LastChangedDate: 2016-10-18 10:41:14 -0700 (Tue, 18 Oct 2016) $
; $LastChangedRevision: 22120 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/sta/l2util/rerun_sta_l2gen.pro $
;-

Pro rerun_sta_l2gen

  test_file = file_search('/tmp/STAL2Rlock.txt')
  If(is_string(test_file[0])) Then Begin
     message, /info, 'Lock file /tmp/STAL2Rlock.txt Exists, Returning'
  Endif Else Begin
     test_file = '/tmp/STAL2Rlock.txt'
     file_touch, test_file[0]
     mvn_call_sta_l2l2
     message, /info, 'Removing Lock file /tmp/STAL2Rlock.txt'
     file_delete, test_file[0]
  Endelse

  Return

End

