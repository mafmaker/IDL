pro get_f107_for_time_p,imagetime,f107,f107m

;# Program to return f107 for the time of a given image. 
;# imagetime is imageinfo.time
;# Forget about UT for now
;#
;#
;
;  Changes : returns f107m for february onward
;
;
;
  stime=strcompress(imagetime(0),/rem)
  year=(strmid(stime,0,4)) & day=fix(strmid(stime,4,3))

	restore,'/home/immel/sci/f107/'+year+'f107.idl'
	print,'Restoring ' + '/home/immel/sci/f107/'+year+'f107.idl'


  f107=annual(day-1)
  f107m=mean(annual(day-31 > 0: day-1 ))

return
end