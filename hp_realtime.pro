
@/home/immel/sci/fuv/realtime/fuv_rt_hp_cond.pro
@/home/immel/sci/fuv/realtime/fuv_rt_kp.pro 
;;;;;@/home/hfrey/idl/image/calibration/si_mission_correction_new.pro
@/home/immel/idl/kp_p.pro 
@/disks/sprite/image/fuview/fuv_mission_correction.pro
;;   Author : THomas Immel, UCB
;;   Date   : 2001
;;
; program to use the realtime_hp calculator to do a series of installed
; images. Looks like the kp is not being fed properly the date...
;
; Changes: To run one for nikolai, who has already done background 
;          subtractions, have to make a bckgnd_flag
;;


bck_flag = 0
hp_flag = 1

if bckgnd_flag eq 0 then begin
print,'-----------------------------------------------'
print,' '
print,'---WARNING! Not using background subtraction---'
print,' '
print,'-----------------------------------------------'
endif

;day_o_fun='2000197'
;day_o_fun2='2000_197'
;bck_mult=[1.05,1.48,.8]
;img_path='/disks/neo/disk1/immel/sci/fuv/bastille/aguf01/'
;filter=''
;rat_booster=20	;bump this up to consider the perturbed atmosphere

day_o_fun='2000155'
day_o_fun2='2000_155'
bck_mult=[1.,1.,1.]
img_path='/disks/trinity/disk1/nikost/studies/000603/fuv_data/'
filter=''
rat_booster=0	;bump this up to consider the perturbed atmosphere


fuv_mission_correction,fix(strmid(day_o_fun,0,4)),$
        fix(strmid(day_o_fun,4,3)),img_corr




new_order=[0,2,1]
img_corr=img_corr(new_order)

kp=3	;kp is later done properly
	;in hp_rt_hp_cond (used for proton correction)

  spawn,'ls '+img_path+ 's13'+day_o_fun+filter+'*map',s13list
  spawn,'ls ' +img_path+'s12'+day_o_fun+filter+'*map',s12list
  spawn,'ls ' +img_path+'wic'+day_o_fun+filter+'*map',wiclist

  spawn,'ls '+img_path+ 's13'+day_o_fun+filter+'*idl',s13mafs
  spawn,'ls ' +img_path+'s12'+day_o_fun+filter+'*idl',s12mafs
  spawn,'ls ' +img_path+'wic'+day_o_fun+filter+'*idl',wicmafs

filelist=[[s12list],[wiclist],[s13list]]
filelist=transpose(filelist)

maflist=[[s12mafs],[wicmafs],[s13mafs]]
maflist=transpose(maflist)
annotation=['S12 Counts','WIC A-D Units','S13 Counts']

  spawn,'ls '+img_path+ 's13'+day_o_fun+filter+'*mapbck',s13list
  spawn,'ls ' +img_path+'s12'+day_o_fun+filter+'*mapbck',s12list
  spawn,'ls ' +img_path+'wic'+day_o_fun+filter+'*mapbck',wiclist

  bcklist=[[s12list],[wiclist],[s13list]]
  bcklist=transpose(bcklist)

counter=n_elements(wiclist)


if hp_flag eq 1 then begin
  hp_arr=fltarr(counter)
  hphi_arr=fltarr(counter)	;to hold hp where one assumes 20 kev protons
;---- account for proton energies separately
  hpp_arr=fltarr(counter)
  hpphi_arr=fltarr(counter)	;to hold hp where one assumes 20 kev protons
endif

ut_arr=fltarr(counter)

for i=0,counter-1 do begin
  for j=0,2 do begin	;s12,wic,s13 selector
    restore,filelist(j,i)
    restore,maflist(j,i)
    load_common,imageinfo
    map=mapim
    map(where(map ne -1)) = map(where(map ne -1)) * img_corr(j)
    case j of 
      0: s12map=mapim
      1: wicmap=mapim
      2: s13map=mapim
    endcase


    if bck_flag eq 1 then begin

      restore,bcklist(j,i)
      if j eq 2 then mapim(where(mapim le 0))=0 	;s13
      if j eq 1 then mapim(where(mapim le 0))=450 	;wic
      if j eq 0 then mapim(where(mapim le 0))=2		;s12

;	mapim=map- bck_mult(j)*(mapim)		;s13
;      if j eq 2 then mapim=map- 1.08*(mapim)		;s13
;      if j eq 1 then mapim=map- 0.98*(mapim)		;wic
;      if j eq 0 then mapim=map- 0.5*(mapim)		;s12

    case j of 
      0: s12map_=s12map - mapim*bck_mult(j)
      1: wicmap_=wicmap - mapim*bck_mult(j)
      2: s13map_=s13map - mapim*bck_mult(j)
    endcase
    

    endif	

    fortime=filelist(j,i)
    if strpos(fortime,'/') gt -1 then name_path_extract,fortime,fortime,b
    sday=strmid(fortime,7,3)

    shour=strmid(fortime,10,2)
    smin=strmid(fortime,12,2)
    ut=float(shour) + float(smin)/60
    ut_arr(i)=ut
    lonformap= -1 * (ut*15) 
  endfor
  
  ee_limit=25.

  fuv_rt_hp_cond,wicmap_,s13map_,s12map_,hp_,ef_,ped_,hall_,/installed,$
	ee_limit=ee_limit,rat_boost=rat_booster
  hp_arr(i)=hp_(0)
  hpp_arr(i)=hp_(1)  
;  !p.multi=[0,2,1,0] &  plot,wicmap_(300,*) & plot,wicmap_(20,*)
;  tvscl,wicmap_
;  tvscl,bytscl(wicmap_,min=0,max=4000)
  print,hp_
endfor


savefile='hp_realtime_limited_ee_' + strcompress(fix(ee_limit),/rem) + $
	'_boost_ratio_' + strcompress(fix(rat_booster),/rem) + '.idl'

save,filename=savefile,hp_arr,hpp_arr,$
	ut_arr,rat_booster,ee_limit
	

end
