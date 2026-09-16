pro multi_o1d, altitude, o1d

; Driver to read several PLOTEXR plotfiles from the transport code

pathlist=['/ph.ext_150e5', '/ph.ext_175e5', '/ph.ext_200e5', $
          '/ph.ext_225e5', '/ph.ext_250e5', '/ph.ext_275e5', $
          '/ph.ext_300e5', '/ph.ext_325e5', '/ph.ext_350e5', $
          '/ph.ext_375e5', '/ph.ext_400e5', '/ph.ext_425e5']
pickz=[150, 175, 200, 225, 250, 275, 300, 325, 350, 375, 400, 425]
get_o1d, '../output', pathlist(0), altitude, temp
ncases=n_elements(pathlist)
o1d=fltarr(n_elements(temp), ncases)
o1d(*,0)=temp

for i=1,ncases-1 do begin
    get_o1d, '../output', pathlist(i), altitude, temp
    o1d(*,i)=temp
endfor

plot, o1d(*,0), altitude, /xlog, $
  xtit='O(!e1!nD) excitation rate (cm!e-3!ns!e-1!n)', $
  ytit='altitude (km)', xr=[max(o1d)*1e-4, max(o1d)], yr=[100,500]
for i=1,ncases-1 do oplot, o1d(*,i), altitude

;iz=[75, 57, 43, 32, 22, 14]
nn=ncases
iz=intarr(ncases)
for i=0,ncases-1 do iz(i)=where(abs(altitude-pickz(i)) eq $
                                min(abs(altitude-pickz(i)))) 
aa=o1d(iz,0:nn-1)
acof=invert(aa)#(fltarr(nn)+max(o1d))
o1d_sum=fltarr(n_elements(temp))
for i=0,nn-1 do o1d_sum=o1d_sum+o1d(*,i)*acof(i)
oplot, o1d_sum, altitude, psym=2

; return
stop
end
