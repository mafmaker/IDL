pro calc_conductance_prot,ee,ef,hall,ped


;
;  Author  Thomas Immel
;  Date    05-09-2001
;  Purpose To calculate Pedersen and Hall Conductances created by protons
;
;  
;

helper=size(ee) & helper=helper(0)
if helper eq 0 then begin
  newee=ef
  newee(*)=ee
  ee=newee
endif

bad=where(ee le 0 or ef le 0)
good=where(ee gt 0 and ef gt 0,counter)

  hall=ee & hall(*)=0
  ped=ee & ped(*)=0

if counter gt 0 then begin

;---

;---

;  ped(good)= (40*ee(good))/(16 + ee(good)^2) * ef(good)^(0.5)
;  hall(good)=ped(good) * 0.45 * ee(good)^(0.85)

  ped(good)=5.7 * ef(good)^0.5
  hall(good)=ped(good) * 0.45 * ee(good)^(0.3)
;---

endif else print, 'In calc_conductance_prot, no good values for calculation'


return 
end
