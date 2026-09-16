;+
;Procedure:
;  thm_sst_quality_flags
;  
;Description:
;  makes a bitpacked tplot variable containing quality flags for SST
;  
;  Bit 0: saturated. (psef_count_rate > 10k)
;  Bit 1: attenuator error (stuck attenuator or incorrect indicator)
;  
;  Set timespan by calling timespan outside of this routine.(e.g. time/duration is not an argument)
;  
; $LastChangedBy: pcruce $
; $LastChangedDate: 2016-10-31 11:37:49 -0700 (Mon, 31 Oct 2016) $
; $LastChangedRevision: 22237 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/themis/spacecraft/particles/SST/thm_sst_quality_flags.pro $
;-


  pro thm_sst_quality_flags,probe=probe
  
    compile_opt idl2
    
    thm_load_state,probe=probe,/get_support
    thm_load_sst,probe=probe
    
    data_types = ['b','r','f']
    
    
    for i = 0, n_elements(data_types)-1 do begin
     
      get_data,'th'+probe+'_pse'+data_types[i]+'_tot',data=d
      
      if is_struct(d) then begin
        bit0 = d.y gt 1e4
      endif else begin
        bit0 = 0
      endelse
      
      get_data,'th'+probe+'_pse'+data_types[i]+'_atten',data=d
      
      if is_struct(d) then begin
        bit1 = (d.y ne 5) and (d.y ne 10)
      endif else begin
        bit1 = 0
      endelse
      
      
      ;state time abcissas won't match sst time abcissas by default 
      tinterpol_mxn,'th'+probe+'_state_spinper','th'+probe+'_pse'+data_types[i]+'_tot',/overwrite
      get_data,'th'+probe+'_state_spinper',data=d
      
      if is_struct(d) then begin
        bit2 = (d.y lt 2.5) or (d.y gt 5)
      endif else begin
        bit2 = 0
      endelse
      
      flags = bit0 or ishft(bit1,1) or ishft(bit2,2)
      
      store_data,'th'+probe+'_pse'+data_types[i]+'_data_quality',data={x:d.x,y:flags}
      store_data,'th'+probe+'_psi'+data_types[i]+'_data_quality',data={x:d.x,y:flags}
       
    endfor
    
    
   
  end