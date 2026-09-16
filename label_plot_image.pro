pro label_plot_image
;PROCEDURE: label_plot_image
;
;PURPOSE:   this program labels any plot and image in the PS device with the 
;	    present time, the name of the user, and the name of the program that
;	    produced the plot
;
;USE:	    include after the last plot- or tv-command in your program
;	    does only work in the ps-file
;	    if !p.multi is set (e.g. !p.multi=[0,2,2]) use it after the 
;	    LAST!! plot command, also if several plots are placed with 
;           position=[.....]  
;
;
;Version:   1.1  10-29-98 	H. Frey
;	    1.2  11-02-98	adjusted for image display
;---------------------------------------------------------------------------
; 

	; only do it in PS file
if (!d.name eq 'PS') then begin

	; any other operating system and IDL release has to be tested for the
	; proper help command (see IDL manual for HELP,/output
	; and the UNIX command 'who'
 if (!version.arch ne 'sparc' and !version.os ne 'sunos' and $
 	!version.os_family ne 'unix' and !version.release ne '5.1') then $
 	print,'!!!!!!!! WARNING !!! TEST HELP FOR THIS VERSION !!!!!!!!'

	; determine the size of the current PS device
 help,/device,output=this_output
; key_enca=strpos(this_output[3],'Non-Encapsulated')
 key_scal=float(strmid(this_output[6],17,10))

	; get the program name
 help,calls=bbb
 if (n_elements(bbb) gt 1) then begin
    anfangp=strpos(bbb[1],' ') 
    program_name=strlowcase(strmid(bbb[1],0,anfangp))
 endif else begin
    anfangp=strpos(bbb[0],' ') 
    program_name=strlowcase(strmid(bbb[0],0,anfangp))
 endelse
	; get the user name
 spawn,'who',users
 anfangu=strpos(users[0],' ')
 user_name=strmid(users[0],0,anfangu)
	; get the name of the current directory
 cd,current=old_dir

	; now label the image or plot
 xyouts,!d.x_size+!d.y_ch_size/key_scal,!y.margin[0]*!d.y_ch_size,/device, $
	strcompress(systime()+',  '+user_name+'!C'+old_dir+'/'+program_name), $
	charsize=0.75/key_scal,al=0.0,orient=90.0,color=0

endif

end