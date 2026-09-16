;$Author: jimm $
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/orbit_plt.pro,v 1.127 2007/12/10 17:52:42 johnson Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $

;+
function get_depend0, astrc
;finding the epoch variable by looking at the depend_0 attribute
;instead of just assuming the variable is named "epoch" - TJK 11/26/97
;return the epoch variables tag index value.
;

dep0 = tagindex('DEPEND_0',tag_names(astrc.(0)))
if (dep0(0) ne -1) then begin; found it!
  epoch_var = astrc.(0).(dep0) ; should return the epoch variable name.
  if (epoch_var(0) ne '')then epoch_index = tagindex(epoch_var,tag_names(astrc))
endif

if (n_elements(epoch_index) eq 0) then begin
  epoch_index = tagindex('EPOCH',tag_names(astrc))
endif

return, epoch_index
end

function ellipse,r,ra 
; Computes an ellipse from major and minor axis
  fact=0.005
  del=abs(ra/fact)+2
  a=dblarr(2,del)
 i=0 
if(ra gt 0) then begin
 for x=0.0,ra,fact do begin
  a(0,i)=x
  a(1,i)=sqrt((r^2*(1.0-(x^2/ra^2))))
  i=i+1
 endfor
endif else begin
 for x=ra,0.0,fact do begin
  a(0,i)=x
  a(1,i)=sqrt((r^2*(1.0-(x^2/ra^2))))
  i=i+1
 endfor
endelse
 b=a(1,*)
 wc=where(b ne 0,wcn)
 c=dblarr(2,wcn)
 c(0,*)=a(0,wc)
 c(1,*)=b(wc)
return,c
end


;+
; NAME: orbax_scl.pro
;
; PURPOSE: Determines the min and max axis for each axis 
;          based on defined limits for orbit plots
;
; xmin     - axis minimum 
; xmax     - axis maximum 
; rstrc    - Returned structure
;
FUNCTION orbax_scl, xmin,xmax,valmin,valmax 
;print, "xmin=", xmin,xmax
if(xmin lt 0) then tmax=max([abs(xmin),xmax]) else tmax=xmax
;print, "tmax=",tmax,xmin,xmax
;print, "valmax=",valmin,valmax
; Don't know why this is set but it is screwy; commented out 4/00 RTB
;if(tmax gt 300 and xmin gt -100) then begin
;  xmin=-100.0 & xmax=500.0 
;endif else begin
; RTB changed 1/27/2000
; RTB changed 3/06/2000
   if(tmax gt 3000.) then begin
    sval = valmax
    if(sval eq 0.) then begin
     print, "STATUS=No VALIDMAX set for the maximum extent of orbit plots"
    endif
   endif
   if(tmax le 3000.) then sval=3000.0
   if(tmax le 2000.) then sval=2000.0
   if(tmax le 1500.) then sval=1500.0
   if(tmax le 1000.) then sval=1000.0
   if(tmax le 800.) then sval=800.0
   if(tmax le 500.) then sval=500.0
   if(tmax le 300.) then sval=300.0
   if(tmax le 100.) then sval=100.0
   if(tmax le 40.) then sval=40.0
   if(tmax le 20.) then sval=20.0
   if(tmax le 10.) then sval=10.0
   if(tmax le 5.) then sval=5.0
 xmin=-1.0*sval
 xmax=sval
;endelse  RTB 4/00

;print, "out", xmin,xmax

rstrc=create_struct('min',xmin,'max',xmax)

return, rstrc
end

;+                                                                            
; NAME: autoscaler.pro
;
; PURPOSE: Determines the axis scales for orbit plots
;
; astrc    -  Input structure
; rstrc    -  Returned structure
;
FUNCTION autoscaler, astrc, crd_sys=crd_sys   

numstr=astrc.(0)

axmin=dblarr(numstr)
aymin=dblarr(numstr)
azmin=dblarr(numstr)
axmax=dblarr(numstr)
aymax=dblarr(numstr)
azmax=dblarr(numstr)

ns=0
for i=1L, numstr do begin
   proj='' ;initiate proj or it will be 'NEW' for cases when it shouldn't be. RCJ 08/28/02
   epoch_index = get_depend0(astrc.(i)) ;TJK added 12/4/97
   if (epoch_index lt 0) then begin
      print,'ERROR= No Epoch variable found' & return,-1
   endif
   var_names=tag_names(astrc.(i))

   for j=0L, n_tags(astrc.(i))-1 do begin ; look for the position/orbit variable

      ; also look for whether these variables have been specified as
      ; orbit plotting variables via the display_type attribute.  If so,
      ; handle these slightly differently.

      ;   att_names=tag_names(astrc.(i).(j))
      ;   disp = tagindex('DISPLAY_TYPE',att_names)
      ;   if (disp(0) ne -1) then begin
      ;     c = break_mystring(astrc.(i).(j).(disp(0)),delimiter='>')
      ;     csize = size(c)
      ;     if ((n_elements(c) eq 2) and strupcase(c(0)) eq 'ORBIT') then begin 
      ;	proj = 'NEW'
      ;        var_index = j ;variable index in the astrc.(i) structure that
      ;	              ;we want to plot as an orbit plot.
      ;     endif 
      ;   endif
      ;TJK commented the above section out since if there are more than one ORBIT 
      ;variables in a structure, this will always set var_index to the last variable
      ;in the list, which is obviously not correct...  replaced w/ code below.
      ;10/25/2000   att_names=tag_names(astrc.(i).(j))

      coord = evaluate_orbstruct(astrc.(i).(j))
      if (coord ne ' ') then begin
         if (strupcase(crd_sys) eq strupcase(coord)) then begin
            proj = 'NEW'
            var_index = j
            ;  print, 'In AUTOSCALER, coordinate system selected is ',crd_sys
            ;  print, 'variable being scaled is ',astrc.(i).(j).varname
         endif
      endif
   endfor

   if (proj eq '') then proj=astrc.(i).(0).project ;define project

   ; Double check on structure content and crd_sys
   if (proj eq 'SSC') then begin
      v_temp='XYZ_'+crd_sys 
   endif else if (proj eq 'NEW') then begin
      v_temp=var_names(var_index)
   endif else v_temp=crd_sys+'_POS'

   wc=where(var_names eq v_temp, wcn)

   if(wcn gt 0) then begin ; Allow only sub-structures w/ appropriate CRD_SYS
      nel=n_elements(astrc.(i).(epoch_index).dat)
      x=dblarr(nel)
      y=dblarr(nel)
      z=dblarr(nel)

      case proj of
         'SSC': begin
                w3=execute('dist=astrc.(i).XYZ_'+crd_sys+'.units')
                ; RCJ 10/06/2004 look for fillval for all 'proj' cases. 
		;     Will use fval just before call to draw_orbit.
                s=execute('fval= astrc.(i).XYZ_'+crd_sys+'.fillval')
                if(strupcase(dist) eq "KM") then scale=6371.2 else scale=1.0
                if(strlen(strtrim(dist,2)) ne 0) then begin
                   w4=execute('x=astrc.(i).XYZ_'+crd_sys+'.dat(0,*)/scale')
                   w5=execute('y=astrc.(i).XYZ_'+crd_sys+'.dat(1,*)/scale')
                   w6=execute('z=astrc.(i).XYZ_'+crd_sys+'.dat(2,*)/scale')
                   ; RTB testing 3/16/2000
                   w6=execute('valmin=astrc.(i).XYZ_'+crd_sys+'.validmin/scale')
                   w6=execute('valmax=astrc.(i).XYZ_'+crd_sys+'.validmax/scale')

                   if(not w3) or (not w4) or (not w5) or (not w6) then begin
                      print, " Error in the execute command for ssc variable "
                      return, -1
                   endif
                endif
                end
         'NEW': begin ; new way - defined by the display_type attribute
                w3=execute('dist=astrc.(i).(var_index).units')
                s=execute('fval= astrc.(i).(var_index).fillval')
                if(strupcase(dist) eq "KM") then scale=6371.2 else scale=1.0
                if(strlen(strtrim(dist,2)) ne 0) then begin
                   w4=execute('x=astrc.(i).(var_index).dat(0,*)/scale')
                   w5=execute('y=astrc.(i).(var_index).dat(1,*)/scale')
                   w6=execute('z=astrc.(i).(var_index).dat(2,*)/scale')
                   ; RTB testing 3/16/2000
                   w6=execute('valmin=astrc.(i).(var_index).validmin/scale')
                   w6=execute('valmax=astrc.(i).(var_index).validmax/scale')

                   if(not w3) or (not w4) or (not w5) or (not w6) then begin
                      print, " Error in the execute command for NEW cdaw variable "
                      return, -1
                   endif
                endif
                end
         else: begin ; original cdaweb case
               w3=execute('dist=astrc.(i).'+crd_sys+'_pos.units')
               s=execute('fval= astrc.(i).'+crd_sys+'.fillval')
               if(strupcase(dist) eq "KM") then scale=6371.2 else scale=1.0
               if(strlen(strtrim(dist,2)) ne 0) then begin
                  w4=execute('x=astrc.(i).'+crd_sys+'_pos.dat(0,*)/scale')
                  w5=execute('y=astrc.(i).'+crd_sys+'_pos.dat(1,*)/scale')
                  w6=execute('z=astrc.(i).'+crd_sys+'_pos.dat(2,*)/scale')
                  ; RTB testing 3/16/2000
                  w6=execute('valmin=astrc.(i).'+crd_sys+'_pos.validmin/scale')
                  w6=execute('valmax=astrc.(i).'+crd_sys+'_pos.validmax/scale')

                  if(not w3) or (not w4) or (not w5) or (not w6) then begin
                     print, " Error in the execute command for cdaw variable "
                     return, -1
                  endif
               endif
               end
      endcase

      axmin(ns)=min(x,max=maxmax)
      axmax(ns)=maxmax
      aymin(ns)=min(y,max=maymax)
      aymax(ns)=maymax
      azmin(ns)=min(z,max=mazmax)
      azmax(ns)=mazmax

      ns=ns+1
   endif ; end crd_sys structure test 
endfor

fxmin=min(axmin)
fymin=min(aymin)
fzmin=min(azmin)
fxmax=max(axmax)
fymax=max(aymax)
fzmax=max(azmax)

; Test code rtb 3/08/99
;help, /struct, astrc
;print, valmin
;print, valmax
;
vsize=size(valmin)
if(vsize(0) eq 0) then begin
  xstr=orbax_scl(fxmin,fxmax,valmin,valmax)
  ystr=orbax_scl(fymin,fymax,valmin,valmax)
  zstr=orbax_scl(fzmin,fzmax,valmin,valmax)
endif else begin
  xstr=orbax_scl(fxmin,fxmax,valmin(0),valmax(0))
  ystr=orbax_scl(fymin,fymax,valmin(0),valmax(0))
  zstr=orbax_scl(fzmin,fzmax,valmin(0),valmax(0))
endelse

rstrc=create_struct('xmin',xstr.min,'xmax',xstr.max,'ymin',ystr.min,'ymax',ystr.max,'zmin',zstr.min,'zmax',zstr.max)

return, rstrc
end

pro time_range,epoch,sat
n=n_elements(epoch)
;print,sat,' ',pdate(epoch(0)),' ',pdate(epoch(n-1))
end

; New orbit_date
pro orbit_date1,epoch,x,y,doymark,hrmark,hrtick $
    ,color=color,noclip=noclip,charsize=cs,charthick=ct
if(n_elements(noclip) eq 0) then noclip = 1
if n_elements(color) eq 0 then color=!p.color
if n_elements(doymark) eq 0 then doymark=1
if n_elements(hrmark) eq 0 then hrmark = 6
if n_elements(hrtick) eq 0 then hrtick = 6 
n = n_elements(epoch)
if n_elements(cs) eq 0 then cs = 1.0
if n_elements(ct) eq 0 then ct =1.0 
;added 
dep = hrtick*3600d3
dephrmark = hrmark*3600d3
cdf_epoch,epoch(0),yr,month,dom,/break
cdf_epoch,ep0,yr,month,dom,/comp
np = fix( (epoch(n-1)-ep0)/dep) + 4
epochs = ep0+indgen(np)*dep
ii = where( (epochs ge epoch(0)) and (epochs le epoch(n-1))  )
;print,'time range:',pdate(epoch(0)),' ',pdate(epoch(n-1))
epochs = epochs(ii)
n = n_elements(epochs)
;
for i=0L,n-1L do begin
   cdf_epoch,epochs(i),yr,month,dom,hr,min,/break
   cdf_epoch,ep0,yr,month,dom,/comp
   ical,yr,doy,month,dom,/idoy
   ;print,yr,doy,month,dom,min
   epdiff =min(abs(epochs(i)-epoch))
   if epdiff gt time_incr(epoch) then goto, skip
   dt =epochs(i)-ep0
   if (dt mod dep) eq 0 then begin
      ii = where(epochs(i) ge epoch)
      j = ii(0)
      if j eq n-1 then begin
         xp = x(i)
         yp = y(i)
      endif else begin
;TJK 10/25/2006 - change name of interp routine (in b_lib.pro) because
;of conflicts w/ SSL s/w routine.
;         xp = interp(epochs(i),epoch,x) 
;         yp = interp(epochs(i),epoch,y) 
         xp = orbit_interp(epochs(i),epoch,x) 
         yp = orbit_interp(epochs(i),epoch,y) 
      endelse
      symsize=1.2
      oplot,[1,1]*xp,[1,1]*yp,noclip=noclip,psym=1,symsize=cs,color=color
      if ( (dt ) mod dephrmark) eq 0 then begin 
        if dt eq 0  then begin
	    text = string(hr,doy,format='(" ",i2.2,"/",i3.3)') 
 	endif else begin
	    if min eq 0 then text=string(hr,format='(i2.2)') $
	    else text=string(hr,min,format='(" ",i2.2,":",i2.2)')
	endelse
	xyouts,xp,yp,noclip=noclip,text,charthick=ct,charsize=cs,color=color
      endif
      skip:
   endif
endfor
end

pro orbit_date,epoch,x,y,doymark,hrmark,hrtick,mntick,mnmark, $
     color=color,noclip=noclip,charsize=cs,charthick=ct,date=date,$
     symsiz=symsiz,map=map
if(n_elements(noclip) eq 0) then noclip = 0
if n_elements(color) eq 0 then color=!p.color
if n_elements(doymark) eq 0 then doymark=1
if n_elements(hrmark) eq 0 then hrmark = 6
if n_elements(hrtick) eq 0 then hrtick = 6 
if n_elements(mntick) eq 0 then mntick = 0 
if n_elements(mnmark) eq 0 then mnmark = 0 
 n = n_elements(epoch)
if n_elements(cs) eq 0 then cs = 1.   
if n_elements(ct) eq 0 then ct =1. 
if n_elements(date) eq 0 then date = 1L 
if n_elements(symsiz) eq 0 then symsiz=1.0

p1=dblarr(2)
p2=dblarr(2)
;added 
;print, doymark,hrmark,hrtick,mnmark,mntick,date
if(mnmark gt 60) then hrmark=0
;
;TJK this returns a negative number at least for cluster data
;hr2=fix(epoch(0)/3600000)
hr2=(epoch(0)/3600000)
;TJK find out whether this datset has minutes starting at 0 or not
minmin = 60
for i=0L,n-1L do begin
   cdf_epoch,epoch(i),yr,month,dom,hr,min,/break
     ;find the minimum minute value for this set of epoch values
     if (min lt minmin) then minmin = min
endfor

for i=0L,n-1L do begin
;  cdf_epoch,epochs(i),yr,month,dom,hr,min,/break
   cdf_epoch,epoch(i),yr,month,dom,hr,min,/break
   min=fix(min)
   ical,yr,doy,month,dom,/idoy
; Build string for date
 if(date) then begin
   doy_st=string(doy,format='(i3.3)') 
   dfm='a3' 
 endif else begin
  doy_st=string(month,dom,format='(i2.2,"/",i2.2)') 
  dfm='a5'
 endelse
; Include hour total option
ihr=fix(hr)
;TJK the following is returning a negative number - at least for Cluster data
;hr1=fix(epoch(i)/3600000)
hr1=(epoch(i)/3600000)
hrtot=hr1-hr2
if(hrmark gt 24) then hr=fix(hrtot)

; force last mark at last point
; Hour and day ticks and marks
         xp = x(i)
         yp = y(i)
         p1(0) = x(i)
         p2(0) = y(i)
         if(i ne (n-1)) then p1(1) = x(i+1) else p1(1) = x(i-1)
         if(i ne (n-1)) then p2(1) = y(i+1) else p2(1) = y(i-1)
;TJK 1/9/2001 change to allow plotting of Cluster tick marks - they never have 
;minute values at "zero".    if min eq 0 then begin
;TJK 1/11/2001 change this logic because now we're getting too many tick marks for datasets
;with high res...  Determine the minimum value of all of the epochs in the array, and look for
;that minimum value before doing the rest of the labeling logic.
 if (min eq minmin) then begin
; Test conditions for hour and day of year labels
  if(hr gt 100) then hrfm='i3.3' else hrfm='i2.2'
    if((hrmark ne 0) and (doymark ne 0)) then begin
     if ( (hr/float(hrmark)) mod 1 ) eq 0 then begin 
;if(((hr/(hrmark)) mod 1) eq 0) and (((doy/float(doymark)) mod 1) eq 0) then $
      if (ihr eq 0) and ( ( (doy/float(doymark)) mod 1 ) eq 0 ) then $
	     xyouts,xp,yp, noclip=noclip $
	       ,string(hr,doy_st,format='(" ",'+hrfm+',":00 ",'+dfm+')') $
               ,charthick=ct,color=color,charsize=cs $
      else xyouts,xp,yp,noclip=noclip,string(hr,format='(" ",'+hrfm+',":00")') $
               ,charthick=ct,charsize=cs,color=color
;     	oplot,[1]*xp,[1]*yp,noclip=noclip,psym=1,symsize=cs,color=color
        make_tick, p2, p1,symsiz=symsiz,symcol=color,map=map
     endif
    endif
     if((hrmark eq 0) and (doymark ne 0)) then begin
;if (((hr/(hrmark)) mod 1) eq 0) and (((doy/float(doymark)) mod 1) eq 0) then begin 
        if (ihr eq 0) and ( ( (doy/float(doymark)) mod 1 ) eq 0) then begin 
             xyouts,xp,yp, noclip=noclip $
               ,string(doy_st,format='(" ",'+dfm+')') $
               ,charthick=ct,color=color,charsize=cs 
;     	oplot,[1]*xp,[1]*yp,noclip=noclip,psym=1,symsize=cs,color=color
        make_tick, p2, p1,symsiz=symsiz,symcol=color,map=map
       endif
     endif
     if((hrmark ne 0) and (doymark eq 0)) then begin
      if ( (hr/float(hrmark)) mod 1 ) eq 0 then begin
         xyouts,xp,yp,noclip=noclip,string(hr,format='(" ",'+hrfm+',":00")') $
               ,charthick=ct,charsize=cs,color=color
;     	oplot,[1]*xp,[1]*yp,noclip=noclip,psym=1,symsize=cs,color=color
        make_tick, p2, p1,symsiz=symsiz,symcol=color,map=map
      endif
     endif
; Add tick marks
     if(hrtick ne 0) then begin
      if ( (hr/float(hrtick)) mod 1 ) eq 0 then  $
;    	oplot,[1,1]*xp,[1,1]*yp,noclip=noclip,psym=1,symsize=cs,color=color
        make_tick, p2, p1,symsiz=symsiz,symcol=color,map=map
     endif
 endif
; Minute ticks and marks
 if(min ne 0) then begin
  if((mnmark ne 0) and (mnmark le 60)) then begin
   if((min mod mnmark) eq 0) then $
     xyouts,xp,yp,noclip=noclip,string(hr,min,format='(i2.2,":",i2.2)'),$
                           charthick=ct,charsize=cs,color=color
  endif
 endif
 if(mnmark gt 60) then begin
    hrmin=60*hr+min
    if((hrmin mod mnmark) eq 0) then $
     xyouts,xp,yp,noclip=noclip,string(hrmin,format='(i4.4)'),$ 
                           charthick=ct,charsize=cs,color=color
 endif
 if(mntick gt 60) then begin
  hrmin=60*hr+min
  if((hrmin mod mntick) eq 0) then $
     make_tick, p2, p1,symsiz=symsiz,symcol=color,map=map
 endif
 if((mntick ne 0) and (mntick le 60)) then begin
  if((min mod mntick) eq 0) then $ 
     make_tick, p2, p1,symsiz=symsiz,symcol=color,map=map
 endif

endfor

end
 
pro legend,i,labpos=labpos,sats=sats,colors=colors,overplot=overplot,$
             charsize=cs
; Not called any longer
sc = 1.1   ; 0.7
chsize,xch,ych,norm=0
xch = abs(xch)
ych = abs(ych) 
ichy = n_elements(sats)
ichx = max(strlen(sats))
x=!x.crange & dx = x(1)-x(0) & sgnx = sgn(dx)
y =!y.crange & dy = y(1)-y(0) & sgny = sgn(dy)
;x0=x(1) - sgnx*1.1*ichx*xch  ; 1.1
if(n_elements(labpos) eq 0) then begin
  x0=x(1)/6 & y0 = y(1)-(i+.5)*sgny*sc*ych
endif else begin
  x0=labpos(0) & y0=labpos(1)-(i+.5)*sgny*sc*ych
endelse

; plot symbol conditions
pltsym=i+1
if((pltsym eq 3) or (pltsym gt 7)) then pltsym=7 
; setup array for symbols to be plotted
  xfc=dx/50.0 & yfc=dy/50.0
  x1=dblarr(1) & y1=dblarr(1)
  x1(0)=x0-xfc & y1(0)=y0+yfc
 
    xyouts,x0,y0,sats,color=colors,charsize=cs
    oplot,x1,y1,color=colors,psym=pltsym,symsize=symsiz

end

function region_orbit,epoch,x,y,z,xmp,rhomp,xbs,rhobs
;region orbit into regions of geospace
; x,y,z MUST be in Re
rho = sqrt(y^2+z^2) 
npts=n_elements(x)
rpts=n_elements(rhomp)

; Test sign condition to resolve XY region error RTB 7/2000
; Comment until bugs in orbit get cleaned up
  rhompmax=max(rhomp)
  rhobsmax=max(rhobs)
 if(rpts gt 1) then begin ; RTB avoids error in call to mean 
			  ; (must have at least 2 points)
  if((rhompmax eq 0) or (rhobsmax eq 0)) then begin
   if(mean(rhomp) < 0) then begin
     rhompmax=abs(min(rhomp))
   endif else begin
     rhompmax=max(rhomp)
   endelse
   if(mean(rhobs) < 0) then begin
     rhobsmax=abs(min(rhobs))
   endif else begin
     rhobsmax=max(rhobs)
   endelse 
  endif
 endif else begin
  rhobsmax=max(rhobs)
  rhompmax=max(rhomp)
 endelse
;Original code rtb
;rhompmax=max(rhomp)
;rhobsmax=max(rhobs)
; End RTB test
regmp = indgen(npts)
regbs = indgen(npts)

for i=0L,npts-1 do begin
; causes error values in HEC Re corrdinates   RTB 5/2000
;   if(abs(x(i)) ge 6371.2) then x=x/6371.2
;   if(abs(y(i)) ge 6371.2) then y=y/6371.2
;   if(abs(z(i)) ge 6371.2) then z=z/6371.2
    if rho(i) ge rhompmax then begin
	regmp(i)=-1 
    endif else begin
	r = interpol(xmp,rhomp,rho(i))-x(i) ; >0 inside magnetosphere
	regmp(i) = r/abs(r)
    endelse

    if rho(i) ge rhobsmax then begin
	regbs(i)=-1
    endif else begin
	r = interpol(xbs,rhobs,rho(i))-x(i) ; >0 inside magnetosphere
	regbs(i) = r/abs(r)
    endelse
endfor
; -2 -> SW, 0 -> magnetosheath ,2 -> magnetosphere
region = regbs+regmp

return,region
end

pro plot_orbit,x,y,ks,regions=region,color=color,lnthick=lnthick
; plot symbol conditions
kks=ks
if(kks ge 6) then kks=ks-6
pltsym=kks+1
if(pltsym eq 3) then pltsym=7

npts = n_elements(x)
i=indgen(npts-1)
dr=region(i+1)-region(i)
ii=where( dr ne 0 )
if ii(0) eq -1 then begin
   ii=[0,npts-1]
endif else begin
   ii=[0,[ii],npts-1]
endelse
nseq = n_elements(ii)-1
for i=0L,nseq-1 do begin
    xs = x(ii(i):ii(i+1))
    ys = y(ii(i):ii(i+1)) 
    imid =(ii(i)+ii(i+1))/2
    reg = long(region(imid))
;     print,ii(i),imid,ii(i+1),' region:',reg

    case reg of
       -2l: linestyle=0 
	0l: linestyle=2
	2l: linestyle=1
    endcase
;    print,'ls',linestyle
; average every 5 points to reduce plot clutter
; causes 1st and last point when averaged to appear as a gap b/w regions
   ; oplot,xs,ys,linestyle=linestyle ,color=color, nsum=5
    oplot,xs,ys,linestyle=linestyle ,color=color,thick=lnthick
endfor
    x1=dblarr(1) & y1=dblarr(1)
    x1(0)=x(0) & y1(0)=y(0)
    oplot,x1,y1,psym=pltsym,color=color,thick=lnthick
end

;The following routine doesn't seem to be used anymore.
pro load_interval,eprange,orbit,x,y,z,epoch
ep0 = eprange(0)
ep1 = eprange(1)
ii = where( (orbit.epoch ge ep0) and (orbit.epoch le ep1) )
if(ii(0) eq -1) then begin
   x=0
   y=0
   z=0
   return
endif

epoch = orbit(ii).epoch
x=orbit(ii).xgse
y=orbit(ii).ygse
z=orbit(ii).zgse
end

function rot_x, x,y,z,deg
; Rotates elements of x,y,z by the given angle about X
 dgrad=!pi/180.0
 rads=deg*dgrad
 cs=cos(rads) 
 ss=sin(rads)
 t=dblarr(3,3) 
 t=[[1.0,0.0,0.0],[0.0,cs,-ss],[0.0,ss,cs]]
 tt=[[cs,ss,0.0],[-ss,cs,0.0],[0.0,0.0,1.0]]
 
  num=n_elements(x)
  r=dblarr(num,3)
  old=dblarr(3)
  new=dblarr(3)
 
  for i=0L,num-1 do begin
    old=[x(i),y(i),z(i)] 
 
    for n=0,2 do begin
     tmp=0.0
     for m=0,2 do begin
       tmp=tt(n,m)*old(m)+tmp
     endfor 
     new(n)=tmp
    endfor
    r(i,*)=new(*)
 endfor 
  return, r 
 end

pro draw_orbit,epoch,x,y,z,ks,xmp,rhomp,xbs,rhobs,doymark,hrmark,hrtick, $
         mntick,mnmark,color=color,noclip=noclip,proj=proj,$
         charsize=cs,date=date,symsiz=symsiz,lnthick=lnthick

if n_elements(x) gt 1 then begin

region = region_orbit(epoch,x,y,z,xmp,rhomp,xbs,rhobs)

case proj of
 'xz':begin
region = region_orbit(epoch,x,y,z,xmp,rhomp,xbs,rhobs)
;print, 'xz', region
;print, 'xz region'
      plot_orbit,x,z,ks,region = region, color=color,lnthick=lnthick
        orbit_date,epoch,x,z,doymark,hrmark,hrtick,mntick,mnmark,$
        color=color,noclip=noclip,charsize=cs,date=date,symsiz=symsiz
      end
 'xy':begin
region = region_orbit(epoch,x,y,z,xmp,rhomp,xbs,rhobs)
;print,'xy', region
;print, 'xy region'
        plot_orbit,x,y,ks,region = region, color=color,lnthick=lnthick
        orbit_date,epoch,x,y,doymark,hrmark,hrtick,mntick,mnmark,$
        color=color,noclip=noclip,charsize=cs,date=date,symsiz=symsiz
      end
 'yz':begin         
region = region_orbit(epoch,x,y,z,xmp,rhomp,xbs,rhobs)
;print, 'yz', region
;print, 'yz region'
        plot_orbit,y,z,ks,region = region, color=color,lnthick=lnthick
        orbit_date,epoch,y,z,doymark,hrmark,hrtick,mntick,mnmark,$
        color=color,noclip=noclip,charsize=cs,date=date,symsiz=symsiz
      end
 'xr':begin          
;print, 'xr region'
region = region_orbit(epoch,x,y,z,xmp,rhomp,xbs,rhobs)
;   deg=45.0 &  r=rot_x(x,y,z,deg) & xp=r(*,0) & yp=r(*,1) & zp=r(*,2)
;        plot_orbit,xp,yp,ks,region = region, color=color
;       orbit_date,epoch,xp,yp,doymark,hrmark,hrtick,color=color,noclip=noclip,$
;                 charsize=cs,date=date,symsiz=symsiz
        numb=n_elements(y)
        r=dblarr(numb)
        for j=0L, numb-1 do begin
         r(j)=sqrt(y(j)^2 +z(j)^2)
;         if(z(j) lt 0) then r(j)=-1.D0*r(j)
        endfor 
        plot_orbit,x,r,ks,region = region, color=color,lnthick=lnthick
        orbit_date,epoch,x,r,doymark,hrmark,hrtick,mntick,mnmark,$
        color=color,noclip=noclip,charsize=cs,date=date,symsiz=symsiz
      end
endcase
endif
end

function secant,x,y
; Find 0 crossing
 wm=where((x lt 0), w1)                                                        
 n=wm(0)
 n1=wm(0)-1
 r=y(n)-x(n)*((y(n)-y(n1))/(x(n)-x(n1)))
return, r
end
;
; Program orbit_plt
;
; Variables
;  astrc     - IDL structure of all  
; 
; Keywords
;  tstart    - start time of plot
;  tstop     - stop time of plot
;  xsize     - window size for x coordinate
;  ysize     - window size for y coordinate
;  orb_vw    - orbit view; up to a 4 element array (xy, xz, yz, xr)
;  press     - solar wind pressure
;  bz        - IMF bz 
;  xmar      - xmargin
;  ymar      - ymargin
;  doymark   - interval along the orbit on which the day of year is plotted
;  hrmark    - interval along the orbit on which the hour of day is plotted  
;  hrtick    - Tick interval along the orbit 
;  xmin      - minimum x axis value
;  xmax      - maximum x axis value
;  ymin      - minimum y axis value
;  ymax      - maximum y axis value
;  color     - color for orbits and labels
;  labpos    - starting point for labels
;  chtsize   - character size
;  lnthick   - line thickness
;  us        - orientation of bow shock/ magnetopause
;  bsmp      - bow shock/ magnetopause plot (ON/OFF:1/0)
;  autoscl   - automatic X/Y scaling
;  symsiz    - symbol size
;  autolabel - automatic labeling
;  datelabel - 0 = yy/mm/dy; 1 = yy/doy 
;  eqlscl    - Forces equal aspect on scale (T/F;1/0)
;  panel     - Normal Orbit plot panel layout (F:0) Stacked layout (T:1)
;
; Other variables
;  overplot  - controls plotting over the same axises 

function orbit_plt,astrc,tstart=tstart,tstop=tstop,xsize=xsize,ysize=ysize, $
                   orb_vw=orb_vw,press=press,bz=bz,crd_sys=crd_sys,xmar=xmar,$
                   ymar=ymar,doymark=doymark,hrmark=hrmark,hrtick=hrtick,$
                   mntick=mntick,mnmark=mnmark,xumn=xumn,xumx=xumx,yumn=yumn,$
               yumx=yumx,zumn=zumn,zumx=zumx,rumn=rumn,rumx=rumx,color=color,$
               labpos=labpos,chtsize=chtsize,US=us,BSMP=bsmp,autoscl=autoscl,$
      symsiz=symsiz,lnthick=lnthick,autolabel=autolabel,datelabel=datelabel, $
                   eqlscl=eqlscl,panel=panel 

status=0
; Establish error handler
  catch, error_status
  if(error_status ne 0) then begin
   print, "ERROR= number: ",error_status," in orbit_plt.pro"
   print, "ERROR= Message: ",!ERR_STRING
   status = -1
   return, status
  endif
 
numstr=astrc.(0)
epoch_index=intarr(numstr+1)
for ii=1, numstr do begin
 epoch_index(ii) = get_depend0(astrc.(ii))
 ;print, 'epoch index = ',epoch_index(ii)
 if (epoch_index(ii) lt 0) then begin
  print,'ERROR= No Epoch variable found' & return,-1
 endif
endfor
;nel = n_elements(astrc.(1).(epoch_index(1)).dat)

if(n_elements(overplot) eq 0) then overplot=0 
if(n_elements(bz) eq 0) then bz = 0
;if(n_elements(xmar) eq 0) then xmar =  [7.,2.] 
;RCJ 03/14/2006 Making a little more room for y-axis label
if(n_elements(xmar) eq 0) then xmar =  [10.,2.] 
if(n_elements(ymar) eq 0) then ymar = [8.25,1.] ;5.25,1.
if(n_elements(doymark) eq 0) then doymark = 1
if(n_elements(hrmark) eq 0) then hrmark = 48
if(n_elements(hrtick) eq 0) then hrtick = 24
if(n_elements(xsize) eq 0) then xsize = 720 ;400
if(n_elements(ysize) eq 0) then ysize = 760 ;512
if(n_elements(chtsize) eq 0) then chtsize = 1.0
if(n_elements(symsiz) eq 0) then symsiz = 1.0
if(n_elements(lnthick) eq 0) then lnthick = 1.0
if(n_elements(crd_sys) eq 0) then crd_sys = 'GSE' 
if(n_elements(autolabel) eq 0) then autolabel=1L
if(n_elements(us) eq 0) then us=1L
if(n_elements(bsmp) eq 0) then bsmp=1L
if(n_elements(autoscl) eq 0) then autoscl=1L
if(n_elements(datelabel) eq 0) then datelabel=1L
if(n_elements(panel) eq 0) then panel=0L
if(n_elements(eqlscl) eq 0) then eqlscl=0L
chtsize0=chtsize+0.6
chtsize1=chtsize/1.1
chtsize2=chtsize/1.2
chtsize3=chtsize/1.3
; autoscl=0L 
if((n_elements(xumn) eq 0) and (n_elements(xumx) eq 0)) then autoscl=1L
if((n_elements(yumn) eq 0) and (n_elements(yumx) eq 0)) then autoscl=1L
if((n_elements(zumn) eq 0) and (n_elements(zumx) eq 0)) then autoscl=1L
if((n_elements(rumn) eq 0) and (n_elements(rumx) eq 0)) then autoscl=1L

; Determine start time from all satellites in structure
if(n_elements(tstart) eq 0) then begin
  gmins=dblarr(numstr)
;  for ik=1,numstr do gmins(ik-1)=astrc.(ik).epoch.dat(0) 
  for ik=1L,numstr do gmins(ik-1)=astrc.(ik).(epoch_index(ik)).dat(0) 
  tstart=min(gmins)
endif
; Determine stop time from all satellites in structure
if(n_elements(tstop) eq 0) then begin
  gmaxs=dblarr(numstr)
  for ik=1L,numstr do begin  
   nel = n_elements(astrc.(ik).(epoch_index(ik)).dat)
   gmaxs(ik-1)=astrc.(ik).(epoch_index(ik)).dat(nel-1) 
  endfor
  tstop=max(gmaxs)
endif
; Default for CDAWEB here
if(n_elements(orb_vw) eq 0) then orb_vw=['xy','yz','xz','xr']
; Default hardcoded for IMAGE here
;orb_vw=['xy']
if(n_elements(press) eq 0) then press=2.10

 if(!d.name eq 'X') then begin
   if(n_elements(color) eq 0) then color=254
   bkgrd=254
 endif
 if(!d.name eq 'Z') then begin
   if(n_elements(color) eq 0) then color=1
   bkgrd=1
 endif
 if(!d.name eq 'PS') then begin 
   if(n_elements(color) eq 0) then color=1
   bkgrd=1
 endif

if(!d.name eq 'X') then begin
  if(overplot eq 0) then window,0,xsize=xsize,ysize=ysize
endif
; Scale Orbit ticks 
;cdf_epoch,tstart,iyr,imon,idy,ihr,imin,isec,mill,/break
;cdf_epoch,tstop,iyr,imon,idy,ihr,imin,isec,mill,/break

dif=(tstop-tstart)/1000
ddif=dif/86400.0

if(autolabel) then begin
 if(ddif gt 1.0) then hrtick=0 & hrmark=0
 if(ddif le 1.0) then begin
  doymark=1
  hrtick=12
  hrmark=12
  mntick=0
  mnmark=0
  if(ddif le 0.5) then begin
    doymark = 1
    hrtick = 3
    hrmark = 6
    mntick=0
    mnmark=0
    if(ddif le 0.2) then begin
     doymark = 1
     hrtick = 1
     hrmark = 2
     mntick = 30
     mnmark = 30
    endif
  endif
 endif else begin
;  if(ddif lt 2.0) then doymark=1 else doymark=fix(ddif/2)
   if(ddif le 4.0) then doymark=1 
   if(ddif gt 4.0) then doymark=2 
   if(ddif gt 7.0) then doymark=7 
   if(ddif gt 30.0) then doymark=30 
   if(ddif gt 180.0) then doymark=180 
   if(ddif gt 365.0) then doymark=365 
 endelse
endif
; Remove XR prespective from all but GSE, GSM, and SM
 if((crd_sys eq 'TOD') or (crd_sys eq 'J2000') or (crd_sys eq 'GEO') or (crd_sys eq 'GM')) then begin 
   orn=n_elements(orb_vw)
   woc=where(orb_vw ne 'xr',oc)
   orb_vw=orb_vw(woc)
 endif
; Determine structure of axis limits
 if(autoscl) then ax_limits=autoscaler(astrc,crd_sys=crd_sys)
; print, ax_limits

; Decompose mega-structure
tagnms=tag_names(astrc)
numstr=astrc.(0)

;color_scale=255/(numstr+3)
; RCJ 02/17/2006  Picking better colors. Avoiding yellow and picking
; greens/blues as far from each other as possible.
; If the max number of satellites allowed to be plotted increases
; more lines have to be added here.
if numstr le 2 then color_scale=[70,238]
if numstr eq 3 then color_scale=[70,200,238]
if numstr eq 4 then color_scale=[70,130,200,238]
if numstr eq 5 then color_scale=[46,82,128,200,238]
if numstr eq 6 then color_scale=[40,70,100,170,200,238]
if numstr eq 7 then color_scale=[40,65,85,110,160,200,238]
if numstr eq 8 then color_scale=[10,40,70,100,130,170,200,238]
;  RCJ 12/07/2007  Increasing this number to 12.  It was tough enough to
;     find 8 colors that weren't so close to each other....  here go some guesses...
if numstr eq 9 then color_scale=[10,25,40,70,100,130,170,200,238]
if numstr eq 10 then color_scale=[10,25,40,55,70,100,130,170,200,238]
if numstr eq 11 then color_scale=[10,25,40,55,70,100,130,145,170,200,238]
if numstr eq 12 then color_scale=[10,25,40,55,70,100,130,145,170,185,200,238]


nall_sats='/' 

for ks=1L, numstr do begin 
   proj='' ;initiate proj or it will be 'NEW' for cases when it shouldn't be. RCJ 08/28/02
   nsat=strtrim(tagnms(ks),2)
   var_names=tag_names(astrc.(ks))
   ; print, var_names

   for j=0L,(n_tags(astrc.(ks))-1) do begin ; look for the position/orbit variable
      ; also look for whether these variables have been specified as
      ; orbit plotting variables via the display_type attribute.  If so,
      ; handle these slightly differently.

      ;   att_names=tag_names(astrc.(ks).(j))
      ;   disp = tagindex('DISPLAY_TYPE',att_names)
      ;   if (disp(0) ne -1) then begin
      ;     c = break_mystring(astrc.(ks).(j).(disp(0)),delimiter='>')
      ;     csize = size(c)
      ;     if ((n_elements(c) eq 2) and strupcase(c(0)) eq 'ORBIT') then begin 
      ;	proj = 'NEW'
      ;        var_index = j ;variable index in the astrc.(i) structure that
      ;	              ;we want to plot as an orbit plot.
      ;     endif 
      ;   endif

      ;TJK commented the above section out since if there are more than one ORBIT 
      ;variables in a structure, this will always set var_index to the last variable
      ;in the list, which is obviously not correct...  replaced w/ code below.
      ;10/25/2000  


      coord = evaluate_orbstruct(astrc.(ks).(j))
      if (coord ne ' ') then begin
         if (strupcase(crd_sys) eq strupcase(coord)) then begin
            proj = 'NEW'
            var_index = j
            ;  print, 'In Orbit_plt, coordinate system selected is ',crd_sys
            ;  print, 'variable being plotted is ',astrc.(ks).(j).varname
         endif
      endif
   endfor
   if (proj eq '') then proj=astrc.(ks).(0).project ;define project

   ; Double check on structure content and crd_sys
   if(proj eq 'SSC') then begin
      v_temp='XYZ_'+crd_sys 
   endif else if (proj eq 'NEW') then begin
      v_temp=var_names(var_index)
   endif else v_temp=crd_sys+'_POS'

   wc=where(var_names eq v_temp, wcn)

   if(wcn gt 0) then begin ; Allow only sub-structures w/ appropriate CRD_SYS

      nel = n_elements(astrc.(ks).(epoch_index(ks)).dat)
      ep00 = astrc.(ks).(epoch_index(ks)).dat(0)
      ep11 = astrc.(ks).(epoch_index(ks)).dat(nel-1)

      time_range,astrc.(ks).(epoch_index(ks)).dat,nsat 

      ;print,'orbit data time interval:',pdate(ep00),' ',pdate(ep11)

      start_time = 0.0D0 ; initialize
      stop_time = 0.0D0 ; initialize
      if keyword_set(TSTART) then begin ; determine datatype and process if needed
         b1 = size(TSTART) & c1 = n_elements(b1)
         if (b1(c1-2) eq 5) then start_time = TSTART $ ; double float already
             else if (b1(c1-2) eq 7) then start_time = encode_cdfepoch(TSTART) $ ; string
         else begin
            print,'ERROR= TSTART parameter must be STRING or DOUBLE' & return,-1
         endelse
      endif

      if keyword_set(TSTOP) then begin ; determine datatype and process if needed
         b1 = size(TSTOP) & c1 = n_elements(b1)
         if (b1(c1-2) eq 5) then stop_time = TSTOP $ ; double float already
            else if (b1(c1-2) eq 7) then stop_time = encode_cdfepoch(TSTOP) $ ; string
         else begin
            print,'ERROR= TSTOP parameter must be STRING or DOUBLE' & return,-1
         endelse
      endif

      ; Determine indices of epoch.dat that are within the tstart and tstop

      tind=where((astrc.(ks).(epoch_index(ks)).dat ge start_time) and  $
            (astrc.(ks).(epoch_index(ks)).dat le stop_time),w)
      if(tind(0) lt 0) then begin
         print, 'ERROR= Start or stop time beyond range of data'
         print, 'STATUS= Start or stop time beyond range of data'
         print, 'STATUS= Re-select time interval'
         print, start_time, stop_time
         return, -1
      endif

      ndays=1
      daymsec = 24*3600d3
      dep = ndays*daymsec

      yrange0 = [-1,1]
      if(autoscl) then xrange0=[-60.0,60.0] else xrange0 = [xumn,xumx]
      ;prefix = 'c'+string(abs(xmax),format='(i3.3)')+'_'

      eprange = [ep00,ep11]

      ;start of orbit plot
      ; nx & ny determine the number of frames in each column and row
      inc=n_elements(orb_vw)
      nx = 1
      ny = 1 
      if(inc gt 1) then overplot=0
      if(inc eq 2) then begin
         nx=2 
         ny=2
      endif
      if(inc gt 2) then begin
         ny=2 & nx=2  
      endif
      ; test new region arrangement

      if(panel) then begin
         nx = 1
         ny = inc
      endif

      ;itle1=rdate1(ep00,format='all') + ' to ' + rdate1(ep11,format='all')
      title1=rdate1(tstart,format='all') + ' to ' + rdate1(tstop,format='all')

      ; Loop through desired views (xy, xz, yz, xr)
      for i=0L,inc-1 do begin

         ;set location for each projection
         title2=''
         pregion,nx,ny,i,/edge,xmargin=xmar,ymargin=ymar,title=title2,bkgrd=bkgrd,$
            overplot=overplot,chtsz=chtsize0
         ; Set xmin, xmax and ymin, ymax

         ;if((panel) and (autoscl)) then begin
         ;  even_scales,xrange0,yrange0,xrange,yrange
         ;  xmin=xrange(0)
         ;  xmax=xrange(1)
         ;  ymin=yrange(0)
         ;  ymax=yrange(1)
         ;endif

         ; Overwrite results of even_scales routine
         if(autoscl) then begin
            case orb_vw(i) OF
               'xy' : begin
                      xmin=min([ax_limits.xmin,ax_limits.ymin])
                      xmax=max([ax_limits.xmax,ax_limits.ymax])
                      ymin=xmin
                      ymax=xmax
                      end
               'xz' : begin
                      xmin=min([ax_limits.xmin,ax_limits.zmin])
                      xmax=max([ax_limits.xmax,ax_limits.zmax])
                      ymin=xmin
                      ymax=xmax
                      end
               'yz' : begin
                      xmin=min([ax_limits.ymin,ax_limits.zmin])
                      xmax=max([ax_limits.ymax,ax_limits.zmax])
                      ymin=xmin
                      ymax=xmax
                      end
               'xr' : begin
                      xmin=min([ax_limits.xmin,ax_limits.ymin,ax_limits.zmin])
                      xmax=max([ax_limits.xmax,ax_limits.ymax,ax_limits.zmax])
                      ymin=xmin
                      ymax=xmax
                      ;      ymin=min([ax_limits.ymin,ax_limits.zmin])
                      ;      ymax=max([ax_limits.ymax,ax_limits.zmax])
                      end
                else: begin
                       print, 'Using Default min and max values'
                       end 
            endcase
         endif else begin ; autoscl
            case orb_vw(i) of
               'xy' : begin
                      xmin=xumn
                      xmax=xumx
                      ymin=yumn
                      ymax=yumx
                      end
               'xz' : begin
                      xmin=xumn
                      xmax=xumx
                      ymin=zumn
                      ymax=zumx
                      end
               'yz' : begin
                      xmin=yumn
                      xmax=yumx
                      ymin=zumn
                      ymax=zumx
                      end
               'xr' : begin
                      xmin=xumn
                      xmax=xumx 
                      ymin=rumn
                      ymax=rumx
                      end
                else: begin
                      print, 'Using Default min and max values'
                      end
            endcase
         endelse

         ; Equal Scale w/ advanced 1-column panel mode
         if((eqlscl) and (panel)) then begin
            pp1=!p.position(1)
            pp3=!p.position(3)
            ppdf=pp3-pp1
            dpos=(ymax-ymin)*ppdf/(xmax-xmin)
            pp3n=pp1+dpos
            ; If position exceeds = scale limit; use default to = scale & = axis length
            if(pp3n ge pp3) then begin
               !p.position(3)=pp3
               xrng0=dblarr(2)
               yrng0=dblarr(2)
               yrng0=[ymin,ymax]
               xrng0=[xmin,xmax]
               even_scales,xrng0,yrng0,xrange,yrange
               xmin=xrange(0)
               xmax=xrange(1)
               ymin=yrange(0)
               ymax=yrange(1)
               xyouts,0.55,0.03,"Min & Max values overridden to fit window", $
                  charsize=chtsize1,/normal,color=bkgrd
            endif else begin
               !p.position(3)=pp3n
            endelse
         endif

         ; Switch position of the Sun for US or EURO/JAP
          if(us) then begin
            xrange=[xmax,xmin] 
            ; if(i eq 1) then yrange=[ymin,ymax] else yrange=[ymax,ymin]
            if((orb_vw(i) eq 'xz') or (orb_vw(i) eq 'yz')) then yrange=[ymin,ymax] $
               else yrange=[ymax,ymin]
            if(orb_vw(i) eq 'yz') then xrange=[xmin,xmax]
         endif else begin
            xrange=[xmin,xmax]
            ; if(orb_vw(i) eq 'xz') then yrange=[ymax,ymin] else yrange=[ymin,ymax]
            yrange=[ymin,ymax]
         endelse
         if(orb_vw(i) eq 'xr') then yrange = [ymin,ymax]
         ;if(n_elements(ymin) ne 0) then yrange(0)=ymin
         ;if(n_elements(ymax) ne 0) then yrange(1)=ymax
         a=indgen(100)/100./!radeg
         xe=cos(a)
         ye=sin(a)

         crd_sys1=crd_sys
         if(crd_sys eq 'TOD') then crd_sys1='GEI/'+crd_sys
         if(crd_sys eq 'J2000') then crd_sys1='GEI/'+crd_sys

         if(orb_vw(i) eq 'xz') then begin
            xtit='X!d'+crd_sys1+'!n (Re)'
            ytit='Z!d'+crd_sys1+'!n (Re)'
         endif
         if(orb_vw(i) eq 'xy') then begin
            xtit='X!d'+crd_sys1+'!n (Re)'
            ytit='Y!d'+crd_sys1+'!n (Re)'
         endif
         if(orb_vw(i) eq 'yz') then begin
            xtit='Y!d'+crd_sys1+'!n (Re)'
            ytit='Z!d'+crd_sys1+'!n (Re)'
         endif
         if(orb_vw(i) eq 'xr') then begin
            xtit='X!d'+crd_sys1+'!n (Re)'
            ytit='R=(Y!e2!n+Z!e2!n)!e1/2!n!d'+crd_sys1+'!n (Re)'
            ;  ytit='R!d'+crd_sys1+'!n' 
         endif
         ;if(inc gt 2) then xtm=4 else xtm=8
         if(overplot eq 0) then begin
            charplot=chtsize-0.1  
            if(inc gt 2) then begin 
               plot,xe,ye,xrange=xrange,xticks=4,yrange=yrange,color=bkgrd,$
               charsize=charplot,xstyle=1,ystyle=1,xtitle=xtit,ytitle=ytit,title= ''
            endif else begin
               plot,xe,ye,xrange=xrange,yrange=yrange,color=bkgrd,$        
               charsize=charplot,xstyle=1,ystyle=1,xtitle=xtit,ytitle=ytit,title= ''
            endelse
         endif else oplot, xe, ye 
         ;draw x and y axis
         if(overplot eq 0) then begin
            tl=.01
            ; Condition added to prevent a scray axis from being plotted 
            if(((yrange(1) gt 0.) and (yrange(0) lt 0.)) or $
               ((yrange(1) lt 0.) and (yrange(0) gt 0.))) then begin
               axis,0,0,/xaxis,xstyle=1,xticklen=tl,xtickname=replicate(' ',30),color=bkgrd
               axis,0,0,/xaxis,xstyle=1,xticklen=-tl,xtickname=replicate(' ',30),$
                  color=bkgrd
            endif
            axis,0,0,/yaxis,ystyle=1,yticklen=tl,ytickname=replicate(' ',30),color=bkgrd
            axis,0,0,/yaxis,ystyle=1,yticklen=-tl,ytickname=replicate(' ',30),color=bkgrd
         endif

         ; For all crd_sys besides GSE set default values
         rhomp=0.0
         rhobs=0.0
         xmp=0.0
         xbs=0.0
         if((crd_sys eq 'GSE') and (bsmp)) then begin
            sibeck2,bz=bz,press=press,rhomp,xmp,rhobs,xbs
            if(orb_vw(i) eq 'xy') then begin
               nxs=n_elements(xmp)
               zdum=dblarr(nxs)
               deg=4.3 & r=rot_x(xmp,rhomp,zdum,deg) & xmp=r(*,0) & rhomp=r(*,1) 
               oplot,xmp,-rhomp,color=bkgrd
               deg=4.3 & r=rot_x(xmp,-rhomp,zdum,deg) & xmp=r(*,0) & rhomp=r(*,1) 
               oplot,xmp,-rhomp,color=bkgrd
               deg=4.3 & r=rot_x(xbs,rhobs,zdum,deg) & xbs=r(*,0) & rhobs=r(*,1) 
               oplot,xbs,-rhobs,color=bkgrd
               deg=4.3 & r=rot_x(xbs,-rhobs,zdum,deg) & xbs=r(*,0) & rhobs=r(*,1)
               oplot,xbs,-rhobs,color=bkgrd
            endif
            if(orb_vw(i) eq 'xz') then begin 
               nxs=n_elements(xmp)
               zdum=dblarr(nxs) 
               deg=-4.3 & r=rot_x(xmp,zdum,zdum,deg) & xmp=r(*,0)
               oplot,xmp,rhomp,color=bkgrd
               oplot,xmp,-rhomp,color=bkgrd
               deg=-4.3 & r=rot_x(xbs,zdum,zdum,deg) & xbs=r(*,0)
               oplot,xbs,rhobs,color=bkgrd
               oplot,xbs,-rhobs,color=bkgrd
            endif
            if(orb_vw(i) eq 'yz') then begin
               nxs=n_elements(xmp)
               zdum=dblarr(nxs)
               rmp=secant(xmp,rhomp) 
               deg=4.3 & r=rot_x(xmp,rhomp,zdum,deg) & rxmp=r(*,0) & rrhomp=r(*,1)
               rmpa=secant(rxmp,rrhomp) 
               rmpb=(rmp-rmpa) + rmp
               rbs=secant(xbs,rhobs) 
               deg=4.3 & r=rot_x(xbs,rhobs,zdum,deg) & rxbs=r(*,0) & rrhobs=r(*,1)
               rbsa=secant(rxbs,rrhobs) 
               rbsb=(rbs-rbsa) + rbs 
               ; rad=!PI/180.
               ; deg=findgen(360)*rad 
               ; a1=dblarr(360)
               ; a2=dblarr(360) 
               ; a1=rmp*cos(deg)
               ; a2=rmp*sin(deg)
               a=ellipse(rmp,rmpa)
               a1=a(0,*) & a2=a(1,*)
               oplot,-a1,a2,color=bkgrd
               oplot,-a1,-a2,color=bkgrd
               a=ellipse(rmp,rmpb)
               a1=a(0,*) & a2=a(1,*)
               oplot,a1,a2,color=bkgrd
               oplot,a1,-a2,color=bkgrd
               a=ellipse(rbs,rbsa)
               a1=a(0,*) & a2=a(1,*)
               oplot,-a1,a2,color=bkgrd
               oplot,-a1,-a2,color=bkgrd
               ; a1=rbs*cos(deg)
               ; a2=rbs*sin(deg)
               a=ellipse(rbs,rbsb)
               a1=a(0,*) & a2=a(1,*)
               oplot,a1,a2,color=bkgrd
               oplot,a1,-a2,color=bkgrd
            endif
            if(orb_vw(i) eq 'xr') then begin
               nxs=n_elements(xmp)
               zdum=dblarr(nxs)
               ; estimate rotation angle from 4.30 abberrated GSE
               deg=2.15 & r=rot_x(xmp,rhomp,zdum,deg) & xmp=r(*,0) & rhomp=r(*,1)
               oplot,xmp,rhomp,color=bkgrd
               ; oplot,xmp,-rhomp,color=bkgrd
               deg=2.15 & r=rot_x(xbs,rhobs,zdum,deg) & xbs=r(*,0) & rhobs=r(*,1)
               oplot,xbs,rhobs,color=bkgrd 
               ; oplot,xbs,-rhobs,color=bkgrd
            endif
            ;TJK call sibeck2 again to get clean values for rhomp, xmp, etc. since 
            ;the above section of code modifies these values... 01/22/2001
            sibeck2,bz=bz,press=press,rhomp,xmp,rhobs,xbs
          
         endif ; GSE crd. sys. only one where mag. pause and bow-shock available

         epoch=dblarr(nel)
         x=dblarr(nel) 
         y=dblarr(nel)
         z=dblarr(nel)
         epoch=astrc.(ks).(epoch_index(ks)).dat(tind)

         case proj of
            'SSC':begin ; original SSC case
                  w3=execute('dist=astrc.(ks).XYZ_'+crd_sys+'.units')
                  ; RCJ 10/04/2004 look for fillval for all 'proj' cases. 
		  ;     Will use fval just before call to draw_orbit.
                  s=execute('fval= astrc.(ks).XYZ_'+crd_sys+'.fillval')
                  if(strupcase(dist) eq "KM") then scale=6371.2 else scale=1.0
                  if(strlen(strtrim(dist,2)) ne 0) then begin
                     w4=execute('x=astrc.(ks).XYZ_'+crd_sys+'.dat(0,tind)/scale')
                     w5=execute('y=astrc.(ks).XYZ_'+crd_sys+'.dat(1,tind)/scale')
                     w6=execute('z=astrc.(ks).XYZ_'+crd_sys+'.dat(2,tind)/scale')
                     if(not w3) or (not w4) or (not w5) or (not w6) then begin
                        print, " Error in the execute command for ssc variable "
                        return, -1
                     endif
                  endif
                  end ;SSC case
             'NEW':begin ; "NEW" case - those that are defined through the display_type
                  w3=execute('dist=astrc.(ks).(var_index).units')
                  s=execute('fval= astrc.(ks).(var_index).fillval')
                  if(strupcase(dist) eq "KM") then scale=6371.2 else scale=1.0
                  if(strlen(strtrim(dist,2)) ne 0) then begin
                     w4=execute('x=astrc.(ks).(var_index).dat(0,*)/scale')
                     w5=execute('y=astrc.(ks).(var_index).dat(1,*)/scale')
                     w6=execute('z=astrc.(ks).(var_index).dat(2,*)/scale')
                     if(not w3) or (not w4) or (not w5) or (not w6) then begin
                        print, " Error in the execute command for NEW cdaw variable "
                        return, -1
                     endif
                  endif
                  end 
            else: begin ;the original CDAWeb case
                  w3=execute('dist=astrc.(ks).'+crd_sys+'_pos.units')
                  s=execute('fval= astrc.(ks).'+crd_sys+'.fillval')
                  if(strupcase(dist) eq "KM") then scale=6371.2 else scale=1.0
                  if(strlen(strtrim(dist,2)) ne 0) then begin
                     w4=execute('x=astrc.(ks).'+crd_sys+'_pos.dat(0,tind)/scale')
                     w5=execute('y=astrc.(ks).'+crd_sys+'_pos.dat(1,tind)/scale')
                     w6=execute('z=astrc.(ks).'+crd_sys+'_pos.dat(2,tind)/scale')
                     if(not w3) or (not w4) or (not w5) or (not w6) then begin
                        print, " Error in the execute command for cdaw variable " 
                        return, -1
                     endif
                  endif
                  end 
         endcase

         ;cols=color_scale*ks
	 ; RCJ 02/17/2006  color_scale now is an array:
         cols=color_scale[ks-1]
         ;print, cols, color_scale

         ; RCJ 10/04/2004 remove fillvals.
	 ; Testing one coord at a time in case one has a fillval but
	 ; not the others. We still want to remove the bad point,
	 ; so we have to remove its x,y, and z coords.
	 if n_elements(fval) ne 0 then begin 
	 if (string(fval) ne ' ') then begin ; fillval is not empty
	    q=where(x ne fval)
	    epoch=epoch[q] & x=x[q] & y=y[q] & z=z[q]
	    q=where(y ne fval)
	    epoch=epoch[q] & x=x[q] & y=y[q] & z=z[q]
	    q=where(z ne fval)
	    epoch=epoch[q] & x=x[q] & y=y[q] & z=z[q]
	    ;help,epoch,x,y,z,q
	 endif 
	 endif  
	 ;
         draw_orbit,epoch,x,y,z,ks,xmp,rhomp,xbs,rhobs,doymark,hrmark,hrtick, $
            mntick,mnmark,color=cols,noclip=noclip,proj=orb_vw(i),$
            charsize=chtsize,date=datelabel,symsiz=symsiz,lnthick=lnthick

         ;legend,ks,labpos=labpos,sats=nsat,colors=cols,charsize=chtsize
         ;end  projection
      endfor
      nall_sats=nall_sats+nsat+'/'+strtrim(cols,2)+'/'
   endif ; end structure w/ crd_sys
endfor
;date_label

; Disclaimer run once
if(overplot eq 0) then begin 
; Get system time
    time_string=systime()
; Set Discliamer
   disclaimer=""
   if(proj ne 'SSC') then begin
    if(crd_sys eq 'SM' or crd_sys eq 'GSM' or crd_sys eq 'GM') then begin
       disclaimer="Key Parameter and Survey data (labels K0,K1,K2) are preliminary data. The "+crd_sys+" coordinate system is time varying."
    endif else begin
       disclaimer="Key Parameter and Survey data (labels K0,K1,K2) are preliminary data."
    endelse
   endif
   if(proj eq 'SSC') then disclaimer1="Generated by SSCweb on: "+time_string $
     else disclaimer1="Generated by CDAWeb on: "+time_string
; Set satellite legend
;2/26/2002 - TJK replace obsolete function str_sep w/ strsplit for IDL 5.3
;       s_prts=str_sep(nall_sats,'/')
        s_prts=strsplit(nall_sats,'/',/EXTRACT)

;unfortunately what's returned from strsplit is slightly different from str_sep
;(I believe its what str_sep should have been returning) anyway, the code below
;also had to be changed - TJK - 02/26/2002

       s_len=n_elements(s_prts)-1
;        if(s_len ge 2) then all_sat1=s_prts(1)+' *'
;        if(s_len ge 4) then all_sat2=s_prts(3)+' x'
;        if(s_len ge 6) then all_sat3=s_prts(5)+' !9V!X'
;        if(s_len ge 8) then all_sat4=s_prts(7)+' !7D!X'
;        if(s_len ge 10) then all_sat5=s_prts(9)+' *'
;        if(s_len ge 12) then all_sat6=s_prts(11)+' x'
;        if(s_len ge 14) then all_sat7=s_prts(13)+' !9V!X'
;        if(s_len ge 16) then all_sat8=s_prts(15)+' !7D!X'
;help,s_len
        if(s_len ge 1) then all_sat1=s_prts(0)+' *'
        if(s_len ge 3) then all_sat2=s_prts(2)+' x'
        if(s_len ge 5) then all_sat3=s_prts(4)+' !9V!X'
        if(s_len ge 6) then all_sat4=s_prts(6)+' !7D!X'
        if(s_len ge 9) then all_sat5=s_prts(8)+' *'
        if(s_len ge 11) then all_sat6=s_prts(10)+' x'
        if(s_len ge 13) then all_sat7=s_prts(12)+' !9V!X'
        if(s_len ge 15) then all_sat8=s_prts(14)+' !7D!X'
        if(s_len ge 17) then all_sat9=s_prts(16)+' *'
        if(s_len ge 19) then all_sat10=s_prts(18)+' x'
        if(s_len ge 21) then all_sat11=s_prts(20)+' !9V!X'
        if(s_len ge 23) then all_sat12=s_prts(22)+' !7D!X'


; Set region legend
       regions=' S/C in the Magnetosphere . . . !C S/C in the Magnetosheath _ _ _ !C S/C in the Solar Wind _____'

;     if((inc-1)) then ytpos=0.506 else ytpos=0.081
    ytpos=0.064 
;TJK - 02/26/2002 - modified to go to IDL 5.3 - the s_len and s_prts index are different now
;    if(s_len ge 2) then $
;     xyouts,0.41,ytpos,all_sat1,charsize=chtsize1,/normal,color=fix(s_prts(2))
;    if(s_len ge 4) then $
;     xyouts,0.56,ytpos,all_sat2,charsize=chtsize1,/normal,color=fix(s_prts(4))
;    if(s_len ge 6) then $
;     xyouts,0.71,ytpos,all_sat3,charsize=chtsize1,/normal,color=fix(s_prts(6))
;    if(s_len ge 8) then $
;     xyouts,0.86,ytpos,all_sat4,charsize=chtsize1,/normal,color=fix(s_prts(8))
;    if(s_len ge 10) then $
;     xyouts,0.41,(ytpos-.02),all_sat5,charsize=chtsize1,/normal,color=fix(s_prts(10))
;    if(s_len ge 12) then $
;     xyouts,0.56,(ytpos-.02),all_sat6,charsize=chtsize1,/normal,color=fix(s_prts(12))
;    if(s_len ge 14) then $
;     xyouts,0.71,(ytpos-.02),all_sat7,charsize=chtsize1,/normal,color=fix(s_prts(14))
;    if(s_len ge 16) then $
;     xyouts,0.86,(ytpos-.02),all_sat8,charsize=chtsize1,/normal,color=fix(s_prts(16))

    if(s_len ge 1) then $
     xyouts,0.41,ytpos,all_sat1,charsize=chtsize1,/normal,color=fix(s_prts(1))
    if(s_len ge 3) then $
     xyouts,0.56,ytpos,all_sat2,charsize=chtsize1,/normal,color=fix(s_prts(3))
    if(s_len ge 5) then $
     xyouts,0.71,ytpos,all_sat3,charsize=chtsize1,/normal,color=fix(s_prts(5))
    if(s_len ge 7) then $
     xyouts,0.86,ytpos,all_sat4,charsize=chtsize1,/normal,color=fix(s_prts(7))
    if(s_len ge 9) then $
     ;xyouts,0.41,(ytpos-.02),all_sat5,charsize=chtsize1,/normal,color=fix(s_prts(19))
     ; RCJ 12/04/2003 Typo. 19 should've been 9.
     xyouts,0.41,(ytpos-.02),all_sat5,charsize=chtsize1,/normal,color=fix(s_prts(9))
    if(s_len ge 11) then $
     xyouts,0.56,(ytpos-.02),all_sat6,charsize=chtsize1,/normal,color=fix(s_prts(11))
    if(s_len ge 13) then $
     xyouts,0.71,(ytpos-.02),all_sat7,charsize=chtsize1,/normal,color=fix(s_prts(13))
    if(s_len ge 15) then $
     xyouts,0.86,(ytpos-.02),all_sat8,charsize=chtsize1,/normal,color=fix(s_prts(15))
    if(s_len ge 17) then $
     xyouts,0.41,(ytpos-.04),all_sat9,charsize=chtsize1,/normal,color=fix(s_prts(17))
    if(s_len ge 19) then $
     xyouts,0.56,(ytpos-.04),all_sat10,charsize=chtsize1,/normal,color=fix(s_prts(19))
    if(s_len ge 21) then $
     xyouts,0.41,(ytpos-.06),all_sat11,charsize=chtsize1,/normal,color=fix(s_prts(21))
    if(s_len ge 23) then $
     xyouts,0.56,(ytpos-.06),all_sat12,charsize=chtsize1,/normal,color=fix(s_prts(23))

    press=string(press,format='(f5.1)') 
    bz=string(bz,format='(f5.1)')
    bsmp_lab='Solar Wind Pressure='+strtrim(press,2)+'nP  IMF BZ='+ $
              strtrim(bz,2)+'nT'

; New adjusting title
     if(panel) then yp=!p.position(3)+.013 else yp=0.975

     xyouts,0.5,yp,title1,charsize=1.8,align=.5,/normal,color=bkgrd
; end title

;       xyouts,0.10,0.64,all_sat,charsize=chtsize2,/normal,color=bkgrd
       xyouts,0.10,0.066,regions,charsize=chtsize1,/normal,color=bkgrd
       xyouts,0.01,0.02,disclaimer,charsize=chtsize2,/normal,color=bkgrd
       xyouts,0.01,0.008,disclaimer1,charsize=chtsize2,/normal,color=bkgrd
  if(bsmp) then xyouts,0.68,0.02,bsmp_lab,charsize=chtsize1,/normal,color=bkgrd

endif
 
return, status
end

