Pro sxmake, unit, File, Data, Par, Groups, Header
;+
; NAME:
;	SXMAKE
; PURPOSE:
;	Create a basic ST header file from an IDL array prior to writing data.
;
; CALLING SEQUENCE:
;	sxmake, Unit, File, Data, Par, Groups, Header
;
; INPUTS:
;	Unit = Logical unit number from 1 to 9.
;	File = file name of data and header files to
;		create.  The filetype extension must not appear
;		in this name.  The header file is created with the
;		extension 'HHH' and the data file has 'HHD'.
;	Data = IDL data array of the same type, dimensions and
;		size as are to be written to file.
;	Par = # of elements in each parameter block for each
;		data record.  If = to 0, parameter blocks will
;		not be written.  The data type of the parameter
;		blocks must be the same as the data array.
;	Groups = # of groups to write.  If 0 then write in basic
;		format without groups.	
;
; OPTIONAL INPUT PARAMETERS:
;	Header = String array containing ST header file.  If this
;		parameter is omitted, a basic header is constructed.
;		If included, the basic parameters are added to the
;		header using sxaddpar.  The END keyword must terminate
;		the parameters in Header.
;
; OPTIONAL OUTPUT PARAMETERS:
;	Header = ST header array, an 80 by N character array.
;
; COMMON BLOCKS:
;	Stcommn - as used in sxwrite, sxopen, etc.
;
; SIDE EFFECTS:
;	The header file is created and written and then the
;	data file is opened on the designated unit.
;
; RESTRICTIONS:
;	Header files must be named .HHH and data files must be
;	named .HHD.
;
; PROCEDURE:
;	Call sxmake to create a header file.  Then call sxwrite
;	to output each group.
;
; MODIFICATION HISTORY:
;	DMS, July, 1983.
;	converted to new VMS IDL  April 90
;	Use SYSTIME() instead of !STIME   W. Landsman   Aug 1997
;	Converted to IDL V5.0   W. Landsman   September 1997
;-
	common stcommn, result, filename
;
        if N_params() LT 2 then begin
           print,'Calling Sequence - sxmake,unit,file,data,par,groups,header'
           return
        endif
;
	if n_elements(result) ne 200 then begin
		result = lonarr(20,10)	;define common blks
		filename = strarr(10)
		endif
;
	if (unit lt 1) or (unit gt 9) then $  ;unit ok?
		message,'Unit number must be from 1 to 9.'
;
	close,unit
	result[unit,*]=0
;
	n = n_params(0)	;# of params
	if n lt 4 then par = 0
	if n lt 5 then groups = 0
;
	if (par eq 0) and (groups eq 0) then $
		sxaddpar,header,'simple','T','Written by IDL:  '+ systime() $
	    else $
		sxaddpar,header,'simple','F','Written by IDL:  '+ systime()
	s = size(data)			;obtain size of array.
	stype = s[s[0]+1]		;type of data.
	case stype of
0:	message,'Data parameter is not defined'
7:	message,"Can't write strings to ST files"
1:	begin& bitpix=  8 & d='INTEGER*1' & endcase
2:	begin& bitpix= 16 & d = 'INTEGER*2' & endcase
4:	begin& bitpix= 32 & d='REAL*4' & endcase
3:	begin& bitpix= 32 & d='INTEGER*4' & endcase
5:	begin& bitpix= 64 & d='REAL*8' & endcase
6:	begin& bitpix= 64 & d='COMPLEX*8' & endcase
	endcase
;
	sxaddpar,header,'BITPIX',bitpix
	sxaddpar,header,'NAXIS',S[0]	;# of dimensions
	for i=1,s[0] do sxaddpar,header,'NAXIS'+strtrim(i,2),s[i]
	sxaddpar,header,'DATATYPE',d,'Type of data'
        Get_date,dte
        sxaddpar,header,'DATE',dte
;
	if groups eq 0 then $		;true if not group fmt.
		sxaddpar,header,'GROUPS','F','No groups' $
	   else begin			;make group params.
		sxaddpar,header,'GROUPS','T'
		sxaddpar,header,'PCOUNT',par
		sxaddpar,header,'GCOUNT',groups
		sxaddpar,header,'PSIZE',bitpix*par,'# of bits in parm blk'
	   endelse
;
	sxopen,unit,file,header,hist,'W' ;make header file, etc.
	return
end
