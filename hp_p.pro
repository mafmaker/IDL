pro hp_p,year,day,hp,ut,maxnorm=maxnorm


;
; To reflect the index programs hp_p, ae_p, and dst_p, here is hp_p!
; Use keyword maxnorm to drop high correction passes
; 

starttime=[year,day,0,0]
endtime=[year,day,23,59]

get_noaa_p,starttime,endtime,hp,ut,index,hemi,sat, norm
if keyword_set(maxnorm) gt 0 then begin
  todo=where(norm lt maxnorm)
  hp=hp(todo)
  ut=ut(todo)
endif

return
end
