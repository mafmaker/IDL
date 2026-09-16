;+
;PROCEDURE:	mav_sta_mass_hist_avg,tp=tp
;PURPOSE:	
;	makes a tplot structure from 'STA_MASSHIST_MASS' with only 64 mass bins
;
;CREATED BY:	J. McFadden
;VERSION:	1
;LAST MODIFICATION:  12/01/31
;MOD HISTORY:
;
;NOTES:	  
;	
;-

pro mav_sta_mass_hist_avg,tp=tp

    get_data,'STA_MASSHIST_MASS',data=tmp

    if keyword_set(tmp) then begin

	npts = n_elements(tmp.x)
	aa = lonarr(npts,64)
	ind1=indgen(8) & ind2=indgen(16) & ind3=indgen(32)

	for i=0,npts-1 do begin 
		for j=0,31 do aa(i,j) = total(tmp.y[i,j*8+ind1],2)
		for j=32,47 do aa(i,j) = total(tmp.y[i,(j-16)*16+ind2],2)
		for j=48,63 do aa(i,j) = total(tmp.y[i,(j-32)*32+ind3],2)
	endfor

	store_data,'STA_MASSHIST_MASS_avg',data={x:tmp.x,y:aa,v:indgen(64)}

	options,'STA_MASSHIST_MASS','spec',1
	options,'STA_MASSHIST_MASS_avg','spec',1
	zlim,'STA_MASSHIST_MASS',.1,1000.,1
	zlim,'STA_MASSHIST_MASS_avg',.1,1000.,1
	ylim,'STA_MASSHIST_MASS_avg',-2,66,0
	ylim,'STA_MASSHIST_MASS',-100,1200.,0

	if keyword_set(tp) then begin
		zlim,'STA_MASSHIST_MASS_avg',1,1.e6,1
		zlim,'STA_MASSHIST_MASS',1,1.e6,1
	endif

    endif
return
end
