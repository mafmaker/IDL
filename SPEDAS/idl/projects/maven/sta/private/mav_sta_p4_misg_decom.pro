function mav_sta_p4_misg_decom,prod

; p4A	32E x 8D x 32M x  0A 	8192
; p4B	16E x 4D x 16M x 16A 	16384
; p4C	32E x 4D x  8M x 16A 	16384 
; p4D	32E x 0D x  8M x 16A	4096
; sort to E,D,A,M

	dbyt = 3			; data bytes per measurement
	mcyc = 512			; message cycles per measurement, p1=128, p2=32, p3=32, p4=512
	ocyc = 192			; message cycle offset, p1=0, p2=128, p3=160, p4=192
	mlen = 48			; message data length in words
	nmes = 2l*mlen/dbyt		; number of data points in a message
	nsam = mcyc*nmes		; number data points in a sample (4 sec)


	ocyc = min(prod.cyclestep)
	ind  = where(prod.cyclestep eq ocyc,count)
	mini = ind[0]
	maxi = ind[count-2]+mcyc-1
	ncyc = (maxi-mini+1)
	npts = ncyc*nmes
	tmp2 = lonarr(npts)
	pd   = lonarr(nsam,count-1)
;	dd   = lonarr(count-1,nsam)

	tmp     = reform(byte(prod[mini:maxi].data,0,dbyt*npts),dbyt,npts)
	time	= prod[ind].time 	& time  = time[0:count-2]
	p4sel	= prod[ind].p4sel	& p4sel = p4sel[0:count-2]
	tmp2 	= reform(tmp[0,*]+256l*(tmp[1,*]+tmp[2,*]*256l))
	
	for j=0,count-2 do begin
		jj = (ind[j]-ind[0])*nmes
		pd[*,j] = tmp2[jj:jj+nsam-1]
		if jj+nsam ne (ind[j+1]-ind[0])*nmes then print,'Missing packet at ',time_string(time[j])
	endfor

	pd=transpose(pd)
	

; make tplots

	p_en = lonarr(count-1,32)
	p_an = lonarr(count-1,64)
	p_ma = lonarr(count-1,32)

	for j=0,count-2 do begin
		case p4sel[j] of
		0: begin
			pp = reform(pd[j,*],32,8,32,2)
			pp = transpose(pp,[2,1,0,3])
			p_en[j,*] 	= total(total(pp[*,*,*,0],2),2)
			p_an[j,0:7] 	= total(total(pp[*,*,*,0],1),2)
			p_ma[j,*] 	= total(total(pp[*,*,*,0],1),1)
;			dd[j,*]		= pp
		end
		1: begin
			pp = reform(pd[j,*],16,16,4,16)
			pp = reform(transpose(transpose(pp,[0,3,2,1]),[1,0,2,3]),16,64,16)
			p_en[j,0:15] 	= total(total(pp[*,*,*],2),2)
			p_an[j,*] 	= total(total(pp[*,*,*],1),2)
			p_ma[j,0:15] 	= total(total(pp[*,*,*],1),1)
;			dd[j,*]		= pp
		end
		2: begin
			pp = reform(pd[j,*],16,8,4,32)
			pp = reform(transpose(transpose(pp,[0,3,2,1]),[1,0,2,3]),32,64,8)
			p_en[j,*] 	= total(total(pp[*,*,*],2),2)
			p_an[j,*] 	= total(total(pp[*,*,*],1),2)
			p_ma[j,0:7] 	= total(total(pp[*,*,*],1),1)
;			dd[j,*]		= pp
		end
		3: begin
			pp = reform(pd[j,*],16,8,32,4)
			pp = transpose(transpose(pp,[0,2,1,3]),[1,0,2,3])
			p_en[j,*] 	= total(total(pp[*,*,*,0],2),2)
			p_an[j,0:15] 	= total(total(pp[*,*,*,0],1),2)
			p_ma[j,0:7] 	= total(total(pp[*,*,*,0],1),1)
;			dd[j,*]		= pp
		end
		endcase
	endfor

	store_data,'STA_P4_en',data={x:time,y:p_en,v:findgen(32)}
		options,'STA_P4_en','spec',1
		zlim,'STA_P4_en',.1,1000.,1
	store_data,'STA_P4_an',data={x:time,y:p_an,v:findgen(64)}
		options,'STA_P4_an','spec',1
		zlim,'STA_P4_an',.1,1000.,1
	store_data,'STA_P4_ma',data={x:time,y:p_ma,v:findgen(32)}
		options,'STA_P4_ma','spec',1
		zlim,'STA_P4_ma',.1,1000.,1
		ylim,'STA_P4_ma',-1,33,0

	return,pd
;	return,dd

end

