;+
; NAME:
;     MWRFITS
; PURPOSE:
;     Write all standard FITS data types from input arrays or structures.
;
; CALLING SEQUENCE:
;     MWRFITS, Input, Filename, [Header],
;                       /LSCALE , /ISCALE, /BSCALE, 
;                       /USE_COLNUM, /Silent, /Create, /Version
;                       /ASCII, Separator=, Terminator=, Null=,
;                       Group=, Pscale=, Pzero=
;
; INPUTS:
;       Input = Array or structure to be written to FITS file.
;
;               -When writing FITS primary data or image extensions
;                input should be an array.
;               --If data is to be grouped
;                 the Group keyword should be specified to point to
;                 a two dimensional array.  The first dimension of the
;                 Group array will be PCOUNT while the second dimension
;                 should be the same as the last dimension of Input.
;               --If Input is undefined, then a dummy primary dataset
;                 or Image extension is created [This might be done, e.g.,
;                 to put appropriate keywords in a dummy primary
;                 HDU].
;
;               -When writing an ASCII table extension, Input should
;                be a structure where no element is a structure or
;                array (except see below).
;               --A byte array will be written as A field.  No checking
;                 is done to ensure that the values in the byte field
;                 are valid ASCII.
;               --Complex numbers are written to two columns with '_R' and
;                 '_I' appended to the TTYPE fields (if present).  The
;                 complex number is enclosed in square brackets in the output.
;               --Strings are written to fields with the length adjusted
;                 to accommodate the largest string.  Shorter strings are
;                 blank padded to the right.
;
;               -When writing a binary table extension, the input should
;                be a structure with no element being a substructure.
;
;               If a structure is specified on input and the output
;               file does not exist or the /CREATE keyword is specified
;               a dummy primary HDU is created.
;
;       Filename = String containing the name of the file to be written.
;                By default MWRFITS appends a new extension to existing
;                files which are assumed to be valid FITS.  The /CREATE
;                keyword can be used to ensure that a new FITS file
;                is created even if the file already exists.
;
; OUTPUTS:
;
; OPTIONAL INPUTS:
;       Header = Header should be a string array.  Each element of the
;                array is added as a row in the FITS  header.  No
;                parsing is done of this data.  MWRFITS will prepend
;                required structural (and, if specified, scaling)
;                keywords before the rows specified in Header.
;                Rows describing columns in the table will be appended
;                to the contents of Header.
;                Header lines will be extended or truncated to
;                80 characters as necessary.
;                If Header is specified then on return Header will have
;                the header generated for the specified extension.
;
; OPTIONAL INPUT KEYWORDS:
;       ASCII  - Creates an ASCII table rather than a binary table.
;                This keyword may be specified as:
;                /ASCII - Use default formats for columns.
;                ASCII='format_string' allows the user to specify
;                  the format of various data types such using the following
;                  syntax 'column_type:format, column_type:format'.  E.g.,
;                ASCII='A:A1,I:I6,L:I10,B:I4,F:E12.6,D:E21.15,C:E12.6,M:E21.15'
;                gives the default formats used for each type.
;                Note that the length of the field for ASCII strings and
;                byte arrays is automatically determined for each column.
;       Separator= This keyword can be specified as a string which will
;                be used to separate fields in ASCII tables.  By default
;                fields are separated by a blank.
;       Terminator= This keyword can be specified to provide a string which
;                will be placed at the end of each row of an ASCII table.
;                No terminator is given when not specified.  Note that
;                a newline character may be specified.
;       NULL=    Value to be written for integers/strings which are
;                undefined or unwritable.
;       CREATE   If this keyword is non-zero, then a new FITS file will
;                be created regardless of whether the file currently
;                exists.  Otherwise when the file already exists,
;                a FITS extension will be appended to the existing file
;                which is assumed to be a valid FITS file.
;       GROUP=   This keyword indicates that GROUPed FITS data is to
;                be generated.
;                Group should be a 2-D array of the appropriate output type.
;                The first dimension will set the number of group parameters.
;                The second dimension must agree with the last dimension
;                of the Input array.
;       PSCALE=  An array giving scaling parameters for the group keywords.
;                It should have the same dimension as the first dimension
;                of Group.
;       PZERO=   An array giving offset parameters for the group keywords.
;                It should have the same dimension as the first dimension
;                of Group.
;       LSCALE   Scale floating point numbers to long integers.
;                This keyword may be specified in three ways.
;                /LSCALE (or LSCALE=1) asks for scaling to be automatically
;                determined. LSCALE=value divides the input by value.
;                I.e., BSCALE=value, BZERO=0.  Numbers out of range are 
;                given the value of NULL if specified, otherwise they are given
;                the appropriate extremum value.  LSCALE=(value,value)
;                uses the first value as BSCALE and the second as BZERO
;                (or TSCALE and TZERO for tables).
;       ISCALE   Scale floats or longs to short integers.
;       BSCALE   Scale floats, longs, or shorts to unsigned bytes.
;       LOGICAL_COLS=  An array of indices of the logical column numbers.
;                These should start with the first column having index 0.
;                The structure element should be an array of characters
;                with the values 'T' or 'F'.  This is not checked.
;       BIT_COLS=   An array of indices of the bit columns.   The data should
;                comprise a byte array with the appropriate dimensions.
;                If the number of bits per row (see next argument)
;                is greater than 8, then the first dimension of the 
;                is assumed to give the number of input bytes per row.
;       NBIT_COLS=  The number of bits actually used in the bit array.
;                This argument must point to an array of the same dimension
;                as BIT_COLS.
;       SILENT   Suppress informative messages.  Errors will still
;                be reported.
;       Version   Print the version number of MWRFITS.
;       USE_COLNUM  When creating column names for binary and ASCII tables
;                MWRFITS attempts to use structure field name
;                values.  If USE_COLNUM is specified and non-zero then
;                column names will be generated as 'C1, C2, ... 'Cn'
;                for the number of columns in the table.
;       NO_TYPES  If the NO_TYPES keyword is specified, then no TTYPE
;                keywords will be created for ASCII and BINARY tables.
;
; EXAMPLE:
;       Write a simple array:
;            a=fltarr(20,20)
;            mwrfits,a,'test.fits'
;
;       Append a 3 column, 1 row, binary table extension to file just created.
;            a={name:'M31', coords:(30., 20.), distance:2}
;            mwrfits,a,'test.fits'
;
;       Now add on an image extension:
;            a=lonarr(10,10,10)
;            hdr=("COMMENT  This is a comment line to put in the header", $
;                 "MYKEY    = "Some desired keyword value")
;            mwrfits,a,'test.fits',hdr

;
; RESTRICTIONS:
;       (1)     Limited to 127 columns in tables by IDL structure limits.
;       (2)     String columns with all columns of zero length crash the
;               program
; NOTES:
;       This multiple format FITS writer is designed to provide a
;       single, simple interface to writing all common types of FITS data.
;       Given the number of options within the program and the
;       variety of IDL systems available it is likely that a number
;       of bugs are yet to be uncovered.  If you find an anomaly
;       please send a report to:
;           Tom McGlynn
;           NASA/GSFC Code 660.2
;           tam@silk.gsfc.nasa.gov (or 301-286-7743)
;
; PROCEDURES USED:
;       FXPAR(), FXADDPAR, IS_IEEE_BIG(), HOST_TO_IEEE
; MODIfICATION HISTORY:
;   Version 0.9: By T. McGlynn   1997-07-23
;      Initial beta release.
;	Converted to IDL V5.0   W. Landsman   September 1997
;	Dec 1, 1997, Lindler, Modified to work under VMS.
;	Version 0.91: T. McGlynn  1998-03-09
;	Fixed problem in handling null primary arrays.
;-
pro mwr_ascii, input, siz, lun, bof, header,     $
        ascii=ascii,                             $
	null=null,                               $
	use_colnum = use_colnum,                 $
	lscale=lscale, iscale=iscale,		 $
	bscale=bscale,                           $
	no_types=no_ttypes,			 $
	separator=separator,                     $
	terminator=terminator,                   $
	silent=silent
	
; Write the header and data for a FITS ASCII table extension.
  
types=  ['A',   'I',   'L',   'B',   'F',    'D',      'C',     'M']
formats=['A1',  'I6',  'I10', 'I4',  'E12.6','E21.15', 'E12.6', 'E21.15']
lengths=[1,     6,     10,     4,    12,     21,       12,      21]

; Check if the user is overriding any default formats.
sz = size(ascii)

if sz[0] eq 0 and sz[1] eq 7 then begin
    ascii = strupcase(strcompress(ascii,/remo))
    for i=0, n_elements(types)-1  do begin
        p = strpos(ascii,types[i]+':')
        if p ge 0 then begin

	    q = strpos(ascii, ',', p+1)
	    if q lt p then q = strlen(ascii)+1
	    formats[i] = strmid(ascii, p+2, (q-p)-2)
	    len = 0
	    
	    reads, formats[i], len, format='(1X,I)'
	    lengths[i] = len
        endif
    endfor
endif

i0 = input[0]
ntag = n_tags(i0)
tags = tag_names(i0)
truform = strarr(ntag)
ctypes = lonarr(ntag)
strmaxs = lonarr(ntag)
if not keyword_set(separator) then separator=' '

slen = strlen(separator)

offsets = 0
tforms = ''
ttypes = ''
offset = 0

for i=0, ntag-1 do begin
    sz = size(i0.(i))
    if sz[0] ne 0 and (sz[sz[0]+1] ne 1) then begin
        print, 'MWRFITS Error: ASCII table cannot contain arrays'
	return
    endif

    ctypes[i] = sz[1]
    
    if sz[0] gt 0 then begin
        ; Byte array to be handled as a string.
	nelem = sz[sz[0]+2]
	ctypes[i] = sz[sz[0]+1]
        tf = 'A'+strcompress(string(nelem))
        tforms = [tforms, tf]
	ttypes = [ttypes, tags[i]+' ']
	offsets = [offsets, offset]
        truform[i] = '('+tf+')'
	offset = offset + nelem
    endif else if sz[1] eq 7 then begin
        ; Use longest string to get appropriate size.
	strmax = max(strlen(input.(i)))
	strmaxs[i] = strmax
	tf = 'A'+strcompress(string(strmax))
	tforms = [tforms, tf]
	offsets = [offsets, offset]
	ttypes = [ttypes, tags[i]+' ']
        truform[i] = '('+tf+')'
	ctypes[i] = 7
	offset = offset + strmax
    endif else if sz[1] eq 6  or sz[1] eq 9 then begin
        ; Complexes handled as two floats.
	offset = offset + 1
	
	if sz[1] eq 6 then indx = where(types eq 'C')
	if sz[1] eq 9 then indx = where(types eq 'M')
	indx = indx[0]
	tforms = [tforms, formats[indx], formats[indx]]
	offsets = [offsets, offset, offset+lengths[indx]+1]
	ttypes = [ttypes, tags[i]+'_R', tags[i]+'_I']
	offset = offset + 2*lengths[indx] + 1

        truform[i] = '("[",'+formats[indx]+',1x,'+formats[indx]+',"]")'
	offset = offset+1
    endif else begin
        if sz[1] eq 1 then indx = where(types eq 'B')     $
	else if sz[1] eq 2 then indx = where(types eq 'I') $
	else if sz[1] eq 3 then indx = where(types eq 'L') $
	else if sz[1] eq 4 then indx = where(types eq 'F') $
	else if sz[1] eq 5 then indx = where(types eq 'D') $
	else begin
	    print, 'MWRFITS Error: Invalid type in ASCII table'
	    return
	endelse
	
	indx = indx[0]
	tforms = [tforms, formats[indx]]
	ttypes = [ttypes, tags[i]+' ']
	offsets = [offsets, offset]
        truform[i] = '('+formats[indx]+')'
	offset = offset + lengths[indx]
    endelse
    if i ne ntag-1 then begin
        offset = offset + slen
    endif
endfor

if keyword_set(terminator) then offset = offset+strlen(terminator)
; Write required FITS keywords.

fxaddpar, header, 'XTENSION', 'TABLE', 'ASCII table extension written by MWRFITS'
fxaddpar, header, 'BITPIX', 8,'Required Value: ASCII characters'
fxaddpar, header, 'NAXIS', 2,'Required Value'
fxaddpar, header, 'NAXIS1', offset, 'Number of characters in a row'
fxaddpar, header, 'NAXIS2', n_elements(input), 'Number of rows'
fxaddpar, header, 'PCOUNT', 0, 'Required value'
fxaddpar, header, 'GCOUNT', 1, 'Required value'
fxaddpar, header, 'TFIELDS', n_elements(ttypes)-1, 'Number of fields'

; Recall that the TTYPES, TFORMS, and OFFSETS arrays have an
; initial dummy element.

; Write the TTYPE keywords.
if not keyword_set(no_types) then begin
    for i=1, n_elements(ttypes)-1 do begin
        key = 'TTYPE'+ strcompress(string(i),/remo)
        if keyword_set(use_colnum) then begin
	    value = 'C'+strcompress(string(i),/remo)
	endif else begin
	    value = ttypes[i]+' '
	endelse
	fxaddpar, header, key, value
    endfor
    
    fxaddpar, header, 'COMMENT', ' ', before='TTYPE1'
    fxaddpar, header, 'COMMENT', ' *** Column names ***', before='TTYPE1'
    fxaddpar, header, 'COMMENT', ' ', before='TTYPE1'
    
endif

; Write the TBCOL keywords.

for i=1, n_elements(ttypes)-1 do begin
    key= 'TBCOL'+strcompress(string(i),/remo)
    fxaddpar, header, key, offsets[i]+1
endfor

fxaddpar, header, 'COMMENT', ' ', before='TBCOL1'
fxaddpar, header, 'COMMENT', ' *** Column offsets ***', before='TBCOL1'
fxaddpar, header, 'COMMENT', ' ', before='TBCOL1'

; Write the TFORM keywords

for i=1, n_elements(ttypes)-1 do begin
    key= 'TFORM'+strcompress(string(i),/remo)
    fxaddpar, header, key, tforms[i]
endfor

fxaddpar, header, 'COMMENT', ' ', before='TFORM1'
fxaddpar, header, 'COMMENT', ' *** Column formats ***', before='TFORM1'
fxaddpar, header, 'COMMENT', ' ', before='TFORM1'

; Write the header.

mwr_header, lun, header

; Now loop over the structure and write out the data.
; We'll write one row at a time.

for i=0, n_elements(input)-1 do begin

    str = ''
    
    for j=0, ntag-1 do begin

        if ctypes[j] eq 1 then begin
            str = str + string(input[i].(j), format=truform[j])
	endif else if ctypes[j] eq 7 then begin
	    str = str + input[i].(j)
	    len = strlen(input[i].(j))
	    if len ne strmaxs[j] then begin
	        str = str + string(replicate(32b, strmaxs[j]-len))
	    endif
	    
	endif else begin
	    str = str + string(input[i].(j), format=truform[j])
	endelse
	
	if j ne ntag - 1 then str = str + separator
     endfor

     if keyword_set(terminator) then str = str+terminator
     ; Write the row.
     writeu, lun, str
     
endfor

; Check to see if any padding is required.

nbytes = n_elements(input)*offset
padding = 2880 - nbytes mod 2880

if padding ne 0 then begin
    pad = replicate(32b, padding)
endif
writeu, lun, pad

return
end

pro mwr_dummy, lun

; Write a dummy primary header-data unit.

fxaddpar, header, 'SIMPLE', 'T','Dummy Created by MWRFITS'
fxaddpar, header, 'BITPIX', 8, 'Dummy primary header created by MWRFITS'
fxaddpar, header, 'NAXIS', 0, 'No data is associated with this header'
fxaddpar, header, 'EXTEND', 'T', 'Extensions may (will!) be present'

mwr_header, lun, header
end

pro mwr_tablehdr, lun, input, header,    $
		no_types=no_types,                $
		logical_cols = logical_cols,	  $
		bit_cols = bit_cols,		  $
		nbit_cols= nbit_cols,             $
		silent=silent

;  Create and write the header for a binary table.

if not keyword_set(no_types) then no_types = 0

nfld = n_tags(input[0])
if nfld le 0 then begin
	print, 'MWRFITS Error: Input contains no structure fields.'
	return
endif

tags = tag_names(input)

; Get the number of rows in the table.

nrow = n_elements(input)

dims = lonarr(nfld)
tdims = strarr(nfld)
types = strarr(nfld)

;
; Get the type and length of each column.  We do this
; by examining the contents of the first row of the structure.
;

nbyte = 0

for i=0, nfld-1 do begin

	a = input[0].(i)

	sz = size(a)
	
	nelem = sz[sz[0]+2]
	type_ele = sz[sz[0]+1]
	if type_ele eq 7 then begin
	    maxstr = max(strlen(input.(i)))
	endif
	
	dims[i] = nelem
	
        if (sz[0] lt 1) or (sz[0] eq 1 and type_ele ne 7) then begin
	    tdims[i] = ''
	endif else begin
	    tdims[i] = '('
	    
	    if type_ele eq 7 then begin
	        tdims[i] = tdims[i] + strcompress(string(maxstr), /remo) + ','
	    endif
	    
	    for j=1, sz[0] do begin
	        tdims[i] = tdims[i] + strcompress(sz[j])
	        if j ne sz[0] then tdims[i] = tdims[i] + ','
	    endfor
	    tdims[i] = tdims[i] + ')'
	endelse
	
	
	case type_ele of
	   1: 	begin
			types[i] = 'B'
			nbyte = nbyte + nelem
		end
	   2:	begin
	    		types[i] = 'I'
			nbyte = nbyte + 2*nelem
		end
	   3:	begin
			types[i] = 'J'
			nbyte = nbyte + 4*nelem
		end
	   4:	begin
	   		types[i] = 'E'
			nbyte = nbyte + 4*nelem
	        end
	   5:	begin
			types[i] = 'D'
			nbyte = nbyte + 8*nelem
		endif
	   6:	begin
	   		types[i] = 'C'
			nbyte = nbyte + 8*nelem
		end
	   7:	begin
			types[i] = 'A'
			nbyte = nbyte + maxstr*nelem
			dims[i] = maxstr*nelem
		endif
	   9:   begin
	                types[i] = 'M'
			nbyte = nbyte + 16*nelem
		end
	   0:   begin
	   		print,'MWRFITS Error: Undefined structure element??'
			return
		end
	   8:   begin
	   		print, 'MWRFITS Error: Nested structures'
			return
		end
	   else:begin
	   		print, 'MWRFITS Error: Cannot parse structure'
			return
		end
	endcase
endfor

; Put in the required FITS keywords.
fxaddpar, header, 'XTENSION', 'BINTABLE', 'Binary table written by MWRFITS'
fxaddpar, header, 'BITPIX', 8, 'Required value'
fxaddpar, header, 'NAXIS', 2, 'Required value'
fxaddpar, header, 'NAXIS1', nbyte, 'Number of bytes per row'
fxaddpar, header, 'NAXIS2', n_elements(input), 'Number of rows'
fxaddpar, header, 'PCOUNT', 0, 'Normally 0 (no varying arrays)'
fxaddpar, header, 'GCOUNT', 1, 'Required value'
fxaddpar, header, 'TFIELDS', nfld, 'Number of columns in table'
fxaddpar, header, 'COMMENT', ' ', after='TFIELDS'
fxaddpar, header, 'COMMENT', ' *** End of required fields ***', after='TFIELDS'
fxaddpar, header, 'COMMENT', ' ', after='TFIELDS'
;
; Handle the special cases.
;
if keyword_set(logical_cols) then begin
	nl = n_elements(logical_cols)
	for i = 0, nl-1 do begin
		icol = logical_cols[i]
		if types[icol-1] ne 'A'  then begin
			print,'WARNING: Invalid attempt to create Logical column:',icol
	      		goto, next_logical
		endif
		types[icol-1] = 'L'
next_logical:
	endfor
endif
	
if keyword_set(bit_cols) then begin
	nb = n_elements(bit_cols)
	if nb ne n_elements(nbit_cols) then begin
		print,'WARNING: Bit_cols and Nbit_cols not same size'
		print,'         No bit columns generated.'
		goto, after_bits
	endif
	for i = 0, nb-1 do begin
		nbyte = (nbit_cols[i]+7)/8
		icol = bit_cols[i]
		if types[icol-1] ne 'B'  or ((dims mod nbyte) ne 0) then begin
			print,'WARNING: Invalid attempt to create bit column:',icol
	      		goto, next_bit
		endif
		types[icol-1] = 'X'
		dims[icol-1] = dims[icol-1]/nbyte
		
		; Fix TDIM field if present.
		if nbyte gt 1 then begin
		    sz = size(input[0].(icol-1))
		    if sz[0] eq 2 then begin
		        tdims[icol-1] = ''
		    endif else begin
		        temp = tdims[icol-1]
			p=strpos(temp, ',')
			tdims[icod-1] = '(' + strmid(temp, p+1, 999)
		    endelse
		endif
	        
next_bit:
	endfor
after_bits:
endif

; First add in the TTYPE keywords if desired.
;
if not no_types then begin
	for i=0, nfld - 1 do begin
	    key = 'TTYPE'+strcompress(string(i+1),/remove)
	    if not keyword_set(use_colnums) then begin
	        value= tags[i]+' '
	    endif else begin
	        value = 'C'+strmid(key,5,2)
	    endelse
	    fxaddpar, header, key, value
	endfor
	fxaddpar, header, 'COMMENT', ' ', before='TTYPE1'
	fxaddpar, header, 'COMMENT', ' *** Column Names *** ',before='TTYPE1'
	fxaddpar, header, 'COMMENT', ' ',before='TTYPE1'
endif
; Now add in the TFORM keywords
for i=0, nfld-1 do begin
	if dims[i] eq 1 then begin
		form = types[i]
	endif else begin
		form=strcompress(string(dims[i]),/remove) + types[i]
        endelse
	
	tfld = 'TFORM'+strcompress(string(i+1),/remove)
	
	; Check to see if there is an existing value for this keyword.
	; If it has the proper value we will not modify it.
	; This can matter if there is optional information coded
	; beyond required TFORM information.
		
	oval = fxpar(header, tfld)
	oval = strcompress(string(oval),/remove_all)
	if (oval eq '0')  or  (strmid(oval, 0, strlen(form)) ne form) then begin
		fxaddpar, header, tfld, form
	endif
endfor

fxaddpar, header, 'COMMENT', ' ', before='TFORM1'
fxaddpar, header, 'COMMENT', ' *** Column formats ***', before='TFORM1'
fxaddpar, header, 'COMMENT', ' ', before='TFORM1'
; Now write TDIM info as needed.
firsttdim = -1
for i=0, nfld-1 do begin
    if tdims[i] ne '' then begin
        fxaddpar, header, 'TDIM'+strcompress(string(i+1),/remo), tdims[i]
    endif
    if firsttdim eq -1 then firsttdim = i
endfor

w=where(tdims ne '')
if w[0] ne -1 then begin
    fxaddpar, header, 'COMMENT', ' ',   $
        before='TDIM'+strcompress(string(firsttdim+1),/remo)
    fxaddpar, header, 'COMMENT', ' *** Column dimensions (2 D or greater) ***',  $
        before='TDIM'+strcompress(string(firsttdim+1),/remo)
    fxaddpar, header, 'COMMENT', ' ', $
        before='TDIM'+strcompress(string(firsttdim+1),/remo)
endif
; Write to the output device.
mwr_header, lun, header

end

pro mwr_tabledat, lun, input, header
;
;  Write binary table data to a FITS file.
;
; file		-- unit to which data is to be written.
; Input		-- IDL structure
; Header	-- Filled header

nfld = n_tags(input)

; Pad out strings to constant length.
for i=0, nfld-1 do begin
        
        sz = size(input.(i))
	nsz = n_elements(sz)
	typ = sz[nsz-2]
	if (typ eq 7) then begin

                siz = max(strlen(input.(i)))
		
		blanks = string(bytarr(siz) + 32b)
		input.(i) = strmid(input.(i)+blanks, 0, siz)

	 endif
endfor

; Use Astron library routine to convert to IEEE (since byteorder
; may be buggy).
if not is_ieee_big() then host_to_ieee, input

nbyte = long(fxpar(header, 'NAXIS1'))
nrow = long(fxpar(header, 'NAXIS2'))

siz = nbyte*nrow

padding = 2880 - (siz mod 2880)
if padding eq 2880 then padding = 0

;
; Write the data segment.
;
writeu, lun, input

; If necessary write the padding.
;
if padding gt 0 then begin
	pad = bytarr(padding)  ; Should be null-filled by default.
	writeu, lun, pad
endif

end


pro mwr_pscale, grp, header, pscale=pscale, pzero=pzero

; Scale parameters for GROUPed data.

; This function assumes group is a 2-d array.

if not keyword_set(pscale) and not keyword_set(pzero) then return

if not keyword_set(pscale) then begin
    pscale = dblarr(sizg[1])
    pscale[*] = 1.
endif

w = where(pzero eq 0.d0)

if w[0] ne 0 then begin
    print, 'MWRFITS  Warning: PSCALE value of 0 found, set to 1.'
    pscale[w] = 1.d0
endif

if keyword_set(pscale) then begin
    for i=0, sizg[1]-1 do begin
        key= 'PSCAL' + strcompress(string(i+1),/remo)
        fxaddpar, header, key, pscale[i]
    endfor
endif

if not keyword_set(pzero) then begin
    pzero = dblarr(sizg[1])
    pzero[*] = 0.
endif else begin
    for i=0, sizg[1]-1 do begin
        key= 'PZERO' + strcompress(string(i+1),/remo)
        fxaddpar, header, key, pscale[i]
    endfor
endelse

for i=0, sizg[1]-1 do begin
    grp[i,*] = grp[i,*]/pscale[i] - pzero[i]
endfor

end

pro mwr_findscale, flag, array, nbits, scale, offset, error

; Find the appropriate scaling parameters.

    error = 0
    if n_elements(flag) eq 2 then begin
         scale = double(flag[0])
	 offset = double(flag[1])
    endif else if n_elements(flag) eq 1 and flag[0] ne 1 then begin
         minmum = min(array, max=maxmum)
	 offset = 0.d0
	 scale = double(flag[0])
    endif else if n_elements(flag) ne 1 then begin
         print, 'MWRFITS Error: Invalid scaling parameters.'
	 error = 1
	 return
    endif else begin
         minmum = min(array, max=maxmum)
	 offset = minmum
	 scale = (maxmum-minmum)/(2.d0^nbits-1)
    endelse
    return
end

pro mwr_scale, array, scale, offset, lscale=lscale, iscale=iscale,  $
   bscale=bscale, null=null

; Scale and possibly convert array according to information
; in flags.

; First dereference scale and offset

if n_elements(scale) gt 0 then xx = temporary(scale)
if n_elements(offset) gt 0 then xx = temporary(offset)

if not keyword_set(lscale) and not keyword_set(iscale) and  $
   not keyword_set(bscale) then return

siz = size(array)
if keyword_set(lscale) then begin

    ; Doesn't make sense to scale data that can be stored exactly.
    if siz[siz[0]+1] lt 4 then return
    amin = -2.d0^31
    amin = -amax + 1
    
    mwr_findscale, lscale, array, 32, scale, offset, error
    
endif else if keyword_set(iscale) then begin
    if siz[siz[0]+1] lt 3 then return
    amax = -2.d0^15
    amin = -amax + 1
    
    mwr_findscale, iscale, array, 16, scale, offset, error

endif else begin
    if siz[siz[0]+1] lt 2 then return
    
    amin = 0
    amax = 255
    
    mwr_findscale, bscale, array, 8, scale, offset, error
endelse

; Check that there was no error in mwr_findscale
if error gt 0 then return

if scale le 0.d0 then begin
    print, 'MWRFITS Error: BSCALE/TSCAL=0'
    return
endif
array = array/scale - offset
w = where(array gt amax)
if w[0] ne -1 then begin
    if keyword_set(null) then array[w] = null else array[w]=amax
endif
w = where(array lt amin)
if w[0] ne -1 then begin
    if keyword_set(null) then array[w] = null else array[w] = amin
endif
if keyword_set(lscale) then array = long(array) $
else if keyword_set(iscale) then array = fix(array) $
else array = byte(array)
end

pro mwr_header, lun, header
;
; Write a header
;

; Fill strings to at least 80 characters and then truncate.

space = string(replicate(32b, 80))
header = strmid(header+space, 0, 80)

w = where(strmid(header,0,8) eq "END     ")

if w[0] eq -1 then begin

	header = [header, strmid("END"+space,0,80)]
	
endif else begin
        if (n_elements(w) gt 1) then begin 
	    ; Get rid of extra end keywords;
	    print,"MWRFITS Warning: multiple END keywords found.'
	    for irec=0, n_elements(w)-2 do begin
		header[w[irec]] = strmid('COMMENT INVALID END REPLACED'+  $
		  space, 0, 80)
	    endfor
	endif

	; Truncate header array at END keyword.
	header = header[0:w[n_elements(w)-1]]
endelse

nrec = n_elements(header)
if nrec mod 36 ne 0 then header = [header, replicate(space,36 - nrec mod 36)]

writeu, lun, byte(header)
end


pro mwr_groupinfix, data, group, hdr
  
;
; Move the group information within the data.
;

siz = size(data)
sizg = size(group)

; Check if group info is same type as data 

if siz[siz[0]+1] ne sizg[3] then begin
    case siz[siz[0]+1] of
      1: begin
	  mwr_groupscale, 127.d0, group, hdr
	  group = byte(group)
	 end
      2: begin
	  mwr_groupscale, 32767.d0, group, hdr
	  group = fix(group)
	 end
      3: begin
	  mwr_groupscale, 2147483647.d0, group, hdr
	  group = long(group)
	 end
      4: group = float(group)
      5: group = double(group)
    else: begin
        print,'MWRFITS Internal error: Conversion of group data'
	return
    end
    endcase
endif

nrow = 1
for i=1, siz[0]-1 do begin
    nrow = nrow*siz[i]
endfor

data = reform(data, siz[siz[0]+2])
for i=0, siz[siz[0]] - 1 do begin
    if i eq 0 then begin
        gdata = group[*,0]
	gdata = reform(gdata)
        tdata = [ gdata , data[0:nrow-1]]
    endif else begin
        start = nrow*i
	fin = start+nrow-1
	gdata = group[*,i]
        tdata = [tdata, gdata ,data[start:fin]]
    endelse
endfor
data = temporary(tdata)
end

pro mwr_groupscale, maxval, group, hdr
; If an array is being scaled to integer type, then
; check to see if the group parameters will exceed the maximum
; values allowed.  If so scale them and update the header.

sz = size(group)
for i=0, sz[1]-1 do begin
     pmax = max(abs(group[i,*]))
     if (pmax gt maxval) then begin
         ratio = pmax/maxval
	 psc = 'PSCAL'+strcompress(string(i+1),/remo)
	 currat = fxpar(hdr, psc)
	 if (currat ne 0) then begin
	     fxaddpar, hdr, psc, currat*ratio, 'Scaling overriden by MWRFITS'
	 endif else begin
	     fxaddpar, hdr, psc, ratio, ' Scaling added by MWRFITS'
	 endelse
         group[i,*] = group[i,*]/ratio
     endif
endfor
end
	 
	 
pro mwr_image, input, siz, lun, bof, hdr,       $
	null=null,                              $
	group=group,                            $
	pscale=pscale, pzero=pzero,             $
	lscale=lscale, iscale=iscale,		$
	bscale=bscale,                          $
	silent=silent

; Write out header and image for IMAGE extensions and primary arrays.

bitpixes=[8,8,16,32,-32,-64,-32,0,0,-64]
; Convert complexes to two element real array.
if siz[siz[0]+1] eq 6 or siz[siz[0]+1] eq 9 then begin

    if not keyword_set(silent) then begin
       print, "MWRFITS Note: Complex numbers treated as arrays"
    endif
    
    array_dimen=(2)
    if siz[0] gt 0 then array_dimen=[array_dimen, siz[1:siz[0]]] 
    if siz[siz[0]+1] eq 6 then data = float(input,0,array_dimen)  $
    else data = double(input,0,array_dimen)

; Convert strings to bytes.
endif else if siz[siz[0]+1] eq 7 then begin
    data = input
    len = max(strlen(input))
    if len eq 0 then begin
        print, 'MWRFITS Error: strings all have zero length'
	return
    endif
    for i=0, n_elements(input)-1 do begin
        t = len - strlen(input[i])
	if t gt 0 then input[i] = input[i] + string(replicate(32B, len))
    endfor
    
    ; Note that byte operation works on strings in a special way
    ; so we don't go through the subterfuge we tried above.
    
    data = byte(data)
    
endif else if n_elements(input) gt 0 then data = input

; Convert scalar to 1-d array.
if siz[0] eq 0 and siz[1] ne 0 then data=(data)

; Do any scaling of the data.
mwr_scale, data, scalval, offsetval, lscale=lscale, $
  iscale=iscale, bscale=bscale, null=null

siz = size(data)
; If grouped data scale the group parameters.
if keyword_set(group) then mwr_pscale, group, hdr, pscale=pscale, pzero=pzero

if bof then begin
    fxaddpar, hdr, 'SIMPLE', 'T','Primary Header created by MWRFITS'
endif else begin
    fxaddpar, hdr, 'XTENSION', 'IMAGE','Image Extension created by MWRFITS'
endelse


if keyword_set(group) then begin
    group_offset = 1
endif else group_offset = 0

fxaddpar, hdr, 'BITPIX', bitpixes[siz[siz[0]+1]]
fxaddpar, hdr, 'NAXIS', siz[0]
if keyword_set(group) then begin
    fxaddpar, hdr, 'NAXIS1', 0
endif

for i=1, siz[0]-group_offset do begin
    fxaddpar, hdr, 'NAXIS'+strcompress(string(i+group_offset),/remo), siz[i]
endfor


if keyword_set(group) then begin
    fxaddpar, hdr, 'GROUPS', 'T'
    sizg = size(group)
    if sizg[0] ne 2 then begin
        print,'MWRFITS Error: Group data is not 2-d array'
	return
    endif
    if sizg[2] ne siz[siz[0]] then begin
        print,'MWRFITS Error: Group data has wrong number of rows'
	return
    endif
    fxaddpar,hdr, 'PCOUNT', sizg[1]
    fxaddpar, hdr, 'GCOUNT', siz[siz[0]]
endif
    
if n_elements(scalval) gt 0 then begin
    fxaddpar, hdr, 'BSCALE', scalval
    fxaddpar, hdr, 'BZERO', offsetval
endif

if keyword_set(group) then begin
    if keyword_set(pscale) then begin
        if n_elements(pscale) ne sizg[1] then begin
	    print, 'MWRFITS Warning: wrong number of PSCALE values'
	endif else begin
            for i=1, sizg[1] do begin
                fxaddpar, hdr, 'PSCALE'+strcompress(string(i),/remo)
	    endfor
	endelse
    endif
    if keyword_set(pzero) then begin
        if n_elements(pscale) ne sizg[1] then begin
	    print, 'MWRFITS Warning: Wrong number of PSCALE values'
	endif else begin
            for i=1, sizg[1] do begin
                fxaddpar, hdr, 'PZERO'+strcompress(string(i),/remo)
	    endfor
	endelse
    endif
endif

bytpix=abs(bitpixes[siz[siz[0]+1]])/8             ; Number of bytes per pixel.
npixel = n_elements(data) + n_elements(group)     ; Number of pixels.

if keyword_set(group) then mwr_groupinfix, data, group, hdr

; Write the FITS header
mwr_header, lun, hdr

; This is all we need to do if input is undefined.
if (n_elements(input) eq 0) or (siz[0] eq 0) then return

; Write the data.
host_to_ieee, data
writeu, lun, data

nbytes = bytpix*npixel
filler = 2880 - nbytes mod 2880
if filler eq 2880 then filler = 0

; Write any needed filler.
if filler gt 0 then writeu, lun, replicate(0B,filler)
end



pro mwrfits, xinput, file, header,              $
        ascii=ascii,                            $
	separator=separator,                    $
	terminator=terminator,                  $
	create=create,                          $
	null=null,                              $
	group=group,                            $
	pscale=pscale, pzero=pzero,             $
	use_colnum = use_colnum,                $
	lscale=lscale, iscale=iscale,		$
	bscale=bscale,                          $
	no_types=no_types,                      $
	silent=silent,                          $
	version=version


; Check required keywords.

if (keyword_set(Version)) then begin
    print, "MWRFITS V0.91:  1998-03-02"
endif

if n_elements(file) eq 0 then begin
    if (not keyword_set(Version)) then begin
        print, 'MWRFITS: Usage:'
        print, '    MWRFITS, struct_name, file, [header,] '
        print, '             /CREATE, /SILENT, /NO_TYPES, '
        print, '             GROUP=, PSCALE=, PZERO=,'
        print, '             LSCALE=, ISCALE=, BSCALE=,'
        print, '             LOGICAL_COLS=, BIT_COLS=, NBIT_COLS=,'
        print, '             ASCII=, SEPARATOR=, TERMINATOR=, NULL='
    endif
    return
endif


; Save the data into an array/structure that we can modify.

if n_elements(xinput) gt 0 then input = xinput

on_ioerror, open_error

; Open the input file.

found= findfile(file, count=count)
if  count eq 0 or keyword_set(create) then begin
    if !version.os eq 'vms' then openw,lun,file,2880,/block,/none,/get_lun $
                            else openw, lun, file, /get_lun
    bof = 1 
endif else begin
    openu, lun, file, /get_lun, /append
    bof = 0
endelse
    

siz = size(input)
if siz[siz[0]+1] ne 8 then begin

    ; If input is not a structure then call image writing utilities.
    mwr_image, input, siz, lun, bof, header,    $
	null=null,                              $
	group=group,                            $
	pscale=pscale, pzero=pzero,             $
	lscale=lscale, iscale=iscale,		$
	bscale=bscale,                          $
	silent=silent

endif else if keyword_set(ascii) then begin

    if bof then mwr_dummy, lun
    ; Create an ASCII table.
    mwr_ascii, input, siz, lun, bof, header,     $
        ascii=ascii,                             $
	null=null,                               $
	use_colnum = use_colnum,                 $
	lscale=lscale, iscale=iscale,		 $
	bscale=bscale,                           $
	no_types=no_types,			 $
	separator=separator,                     $
	terminator=terminator,                   $
	silent=silent

endif else begin

    if bof then mwr_dummy, lun

    ; Create a binary table.
    mwr_tablehdr, lun, input, header,    $
		no_types=no_types,                $
		logical_cols = logical_cols,	  $
		bit_cols = bit_cols,		  $
		nbit_cols= nbit_cols
    mwr_tabledat, lun, input, header

endelse

free_lun, lun
return
    

; Handle error in opening file.
open_error:
on_ioerror, null
print, 'MWRFITS Error: Cannot open output: ', file
if n_elements(lun) gt 0 then free_lun, lun

return
end

