pro fill_map,mapim,flagoff=flagoff

;
;  
;
;
;
;
;  The Genius of RSI : to write two interpolation functions, neither of
;   which can be caused to interpolate a 2-D array to points where data;
;   are missing.
;
;  Seriously, interp is for vectors only, and interpolate will interpolate
;  data flagged to -999 or -1e-38 right down to those values. There is NO
;  WAY that I see to get around that. 
;
;  fill_map provides a modest and fairly quick way around this serious
;  limitation of the interpolation routines. It calculates
;  mean values where data are missing, in a 3x3 box only right now. It won't
;  do it if the majority of points in the moving box are flagged (-1 is the
;  flag now)
;  
;  The dilation operation allows one not to sort through the whole image.
;  It saves time.
; 
;  CHANGES - 
;
;  Now there is one keyword which, if provided, sets the bad_data flag.
;  This must be one (1) integer step below the lowest allowed good data flag
;

if keyword_set(flagoff) lt 1 then flagoff=-1

;restore,'s1220010231944.map'
sizer=size(mapim)
sizex=sizer(1) & sizey=sizer(2)

b=mapim gt flagoff
s=replicate(1,3,3)
d = (dilate(B, S))

thing=where((d-b) eq 1,counter)
thingx=thing mod sizex & thingy=fix(thing/sizex)

meanie=fltarr(3,3,counter)
filler=fltarr(counter)
fillcount=fltarr(counter)
newmapim=mapim

for i=0,counter-1 do begin

  if thingx(i) gt 1 and thingx(i)+1 lt sizex $
         and thingy(i) gt 1 and thingy(i)+1 lt sizey then begin
    meanie(*,*,i)=mapim(thingx(i)-1:thingx(i)+1,thingy(i)-1:thingy(i)+1)  
    user=meanie(*,*,i)
    filler(i)=mean(user(where(user gt flagoff,xxx)))
    fillcount(i)=xxx

  endif

;--- do a single for loop. not 2. Changing mapim here, does this affect
;--- previous stuff??? Create newmapim

  if fillcount(i) gt 4 then begin 
	meanie(*,*,i) =$
	(meanie(*,*,i) le flagoff)*filler(i)  + $   ;add average to bad
;;;;	(meanie(*,*,i) le flagoff)*flagoff    + $   ;UNNECESSARY 
	(meanie(*,*,i) gt flagoff) * meanie(*,*,i)  ;add good!
    newmapim(thingx(i)-1:thingx(i)+1,thingy(i)-1:thingy(i)+1)  =meanie(*,*,i)
  endif



endfor


mapim=newmapim

;toavg=total(total(meanie gt 1,1),1)
;newthing=where(toavg lt 5,todoavg)

;stop

;for i=0,counter-1 do begin
;  if fillcount(i) gt 4 then begin 
;	meanie(*,*,i) =$
;	(meanie(*,*,i) le flagoff)*filler(i)  + $   ;add average to bad
;	(meanie(*,*,i) le flagoff)*flagoff    + $   ;zero out flagoff    
;	(meanie(*,*,i) gt flagoff) * meanie(*,*,i)  ;add good!
;    mapim(thingx(i)-1:thingx(i)+1,thingy(i)-1:thingy(i)+1)  =meanie(*,*,i)
;  endif
;endfor

;stop
return
end




