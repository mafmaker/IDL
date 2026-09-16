pro remap_sami,image,lats,mapout,latres=latres_,lonres=lonres_
;
;  Remap_sami.pro
;
;  Code that takes the output of call_readu_dork_fuv.pro, prepares it
;  for trimag, calls trimag, and returns the outputs of trimag in
;  another structure
;
;

if keyword_set(latres) then latres=latres_ else latres=1.
if keyword_set(lonres) then lonres=lonres_ else lonres=0.5

image=image/max(image) * 600.    ; reduce to 600 rayleighs max right here
newim=congrid(image,360,100,/interp)
newlat=congrid(lats,360,100,/interp)

src='HWIC'  ; causes trimag to run in 16-bit mode
sza=newim-newim
dza=newim-newim
mlat=newim-newim
;mlt=newim-newim

sizer=size(newim)
dummy=intarr(sizer(2)) + 1
newlon=indgen(sizer(1))#dummy



imageinfo={image:newim,glat:newlat,glon:newlon,sza:sza,dza:dza,mlat:mlat,mlt:mlat,src:src}





trimag,imageinfo,mapim,latmax,latmin,/geo,/z,latres=latres,lonres=lonres

;stop

mapout={mapim:smooth(mapim,5),latmax:latmax,latmin:latmin}


end
