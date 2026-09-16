
function mav_sta_tdc1_cal,d,param=p
   if not keyword_set(p) then begin
      p = {func:'mav_sta_tdc1_cal',anode:0, p1:average(d.tdc1,/double),  p3:average(d.tdc3,/double) , p4:average(d.tdc4,/double),m3:.001d,  m4:.001d }
   endif
   if not keyword_set(d) then return,p
   tof =  (d.tdc1- p.p1) + p.m3*(d.tdc3 - p.p3) + p.m4*(d.tdc4 - p.p4)
   return,tof
end


function mav_sta_instpos,a
   dts = replicate(2.,17)
   dts[9] = 4
   idts = total(dts,/cum)

   deltat =interp(findgen(17),idts,a) ;- idts[16]


end



pro spp_static_anodes,starta,stopa,xb

stop_x0 = [-575.1, -502.9, -430.8, -351.5, -269.5, -197.3, -123.2, -45.9, 41.1, 115.2,  191.6, 272.3, 348.7, 423.7, 497.2, 572.2]
stop_sig= stop_x0 *0 + 7

anode =[ 1,         2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
start_x0 =[-569.4, -500.1, -426.5, -345.9 ,-273.7, -194.5, -122.6, -51.6, 39.4, 124.,    188.,   261. ,  333, 408.1, 476.0, 551.0]
start_sig=start_x0 * 0 +8

starta = fix(xb) * 0 -1
stopa  = fix(xb) * 0 -2

for i=0,15 do begin
   w = where( abs(xb - start_x0[i]) lt start_sig[i] ,nw)
   if nw gt 0 then starta[w] = anode[i]

   w = where( abs(xb - stop_x0[i]) lt stop_sig[i] ,nw)
   if nw gt 0 then stopa[w] = anode[i]

endfor

end



pro spp_static_pngs,str
if not keyword_set(str) then str= 'x'
wset,8
makepng,'TDC3+TDC4_'+str
wset,1
makepng,'TDC1_'+str
wset,2
makepng,'TDC2_'+str
wset,3
makepng,'TDC4-vs-TDC3_'+str
wset,4
makepng,'TDC2-vs-TDC1_'+str
wset,5
makepng,'TDC2-vs-TDC1_filt_'+str
wset,7
makepng,'Custom_'+str
end


if n_elements(anode) eq 0  then anode = 0


if 1 then begin
  if not keyword_set(tt) then tt=[0d,1d10]
  if not keyword_set(tr) then tr = tt
  timebar,tr,color=3,/transient   ; draw old
  ctime,tt,npoints=2
  timebar,tr,color=3,/transient  ; erase old
  if n_elements(tt) eq 2 then  tr=minmax(tt)
  w = where(rawdat.time ge tr[0] and rawdat.time le tr[1],nw)
  if nw ne 0 then adat=rawdat[w] ;else adat = rawdat
  wshow,0,icon=1
  title = 'STATIC '+ strjoin( time_string(tr) , ' to ' ) + '  Anode= '+strtrim(anode)
endif



!x.margin=10



; crosshairs

;pro spp_static_read2
xrange = [100,300]   & xlog = 0
xrange = [10,1100]   & xlog = 1
xlim,lim,xrange,log=xlog
psym = 10
;anode = 10   &  adat=0

if keyword_set(adat) eq 0 && ( n_elements(last_anode) eq 0 || (anode ne last_anode)) then  begin
   adat=0
   anodestr = keyword_set(anode) ? 'A'+strtrim(anode,2) : 'A'+strtrim([2,3,4,5,6,7,8,9,10,11,12,13],2)
   source = mav_file_source()
   dir = 'maven/sta/prelaunch/misc/2011_12_06_beamtest/'
   file = file_retrieve(dir+'misg_all_msg_'+anodestr+'_4keV_13kV_nom.dat',_extra=source)
   title = file_basename(file)
   dformat = {UTC:0L,CYCLESTEP:0L,TDC1:0L,TDC2:0L,TDC3:0L,TDC4:0L,PA:0L,PB:0L,PC:0L,PD:0L,CF:0L,AF:0L}
   for i=0,n_elements(file)-1 do adat = read_asc(file[i],verbose=0,append=adat,format=dformat) ;,/tags)
   if i gt 1 then title='*.dat'
   if i gt 1 then anodestr = 'A0'

   adat.tdc3 = (1 - adat.af *2) * adat.tdc3
   adat.tdc4 = (1 - adat.cf *2) * adat.tdc4
   last_anode = anode
   w0=0

endif

if 1 then begin
   mnb = 5
   mxb = 1023
   ndat = n_elements(adat)
   bad =        abs(adat.tdc3) le mnb or abs(adat.tdc4) le mnb
   bad = bad or abs(adat.tdc3) ge mxb or abs(adat.tdc4) ge mxb
   bad = bad or adat.tdc1 le mnb or adat.tdc2 le mnb
   bad = bad or adat.tdc1 ge 1023 or adat.tdc2 ge 1023
   wgood = where(~ bad, ngood)
   adat = adat[wgood]
   dprint,dlevel=0, 'Kept ',ngood,' of ',ndat
endif



yrange=[.5,1e6]

wi,8
plot,xrange=[-1100,1100],yrange=yrange,/ylog,/ystyle,indgen(3),/nodata,/xstyle,title=title,xtitle='Position TDC'

brange = [-1023.5,1023.5]

oplot,xp,histbins(adat.tdc4,xp,binsize=1,range=brange,/shift),color=6,psym=psym
oplot,xp,histbins(adat.tdc3,xp,binsize=1,range=brange,/shift),color=4,psym=psym

spp_static_anodes,starta,stopa,xp


;oplot,xp,100*10.^(stopa/1.),color=6
;oplot,xp,100*10.^(starta/1.),color=4

wi,1
w = where(finite(adat.tdc1))

plot,xt,histbins(adat.tdc1,xt,binsize=1,range=[-.5,1023.5]),xtitle='TDC1',/ylog,yrange=yrange,/ystyle,xrange=xrange,xlog=xlog,/xstyle,/nodata,title=title
oplot,xt,histbins(adat.tdc1,xt,binsize=1,range=[-.5,1023.5]), color=4,psym=psym

ok = adat.tdc3 ne 99999
a3 = starta[adat.tdc3+1023]
a4 = stopa[adat.tdc4+1023]
ok = ok and (a3 eq a4) and ((anode eq 0) or (a3 eq anode))
w = where( ok, nw )
if nw eq 0 then begin
   dprint,'No valid data points selected- choose another anode'
   message,'Error'
endif

h = histbins(adat[w].tdc1,xb,binsize=1)
oplot,xb,h,color=2,psym=psym

p = mgauss(numg=1)
p.binsize=1
p.shift = 0

mx = max(h * (xb gt 10 and xb lt 1000),mxbin)
w1 = where(xb ge (xb[mxbin]-5)  and xb le (xb[mxbin]+5))
p.g[0].x0 = xb[mxbin]
p.g[0].a  = total(h[w1])
p.g.s = 1

fit ,param=p,xb[w1],h[w1] , names='g'
pf,p,color=6,psym=10
oplot,xb[w1],h[w1],/psym
printdat,p,outp=outs ,/val
xyouts,.4,.9,strjoin(outs+'!c'),/norm



wi,2
plot,xb,histbins(adat.tdc2,xb,binsize=1),xtitle='TDC2',/ylog,yrange=yrange,/ystyle,xrange=xrange,xlog=xlog,/xstyle,/nodata,title=title
oplot,xb,histbins(adat.tdc2,xb,binsize=1), color=4,psym=psym

h = histbins(adat[w].tdc2,xb,binsize=1)
oplot,xb,h,color=2,psym=psym

mx = max(h * (xb gt 10 and xb lt 1000),mxbin)
w1 = where(xb ge (xb[mxbin]-4)  and xb le (xb[mxbin]+4))
p.g[0].x0 = xb[mxbin]
p.g[0].a  = total(h[w1])
p.g.s = 1
fit ,param=p,xb[w1],h[w1] , names='g'

pf,p,color=6,psym=10
oplot,xb[w1],h[w1],/psym

printdat,p,outp=outs ,/val
xyouts,.4,.9,strjoin(outs+'!c'),/norm


pcal = polycurve()
pcal.a0 = 5.302
pcal.a1 = 1.021

dtof = adat.tdc2-func(adat.tdc1,param=pcal)



print,float(n_elements(w))/n_elements(adat)



if not keyword_set(wsize) then wsize = [700,600]  ; wsize = fix(wsize * 1.2)

zlim,lim2,.5,1e4,1
xlim,lim2,-1100,1100
ylim,lim2,-1100,1100
options,lim2,/no_interp,title=title


wi,3,wsize=wsize
h2 = histbins2d(adat.tdc3,adat.tdc4,xb2,yb2,xbinsize=4,ybinsize=4)
specplot,xb2,yb2,h2,lim=struct(lim2,xtitle='TDC3',ytitle='TDC4')
oplot,dgen(),dgen()


if 1 then begin
dprint,'Select ranges' ;,cx,cy

  cyx = [0,0,1,1,0]  & cyy = [0,1,1,0,0]
;  oplot, cx
  if (n_elements(tdc3_r)+n_elements(tdc4_r)) eq 4 then oplot,tdc3_r[cyx],tdc4_r[cyy]
;  cx=0
  wshow
  crosshairs,cx,cy,nselected=np
  if n_elements(cx) eq 2 then begin
    if (n_elements(tdc3_r)+n_elements(tdc4_r)) eq 4 then oplot,tdc3_r[cyx],tdc4_r[cyy],color=5
    tdc3_r = minmax(cx)
    tdc4_r = minmax(cy)
    oplot,tdc3_r[cyx],tdc4_r[cyy]
  endif
endif




xlim,lim2,-100,1100
ylim,lim2,-100,1100
wi,4,wsize=wsize
h2 = histbins2d(adat.tdc1,adat.tdc2,xb2,yb2,xbinsize=4,ybinsize=4)
specplot,xb2,yb2,h2,lim=struct(lim2,xtitle='TDC1',ytitle='TDC2')
oplot,dgen(),dgen()


wi,5,wsize=wsize
h2 = histbins2d(adat[w].tdc1,adat[w].tdc2,xb2,yb2,xbinsize=4,ybinsize=4)
specplot,xb2,yb2,h2,lim=struct(lim2,xtitle='TDC1',ytitle='TDC2')
oplot,dgen(),dgen()
pf,pcal,/over




wi,6
xtitle = '' & ytitle = ''
;dtx = -100 > (adat.tdc2 - adat.tdc1) < 100  & xtitle = 'TDC2-TDC1'
;dtx = -100 > ((adat.tdc2 - adat.tdc1) - (adat.tdc3-adat.tdc4)/2.7) < 100  & xtitle = 'TDC2-TDC1 - (TDC3-TDC4)/2.7'
;dtx =  ((adat.tdc1 + adat.tdc1)/2. +0* (adat.tdc3-adat.tdc4)/2.7) < 500   & xtitle = '(TDC2+TDC1)/2 + (TDC3-TDC4)/2.7'
dtx = -650 > (adat.tdc3  - adat.tdc4)  <650  & xtitle = 'TDC3-TDC4'
;dtx = adat.tdc4                     & xtitle = 'TDC4'
;dtx = adat.tdc3                     & xtitle = 'TDC3'


dtx = adat.tdc1     <500                 & xtitle = 'TDC1'
;dtx = adat.tdc2     <500                 & xtitle = 'TDC2'
;dtx = (adat.tdc1 + (+0.37)*(adat.tdc3-adat.tdc4))   <500        & xtitle = 'TDC1 + 0.37*(TDC3-TDC4)' ; use for anode 16
;dtx = adat.tdc2     <500                 & xtitle = 'TDC2'   ; use for anode 16
;dtx = (adat.tdc2 + (-0.37)*(adat.tdc3-adat.tdc4))   <500        & xtitle = 'TDC2 - 0.37*(TDC3-TDC4)'

;dty = adat.tdc2                   & ytitle = 'TDC2'
;dty = (adat.tdc2 +adat.tdc1)/2                  & ytitle = '(TDC1+TDC2)/2'
;dty = -150 > (adat.tdc3-adat.tdc4)  < 150       & ytitle= 'TDC3-TDC4'
;dty = -650 > (adat.tdc3+adat.tdc4)/2.  < 650       & ytitle= '(TDC3+TDC4)/2'    & yrange= [-650,650]
dty = -650 > (adat.tdc3)   < 650       & ytitle= 'TDC3' & yrange= [-650,650]
dty = -650 > (adat.tdc4)   < 650       & ytitle= 'TDC4' & yrange= [-650,650]



dtx =dtx[w]
dty =dty[w]

;if not keyword_set(w0) then
w0 = lindgen(n_elements(dtx))
;  w0= enclosed(dtx,dty,cx,cy,ncircs=ncircs)

h = histbins(dtx[w0],xb,binsize=1)
plot,xb,h > .2,/ylog,/xstyle   , xtitle=xtitle,title=title,psym=psym


wi,7
h2 = histbins2d(dtx[w0],dty[w0],xb2,yb2,xbinsize=1,ybinsize=2)
specplot,xb2,yb2,h2,lim=struct(lim2,xrange=[0,0],yrange=[0,0],xtitle=xtitle,ytitle=ytitle,title=title)



wi,9
yrange = [-40,40]
xrange = [0,500]
dty = yrange[0] > (adat.tdc3-adat.tdc4)  < yrange[1]       &   ytitle= 'TDC3-TDC4

 CF = 0.37 &  dtx = (adat.tdc1 + CF*(adat.tdc3-adat.tdc4))   <500        & xtitle = 'TDC1 + C*(TDC3-TDC4)  C= '+strtrim(CF,2)
 CF = 0.0  &  dtx = (adat.tdc2 + CF*(adat.tdc3-adat.tdc4))   <500        & xtitle = 'TDC2 + C*(TDC3-TDC4)  C= '+strtrim(CF,2)
 CF = 0. &  dtx = (adat.tdc1 + CF*(adat.tdc3-adat.tdc4))   <500        & xtitle = 'TDC1 + C*(TDC3-TDC4)  C= '+strtrim(CF,2)
; CF = -.37  &  dtx = (adat.tdc2 + CF*(adat.tdc3-adat.tdc4))   <500        & xtitle = 'TDC2 + C*(TDC3-TDC4)  C= '+strtrim(CF,2)

;dy3 = -650 > adat.tdc3 < 650

dtx =dtx[w]
dty =dty[w]
;dy3 =dy3[w]

w0 = lindgen(n_elements(dtx))
h = histbins(dtx[w0],xb,binsize=1,range=xrange+[-.5,.5])
h2 = histbins2d(dtx[w0],dty[w0],xb2,yb2,xbinsize=1,ybinsize=1,yrange=yrange+[-.5,.5],xrange=xrange+[-.5,.5])
;h3 = histbins2d(dtx[w0],dy3[w0],xb3,yb3,xbinsize=1,ybinsize=5,yrange=[-500.5,500.5],xrange=xrange +[-.5,.5])

!p.multi = [0,1,2]
;specplot,xb3,yb3,h3,lim=struct(lim2,xrange=[0,0],yrange=[0,0],xtitle=xtitle,ytitle=ytitle3,title=title)
specplot,xb2,yb2,h2,lim=struct(lim2,xrange=[0,0],yrange=[0,0],xtitle=xtitle,ytitle=ytitle,title=title)
plot,xb,h > .2,/ylog,/xstyle   , xtitle=xtitle,psym=psym
!p.multi =0


p = mgauss(numg=1)
p.binsize=1
p.shift = 0
mx = max(h * (xb gt 10 and xb lt 400),mxbin)
w1 = where(xb ge (xb[mxbin]-5)  and xb le (xb[mxbin]+5))
p.g[0].x0 = xb[mxbin]
p.g[0].a  = total(h[w1])
p.g.s = 1

fit ,param=p,xb[w1],h[w1] , names='g'

;p=p2
pf,p,color=6,psym=10
oplot,xb[w1],h[w1],/psym
printdat,p,outp=outs ,/val,nstr=6
xyouts,.6,.45,strjoin(outs+'!c'),/norm

oplot,xb,smooth(h-func(xb,param=p),5),color=3,psym=psym


if not keyword_set(pp) then pp = replicate(p,17)

pp[anode] = p

;wi,8
wi,10

tdc1_r = [35,60]

printdat,ok,adat
ok = ok and ((adat.tdc3 ge tdc3_r[0]) and (adat.tdc3 le tdc3_r[1]))
ok = ok and ((adat.tdc4 ge tdc4_r[0]) and (adat.tdc4 le tdc4_r[1]))
ok = ok and ((adat.tdc1 ge tdc1_r[0]) and (adat.tdc1 le tdc1_r[1]))

w = where(ok)
d = adat[w]

pc=0
val = mav_sta_tdc1_cal(d,param=pc)
hv = histbins(val,xv,binsize=1)
plot,xv,hv > .5, /ylog;,psym=10

fit,d,w*0.,param=pc,name='m3 m4 p3 p4'


val = mav_sta_tdc1_cal(d,param=pc)
hv = histbins(val,xv,binsize=1)
oplot,xv,hv > .5,color=2;,psym=10

g0 = mgauss(binsize=1.)
g0.g.a = n_elements(val)
fit,xv,hv,param=g0,name='g'
pf,g0,/over,color=6

  FMT = '(1(g10.4," "),1(i9," "),1(i4," "),1(i4," "),1(i5," "),1(i5,"  "),1(b06," "),1(i2," ")," ")'





wi,11
ok = adat.tdc3 ne 99999
a3 = starta[adat.tdc3+1023]
a4 = stopa[adat.tdc4+1023]
ok = ok and (a3 eq a4) and ((anode eq 0) or (a3 eq anode))
;ok = ok and ((adat.tdc3 ge tdc3_r[0]) and (adat.tdc3 le tdc3_r[1]))
;ok = ok and ((adat.tdc4 ge tdc4_r[0]) and (adat.tdc4 le tdc4_r[1]))
;ok = ok and ((adat.tdc1 ge tdc1_r[0]) and (adat.tdc1 le tdc1_r[1]))

w = where(ok)
d = adat[w]

yrange = [-40,40]
xrange = [0,500]
dty = yrange[0] > (adat.tdc3-adat.tdc4)  < yrange[1]       &   ytitle= 'TDC3-TDC4
dtx = 50. + func(adat,param=pc)  & xtitle = 'Corrected TDC1'

dtx =dtx[w]
dty =dty[w]
;dy3 =dy3[w]

w0 = lindgen(n_elements(dtx))
h = histbins(dtx[w0],xb,binsize=1,range=xrange+[-.5,.5])
h2 = histbins2d(dtx[w0],dty[w0],xb2,yb2,xbinsize=1,ybinsize=1,yrange=yrange+[-.5,.5],xrange=xrange+[-.5,.5])
;h3 = histbins2d(dtx[w0],dy3[w0],xb3,yb3,xbinsize=1,ybinsize=5,yrange=[-500.5,500.5],xrange=xrange +[-.5,.5])

!p.multi = [0,1,2]
;specplot,xb3,yb3,h3,lim=struct(lim2,xrange=[0,0],yrange=[0,0],xtitle=xtitle,ytitle=ytitle3,title=title)
specplot,xb2,yb2,h2,lim=struct(lim2,xrange=[0,0],yrange=[0,0],xtitle=xtitle,ytitle=ytitle,title=title)
plot,xb,h > .2,/ylog,/xstyle   , xtitle=xtitle,psym=psym
!p.multi =0


p = mgauss(numg=1)
p.binsize=1
p.shift = 0
mx = max(h * (xb gt 10 and xb lt 400),mxbin)
w1 = where(xb ge (xb[mxbin]-5)  and xb le (xb[mxbin]+5))
p.g[0].x0 = xb[mxbin]
p.g[0].a  = total(h[w1])
p.g.s = 1

fit ,param=p,xb[w1],h[w1] , names='g'

;p=p2
pf,p,color=6,psym=10
oplot,xb[w1],h[w1],/psym
printdat,p,outp=outs ,/val,nstr=6
xyouts,.6,.45,strjoin(outs+'!c'),/norm

oplot,xb,smooth(h-func(xb,param=p),5),color=3,psym=psym

dprint,'Done'
end
