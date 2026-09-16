;+
;Procedure:
;  mms_pgs_split_hpca
;
;Purpose:
;  Split hpca elevation bins so that dphi == dtheta.
;  Combined with updates to spectra generation code this should allow
;  the regrid step for FAC spectra to be skipped in mms_part_products.
;   
;Input:
;  data:  Sanitized hpca data structure
;
;Output:
;  output:  New structure with theta bins split in two
;           (2x data points in angle dimension)
;
;Notes:
;
;
;$LastChangedBy: aaflores $
;$LastChangedDate: 2016-09-30 17:29:27 -0700 (Fri, 30 Sep 2016) $
;$LastChangedRevision: 21991 $
;$URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/mms/particles/mms_pgs_split_hpca.pro $
;-
pro mms_pgs_split_hpca, data, output=output

  compile_opt idl2,hidden
  
  
  output = {  $
    time: data.time, $
    end_time: data.end_time, $
    charge: data.charge, $
    mass: data.mass, $
    magf: data.magf, $
    sc_pot: data.sc_pot, $
    scaling:[[data.scaling],[data.scaling]], $
    units: data.units, $
    data: [[data.data],[data.data]], $
    bins: [[data.bins],[data.bins]], $
    energy: [[data.energy],[data.energy]], $
    denergy: [[data.denergy],[data.denergy]], $ ;placeholder
    phi: [[data.phi],[data.phi]], $
    dphi: [[data.dphi],[data.dphi]], $
    theta: [[data.theta+(0.25*data.dtheta)],[data.theta-(0.25*data.dtheta)]], $
    dtheta: [[data.dtheta],[data.dtheta]]/2 $
  }


end