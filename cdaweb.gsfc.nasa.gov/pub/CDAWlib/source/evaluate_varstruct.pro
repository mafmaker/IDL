;$Author: johnson $
;$Date: 2001/05/10 18:48:45 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/evaluate_varstruct.pro,v 1.40 2001/05/10 18:48:45 johnson Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.40 $
; Purpose: called from plotmaster, given a variable structure it
; returns the plotting information: plot type, number of panels,
; width, height, beginning and end time and title of the window/gif.
;
;
FUNCTION evaluate_varstruct,a

; Verify that the input variable is a structure
b = size(a)
if (b(n_elements(b)-2) ne 8) then begin
  print,'ERROR=Input parameter is not a valid structure.' & return,-1
endif

; Initialize the structure to be returned by this routine
atags = tag_names(a) ; get names of all attributes for structure
timing_data = 0L & plottable_data = 0L ; initialize flags
pstruct = {vname:'',ptype:0L,npanels:0L,iwidth:0L,iheight:0L,$
           btime:DOUBLE(0.0),etime:DOUBLE(0.0),title:'',source:''}
allfill = 0; FALSE

; Retrieve the name of the variable from structure or structure tag
b = tagindex('VARNAME',atags)
if (b(0) ne -1) then pstruct.vname = a.VARNAME

; RTB 9/96 Retrieve the Data set name from the Logical source or 
;          the Logical file id 
b = tagindex('LOGICAL_SOURCE',atags)
b0 = tagindex('Logical_source',atags)
b1 = tagindex('LOGICAL_FILE_ID',atags)
b2 = tagindex('Logical_file_id',atags)
if (b(0) ne -1) then pstruct.source = strupcase(a.LOGICAL_SOURCE) 
if (b1(0) ne -1) then pstruct.source = strupcase(strmid(a.LOGICAL_FILE_ID,0,9)) 
if (b2(0) ne -1) then  pstruct.source = strupcase(strmid(a.Logical_file_id,0,9))
if (b0(0) ne -1) then pstruct.source = strupcase(a.Logical_source) 

; Determine the cdf type of the data for min/max time determination
b = tagindex('CDFTYPE',atags)
if (b(0) ne -1) then begin 
  if (a.CDFTYPE eq 'CDF_EPOCH') then timing_data = 1 ; set flag
endif

; Only variables with the attribute 'VAR_TYPE' equal to data are plottable
b = tagindex('VAR_TYPE',atags)
if (b(0) ne -1) then begin
  if (strupcase(a.VAR_TYPE) eq 'DATA') then plottable_data = 1 ; set flag
endif

; Retrieve the data and get its dimensionality.  If the data is timetag
; data then get its min and max values.
if ((timing_data eq 1)OR(plottable_data eq 1)) then begin
  b = tagindex('DAT',atags)
  if (b(0) ne -1) then begin
    d = a.DAT & dsize=size(d)
    if (timing_data) then begin
      agood = where((a.DAT gt 0.0), acnt) ;TJK 5/13/99 add check for epoch values of 0.0
      if (acnt gt 0) then begin 
	c = min(a.DAT(agood)) & pstruct.btime = c
        c = max(a.DAT) & pstruct.etime = c
      endif
    endif
  endif else begin
    b = tagindex('HANDLE',atags)
    if (b(0) ne -1) then begin
      handle_value,a.HANDLE,d & dsize=size(d)
      if (timing_data) then begin
        agood = where((d gt 0.0), acnt) ;TJK 5/13/99 add check for epoch values of 0.0
        if (acnt gt 0) then begin 
          c = min(d(agood)) & pstruct.btime = c
          c = max(d) & pstruct.etime = c
	endif
      endif
    endif else begin
      print,'ERROR=No DAT or HANDLE field in structure' & return,-1
    endelse
  endelse

  b = tagindex('FILLVAL',atags)
  if (b(0) ne -1) then begin
    fill = where(d ne a.FILLVAL, fcnt)
    if (fcnt eq 0) then allfill = 1 ;TRUE
  endif

endif

; If data is not plottable, then no need to proceed.
if (plottable_data eq 0) then return,pstruct

; Attempt to determine the plot type based on the display type attribute
b = tagindex('DISPLAY_TYPE',atags)
if (b(0) ne -1) then begin ; attribute found
  c = break_mystring(a.(b(0)),delimiter='>')

  case strupcase(c(0)) of
  'TIME_SERIES': begin
                 pstruct.ptype = 1
;TJK changed this logic to deal w/ the fact that we'd added "keywords" to the
;time_series display_type syntax, e.g. "scatter" and "noauto" which are 
;preceeded by ">". This fact was throwing off the npanels setting... 5/14/2001
		 pstruct.npanels = 0
                 if (n_elements(c) eq 2) then begin ; check for element list
                   dn = break_mystring(c(1),delimiter=',')
;TJK		   if (dn(0) ne ' ') then pstruct.npanels = n_elements(dn)
		 endif

                 if (pstruct.npanels eq 0) then begin ; determine number of panels dimensionaly
                   if (dsize(0) eq 0) then pstruct.npanels = 1 ; only 1 point. RCJ 02/2001
                   if (dsize(0) eq 1) then pstruct.npanels = 1
                   if (dsize(0) eq 2) then pstruct.npanels = dsize(1)
                   if (dsize(0) ge 3) then pstruct.ptype = 0 ; reset
                 endif

		   ;need to check whether there's any good data in range
		   b = tagindex('VALIDMIN',atags)
		   if (b(0) ne -1) then begin
		     npanels = pstruct.npanels-1
		     for nel=0, npanels do begin
			if (dsize(0) le 1) then begin ;scalar
			  vmin = where((d ge a.VALIDMIN and d le a.VALIDMAX), count)
			  if (count lt 1) then pstruct.npanels = 0 ;no good values to plot
			endif else begin ;dim sizes greater than 1
			  vsize = size(a.VALIDMIN)
			  ;in case the number of validmin/max values doesn't
			  ;match the size of the data, then just use the first min/max
			  if (vsize(0) eq 0) then begin
				idx = 0
			  endif else if (vsize(1) ne dsize(1)) then begin
				idx = 0 
			  endif else idx = nel

			  vmin = where((d(nel,*) ge a.VALIDMIN(idx) and d(nel,*) le a.VALIDMAX(idx)), count)
			  if (count lt 1) then begin
			    pstruct.npanels = pstruct.npanels-1 ;this dimension not good.
			    print, 'no good values'
			  endif
			endelse
		     endfor
		   endif ;validmin/max exists

                 end
  'SPECTROGRAM': begin
                 pstruct.ptype = 2
                 ; Number of panels may be determined either dimensionaly
                 ; or based on other information in display_type if present.
                 dimension_based = 0 ; initialize flag
                 if (n_elements(c) eq 1) then dimension_based = 1
                 if (n_elements(c) eq 2) then begin
                   if (c(1) eq '') then dimension_based = 1
                 endif
                 if (dimension_based eq 0) then begin ; process display_type
                   dn = strupcase(c(1)) & i=0 & n=0
                   while (i ne -1) do begin
                     i=strpos(dn,'Z=',i)
                     if (i ne -1) then begin & n=n+1 & i=i+1 & endif
                   endwhile
                   if (n gt 0) then pstruct.npanels = n $
                   else dimension_based = 1 ; no useful info in display_type
                 endif
                 if (dimension_based eq 1) then begin
;TJK not right     if (dsize(1) eq 2) then pstruct.npanels = 1 $
                   if (dsize(0) eq 2) then pstruct.npanels = 1 $
                   else pstruct.ptype = 0 ; not plottable as spectrogram!
                 endif
                 end
  'TOPSIDE_IONOGRAM': begin
                       pstruct.ptype = 2 & pstruct.npanels = 1
                      end
  'BOTTOMSIDE_IONOGRAM': begin
                          pstruct.ptype = 2 & pstruct.npanels = 1
                         end
  'RADAR_VECTOR': begin
                 pstruct.ptype = 3
                 end
  'IMAGE'      : begin
                 pstruct.ptype = 4
                 ; must determine the number of images present
                 if (dsize(0) eq 2) then pstruct.npanels = 1 ; $ RTB 12/98
; images should not need more than 1 panel
; RTB 12/98                 else pstruct.npanels = dsize(dsize(0))
                 ; need image size for window/gif sizing
                 pstruct.iwidth  = dsize(1)
                 pstruct.iheight = dsize(2)
                 end
  'ORBIT'      : begin
                 pstruct.ptype = 5
                 end
  'MAPPED'     : begin
                 pstruct.ptype = 6
                 end
  'STACK_PLOT' : begin
                 pstruct.ptype = 7 & pstruct.npanels = 1
                 end
  'MAP_IMAGE'  : begin
                 pstruct.ptype = 8 
                 ; must determine the number of images present
                  if (dsize(0) eq 2) then pstruct.npanels = 1 ; $
; images should not need more than 1 panel
; RTB 12/98       else pstruct.npanels = dsize(dsize(0))
                  ; need image size for window/gif sizing
                  pstruct.iwidth  = dsize(1)
                  pstruct.iheight = dsize(2)
                 end
  'PLASMAGRAM' : begin
                 pstruct.ptype = 9
                 ; must determine the number of images present
                  if (dsize(0) eq 2) then pstruct.npanels = 1 $
                  else pstruct.npanels = dsize(dsize(0))
                  ; need image size for window/gif sizing
                  pstruct.iwidth  = dsize(1)
                  pstruct.iheight = dsize(2)
                 end
  'MOVIE'      : begin
                 pstruct.ptype = 10
                 ; must determine the number of images present
                 if (dsize(0) eq 2) then pstruct.npanels = 1 ; $
; images should not need more than 1 panel
; RTB 12/98     else pstruct.npanels = dsize(dsize(0))
                 ; need image size for window/gif sizing
                 pstruct.iwidth  = dsize(1)
                 pstruct.iheight = dsize(2)
                 end
  'MAP_MOVIE'   : begin
                 pstruct.ptype = 11
                 ; must determine the number of images present
                 if (dsize(0) eq 2) then pstruct.npanels = 1 ; $
; images should not need more than 1 panel
; RTB 12/98      else pstruct.npanels = dsize(dsize(0))
                 ; need image size for window/gif sizing
                 pstruct.iwidth  = dsize(1)
                 pstruct.iheight = dsize(2)
                 end
  'TIME_TEXT'   : begin
  		 pstruct.ptype=12
  		 if (a.LABLAXIS ne '') then $
  		   ; a 'panel' is one line of labels
  		   pstruct.npanels = 1 $
  		 else  pstruct.npanels = n_elements(a.LABL_PTR_1) 
    		 end                 
  'FLUX_IMAGE'  : begin
                 pstruct.ptype = 13
                 ; must determine the number of images present
                 if (dsize(0) eq 2) then pstruct.npanels = 1 ; $ RTB 12/98
; images should not need more than 1 panel
; RTB 12/98                 else pstruct.npanels = dsize(dsize(0))
                 ; need image size for window/gif sizing
                 pstruct.iwidth  = dsize(1)
                 pstruct.iheight = dsize(2)
                 end
  'FLUX_MOVIE'      : begin
                 pstruct.ptype = 14
                 ; must determine the number of images present
                 if (dsize(0) eq 2) then pstruct.npanels = 1 ; $
; images should not need more than 1 panel
; RTB 12/98     else pstruct.npanels = dsize(dsize(0))
                 ; need image size for window/gif sizing
                 pstruct.iwidth  = dsize(1)
                 pstruct.iheight = dsize(2)
                 end
  else         : begin
                 pstruct.ptype = 0 ; unknown plot type
                 ; print,'WARNING=Unknown value for DISPLAY_TYPE attribute'
                 end
  endcase
endif

; If no plot type has yet been determined, then attempt to determine the
; plot type according to the dimensionality and size of the data.
if (pstruct.ptype eq 0) then begin

  case dsize(0) of
    0  : begin  ; only 1 point. Same case as if dsize(0)=1. RCJ 02/2001
         pstruct.npanels = 1 
         pstruct.ptype = 1
	 b = tagindex('VALIDMIN',atags)
	 if (b(0) ne -1) then begin
           vmin = where((d ge a.VALIDMIN and d le a.VALIDMAX), count)
	   if (count lt 1) then pstruct.npanels = 0 ;no good values to plot
         endif ;validmin/max exists
         end
                  
    1  : begin ; single panel time series
         pstruct.ptype = 1 & pstruct.npanels = 1
	 ;TJK - 1/29/99 - need to check whether there's any good data in range
	 b = tagindex('VALIDMIN',atags)
	 if (b(0) ne -1) then begin
           vmin = where((d ge a.VALIDMIN and d le a.VALIDMAX), count)
	   if (count lt 1) then pstruct.npanels = 0 ;no good values to plot
         endif ;validmin/max exists
         end
    2  : begin ; could be multi panel time series or single panel spectrogram
               ; or orbit plot
         if (dsize(1) le 3) then begin
           source_key=strmid(pstruct.source,3,6)
           if (source_key eq 'OR_DEF') OR (source_key eq 'OR_PRE') then begin
              var_key=strmid(pstruct.vname,3,4)
              crd_key=strmid(pstruct.vname,0,3)
              if(var_key eq '_POS') then begin
                 if(crd_key eq 'GSM') or (crd_key eq 'GM_') or (crd_key eq 'SM_') then begin
                    ;           pstruct.ptype = 1 & pstruct.npanels = dsize(1) 
                    pstruct.ptype = 5  ; This may change back sometime
                 endif else pstruct.ptype = 5 
              endif else begin
                 pstruct.ptype = 1 & pstruct.npanels = dsize(1)
              endelse 
           endif else begin
              pstruct.ptype = 1 & pstruct.npanels = dsize(1)  
           endelse
           ;TJK added 1/29/99
           ;need to check whether there's any good data in range
	   if (pstruct.ptype eq 1) then begin
	      b = tagindex('VALIDMIN',atags)
	      if (b(0) ne -1) then begin
                 npanels = pstruct.npanels-1
	         for nel=0, npanels do begin
	            if (dsize(0) eq 0) then begin ;scalar
		       vmin = where((d ge a.VALIDMIN and d le a.VALIDMAX), count)
		       if (count lt 1) then pstruct.npanels = 0 ;no good values to plot
		    endif else begin ;dim sizes greater than 1
		       vsize = size(a.VALIDMIN)
		       ;in case the number of validmin/max values doesn't
		       ;match the size of the data, then just use the first min/max
	               if (vsize(0) eq 0) then begin
		          idx = 0
		       endif else if (vsize(1) ne dsize(1)) then begin
		          idx = 0 
		       endif else idx = nel

		       vmin = where((d(nel,*) ge a.VALIDMIN(idx) and d(nel,*) le a.VALIDMAX(idx)), count)
		       if (count lt 1) then begin
		          print, 'no good vals' & pstruct.npanels = pstruct.npanels-1 ;this dimension not good.
		       endif
		    endelse
	         endfor
	      endif ;validmin/max exists
 	   endif ; for time series plots
         endif else begin  ; dsize(1) gt 3
           ;
           ; RCJ 05/01 added this check for validmin/max:
           ;
           ;need to check whether there's any good data in range
	   b = tagindex('VALIDMIN',atags)
	   bb = tagindex('VALIDMAX',atags)
	   if (b(0) ne -1) and (bb(0) ne -1) then $
              vmin = where((d ge a.VALIDMIN) and (d le a.VALIDMAX)) 
           if (n_elements(vmin) ne 0) and (vmin(0) eq -1) then begin
	      print, 'no good vals' & pstruct.npanels = 0
	   endif else begin    
              ;
              b = tagindex('DEPEND_1',atags)
              if (b(0) ne -1)AND(a.DEPEND_1 ne '') then begin
                 pstruct.ptype = 2 & pstruct.npanels = 1
              endif else begin ; do it as a time series
                 pstruct.ptype = 1 & pstruct.npanels = dsize(1)
              endelse
           endelse   
         endelse
         end
    3  : begin ; image
         pstruct.ptype = 4
         ; must determine the number of images present
         if (dsize(0) eq 2) then pstruct.npanels = 1 $
         else pstruct.npanels = dsize(dsize(0))
         ; need image size for window/gif sizing
         pstruct.iwidth  = dsize(1)
         pstruct.iheight = dsize(2)
         end
  else : d=0 ; unplottable
  endcase
endif 

d = 0 ;deallocate the data array - TJK

; Verify that required DEPEND attributes are present so that automatic
; plotting can be done.  Autoplotting is impossible without the DEPEND's.
d0 = 0L & d1 = 0L & d2 = 0L ; initialize
b = tagindex('DEPEND_0',atags)
if (b(0) ne -1) then if (a.DEPEND_0 ne '') then d0=1L
b = tagindex('DEPEND_1',atags)
if (b(0) ne -1) then if (a.DEPEND_1 ne '') then d1=1L
b = tagindex('DEPEND_2',atags)
if (b(0) ne -1) then if (a.DEPEND_2 ne '') then d2=1L
case pstruct.ptype of ; check for missing depends
 1   : if (d0 eq 0) then pstruct.ptype = 0
 2   : if ((d0 eq 0)OR(d1 eq 0)) then pstruct.ptype = 0
 3   : if ((d0 eq 0)OR(d1 eq 0)OR(d2 eq 0)) then pstruct.ptype = 0
 4   : if ((d0 eq 0)OR(d1 eq 0)OR(d2 eq 0)) then pstruct.ptype = 0
 else: d=0 ; do nothing
endcase
if pstruct.ptype eq 0 then pstruct.npanels = 0

;check to see if the data for this variable is all fill, if so don't
;allocate any panels for it.  Added TJK 2/28/99
if (allfill eq 1) then begin
  pstruct.ptype = 0
  pstruct.npanels = 0
  print, 'setting .npanels and .ptype to zero - no good data'
endif

; Determine the title for a window or gif file using this variable
b = tagindex('SOURCE_NAME',atags)
if (b(0) ne -1) then begin
  n = break_mystring(a.SOURCE_NAME,delimiter='>')
  mytitle = n(0)
endif else mytitle = ''

b = tagindex('DESCRIPTOR',atags)
if (b(0) ne -1) then mytitle = mytitle + '  ' + a.DESCRIPTOR

b = tagindex('DATA_TYPE',atags)
if (b(0) ne -1) then mytitle = mytitle + '  ' + a.DATA_TYPE

pstruct.title = mytitle

return,pstruct
end












