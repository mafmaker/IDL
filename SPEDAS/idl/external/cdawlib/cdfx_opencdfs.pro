;-----------------------------------------------------------------------------

function cdfx_file_search, pathSpec

if !version.release ge '5.5' then $
  return, file_search(pathSpec)

return, findfile(pathSpec) ; for pre-5.5
end

;-----------------------------------------------------------------------------
; Returns true if either (A) the passed set of two strings are valid time
; specifications for 'read_myCDF', or (B) both strings are empty.

function cdfx_valid_time_range, tr

syntax = '[0-9]{4}(/[0-9]{2}){2} [0-9]{2}(:[0-9]{2}){2}'

return, (tr[0]+tr[1] eq '') or $
  (stregex(tr[0], syntax, /boolean) and stregex(tr[1], syntax, /boolean))
end

;-----------------------------------------------------------------------------
; Returns the named attribute of a given variable of a given CDF object.

function cdfx_read_attr, cdfid, varname, attname

;attname = strupcase(attname)

error_status = 0    ; initialize error flag
catch, error_status ; set up exception handler to handle missing name
if error_status ne 0 then $
  return, '' $
else $
  a = read_myattribute(varname, cdf_attnum(cdfid, attname), cdfid)

return, a.(0)
end

;-----------------------------------------------------------------------------
; Returns the minimum and maximum epoch values of the given CDF data files.

function cdfx_time_range_of_files, fpaths

rmin = 6.0e13 ; about 1900
rmax = 7.0e13 ; about 2200

for i = 0, n_elements(fpaths)-1 do begin
;TJK add check for master, don't look for time range in the masters
  if not stregex(fpaths[i], '.*_00000000_v[0-9]+[.]cdf$', /boolean, /fold) then begin
;    print, 'DEBUG, found a non-master -',fpaths[i]
    cdfid = cdf_open(fpaths[i])
    cdf_control, cdfid, set_zmode=2
    info = cdf_inquire(cdfid)

found = 0L ; initialize flag

    for varindex = 0, info.nzvars-1 do begin
      varname = (cdf_varinq(cdfid, varindex, /zvar)).name

;TJK 12/7/2006 - change this to look for range_epoch variable 1st
;since that's the only "good" epoch variable in the THEMIS cdfs
;if not found, then look for a regular epoch variable.
;    if stregex(varname, 'epoch.*|range_epoch', /bool, /fold) then begin
      if stregex(varname, 'range_epoch', /bool, /fold) then begin
        found = 1L
        epoch = read_myvariable(varname, cdfid, vary, dtype, recs)
        emin = epoch[0]
        emax = epoch[n_elements(epoch)-1]
;        print, emin,emax
;TJK 4/30/2007 - only replace rmin/max w/ different epoch values (from
;                the same cdf) if the new min/max are valid
;TJK 5/15/2008 - change to ge instead of gt, since we have cdfs w/
;                just one epoch and we want to show the cdfs time, vs.
;                some strange start year like 1901...
;
;        if ((i eq 0) and (emax gt emin)) then begin
        if ((i eq 0) and (emax ge emin)) then begin
          rmin = emin
          rmax = emax
        endif else begin
            rmin = min([rmin, emin])
            rmax = max([rmax, emax])
        endelse

       endif    
     endfor
  
    if (not found) then begin ;if range_epoch variable not found, look for
                          ;regular epochs

      for varindex = 0, info.nzvars-1 do begin
        varinfo = cdf_varinq(cdfid, varindex, /zvar)

        varname = varinfo.name
        vartype = varinfo.datatype
        varys = varinfo.recvar
;TJK 12/15/2006 - determine that the epoch variable we want to use has
;                 type cdf_epoch AND is record varying (THEMIS has
;                 several epochs, so you can't just take the 1st one
;                 that's cdf_epoch
        if (stregex(vartype, 'cdf_epoch', /bool, /fold) and (varys eq 'VARY')) then begin

;print, 'DEBUG, found  regular epoch, varname = ',varname

          epoch = read_myvariable(varname, cdfid, vary, dtype, recs)
          emin = epoch[0]
          emax = epoch[n_elements(epoch)-1]
;TJK 4/30/2007 - only replace rmin/max w/ different epoch values (from
;                the same cdf) if the new min/max are valid
;TJK 5/15/2008 - change "gt" to "ge" to handle the case where we have
;                one cdf w/ one record - we want the times shown on the
;interface to at least be from the cdf, vs. a year like 1901.
          if ((i eq 0) and (emax ge emin)) then begin
            rmin = emin
            rmax = emax
          endif else begin
;TJK 2/15/2008 add code to compare epoch vs. epoch16 values (can't do w/
;min/max functions).  THEMIS has datasets w/ both epoch and epoch16s.
            if (!version.release ge '6.2') then begin
                if (size(emin,/tname) eq 'DCOMPLEX')then begin
                    if (cdf_epoch_compare(rmin, emin) ge 0) then rmin = emin
                    if (cdf_epoch_compare(emax, rmax) ge 0) then rmax = emax
                endif else begin
                  rmin = min([rmin, emin])
                  rmax = max([rmax, emax])
                endelse
            endif else begin
                rmin = min([rmin, emin])
                rmax = max([rmax, emax])
            endelse
          endelse

        endif    
      endfor
    endif 
    found = 0L; reset flag for check in next CDF.


    cdf_close, cdfid
  endif
endfor

return, [rmin, rmax]
end

;-----------------------------------------------------------------------------
; Separates a list of CDF file paths into ordinary data files and
; master files.  Also supplements the master file set with new ones
; generated from the data file names, looking for masters in both the
; current directory and the user-specified Masters directory.

pro cdfx_separate_cdfs, fpaths, cpaths=cpaths, mpaths=mpaths

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

cpaths = ['']
mpaths = ['']

for i = 0, n_elements(fpaths)-1 do begin
  fpath = fpaths[i]

  if not stregex(fpath, '.*_00000000_v[0-9]+[.]cdf$', /boolean, /fold) then begin
    print,'This does not check for .CDF, only .cdf'

    ; then got data file, not a master
    cpaths = [cpaths, fpath] ; add it now

    ; Now look for data file's master CDF.

    ;dname = stregex(fpath, '/.*/', /extract)
    ;fname = stregex(fpath, '[^/]+$', /extract)
;    dname = stregex(fpath, '\\.*\\', /extract)
;    fname = stregex(fpath, '[^\\]+$', /extract)
;TJK 12/18/2006 - changed above to the following since above didn't
;                 work for directories containing '_' or various OS's

    if (strupcase(!version.os_family) eq 'UNIX' or $
       strupcase(!version.os_family) eq 'MACOS') then $
       delim = strpos(fpath, '/',/reverse_search) else $
       delim = strpos(fpath, '\',/reverse_search)

    dname = strmid(fpath,0,delim+1)
    fname = strmid(fpath,delim+1, strlen(fpath))

;TJK 12/18/2006 - change logic since it won't work w/ dataset
;                 names containing more than the usual fields
    split = strsplit(fname, '_', /extract)
    split[n_elements(split)-2] = '00000000'
    split[n_elements(split)-1] = 'v*.cdf'
    mname = strjoin(split, '_', /single) ; master CDF file name

    fpath = cdfx_file_search("{./," + dname + "," + $
      CDFxprefs.masters_path + "/}" + mname) ; searches in three places
    if (size(fpath))[0] ne 0 then $; there is something to add
      mpaths = [mpaths, fpath[0]]
  endif

endfor

if n_elements(cpaths) gt 1 then $
  cpaths = cpaths[1:*]

if n_elements(mpaths) gt 1 then $
  mpaths = cdfx_uniq_sort(mpaths[1:*])

;print, 'cpaths = ',cpaths
;print, 'masters = ',mpaths
;stop;TJK
end

;-----------------------------------------------------------------------------
; Returns whether the given set of CDF data files are structurally
; compatible with each other.  Compatibility is defined by the routine
; Compare_mycdfs.

function cdfx_files_compatible, cpaths

n = n_elements(cpaths)
if n lt 2 then return, 1

id0 = cdf_open(cpaths[0])
cdf_control, id0, set_zmode=2

for i = 1, n-1 do begin
  id = cdf_open(cpaths[i])
  cdf_control, id, set_zmode=2
  match = compare_mycdfs(id, id0)
  cdf_close, id

  if not match then begin
    cdf_close, id0
    return, 0
  endif  
endfor

cdf_close, id0
return, 1
end

;-----------------------------------------------------------------------------

pro cdfx_refine_open_event, event

widget_control, event.top, get_uvalue=info
widget_control, (*info).list, get_value=bvals

case event.id of
  (*info).bSelectAll:	begin
	bvals[*] = 1
	widget_control, (*info).list, set_value=bvals
	end

  (*info).bUnselectAll:	begin
	bvals[*] = 0
	widget_control, (*info).list, set_value=bvals
	end

  (*info).bCancel:	begin
	widget_control, event.top, /destroy
	end

  (*info).bProceed:	begin
        widget_control, (*info).tstart, get_value=tstart
        widget_control, (*info).tstop,  get_value=tstop
	trange = [tstart[0], tstop[0]]
	w = where(bvals eq 1, wc)

	if not cdfx_valid_time_range(trange) then $
	  resp = dialog_message(/error, "Invalid syntax in time fields!") $
	else if wc lt 1 then $
	  resp = dialog_message(/error, 'No variables selected!') $
	else begin
	  (*info).selection = bvals
	  (*info).trange = trange
	  widget_control, event.top, /destroy
	endelse

	end

  else : ; do nothing
endcase

end

;-----------------------------------------------------------------------------

function cdfx_opencdfs,gleader=gleader

common cdfxcom, CDFxwindows, CDFxprefs ; include cdfx common

; Get a set of CDF files from user.
;paths = dialog_pickfile(title='Choose CDF(s)',/multiple) ;/fix_filter, filter="*.cdf"
paths = dialog_pickfile(title='Choose CDF(s)',/multiple, $
          path=CDFxprefs.cdf_path,get_path=thispath)
CDFxprefs.cdf_path=thispath

if paths[0] eq '' then $
  return, -1
if !version.release ge '6' then $
  if file_test(paths[0], /directory) then $
    return, -1

cdfx_separate_cdfs, paths, cpaths=cpaths, mpaths=mpaths

if n_elements(cpaths) lt 1 then begin
  resp = dialog_message(/error, 'No CDF data files selected!')
  return, -1
endif

if not cdfx_files_compatible(cpaths) then begin
  resp = dialog_message(/error, $
    'The selected data files are not structurally compatible!')
  return, -1
endif

cdfid  = cdf_open(cpaths[0])
mcdfid = -1
vnames = get_allvarnames(cdfid=cdfid)
;print, vnames ;!!
;cinfo  = cdf_inquire(cdfid) ; inquire about the cdf

if mpaths[0] ne '' then begin
  mcdfid = cdf_open(mpaths[0])
  vnames = [vnames, get_allvarnames(cdfid=mcdfid)] ; add master vars
endif else $
  resp = dialog_message(/info, 'No CDF master files found.')

vnames = cdfx_uniq_sort(vnames)
new_vnames = ['']
vlist = ['']

;nvars  = n_elements(vnames)
;vlist  = strarr(nvars)

; Gather display information for the variables.
!quiet = 1
for i=0, n_elements(vnames)-1 do begin ; construct the list of variables name
  vname = vnames[i]

  vtype = cdfx_read_attr(cdfid, vname, 'VAR_TYPE')
  if vtype eq ''  and  mcdfid ne -1 then $
    vtype = cdfx_read_attr(mcdfid, vname, 'VAR_TYPE')

  fname = cdfx_read_attr(cdfid, vname, 'FIELDNAM')
  if fname eq ''  and  mcdfid ne -1 then $
    fname = cdfx_read_attr(mcdfid, vname, 'FIELDNAM') + ' (M)'

  if vtype eq 'data'  or  vtype eq 'support_data' then begin
    vlist = [vlist, string(format='(a25,a15,a50)', vname, vtype, fname)]
    new_vnames = [new_vnames, vname]
  endif
endfor
!quiet = 0
;TJK record the number of selectable variables for comparison down below
total_vnames = n_elements(new_vnames)-1 ; -1 because the 1st elem. is blank

cdf_close, cdfid
if mcdfid ne -1 then $
  cdf_close, mcdfid

if n_elements(vlist) lt 2 then begin
  resp = dialog_message(/error, $
    "No data or support variables were found in the chosen CDF file(s).  The files are probably not ISTP-compliant.")
  return, -1
endif

vlist = vlist[1:*]
vnames = new_vnames[1:*]
nvars = n_elements(vlist)

trange = cdfx_time_range_of_files(cpaths)
tstart = cdfx_time_string_of_epoch(trange[0])
tstop  = cdfx_time_string_of_epoch(trange[1])

;base	= widget_base(/column, title='Select Variables and Time Interval', /frame)
base	= widget_base(/column, title='Select Variables and Time Interval', /frame,$
                       group_leader=gleader,/modal)
base1	= widget_base(base, /column, /frame)
base3	= widget_base(base, /row)
base4	= widget_base(base3, /column, /frame)
base2	= widget_base(base3, /column, /frame)

w	= widget_label(base4, value='Time Interval')
w	= widget_label(base4, value='(Format: YYYY/MM/DD hh:mm:ss)')
bstart	= widget_base(base4, /row)
lstart	= widget_label(bstart, value='Start time:')
bstop	= widget_base(base4, /row)
lstop	= widget_label(bstop, value='Stop time: ')

info = ptr_new({$
  selection:lonarr(nvars), $
  trange:["",""], $
  list:cw_bgroup(base1, vlist, /nonexclusive, scroll=(nvars>20), $
    set_value = lonarr(nvars), $
    label_top = strtrim(string(nvars), 2) + ' Variables', $
    y_scroll = (20 * !d.y_ch_size), $
    x_scroll = (95 * !d.x_ch_size)), $
  tStart:	widget_text(bstart, value=tstart, xsize=20, /editable), $
  tStop:	widget_text(bstop , value=tstop , xsize=20, /editable), $
  bProceed:	widget_button(base2, value='Proceed'), $
  bSelectAll:	widget_button(base2, value='Select All'), $
  bUnselectAll:	widget_button(base2, value='Unselect All'), $
  bCancel:	widget_button(base2, value='Cancel') })

widget_control, base, /realize, set_uvalue=info
xmanager, 'cdfx_refine_open', base;, /modal  ;modal is obsolete in xmanager

w = where((*info).selection eq 1, wc)
a = -1
if wc gt 0 then begin
  tstart = ((*info).trange)[0]
  tstop  = ((*info).trange)[1]
  widget_control, /hourglass

  if mpaths[0] eq '' then $
    allpaths = cpaths $
  else $
    allpaths = [mpaths, cpaths]

;TJK 3/28/2007 - try to improve performance by using the all=2 keyword
;                to read_myCDF when we can, otherwise the checking and
;                reading of metadata and extra variables is very
;                costly, especially in cases like the L1 THEMIS files.
;IF all variables selected, try just reading the data variables and 
;those required (depends, etc.) vs. all support/metadata variables
;TJK 7/14/2008 - compare total_vnames w/ vnames(w) not vnames,
;                otherwise we get all the variables all the time.

  if tstart eq "" or tstop eq "" then begin
    if (total_vnames eq n_elements(vnames(w))) then $
      a = read_mycdf(' ', allpaths, /nodatastruct, ALL=2) else $
      a = read_mycdf(vnames[w], allpaths, /nodatastruct)
  endif else begin
    if (total_vnames eq n_elements(vnames(w)))then $
      a = read_mycdf(' ', allpaths, /nodatastruct, ALL=2, $
        tstart=tstart, tstop=tstop) else $
      a = read_mycdf(vnames[w], allpaths, /nodatastruct, $
        tstart=tstart, tstop=tstop)
  endelse
endif

ptr_free, info
return, a
end

;-----------------------------------------------------------------------------
