pro trimag,maf,mapim,lat_max,lat_min,geo=geo,mag=mag,z=z,$
	latres=latres,lonres=lonres,$
	nosamp_value=nosamp_value,legacy=legacy,stopper=stopper,$
	maxlatdiff=maxlatdiff,maxlondiff=maxlondiff,eightbit=eightbit, $
           de = de

;	noflags=noflags,passmap=passmap,
					       ;experimental keywords

;
; program to write and test some new mapping procedures
;
;  Author  : T. Immel - UCB
;  Date    : June 6, 2001
;  License : GPL  -  http://www.gnu.org/copyleft/gpl.html, so don't
;	     incorporate it into your binaries for distribution 
;            if you don't plan to share your changes to this code.
;
;
; This will be a procedure
;
;  INPUT : imageinfo, a structure containing
;		imageinfo.image
;		imageinfo.glat
;		imageinfo.glon 
;		imageinfo.sza
;		imageinfo.dza   and
;		imageinfo.mlat
;		imageinfo.mlt	if glat_flag eq 0
;		imageinfo.src   'HWIC','13LS', or '12LS' for IMAGE-FUV
;   OUTPUT : mapim, a grid of mapped pixels
;	     lat_min, lat_max (in degrees from south pole)
;	     the top and bottom of the returned array, mapim
;   KEYWORDS
;		geo - ignore default, set to geographic mapping
;		mag - ignore default, set to geomagnetic mapping
;		z - ignore default, do mapping in z buffer
;		latres - ignore default, redefine latitude resolution
;		latres - ignore default, redefine longitude resolution
;		nosamp_value - off image value in map grid
;				(set this to 88 to bypass this process!)
;		legacy - compatible with Immel's code which assumes 360 
;			degrees of longitude + one 
;               de - maf.img instead of maf.image
;
;   ISSUES : handles only integers counts now.
;   noflags is slightly dangerous! I am not sure I want to use this!
;   need to define where there are no samples! (DONE) 
;   CHANGES: 11-7-01
;	added 'EUV' capability (causes 16 bit mapping to occur);
;       added maxlatdiff and maxlondiff for low resolution images (EUV)
;       added eightbit keyword (for DE images, or other imageinfo w/o .src
;       Lower than 0.3 degree resolution, this starts to lose pixels! WHY?!
;         *Because you are not setting maxlatdiff and maxlondiff 
;	  *keywords smaller that the defaults, which obviously dont work!
;	12-2-01
;       added neg_flag variable, now can accept mafs which have negative
;		counts (happens with background subtraction)
;       08-01-02 : S-13 images are coming up with 100s of counts over
;                  base values, WHAT IS GOING ON?! (You have to NOT
;                  send negative values over here to trimag.
;       09-27-02 : use of z buffer tends to hose postscript. Try to
;                  save the original device and set back to it when done 
;   Other notes : This code was inspired by discussions with Scott
;   Claflin at Lockheed-Martin, who has used the polyfill routine for 
;   other similar uses. It replaces vismag.
;
;       05-02-04 : ATTENTION! You should definitely use the Z buffer if you are
;       on a Mac. !!!
;       03-25-19 : Works with no modification for GOLD, detecting high
;       counting rates and switching to 16 bit mode. Pondering how dsk is
;       used and how dza_cut1 is used or passed, without this code crashing?
;
;


@trimag_flags
nosamp_value=-1 
old_name=!d.name

;if keyword_set(noflags) eq 0 then @trimag_flags ;default values for flags

if keyword_set(z) eq 1 then xwin_flag=0   ;else xwin_flag = 1
if keyword_set(geo) eq 1 then glat_flag=1 ;else glat_flag=0
if keyword_set(mag) eq 1 then glat_flag=0 ;else glat_flag=1
if keyword_set(latres) gt 0 then lat_res=latres
if keyword_set(lonres) gt 0 then lon_res=lonres
if keyword_set(nosamp_value) gt 0 then nosamp_value=nosamp_value
if keyword_set(maxlatdiff) gt 0 then max_lat_diff=maxlatdiff
if keyword_set(maxlondiff) gt 0 then max_lon_diff=maxlondiff
if keyword_set(de) gt 0 then de_flag = 1 else de_flag =  0

if de_flag eq 0 then sizer=size(maf.image) else sizer = size(maf.img)
xsize=sizer(1)
ysize=sizer(2)

if de_flag eq 1 then bit_flag = 8 else $
if maf.src eq 'HWIC' or maf.src eq 'EUV' or maf.src eq 'GOLD' then bit_flag = 16 else bit_flag = 8

print,bit_flag,' Bit Flag'

if de_flag eq 0 then img=maf.image else img = maf.img
if glat_flag then begin
  glat=maf.glat & glon=maf.glon
endif else begin
  glat=maf.mlat & glon=maf.mlt*15.      ;mag lat & magnetic time!
endelse

sza=maf.sza
dza=maf.dza

;--- give an upper right frame of bad sza values, since we don't have coords
sza(xsize-1,*)=-1
sza(*,ysize-1)=-1
sza(0,*)=-1
sza(*,0)=-1
;---

GLONCORR=GLON 		;0-24 mlt ---> 0-360 'glon'
if glat_flag then SHIFTLONG,GLONCORR	;

dsk=where(sza ne -1 and img ne -1 and dza lt dza_cut1,counter)

;--- had to wait until this point to see what pixels were to be used, but
;--- if there are negative counts, then switch to 16 bit mode

neg_flag = 0
lowest_ct = 0

if counter le 0 then begin
  print,'No pixels in disk region'
  mapim=-1
  goto, BAILOUT
endif

negative=where(img(dsk) lt 0,negcount) & if negcount gt 0 then begin
  neg_flag=1
  lowest_ct=min(img(dsk))
  img=img - lowest_ct	;remove this bias later  

;--- only run in 16 bit mode if absolutely necessary

  if max(img) gt 255 then begin
	  bit_flag = 16
          print,'Negative values found, switching to 16 bit mode'
  endif
endif

gLAT(dsk)=(GLAT(DSK)+90.)
gLON(DSK)=(GLONCORR(DSK))
minlat=min(glat(dsk)) & lat_min=minlat
maxlat=max(glat(dsk)) & lat_max=maxlat
minlon=min(glon(dsk))
maxlon=max(glon(dsk))
minlonb4=minlon
maxlonb4=maxlon

;---define coordinates of corners of pixel

nglat=glat
nglat(dsk)=nglat(dsk)-minlat
coords=replicate(0.,8,counter)

lllat=shift(shift(nglat,0,0),0,0)
lrlat=shift(shift(nglat,0,0),-1,0)
ullat=shift(shift(nglat,0,-1),0,0)
urlat=shift(shift(nglat,0,-1),-1,0)
lllon=shift(shift(glon,0,0),0,0)
lrlon=shift(shift(glon,0,0),-1,0)
ullon=shift(shift(glon,0,-1),0,0)
urlon=shift(shift(glon,0,-1),-1,0)

coords(0,*)=lllat(dsk)/lat_res ;ll
coords(1,*)=lllon(dsk)/lon_res ;ll

coords(2,*)=lrlat(dsk)/lat_res ;lr
coords(3,*)=lrlon(dsk)/lon_res ;lr

coords(6,*)=ullat(dsk)/lat_res ;ul
coords(7,*)=ullon(dsk)/lon_res ;ul

coords(4,*)=urlat(dsk)/lat_res ;ur
coords(5,*)=urlon(dsk)/lon_res ;ur

;--- the following array will help up in mapping pixels at the 0-360 demarc.

lons_shift=coords([1,3,5,7],*) * lon_res	;back to degrees
lons_shift=lons_shift - 180.
shiftlong,lons_shift
coords_shift=coords
coords_shift([1,3,5,7],*)=lons_shift/lon_res	;back to indices


;--- handle 16 bit images starting now

if bit_flag eq 16 then begin 
  print,'16-bit mode yes'
  counts=bytarr(counter,2)
  imhigh = img / 256
  imlow = img mod 256
  counts(*,0)= imlow(dsk)	;most significant byte
  counts(*,1)= imhigh(dsk)	;least significant byte
endif else begin			;8 bit image
  print, '8-bit mode'
  counts=bytarr(counter)
  counts(*)=img(dsk)
endelse

;--- define grid to map these pixels into

xsizer=360 & minlon=0 & maxlon=359.999
ysizer=abs(fix(maxlat + 1) -fix(minlat))
;mapim=lonarr(fix(xsizer/lon_res)+1,fix(ysizer/lat_res)+1)
;minmapim=-1                             ;never comment this out!

xxsize=fix(xsizer/lon_res)
if keyword_set(legacy) gt 0 then xxsize=xxsize + 1
xysize=fix(ysizer/lat_res)

;if pd_flag eq 1 then minmapim=-61
;if diff_flag eq 1 then minmapim=-32000  ; this will be changed later
;mapim(*,*)=minmapim

if xwin_flag eq 1 then $
	window,0,xsize=xxsize,ysize=xysize $
else begin
  set_plot,'z'
  device,set_resolution=[xxsize,xysize],z_buffer=0
endelse

;---do not map across 0-360 boundary, 
;---or to pixels flagged off earth (negative).
;---or to places where the latitudes are stretched over XX degrees

;help,coords


bad1=abs(coords(1,*)-coords(3,*))
bad2=abs(coords(5,*)-coords(7,*))
bad3=abs(coords(1,*)-coords(5,*))
bad4=abs(coords(3,*)-coords(7,*))
bad5=abs(coords(0,*)-coords(6,*))
bad6=abs(coords(2,*)-coords(4,*))
bad7=abs(coords(0,*)-coords(2,*))
bad8=abs(coords(4,*)-coords(6,*))

xcoords=[coords(1,*),coords(3,*),coords(5,*),coords(7,*)]
ycoords=[coords(0,*),coords(2,*),coords(4,*),coords(6,*)]

newdsk=where(bad1 lt max_lon_diff and bad2 lt max_lon_diff and $
	bad3 lt max_lon_diff and bad4 lt max_lon_diff and $
	bad5 lt max_lat_diff and bad6 lt max_lat_diff and $
	bad7 lt max_lat_diff and bad8 lt max_lat_diff and $
	total(abs(xcoords),1) eq total(xcoords,1) and $
	total(abs(ycoords),1) eq total(ycoords,1),counter2)
;help,newdsk


;--- baddsk is for mapping ONLY the pixels which stretch across the 0-360
;--- boundary, not the rest of the bad pixels, so those are still flagged
;--- as in newdsk

baddsk=where(bad1 gt max_lon_diff or bad2 gt max_lon_diff or $
	bad3 gt max_lon_diff or	bad4 gt max_lon_diff and $
	bad5 lt max_lat_diff and bad6 lt max_lat_diff and $
	bad7 lt max_lat_diff and bad8 lt max_lat_diff and $
	total(abs(xcoords),1) eq total(xcoords,1) and $
	total(abs(ycoords),1) eq total(ycoords,1),counter3)

;--- create indices, but do not use them yet
xcoords_shift=[coords_shift(1,*),coords_shift(3,*),$
		coords_shift(5,*),coords_shift(7,*)]
ycoords_shift=[coords_shift(0,*),coords_shift(2,*),$
		coords_shift(4,*),coords_shift(6,*)]



;newcoords=coords(*,newdsk)
;bad_coords=coords_shift(*,baddsk)	;already shifted for when we 
					;shift mapim and do the remaining
					;pixels


loops=0
if bit_flag eq 16 then loops=1


;--- now fill the array, possibly with 2 passes

for j=0,loops do begin

  cts2use=reform(counts(newdsk,j))
;  help,cts2use
  if counter3 gt 0 then badcts2use=reform(counts(baddsk,j))
  if j eq 1 then erase

  if counter2 gt 0 then for i=0l,counter2-1 do begin
    xcoords1=xcoords(*,newdsk(i))
    ycoords1=ycoords(*,newdsk(i))
    polyfill,xcoords1,ycoords1,color=cts2use(i),/device
  endfor

;--- it's important to put these pixels back later

  a=tvrd() & a=shift(a,fix(xsizer/lon_res)/2,0) 

;--- but first discriminate between on-off earth image pixels
;--- don't do this in both low and high bit passes! (j check)
;--- also can bypass whole thing by setting nosamp_value to 88 in call!

  if keyword_set(nosamp_value) ne 88 and j eq 0 then begin

;--- prepare zbuffer or window

    polyfill,[0.,0,xxsize,xxsize],[0.,xysize,xysize,0.],color=200,/device  

;--- 

    if counter2 gt 0 then for i=0l,counter2-1 do begin
      xcoords1=xcoords(*,newdsk(i))
      ycoords1=ycoords(*,newdsk(i))
      polyfill,xcoords1,ycoords1,color=0,/device
    endfor
    aaa=tvrd() & aaa=shift(aaa,fix(xsizer/lon_res)/2,0) & tv,aaa
    if counter3 gt 0 then for i=0l,counter3-1 do begin
      xcoords2=xcoords_shift(*,baddsk(i))
      ycoords2=ycoords_shift(*,baddsk(i))
      polyfill,xcoords2,ycoords2,color=0,/device
    endfor

    aaa=tvrd() & aaa=shift(aaa,fix(xsizer/lon_res)/2,0)
    nosamp=where(aaa eq 200,nocount)

  endif  ; this will have been done unless you said '88'

;--- back to what we were doing in the first place

  tv,a	;NOT TVSCL!!!

;--- do the pixels at the 0-360 demarcation

  if counter3 gt 0 then for i=0l,counter3-1 do begin
    xcoords2=xcoords_shift(*,baddsk(i))
    ycoords2=ycoords_shift(*,baddsk(i))
    polyfill,xcoords2,ycoords2,color=badcts2use(i),/device
  endfor

;--- now read them again, shifting them another 180 degrees, finally

  a=tvrd() & a=shift(a,fix(xsizer/lon_res)/2,0)

;--- shouldn't I be doing this with aaa as well?? hmm

;---

  if j eq 1 then high_mapim=a
  if j eq 0 then low_mapim=a
  
endfor

if bit_flag eq 16 then begin
  mapim=256.*high_mapim + 1. * low_mapim
  if neg_flag gt 0 then mapim=mapim + lowest_ct
endif else mapim=low_mapim

mapim=float(mapim)				;so you can set it to -1!!!
if nocount gt 0 then mapim(nosamp)=nosamp_value

BAILOUT:

;if xwin_flag ne 1 then ps_close
set_plot,old_name   ; don't want to close PS device yet! 09-27-02

if keyword_set(stopper) eq 1 then stop



end




