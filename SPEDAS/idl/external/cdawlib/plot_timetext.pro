;+------------------------------------------------------------------------
; NAME: PLOT_TIMETEXT
; PURPOSE: To generate a time text plot given the anonymous structures
;          returned by the read_mycdf function.
; CALLING SEQUENCE:
;       out = plot_timetext(Xstruct,Ystruct)
; INPUTS:
;       Xstruct = structure containing the Epoch variable structure of the
;                 type returned by the read_mycdf structure.
;       Ystruct = structure containing the variable to be printed against
;                 the Epoch variable in the Xstruct parameter
; KEYWORD PARAMETERS:
;       TSTART   = Forces the time axis to begin at this Epoch time.
;       TSTOP    = Forces the time axis to end at this Epoch time.
;	NOTIME	 = time is not displayed by timeaxis_text
;	NOSUBTITLE=subtitle is not displayed 
;	PLABELOFFSET=Label offset in pixels
;	ONLYLABEL= only label will be displayed by timeaxis, no x-axis. 
;	ELEMENTS = if set, then only these elements of a dimensional variable
;                  will be plotted.
;       NONOISE  = if set, filter out values outside 3 sigma from mean
;	NOVALIDS = if set, ignore validmin and validmax from input structures
;	COMBINE = if set, need to add the dataset name to the y axis label
;		  added 10/24/2003 - TJK.	
;       DEBUG    = if set, turns on additional debug output.
; OUTPUTS:
;       out = status flag, 0=0k, -1 = problem occured.
; AUTHOR:
;       Created 11/99 by RCJ. Based on plot_timeseries.pro
; MODIFICATION HISTORY:
;       10/24/2003 - TJK added COMBINE keyword to add dataset name label
;
;-------------------------------------------------------------------------
FUNCTION plot_timetext, Xvar, Yvar, $
         TSTART=TSTART,TSTOP=TSTOP,NOTIME=NOTIME, NOSUBTITLE=NOSUBTITLE, $
         ONLYLABEL=ONLYLABEL,PLABELOFFSET=PLABELOFFSET, ELEMENTS=ELEMENTS,$
         NONOISE=NONOISE, NOVALIDS=NOVALIDS, COMBINE=COMBINE,$
         DEBUG=DEBUG,REPORT=REPORT,_EXTRA=EXTRAS, HELP=HELP

; Open report file if keyword is set
status = 0
nogood=0
if keyword_set(help) then begin
   print,'Plot_timetext. Example:'
   print,'IDL>s=plot_timeseries(xvar,yvar,/onlylabel,panel_height=100,/nosubtitle)'
   print,'where xvar and yvar are structures containing the Epoch variable'
   print,'as returned by read_myCDF, and the variable to be printed against the'
   print,'Epoch variable, respectively.'
   print,'IDL>s=plot_timetext(xvar,yvar,/notime, plabellofset=-40)'   
   status=-1
   goto, skipped
endif   
;

if keyword_set(REPORT) then begin & reportflag=1L
   a=size(REPORT) & if (a(n_elements(a)-2) eq 7) then $
   OPENW,1,REPORT,132,WIDTH=132
endif else reportflag=0L

; Verify that both Xvar and Yvar are present
if (n_params() ne 2) then begin
   print,'ERROR=Missing parameter to plot_timetext function' & return,-1
endif

; Verify the type of the first parameter and retrieve the data
a = size(Xvar)
if (a(n_elements(a)-2) ne 8) then begin
   print,'ERROR=1st parameter to plot_timetext not a structure' & return,-1
endif else begin
   a = tagindex('DAT',tag_names(Xvar))
   if (a(0) ne -1) then times = Xvar.DAT $
   else begin
      a = tagindex('HANDLE',tag_names(Xvar))
     if (a(0) ne -1) then handle_value,Xvar.HANDLE,times $
     else begin
        print,'ERROR=1st parameter does not have DAT or HANDLE tag' & return,-1
     endelse
     b = size(times)
     if (b(n_elements(b)-2) ne 5) then begin
        print,'ERROR=1st parameter datatype not CDF EPOCH' & return,-1
     endif
   endelse
endelse
szck=size(times)
if(szck(szck(0)+2) ne 1) then $ ; RTB added to prevent reform(scalar)
       times = reform(times) ; eliminate any redundant dimensions
       
; Verify the type of the second parameter and retrieve the data
a = size(Yvar)
if (a(n_elements(a)-2) ne 8) then begin
   print,'ERROR=2nd parameter to plot_timetext not a structure' & return,-1
endif else begin
   YTAGS = tag_names(Yvar) ; avoid multiple calls to tag_names

   if keyword_set(COMBINE) then begin
     a = tagindex('LOGICAL_SOURCE',YTAGS)
     if (a(0) ne -1) then yds = strupcase(Yvar.(a(0)))
   endif

   a = tagindex('DAT',YTAGS)
   if (a(0) ne -1) then THEDATA = Yvar.DAT $
   else begin
      a = tagindex('HANDLE',YTAGS)
      if (a(0) ne -1) then handle_value,Yvar.HANDLE,THEDATA $
      else begin
         print,'ERROR=2nd parameter does not have DAT or HANDLE tag' & return,-1
      endelse
   endelse
endelse

szck=size(thedata)
if(szck(szck(0)+2) ne 1) then $ ; RTB added to prevent reform(scalar)
      thedata = reform(thedata) ; eliminate any redundant dimensions
      
; Get size of data 
thedata_size = size(thedata)

; Verify type of data and determine the number of panels that will be plotted
; and which elements of the data array are to be plotted.
a = size(thedata) & b = a(n_elements(a)-2) & thedata_size = a
if ((b eq 0) OR (b gt 5)) then begin
  print,'STATUS=datatype indicates that data is not plottable' & return,-1
endif else begin
  case a(0) of
  0   : begin
        print,'STATUS=Re-select longer time interval. Single data points are not plottable' & return,-1
        end
  1   : begin
        elist=0
        end
  2   : begin ; #panels determined by dimensionality or by display type
        elist=indgen(a(1))
        ;if keyword_set(ELEMENTS) then begin
	; RCJ 11/13/2003 Line above is not a good way to check the keyword elements
	; because it could be =0 (ie, we want x component only) but it will
	; be understood by the program as 'elements keyword not set'. Better line below:
        if n_elements(ELEMENTS) ne 0 then begin
           elist = ELEMENTS
        endif else begin
          if NOT keyword_set(IGNORE_DISPLAY_TYPE) then begin
            b = tagindex('DISPLAY_TYPE',YTAGS)
            if (b(0) ne -1) then begin ; evaluate the display type
              c = strupcase(Yvar.(b(0))) & c = break_mystring(c,delimiter='>')
              if ((c(0) eq 'TIME_TEXT')AND(n_elements(c) gt 1)) then begin
                d = break_mystring(c(1),delimiter=',')
                elist = long(d) & elist = elist -1
              endif
            endif
          endif
        endelse
        end
  else: begin
        print,'ERROR=Cannot plot data with > 2 dimensions' & return,-1
        end
  endcase
endelse

if (thedata_size(0) eq 1) then mydata = thedata $
  else mydata=thedata(elist,*)
mydata=reform(mydata)
  
; Determine the proper start and stop times of the plot
tbegin = times(0) & tend = times(n_elements(times)-1) ; default to data
if keyword_set(TSTART) then begin ; set tbegin
   tbegin = TSTART & a = size(TSTART)
   if (a(n_elements(a)-2) eq 7) then tbegin = encode_CDFEPOCH(TSTART)
endif

if keyword_set(TSTOP) then begin ; set tend
   tend = TSTOP & a = size(TSTOP)
   if (a(n_elements(a)-2) eq 7) then tend = encode_CDFEPOCH(TSTOP)
endif
;
; Compare the range of the time data to the requested start and stop times
pad_front = 0L & pad_end = 0L
if (tbegin lt times(0)) then begin
   if keyword_set(DEBUG) then print,'Padding front of times...'
   times = [tbegin,times] & pad_front = 1L
endif
if (tend gt times(n_elements(times)-1)) then begin
   if keyword_set(DEBUG) then print,'Padding end of times...'
   times = [times,tend] & pad_end = 1L
endif
;
; Determine the first and last data time points to be plotted
rbegin = 0L & w = where(times ge tbegin,wc)
if (wc gt 0) then rbegin = w(0)
rend = n_elements(times)-1 & w = where(times le tend,wc)
if (wc gt 0) then rend = w(n_elements(w)-1)
if (rbegin ge rend) then begin
   print,'STATUS=No data within specified time range.' & return,-1
endif
;
if not keyword_set(nosubtitle) then begin
   ; Create a subtitle for the plots showing the data start and stop times
   CDF_EPOCH,tbegin,year,month,day,hour,minute,second,milli,/BREAK
   ical,year,doy,month,day,/idoy
   subtitle = 'TIME RANGE='+strtrim(string(year),2)+'/'+strtrim(string(month),2)
   subtitle = subtitle + '/' + strtrim(string(day),2)  
   subtitle = subtitle + ' (' + strtrim(string(doy),2) + ') to '
   CDF_EPOCH,tend,year,month,day,hour,minute,second,milli,/BREAK
   ical,year,doy,month,day,/idoy
   subtitle = subtitle + strtrim(string(year),2)+'/'+strtrim(string(month),2)
   subtitle = subtitle + '/' + strtrim(string(day),2)
   subtitle = subtitle + ' (' + strtrim(string(doy),2) + ')'
endif else subtitle=''
;
; Convert the time array into seconds since tbegin
CDF_EPOCH,tbegin,year,month,day,hour,minute,second,milli,/BREAK
CDF_EPOCH,a,year,month,day,0,0,0,0,/COMPUTE_EPOCH
times  = (times - a) / 1000
julday = ymd2jd(year,month,day)
;
; Determine label for time axis based on time range
xranger = lonarr(2)
xranger(0) = (tbegin-a)/1000
xranger(1) = (tend-a)/1000
trange = xranger(1) - xranger(0)
if (trange le 60.0) then tform='h$:m$:s$.f$@y$ n$ d$' $
else tform='h$:m$:s$@y$ n$ d$'
;
; Determine the fill value for the Y data and valid min and valid max values
a = tagindex('FILLVAL',YTAGS)
if (a(0) ne -1) then Yfillval = Yvar.FILLVAL else Yfillval = 1.0e31
;
mydata_size=size(mydata)
; pad the beginning and end of data if extra time points were added
;  if (pad_front) then mydata = [Yfillval,mydata] ; add fill point to front
if (pad_front) then begin
   if (mydata_size(0) eq 1) then begin
      mydata = [Yfillval,mydata]
   endif else begin
      for ii=0,mydata_size(1)-1 do begin
         command='mydata'+strtrim(string(ii),2)+ $
             '=[Yfillval,reform(mydata('+strtrim(string(ii),2)+',*))]'
         status=execute(command) 
      endfor
      mydata=[mydata0] ; there's always going to be a mydata0
      for ii=1,mydata_size(1)-1 do begin
         command='mydata=[[mydata],[mydata'+strtrim(string(ii),2)+']]'
         status=execute(command)
      endfor
      mydata=transpose(mydata)
   endelse   
endif
;  if (pad_end) then mydata = [mydata,Yfillval] ; add fill point to back
if (pad_end) then begin
   if (mydata_size(0) eq 1) then begin
      mydata = [mydata,Yfillval]
   endif else begin
      for ii=0,mydata_size(1)-1 do begin
         command='mydata'+strtrim(string(ii),2)+ $
             '=[reform(mydata('+strtrim(string(ii),2)+',*)),Yfillval]'
         status=execute(command) 
      endfor
      mydata=[mydata0] ; there's always going to be a mydata0
      for ii=1,mydata_size(1)-1 do begin
         command='mydata=[[mydata],[mydata'+strtrim(string(ii),2)+']]'
         status=execute(command)
      endfor
      mydata=transpose(mydata)
   endelse   
endif

if (mydata_size(0) eq 1) then mydata=mydata(rbegin:rend) else mydata=mydata(*,rbegin:rend)
mytimes = times(rbegin:rend)

addi=[mytimes]
size_mydata=size(mydata)
if size_mydata(0) ne 1 then begin ; 1 = array, more than 1 = matrix
   for ii=0,size_mydata(1)-1 do begin
      addi=[[addi],[reform(mydata[ii,*])]]
   endfor
endif else begin
   addi=[[addi],[mydata]]
endelse 
;
; correction for bad or missing data at the beginning, end, and middle of addi array  
;
szaddi=size(addi)
; this part will fix the beginning of the array, row by row.
; example: if the array starts with  99  99  99  5  7  3 ... it will become
; 5  5  5  5  7  3 .... the bad values will be replaced with the first good value.
; Addendum (07/00): Only replace values within 'delta' from first good value,
; where delta is 1% of number of points. Remaining bad values will become 0's. RCJ
for i=1,szaddi(2)-1 do begin ; i starts at 1 because row 0 is time
   delta=round(n_elements(addi(*,i))*0.01) ; 1% of total number of elements in that row
   if keyword_set(DEBUG) then print,'DELTA = ',strtrim(delta,2), ', 1% of ',strtrim(n_elements(addi(*,i)),2)
   q=where(addi(*,i) ne yfillval)
   if q(0) ne -1 then begin
      j=0
      counter=0
      value=addi(0,i)
      while (value eq yfillval) do begin
         counter=j
         j=j+1
         value=addi(j,i)
      endwhile
      ;if keyword_set(DEBUG) then print,'Replacing array positions (',$
      ;      '0:',strtrim(counter,2),$
      ;      ',',strtrim(i,2),') with ',strtrim(value,2)
      if (counter-delta lt 0) then begin
         if keyword_set(DEBUG) then print,'Replacing array positions (',$
            '0:',strtrim(counter,2),$
            ',',strtrim(i,2),'), value(s) =  ',strtrim(addi[0:counter,i],2),' with ',strtrim(value,2)
         addi[0:counter,i]=value 
      endif else begin
         if keyword_set(DEBUG) then print,'Replacing array positions (',$
            strtrim(counter-delta,2),':',strtrim(counter,2),$
            ',',strtrim(i,2),'), value(s) =  ',strtrim(addi[counter-delta:counter,i],2),' with ',strtrim(value,2)
         addi[counter-delta:counter,i]=value
      endelse   
      ;
      ; similarly for the end of the array.....
      j=n_elements(addi(*,i))-1
      counter=n_elements(addi(*,i))-1
      value=addi(j,i)
      while (value eq yfillval) do begin
         counter=j
         j=j-1
         value=addi(j,i)
      endwhile
      ;if keyword_set(DEBUG) then print,'Replacing array positions (',$
      ;      strtrim(counter,2),':', $
      ;      strtrim(n_elements(addi(*,i))-1,2),$
      ;      ',',strtrim(i,2),') with ',strtrim(value,2)
      if (counter+delta gt n_elements(addi(*,i))-1) then begin
         if keyword_set(DEBUG) then print,'Replacing array positions (',$
            strtrim(counter,2),':',strtrim(n_elements(addi(*,i))-1,2),$
            ',',strtrim(i,2),'), value(s) =  ',strtrim(addi[counter:n_elements(addi(*,i))-1,i],2),' with ',strtrim(value,2)
         addi[counter:n_elements(addi(*,i))-1,i]=value
      endif else begin
         if keyword_set(DEBUG) then print,'Replacing array positions (',$
            strtrim(counter,2),':',strtrim(counter+delta,2),$
            ',',strtrim(i,2),'), value(s) =  ',strtrim(addi[counter:counter+delta,i],2),' with ',strtrim(value,2)
         addi[counter:counter+delta,i]=value
      endelse   
      ;
      ; now for gaps in the data. Take an average of the closest non-bad values to the
      ; left and to the right of the gap. In other words, interpolate the data.
      for j=1L,n_elements(addi(*,i))-2 do begin
         if addi(j,i) eq yfillval then begin
            prev=addi(j-1,i)
            pos_prev=j-1
            next=addi(j+1,i)
            pos_next=j+1
            for k=pos_next,n_elements(addi(*,i))-1 do begin
               if addi(k,i) ne yfillval then begin
                  next=addi(k,i)
                  pos_next=k
                  goto, fill_gap
               endif    
            endfor
            fill_gap:
            ;if keyword_set(DEBUG) then print,'Replacing array positions (',$
            ;	strtrim(pos_prev+1,2),':', $
            ;	strtrim(pos_next-1,2),$
            ;	',',strtrim(i,2),') with ',strtrim((prev+next)/2.,2)
            ;addi[pos_prev+1:pos_next-1,i]=(prev+next)/2.   ; gap is filled with average 
            if (pos_next-pos_prev le delta) then begin
               if keyword_set(DEBUG) then print,'Replacing array positions (',$
            	  strtrim(pos_prev+1,2),':', $
            	  strtrim(pos_next-1,2),$
            	  ',',strtrim(i,2),'), value(s) =  ',strtrim(addi[pos_prev+1:pos_next-1,i],2),' with ',strtrim(prev,2)
               addi[pos_prev+1:pos_next-1,i]=prev
            endif else begin
	       ; The condition below is for the case when we are at the beginning of the array
	       ; and we could have pos_prev=0 and delta=0 (small number of points, 1% of
	       ; it would be =0). In this case we would be doing:
	       ; addi[1:0,i]=prev which results in error.
	       ; RCJ 10/15/02
	       if (pos_prev+1 le pos_prev+delta) then $
               addi[pos_prev+1:pos_prev+delta,i]=prev
               w=where(addi[pos_prev+delta:pos_next-1,i] eq yfillval)
               if w(0) ne -1 then begin
                  if (n_elements(w) gt delta) then begin
                     if keyword_set(DEBUG) then print,'Replacing array positions (',$
            	        strtrim(pos_next-1-delta,2),':', $
            	        strtrim(pos_next-1,2),$
            	        ',',strtrim(i,2),'), value(s) =  ',strtrim(addi[pos_next-1-delta:pos_next-1,i],2),' with ',strtrim(next,2)
                     addi[pos_next-1-delta:pos_next-1,i]=next
                  endif else begin
                     if keyword_set(DEBUG) then print,'Replacing array positions (',$
            	        strtrim(w(0),2),':', $
            	        strtrim(w(n_elements(w)-1),2),$
            	        ',',strtrim(i,2),'), value(s) =  ',strtrim(addi[w,i],2),' with ',strtrim(next,2)
                     addi[w,i]=next
                  endelse
               endif   
            endelse  
            j=k
         endif  ; end if element is yfillval
      endfor ; done all the gaps
   endif   ; end if there are yfillvals 
   qq=where(addi(*,i) eq yfillval) 
   ; if after all we've done there are still yfillvals in this row, make them = 0
   if qq(0) ne -1 then begin
      addi(qq,i) = 0
      if keyword_set(debug) then print,'Array position(s) set to 0: ',qq
   endif   
endfor ; end i, for each row 
;
if (yvar.lablaxis ne '') then begin
   if keyword_set(notime) then addl=[yvar.lablaxis] else addl=['UT','',yvar.lablaxis]
endif else begin ; if lablaxis is not present, labl_ptr_1 must be
    if keyword_set(notime) then addl=[yvar.labl_ptr_1] else addl=['UT','',yvar.labl_ptr_1]
endelse    
 
;addf=['(e10.2)','(e10.2)','(e10.2)','(e10.2)'] format accepted by timeaxis_text. RCJ
;
; timeaxis_text will only accept addf with same number of rows as addi
; so the first element of addf = '' (that would be the time format).  RCJ
addf=strarr(szaddi(2))
addf(0)='' 
 if (yvar.format ne '') then $
      addf(1:*)='('+yvar.format+')' else addf(1:*)='('+yvar.form_ptr(elist)+')'
 addl=[addl(elist)]
; RCJ attempt to align all labels:
for ii=0,n_elements(addl)-1 do begin
   if strlen(addl(ii)) lt 10 then begin
      for iii=strlen(addl(ii))+1,10 do addl(ii)=addl(ii)+' ' 
   endif
endfor

add_dataset='' ; initialize dataset label
if (keyword_set(COMBINE) and n_elements(yds) gt 0)then begin
  add_dataset = make_array(szaddi(2),/string,value=' ')
  add_dataset(0) = yds
endif

;

 timeaxis_text,FORM=tform,JD=julday,title=subtitle,CHARSIZE=0.9, /notime, $
         addinfo=addi,addlabel=addl,addformat=addf, add_ds=add_dataset, $
	 plabeloffset=plabeloffset, onlylabel=onlylabel, _extra=extras   
;

skipped:
return,status
end
