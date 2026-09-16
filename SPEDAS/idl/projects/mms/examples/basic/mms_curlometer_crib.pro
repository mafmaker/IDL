;+
; MMS curlometer crib sheet
;
;  This script shows how to calculate div B and curl B
;  using mms_curl
;
;
; do you have suggestions for this crib sheet?
;   please send them to egrimes@igpp.ucla.edu
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-09-26 12:01:16 -0700 (Mon, 26 Sep 2016) $
; $LastChangedRevision: 21943 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/mms/examples/basic/mms_curlometer_crib.pro $
;-

trange = ['2015-10-30/05:15:45', '2015-10-30/05:15:48']

mms_load_fgm, trange=trange, /get_fgm_ephemeris, probes=[1, 2, 3, 4], data_rate='brst'

fields = 'mms'+['1', '2', '3', '4']+'_fgm_b_gse_brst_l2'
positions = 'mms'+['1', '2', '3', '4']+'_fgm_r_gse_brst_l2'

mms_curl, trange=trange, fields=fields, positions=positions

tplot, ['divB','curlB','jtotal','baryb','jperp','jpar','baryb']

end