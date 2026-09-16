;20160404 Ali
;this is a revised version of Davin's average_hist function
;FUNCTION average_hist2(a,x)
;returns the average of "a", binned according to binsized "x"
;can handle up to 5 dimentional "a"
;(e.g. MAVEN STATIC time-energy-anode-deflection-mass spectra)
;centertime is output
;to be called by mvn_pui_model > mvn_pui_data_res

function average_hist2,a,x,binsize=binsize,trange=trange,centertime=centertime
  tdrange=time_double(trange)
  h=histogram(x,binsize=binsize,min=tdrange[0],max=tdrange[1]-binsize,locations=centertime,reverse=ri,/nan)
  centertime+=binsize/2
  sizea=size(a)
  sizeh=size(h)
  nan=!values.d_nan
  if (sizea[0] eq 1) then avg=replicate(nan,sizeh[1])
  if (sizea[0] eq 2) then avg=replicate(nan,sizeh[1],sizea[2])
  if (sizea[0] eq 3) then avg=replicate(nan,sizeh[1],sizea[2],sizea[3])
  if (sizea[0] eq 4) then avg=replicate(nan,sizeh[1],sizea[2],sizea[3],sizea[4])
  if (sizea[0] eq 5) then avg=replicate(nan,sizeh[1],sizea[2],sizea[3],sizea[4],sizea[5])
  whn0=where(h,count)
  for j=0l,count-1 do begin
    i=whn0[j]
    ind=ri[ri[i]:ri[i+1]-1]
    avg[i,*,*,*,*]=average(a[ind,*,*,*,*],1)
  endfor
  return,avg
end
