pro plot_crs, path

; plot the cross section from degrad

common crs, energy, de, ethr_n2, ethr_o2, ethr_o, c_n2, c_o2, c_o, $
	    exc_n2, exc_o2, exc_o, elastic_n2, elastic_o2, elastic_o, $
	    states_n2, states_o2, states_o, n_species, nstat_n2, nstat_o2, $
	    nstat_o, nmax

read_crs, path

nstat=[nstat_n2, nstat_o2, nstat_o]
specs=['N!i2!n', 'O!i2!n', 'O']
exc=fltarr(3,max(nstat),nmax)
exc(0,0:nstat_n2-1,*)=exc_n2
exc(1,0:nstat_o2-1,*)=exc_o2
exc(2,0:nstat_o-1,*)=exc_o
states=strarr(3,max(nstat))
for j=0,nstat_n2-1 do states(0,j)=strtrim(strmid(states_n2,j*8,8),2)
for j=0,nstat_o2-1 do states(1,j)=strtrim(strmid(states_o2,j*8,8),2)
for j=0,nstat_o-1 do states(2,j)=strtrim(strmid(states_o,j*8,8),2)

if not !d.flags/256 then device, yoffset=5., ysize=22.
!p.multi=[0,2,4]

count=0
for i=0,n_species-1 do begin
  for j=0,nstat(i)-1 do begin
    if (count mod 8) eq 0 and !d.flags/256 then window, /free, ysize=800
    count=count+1
    plot_oo, energy, exc(i,j,*), title=specs(i)+'('+states(i,j)+')', xtitle='Energy (eV)', $
       ytitle='Cross section (cm!e2!n)', yrange=[1e-20, 1e-15], $
       xrange=[1., max(energy)]
  endfor
endfor

stop
end
