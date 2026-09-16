pro post_process_ncdfv3, history
;
;  program to post process history fields, interpolating
;  things to gridpoints as B. Foster did in proclat.f
;  also convert to mks units
;
;  modified from post_process_history by Chris Hackert, May 2, 2002
;

eps = 1.0e-12				;minimum O2+ den if less than 0

;---interpolating

nfields = n_elements(history)

scan_index, history(*).title, n_tn=n_t, n_un=n_u, n_vn=n_v, n_w=n_w, $
   n_z=n_z, n_pot=n_pot, n_o2_=n_o2, n_op=n_op, n_ne=n_ne, n_o2p=n_o2p, $
   n_qj=n_qj, n_qt=n_qt, n_qei=n_qei, n_qic=n_qic, n_qnc=n_qnc, $
   n_qo3=n_qo3, n_qsrc=n_qsrc, n_qsrb=n_qsrb, n_qa=n_qa, n_qeuv=n_qeuv, $
   n_qo2=n_qo2, n_qdh=n_qdh, n_qgw=n_qgw, n_qm=n_qm

ions = [n_op,n_ne,n_o2p] ; OP, NE, O2P are in cm^-3, not mass fraction
if max(ions) ge 0 then begin
   ions = ions(where(ions gt -1))
   print, 'ions are ', history(ions).title
endif

    thing=history(0) 
    print,'Post Processsor --- running'

    for ii=0,nfields-1 do begin				;no W, Z or Phi changes
      if where([n_w,n_z,n_pot] eq ii) gt -1 then begin
         ; do nothing
      endif else if where([n_t,n_u,n_v] eq ii) gt -1 then begin
        ; for TN, UN, VN, lower bc is stored in top altitude
        thing.a(*,*,1:44)=history(ii).a(*,*,0:43)  ;this shift must be
        thing.a(*,*,0)=history(ii).a(*,*,44)	     ;accounted for
        thing.a(*,*,1:43)=  $			     ;in THIS statement
			(thing.a(*,*,1:43)+thing.a(*,*,2:44))/2.0
        thing.title = history(ii).title
        history(ii) = thing
      endif else if where(ions eq ii) gt -1 then begin ; ion species
        history(ii).a(*,*,1:44)= $
		(history(ii).a(*,*,1:44)+history(ii).a(*,*,0:43))/2.0 

      endif else if where([n_qt,n_qnc,n_qdh,n_qgw] eq ii) gt -1 then begin
          ; some heating may be locally negative
          ; QT,QDH,QGW top level bogus: real values in 0:43
          if where([n_qt,n_qdh,n_qgw] eq ii) gt -1 then $
          history(ii).a(*,*,44)= 2*history(ii).a(*,*,43) - history(ii).a(*,*,42)
      
      endif else begin				; non-ion species
          if ii eq n_o2 then begin    ;O2 gets special treat
            finder=where(history(ii).a(*,*,*) lt 0,negcount)
            if negcount gt 0 then history(ii).a(finder)=eps
          endif 
          history(ii).a(*,*,44)= $
		sqrt( history(ii).a(*,*,43)^3. /history(ii).a(*,*,42))       
          history(ii).a(*,*,1:43)= $
	        sqrt( history(ii).a(*,*,1:43) *history(ii).a(*,*,0:42))       
 	  history(ii).a(*,*,0)= $
		sqrt( history(ii).a(*,*,0)^2. /history(ii).a(*,*,1))       
      endelse

    endfor

;===ending interpolation
;---begin unit conversion 

; full list: version 1
;   0      1    2      3    4       5        6      7      8       9
; TN (K)  UN   VN    O2    O1    [N4O]    [NOz]   [CO]   [CO2]   [H2O]
; [H2]  [HOx]  O+  [CH4] [O21D]  [NO2]     [NO]   [O3]    [O1]    [OH] 
; [HO2]   H  [N2D] TI (K)TE (K) NE (M-3) O2+ (M-3) WN      Z       Phi 



adjustby1e2=[n_u,n_v]	;convert from cm/s to m/s
adjustby1e5=[n_z]	;convert from cm to km
adjustby1e6=ions        ;convert from cm^-3 to m^-3
adjustby1e4=[n_qj,n_qt,n_qei,n_qic,n_qnc,n_qsrc,n_qsrb,n_qo3,n_qa,n_qeuv, $
             n_qo2,n_qdh,n_qgw,n_qm]
                        ;convert from erg/g/sec to W/kg


;TJI:---Vertical winds need a DIFFERENT CORRECTION? Not according to B. Foster.
;CLH: Vertical winds are in units of pressure level/second not cm/s. 

if max(adjustby1e2) gt -1 then $
   history(adjustby1e2).a(*,*,*)=temporary(history(adjustby1e2).a(*,*,*))/1e2
if max(adjustby1e5) gt -1 then $
   history(adjustby1e5).a(*,*,*)=temporary(history(adjustby1e5).a(*,*,*))/1e5
if max(adjustby1e6) gt -1 then $
  history(adjustby1e6).a(*,*,*)=temporary(history(adjustby1e6).a(*,*,*))*1e6
if max(adjustby1e4) gt -1 then $
  history(adjustby1e4).a(*,*,*)=temporary(history(adjustby1e4).a(*,*,*))/1e4

print,'Post Processsor --- done'

return
end

