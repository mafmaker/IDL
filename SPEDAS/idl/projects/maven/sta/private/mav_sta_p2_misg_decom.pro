function mav_sta_p2_misg_decom,prod

; p2	64E x 16D  	1024

	dbyt = 3			; data bytes per measurement
	mcyc = 32			; message cycles per measurement, p1=128, p2=32, p3=32, p4=512
	ocyc = 128			; message cycle offset, p1=0, p2=128, p3=160, p4=192
	mlen = 48			; message data length in words
	nmes = 2l*mlen/dbyt		; number of data points in a message
	nsam = mcyc*nmes		; number data points in a sample (4 sec), 1024

	ocyc = min(prod.cyclestep)
	ind  = where(prod.cyclestep eq ocyc,count)

	mini = ind[0]
	maxi = ind[count-2]+mcyc-1
	ncyc = (maxi-mini+1)
	npts = ncyc*nmes
	tmp2 = lonarr(npts)
	pd   = lonarr(nsam,count-1)

	tmp     = reform(byte(prod[mini:maxi].data,0,dbyt*npts),dbyt,npts)
	time	= prod[ind].time 	& time  = time[0:count-2]
	tmp2 	= reform(tmp[0,*]+256l*(tmp[1,*]+tmp[2,*]*256l))
	
	for j=0,count-2 do begin
		jj = (ind[j]-ind[0])*nmes
		pd[*,j] = tmp2[jj:jj+nsam-1]
		if jj+nsam ne (ind[j+1]-ind[0])*nmes then print,'Missing packet at ',time_string(time[j])
	endfor

	pd=transpose(pd)
	
; make tplots

	pd=reform(pd,count-1,16,64)
;	dd = transpose(pd,[0,2,1])

	store_data,'STA_P2_en',data={x:time,y:total(pd,2),v:findgen(64)}
		options,'STA_P2_en','spec',1
		zlim,'STA_P2_en',.1,1000.,1
	store_data,'STA_P2_an',data={x:time,y:total(pd,3),v:findgen(16)}
		options,'STA_P2_an','spec',1
		zlim,'STA_P2_an',.1,1000.,1

	return,pd
;	return,dd

end

