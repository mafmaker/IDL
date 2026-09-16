function mav_apid_sta_rate_surv_decom,ccsds,lastpkt=lastpkt

;dprint,dlevel=2,'APID ',ccsds.apid,ccsds.seq_cntr,ccsds.size ,format='(a,z03," ",i,i)'
data = ccsds.data
if not keyword_set(lastpkt) then lastpkt = ccsds



str = {time:ccsds.time + 4.d*findgen(16) ,$
;       dtime:  ccsds.time - lastpkt.time ,$
;       seq_cntr:  ccsds.seq_cntr   ,$
       seq_cntr:  ccsds.seq_cntr#replicate(1,16)   ,$
;       seq_dcntr:  fix( ccsds.seq_cntr - lastpkt.seq_cntr )#replicate(1,16)   ,$
;       valid: 1  ,$
       valid: 1#replicate(1,16)  ,$
;       mode:  data[2]  ,$
;       comp:  data[3]  ,$
;       atten: data[4]  ,$
       mode:  data[2]#replicate(1,16)  ,$
       comp:  data[3]#replicate(1,16)  ,$
       atten: data[4]#replicate(1,16)  ,$
       data : reform(data[6:197],12,16)}

return, str
end

