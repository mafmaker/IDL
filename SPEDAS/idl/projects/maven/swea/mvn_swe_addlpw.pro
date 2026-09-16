;+
;PROCEDURE:   mvn_swe_addlpw
;PURPOSE:
;  Loads LPW data and creates tplot variables using LPW code.
;
;USAGE:
;  mvn_swe_addlpw
;
;INPUTS:
;    None:          Data are loaded based on timespan.
;
;KEYWORDS:
;
;    PANS:          Named variable to hold a space delimited string containing
;                   the tplot variable(s) created.
;
;    NE_ONLY:       Only include the density panel, ignoring T_e and V_sc.
;                   Default = 1 (yes).
;
; $LastChangedBy: dmitchell $
; $LastChangedDate: 2016-06-06 08:43:10 -0700 (Mon, 06 Jun 2016) $
; $LastChangedRevision: 21265 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/swea/mvn_swe_addlpw.pro $
;
;CREATED BY:    David L. Mitchell  03/18/14
;-
pro mvn_swe_addlpw, pans=pans, ne_only=ne_only

  if (size(ne_only,/type) eq 0) then ne_only = 1

  pans = ''
  mvn_lpw_load_l2, ['lpnt'], tplotvars=lpw_pan, /notplot
  
  if (lpw_pan[0] ne '') then begin
    for i=0,(n_elements(lpw_pan)-1) do pans += lpw_pan[i] + ' '
    pans = strtrim(strcompress(pans),2)
  endif

  options,'mvn_lpw_lp_ne_l2','psym',10
  if (ne_only) then pans = 'mvn_lpw_lp_ne_l2'

  return
  
end
