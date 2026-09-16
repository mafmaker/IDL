;;;----------GLOBAL VARIABLES SET HERE
;
;   When will I put these in an include file????
;
	lat_res= 0.5			;degrees lat. for each mapped element
	lon_res= 0.5			;degrees longitude for "  "
	dza_cut1= 80.0			;first cutoff for calculating corners
	dza_cut2= 76.0			;second cutoff for mapping pixels
	lon_lim1= 88.0			;limits in longitude of pixels which
	lon_lim2= 272.0			;are mapped at any one time

	max_lon_diff = 90		;maximum lon difference for pixels
					;for best polar representation, need
					;this to be bigger than 10
	max_lat_diff = 10		;same for latitude

;-----------GLOBAL FLAGS
	de_flag=1			;if doing DE images (vs. VIS)
	sc_flag=2			;0=de, 1=vis, 2=FUV

	q_flag=1			;ask questions
	inter_flag=0			;interpolate at pole(s)
	glat_flag=0			;geographic(1) (vs. magnetic,0) coords.

	flat_flag=0			;do flat fielding
        xwin_flag=1			;running xwindows for graphical output?
	f107_flag=0			;make supplementary f107 corrections
					;---NOT to be used in 1981!!!
        pd_flag=0			;do percent diferences
        diff_flag=0			;do absolute differences! 
	bck_flag=0			;0 = use maf.bckgnd 1=request bckpath
	bckonly_flag=1			;map the background image only
	angle_flag=0			;map S and D to geo or mag coords
	save_flag=1
        impath_flag=1			;impath should be in the .dat file.
        shift_question=1		;for image, whether to look for .off
	shift_flag = 0			;files 
	fill_question=0			;fill in gaps by default
	fill_flag = 1			; "   " 

;-----------SYSTEM FLAGS
	vms=0 ;& vms_flag = 0
	sun=1
	
;-----------

print,lat_res,lon_res,dza_cut1,dza_cut2,lon_lim1,lon_lim2
case sc_flag of
	0:print,'DE Images'
	1:print,'POLAR VIS Images'
	2:print,'IMAGE FUV Images'
endcase