;+
; PROCEDURE:
;         mms_mec_fix_metadata
;
; PURPOSE:
;         Helper routine for setting metadata of MEC variables
;
;
;
;$LastChangedBy: egrimes $
;$LastChangedDate: 2016-05-03 14:32:57 -0700 (Tue, 03 May 2016) $
;$LastChangedRevision: 21012 $
;$URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/mms/mec/mms_mec_fix_metadata.pro $
;-

pro mms_mec_fix_metadata, probe, suffix = suffix
    if undefined(suffix) then suffix = ''
    probe = strcompress(string(probe), /rem)
    position_vars = tnames('mms'+probe+'_mec_r_*')
    velocity_vars = tnames('mms'+probe+'_mec_v_*')

    for pos_idx = 0, n_elements(position_vars)-1 do begin
        options, position_vars[pos_idx], colors=[2, 4, 6]
    endfor
    for vel_idx = 0, n_elements(velocity_vars)-1 do begin
        options, velocity_vars[vel_idx], colors=[2, 4, 6]
    endfor
    
    ; the coordinate system for the ECI variables in the MEC files
    ; is set to 'gei'; this represents J2000 GEI, not MOD GEI (which
    ; is what SPEDAS assumes 'gei' is)
    eci_vars = 'mms'+probe+['_mec_r_eci', '_mec_v_eci']+suffix
    for eci_var=0, n_elements(eci_vars)-1 do begin
        get_data, eci_vars[eci_var], data=d, dlimits=dl, limits=l
        cotrans_set_coord, dl, 'j2000'
        store_data, eci_vars[eci_var], data=d, dlimits=dl, limits=l
    endfor
end