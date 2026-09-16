pro get_savefilename,time_,savefilename
    		utseconds_=time_(1)/1000.
		year_=time_(0)/1000
    		doy_=time_(0) mod 1000
    		decimal_hours=utseconds_/86400. * 24.
    		hr_=0 & min_=0 & sec_=0 & msec_  = 0. 
    		time_dec2clock,decimal_hours,hr_,min_,sec_,msec_    ;see ~immel/idl
    		shr_=strcompress(hr_,/rem) & smin_=strcompress(min_,/rem)
    		if hr_ lt 10 then shr_='0' + shr_ & if min_ lt 10 then smin_='0' + smin_
    		xdrfile_name=strcompress(time_(0),/rem) + $
            				shr_ + smin_ + '.idl'
;		print,xdrfile_name,' SAVEFILENAME'
                savefilename=xdrfile_name
return
end

pro i_map,starttime,stoptime,inst,stopper=stopper,filename=filename,$
           outdir=outdir,every=every

;this program based on code written by T Immel and Harald Frey for 
;pro fuv_rt_management_2
;
;
;  INPUTS : starttime,stoptime [yyyy,ddd,hh,mm,ss] format
;         : inst 0=wic, 1=SI-12, 2=SI-13
;  OUTPUTS : only to local directory
;  for north and south arcs. 
;            img_arr=fltarr(4,*,*) =[magstack,maglonstack,smagstack,smaglonsta]
;	     
;  Keywords : stopper - stops processing after last file is produced
;             filename - set filename as you like. Note that this is
;                        pretty stupid if you have more than one file.
;             outdir - different output directory than ./
;  Requirements : you need ~immel/idl/time_dec2clock.pro and all the
;                 fuview software in your path.


@fuv_cmnblk
fuv_init,/mkblack 

each=1
if keyword_set(every) gt 0 then each=every

case inst of 
  '0':inst_str='IMFHWIC'
  '1':inst_str='IMF12LSI'
  '2':inst_str= 'IMF13LSI'
  else : begin 
    print, 'Enter 0 for wic, 1 for S12'
    entry = ' '
    read, entry
    case entry of 
      '0':inst_str='IMFHWIC'
      '1':inst_str='IMF12LSI'
      '2':inst_str= 'IMF13LSI'
    endcase

  endelse

endcase

ret=fuv_read_udf(vinst=inst_str,starttime=starttime,$
                 stoptime=stoptime,/inventory)
;ret has images and all sorts of other fields
;in it, unless you specify /inventory
;in that case, it is btime and etime only.

active_inst=fix(inst)

;;;-- MUST set mafrec before calling uget_time
count=n_elements(ret)
maxrec(active_inst)=count

;--- unlike rt processing, we need to load dstr with epochs!
inventory=ret
uget_time_list,active_inst,ret_err,inventory  ;load that inventory into

;flatfield=get_flatfield(starttime(0), starttime(1),inst)


skipper=1
if keyword_set(every) gt 0 then skipper=every

for i=0,n_elements(ret)-1,each do begin

  current_record=i
  print,current_record, ': Current Record'
;--- 
;  stop
  getudf_var,active_inst,current_record,xerror,/nowid

;--- it's done, imageinfo is completely loaded

  imageinfo(*).src=['HWIC','12LS','13LS']	;except this

;---rotate the images so that they match geographic/magnetic/solar coords

  fuv_rt_rotations



  timestamp  =imageinfo(active_inst).time
  if keyword_set(filename) gt 0 then savefile=filename else $
     get_savefilename,timestamp,savefile
  
  case active_inst of & 0:front='wic' & 1:front='s12' & 2:front='s13' & endcase
  savefile=front+savefile

  if keyword_set(outdir) gt 0 then begin
    lastchar=strmid(outdir,strlen(outdir)-1,1)
    if lastchar ne '/' then outdir=outdir+'/'
    savefile=outdir + savefile
  endif

  oldimageinfo=imageinfo
  imageinfo=imageinfo(active_inst)

  if (active_inst ge 1) then begin

;--- MUST load siinfo structure

	downshift

	imageinfo=siinfo(active_inst) 

;--- DONE

  endif

  save,filename=savefile, imageinfo, /compress
  print,"Wrote " + savefile
  imageinfo=oldimageinfo   ;have to restore imageinfo to an array of 3 structures before continuing processing.

endfor

if keyword_set(stopper) gt 0 then stop
 
end
