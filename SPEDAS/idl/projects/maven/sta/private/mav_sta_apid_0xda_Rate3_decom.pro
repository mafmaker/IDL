function mav_sta_apid_0xda_Rate3_decom,ccsds,lastpkt=lastpkt
len=1024 & apid='DA'	; pcyc must be determined from header
;dprint,dlevel=2,'APID ',ccsds.apid,ccsds.seq_cntr,ccsds.size ,format='(a,z03," ",i,i)'

data = mav_pfdpu_part_decompress_data(ccsds)
;data = ccsds.data

if not keyword_set(lastpkt) then nolstpkt = 0 else nolstpkt=1
if not keyword_set(lastpkt) then lastpkt = ccsds
last = mav_pfdpu_part_decompress_data(lastpkt)

	subsec1 = data[0]/256.d 
	subsec2 = data[1]/(256.d)^2
	lstsub1 = last[0]/256.d 
	lstsub2 = last[1]/(256.d)^2
	time = ccsds.time + subsec1 + subsec2
	lasttime = lastpkt.time + lstsub1 + lstsub2


	nn = 2^(7 and data[3])
	ss = (8 and data[3])/2^3
	if ss eq 0 then n2=1 else n2=nn
	lstnn = 2^(7 and last[3])
	rr = ( 15 and data[5])

	da_gg=[64,128,256,1024]
	pcyc = da_gg[( 48 and data[3])/2^4]

;	npts=ccsds.size-16
;	lpts=lastpkt.size-16
	npts=n_elements(data) - 6
	lpts=n_elements(last) - 6

	ncyc = npts/pcyc
	lcyc = lpts/pcyc
;	if abs(time-lasttime-4.*lcyc*lstnn) gt 0.01 and nolstpkt and (pp eq 0) then print,'Error: ',apid,' pkt time jump ',time-lasttime,' ',time_string(time),' ',time_string(lasttime)
	if npts ne len then print,'Error in APID ',apid,' - length: ',npts,'  Should be ',len,'  ', time_string(ccsds.time)
	if (npts mod pcyc) ne 0 then begin
		print,'Error in APID ',apid,' - length: ',npts,' pts_cyc= ',pcyc,'  ', time_string(ccsds.time)
		npts=npts - (npts mod pcyc)
		ncyc = npts/pcyc
		if npts eq 0 then return, {time:ccsds.time,valid: 0}
	endif

;print,npts/128., npts

str = {time:ccsds.time + 2.d*n2 + 4.d*nn*findgen(ncyc) ,$
;       subsec1:  subsec1,$
;       subsec2:  subsec2,$
;       subsec1b:  data[0],$
;       subsec2b:  data[1],$
;       dtime:  time - lasttime,$
       seq_cntr:  ccsds.seq_cntr#replicate(1,ncyc)   ,$
;       seq_dcntr:  fix( ccsds.seq_cntr - lastpkt.seq_cntr )   ,$
       valid: 1#replicate(1,ncyc)  ,$
       mode: data[2]#replicate(1,ncyc)  ,$
       avg:  data[3]#replicate(1,ncyc)  ,$
       atten: data[4]#replicate(1,ncyc)  ,$
       diag: data[5]#replicate(1,ncyc)  ,$
       data : reform(data[6:pcyc*ncyc+5],pcyc,ncyc) }

lastpkt = ccsds

return, str
end

