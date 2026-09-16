;$Author: jimm $                                                            
;$Date: 2010-01-12 12:18:45 -0800 (Tue, 12 Jan 2010) $
;$Header: /home/cdaweb/dev/control/RCS/orb_mgr.pro,v 1.65 2008/02/14 21:08:42 kovalick Exp kovalick $
;$Locker: kovalick $
;$Revision: 7092 $

;+                                                                            
; NAME: rmvar_strc.pro
;
; PURPOSE: Removes indicated variable from the structure if present 
;
; astrc    -  Input structure
; vname    -  Variable name

FUNCTION rmvar_strc, astrc, vname

namest=tag_names(astrc)
ns_tags=n_tags(astrc)

 for k=0, ns_tags-1 do begin

  if(namest(k) ne vname) then begin
   if(k eq 0) then b=create_struct(namest(k),astrc.(k)) else begin
     temp=create_struct(namest(k),astrc.(k))
     b=create_struct(b,temp)
   endelse
  endif
 endfor

return, b
end

;+                                                                            
; NAME: orb_handle.pro
;
; PURPOSE: Converts handles to data for a given structure
;
; a    -  Input structure
; b    -  Output structure

FUNCTION orb_handle, a

 namest=tag_names(a)
 ns_tags=n_tags(a)

 for k=0, ns_tags-1 do begin
   names=tag_names(a.(k))
   ntags=n_tags(a.(k))
   whc=where(names eq 'HANDLE',whn)
    if(whn) then begin
     handle_value, a.(k).HANDLE, dat
     if(n_elements(dat) gt 1) then dat=reform(dat)
     temp=create_struct('DAT',dat)
     temp1=create_struct(a.(k),temp)
     temp2=create_struct(namest(k),temp1)
     if(k eq 0) then b=temp2 else b=create_struct(b,temp2)
    endif else begin
     temp2=create_struct(namest(k),a.(k))
     if(k eq 0) then b=temp2 else b=create_struct(b,temp2)
    endelse

 endfor
a=0 ; free structure a 
return, b
end

FUNCTION evaluate_orbstruct, a
; determine if there's an display_type attribute for this structure
; and if so, whether it is defined as "orbit" or not.  If so, whether
; the coordinate system is defined, ie. orbit>coord=gse

; Verify that the input variable is a structure
b = size(a)
if (b(n_elements(b)-2) ne 8) then begin
  print,'ERROR=Input parameter is not a valid structure.' & return,-1
endif

atags = tag_names(a) ; get names of all attributes for structure

; Attempt to determine the coordinate system based on the display_type 
; attribute values.

b = tagindex('DISPLAY_TYPE',atags)
if (b(0) ne -1) then begin
  c = break_mystring(a.(b(0)),delimiter='>')
  csize = size(c)
  if (csize(1) eq 2)then begin
    d = break_mystring(c(1), delimiter='=')
    dsize = size(d)
    if (dsize(1) eq 2) then begin
      if (strupcase(d(0)) eq 'COORD') then coord = strupcase(d(1))
    endif
  endif 
endif 

if (n_elements(coord) eq 0) then coord = ' '

return, coord
end  




function orb_mgr,m0, $
                 tstart=tstart,tstop=tstop,xsize=xsize,ysize=ysize, $
                 orb_vw=orb_vw,press=press,bz=bz,crd_sys=crd_sys,xmar=xmar,$
                 ymar=ymar,doymark=doymark,hrmark=hrmark,hrtick=hrtick, $
                 mntick=mntick,mnmark=mnmark,xumn=xumn,xumx=xumx,yumn=yumn,$
                 yumx=yumx,zumn=zumn,zumx=zumx,rumn=rumn,rumx=rumx,$
                 labpos=labpos,chtsize=chtsize, $
		 GIF=GIF,GCOUNT=GCOUNT, ps=ps,pCOUNT=pCOUNT,$
                 REPORT=reportflag,DEBUG=DEBUG,us=us,bsmp=bsmp,SSC=SSC,$
    symsiz=symsiz,lnthick=lnthick,autolabel=autolabel,datelabel=datelabel,$
                 eqlscl=eqlscl,panel=panel
;
; m0            - mega-structure of input sturctures from plotmaster or
;                 input filename array from ssc
; out_names     - an array of output plotfile names
;
; Purpose: Read in data structures in SSC mode
;          Determine # of structures both SSC and CDAW modes
;
; Author:  R.Baldwin   8/96
;
; Problems: If a user specifies predictive and definitive data, then the
;           variables for each data type must be the same for both cases.
;           Otherwise an error will result. eg. GSE_POS for both pre and
;           def. NOT GSE_POS for pre and GSM_POS for def. 
; 

out_names=strarr(10)

; Set defaults
if(n_elements(SSC) eq 0) then SSC=0
if(n_elements(panel) eq 0) then panel=0

   autoscale=0L ; autoscaling off
if(NOT SSC) then begin

;TJK comment out these settings - these were needed for making some
;special Postscript files for Don Fairfield
;print, 'Orb_mgr TJK setting custom settings for postscript plot'
;  orb_vw=['xy']
;   xumn=-50 & yumn=-60 & yumx=60 & xumx=70
;   zumx=30 & zumx=30 & rumx=30 & rumx=30 ;have to define these or autoscaling is turned on
;   autoscale=0L ; autoscaling off

print, 'Setting defaults'
   orb_vw=['xy','xz','yz','xr']

;   xmin=-60 & ymin=-60 & ymax=60 & xmax=60
;  xmin=-5 & ymin=-5 & ymax=5 & xmax=5
;  labpos=[-30.0,-30.0]
   doymark=0
   hrmark=0
   hrtick=0
   mnmark=0
   mntick=0
   autolabel=1L
   autoscale=1L ; autoscaling on
   datelabel=1L
;  chtsize=0.7
endif

; Insure m0 is an array and not a structure. If it is a structure, set ssc=0
ain=size(m0)
nain=n_elements(ain) 
if(ain(nain-1) eq 8) then begin
 SSC=0
 print, "WARNING= switching from SSC to CDAW application"
endif

 nstruct=n_tags(m0)
 for l=0, nstruct-1 do begin
  w=execute('a'+strtrim(string(l),2)+'=m0.(l)')
  if(not w) then print, "ERROR=Assessing cdf's in execute string "
 endfor

if keyword_set(GCOUNT) then gif_number = GCOUNT else gif_number = 0L  
if keyword_set(pCOUNT) then ps_number = pCOUNT else ps_number = 0L  
if keyword_set(XSIZE) then xs = XSIZE else xs = 720
if keyword_set(YSIZE) then ys = YSIZE else ys = 850  

; Loop through structures; valid for both ssc and cdaw
; Build final mega-structure from each defined mega-structure 
;  
cs_bol=intarr(9)
new_str=create_struct('NPARMS',nstruct);

; Process input structures (CDAWeb or SSCweb) a0,a1,a2,a3.....
for i=0, nstruct-1 do begin
  w=execute('a=a'+strtrim(string(i),2))
  if(not w) then print, "ERROR= Execute command for structure failed." 
; Convert handles to data if not SSC
;  if(NOT SSC) then a=orb_handle(a)
   a=orb_handle(a)
; patch for tstart
  if(tstart eq 0.d0) then tstart=a.epoch.dat(0)
; Determine satellite names
  if(a.(0).project eq 'SSC') then begin
   tagnm=a.(0).source_name
  endif else begin
   tagtmp=a.(0).source_name
   ch=''
   tagnm=''
   ii=0
   while(ch ne '>') do begin
    ch=strmid(tagtmp,ii,1)
    ii=ii+1
    tagnm=tagnm+ch
   endwhile
    tagnm=strmid(tagnm,0,(strlen(tagnm)-1))
  endelse

;TJK 2/26/2002 - call replace_bad_chars to replace any "illegal" characters in
;the tagnm w/ a legal one.  This was necessary to go to IDL 5.3.

  tagnm = replace_bad_chars(tagnm,repchar="_",found)


; Determine coordinate system
  vnames=tag_names(a)

  for j=0,n_elements(vnames)-1 do begin
;Get the structure tag names (attributes) for this 
;variable then find out if the display_type is set.
   coord = evaluate_orbstruct(a.(j))
   if(coord ne ' ') then begin
;        print, 'Coordinate system = ',coord
	coord = strupcase(coord)
	if (coord eq 'GCI') then cs_bol(0) = 1
	if (coord eq 'TOD') then cs_bol(1) = 1
	if (coord eq 'J2000') then cs_bol(2) = 1
	if (coord eq 'GEO') then cs_bol(3) = 1
	if (coord eq 'GM') then cs_bol(4) = 1
	if (coord eq 'GSE') then cs_bol(5) = 1
	if (coord eq 'GSM') then cs_bol(6) = 1
	if (coord eq 'SM') then cs_bol(7) = 1
	if (coord eq 'HEC') then cs_bol(8) = 1
   endif

    ;TJK added the following if statement so that these assumptions don't
    ;get used w/ CDAWEB.  CDAWeb uses the above settings, ie. orbit>coord=gse
    ;and makes no assumptions based on variable names. 08/09/2000

    if(a.(0).project eq 'SSC') then begin

     if(vnames(j) eq 'GCI_POS') then cs_bol(0)=1                               
     if(vnames(j) eq 'XYZ_GCI') then cs_bol(0)=1
     if(vnames(j) eq 'TOD_POS') then cs_bol(1)=1                              
     if(vnames(j) eq 'XYZ_TOD') then cs_bol(1)=1
     if(vnames(j) eq 'J2000_POS') then cs_bol(2)=1  
     if(vnames(j) eq 'XYZ_J2000') then cs_bol(2)=1
     if(vnames(j) eq 'GEO_POS') then cs_bol(3)=1                               
     if(vnames(j) eq 'XYZ_GEO') then cs_bol(3)=1
     if(vnames(j) eq 'GM_POS') then cs_bol(4)=1
     if(vnames(j) eq 'XYZ_GM') then cs_bol(4)=1
     if(vnames(j) eq 'GSE_POS') then cs_bol(5)=1
     if(vnames(j) eq 'XYZ_GSE') then cs_bol(5)=1
     if(vnames(j) eq 'GSM_POS') then cs_bol(6)=1                               
     if(vnames(j) eq 'XYZ_GSM') then cs_bol(6)=1
     if(vnames(j) eq 'SM_POS') then cs_bol(7)=1
     if(vnames(j) eq 'XYZ_SM') then cs_bol(7)=1
     if(vnames(j) eq 'HEC_POS') then cs_bol(8)=1                               
     if(vnames(j) eq 'XYZ_HEC') then cs_bol(8)=1
    endif
  endfor 

; Build final mega-structure
  temp=create_struct(tagnm,a)
  new_str=create_struct(new_str,temp)
  catch, error_stat
; Trap pre. + def. error
  if error_stat ne 0 then begin
   print, 'ERROR=Cannot plot predictive and definitive data together on an orbit plot.  Re-select.'   
   print, 'STATUS=Cannot plot predictive and definitive data together on an orbit plot.  Please re-select.'   
; SSCweb breaks if this condition occurs. The stop below prevents idl server
; failure and email overflow of server email recipent   RTB
     stop 
;;   print, 'Error index: ', error_stat
;;   print, 'Error Message: ', !ERR_STRING
;;   help, new_str /struct
    new_str.nparms=1
    return, -1
  endif

endfor

; Override window size 
         if(SSC) then  begin
          if(not panel) then begin
            xs=720 
            ys=850 
          endif else begin
            xs=720 
            ys=800 
          endelse
         endif

; Loop through the # of coord. systems plotting each one on a separate page
cs_names=['GCI','TOD','J2000','GEO','GM','GSE','GSM','SM','HEC']
for l=0,8 do begin
 if(cs_bol(l) eq 1) then begin
  crd_sys=cs_names(l)

; Patch for panel and stacked orbit plots
   if(panel) then n_lp=n_elements(orb_vw)-1 else n_lp=0
    
   temp_arr=orb_vw
   for mm=0,n_lp do begin                 ; Re-assign view for each 
    if(panel) then begin                  ; stacked plot
       orb_vw=strarr(1)
       orb_vw(0)=temp_arr(mm) 
    endif
     
    ; Open an X-window or GIF file depending on keywords
     if keyword_set(GIF) then begin
       if(gif_number lt 100) then gifn='0'+strtrim(string(gif_number),2)
       if(gif_number lt 10) then gifn='00'+strtrim(string(gif_number),2)
       if(gif_number ge 100) then gifn=strtrim(string(gif_number),2) 
       GIF=strmid(GIF,0,(strpos(GIF,'.gif')-3))+gifn+'.gif'
;      out_names(l)=GIF
       deviceopen,6,fileOutput=GIF,sizeWindow=[xs,ys],COLORTAB=39

       gif_number = gif_number + 1
       if (reportflag eq 1) then printf,1,'GIF=',GIF
       print,'GIF=',GIF
     endif
     if keyword_set(ps) then begin
       ; Determine name for new ps file
       if(ps_number lt 100) then psn='0'+strtrim(string(ps_number),2)
       if(ps_number lt 10) then psn='00'+strtrim(string(ps_number),2) 
       if(ps_number ge 100) then psn=strtrim(string(ps_number),2) 
       ps=strmid(ps,0,(strpos(ps,'.eps')-3))+psn+'.eps'

       deviceopen,1,fileOutput=ps,/portrait,sizeWindow=[xs,xs]
       if (reportflag eq 1) then printf,1,'PS=',ps
       print,'PS=',ps
       ps_number = ps_number + 1
  endif  
  if (not keyword_set(GIF)  and not keyword_set(ps)) then begin
     set_plot, 'x'
     loadct,13
  endif  
     ;endif else begin
     ;  set_plot, 'x'
     ;  loadct,13
     ;endelse

stat=orbit_plt(new_str,tstart=tstart,tstop=tstop,xsize=xsize,ysize=ysize, $
               orb_vw=orb_vw,press=press,bz=bz,crd_sys=crd_sys,xmar=xmar,$
               ymar=ymar,doymark=doymark,hrmark=hrmark,hrtick=hrtick, $
               mntick=mntick,mnmark=mnmark,xumn=xumn,xumx=xumx,yumn=yumn,$
            yumx=yumx,zumn=zumn,zumx=zumx,rumn=rumn,rumx=rumx,color=color, $
            labpos=labpos,chtsize=chtsize,us=us,bsmp=bsmp,autoscl=autoscale,$
    symsiz=symsiz,lnthick=lnthick,autolabel=autolabel,datelabel=datelabel, $
               eqlscl=eqlscl,panel=panel)

 
if (keyword_set(GIF) or keyword_set(ps))then begin
; set background
  top = 255
  bottom = 0
  tvlct, r_curr, g_curr, b_curr, /get
  r_curr(0) = bottom & g_curr(0) = bottom & b_curr(0) = bottom
  r_curr(!d.n_colors-1) = top & g_curr(!d.n_colors-1) = top
  b_curr(!d.n_colors-1) = top
  r_curr(!p.color) = top & g_curr(!p.color) = top
  b_curr(!p.color) = top
  tvlct, r_curr, g_curr, b_curr
  deviceclose
  erase
endif
 
 endfor ; Stacked plot loop

 endif ; End condition for coordinate system
endfor ; End loop for all coord. systems 

;out_strc=create_struct('status',gif_number,'names',out_names)


;return, gif_number 
if keyword_set(ps) then return,ps_number 
if keyword_set(gif) then return,gif_number 
end
