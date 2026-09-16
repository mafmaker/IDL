;+
;
;  This crib sheet shows how to create a figure with multiple panels, one
;  of which contains 2 variables with independent axes (FPI DES perpendicular temp and density)
;     i.e., line plots of two tplot variables in a single panel where one has its 
;     y-axis/title on the left and the other has its y-axis/title on the right
;
; do you have suggestions for this crib sheet?
;   please send them to egrimes@igpp.ucla.edu
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-11-04 15:45:57 -0700 (Fri, 04 Nov 2016) $
; $LastChangedRevision: 22308 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/mms/examples/advanced/mms_multi_axis_figure.pro $
;-

; load the data
mms_load_fgm, trange=['2015-10-16/13:00', '2015-10-16/14:00'], probe=1, /time_clip
mms_load_fpi, trange=['2015-10-16/13:00', '2015-10-16/14:00'], probe=1, datatype='des-moms', /time_clip

; remove the ytitle/labels
options, 'mms1_des_numberdensity_fast', labels='', colors=0 ; black
options, 'mms1_des_tempperp_fast', labels='', colors=2 ; blue

tplot_multiaxis, ['mms1_fgm_b_gse_srvy_l2_bvec', 'mms1_des_numberdensity_fast', 'mms1_des_bulkv_gse_fast', 'mms1_des_energyspectr_omni_fast'], $ ; left plots
                'mms1_des_tempperp_fast', $ ; right plots
                2 ; panel of the right plot (starts at 1)
end