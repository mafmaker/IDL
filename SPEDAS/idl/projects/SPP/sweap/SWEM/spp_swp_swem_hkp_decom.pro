

function spp_swp_swem_hkp_decom,ccsds,ptp_header=ptp_header,apdat=apdat


if n_params() eq 0 then begin
  dprint,'Not working yet.'
  return,!null
endif


ccsds_data = spp_swp_ccsds_data(ccsds)

;if typename(ccsds) eq 'CCSDS_FORMAT' then data = *ccsds.pdata  else data=ccsds.data
;data = ccsds.data

if ccsds.pkt_size lt 42 then begin
  if debug(2) then begin
    dprint,'error',ccsds.pkt_size,dlevel=2
    hexprint,ccsds_data
    return,0    
  endif
endif


;values = swap_endian(ulong(ccsds_data,10,11) )


str = {time:   ccsds.time  ,$
     seqn: ccsds.seqn, $
     mon_3p3_c:    ( swap_endian(uint(ccsds_data, 192/8)) and '3ff'x ) * .997  , $
     mon_3p3_v:    ( swap_endian(uint(ccsds_data, 144/8)) and '3ff'x ) * .0035  , $
     gap:  ccsds.gap }
       
  return,str

end



