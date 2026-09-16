;$Author: nikos $
;$Date: 2014-07-10 10:01:21 -0700 (Thu, 10 Jul 2014) $
;$Header: /home/cdaweb/dev/control/RCS/b_lib.pro,v 1.18 1997/09/25 12:53:11 baldwin Exp kovalick $
;$Locker: kovalick $
;$Revision: 15545 $
;+
; NAME: MAKE_TICK.PRO
;
; PURPOSE:  Make tick mark on orbit or trace plot
;
; CALLING SEQUENCE:
;
;  make_tick,lat,lon,symsiz=symsiz,symcol=symcol
;
 pro make_tick,lat,lon,symsiz=symsiz,symcol=symcol,map=map  

if(n_elements(map) eq 0) then mp=0L else mp=1L
 scal=1.0
;print, !x.crange
xdif=!x.crange(1)-!x.crange(0)/2.0 
; if(mp) then scal=25.0*xdif/45.0 else scal=xdif/45.0
 if(mp) then scal=45.0*xdif/45.0 else scal=xdif/45.0
  y=lat(1)-lat(0)
  x=lon(1)-lon(0)
  if(x gt 350) then x=(lon(1)-360.0)-lon(0) 
  if(x lt -350) then x=lon(1)-(lon(0)-360.0) 
  theta=atan(y,x)
  dx=scal*symsiz*sin(theta)
  dy=scal*symsiz*cos(theta)
  tlat=fltarr(2)
  tlon=fltarr(2)
   tlat(0)=lat(0)-dy
   tlon(0)=lon(0)+dx
   tlat(1)=lat(0)+dy
   tlon(1)=lon(0)-dx

   oplot,tlon,tlat,color=symcol
return
end

function time_incr,t
;determine time scale of typical time steps 't'.
n = n_elements(t)
dt = t(1:n-1)-t(0:n-2)
tinc = min(dt)*2.
ii = where( dt lt tinc)
m=n_elements(ii)
print,'time interval:',tinc,' N(dt<tinc)/N(dt):',m/float(n)
return, tinc
end

function sgn,x
if x ne 0 then return,x/abs(x) else return, 1.
end

pro chsize,xchsize,ychsize,norm=norm                                              
if n_elements(norm) eq 0 then norm =1
;compute size of standard character in normalized units
xcharsize=1.
Xchsize = float(!d.x_ch_size) / float(!d.x_size) * xcharsize
Ychsize = float(!d.y_ch_size) / float(!d.y_size) * xcharsize
if norm eq 0 then begin
   xchsize = Xchsize/!x.s(1)
   Ychsize = Ychsize/!y.s(1)
endif
;help,norm,xchsize,ychsize
end

pro pregion,nx,ny,jplot,device=device,edge=edge,xmargin=xmar,ymargin=ymar $
	,title=title,xt=xt,yt=yt,bkgrd=bkgrd,OVERPLOT=overplot,chtsz=chtsz
iplot= jplot mod (nx*ny)
;if iplot eq 0 then !p.noerase=0 else !p.noerase=1
if n_elements(overplot) eq 0 then overplot=0
if n_elements(xmar) eq 0 then xmar =2
if n_elements(ymar) eq 0 then ymar =2
if n_elements(chtsz) eq 0 then chtsz = 1.8 

;common deviceTypeC, deviceType
 deviceType=5
;divide plot area into nx by ny regions
;iplot is the plot number ranges from 0 to nx*ny-1

case devicetype of
   0:begin
        xm= [.05,.925]
        ym= [.05,.925]
     end
   4:begin
        xm= [.1,.9]
        ym= [.1,.9]
     end
else: begin
        xm= [.05,.9]
        ym= [.05,.9]
      end
endcase
if n_elements(edge) ne 0 then begin
        xm= [.0125,.9875]
        ym= [.0125,1.]
endif

if iplot eq 0 then begin
;  !p.noerase=0
   !p.noerase=1
   plot,[0,1],[0,1],/nodata,xstyle=5,ystyle=5 
;  !p.noerase=1
endif
if (n_elements(title) ne 0) then begin
	Ych = float(!d.y_ch_size) / float(!d.y_size) 
  	ym(1) = ym(1) - ych*1.5
	xt = total(xm)/2.
	yt = ym(1)
   if title ne ' ' then begin
      xyouts,/norm,xt,yt,title,charsize=chtsz,align=.5,color=bkgrd
   endif
endif
dy = (ym(1)-ym(0))/ny
dx = (xm(1)-xm(0))/nx
iy = fix(iplot/nx)
ix = iplot-iy*nx
y0 = ym(0) + (ny-iy-1)*dy
y1 = y0+dy
x0 = xm(0) + ix*dx
x1 = x0+dx
!p.region=[x0,y0,x1,y1]
;print,'plot region  :',!p.region
if n_elements(edge) eq 0 then !p.position=[x0,y0,x1,y1] $
else begin
;compute size of standard character in normalized units
   Xch = float(!d.x_ch_size) / float(!d.x_size) 
   Ych = float(!d.y_ch_size) / float(!d.y_size) 
  !p.position=[x0+(xmar(0))*xch,y0+ymar(0)*ych,x1-(xmar(1))*xch,y1-ymar(1)*ych] 
endelse

;print,'plot region  :',!p.region
;print,'plot position:',!p.position
end

function rdate1,epoch,cdate=cdate,format=format
cdf_epoch,epoch,yr,month,dom,hr,min,sec,msec,/break
ical,yr,doy,month,dom,/idoy ;compute doy
cdate={yr:yr,doy:doy,month:month,dom:dom,hr:hr,min:min,sec:sec,msec:msec}
if n_elements(format) eq 0 then format='yrdoyhrmin'

case format of
 'plan': $
      date = string( format= '(i4,5i3)' , yr, month,dom, hr,min,sec)
 'plan1': $
      date = string( format= '(i4,i3.3,x,i2.2,":",i2.2)',yr,doy,hr,min)
 'a': $
      date = string( format= '(i4,i4,3i3)' , yr, doy, hr,min,sec)
 'hhmm': $
      date = string( format= '(i2.2,":",i2.2," UT")' ,  hr,min)
 'doy': $
      date = string( format= '(i3.3)' , doy) 
 'yrdoyhr': $
      date = string( format= '(i4,i3.3,i2.2)' , yr, doy, hr) 
 'yrdoyhrmin': $
      date = string( format= '(i4,i3.3,2i2.2)' , yr, doy, hr,min)
 'rql': $
      date = string( format= '(i3.3,":",2(i2.2,":"),i2.2)' ,  doy, hr,min,sec)
 'all': $
      date = string(  $
      format= '(i4,x,i3.3,x,"(",i2.2,"/",i2.2,")",x,i2.2,":",i2.2," UT")'  $
      , yr,doy,month,dom,hr,min)
 'doydom': $
      date = string( $
    	   format= '(i4,x,i3.3," (",i2.2,"/",i2.2,") ", i2.2,":",i2.2," UT")' $
		, yr, doy,month,dom, hr,min)
 'yrdoy': $
      date = string( format= '(i4,i3.3)' , yr, doy)

 'yrmmdd':date = string( yr,month,dom, $ 
               format= '(i4,x,i2.2,"/",i2.2," UT ")' )

 'yyyymmdd':date = string( yr,month,dom, $
               format= '(i4,i2.2,i2.2)')

 'yyyydoyhrminsec':date = string( yr,doy,hr,min,sec,msec/10 $ 
		,format= '(i4,x,i3,3(x,i2.2),".",i2.2)' )
 'mm/dd/yy':date = string( month,dom,yr, $
               format= '(i4.4,"/",i2.2,"/",i2)')    
 else:begin
     date = string( $
               format= '(i4,x,i2.2,"/",i2.2," ",i2.2,":",i2.2," UT ")' $
               ,yr,dom,month,hr,min)
      date = string( format= '(i4,i3.3,2i2.2)' , yr, doy, hr,min)
 end
endcase

return,date
end

function pdate,epoch,icase=icase
cdf_epoch,epoch,yr1,month1,dom1,hr1,min1,sec1,msec1,/break
ical,yr1,doy1,month1,dom1,/idoy ;compute doy
if (n_elements(icase) eq 0) then icase = 1
if (n_elements(idom) ne 0 ) then icase = 0
case icase of
   0:begin ;yr/dom/hr/min
        date = string( $
               format= '(i4,x,i2.2,"/",i2.2," ",i2.2,":",i2.2," UT ")' $
               ,yr1,dom1,month1,hr1,min1)
     end
   1:begin ;yr/doy/hr/min
        date = string( format= '(i4,x,i3," ",i2.2,":",i2.2," UT ")' $
               ,yr1,doy1,hr1,min1)
     end
   2:begin ;y/doy/hr/min/sec
        date = string( format= '(i4,x,i3," ",i2.2,":",i2.2,":",i2.2," UT ")' $
               ,yr1,doy1,hr1,min1,sec1)
     end
endcase
return,date
end

function tod1,hr,min,sec
return, (hr*60 + min)*60 + sec
end

pro ical,yr,doy,month,dom,eom=eom,idoy = idoy ;set idoy=1 to compute day of year
;eom - set to compute the doy  -> to the end of the month
if( n_params() eq 0 ) then begin
	print,'positional param: yr,doy,month,dom
	print,'keyword: idoy = 0-doy to month and dom, 1-month dom to doy'
	return
endif
if( n_elements(idoy) eq 0 ) then idoy = 0
days=[31,28,31,30,31,30,31,31,30,31,30,31]
yr0=yr
if yr0 lt 100 then yr0=1900+yr0

if( ((yr0-1900) mod 4) eq 0)then begin
	days(1) = 29 ;leap year
;        print,'year:',yr0,' is a leap year'
endif else days(1) = 28

if keyword_set(eom) then begin
   idoy = 1
   dom = days(month-1)
endif

if(idoy eq 1)then begin
	doy =dom
	for i= 0,month-2 do doy = doy + days(i)
	return
endif else begin
	dom = doy
	for month = 1,12 do begin
		if( dom le days(month-1)) then goto, jump
		dom = dom - days(month-1)
	endfor
endelse
print,' error in date conversion'
jump:return
end	

function epoch0,yr0,doy0,tod0
yr=yr0
doy=doy0
if n_elements(tod0) eq 0 then tod0 = 0d0
tod=tod0
if n_params() eq 0 then begin
   print,'function,epoch0:yr,doy,tod
   return,-1
endif
if n_params() eq 2 then doy=0d0
;ep0 is epoch at start of 20th cent.
;tod - time of doy in seconds
;doy - day of year starting at 1
;yr - ie 1974 is 74
;if(yr gt 1000)then yr=yr-1900
yr = yr mod 1900
ep0 = 5.99582304d13
return,(yr*365d0 + fix((yr-1)/4)+ doy-1)*8.64d7 +tod*1000d0 + ep0
end
pro sibeck2,rhomp,xmp,rhobs,xbs,a=a,b=b,c=c,press=press,bz=bz0
; xmp - x [RE] location of magnetopause
; rhomp = sqrt(ymp^2+zmp^2) distance of mp from x-axis 
; xbs - x [RE] location of bowshock 
; rhobs = sqrt(ybs^2+zbs^2) distance of bs from x-axis 
; press - solar wind pressure in nPa
; bz - IMF Bz component in nT
; note: I clip bz if |bz| > 6.5 nT
; also for low pressure (i.e. .1 nT) the subsolar point moves earthward
; instead of anti-earthward
if n_elements(bz0) eq 0 then read,'input IMF bz(nT)?',bz0
if n_elements(press) eq 0 then read,'input SW pressure(nPa)?',press
if abs(bz0) gt 6.5 then begin
   bz = bz0/abs(bz0)*6.5
   print,' |Bz| clipped at 6.5'
endif else bz = float(bz0)
y=bz+0.1635
x=press/2.088
z=alog(x)
a=0.171*x^(-0.474-0.616*z+0.023*y)*exp(-0.043*y+0.0391*y*y)
b=18.80*x^(-0.120-0.030*z+0.036*y)*exp(-0.037*y+0.0002*y*y)
c=-220.8*x^(-0.290-0.110*z+0.018*y)*exp(-0.012*y+0.0017*y*y)
pt = 100
rhomp = indgen(pt)*1.
xmp = fltarr(pt)
for j=0,pt-1 do begin
    r=rhomp(j)
    r2=r*r
    fact=b*b-4.0*a*(c+r2)
    if(fact lt 0.0) then goto, jump
    xx=(-b+sqrt(fact))/(2.0*a)
    xmp(j) = xx
endfor
jump:
if( j lt (pt-1) )then begin
    rhomp(j:pt-1) = rhomp(j-1)
    xmp(j:pt-1) = xmp(j-1) - (1 + indgen(pt-j) )
endif
;
;
pt=80
rhobs = fltarr(pt)
xbs = fltarr(pt)
for j=0,pt-1 do begin
    r=float(j)
    r2=r*r
    xxx=(-r2+623.77*x^(-0.3333))/(44.916*x^(-0.1666))
    rhobs(j) = r
    xbs(j) = xxx
endfor
rhobs = rhobs(0:j-1)
xbs = xbs(0:j-1)


end

pro even_scales,xr,yr,xr0,yr0

scale_get,dx_dy
dx = xr(1)-xr(0)
dy = yr(1)-yr(0)
dxa = abs(dx)
dya = abs(dy)
dx0 = abs(dy*dx_dy)
dy0 = abs(dx/dx_dy)
;help,dx,dx0,dy,dy0
if (dx0 ge dxa) then i=0 else i=1

if (dx0 ge dxa) and (dy0 ge dya ) then begin
   dummy= min(abs([dx0-dxa,dy0-dya]),i)
endif
scale_get,dy_dx
if i eq 0 then begin
        xr0 = abs(dy_dx*(yr(1)-yr(0)) )/2*[-1.,1.]*dx/dxa + total(xr)/2.
        yr0 = yr
endif else begin
        xr0 = xr
        yr0 = abs(1/dy_dx*(xr(1)-xr(0)) )/2*[-1.,1.]*dy/dya + total(yr)/2.
endelse

;print,'x:',xr(1)-xr(0),xr0(1)-xr0(0)
;print,'y:',yr(1)-yr(0),yr0(1)-yr0(0)
end

pro scale_get,dy_dx
ysc = (!d.y_vsize/!d.y_px_cm)
xsc = (!d.x_vsize/!d.x_px_cm) 
dxr = !p.position(2)-!p.position(0)
dyr = !p.position(3)-!p.position(1)
if (dxr*dyr) eq 0 then begin
   dxr=1
   dyr=1
endif
;print,xsc,ysc
;print,dxr,dyr
dy_dx = (dxr/dyr)*(xsc/ysc)
;print,dy_dx
end

function binary_search,a,arr,istart
; search monotone increasing arrary 'arr'
;locate start rec by binary search
nrec = n_elements(arr)
if (n_elements(istart) ne 0) then irec0 = long(istart) else irec0 = 0l
irec1 = nrec-1
if a ge arr(nrec-1) then return,nrec-1
if a le arr(0) then return,0
jump:
   irec = (irec0+irec1)/2l
   if irec eq irec0 then goto,found
   if a lt arr(irec) then irec1 = irec else irec0 = irec
goto,jump
found:
return,irec
end

;Changed name of this function from interp to orbit_interp
;to alleviate conflict w/ other routines w/ the same name
;TJK 10/25/2006
;function interp,x,xn,yn,extrap = extrap
function orbit_interp,x,xn,yn,extrap = extrap
n = n_elements(xn)
if x le xn(0) then begin
  if keyword_set(extrap) then i=0 else return,yn(0)
endif
if x ge xn(n-1) then begin
  if keyword_set(extrap) then i=n-2 else return,yn(n-1)
endif else i = binary_search(x,xn)
y =  yn(i) + (yn(i+1)-yn(i))*( (x-xn(i))/(xn(i+1)-xn(i)) )
return,y
end

pro b_lib
end
