function pressure_alt_f,iiyd,uts,gla,glo,f107m,f107,ap,p_target
;
;  THIS PROGRAM IS CREATED TO REPLACE SEARCH_ALT_F.PRO
;  IT USES GHP6 TO FIND THE ALTITUDE OF A PARTICULAR PRESSURE LEVEL,
;  INSTEAD OF ITERATIVELY SEARCHING THROUGH ALTITUDES AND CALCULATING
;  PRESSURES USING GTD6, the most often called MSIS routine.
;
; idl program creates 9 necessary values for MSIS 
; and calls msisdriver_sub
;
; inputs are the regular msis inputs and pressure which
; must be given in Torr. It is converted here to mbars
; before being handed to MSIS
;
;
; the output is the altitude of the pressure level.
;
; This works GREAT!!!
;

torr_2_mbar=1.33322

p_target=p_target * torr_2_mbar

press_alt=3420.	; the variable which will hold the new pressure altitude
		; set to garbage number to demonstrate there is no effect
		; of this choice on the outcome.


den=fltarr(8)	;should get returned as a real_array!
temp=fltarr(2)  ;should be returned as a real_array!


  slt=float( fix(uts/3600.) + glo/15.)

  obj_2_call='callghp6_'
;  if !version.os eq 'darwin' then obj_2_call='callghp6_'

  result=call_external('/home/immel/sci/msis/msis.so',obj_2_call,iiyd,uts,$
	     press_alt,gla,glo,$
             slt,f107m,f107, ap, den, temp, p_target )

return,press_alt
end
