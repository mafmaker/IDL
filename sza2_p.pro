
pro sza2_p,imageinfo,sza_arr

; program - test_sza2
; date    - 6-22-2000
; author  - thomas immel
; purpose - calculate sza for one image from geographic coordinates
;         eventually make it callable and integrable into fuview and
;         any other IMAGE software
;
; variables - 
;	lono,lato =length of line in equatorial (solar-meridional) 
;		   plane tangent to subsolar point, between that
;		   point and intersection with lat (lon) vector of
;		   geographic point in question in meridional (equatorial)
;		   plane. 
; version notes
;	  - 0.1 second try
;	  - 0.2 it works rotating the sun vector to [1,0,0]
; 		but the solar zenith angles simply look wrong. They to 
;		not correspond to the image. The xarrays and yarrays also 
;		seem to be rotated differently than they should. 
;	  - 0.3 returning to this after fling with test_sza3.pro as
;	  	I now know that the geographic coords are reversed.
;	   	The imaging coords are worse, requiring a rotate(,5).
;   	  - 0.4 proceduralized to watch the rotations carefully.
;		the slon,/slon thing is terrible. _extra?
; rotate
; arg		Transpose? 	Rotate?
; 0		No		None		X0	Y0	
; 1		No		90°		-Y0	X0	
; 2		No		180°		-X0	-Y0	
;***3***	No		270°		Y0	-X0	
; 4		Yes		None		Y0	X0	
; 5		Yes		90°		-X0	Y0	
; 6		Yes		180°		-Y0	-X0	
; 7		Yes		270°		X0	-Y0
;
;  THis is due to things being stuffed in the UDF in a strange manner.
;  Now I have to revisit all those signs I was throwing about haphasardly
;  Since I thought *I* was doing something wrong.;
;
;	- 0.4	Why this works better than test_sza3, I don't know.
;		But we have to make them give the same result, ASAP.
;	-0.89   Don't do ANYTHING to imageinfo before you pass it. 
;		this is now simply sza2_p.pro sza_p.pro is not to be
;		used (yet)
;	-	sza_3 is faster!

;;;;;;;;pro test_sza2,imageinfo,sza_arr   uncomment to 'proceduralize'

flag_quick=1
if flag_quick ne 1 then begin

  print,'restoring file'
;  restore,'wic_may25_1355.idl'
;  restore,'wic_june8_0603.idl'
  restore,'wic_june8_2015.idl'
  print,'restored, creating arrays'

endif

glat=double(reverse(imageinfo(0).glat,1))	;reversed per Frey's work
glon=double(reverse(imageinfo(0).glon,1))	;in image_dev/main_scr.pro
image=rotate(imageinfo(0).image,3)

;---there is a serious problem with the longitudes in the saved wic files
;print,'correcting longitudes for backwardness!'
;  glon=abs(glon-360) +90
;  lon_adjust=where(glon gt 360.)             ;labbook page 1 for sketch
;  glon(lon_adjust)=glon(lon_adjust)-360.
;---



onearth=where(glat gt -999 and glon gt -999,numpoints)

r=1.
theta=glat(onearth)+90			;0-180, theta defined from +z axis
phi=glon(onearth)  			;0-360

rz=r * cosd(theta) 
rx=r * sind(theta) * cosd(phi)
ry=r * sind(theta) * sind(phi); 

;;;;glon=shift(glon,-1,1)   ;just testing

time=imageinfo(0).time
utseconds=time(1)/1000.
year=time(0)/1000
doy=time(0) mod 1000
slat=0.
slon2=0.

;print,'subsol-shiftlong'


subsol, year, doy, slat, slon2, utsec=utseconds

shiftlong,slon2				;-180 to 180 -> 180->360/0->180
if keyword_set(slon) then slon2 =slon_ 	;set slon2 to passed value
slon=slon2				;set slon to one or the other
;print,slon



;slat=slat				;+90 not necessary, as in the
					;rotation, theta is defined from
					;the xaxis as usual
slatz=r * sind(slat) * (-1.)
slatx=r * cosd(slat) * cosd(slon)
slaty=r * cosd(slat) * sind(slon) * (-1.)

;---t for test
tlatz=r * sind(slat) * (-1.)
tlatx=r * cosd(slat) * cosd(slon-90.)
tlaty=r * cosd(slat) * sind(slon-90.) * (-1.)

print,'calculating sza (sza2_p)'	

;---------rotate vector about geographic pole to align 0 lon with sun

;---first create array of ones
thing=fltarr(numpoints) & thing(*)=1

;---prepare to do all transformations at once.
A_matrix=fltarr(3,3,numpoints)
A_matrix(0:2,0,*)=[cosd(slon),-1*sind(slon),0]#thing
A_matrix(0:2,1,*)=[sind(slon),cosd(slon),0]#thing
A_matrix(0:2,2,*)=[0,0,1]#thing

;A_matrix=a_matrix

rprime=fltarr(3,numpoints)
rprime(0,*)=rx
rprime(1,*)=ry
rprime(2,*)=rz

;---here is a test point at the subsolar point
;---comment this OUT for science work


;rprime(*,0)=[slatx,slaty,slatz]
;rprime(*,1)=[tlatx,tlaty,tlatz]



;---

rorig=rprime
rprime=a_matrix#rprime

;---------the above works, it eliminates the y component of the subsolar vector
;---------now rotate the new vector such that the 'equator' is at the subsolar
;---------point 

B_matrix=fltarr(3,3,numpoints)
B_matrix(0:2,0,*)=[cosd(slat),0,sind(slat)]#thing
B_matrix(0:2,1,*)=[0,-1,0]#thing
B_matrix(0:2,2,*)=[-1*sind(slat),0,cosd(slat)]#thing

;B_matrix=b_matrix*(-1)

rdprime=rprime
rdprime=b_matrix#rdprime

;-----the above works, it eliminates the remaining z component of the subsolar
;-----vector.
;-----now get back to a new rotated set of angles

;lat=atan(z/xyprojection)
;lon=atan(x/y)

;---these are the new lats and lons---

glat_prime=atan(rdprime(2,*)/rdprime(0,*)) * !radeg
glon_prime=atan(rdprime(1,*)/rdprime(0,*)) * !radeg

xtra_glat=glat_prime				;difference latitude
xtra_glon=glon_prime				;"      "   longitude


;---need array of 1,-1 (Re) to get to tangent angles > 90 degrees
;---back means dark side of Earth

front_back=rdprime(0,*) & back=where(front_back lt 0.,count_back)
front_back(*)=1 
if count_back eq 0 then front_back(*)=-1
if count_back gt 0 then front_back(back)=-1
;help,front_back
;front_back=front_back*(-1)		;did not need to do that afterall

lono=abs(tand(xtra_glon))		;length of opposite face
lato=tand(xtra_glat)			;"   "      "       " 

line_sun_to_vector=sqrt((lono^2) + (lato^2))

if count_back gt 0 then $
sza=atan(line_sun_to_vector,front_back) * !radeg else $
sza=atan(line_sun_to_vector) * !radeg

sza_arr=glat & sza_arr(*)=0
sza_arr(onearth)=sza  

;----debugging work
;new_glat=glat & new_glat(*)=0 & new_glon=new_glat & newline=new_glon
;old_x=new_glat & old_y=new_glat & old_z=new_glat
;mid_x=new_glat & mid_y=new_glat & mid_z=new_glat
;new_x=new_glat & new_y=new_glat & new_z=new_glat

;old_x(onearth)=rorig(0,*) & old_y(onearth)=rorig(1,*) 
;old_z(onearth)=rorig(2,*)

;mid_x(onearth)=rprime(0,*) & mid_y(onearth)=rprime(1,*) 
;mid_z(onearth)=rprime(2,*)

;new_x(onearth)=rdprime(0,*) &  new_y(onearth)=rdprime(1,*)  
;new_z(onearth)=rdprime(2,*) 

;new_lato=new_glat & new_lono=new_glon
;new_glat(onearth)=xtra_glat
;new_glon(onearth)=xtra_glon

;newline(onearth)=line_sun_to_vector
;new_lato(onearth)=lato
;new_lono(onearth)=lono

glonlev=findgen(36)*10
;contour,(glon(169:175,108:114)),levels=glonlev        
;contour,(glat(169:175,108:114))


return
end


function cosd,angle
  angle2=angle/!radeg
  cosine=cos(angle2)
return,cosine
end

function sind,angle
  angle2=angle/!radeg
  sine=sin(angle2)
return,sine
end

function tand,angle
  angle2=angle/!radeg
  tangent=tan(angle2)
return,tangent
end
