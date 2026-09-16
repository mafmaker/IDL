;run @compile_cdaweb before executing
;checkfiles looks through a given directory worth of CDF files and looks for
;variables with a display_type attribute equal to whatever the plottype
;keyword is set to, or SPECTROGRAM by default.  Once it finds a variable of
;with the given plottype, then it looks to see whether it has a scalemin/max
;and or validmin/max attribute and compares their values.  It prints out
;its findings to an output file specified by the outfile keyword or to 
;output.lis by default.
;
;written by Tami Kovalick, March 1, 2001 
;
;
pro checkfiles, plottype=plottype, indir=indir, outfile=outfile, debug=debug

if keyword_set(plottype) then plottype=strupcase(plottype) else plottype = 'SPECTROGRAM'
if keyword_set(indir) then input_files = indir + '*.cdf' else $
	input_files = '/ncf/rumba1/istp/0MASTERS/*.cdf'
if keyword_set(outfile) then outfile=outfile else outfile = 'output.lis'

;get the list of cdf files in this directory
cdffiles = findfile(input_files)

;open the output report file
openw, lun, outfile, /get_lun
printf, lun, 'Processing ',n_elements(cdffiles),' cdf files in the ',input_files,' directory.'
printf, lun, '       '
printf, lun, 'Looking for variables with their display_type set to ',plottype

!quiet = 1 ;turn off cdf messages

for i = 0, n_elements(cdffiles)-1 do begin
  vars = ' '
  buf = read_mycdf(vars,cdffiles(i),/all)

  printf, lun, '        '
  printf, lun,'Processing dataset ',cdffiles(i)

  if (n_tags(buf) ge 1) then begin
    for j = 0, n_tags(buf) - 1 do begin
	atags = tag_names(buf.(j))
	index = tagindex('VARNAME',atags)
	if (index ge 0) then varname = buf.(j).(index)
	index = tagindex('DISPLAY_TYPE',atags)

	;initialize variables
	validmin = 0
	validmax = 0
	scalemin = 0
	scalemin = 0

	if (index ge 0) then begin ;display_type exists
	  display_type = buf.(j).(index)
	  index = tagindex('VALIDMIN',atags)
	  if (index ge 0) then validmin = buf.(j).(index) else validmin = 'N_D'
	  index = tagindex('VALIDMAX',atags)
	  if (index ge 0) then validmax = buf.(j).(index) else validmax = 'N_D'
	  index = tagindex('SCALEMIN',atags)
	  if (index ge 0) then scalemin = buf.(j).(index) else scalemin = 'N_D'
	  index = tagindex('SCALEMAX',atags)
	  if (index ge 0) then scalemax = buf.(j).(index) else scalemin = 'N_D'

	  ;check for the cases where we have additional syntax, e.g.
	  ;spectrogram>x=epoch,y=flux,z=energy
	  a = break_mystring(display_type, delimiter='>')
	  asize = size(a)
	  if (asize(1) eq 2) then begin
	    printf, lun, 'display_type being reset to ',a(0)
	    display_type = a(0)
	  endif

	  if (strupcase(display_type) eq plottype) then begin
	    printf, lun, '        '
  	    printf, lun, 'Varname = ',varname, ' d_t = ',display_type,' vmin = ',validmin, ' vmax = ',validmax, ' smin = ',scalemin, ' smax = ',scalemax 
	    if (validmin ne scalemin) then printf, lun, 'vmin and smin not equal'
	    if (validmax ne scalemax) then printf, lun, 'vmax and smax not equal'

	    ;now check the depend 1 for this variable
	    index = tagindex('DEPEND_1',atags)
	    if (index ge 0) then depend_1 = buf.(j).(index)
	    if (depend_1 ne ' ') then begin
	      comm = execute('depend_struct = buf.'+depend_1)
	      vtags = tag_names(depend_struct)
	      index = tagindex('VALIDMIN',vtags)
	      if (index ge 0) then validmin = depend_struct.(index) else validmin = 'N_D'
	      index = tagindex('VALIDMAX',vtags)
	      if (index ge 0) then validmax = depend_struct.(index) else validmax = 'N_D'
	      index = tagindex('SCALEMIN',vtags)
	      if (index ge 0) then scalemin = depend_struct.(index) else scalemin = 'N_D'
	      index = tagindex('SCALEMAX',vtags)
	      if (index ge 0) then scalemax = depend_struct.(index) else scalemin = 'N_D'
	      printf, lun, '        '
  	      printf, lun, 'Depend 1 Varname = ',depend_1,' vmin = ',validmin, ' vmax = ',validmax, ' smin = ',scalemin, ' smax = ',scalemax 
	      if (validmin ne scalemin) then printf, lun, 'vmin and smin not equal'
	      if (validmax ne scalemax) then printf, lun, 'vmax and smax not equal'

	    endif ; if depend_1 is defined
	    
	  endif ; if display_type matches the one we're looking for

	endif ; if display_type attribute is set

    endfor ;the list of variables
  endif
endfor ; the list of cdf

printf, lun, 'End of processing. '
free_lun, lun
!quiet = 0 ;turn on cdf messages

end