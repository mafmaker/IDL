
pro dza_p,imageinfo,dza_arr

;
;  program: test_dza
;  date   : 6-27-2000
;  author : Thomas Immel, adapted from Mitch, John, Harald, and others.
;  purpose: Provide stripped down routine to quickly calculate spacecraft
;	    zenith angles using image subroutines.
;  means  : The gci vector to each point on Earth is determined, then 
;	  : the dot-product between that and the spacecraft vector 
;	  : is calculated. That 
;
;	  : version 1.0 It seems to be working just right.
;	  : version 1.0.1 added reverse statement.

;---compile several routines which will be used.




;flag_quick=0
;if flag_quick eq 1 then print ,'not restoring file' else begin;
;
;  print,'restoring file'
;  restore,'wic_june8_0603.idl'
;  print,'restored'
;  imageinfo=imageinfo(0)
;endelse

gci_flag=0

;    if (gci_flag eq 0) then fuv_ptg,ImageInfo(0), imageinfo(0).time, $
;         emis_hgt, glat, glon, l0, ras, decl, $
;         posX=posX, posY=posY, posZ=posZ, /geodetic $
;    else $
;		 fuv_ptg,ImageInfo(0), imageinfo(0).time, $
;         emis_hgt, glat, glon, l0, ras, decl, $
;        posX=posX, posY=posY, posZ=posZ


     nrows = imageinfo.rows
     ncols = imageinfo.cols
     angle_res_r = imageinfo.angl_res_r
     angle_res_c = imageinfo.angl_res_c

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
print,'!!!At the moment everything hard wired!!!!'
print,'!!!Remove later!!!'

     omega = imageinfo.inst_roll
     theta = imageinfo.inst_co_elev
     phi   = imageinfo.inst_azimuth
     scsv_x = imageinfo.sc_sv[0]
     scsv_y = imageinfo.sc_sv[1]
     scsv_z = imageinfo.sc_sv[2]
     sc_x = imageinfo.a_gci3[0]
     sc_y = imageinfo.a_gci3[1]
     sc_z = imageinfo.a_gci3[2]
     scpos_x = imageinfo.o_gci[0]
     scpos_y = imageinfo.o_gci[1]
     scpos_z = imageinfo.o_gci[2]
     psi = imageinfo.spin_phase		; in degrees

print,'hard coded in fuv_ptg'
omega=0.0
theta=0.94
phi=42.89
;stop
     transformation_matrix = fuv_rotation_matrix(omega,theta,phi, $
        scsv_x,scsv_y,scsv_z,sc_x,sc_y,sc_z,psi)

;... apply rotation

     result = transformation_matrix ## [[lpx[*]],[lpy[*]],[lpz[*]]]

;... determine Lpix

     LpixX = reverse(reform(result[*,0],ncols,nrows),1)
     LpixY = reverse(reform(result[*,1],ncols,nrows),1)
     LpixZ = reverse(reform(result[*,2],ncols,nrows),1)

     Ox = imageinfo.o_gci[0]
     Oy = imageinfo.o_gci[1]
     Oz = imageinfo.o_gci[2]

     emis_hgt=150.			;hand load emission height
					;where is this defined anyway???

     get_scalarP,Ox,Oy,Oz,LpixX,LpixY,LpixZ,emis_hgt,ncols,nrows,s,f, $
                off_axis,num_off_axis

     posX = Ox + s*LpixX
     posY = Oy + s*LpixY
     posZ = Oz + s*LpixZ

     dummy=posx & dummy(*)=0 & if off_axis(0) ne -1 then dummy(off_axis)=1
     on_axis=where(dummy eq 0)

     print,scpos_x,scpos_y,scpos_z

;---to vector is the vector from points on earth to the spacecraft.
     to_x=(scpos_x-posx)
     to_y=(scpos_y-posy)
     to_z=(scpos_z-posz)

;---calculate magnitude of each array of vectors, and dot product thereof

     mag_a=(to_x^2+to_y^2+to_z^2)^(0.5)
     mag_b=(posx^2+posy^2+posz^2)^(0.5)
     dot=to_x*posx+to_y*posy+to_z*posz
;---dza is simple
     dza_arr=acos(dot/(mag_a*mag_b))*!radeg
     if off_axis(0) ne -1 then dza_arr(off_axis)=-1

     dza_arr=reverse(dza_arr,1)

;     dza_arr=dummy & dza(*)=0
;     dza	
 

;--- A dot B= AB cos theta
;---this can all be reduced by not doing any off earth points, but it is
;---easier to visualize and debug in 2-D













return

end