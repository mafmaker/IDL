@star_fit2d
@/home/immel/sci/fuv/dev/fuv_rotation_matrix
@/home/immel/sci/fuv/dev/fuv_ptg
@degree_trig
;;;@../model/correct_f107_p   <--- this is now in ~/idl directory

pro bin_cts3_p,filelist,ct_arr,wt_arr

;
;  Program to begin to characterize count rates as a function of
;  zenith angles. 
;
;  notes - 
;		maf is used as the variable name for the reduced-in-size
;		and fully reversed and rotated imageinfo files. sza_arr
;		and dza_arr will match up with maf.image, maf.glat, etc...
;
;  now calling dza2_arr which is slighly weird, but runs from geographic
;  coordinates, so it will at least not try to incorporate stars into
;  my dayglow!!!
;
;
;  12-7-2000   WHY is SI13 still screwing up!? The RAW average numbers
;		provide a terrible representation of the airglow. Just
;		try it with Bastille day images
;
;   --- they were screwing up because the pointing was a disaster
;
;

;sc_flag = 0             ;0=wic, 3=si12, 2=si13, NOW set in call.

restore,filelist(0)
case imageinfo.src of
  '12LS' : begin
	  	sc='s12'
	  	dim=128
		inst=3
		sc_flag=inst
		surface=replicate(1.,dim,dim)
	   end
  '13LS' : begin
		sc='s13'
		dim=128
		inst=2
		sc_flag=inst
		surface=replicate(1.,dim,dim)
	   end

  'HWIC' : begin
		sc='wic' 
		dim=256
		inst=0
		sc_flag=inst
		restore,'/home/immel/neo/sci/fuv/flatfield/wic_bias.idl'
	   end
endcase



imgs=size(filelist) & imgs=imgs(1)

  max_sza=110
  max_dza=89
  max_mlat=60

  mlt_arr=fltarr(imgs,max_sza,90) & mlt_arr(*)=0.
  ctsqr_arr=fltarr(imgs,max_sza,90) & ctsqr_arr(*)=0.
  ct_arr=dblarr(imgs,max_sza,90) & ct_arr(*)=0.		;bin images 
  wt_arr=lonarr(imgs,max_sza,90) & wt_arr(*)=0		;separately
  f107_arr=fltarr(imgs)
  alt_arr=fltarr(imgs)

print,'Number of Images', imgs

offset_arr=intarr(imgs)

year=0 & oldyear=1
day=0 & oldday=1

;set_plot,'ps'
;device,filename='bin_cts2_show.ps',/land


for i=0,imgs-1 do begin
  print,filelist(i),i
  restore,filelist(i) & stime=strcompress(imageinfo.time(0),/rem)
  print,'restored, fixing array rotations-transpostions'

;--- get flatfield now
  image_time,imageinfo.time,year,day,month,dom,hh,mm,ss
  flat_field=get_flatfield(year,day,inst)
;---

;--- roll in altitudes
  if i eq 0 then alt_arr=fltarr(imgs)
  alt_= sqrt(total(imageinfo.o_gci^2))
  alt_arr(i)=alt_

  maf=imageinfo(0)	;for WIC, 0 is the index
  imageinfo=maf


  img=maf.image ; this is now used
  tvscl,maf.image

;--- take care of missing pixels, bad lines in images

  badspots=where(img eq 0,badct)
  badim=maf.image & badim(*)=0 & if badct ne 0 then badim(badspots)=1
  if sc_flag eq 2 then badim(*,0:10)=1
  if sc_flag eq 3 then badim(*,0:12)=1
  if sc_flag eq 3 then badim(*,117:127)=1

;---

;  sza3_p,imageinfo,sza_arr	;pass raw, original, unrotated, unreversed
;  dza2_p,imageinfo,dza_arr	;imageinfo files to these subroutines.
  sza_arr=maf.sza
  dza_arr=maf.dza
  old_sza=sza_arr
  old_dza=dza_arr
  glat=maf.glat
  glon=maf.glon
  mlat=maf.mlat
  mlt=maf.mlt
  bla=strpos(filelist(i),'.idl')			;bla is just a spare
  shiftfile=strmid(filelist(i),0,bla) + '.off'
  print,shiftfile,' Should find this file!'
  spawn,'ls ' + shiftfile,bla
  
  if bla(0) ne '' then begin	;if there is an offset file, use it.
;    restore,shiftfile
    size_=size(imageinfo.glat) & size_=size_(1)
    blabla=strpos(filelist(i),'.idl')            ;bla is just a spare
    shiftfile=strmid(filelist(i),0,blabla) + '.off'           ;silly word
    print,shiftfile
    restore,shiftfile
        ;---need to blow away geographic coordinates that could wrap onto
        ;---image upon shifting
    if offset gt 0 then begin
       maf.mlat(0:offset,*)=-1
       glat(0:offset,*)=-1
       glon(0:offset,*)=-1
       sza_arr(0:offset,*)=-1
       dza_arr(0:offset,*)=-1
    endif else begin
       mlat(size_-1+offset:size_-1,*)=-1
       mlt(size_-1+offset:size_-1,*)=-1
       glat(size_-1+offset:size_-1,*)=-1
       glon(size_-1+offset:size_-1,*)=-1
       dza_arr(size_-1+offset:size_-1,*)=-1
       sza_arr(size_-1+offset:size_-1,*)=-1
    endelse
    mlat=shift(mlat,(-1) * offset)
    mlt=shift(mlt,(-1) * offset)
    glat=shift(glat,(-1) * offset)
    glon=shift(glon,(-1) * offset)
    sza_arr=shift(sza_arr,(-1) * offset)
    dza_arr=shift(dza_arr,(-1) * offset)
    offset_arr(i)=offset

;---pass shifts on if necessary for continued work --- IT IS
	maf.sza=sza_arr
	maf.dza=dza_arr

  endif
  
  onearth=where(glat lt 180 and glat gt -90)

;--- to not use pixels within 10 pixel widths of stars
;--- exclude them by setting sza to -1

  star_fit2d,imageinfo.image,coefs,/actual
  if coefs(0) ne -1 then begin
    coefs=transpose(coefs)
    imgsize=size(imageinfo.image) 
    stars=size(coefs) & stars=stars(1)
    for j=0, stars-1 do begin

	print,coefs(j,4),coefs(j,5) 	
	sza_arr(0>(coefs(j,4)-10):(imgsize(1)-1)< (coefs(j,4)+10), $
		0>(coefs(j,5)-10):(imgsize(2)-1)< (coefs(j,5)+10))=-1
    endfor
  
  endif
;---take care of background bias

  maf.image=maf.image-surface	;surface is the 3rd degree fit to the bias.

  if sc_flag eq 2 then begin
    year_=imageinfo.time(0)/1000
    day_=imageinfo.time(0) - 1000*year_
    flat_field=get_flatfield(year_,day_,2)
  endif
  maf.image=maf.image * flat_field

  toolow=where(maf.image lt 0) & if toolow(0) ne -1 then maf.image(toolow)=0

  dayglow=where(abs(mlat) lt max_mlat and sza_arr lt max_sza-1 $
		and dza_arr lt max_dza and dza_arr gt -1 and $
		sza_arr gt -1 and badim eq 0,pix)
;  test1=where(abs(mlat) lt max_mlat)
;  test2=where(sza_arr lt max_sza - 1)
;  test3=where(dza_arr lt max_dza)
;  test4=where(sza_arr gt -1)
;  dummy1=maf.image & dummy1(*)=1 & dummy1(test1)=0
;  dummy2=maf.image & dummy2(*)=1 & dummy2(test2)=0
;  dummy3=maf.image & dummy3(*)=1 & dummy3(test3)=0
;  dummy4=maf.image & dummy4(*)=1 & dummy4(test4)=0

  dummy=maf.image & dummy(*)=1
  dummy(dayglow)=0 & noglo=where(dummy eq 1)


  sza_index=round(sza_arr(dayglow))
  dza_index=round(dza_arr(dayglow))

 
  for j=0L,pix-1 do begin	;could be more pixels that you thought
    S=sza_index(j)	
    D=dza_index(j)
    mlt_arr(i,s,d)=maf.mlt(dayglow(j)) + mlt_arr(i,s,d)
    ct_arr(i,s,d)=maf.image(dayglow(j)) + ct_arr(i,s,d)
    ctsqr_arr(i,s,d)=maf.image(dayglow(j))^2 + ctsqr_arr(i,s,d)
    wt_arr(i,s,d)=wt_arr(i,s,d) + 1
  endfor

	tvscl,maf.image,256,0

;  surface,total(ct_arr(0:i,*,*),1)        / $
;	  total(wt_arr(0:i,*,*),1),title=filelist(i),charsize=2.1
;  stop

  ;--- do some 0th order checking of yourself (it has come to this)

  spareim=maf.image
  spareim(*)=0
  imavg=reform(ct_arr(i,*,*)/wt_arr(i,*,*))
  spareim(dayglow)=imavg(sza_index,dza_index)
  tvscl,bytscl((maf.image-spareim)/spareim,min=-0.6,max=0.6)


endfor

;device,/close
;set_plot,'x'


nodata=where(wt_arr eq 0)
data=where(wt_arr gt 0)
avg=ct_arr/wt_arr


big_ct=ct_arr
big_wt=wt_arr
big_mlt=mlt_arr
big_ctsqr=ctsqr_arr
ct_arr=total(ct_arr,1)
ctsqr_arr=total(ctsqr_arr,1)
wt_arr=total(wt_arr,1)
mlt_arr=total(mlt_arr,1)

avg(nodata)=0

end