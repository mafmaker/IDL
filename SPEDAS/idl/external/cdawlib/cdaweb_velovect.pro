;+------------------------------------------------------------------------
; NAME: CDAWEB_VELOVECT
; PURPOSE: To plot a velocity field (uses normalized coords) on a map
; CALLING SEQUENCE:
;       cdaweb_velovect,u,v,x,y
; INPUTS:
;       u = x component of the 2D field.
;       v = y component of the 2D field.
;           The vector at point [i,j] has a magnitude of:
;			(U[i,j]^2 + V[i,j]^2)^0.5
;		and a direction of:
;			ATAN2(V[i,j],U[i,j]).
;       x = abcissae values, latitudes
;       y = ordinate values, longitudes
;
; KEYWORD PARAMETERS:
;       latpass   = Initial latitude of each particular pass
;       lonpass   = Initial longitude of each particular pass
;       missing   = Missing data value. (fillval)
;       length    = Length factor.  The default of 1.0 makes the longest (U,V)
;                   vector the length of a cell.
;       error     = 0=ok, -1=error occurred
;       color     = The color index used for the plot.
;     Note:   All other keywords are passed directly to the PLOT procedure
;       and may be used to set option such as TITLE, POSITION, NOERASE, etc.
;
; OUTPUTS:
;       None.
; AUTHOR:
;       Rita Johnson 12/2004. Based on velovect.pro
; MODIFICATION HISTORY:
;      
;-------------------------------------------------------------------------

PRO cdaweb_velovect,U,V,X,Y,$
        ;latpass=latpass,lonpass=lonpass, $
	Missing = Missing, Length = length, error=error,   $
        Color=color, CLIP=clip, projection=projection,$
	myscale=myscale, myunit=myunit, xy_step=xy_step, $
	nolabels=nolabels, _EXTRA=extra
;
error=0
s = size(u)
if s[0] ne 1 then begin 
   print,'STATUS= Cannot plot this array'
   print,'ERROR= U array must be 1D'
   error=-1 & return
endif
s = size(v)
if s[0] ne 1 then begin 
   print,'STATUS= Cannot plot this array'
   print,'ERROR= V array must be 1D'
   error=-1 & return
endif
s = size(x)
if s[0] ne 1 then begin 
   print,'STATUS= Cannot plot this array'
   print,'ERROR= X array must be 1D'
   error=-1 & return
endif
s = size(y)
if s[0] ne 1 then begin 
   print,'STATUS= Cannot plot this array'
   print,'ERROR= Y array must be 1D'
   error=-1 & return
endif
;if (keyword_set(latpass) and keyword_set(lonpass)) then begin
;   if n_elements(latpass) ne n_elements(lonpass) then begin
;      print,'ERROR= Latpass and lonpass must be of same size'
;      ; still do the map, but set these vars to 0:
;      latpass=0 & lonpass=0
;   endif
;endif
;
if n_elements(missing) le 0 then missing = 1.0e-30
if n_elements(length) le 0 then length = 1.0
if not keyword_set(myunit) then myunit='km/s'
;
;
q=where(u eq missing)
if (q[0] ne -1) then begin
   u[q]=0.0 & v[q]=0.0
endif   
;
if keyword_set(myscale) then begin
   u=[myscale,u] & v=[0.,v]
   if (projection eq 'Cylindrical') then begin
      x=[140,x]
      y=[-75,y]
   endif else begin  ; transverse mercator 
      x=[-100,x]
      y=[-10,y]
   endelse  
endif
;
scale=.01/max(abs([u,v])) ; .01 is a guess. we want small number
a=x+u*scale
b=y+v*scale
;
;res1=convert_coord(a,b,/data,/to_normal)
; RCJ 03/21/2006  After talking to Bobby, /to_device seems like a better option
res1=convert_coord(a,b,/data,/to_device)
a1=res1[0,*] & b1=res1[1,*]
;res2=convert_coord(x,y,/data,/to_normal)
res2=convert_coord(x,y,/data,/to_device)
x1=reform(res2[0,*]) & y1=reform(res2[1,*])
;
angle=atan(b1-y1,a1-x1)
;
mag = sqrt(u^2.+v^2.)             ;magnitude.
;
u1=mag*cos(angle)
v1=mag*sin(angle)
q=where(finite(u1) eq 0); find NaN's, make them 0's
if q[0] ne -1 then begin
   u1[q]=0. & v1[q]=0.
endif

u=u1
v=v1
x=x1
y=y1

good=where(u ne 0.0)
if good[0] ne -1 then ugood = u[good] else ugood=u[0]
if good[0] ne -1 then vgood = v[good] else vgood=v[0]
x0 = 0.;min(x)
x1 = 1.;max(x)
y0 = 0.;min(y)
y1 = 1.;max(y)
if keyword_set(xy_step) then begin
   x_step=(x1-x0)/(xy_step-1.)  
   y_step=(y1-y0)/(xy_step-1.)
endif else begin   
   x_step=(x1-x0)/(n_elements(ugood)-1.)  
   y_step=(y1-y0)/(n_elements(ugood)-1.)
endelse
if keyword_set(myscale) then begin
   maxmag=abs(ugood[0]/x_step)
endif else begin   
   maxmag=max([max(abs(ugood/x_step)),max(abs(vgood/y_step))])
endelse	

sina = length * (ugood/maxmag)
cosa = length * (vgood/maxmag)

if n_elements(title) le 0 then title = ''
if n_elements(color) eq 0 then color = !p.color
;x_b0=x0-x_step
;x_b1=x1+x_step
;y_b0=y0-y_step
;y_b1=y1+y_step
;if (not keyword_set(overplot)) then begin
;   if n_elements(position) eq 0 then begin
;      plot,[x_b0,x_b1],[y_b1,y_b0],/nodata,/xst,/yst, $
;           color=color, _EXTRA = extra
;   endif else begin
;      plot,[x_b0,x_b1],[y_b1,y_b0],/nodata,/xst,/yst, $
;           color=color, _EXTRA = extra
;   endelse
;endif
if n_elements(clip) eq 0 then $
   clip = [!x.crange[0],!y.crange[0],!x.crange[1],!y.crange[1]]
;
r = .5                          ;len of arrow head .3
angle = 15.5 * !dtor            ;Angle of arrowhead
st = r * sin(angle)             ;sin 22.5 degs * length of head
ct = r * cos(angle)
;
index=0L
if keyword_set(myscale) then begin
   x0 = x[good[0]]        ;get coords of start & end
   dx = sina[0]
   x1 = x0 + dx
   y0 = y[good[0]]
   dy = cosa[0]
   y1 = y0 + dy
   xd=x_step
   yd=y_step
   plots,[x0,x1,x1-(ct*dx/xd-st*dy/yd)*xd, $
      x1,x1-(ct*dx/xd+st*dy/yd)*xd], $
      [y0,y1,y1-(ct*dy/yd+st*dx/xd)*yd, $
      y1,y1-(ct*dy/yd-st*dx/xd)*yd], $
      color=color,clip=clip,_extra=extra
   if not(keyword_set(nolabels)) then $
      xyouts,[x0],[y0-.15*y0], $
      strtrim((round(myscale)),2)+' '+myunit,_extra=extra
   index=1L
endif

if good[0] ne -1 then begin
   ;for i=1L,n_elements(good)-1 do begin     ;Each point
   for i=index,n_elements(good)-1 do begin     ;Each point
      x0 = x[good[i]]        ;get coords of start & end
      dx = sina[i]
      x1 = x0 + dx
      y0 = y[good[i]]
      dy = cosa[i]
      y1 = y0 + dy
      xd=x_step
      yd=y_step
      plots,[x0,x1,x1-(ct*dx/xd-st*dy/yd)*xd, $
         x1,x1-(ct*dx/xd+st*dy/yd)*xd], $
         [y0,y1,y1-(ct*dy/yd+st*dx/xd)*yd, $
         y1,y1-(ct*dy/yd-st*dx/xd)*yd], $
         color=color,clip=clip,_extra=extra
   endfor
endif
;if not(keyword_set(nolabels)) then begin
;   if (keyword_set(latpass) and keyword_set(lonpass)) then begin
;      sz=size(latpass) ; or lonpass
;      if sz(0) ne 1 then begin 
;         for i=0,sz(2)-1 do begin
;            xyouts,lonpass[0,i],latpass[0,i],strtrim(string(i),2), $
;	    color=color,charsize=1.2
;         endfor   		       
;      endif
;   endif    
;endif
;
end
