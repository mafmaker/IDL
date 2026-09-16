;$Author: johnson $
;$Date: 2001/06/06 21:22:12 $
;$Header: /home/rumba/cdaweb/dev/control/RCS/read_myCDF.pro,v 1.107 2001/06/06 21:22:12 johnson Exp kovalick $
;$Locker: kovalick $
;$Revision: 1.107 $
;+------------------------------------------------------------------------
; This package of IDL functions facilitates reading data and metadata from
; Common Data Format (CDF) files.  While CDF provides all the benefits
; of a portable, self-documenting scientific data format, reading them is
; not always a simple matter.  To make it simple, I have created this IDL
; package so that all of the data and metadata from multiple variables can 
; be read from multiple CDF files ... in one single, simple command.  The 
; function is called 'READ_MYCDF' and it returns an anonymous structure of
; the form:
;
;       structure_name.variable_name.attribute_name.attribute_value
;
; From this structure, all data and metadata for the requested variables
; is easily accessed.
;
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; 
; NOTES:
;
; Three additional 'attributes' will be included in the sub-structure for 
; each variable.  The first is the 'VARNAME' field.  Because IDL structure
; tags are always uppercase, and because CDF variable names are case sen-
; sitive, a case sensitive copy of the variable name is created.  The second
; 'attribute' to be added is the 'CDFTYPE' field.  This field will hold a
; string value holding the cdf data type.  The last 'attribute' to be
; artificially added will be either the 'DAT' field or, if the keyword
; NODATASTRUCT is set, the 'HANDLE' field.  The 'DAT' field will contain
; the actual data values read from the CDF's for the variable.  The 'HANDLE'
; field will hold a handle_id where the data will reside.
;
; This package will look for and utilize certain special attributes required
; by the International Solar Terrestrial Physics Key Parameters Generation
; Software Standards and Guidelines.  The existance of these attributes is
; not required for the operation of this software, but will enhance its
; usefullness, primarily by reading variables that will be needed for proper
; utilization of the data, even though you may not have asked for them 
; explicitly.
;
; This package was tested under IDL version 4.0.1b.  This package was tested
; on CDF's up to version 2.5 and on both r-variables and z-variables.
;
; CDF variables defined as unsigned integers are, unfortunately, currently
; returned by the IDL CDF_VARGET procedure as signed integers.  This can
; cause sign flips.  This software detects and corrects for this defect for
; data values.  However, it cannot detect and correct for this defect for
; attribute values because the IDL procedure CDF_ATTINQ does not return the
; CDF data type of the attribute.  These problems have been reported to
; RSI.
;
;
; Modifications: 
;	As of October 2, 2000, this software can run on all of the following
;	IDL versions, 5.1, 5.2 and 5.3 (testing for 5.4 will commence soon).
;	Some fairly major changes were necessary in order for read_myCDF
;	to work under 5.3.  IDL 5.3 enforces the variable naming rules for
;	structure tag names.  This change affects this s/w because we basically
;	had never checked our tag names, e.g. we used the CDF variable names
;	and label attribute values directly.  So in read_myCDF the general
;	concept to fixing this problem was to set up a table (which is shared
;	in a common block - not my favorite way to go, but definitely the 
;	easiest), where there are two tags, equiv and varname.  varname 
;	contains the real CDF variable name, equiv contains the "cleaned up,
;	IDL acceptable" variable name that can be used as a structure tag
;	name... TJK 04/02/2000
;
; 1996, NASA/Goddard Space Flight Center
; This software may be used, copied, or redistributed as long as it is not
; sold and this copyright notice is reproduced on each copy made.  This
; routine is provided as is without any express or implied warranties
; whatsoever.
;-------------------------------------------------------------------------
; NAME: BREAK_MYSTRING
; PURPOSE: 
;       Convert a string into a string array given a delimiting character 
; CALLING SEQUENCE:
;       out = break_mystring(instring)
; INPUTS:
;       instring = input text string
; KEYWORD PARAMETERS:
;       delimiter = character to parse by.  Default = ' '
; OUTPUTS:
;       out = string array
; AUTHOR:
;       Jason Mathews, NASA/GSFC/Code 633,  June, 1994
;       mathews@nssdc.gsfc.nasa.gov    (301)286-6879
; MODIFICATION HISTORY:
;-------------------------------------------------------------------------
FUNCTION break_mySTRING, s, DELIMITER=delimiter
; Validate the input parameters
s_size=size(s) & n_size=n_elements(s_size)
if (s_size(n_size - 2) ne 7) then begin
  print,'ERROR>Argument to break_mySTRING must be of type string'
  return,-1
endif
if s eq '' then return, [ '' ]
if n_elements(delimiter) eq 0 then delimiter = ''
; dissect the string
byte_delim = Byte( delimiter ) ; convert string to byte delimiter
result = Where( Byte(s) eq byte_delim(0), count ) ; count occurences
result = StrArr( count+1 ) & pos = -1
if (count gt 0) then begin
  for i=0, count-1 do begin
    oldpos = pos + 1
    pos = StrPos(s, delimiter, oldpos)
    result(i) = StrMid(s, oldpos, pos-oldpos)
  endfor
endif
pos = pos + 1
result(count) = StrMid( s, pos, StrLen(s) - pos )
return, result
end
;+-----------------------------------------------------------------------
; Search the tnames array for the instring, returning the index in tnames
; if it is present, or -1 if it is not.
;TJK this function is in a separate file called TAGindex.pro
;since its called from many different routines in this system.
;FUNCTION TAGindex, instring, tnames
;instring = STRUPCASE(instring) ; tagnames are always uppercase
;a = where(tnames eq instring,count)
;if count eq 0 then return, -1 $
;else return, a(0)
;end

;+------------------------------------------------------------------------
; NAME: AMI_ISTPPTR
; PURPOSE:
;       Return true(1) or false(0) depending on whether or not the
;       given attribute name qualifies as an ISTP pointer-class attribute.
; CALLING SEQUENCE:
;	out = amI_ISTPptr(attribute_name)
; INPUTS:
;	attribute_name = name of a CDF attribute as a string
; KEYWORD PARAMETERS:
; OUTPUTS:
;       True(1) or False(0)
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;-------------------------------------------------------------------------
FUNCTION amI_ISTPptr, aname
if (aname eq 'UNIT_PTR')        then return,1
if (aname eq 'FORM_PTR')        then return,1
if (aname eq 'DELTA_PLUS_VAR')  then return,1
if (aname eq 'DELTA_MINUS_VAR') then return,1
len = strlen(aname) & pos = strpos(aname,'LABL_PTR_')
if ((len gt 9)AND(pos eq 0)) then begin ; label pointer found
  ON_IOERROR,escape ; return false if non-digit found
  for j=0,(len-10) do begin ; check one character at a time
    r = strmid(aname,(9+j),1) & READS,r,v,FORMAT='(I1)'
  endfor
  return,1 ; remaining characters in label pointer are valid
endif
pos = strpos(aname,'OFFSET_')
if ((len gt 7)AND(pos eq 0)) then begin ; label pointer found
  ON_IOERROR,escape ; return false if non-digit found
  for j=0,(len-8) do begin ; check one character at a time
    r = strmid(aname,(7+j),1) & READS,r,v,FORMAT='(I1)'
  endfor
  return,1 ; remaining characters in offset pointer are valid
endif
escape: return,0
end

;+------------------------------------------------------------------------
; NAME: AMI_VAR
; PURPOSE:
;       Return true(1) or false(0) depending on whether or not the
;       given attribute name's value is assigned to a real CDF variable name.
; CALLING SEQUENCE:
;	out = amI_VAR(attribute_name)
; INPUTS:
;	attribute_name = name of a CDF attribute as a string
; KEYWORD PARAMETERS:
; OUTPUTS:
;       True(1) or False(0)
; AUTHOR:
;	Tami Kovalick	March 6, 2000
;
; MODIFICATION HISTORY:
;-------------------------------------------------------------------------
FUNCTION amI_VAR, aname
if (strpos(aname, 'DEPEND') eq 0) then return,1
if (strpos(aname, 'COMPONENT') eq 0) then return,1
return,0
end

;+------------------------------------------------------------------------
; NAME: PARSE_DISPLAY_TYPE
; PURPOSE: 
;	Parse and examine the input string.  It should be the value of the
;	CDF attribute 'DISPLAY_TYPE'.  Return an array of variable names
;       that it 'points' to.
; CALLING SEQUENCE:
;	out = parse_display_type(instring)
; INPUTS:
;       instring = string, value of a CDF attribute called 'DISPLAY_TYPE'
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = string array, names of other variables required for display
; NOTES: This routine expects to find 'DISPLAY_TYPE' values looking like:
;        PLOT_TYPE>x=vname,y=vname ...
;        PLOT_TYPE>y=vname,z=vname(*,1),z=vname(*,2) ...
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;TJK modified 01/27/98 to not parse orbit display type here - the items
;specified for the orbit plot type aren't additional variables.
;
;-------------------------------------------------------------------------
FUNCTION parse_DISPLAY_TYPE, instring
num_vnames = 0L & spos = 0L & i=0L ; initialize
a = break_mySTRING(instring,DELIMITER='>') ; break string into components
if n_elements(a) le 1 then return,-1 ; no '>' following plot type
if a(1) eq '' then return,-1 ; no info past '>' to parse
if strlowcase(a(0)) eq 'orbit' then return,-1 ; dont want to parse orbit.

lastn=n_elements(a)-1  ; RTB added 3/98
b = break_mystring(a(lastn),delimiter=',') ; Parse the string into substrings
for i=0,n_elements(b)-1 do begin ; examine each substring
   s = strpos(b(i),'=') & p = strpos(b(i),'(') ; find '=' and '(' signs
   if s ne -1 then begin ; probably a properly formated DISPLAY_TYPE vattr
      s = s + 1 ; point to first character past the '=' sign
      if p ne -1 then vname = strmid(b(i),s,(p-s)) $ ; extract vname
         else vname = strmid(b(i),s,(strlen(b(i))-s))   ; extract vname
      if num_vnames eq 0 then begin
         variable_names = vname & num_vnames = num_vnames + 1
      endif else begin
         index = where(variable_names eq vname,wc)
         if wc eq 0 then begin
            variable_names = [variable_names,vname] ; add to existing list
            num_vnames = num_vnames + 1 ; keep count of number of names
         endif
      endelse
   endif
endfor
if num_vnames eq 0 then return,-1 else return,variable_names
end

;Function correct_vnames(vnames)
;This function takes a list of variable names, checks to see if any of them
;are in the structure called "table" which has a mapping of the "real" variable names
;to those who've been "corrected" in order to run under IDL5.3.

Function correct_vnames, vnames
common global_table, table

if (n_elements(table) gt 0) then begin
   for i = 0, n_elements(table.equiv)-1 do begin
      c_index = where(vnames eq table.equiv(i), c_count)
      if (c_count ge 1) then vnames(c_index(0)) = table.varname(i)
   endfor
endif

return, vnames
end

;+------------------------------------------------------------------------
; NAME: follow_myDEPENDS
; PURPOSE: 
;	Search the metadata anonymous structure for ISTP 'DEPEND' attributes.
;       If and when found, add the variable name that it points to to the
;       vnames array if it is not already present, and increase the size
;       of the dhids and mhids arrays.
; CALLING SEQUENCE:
;       follow_myDEPENDS, metadata, vnames, dhids, mhids
; INPUTS:
;       metadata = anonymous structure holding attribute values
;       vnames   = string array of the names of variables already processed
;       vvarys   = string array of the record variance for each variable
;       dhids    = array of data handle id's
;       mhids    = array of metadata handle id's
; KEYWORD PARAMETERS:
; OUTPUTS:
;       dhids    = array of data handle id's
;       mhids    = array of metadata handle id's
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;-------------------------------------------------------------------------
PRO follow_myDEPENDS, metadata, vnames, vvarys, ctypes, dhids, mhids

tnames = tag_names(metadata)
for i=0,n_elements(tnames)-1 do begin
   ; Determine if the current tagname is a legal ISTP-style DISPLAY_TYPE vattr
   if (tnames(i) eq 'DISPLAY_TYPE') then begin
      dvnames = parse_DISPLAY_TYPE(metadata.(i)) & dvs = size(dvnames)
      if (dvs(n_elements(dvs)-2) eq 7) then begin ; variable names found
         for j=0,n_elements(dvnames)-1 do begin
	    dvnames(j) = correct_vnames(dvnames(j)) ;look for variable names that have
	    ;been corrected (no illegal characters)
	    ;replace them w/ their "real" names 
	    ;so that their associated data can be
	    ;retrieved from the cdf files.
            a = where(vnames eq dvnames(j),count) ; search vnames array so no duplicates.
            if ((dvnames(j) ne '')AND(count eq 0)) then begin
               ; add the display variable name all array parameters
               n = n_elements(vnames)
               newn = strarr(n+1) & newd = lonarr(n+1) & newm = lonarr(n+1)
               newv = strarr(n+1) & newr = lonarr(n+1) & newc = strarr(n+1)
               newn(0:(n-1)) = vnames(0:(n-1))
               newv(0:(n-1)) = vvarys(0:(n-1))
               newc(0:(n-1)) = ctypes(0:(n-1))
               newd(0:(n-1)) = dhids(0:(n-1))
               newm(0:(n-1)) = mhids(0:(n-1))
               newn(n)=dvnames(j) & newv(n)='' & newc(n)='' & newd(n)=0 & newm(n)=0
               vnames=newn & vvarys=newv & ctypes=newc & dhids=newd & mhids=newm
            endif
         endfor
      endif
   endif

   ; Determine if the current tagname is a legal ISTP-style depend attribute
   len = strlen(tnames(i)) & pos = strpos(tnames(i),'DEPEND_')
   if ((len gt 7)AND(pos eq 0)) then begin ; DEPEND found, check remainder
      ON_IOERROR, escape ; return false if non-digit found
      for j=0,(len-8) do begin ; check one character at a time
         r = strmid(tnames(i),(7+j),1) & READS,r,v,FORMAT='(I1)'
      endfor
      dvname = metadata.(i) ; depend attribute FOUND
      dvname = correct_vnames(dvname) ;look for variable names that have
      ;been corrected (no illegal characters)
      ;replace them w/ their "real" names 
      ;so that their associated data can be
      ;retrieved from the cdf files.

      a = where(vnames eq dvname,count) ;search vnames array to make sure
				      ;there are no duplicates
      if ((dvname ne '')AND(count eq 0)) then begin
         ; add the depend variable name to all array parameters
         n = n_elements(vnames)
         newn = strarr(n+1) & newd = lonarr(n+1) & newm = lonarr(n+1)
         newv = strarr(n+1) & newr = lonarr(n+1) & newc = strarr(n+1)
         newn(0:(n-1)) = vnames(0:(n-1))
         newv(0:(n-1)) = vvarys(0:(n-1))
         newc(0:(n-1)) = ctypes(0:(n-1))
         newd(0:(n-1)) = dhids(0:(n-1))
         newm(0:(n-1)) = mhids(0:(n-1))
         newn(n) = dvname & newv(n)='' & newc(n)='' & newd(n)=0 & newm(n)=0
         vnames = newn & vvarys=newv & ctypes=newc & dhids=newd & mhids=newm
      endif
   endif
   escape: ; Current tag name is not a depend attribute
endfor

end


;-------------------------------------------------------------------------
; NAME: CDFTYPE_T0_MYIDLTYPE
; PURPOSE: 
;	Convert from CDF type number to IDL type number
; CALLING SEQUENCE:
;       out = CDFtype_to_myIDLtype(in)
; INPUTS:
;       in = integer, CDF type number
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = integer, IDL type number
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;-------------------------------------------------------------------------
FUNCTION CDFtype_to_myIDLtype,cdftype
case cdftype of
   22L : idltype = 5 ; CDF_REAL8
   45L : idltype = 5 ; CDF_DOUBLE
   31L : idltype = 5 ; CDF_EPOCH
   21L : idltype = 4 ; CDF_REAL4
   44L : idltype = 4 ; CDF_FLOAT
   4L  : idltype = 3 ; CDF_INT4
   14L : idltype = 3 ; CDF_UINT4
   2L  : idltype = 2 ; CDF_INT2
   12L : idltype = 2 ; CDF_UINT2
   51L : idltype = 7 ; CDF_CHAR
   52L : idltype = 1 ; CDF_UCHAR
   1L  : idltype = 1 ; CDF_INT1
   11L : idltype = 1 ; CDF_UINT1
   41L : idltype = 1 ; CDF_BYTE
   else: idltype = 0 ; undefined
endcase
return,idltype
end


;+------------------------------------------------------------------------
; NAME: APPEND_MYDATA
; PURPOSE: 
; 	Append the 'new' data to the 'old' data using array concatenation.
; CALLING SEQUENCE:
;       out = append_mydata(new,old)
; INPUTS:
;       new = data to be appended to the old data
;       old = older data that new data is to be appended to
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = product of concatenating the old and new data arrays
; NOTES:
; 	Special case check: if old data was from either a skeleton CDF or from
; 	a CDF with only a single record, then the last dimension was dropped 
;	during the process of saving/retrieving the data from a handle.  
;	Must compare the dimensionality of the new and old data to determine 
;	if this drop has occured, and if so, reform the old data to include 
;       the extra dimension so that the data can be appended.
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;-------------------------------------------------------------------------
FUNCTION append_myDATA, new, old
a = size(new) & b = size(old) & data=0L

if (a(0) gt b(0)) then begin ; dimension mismatch - reform old data
   print,'WARNING= Dimension mismatch detected, attempting to reform...' ;DEBUG
   case b(0) of
      0    : ; no special actions needed
      1    : old = reform(temporary(old),b(1),1)
      2    : old = reform(temporary(old),b(1),b(2),1)
      3    : old = reform(temporary(old),b(1),b(2),b(3),1)
      else : print,'ERROR=Cannot reform single-record variable with > 3 dims'
   endcase
   b = size(old) ; recompute b after it has been reformed
endif
if (a(0) lt b(0)) then begin ; dimension mismatch - reform new data
   ;print,'WARNING= Dimension mismatch detected, attempting to reform...' ;DEBUG
   case a(0) of
      0    : ; no special actions needed
      1    : new = reform(temporary(new),a(1),1)
      2    : new = reform(temporary(new),a(1),a(2),1)
      3    : new = reform(temporary(new),a(1),a(2),a(3),1)
      else : print,'ERROR=Cannot reform single-record variable with > 3 dims'
   endcase
   a = size(new) ; recompute a after it has been reformed
endif

;print, size(old)
;print, size(new)

; append the new data to the old data
case a(0) of
   0:begin
       data = [old,new]
    end
   1:begin
       data = [old,new]
    end
   2:begin
       data = make_array(a(1),a(2)+b(2),type=a(3))
       data(*,0:b(2)-1)=old(*,*) & data(*,b(2):*)=new(*,*)
    end
   3:begin
       data = make_array(a(1),a(2),a(3)+b(3),type=a(4))
       data(*,*,0:b(3)-1)=old(*,*,*) & data(*,*,b(3):*)=new(*,*,*)
    end
   else: print,'ERROR=Cannot append arrays with > 3 dimensions yet'
endcase
new = 0L & old = 0L ; free up unneeded memory
return,data
end

;+------------------------------------------------------------------------
; NAME: add_myCOMPONENTS
; PURPOSE: 
;	Search the metadata anonymous structure for ISTP 'COMPONENT' 
;	attributes and add the variable name that it points to to the
;       vnames array if it is not already present.  If the component
;	variable is not present in the list, change the data_type so it
;	won't be plotted.
;
; CALLING SEQUENCE:
;       follow_myCOMPONENTS, metadata, vnames
;
; INPUTS:
;       metadata = anonymous structure holding attribute values
;       vnames   = string array of virtual variables found
;
; OUTPUTS:
;       vnames    = modified variable name that includes component variable
;                   names
;
; AUTHOR:
; 	Carrie Gallap, Raytheon STX,   1/5/98
;-------------------------------------------------------------------------
PRO add_myCOMPONENTS, metadata, vnames
common global_table, table

tnames = tag_names(metadata)

;TJK changed the i to k since that's what's used below
;for i=0,n_elements(tnames)-1 do begin

for k=0,n_elements(tnames)-1 do begin
   len = strlen(tnames(k)) & pos = strpos(tnames(k),'COMPONENT_')
   if ((len gt 10) AND (pos eq 0)) then begin 
      ; COMPONENT found, check remainder
      ON_IOERROR, escape ; return false if non-digit found
      for j=0,(len-11) do begin ; check one character at a time
         r = strmid(tnames(k),(10+j),1) & READS,r,v,FORMAT='(I1)'
      endfor
      dvname = metadata.(k) ; component attribute FOUND
      a = where(vnames eq dvname,count)    ; search vnames array
      ;TJK 4/23/01 added extra check for the case where the component_0 variable
      ; has an alternate name (its original name had invalid characters in it) - so
      ; check the table prior to including it.
      v_count = 0   
      e_index = where(dvname eq table.equiv, e_count)
      if (e_count gt 0) then begin 
         v_index = where(vnames eq table.varname(e_index), v_count)
      endif
      if ((dvname ne '')AND(count eq 0)AND(v_count eq 0)) then begin
         ;print, 'Adding ',dvname,' to vnames'
         ;  if COMPONENT variable not already requested, add it to the vnames
         ;  array, but change data_type so it won't be plotted...
         n = n_elements(vnames)
         newn = strarr(n+1)
         newn(0:(n-1)) = vnames(0:(n-1))
         vnames = newn
         vnames(n) = dvname ;put the component variable in place - TJK
      endif  ;  Added all component variable names
   endif  ;  Finished reading all component variable names
   escape: ;Current tag name is not a Component attribute
endfor  ;  Finished looping through all metadata elements

end

;+------------------------------------------------------------------------
; NAME: READ_MYVARIABLE
; PURPOSE: 
;	Return the data for the requested variable.
; CALLING SEQUENCE:
;       out = read_myvariable(vname, CDFid, vary, dtype, recs)
; INPUTS:
;       vname = string, name of variable to be read from the CDF
;       CDFid = integer, id or already opened CDF file.
; KEYWORD PARAMETERS:
;	START_REC = first record to read.
;	REC_COUNT = number of records to read.
; OUTPUTS:
;       out = all data from the CDF for the variable being read
;       vary = True(1) or False(0) is variable record-varying
;       dtype= string, CDF data type
;       recs = integer, number of data records
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;       96/04/11 : R.Burley :zVar handling when MAXRECS = -1 changed to
;                            read REC_COUNT of MAXRECS + 2 & return,DAT
; 	96/12/20 ; T. Kovalick modified to take START_REC and REC_COUNT
;	keywords (see above).  If they aren't set you will get all of
; 	the records in a cdf.
;-------------------------------------------------------------------------
FUNCTION read_myVARIABLE, vname, CDFid, vary, $
	 dtype, recs, START_REC=START_REC, REC_COUNT=REC_COUNT

;
; Get needed information about the cdf and variable

cinfo = cdf_inquire(CDFid) ; inquire about the cdf

vinfo = cdf_varinq(CDFid,vname) ; inquire about the variable
cdf_control,CDFid,VAR=vname,GET_VAR_INFO=vinfo2 ; inquire more about the var
zflag = vinfo.is_zvar ; determine if r-variable or z-variable

if keyword_set(START_REC) then start_rec = START_REC else start_rec = 0L
;TJK changed this because the maxrec that comes back from cdf_inquire only
;applies to R variables under IDL v5.02, so if you don't have any R 
;variables in your CDF, maxrec will come back as -1...
;rcount = cinfo.maxrec+1 & if (vinfo.RECVAR eq 'NOVARY') then rcount=1L
rcount = vinfo2.maxrec+1 & if (vinfo.RECVAR eq 'NOVARY') then rcount=1L


;TJK changed this...maxrecs isn't documented by RSI.
;if keyword_set(REC_COUNT) then recs = REC_COUNT else recs = vinfo2.maxrecs+1
;So if the rec_count keyword is specified us it, else determine the
;the max recs depending on whether the variable is z or r.

if keyword_set(REC_COUNT) then recs = REC_COUNT else recs = vinfo2.maxrec+1
;So if the rec_count keyword is specified us it, else determine the
;the max recs depending on whether the variable is z or r.

;TJK w/ IDL 5.02 they have now defined maxrec and maxrecs, we want to
; use maxrec and this should work the same for both r and z variables.
;if keyword_set(REC_COUNT) then begin 
;  recs = REC_COUNT 
;endif else if(zflag eq 1) then begin ;set the z variable max recs
;  recs = vinfo2.maxrec+1
;endif else recs = vinfo2.maxrecs+1 ;set the r variable max recs

vary = vinfo.RECVAR & dtype = vinfo.DATATYPE

; Read the CDF for the data for the requested variable
if (zflag eq 1) then begin ; read the z-variable
   cdf_control,CDFid,VAR=vname,GET_VAR_INFO=zvinfo
   if zvinfo.MAXREC eq -1 then begin
      if keyword_set(DEBUG) then print,'WARNING=',vname,' has ZERO records!'
      cdf_varget,CDFid,vname,dat,REC_COUNT=1 & return,dat
   endif else begin
      if keyword_set(DEBUG) then print, 'reading Z at record', start_rec, recs, 'number of records'
      cdf_varget,CDFid,vname,dat,REC_START=start_rec,REC_COUNT=recs
   endelse
   ;TJK - added the next two lines so that extraneous single dimensions
   ;will be taken out - this was already being done for r variables
   ;but wasn't for Z variables, so if we were loading a variable from
   ;both a z and r variable cdf there would be a mismatch and the
   ;append of the two data arrays would not be successful.
   ds = size(dat) ; get size info to determine if dat is scalar or not
   if (ds(0) ne 0) then dat = reform(temporary(dat)) ; eliminate extraneous dims
endif else begin ; read the r-variable
   dims = total(vinfo.dimvar) & dimc = vinfo.dimvar * cinfo.dim
   dimw = where(dimc eq 0,dcnt) & if (dcnt ne 0) then dimc(dimw)=1
   if rcount eq 0 then begin
      print,'WARNING=',vname,' has ZERO records!' & return,0
      ;TJK replaced this line w/ the following to accommodate start_rec and rec_count
      ;  endif else CDF_varget,CDFid,vname,dat,COUNT=dimc,REC_COUNT=rcount
   endif else CDF_varget,CDFid,vname,dat,COUNT=dimc,REC_START=start_rec,REC_COUNT=recs
   if keyword_set(DEBUG) then print, 'reading ',vname,' starting at record', start_rec,' ', recs, 'number of records'

   ds = size(dat) ; get size info to determine if dat is scalar or not
   if (ds(0) ne 0) then dat = reform(temporary(dat)) ; eliminate extraneous dims
endelse

; Correct for fact that IDL retrieves character data as bytes
if vinfo.DATATYPE eq 'CDF_CHAR' then begin ; IDL retrieves as bytes
   ds = size(dat) ; get dimensions of dat for single char special case
   if (ds(0) gt 1) then begin 
      dat = string(dat) & dat = reform(temporary(dat)); eliminate extraneous dims
   endif else begin ; process each element of array
      d2=strarr(ds(1)) & for i=0,ds(1)-1 do d2(i)=string(dat(i))
      dat = d2
   endelse
endif

; Check for sign loss for cdf unsigned integer data.  IDL (as of v4.0.1b)
; returns unsigned cdf variables as signed IDL variables with the same
; number of bytes.  This could cause a sign flip.  Detect and Correct.
if vinfo.DATATYPE eq 'CDF_UINT2' then begin
   w = where(dat lt 0,wc) ; search for negative values
   if (wc gt 0) then begin ; convert to long
      dat = long(dat) & dat(w) = dat(w)+(2L^16) & dtype='CDF_INT4'
      print,'WARNING=Converting CDF_UINT2 to CDF_INT4 to avoid sign switch.'
   endif
endif
if vinfo.DATATYPE eq 'CDF_UINT4' then begin
   w = where(dat lt 0,wc) ; search for negative values
   if (wc gt 0) then begin ; convert to float
      dat = float(dat) & dat(w) = dat(w)+(2.0d0^32) & dtype='CDF_REAL'
      print,'WARNING=Converting CDF_UINT4 to CDF_REAL4 to avoid sign switch.'
   endif
endif

; If this variable is a record-varying variable, but this CDF only happens
; to have one record, then we must add the extra dimension onto the end
; for proper appending to take place when other CDF's are read
if ((vinfo.RECVAR eq 'VARY')AND(rcount eq 1L)) then begin
   ; print,'WARNING=Reforming single-record variable' ;DEBUG
   ds = size(dat) ; get dimensions of dat
   case ds(0) of
      0    : rcount = 1L ; do nothing
      1    : dat = reform(temporary(dat),ds(1),1)
      2    : dat = reform(temporary(dat),ds(1),ds(2),1)
      3    : dat = reform(temporary(dat),ds(1),ds(2),ds(3),1)
      else : print,'ERROR=Cannot reform single-record variable with > 3 dims'
   endcase
endif
; Return the data read from the CDF
return,dat
end

;+------------------------------------------------------------------------
; NAME: READ_MYATTRIBUTE
; PURPOSE: 
;	Return the value of the requested attribute for the requested variable.
; CALLING SEQUENCE:
;       out = read_myattribute(vname,anum,CDFid)
; INPUTS:
;       vname = string, name of variable whose attribute is being read
;       anum = integer, number of attribute being read
;       CDFid = integer, id of already opened CDF file.
; KEYWORD PARAMETERS:
; OUTPUTS:
;       out = anonymous structure holding both the name of the attribute
;             and the value of the attribute
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;-------------------------------------------------------------------------
FUNCTION read_myATTRIBUTE, vname, anum, CDFid
common global_table, table

cdf_attinq,CDFid,anum,aname,ascope,maxe,maxze ; inquire about the attribute
aname = strtrim(aname,2) ; trim any possible leading or trailing blanks
attval='' & astruct=create_struct(aname,attval) ; initialize anonymous structure
;TJK modified this error catch to re-set the !error value since not finding
;all attributes is not a fatal error - w/o this SSWeb and the IDL server
;were getting stuck.
CATCH,error_status & if error_status ne 0 then begin !ERROR=0 & return,astruct & endif
   if (ascope eq 'GLOBAL_SCOPE')OR(ascope eq 'GLOBAL_SCOPE_ASSUMED') then begin
      cdf_attget,CDFid,anum,0,aval & attval = aval ; get the global attribute
      for entry=1,maxe do begin ; get remaining entrys if any
         if (entry eq 1) then begin ; create array to hold the data
            asize = size(aval) & dtype = asize(n_elements(asize)-2)
            attval = make_array((maxe+1),TYPE=dtype) & attval(0) = aval
         endif
         cdf_attget,CDFid,anum,entry,aval
         attval(entry) = aval
      endfor
      asize = size(attval) & nea = n_elements(asize)
      if (asize(nea-2) eq 7) then begin
         if asize(0) eq 0 then attval = strtrim(attval,2) $
         else for i=0,asize(1)-1 do attval(i) = strtrim(attval(i),2)
      endif
      astruct = create_struct(aname,attval)
   endif else begin ; 'VARIABLE_SCOPE' or 'VARIABLE_SCOPE_ASSUMED'
      cdf_attget,CDFid,anum,vname,aval & attval = aval ; read variable attribute  
      if (amI_ISTPptr(aname) eq 1) then begin ; check for pointer-type attribute
         attval = read_myVARIABLE(attval,CDFid,vary,ctype,recs)
      endif
      asize = size(attval) & nea = n_elements(asize)
      ;TJK, 3/2/2000, restrict the strtrim calls below because some attributes
      ;values are actually variable names which may need to have any leading/trailing
      ;blanks in order to be found in the cdf...  this is certainly the case for
      ;depend and component variable attributes...

      if ((asize(nea-2) eq 7) and NOT(amI_VAR(aname))) then begin
         if asize(0) eq 0 then attval = strtrim(attval,2) $
         else for i=0,asize(1)-1 do attval(i) = strtrim(attval(i),2)
      endif else begin
         if (amI_VAR(aname)) then begin
         ;replace "bad characters" w/ a "$"
         table_index = where(table.varname eq attval, tcount)
         ttable_index = where(table.equiv eq attval, ttcount)
         vcount = -1 ;initialize
         if (table_index(0) eq -1) and (ttable_index(0) eq -1)then begin ;add this variable to the table
            if keyword_set(debug) then print, 'found new attribute adding to table, ',attval
	    tfree = where(table.varname eq '',fcount)
	    if (fcount gt 0) then begin
	       table.varname(tfree(0)) = attval
	    endif else begin
	       print, '1, Number of variables exceeds the current size of the table structure, please increase it, current size is ' 
	       help, table.varname
	       return, -1
	    endelse
            table_index = where(table.varname eq attval, vcount)
         endif 

         if (vcount ge 0) then begin
      	    attval = replace_bad_chars(attval, diff)
	    table.equiv(table_index(0)) = attval ;set equiv to either the
	    ;new changed name or the original
	    ;if it doesn't contain any bad chars..
         endif else begin
	    if (vcount eq -1) then begin ;already set in the table, assign attval to what's in equiv.
	       attval = table.equiv(table_index(0))
	    endif
         endelse
      endif
   endelse
   astruct = create_struct(aname,attval)
endelse

return,astruct
end ;read_myattribute


;+------------------------------------------------------------------------
; NAME: READ_MYMETADATA
; PURPOSE: 
;	To read all of the attribute values for the requested variable, and
;       to return this information as an anonymous structure.
; CALLING SEQUENCE:
;       metadata = read_mymetadata(vname,CDFid)
; INPUTS:
;       vname = string, name of variable whose metadata is being read
;       CDFid = integer, id of already opened CDF file
; KEYWORD PARAMETERS:
; OUTPUTS:
;       metadata = anonymous structure whose tags are the attribute names
;                  and whose fields are the corresponding attribute values.
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;-------------------------------------------------------------------------
FUNCTION read_myMETADATA, vname, CDFid

cinfo = cdf_inquire(CDFid) ; inquire about the cdf to get #attributes
; Create initial data structure to hold all of the metadata information
METADATA = create_struct('varname',vname)
; Extract all metadata information for the all attributes
for anum=0,cinfo.natts-1 do begin
   astruct = 0 ; initialize astruct
   ; Get the name and value of the next attribute for vname
   astruct = read_myATTRIBUTE(vname,anum,CDFid)
   METADATA = create_struct(temporary(METADATA),astruct)
endfor ; for each attribute
return,METADATA
end

;+------------------------------------------------------------------------
; NAME: GET_NUMALLVARS
; PURPOSE: 
; 	To return the total number of variables in the cdf.
;
; CALLING SEQUENCE:
;       num_vars = get_numallvars(CNAME=CNAME)
; INPUTS:
; KEYWORD PARAMETERS:
;	CNAME = string, name of a CDF file to be opened and read
;	CDFid = integer, id of an already opened CDF file
; OUTPUTS:
;       num_vars = number of variables in the CDF
; AUTHOR:
;       Tami Kovalick, RITSS, October 27, 2000
; MODIFICATION HISTORY:
;
;-------------------------------------------------------------------------
FUNCTION get_numallvars, CNAME=CNAME, CDFid=CDFid

; validate keyword combination and open cdf if needed
if keyword_set(CNAME) AND keyword_set(CDFid) then return,0 ; invalid
if keyword_set(CNAME) then CDFindex = CDF_OPEN(CNAME) ; open the cdf
if keyword_set(CDFid) then CDFindex = CDFid ; save the cdf file number

; determine the number of variables 
cinfo = CDF_INQUIRE(CDFindex) ; inquire about number of variables
num_vars = cinfo.nvars + cinfo.nzvars
return, num_vars
end

;+------------------------------------------------------------------------
; NAME: GET_ALLVARNAMES
; PURPOSE: 
; 	To return a string array containing the names of all of the
;	variables in the given CDF file.
; CALLING SEQUENCE:
;       vnames = get_allvarnames()
; INPUTS:
; KEYWORD PARAMETERS:
;	CNAME = string, name of a CDF file to be opened and read
;	CDFid = integer, id of an already opened CDF file
;       VAR_TYPE = string, only return the names for variables who have an
;                  attribute called 'VAR_TYPE' and whose value matches the
;                  value given by this keyword.  (ex. VAR_TYPE='data')
; OUTPUTS:
;       vnames = string array of variable names
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;	4/9/1998 - TJK modified to include all variable when the "var_type"
;	keyword isn't used.  The original code only included variables
;	that vary by record so some important "support_data" variables
;	were being thrown out.
;-------------------------------------------------------------------------
FUNCTION get_allvarnames, CNAME=CNAME, CDFid=CDFid, VAR_TYPE=VAR_TYPE

; validate keyword combination and open cdf if needed
if keyword_set(CNAME) AND keyword_set(CDFid) then return,0 ; invalid
if keyword_set(CNAME) then CDFindex = CDF_OPEN(CNAME) ; open the cdf
if keyword_set(CDFid) then CDFindex = CDFid ; save the cdf file number

; determine the number of variables 
cinfo = CDF_INQUIRE(CDFindex) ; inquire about number of variables
numvars = cinfo.nvars + cinfo.nzvars & vnames=strarr(numvars)

; Set up an error handler
CATCH, Error_status
if Error_status ne 0 then begin
   if keyword_set(CNAME) then cdf_close,CDFindex
   print, "STATUS= Error reading CDF. "
   print,!ERR_STRING, "get_allvarnames.pro" & return,-1
endif

; Get the name of every r variable
for i=0,cinfo.nvars-1 do begin
   vinfo = CDF_VARINQ(CDFindex,i)
   if keyword_set(VAR_TYPE) then begin ; only get VAR_TYPE='data'
      metadata = read_myMETADATA(vinfo.name,CDFindex)
      tags = tag_names(metadata) & temp = where(tags eq 'VAR_TYPE',count)
      if count ne 0 then begin
         if metadata.VAR_TYPE eq VAR_TYPE then vnames(i) = vinfo.name
      endif
   endif else begin 
      vnames(i) = vinfo.name
   endelse
endfor

; Get the name of every z variable
for j=0,cinfo.nzvars-1 do begin
   vinfo = CDF_VARINQ(CDFindex,j,/ZVARIABLE)
   if keyword_set(VAR_TYPE) then begin ; only get VAR_TYPE='data'
      metadata = read_myMETADATA(vinfo.name,CDFindex)
      tags = tag_names(metadata) & temp = where(tags eq 'VAR_TYPE',count)
      if count ne 0 then begin
         if metadata.VAR_TYPE eq VAR_TYPE then vnames(j+cinfo.nvars) = vinfo.name
      endif
   endif else begin
      vnames(j+cinfo.nvars) = vinfo.name 
   endelse
endfor

if keyword_set(CNAME) then CDF_CLOSE,CDFindex
; strip blank vnames from the array
v = where(vnames ne "",vc)
if vc gt 0 then begin
   temp = strarr(vc) & temp = vnames(v) & vnames = temp
endif
return,vnames
end
 
function write_fill, vn_sdat, burley, tmp_str

;v_err='ERROR=Instrument off; fillval=dat'
v_stat='STATUS=Instrument off for variable '+vn_sdat+'.  Re-select variable or time. '
atags=tag_names(burley.(0))
b0 = tagindex('LOGICAL_SOURCE',atags)
b1 = tagindex('LOGICAL_FILE_ID',atags)
b2 = tagindex('Logical_file_id',atags)
if (b0(0) ne -1) then  psrce = strupcase(burley.(0).LOGICAL_SOURCE)
if (b1(0) ne -1) then $ 
   psrce = strupcase(strmid(burley.(0).LOGICAL_FILE_ID,0,9))
if (b2(0) ne -1) then $     
   psrce = strupcase(strmid(burley.(0).Logical_file_id,0,9))
v_data='DATASET='+psrce
; Reduce the number of reported errors to the developers RTB 1/97
;tmp_str=create_struct('DATASET',v_data,'ERROR',v_err,'STATUS',v_stat)
tmp_str=create_struct('DATASET',v_data,'STATUS',v_stat)
ikill=1

return, ikill
end

;This function checks to make sure a given variables 'varname' attribute 
;actually matches its structure members name.
;
function correct_varname, struct, varnames, index

;TJK 09/29/00 Put in a check to make the varname attribute value match
;its variables structure tag name - if it doesn't list_mystruct won't work...
;This is all necessary for the upgrade to IDL5.3
str_index = strtrim(string(index),2) ;convert to string
comm = execute('att_names = tag_names(struct.('+str_index+'))')
if (comm eq 1) then begin
   att_v = where(att_names eq 'VARNAME', att_cnt)
   if (att_cnt gt 0) then begin
      ;assign the variable name to the "VARNAME" attribute for this variable...
      ;assign_string = 'struct.'+varnames(index)+'.('+strtrim(string((att_v(0))),2)+')='''+varnames(index)+'''
      assign_string = 'struct.('+str_index+').('+strtrim(string((att_v(0))),2)+')='''+varnames(index)+'''
      ;print, 'assign_string = ',assign_string
      comm = execute(assign_string)
      if (comm ne 1) then print, 'execute failed for ',assign_string 
   endif
endif ;end TJK mod 09/29/00

return, struct
end

;+------------------------------------------------------------------------
; NAME: READ_MYCDF
; PURPOSE: 
;	Read all data and metadata for given variables, from given CDF
;       files, and return all information in a single anonymous structure
;       of the form: 
;          structure_name.variable_name.attribute_name.attribute_value
;
; CALLING SEQUENCE:
;       out = read_mycdf(vnames,cnames)
; INPUTS:
;       vnames = string, array of variable names or a single string of
;                names separated by a comma.  (ex. 'Epoch,Magfld,Bmax')
;       cnames = string, array of CDF filenames or a single string of
;                names separated by a comma.
; KEYWORD PARAMETERS:
;	ALL = If set, get data and metadata for ALL variables in the CDFs.
;       NODATASTRUCT = If set, instead of returning the data for each variable
;                   in the 'DAT' attribute field, create a 'HANDLE' field
;                   and set it to the handle id of a data handle which
;                   holds the data for each variable.
;       NOQUIET = If set, do NOT set the !QUIET system variable before
;                 reading the cdf file(s).
;       DEBUG = If set, print out some progress information during reading.
;	TSTART = epoch starting value - YYYYMMDD etc. string.
;	TSTOP = epoch ending value - YYYYMMDD etc. string.
; OUTPUTS:
;       out = anonymous structure holding all data and metadata for the
;             requested variables. If an error occurs, that we know how
;             to deal w/, an alternate structure is returned, its structure
;	      is as follows: ('DATASET',d_set,'ERROR',v_err,'STATUS',v_stat)
;	      
; AUTHOR:
;       Richard Burley, NASA/GSFC/Code 632.0, Feb 13, 1996
;       burley@nssdca.gsfc.nasa.gov    (301)286-2864
; MODIFICATION HISTORY:
;	Tami Kovalick, HSTX, 12/16/96 modified to verify whether 
; variables requested in vnames array are actually in the "data" cdfs 
; prior to requesting the data from these variables.  If variables 
; aren't valid then they are removed from the vnames array and the 
; code continues on to create a valid structure.
;	Tami Kovalick, HSTX, 12/20/96 modified to allow the use of 
; TSTART and TSTOP keywords (see above).  Use of these keywords will
; force the code to only read the necessary records in the CDF, otherwise
; the code will read the entire CDF.  Could enhance the code to deal
; w/ one or the other keyword - right now they are only used if both
; are set.
;	Tami Kovalick, RSTX, 02/13/98, Carrie Gallap started modifications
; to read_myCDF to accommodate "virtual variables" (VV) .  Tami finished 
; up the code and made corrections to several sections.  One new routine was
; written add_myCOMPONENTS, this routine is called when a valid virtual
; variable is found in order to add any additional variables needed for
; actually generating the data for the VV.  The routine looks for variable
; attributes w/ the naming convention COMPONENT_n where n is a digit.  The
; basic methodology to the changes is to determine whether any of the
; variables selected are virtual variables, if so then the variable name
; and the source (where the VV was defined - master or data cdfs) are
; stored in a structure called vir_vars, then add the component variables
; to the vnames array.  Do the usual checking to see if the variables requested
; in vnames actually exist. Then continue on w/ getting the metadata for all
; variables (including VV), and continue on w/ the getting the data from
; the CDFs for all variables except the VV.  Population of the VV's data field
; in the "burley" structure are handled at the very end in a case statement 
; which looks for each VV's variable attribute FUNCTION to determine which 
; actual "IDL function" to call, ie. conv_pos.
;-------------------------------------------------------------------------

FUNCTION read_mycdf2, vnames, cnames, ALL=ALL,NODATASTRUCT=NODATASTRUCT, $
                                     NOQUIET=NOQUIET,DEBUG=DEBUG, $
				     TSTART=TSTART, TSTOP=TSTOP


; establish exception handler to trap errors from all sources.
CATCH,error_status
if (error_status ne 0) then begin
   print,!ERR_string ," Trapped in read_myCDF."; output description of error
   print,'Error Index=',error_status
   ;also need to check for -123 for IDL 5.02, -98 is for IDL 4.01b - TJK 1/23/98
   if(error_status eq -98 or error_status eq -123 or error_status eq -124) then begin
      val_err="ERROR=Memory Exceeded; -98 or -123 or -124"
      val_stat="STATUS=Time range selected generates array which exceeds available space. Re-select time range."
      ;
      if(n_elements(mydata) ne 0) then begin
         atags=tag_names(mydata.(0))
         b0 = tagindex('LOGICAL_SOURCE',atags)
         b1 = tagindex('LOGICAL_FILE_ID',atags)
         b2 = tagindex('Logical_file_id',atags)
         if (b0(0) ne -1) then  psrce = strupcase(mydata.(0).LOGICAL_SOURCE)
         if (b1(0) ne -1) then $
            psrce = strupcase(strmid(mydata.(0).LOGICAL_FILE_ID,0,9))
         if (b2(0) ne -1) then $
            psrce = strupcase(strmid(mydata.(0).Logical_file_id,0,9))
         v_data='DATASET='+psrce
      endif else begin
         parts=str_sep(cnames(cx),'/')
         piece=strupcase(str_sep(parts(n_elements(parts)-1),'_'))
         tempnm= piece(0)+'_'+piece(1)+'_'+piece(2)
         val_data="DATASET="+tempnm
      endelse
      tmpstr=create_struct('DATASET',val_data,'ERROR',val_err,'STATUS',val_stat)
      return, tmpstr
  endif  
  return,-1 ; return failure flag
endif

debug = 0
if keyword_set(DEBUG) then debug = 1

; Validate cnames parameter, remove .cdf extensions if present
s = size(cnames) & ns = n_elements(s)
if (s(ns-2) eq 7) then begin
   if (s(0) eq 0) then cnames = break_mySTRING(cnames,DELIMITER=',')
   for i=0,n_elements(cnames)-1 do begin
      j=strpos(cnames(i),'.cdf') & if (j eq -1) then j=strpos(cnames(i),'.CDF')
      if (j ne -1) then cnames(i) = strmid(cnames(i),0,j)
   endfor
endif else begin
   print,'ERROR=CDF filenames must be given as strings.' & return,-1
endelse
if keyword_set(DEBUG) then print,'Number of CDFs to read=',n_elements(cnames)

;TJK setup a structure called table to hold the variable name as they are in
;the cdf and then an 'equivalent' name if the real variable name turned out to 
;contain "illegal characters", e.g. "!,@,#" etc..

common global_table, table
num_vars = get_numallvars(CNAME=cnames(0))
var_names = strarr(num_vars)
 
;varname will contain the real cdf variable name(s)
;equiv will contain the "fake" one(s)
table = create_struct('varname',var_names,'equiv',var_names)

; If the ALL keyword is set then get names of all data variables
if keyword_set(ALL) then vnames = get_allvarnames(CNAME=cnames(0),var_type='data')

quiet_flag = !quiet ; save current state of quiet flag
if not keyword_set(NOQUIET) then !quiet=1 ; turn off annoying cdf messages
;print, 'Announcement of annoying CDF messages = ', !quiet

; Validate vnames parameter.  May be a strarr or single string
s = size(vnames) & ns = n_elements(s)
if (s(ns-2) eq 7) then begin
   if (s(0) eq 0) then vnames = break_mySTRING(vnames,DELIMITER=',')
endif else begin
   print,'ERROR=variable names must be given as strings.' & return,-1
endelse

;make a copy of the vnames in the orig_names array for use w/
;virtual variables and/or alternate views. TJK 2/4/98
orig_names = vnames


;TJK - 12/16/96
; added this section of code to check whether the requested variables
;are actually in the CDFs (other than the master CDFs).  If not, take them
;out... and continue building the structure w/ the resultant variables.
 
rcount = n_elements(vnames)
num_virs = -1 ; keep counter of number of virtual variables found
;create a structure to contain the virtual variable name and whether
;the variable was found in the master or in a data CDF, set to
;0 or 1 respectively.
; Added arbitrary # of 10 to structure; need space for vv depends  RTB  3/98
n_tmp = strarr(n_elements(vnames)+10) ; initialize it
m_tmp = make_array(n_elements(vnames)+10,/integer, value=-1)
vir_vars= create_struct('name',n_tmp,'flag',m_tmp)

for cx=0,n_elements(cnames)-1 do begin
   if (rcount gt 0) then begin
      ; Open the CDF and inquire about global information about file
      print,'Verifying variables in ',cnames(cx)
      CDFid = cdf_open(cnames(cx)) & cinfo = cdf_inquire(CDFid)
      ; if there is a master, look there for virtual variables that may not
      ; be defined in the actual cdfs...
      if (strpos(cnames(cx),'00000000') ne -1) then begin  ;a master
         ;read the metadata for the variables requested from the master...	
         vdep_cnt=0;
         chkvv_dep=strarr(20)
         for nreq =0, n_elements(vnames)-1 do begin
	    atmp = read_myMETADATA (vnames(nreq), CDFid)
	    atags = tag_names (atmp)
	    b0 = tagindex ('VIRTUAL', atags)
            ;look through metadata and look for virtual variables...
            ; get components of the virtual variables and add them to the vnames  
            ; array...
            if (b0(0) ne -1 ) then begin
               if (strlowcase(atmp.VIRTUAL) eq 'true') then begin
	          if (debug) then print, 'Found a VV ',vnames(nreq),' in Master CDF.'
	          num_virs = num_virs + 1
                  vir_vars.name(num_virs) = vnames(nreq)
                  vir_vars.flag(num_virs) = 0 ;indicate this var found in master
	          print, 'found a VV ', vnames(nreq), ' in Master CDF.'
	          print, 'adding components next...'
	          add_myCOMPONENTS, atmp, vnames
                  ; Check VV's depends for other VV's and add to list
                  ;TJK 11/98 added logic to only add the variable if it doesn't
                  ;already exist in the chkvv_dep list.
                  b1 = tagindex ('DEPEND_0', atags)
	          if (b1(0) ne -1 ) then begin
	             if (atmp.depend_0 ne '') then begin
	                num = where(chkvv_dep eq atmp.depend_0, cnt)
	                if (cnt eq 0) then begin
		           chkvv_dep(vdep_cnt)=atmp.depend_0
		           vdep_cnt=vdep_cnt+1
	                endif
	             endif
	          endif
	          b1 = tagindex ('DEPEND_1', atags)
	          if (b1(0) ne -1 ) then begin
	             if (atmp.depend_1 ne '') then begin
	                num = where(chkvv_dep eq atmp.depend_1, cnt)
	                if (cnt eq 0) then begin
		           chkvv_dep(vdep_cnt)=atmp.depend_1
		           vdep_cnt=vdep_cnt+1
	                endif
	             endif
	          endif
	          b1 = tagindex ('DEPEND_2', atags)
	          if (b1(0) ne -1 ) then begin
	             if (atmp.depend_2 ne '') then begin
	                num = where(chkvv_dep eq atmp.depend_2, cnt)
                        if (cnt eq 0) then begin
		           chkvv_dep(vdep_cnt)=atmp.depend_2
		           vdep_cnt=vdep_cnt+1
	                endif
	             endif
	          endif
                  ;TJK - 1/29/2001 add a check to see whether the component 
                  ; variables are virtual
	          b1 = tagindex ('COMPONENT_0', atags)
	          if (b1(0) ne -1 ) then begin
	             if (atmp.component_0 ne '') then begin
	                num = where(chkvv_dep eq atmp.component_0, cnt)
                        if (cnt eq 0) then begin
		           chkvv_dep(vdep_cnt)=atmp.component_0
		           vdep_cnt=vdep_cnt+1
	                endif
	             endif
	          endif
               endif ; if atmp.virtual eq true
            endif ; if b0(0) ne -1
         endfor
         ; Now check the depend var's of the VV for VV
         if(vdep_cnt gt 0) then begin
            cwc=where(chkvv_dep ne '',cwcn)
            chkvv_dep=chkvv_dep(cwc)
            for nvvq =0, n_elements(chkvv_dep)-1 do begin
               atmp = read_myMETADATA (chkvv_dep(nvvq), CDFid)
               atags = tag_names (atmp)
               b0 = tagindex ('VIRTUAL', atags)
               if (b0(0) ne -1 ) then begin
                  if (strlowcase(atmp.VIRTUAL) eq 'true') then begin
                     if (DEBUG) then print, 'Found a VV ',chkvv_dep(nvvq),' among Depends.'
                     num_virs = num_virs + 1
                     vir_vars.name(num_virs) = chkvv_dep(nvvq)
                     vir_vars.flag(num_virs) = 0 ;indicate this var found in master
                     add_myCOMPONENTS, atmp, vnames 
                  endif
               endif
            endfor
         endif
         ; Continue to process vnames array...  
      endif 
      ;  Possibly the virtual variable is defined in the cdf itself, check for 
      ;  that...
      if (strpos(cnames(cx),'00000000') eq -1) then begin  ;not a master
         ;if this is not a master cdf we want to check to make sure all of the
         ;variables that were requested (in vnames) actually exist in this cdf.
         ;If not, do not ask for them... doing so causing problems...
         ; look for the requested variable in the whole list of vars in this cdf
         all_cdf_vars = get_allvarnames(CDFid = CDFid)
         ;  Look to see if a virtual variable is defined in the cdf file...
         for nvar = 0, (n_elements(all_cdf_vars)-1)  do begin
            atmp = read_myMETADATA (all_cdf_vars(nvar), CDFid)
            atags = tag_names (atmp)
            b0 = tagindex ('VIRTUAL', atags)
            if (b0(0) ne -1) then begin
               if (strlowcase(atmp.VIRTUAL) eq 'true') then begin
	          ;check to see if the vir_var is already in the array,
	          ; if so don't add it to the array.
 	          if (num_virs ge 1) then begin
	             c = where(vir_vars.name eq all_cdf_vars(nvar), cnt) 
	             ;compare this one with the vir_vars
	             if (cnt eq 0) then begin ;if this one isn't in vir_vars add it.
	                num_virs = num_virs+1
	                vir_vars.name(num_virs) = all_cdf_vars(nvar)
                        vir_vars.flag(num_virs) = 1 ;indicate this var found in data cdf
	                if (debug) then print, 'Found a VV ',all_cdf_vars(nvar),' in data CDF'
	             endif
	          endif else begin
	             num_virs = num_virs+1
	             vir_vars.name(num_virs) = all_cdf_vars(nvar)
                     vir_vars.flag(num_virs) = 1 ;indicate this var found in data cdf
	             if (debug) then print, 'Found a VV ',all_cdf_vars(nvar),' in data CDF'
	          endelse	
	       endif
            endif
         endfor
         ;  If virtual variables were found in the cdf, see if they were requested... 
         for req_vars=0, (n_elements(vnames)-1) do begin
            if (debug) then print,'Determining if VVs requested and add any components', req_vars
            vcdf = where(vir_vars.name eq vnames(req_vars), v_cnt)
            ;virtual has been requested...
            if (vcdf(0) ne -1L)  then begin
	       ; found in data cdf (vs. Master cdf) so we need to add it
               if(vir_vars.flag(num_virs)) then begin
	          if (debug) then print, 'Add components for VV, ',vnames(req_vars)
                  atmp = read_myMETADATA (vnames(req_vars), CDFid)
	          add_myCOMPONENTS, atmp, vnames
	       endif
            endif
         endfor
         ;  Now check that all variables requested, and components of virtuals, are
         ;  found in the cdf file...
         for req_vars=0, (n_elements(vnames)-1) do begin
            if (DEBUG) then print, 'Checking to see if variables are actually in this data cdf.'
            fcdf = where(all_cdf_vars eq vnames(req_vars), found_cnt)  
            if (fcdf(0) eq -1L) then begin      ;didn't find requested variable.
               ;Make sure you don't blank out a virtual variable that has 
               ;been defined in a master...
               vcdf = where (vir_vars.name eq vnames(req_vars), v_cnt)
               ;TJK added code to check whether vnames(req_vars) is a variable that has been altered
               ;because its original name had "invalid" characters in it - if it was altered, do
               ;not throw it out... 10/31/2000
               table_index = where(table.equiv eq vnames(req_vars), tcount)
               if (tcount gt 0) then begin
	          ;before adding the table.varname to vnames, make sure it isn't already there...
	          already_there = where(table.varname(table_index(0)) eq vnames, already_cnt)
	          if (already_cnt eq 0) then begin
	             vnames(req_vars) = table.varname(table_index(0)) 
	             ;another name needs to be used in order to get 
	             ;the data out of the cdf
	          endif ;TJK removed this - this shouldn't be necessary 1/29/2001
	          ; else vnames(req_vars) = ' '     ; so blank it out
	       endif
               ;No, this is not a virtual variable
               ;TJK modified if (vcdf(0) eq -1L) then begin
	       if (vcdf(0) eq -1L and tcount eq 0) then begin
	          if (DEBUG) then print,'Variable ',vnames(req_vars),$
                     ' not found in this data cdf - throwing out.
                  vnames(req_vars) = ' '     ; so blank it out
	       endif
            endif
         endfor ;for each requested variable
         if (DEBUG) then print, 'made it through SETUP for DATA cdfs'
      endif ; if not a master cdf
      real_vars = where(vnames ne ' ', rcount);
      if (rcount gt 0) then vnames = vnames(real_vars)
      cdf_close,CDFid ; close the open cdf
   endif 
endfor ; for each cdf

;end TJK modifications

dhids = lonarr(n_elements(vnames)) ; create array of handle ids for data
mhids = lonarr(n_elements(vnames)) ; create array of handle ids for metadata
vvarys = strarr(n_elements(vnames)) ; initialize variable variance array
cdftyp = strarr(n_elements(vnames)) ; initialize cdftype array

if (rcount gt 0) then begin ; check whether there are any variables to retrieve
   ; get the data and metadata for all variables from all cdfs
   for cx=0,n_elements(cnames)-1 do begin
      ; Open the CDF and inquire about global information about file
      CDFid = cdf_open(cnames(cx)) & cinfo = cdf_inquire(CDFid)
      ;TJK had to add the following two calls to cdf_control in order
      ;to get the proper number of maxrecs down below - this was needed
      ;for IDL v5.02
      cdf_control, CDFid, SET_ZMODE=2 ;set zmode so that i can always know that
      ;the variables are z variables for next line.
      cdf_control, CDFid,  VAR=0, /Zvariable, GET_VAR_INFO=vinfo2 ; inquire more about the var
      ; TJK - 12/20/96 - added this section plus some modifications below
      ; to only get the data for requested time range.  This should significantly
      ; help conserve memory usage in this s/w.
      start_rec = 0L ;initialize to read the whole cdf.
      ;TJK changed this since the maxrec coming back from cdf_inquire only
      ;applies to R variables under IDL v5.02, so if you don't have any R
      ;variables in your CDF, maxrec will come back as -1...
      ;  rec_count = cinfo.maxrec+1 ; initialize to read all records
      rec_count = vinfo2.maxrecs+1 ; initialize to read all records
      if (keyword_set(TSTART) and keyword_set(TSTOP))then begin 		
         ;convert the TSTART and TSTOP to double precision numbers.
	 ;Get the epoch variable data first, determine
	 ;which records fall within the TSTART and TSTOP range.
	 start_time = 0.0D0 ; initialize
	 b = size(TSTART) & c = n_elements(b)
	 if (b(c-2) eq 5) then start_time = TSTART $ ; double float already
	 else if (b(c-2) eq 7) then start_time = encode_cdfepoch(TSTART); string
	 stop_time = 0.0D0 ; initialize
	 b = size(TSTOP) & c = n_elements(b)
	 if (b(c-2) eq 5) then stop_time = TSTOP $ ; double float already
	 else if (b(c-2) eq 7) then stop_time = encode_cdfepoch(TSTOP); string
         ; Read depend_0; Move this below inside REPEAT loop RTB 9/30/97 
         ;        atmp=read_myMETADATA(vnames(cx), CDFid)
         ;        depend0=atmp.depend_0
         ;	epoch = read_myVARIABLE(depend0,CDFid,vary,dtype,recs)
         ;         	epoch = read_myVARIABLE('Epoch',CDFid,vary,dtype,recs) ; RTB replaced 9/30/97
         ;	if (recs gt 0) then begin ; we're looking at a cdf w/ data in it!
         ;	  valid_recs = where(((epoch lt stop_time) and (epoch gt start_time)),$
         ;			  rec_count)
         ;	  if (rec_count gt 0) then start_rec = valid_recs(0)
         ;	endif else start_rec = 0L ;read the whole cdf.
      endif
      ;end TJK TSTART and TSTOP modifications.

      vnn=0
      vn_sdat=strarr(n_elements(vnames)+40)
      all_cdf_vars = get_allvarnames(CDFid = CDFid)
      ;get the list of vars in the current CDF.
      ; Read all of the selected variables from the open CDF
      vx = 0 & REPEAT begin
         ;TJK check to see if the current variable exists in this CDF.
         ;if not go to the bottom of the repeat. 5/1/98
         found = where(all_cdf_vars eq vnames(vx), found_cnt)  
         if (found_cnt gt 0L) then begin  ;did find requested variable.
            ;TJK added this next section so that the vvarys array is 
            ;actually set for all of the variables. 4/98
            vvarys(vx) = 'NOVARY'
            cdftyp(vx) = ' '
            if (num_virs gt -1) then begin
               vv = where(vnames(vx) eq vir_vars.name, vv_cnt)
               ;if this var is not virtual or looking in a master CDF
               if ((vv_cnt le 0) or (cx eq 0)) then begin 
                  vinfo = cdf_varinq(CDFid,vnames(vx)) ; inquire about the variable
                  vvarys(vx) = vinfo.RECVAR
                  cdftyp(vx) = vinfo.DATATYPE
               endif
            endif else begin
               vinfo = cdf_varinq(CDFid,vnames(vx)) ; inquire about the variable
               vvarys(vx) = vinfo.RECVAR
               cdftyp(vx) = vinfo.DATATYPE
            endelse
            ;end of TJK mods. 4/98
            ; Read the data for the variable unless it is known to be non varying
            if (vvarys(vx) ne 'NOVARY') then begin    
               ; Determine rec_count from depend_0 of current variable; check start & stop times RTB 9/30/97
               if (keyword_set(TSTART) and keyword_set(TSTOP))then begin 		
                  ; Need to find depend_0 for the current variable
                  ;TJK - 12/20/96 added the use of the start_rec and rec_count keywords.
                  if (cx eq 0) then begin ;TJK only get the metadata from the 1st cdf.
                     ;read this metadata from a master CDF only
                     atmp=read_myMETADATA(vnames(vx), CDFid)
                  endif else begin ;get the already retrieved data out of the handle
                     handle_value, mhids(vx), atmp
                  endelse
                  mnames=tag_names(atmp)
                  ; If a depend0 is not defined for a variable, read 
                  ;entire cdf (no time limits applied. RTB
                  nck=where(mnames eq 'DEPEND_0',dum)
                  if(nck(0) ne -1L) then depend0=atmp.depend_0 $
                  else begin 
                     if keyword_set(DEBUG) then print, "No depend_0 attribute, read entire cdf"
                     start_rec = 0L
                     goto, NO_VAR_ATT
                  endelse
                  nck=where(mnames eq 'VAR_TYPE',dum)
                  if(nck(0) ne -1L) then vartype=atmp.var_type $
                  else begin 
                     if keyword_set(DEBUG) then print, "No variable attribute, read entire cdf"
                     start_rec = 0L 
                     goto, NO_VAR_ATT 
                  endelse
                  ;RTB - 10/03/97 added code to distinguish b/w epoch and other data
                  ;read all epoch data then apply start and stop times
                  if(depend0 ne '') then begin
                     table_index = where(table.equiv eq depend0, tcount)
                     if (tcount gt 0) then begin
                        depend0 = table.varname(table_index(0)) 
                        ;another name needs to be used 
                        ;in order to get the data out of the cdf
                     endif
                     epoch = read_myVARIABLE(depend0,CDFid,vary,dtype,recs)
                  endif else begin ;assumes this is the epoch variable
                     if(vartype ne 'metadata') then begin
                        table_index = where(table.equiv eq vnames(vx), tcount)
                        if (tcount gt 0) then begin
                           depend0 = table.varname(table_index(0)) 
                           ;another name needs to be used 
                           ;in order to get the data out of the cdf
                           epoch = read_myVARIABLE(depend0,CDFid,vary,dtype,recs)
                        endif else begin
                           epoch = read_myVARIABLE(vnames(vx),CDFid,vary,dtype,recs)
                        endelse
                     endif
                  endelse
                  if (recs gt 0) then begin ; we're looking at a cdf w/ data in it!
                     valid_recs = where(((epoch lt stop_time) and (epoch gt start_time)),$
                     rec_count)
                     if (rec_count gt 0) then begin 
                        start_rec = valid_recs(0)
                     endif else begin ;read one, only because if I set rec_count to zero
                        start_rec = 0L ;we'll get ALL of the records instead of none!
                        rec_count = 1L
                     endelse
                  endif else start_rec = 0L ;read the whole cdf.
               endif else begin ; if keyword set start and stop
                  start_rec = 0L ; else, get all records for this variable 
                  rec_count = 0L
               endelse
            endif else begin ;variables don't vary
               start_rec = 0L & rec_count = 1L
            endelse
            NO_VAR_ATT:
            ; RTB end 9/30/97
            if keyword_set(DEBUG) then begin
               print,'Reading data for ',vnames(vx)
               print, 'Starting at record ',start_rec,' and reading ',$
               rec_count, ' records.'
            endif
            ;TJK - 02/17/98 added check for virtual variables, if a
            ;virtual variable has been requested then there isn't any
            ;data to read from the CDF so set the data array to zero.
            ;The data will be filled in at the very bottom of this routine.
            read_flag = 1 ; set flag to true
            if (num_virs gt -1) then begin
               vv = where(vnames(vx) eq vir_vars.name, vv_cnt)
               if (vv_cnt ge 1) then begin
                  ;one exception to above
                  ; Check var_type for current variable  RTB 5/98
                  cdf_attget,CDFid,'VAR_TYPE',vnames(vx),vartype
                  if ((vartype eq 'metadata') and(vvarys(vx) eq 'NOVARY') and $
                     (cx eq 0)) then begin ;vv,novary,metadata read from master
                  read_flag = 1
                  print, 'reading vv, novary,non-metadata from master, ',vnames(vx)
               endif else begin
                  read_flag = 0 ;set read flag to false
                  data = 0 ;set the data array to nothing as a place holder.
               endelse
            endif
         endif
         if (read_flag) then $
            data = read_myVARIABLE(vnames(vx),CDFid,$
            vary,dtype,recs,start_rec=start_rec, $
            rec_count=rec_count) ; read the data
         ; Flag arrays of length 1; will check later to see if these have fillval's
         ; which indicates instrument is off  RTB 9/96
         sz=size(data)
         ;print,vnames(vx)
         ;print, sz
         ; Check if data is of 0, 1 or multi-dimension and set flag
         ;  if(sz(0) ge 1) then szck=sz(1)/(sz(sz(0)+2)) else szck=sz(sz(0)+2)
         ; RTB 10/29/97 
         if(sz(0) gt 1) then szck=sz(1)/(sz(sz(0)+2)) else szck=sz(sz(0)+2)
         if(sz(0) eq 3) then  szck=sz(sz(0))
         ;TJK 3/17/98, added check for read_flag, if its set then this is
         ;NOT a virtual variable, so go ahead w/ the check for a single
         ;record containing fill (indicates instrument is off).
         ;TJK 10/25/99 added further check to see if this CDF is a master, if 
         ;it is then don't check for "instrument off" since most masters 
         ;don't contain any data.
         if(szck eq 1) and (vnames(vx) ne '') and (read_flag eq 1) and $
            (strpos(cnames(cx),'00000000') eq -1) then begin
            vn_sdat(vnn)=vnames(vx)
            vnn=vnn+1
            ;print, "Add to instrument off list:", vn_sdat
         endif
         ;      
         if keyword_set(DEBUG) then begin 
            print, 'data read and has the form: '
            help, data
         endif
         vvarys(vx) = vary  ; save the record variance flag
         cdftyp(vx) = dtype ; save the cdf data type
         ;TJK moved this up above No_VAR_ATT 4/16/98   endif
         ; Process the metadata of the current variable
         if (cx eq 0) then begin ; for only the first cdf in the list 
            vvarys(vx) = vary ; set value in variable variance array
            if keyword_set(DEBUG) then print,'Reading metadata for ',vnames(vx)
            metadata = read_myMETADATA(vnames(vx),CDFid) ; read variable metadata
            mhids(vx) = HANDLE_CREATE() & HANDLE_VALUE, mhids(vx), metadata, /SET
            ; Check metadata for ISTP depend attr's, modify other arrays accordingly
            follow_myDEPENDS, metadata, vnames, vvarys, cdftyp, dhids, mhids
         endif

         ; Process the data of the current variable
         if(strpos(cnames(cx),'00000000') eq -1)OR(vvarys(vx) eq 'NOVARY') then begin
            ; not a master skeleton or NRV data values from a master
            if (dhids(vx) eq 0) then begin ; create handle to hold data
               dhids(vx) = HANDLE_CREATE() & HANDLE_VALUE, dhids(vx), data, /SET
            endif else begin ; only append record varying data
               if (vvarys(vx) eq 'VARY') then begin  ; append data to previous data
                  HANDLE_VALUE, dhids(vx), olddata    ; get data from previous cdf's
                  ; Append only data when the instrument is on. RTB 10/29/97
                  ;print, "vnn=", vnn
                  ;print, vnames
                  ;print, "vn_sdat ",vn_sdat
                  ;if(vnn eq 0) then begin 
                  ;if(vn_sdat(vnn-1) ne vnames(vx)) then $ 
                  ;data = append_myDATA(data,olddata)  ; append new data to old data
                  ;endif else begin
                  ; print, vnames(vx),vnn
                  data = append_myDATA(data,olddata)  ; append new data to old data
                  ;endif
                  ;endelse
                  HANDLE_VALUE, dhids(vx), data ,/SET ; save back into handle
               endif
            endelse
         endif
      endif else print, 'variable ',vnames(vx), ' not found in ',cnames(cx)
      vx = vx + 1 ; increment variable name index
      ENDREP UNTIL (vx eq n_elements(vnames))
      cdf_close,CDFid ; close the open cdf
   endfor ; loop thru all cdfs
      
   if keyword_set(DEBUG) then print,'Assembling Anonymous Structure'
   ; It is possible that some of the variable names may be padded with blanks
   ; This will likely cause problems later, so trim any blanks around vnames.
      
   ;TJK took out on 3/12/01 - because the replace_bad_chars function now
   ;replaces any non-acceptable characters w/ dollars signs instead of just
   ;removing them.
   ;for i=0,n_elements(vnames)-1 do vnames(i) = strtrim(vnames(i),2)
      
   ; Retrieve the data and metadata from first handle, and append them
   ; together to create a data structure to be output from this function.
      
   HANDLE_VALUE, mhids(0), metadata, /NO_COPY  & HANDLE_FREE,mhids(0)
   if dhids(0) ne 0 then HANDLE_VALUE,dhids(0),data else data = ''
   ds = size(data) & if (ds(0) ne 0) then data = reform(temporary(data)) ; special case
   
   ;IDL 5.3 doesn't allow structure tag names that are not valid variable names,
   ;thus we need to check the vnames array for any CDF variable names that contain
   ;special characters, e.g. badChars=['\','/','.','%','!','@','#','^','&',
   ; '*','(',')','-','+','=', '`','~','|','?','<','>']  and replace them w/ a "$"
   ; character instead... not sure what other ramifications this will have 
   ; throughout the rest of the system. TJK 4/5/2000
      
   for t=0, n_elements(vnames)-1 do begin
      if keyword_set(DEBUG) then print, 'Processing table variable, ',vnames(t)
      table_index = where(table.varname eq vnames(t), tcount)
      ttable_index = where(table.equiv eq vnames(t), ttcount)
      vcount = -1 ;initialize
      if (table_index(0) eq -1) and (ttable_index(0) eq -1) then begin ;add this variable to the table
         if keyword_set(DEBUG) then print, 'found new variable, adding to table, ',vnames(t)
         tfree = where(table.varname eq '',fcount)
         if (fcount gt 0) then begin
            table.varname(tfree(0)) = vnames(t)
         endif else begin
            print, '2, Number of variables exceeds the current size of the table structure, please increase it, current size is ' 
            help, table.varname
            return, -1
         endelse
         table_index = where(table.varname eq vnames(t), vcount)
      endif
      if (vcount ge 0) then begin
         vnames(t) = replace_bad_chars(vnames(t), diff)
         table.equiv(table_index(0)) = vnames(t) 
         ;set equiv to either the new changed name or the original
         ;if it doesn't contain any bad chars..
      endif else begin
         if (vcount eq -1) then begin ;already set in the table, assign to what's in equiv.
            if table_index(0) ge 0 then idx = table_index(0)
            if ttable_index(0) ge 0 then idx = ttable_index(0)
            vnames(t) = table.equiv(idx)
         endif
      endelse
   endfor
      
   if keyword_set(NODATASTRUCT) then begin
      ; Rather than place the actual data into the megastructure, create
      ; a data handle structure field and put the data handle id in it.
      mytype = create_struct('cdftype',cdftyp(0))  ; create .cdftype structure
      mydata = create_struct('handle',dhids(0))    ; create .handle structure
      mysize = create_struct('idlsize',size(data)) ; create .idlsize structure
      mytype = create_struct(mytype,mysize)        ; append the structures
      mydata = create_struct(mytype,mydata)        ; append the structures
      mydata = create_struct(metadata,mydata)      ; append the metadata
      burley = create_struct(vnames(0),mydata)     ; create initial structure
   endif else begin
      ; Place the actual data into the large data structure.  This requires
      ; moving data and can take a long time with large image data arrays.
      if dhids(0) ne 0 then HANDLE_FREE,dhids(0)
      ds = size(data) & if (ds(0) ne 0) then data = reform(data) ; special case
      mytype = create_struct('cdftype',cdftyp(0)) ; create .cdftype structure
      mydata = create_struct('dat',data)          ; create .dat structure
      mydata = create_struct(mytype,mydata)       ; append the structures
      mydata = create_struct(metadata,mydata)     ; append the metadata
      burley = create_struct(vnames(0),mydata)    ; create initial structure
   endelse
      
   burley = correct_varname(burley, vnames, 0)

   ; If more than one variable is being processed, then retrieve the data
   ; and metadata from the handles, and append them into an anonymous struct
   ; and append these structures into a single anonymous struct for output.
   
   for vx = 1,n_elements(vnames)-1 do begin ; retrieve and append
      HANDLE_VALUE, mhids(vx), metadata, /NO_COPY  & HANDLE_FREE,mhids(vx)
      if dhids(vx) ne 0 then HANDLE_VALUE,dhids(vx),data else data = ''
      ds = size(data) & if (ds(0) ne 0) then data = reform(temporary(data)) ; special case
      if keyword_set(NODATASTRUCT) then begin
         ; Rather than place the actual data into the megastructure, create
         ; a data handle structure field and put the data handle id in it.
         mytype = create_struct('cdftype',cdftyp(vx)) ; create .cdftype structure
         mysize = create_struct('idlsize',size(data)) ; create .idlsize structure
         mydata = create_struct('handle',dhids(vx))   ; create .handle structure
         mytype = create_struct(mytype,mysize)        ; append the structures
         mydata = create_struct(mytype,mydata)        ; append the structures
         mydata = create_struct(metadata,mydata)      ; append the metadata
         rick   = create_struct(vnames(vx),mydata)    ; create new structure
         burley = create_struct(burley,rick)          ; create initial structure
      endif else begin
         if (dhids(vx) ne 0) then HANDLE_FREE,dhids(vx)
         mytype = create_struct('cdftype',cdftyp(vx)) ; create .cdftype structure
         mydata = create_struct('dat',data)           ; create .dat structure
         mydata = create_struct(mytype,mydata)        ; append the structures
         mydata = create_struct(metadata,mydata)      ; append the metadata
         rick   = create_struct(vnames(vx),mydata)    ; create new structure
         burley = create_struct(burley,rick)          ; append the structures
      endelse
      burley = correct_varname(burley, vnames, vx)
   endfor
      
   ; Check for conditions where ISTP instrument may be off; data array length of
   ; 1 and equal to the fill value. If true set structure to -1 and return
   ; error and status messages
   ;TJK changed to ne 4/29/98  wvn=where(vn_sdat eq '',wcvn)
   ikill=0
   wvn=where(vn_sdat ne '',wcvn)
   if(wcvn ne 0) then begin
      for vi=0, wcvn-1 do begin
         if(vn_sdat(vi) ne '') then begin
            ;TJK - get the tag index in the burley structure for this variable name -
            ;can't use the variable names since they sometimes contain wierd 
            ;characters like "%" in equator-s
            ttags = tag_names(burley)
            ; RCJ 11/28/00 added line below. vn_sdat still had bad characters in
            ; the variable names and the search for var_type was failing.
            vn_sdat(vi) = replace_bad_chars(vn_sdat(vi), diff)
            tindex = strtrim(string(tagindex(vn_sdat(vi),ttags)),2) ;convert to string
            comm=execute('var_type=burley.('+tindex+').var_type')
            if(var_type eq 'data') then begin
               comm=execute('vfill=burley.('+tindex+').fillval')
               if(keyword_set(NODATASTRUCT)) then begin
                  comm=execute('temp=burley.('+tindex+').handle')
                  handle_value,temp,vdat 
               endif else comm=execute('vdat=burley.('+tindex+').dat')
               if(not comm) then print, 'ERROR=execute failed '
               ;TJK 4/17/98, added check for the datatype before doing
               ;the abs function test. If the data_type is byte, then the
               ;abs function cannot be applied, ie. under IDL 5.02 abs(255) is 1.
               data_size = size(vdat)
               data_type = data_size(n_elements(data_size)-2)
               ;TJK added logic to check if the data array size is still equal to
               ;just one value.  If so,then check the fill value, else get out.
               if(data_size(0) gt 1) then $
                  szck=data_size(1)/(data_size(data_size(0)+2)) else $
     	          szck=data_size(data_size(0)+2)
               if(data_size(0) eq 3) then  szck=data_size(data_size(0))
               if(szck eq 1) then begin  ;data array has single value in it.
                  if (data_type eq 1) then begin
                     ;print, 'detected a byte value'
                     if (vfill eq vdat(0)) then $
   	                ikill = write_fill(vn_sdat(vi), burley, tmp_str)
                  endif else begin 
                     if (data_type gt 1) then begin
                        ; RCJ 06/06/01 Commented this part out. Maybe we have to rethink
                        ; the way we handle these situations.
	                ;;print, 'detected a non byte value'
                        ;if (abs(vfill) eq abs(vdat(0))) then $
	                ;   ikill = write_fill(vn_sdat(vi), burley, tmp_str)
                     endif ;datatype isn't byte (is gt 1)
                  endelse
               endif else begin
                     ; RCJ 05/01 commented this part out. We don't want to set ikill=1 if at least 
                     ; one of the variables has good data. 
	             ;if (data_size(0) eq 1) then begin
	             ;   fidx = where(vfill eq vdat, fcnt)
	             ;   if (fcnt eq n_elements(vdat)) then begin
                     ;     ;print, 'Found single record vector w/ all fill values'
                     ;     ;print, 'Setting fill message for variable',vn_sdat(vi)
	             ;     ikill = write_fill(vn_sdat(vi), burley, tmp_str)
	             ;   endif
	             ;endif
               endelse
            endif
         endif
      endfor
   endif  
endif else begin ;TJK added check for no varibles to retrieve
   ;get some metadata out of the 1st CDF or Master CDF
   v_err = 'ERROR=Variable(s) not available for specified time range.'
   v_stat='STATUS=Variable(s) not available for specified time range. Re-select a different time range.'
   slash = rstrpos(cnames(0),'/')
   d_set = strmid(cnames(0), slash+1, 9)
   d_set = 'DATASET='+strupcase(d_set)
   tmp_str=create_struct('DATASET',d_set,'ERROR',v_err,'STATUS',v_stat)
   ikill=1
endelse

if(ikill) then return, tmp_str
!quiet = quiet_flag ; restore
; Return successfull

if (keyword_set(DEBUG)) then begin
   print, 'num_virs',num_virs 
   help, burley
endif

;TJK add check in orig_names array for any variable name that might have
;bad characters in it.  Compare w/ what's been stored in the table structure.
print, 'orig_names before checking ',orig_names
for i = 0, n_elements(orig_names)-1 do begin
   found = where(orig_names(i) eq table.varname, found_cnt)
   if (found_cnt eq 1) then orig_names(i) = table.equiv(found(0))
endfor
print, 'orig_names after checking ',orig_names
;TJK add system time check to determine how long our virtual variables
;take to generate.

ttime = systime(1)
for i = 0, num_virs do begin
   vtags = tag_names(burley)
   vindex = tagindex(vir_vars.name(i), vtags) ; find the VV index number
   if (vindex(0) ge 0) then begin
      vartags = tag_names(burley.(vindex))
      findex = tagindex('FUNCTION', vartags) ; find the FUNCTION index number
      if (findex(0) ne -1) then begin ;found a virtual value w/ a function definition
         if keyword_set(DEBUG) then print,'VV function being called ',$
            strlowcase(burley.(vindex).(findex)), 'for variable ',vir_vars.name(i)
         case (strlowcase(burley.(vindex).(findex))) of
;         'crop_image': begin
;                          burley=crop_image(temporary(burley),orig_names,index=vindex)
;   		       end   
         'alternate_view': begin
                              burley = alternate_view(temporary(burley),orig_names)
                           end
;         'conv_pos': begin
;                        burley = conv_pos(temporary(burley),orig_names,$
;                           tstart=start_time, tstop=stop_time)
;                     end
;         'conv_pos1': begin
;                         burley = conv_pos(temporary(burley),orig_names,$
;                            tstart=start_time, tstop=stop_time, $
;                            COORD="ANG-GSE",INDEX=vindex)
;                      end
;         'conv_pos2': begin
;                         burley = conv_pos(temporary(burley),orig_names,$
;                            tstart=start_time, tstop=stop_time, $
;                            COORD="SYN-GEO",INDEX=vindex)
;                      end
         'conv_map_image': begin
                              burley = conv_map_image(temporary(burley),orig_names)
                           end
;         'calc_p': begin
;                      burley = calc_p(temporary(burley),orig_names,INDEX=vindex)
;                   end
         'create_vis': begin
                          burley = create_vis(temporary(burley),orig_names)
                       end
         'create_plain_vis': begin
                                burley = create_plain_vis(temporary(burley),orig_names)
                             end
         'create_plmap_vis': begin
                                burley = create_plmap_vis(temporary(burley),orig_names)
                             end
         'apply_qflag': begin
                           burley = apply_qflag(temporary(burley),orig_names,index=vindex)
                        end
         'convert_log10': begin
                             burley = convert_log10(temporary(burley),orig_names)
                          end
;         'add_51s': begin
;                       burley = Add_51s(temporary(burley),orig_names,index=vindex)
;                    end
;         'compute_magnitude': begin
;                       burley = compute_magnitude(temporary(burley),orig_names,index=vindex)
;                    end

         else : print, 'WARNING= No function for:', vtags(vindex)
         endcase
      endif ;if function defined for this virtual variable    
   endif ;found the tag index for this virtual variable
endfor ; for number of virtual variables
print, 'read_myCDF took ',systime(1)-ttime, ' seconds to generate VVs.'

;Add a check for variables that have var_type of data, but that the user didn't request.
;This has just recently become an issue because we want to allow plotting of variables
;that are defined as depends for other variables, e.g. ge_k0_epi.  TJK 11/22/2000
var_stat = 0

;TJK 1/26/01 - add if statement because if one of the virtual variable 
;functions has trouble running (doesn't find any data), burley will be
; equal to -1, then check_myvartype fails...  so basically check to see
;if burley is a structure, by asking how many tags it has, if its not a
;structure, n_tags returns 0

if (n_tags(burley) ne 0) then begin
   var_stat = check_myvartype(burley, orig_names)
   if (var_stat ne 0) then print, 'READ_MYCDF, no data to plot/list.'
endif
 
Return, burley
end
