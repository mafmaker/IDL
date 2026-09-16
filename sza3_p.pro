
pro sza3_p,imageinfo,sza_arr
	
;	
;
;  program: test_sza3
;  date   : 6-27-2000
;  author : Thomas Immel, adapted from Mitch, John, Harald, and others.
;  purpose: Provide stripped down routine to quickly calculate solar
;	    zenith angles using IMAGE subroutines.
;  means  : The gci vector to each point on Earth is determined, then 
;	  : the dot-product between that and the sun vector 
;	  : is calculated.
;
;	  0.89 :  Now proceduralized, I deleted the reverse on Lpix.
;		  There was no need for this that I know of!!!
;	       :  Also added several (0) indices to imageinfo references
;		  Totally bizarre that removing the reverse statements
;		  suddenly revealed the need for scalars everywhere.
;
;	  0.92 :  now is sza3_p, do not do _anything_ to imageinfo
;		  before passing it to the subroutine.
;
;;---compile several routines which will be used.


print,'calculating sza (sza3_p)'


flag_quick=1
if flag_quick ne 1 then begin

  print,'restoring file'
  restore,'wic_june8_0603.idl'
  print,'restored'
  imageinfo=imageinfo(0)
endif

gci_flag=0

;    if (gci_flag eq 0) then fuv_ptg,ImageInfo(0), imageinfo(0).time, $
;         emis_hgt, glat, glon, l0, ras, decl, $
;         posX=posX, posY=posY, posZ=posZ, /geodetic $
;    else $
;		 fuv_ptg,ImageInfo(0), imageinfo(0).time, $
;         emis_hgt, glat, glon, l0, ras, decl, $
;        posX=posX, posY=posY, posZ=posZ


     nrows = imageinfo(0).rows			;adding ZERO indices!!!
     ncols = imageinfo(0).cols
     angle_res_r = imageinfo(0).angl_res_r
     angle_res_c = imageinfo(0).angl_res_c

     versStr = 'FUV_PTG v1.0  1/2000'
     zrot  = DBLARR(ncols,nrows)
     yrot  = DBLARR(ncols,nrows)
     gclat = DBLARR(ncols,nrows)
     gclon = DBLARR(ncols,nrows)
     ra    = DBLARR(ncols,nrows)
     dec   = DBLARR(ncols,nrows)

     fill_value = -1.D31

;... single pixel angular resolution
     pr = angle_res_r       ; determined from fov of WIC or SI
     pc = angle_res_c       ; same

;... initialize output arrays to default
     gclat(*,*) = fill_value
     gclon(*,*) = fill_value
        ra(*,*) = fill_value
       dec(*,*) = fill_value

;... find rotation angles for each pixel
;    unless in uvilook, the axis definition is different for FUV
;    UVI defined the image axes as
;
;              UVI			FUV
;	zrot going horizontally		xrot going horizontally
;	yrot going vertically		yrot going vertically
;	x    going outward		z    going inward as photons

     a = (FINDGEN(ncols)- (ncols-1)/2)*pc
     b = REPLICATE(1.,nrows)
     xrot = a#b
     c = (FINDGEN(nrows)- (nrows-1)/2)*pr
     d = REPLICATE(1.,ncols)
     yrot = d#c

;... Determine Lpix
     tanx = tan(xrot*!DPI/180d)
     tany = tan(yrot*!DPI/180d)

     lpz = -1.D /SQRT(1.D + tany*tany + tanx*tanx)
     lpx = -lpz*tanx
     lpy = -lpz*tany

;... call the routine which determines the rotation matrix
;print,'!!!At the moment everything hard wired!!!!'
;print,'!!!Remove later!!!'

     omega = imageinfo(0).inst_roll
     theta = imageinfo(0).inst_co_elev
     phi   = imageinfo(0).inst_azimuth
     scsv_x = imageinfo(0).sc_sv[0]
     scsv_y = imageinfo(0).sc_sv[1]
     scsv_z = imageinfo(0).sc_sv[2]
     sc_x = imageinfo(0).a_gci3[0]
     sc_y = imageinfo(0).a_gci3[1]
     sc_z = imageinfo(0).a_gci3[2]
     scpos_x = imageinfo(0).o_gci[0]
     scpos_y = imageinfo(0).o_gci[1]
     scpos_z = imageinfo(0).o_gci[2]
     psi = imageinfo(0).spin_phase		; in degrees

;print,'hard coded in fuv_ptg'
omega=0.0
theta=0.94
phi=42.89
;stop
     transformation_matrix = fuv_rotation_matrix(omega,theta,phi, $
        scsv_x,scsv_y,scsv_z,sc_x,sc_y,sc_z,psi)

;... apply rotation

     result = transformation_matrix ## [[lpx[*]],[lpy[*]],[lpz[*]]]

;... determine Lpix ---this reverse gives BAD results on solar zenith angles.

     LpixX = reverse(reform(result[*,0],ncols,nrows),1)
     LpixY = reverse(reform(result[*,1],ncols,nrows),1)
     LpixZ = reverse(reform(result[*,2],ncols,nrows),1)

;
;  maybe this should be an arbitrary rotate,3, not a reverse,1
;

;     LpixX = reform(result[*,0],ncols,nrows)
;     LpixY = reform(result[*,1],ncols,nrows)
;     LpixZ = reform(result[*,2],ncols,nrows)

     Ox = imageinfo(0).o_gci[0]
     Oy = imageinfo(0).o_gci[1]
     Oz = imageinfo(0).o_gci[2]

     emis_hgt=150.			;hand load emission height
					;where is this defined anyway???

     get_scalarP,Ox,Oy,Oz,LpixX,LpixY,LpixZ,emis_hgt,ncols,nrows,s,f, $
                off_axis,num_off_axis

;---vectors to points on Earth from center (in GCI)

     posX = Ox + s*LpixX
     posY = Oy + s*LpixY
     posZ = Oz + s*LpixZ

     dummy=lpixx & dummy(*)=0 & if off_axis(0) ne -1 then dummy(off_axis)=1
     on_axis=where(dummy eq 0)

;     print,scpos_x,scpos_y,scpos_z	immaterial

;---get solar angular coordinates

     SUN3,imageinfo,GST,SLON,RA,DEC

;---convert to GCI vector of sun [sun_x,sun_y,sun_z]

     sun_z=sind(dec)
     sun_x=cosd(dec)*cosd(ra)
     sun_y=cosd(dec)*sind(ra)	;a much smaller unit vector, but no matter.

;---to vector is the vector from points on earth to the spacecraft.
;     to_x=(scpos_x-posx)
;     to_y=(scpos_y-posy)
;     to_z=(scpos_z-posz)

;---calculate magnitude of each array of vectors, and dot product thereof

     mag_a=(sun_x^2+sun_y^2+sun_z^2)^(0.5)	;
     mag_b=(posx^2+posy^2+posz^2)^(0.5)
     dot=sun_x*posx+sun_y*posy+sun_z*posz
;---dza is simple
     sza_arr=acos(dot/(mag_a*mag_b))*!radeg
     if off_axis(0) ne -1 then sza_arr(off_axis)=-1

     sza_arr=reverse(sza_arr,1)	;just like lats and lons have to be reversed


;stop


;     dza_arr=dummy & dza(*)=0
;     dza	
 

;--- A dot B= AB cos theta
;---this can all be reduced by not doing any off earth points, but it is
;---easier to visualize and debug in 2-D















end