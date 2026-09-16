;
;  It is ultimately stupid to have plot_conductance plot e-fields
;  and potentials.
;  But I am going to keep doing it it seems.
;
;  Anyway, this program was created to plot e-fields correctly
;  without breaking the code which apparently worked just fine
;  with the Nov, 93 data. Don't ask me how it did that. :p
;
;  if plot_conductance were called plot_variable, things would make
;  much more sense
;  4-5-2000, difference plots are wrong for potentials.
;  comp_data_amie_3 - working on interpolation between amie timesteps
;		    - that works! So does the rough despiking routine
;		    - now start correcting f-14 e-fields
;		 _4 - consider efields from sonde - 2D data
;		    	conductances were 2D but pretty easy.
;                	Efields have 2 components and are +- numbers.
;			but still aren't too bad
;		 _5 - time to do Joule heating. Its looking good
;			(numbers are a little low???)
;		 _6 - time to add alternate plot_subroutine that
;		      plots 2d images if requested (SONDE only of course)
;                   - times keyword changed to times_ since array named 'times'
;		    - confuses keyword_set()
;
pro plot_2D,amie_dat,sat_dat,mlat,mlt_,ut,datatype,sc_arr,$
	datafile,$
	no_erase=no_erase,small=small,$
	nomlt=nomlt,nomlat=nomlat,$
	utx=utx,efield=efield,emag=emag,times_=times_

;
; 11-5-99 : Must expect bad sonde data points
;

print,datafile, '---Datafile'

if keyword_set(efield) then efield_flag=1 else efield_flag=0


if keyword_set(emag) then emag_flag=1 else emag_flag=0


if keyword_set(no_erase) then noerase_flag=1 else noerase_flag=0
print,noerase_flag,'NOERASE FLAG'
stop

small_flag=0
if keyword_set(small) then small_flag=1

potential_flag=0
joule_flag = 0

same_scale_flag = 0	;do bytscl with peak determined from BOTH sc and AMIE

if datatype eq 'pot' and efield_flag ne 1 then begin
  print, 'Plotting Potential'
  potential_flag=1				;may be unused, who knows
endif

;---convert amie efields to mV/m vs V/m, their default units
if datatype eq 'ee' or datatype eq 'en' then amie_dat = amie_dat*1000

s_units=' '
if datatype eq 'sjh' then begin
  amie_dat = amie_dat*1000
  joule_flag =1 
  s_units='(mW/m!u2!n)'
endif

print,keyword_set(efield),' Efield keyword'

mlat_flag = 1
if keyword_set(nomlat) then  mlat_flag=0

mlt_flag = 1
if keyword_set(nomlt) then  mlt_flag=0

print,'********* datatype ',datatype,' **************'

;----adding new spacecraft requires that these be adjusted as well!!@!!@!

spacecraft_strings=['F08','F10','F11','N12','MEPS','AXIS','Sonde',$
			'F12','F13','F14']
;--------------------------------------------------------------------;
;---------------------- make a 2d array -----------------------------;
;--------------------------------------------------------------------;

;---have to rebin this data.

yindices=fix((mlat-min(mlat))*4) ; 4 gets us in ballpark of 1 degree per bin
ysize=max(yindices)

thing=uniq(mlt_)		;find out how many mlts to be plottin
times=size(thing) & times=times(1)
xindices=mlt_
for i=0,times-1 do begin
  xindices(where(xindices eq xindices(thing(i))))=i
endfor

amie_arr=fltarr(times,ysize)
sat_arr=fltarr(times,ysize)
amie_arr(xindices,yindices)=amie_dat
sat_arr(xindices,yindices)=sat_dat

;---2 d array done--- :)

linestyle_arr=indgen(4) + 1

if datatype eq 'hal' then datatype2= 'Hall'
if datatype eq 'ped' then datatype2='Pedersen'
if datatype eq 'pot' or datatype eq 'ee' or datatype eq 'en' or 	$
datatype eq 'sjh' then datatype2=''


;----drop in code to account for differences in tom's and Ridley's naming
;----schemes

if strpos(datafile,'x') eq -1 then begin	;immel naming scheme

  all_finder=strpos(datafile,'all')
  not_all_finder=strpos(datafile,'all-super')
  UVI_finder=strpos(datafile,'UVI')
  dmsp_finder=strpos(datafile,'dmsp')
  dmsp_sigma_finder=strpos(datafile,'dmsp_sigma')	;only dmsp conductance
  sonde_finder=strpos(datafile,'sonc')
  nm_finder=strpos(datafile,'.nm.')

  sonde_e_finder=strpos(datafile,'sone')

  handy_arr=intarr(6)
  handy_arr=[all_finder,not_all_finder,UVI_finder,dmsp_finder,$
		sonde_finder,nm_finder]

  handy_arr=(1<handy_arr)
  print,handy_arr,' Data flags'

  possible_titles=strarr(8)
  possible_titles(0)='(' + datatype2 + $
		' Conductance: Mags, Sats, Radar and UVI inputs)'
  possible_titles(1)='(' + datatype2 + $
		' Conductance: Mags, Sats, and UVI inputs)'
  possible_titles(2)='(' + datatype2 + $
		' Conductance: Mags, Sonde and UVI inputs)'
  possible_titles(3)='(' + datatype2 + $
		' Conductance: Mags and UVI inputs)'
  possible_titles(4)='(' + datatype2 + $
		' Conductance: Mags and Sonde inputs only)'
  possible_titles(5)='(' + datatype2 + $
		' Conductance: Mags only)'
  possible_titles(6)='(' + datatype2 + $
		' Conductance: Mags and Sat inputs)'
  possible_titles(7)='(Statistical '+ datatype2  +   ' Conductance only)'
  
  title_add='(Full Run)'
  if all_finder ge 0 and not_all_finder ne 1 then $
	title_add = possible_titles(0) else title_add = possible_titles(1)

  if total(handy_arr * [1,-1,-1,-1,-1,-1]) eq 6 then $
	title_add=possible_titles(0)
  if total(handy_arr * [1,1,-1,-1,-1,-1]) eq 6 then $
	title_add=possible_titles(1)
  if total(handy_arr * [-1,-1,-1,-1,1,-1]) eq 6 then $
	title_add=possible_titles(4)
  if total(handy_arr * [-1,-1,-1,-1,-1,-1]) eq 6 then $
	title_add=possible_titles(5)
  if total(handy_arr * [-1,-1,-1,-1,-1,1]) eq 6 then $
	 title_add=possible_titles(7)
  if total(handy_arr * [-1,-1,1,-1,-1,-1]) eq 6 then $ 
	title_add=possible_titles(3)
  if total(handy_arr * [-1,-1,1,-1,1,-1]) eq 6 then $
	title_add=possible_titles(2)
  if total(handy_arr * [-1,-1,-1,1,-1,-1]) eq 6 then $
	title_add=possible_titles(6)

  


endif else begin				;ridley naming scheme

  nc_finder=strpos(datafile,'.nc.')		;no conductance
  mo_finder=strpos(datafile,'.mo.')		;magnetometers only
  _98_finder=strpos(datafile,'.98.')

  nc_finder=(1<nc_finder)				;either 1 or -1
  mo_finder=(1<mo_finder)				;either 1 or -1
  _98_finder=(1<_98_finder)				;either 1 or -1

  if nc_finder eq -1 and _98_finder eq -1 then $
    _91_finder=1 else _91_finder=-1

  if nc_finder eq 1 then title_add='(Statistical ' + datatype2 + ' Conductance'
  if _98_finder eq 1 then title_add='(Ahn 98 '+ datatype2 + ' Conductance' 
  if _91_finder eq 1 then title_add='(Ahn 91 '+ datatype2 +' Conductance' 
  if mo_finder eq 1 then title_add=title_add + ', mags only)' else $
	if nc_finder eq 1 then title_add=title_add + ', no data)' else $
	title_add=title_add + ', all data)'

endelse


datsize=size(amie_dat) & datsize=datsize(1) ;
year_arr=intarr(datsize)
month_arr=intarr(datsize)
day_arr=intarr(datsize)
hour_arr=intarr(datsize)
min_arr=intarr(datsize)
sec_arr=intarr(datsize)

for i=0,datsize-1 do begin
  timer=ut(i)
  thing=0
  c_r_to_a,thing,timer
  year_arr(i)=thing(0)
  month_arr(i)=thing(1)
  day_arr(i)=thing(2)
  hour_arr(i)=thing(3)
  min_arr(i)=thing(4)
  sec_arr(i)=thing(5)
endfor

debug=0

if keyword_set(times_) eq 1 then begin ;want vertical lines at particular times




  print,'---Plotting times---'
  close,7
  openr,7,'studytimes.txt'
  num='  '
  readf,7,format='(a2)',num
  if strcompress(num,/rem) ne '' then begin
    time_arr=dblarr(num)
    stringer=' '
    for i=0,num-1 do begin
;---format should be yymmddhhmmss in studytimes
      readf,7,format='(a12)',stringer
      c_a_to_r,[fix(strmid(stringer,0,2)),fix(strmid(stringer,2,2)),$
		fix(strmid(stringer,4,2)),fix(strmid(stringer,6,2)),$
		fix(strmid(stringer,8,2)),fix(strmid(stringer,10,2))],bla
      time_arr(i)=bla
    endfor
  endif
endif

;----set up plotting ticks and annotations----;

delta_t_sec=max(ut)-min(ut)                     ;ut(datsize-1)-ut(0)
step_t_sec=ut-min(ut)                           ;Array begins at 0 seconds
time_sort=sort(step_t_sec)			;necessary if 2 or more sc
  if debug then print,time_sort

num_xticks=4			                  ;lesser of the two
time_labs=strarr(num_xticks+1)
for i=0,num_xticks do begin
  dummy='0'
  c_r_to_a,dummy,min(ut)+delta_t_sec*i/num_xticks+1.	;convert huge float to integers
  finder=where(dummy lt 10,finderct)
  dummy_s=string(dummy)
  if finderct gt 0 then dummy_s(finder)='0' + dummy_s(finder)  ;0:3=>00:03
  time_labs(i)=strcompress(dummy_s(3) + ':' + dummy_s(4),/rem)
endfor

;---sort data to be plotted by time
;---time_sort defined above

  ut_sort=ut(time_sort)
  step_t_sec_sort=step_t_sec(time_sort)
  amie_dat_sort=amie_dat(time_sort)
  sat_dat_sort=sat_dat(time_sort)
  sc_arr_sort=sc_arr(time_sort)
  mlat_sort=mlat(time_sort)
  mlt_sort=mlt_(time_sort)

  if debug gt 0 then print,sc_arr_sort,' sc_arr'
  if debug gt 0 then print,size(uniq(sc_arr)),'Number of spacecraft'

  uniquity=uniq(sc_arr)  
  sc_to_plot=size(uniq(sc_arr))
  if sc_to_plot(0) ne 0 then sc_to_plot=sc_to_plot(1) else $
	sc_to_plot=1

;----save initial !p.position and set new ones
;----added additional plot box    5-24-99

old_position=!p.position
yplots=6
ytot=!p.position(3)-!p.position(1)
ytop=!p.position(3)
ystep=ytot/yplots
pos_arr=fltarr(4,yplots)

;--move rh bound by 0.1 to make room for color bars.
pos_arr(*,0)=[!p.position(0),ytop-2*ystep,!p.position(2)-0.1 ,ytop]
pos_arr(*,1)=[!p.position(0),ytop-4*ystep,!p.position(2)-0.1 ,ytop-2*ystep]
pos_arr(*,2)=[!p.position(0),ytop-6*ystep,!p.position(2)-0.1 ,ytop-4*ystep]
;pos_arr(*,3)=[!p.position(0),ytop-6*ystep,!p.position(2)-0.1,ytop-5*ystep]

if debug gt 0 then print,pos_arr

;---------------set up other things for plots

;--work with the graph title a little. If sc_arr has only -999 and 1-5, 
;--then you can put the individual title in there

if sc_to_plot lt 2 then title_sc=spacecraft_strings(sc_arr(uniquity(0))) $
	else title_sc='DMSP'
!x.thick=2.5
!y.thick=2.5
!p.thick=2
!p.charthick=2
!p.charsize=1.4

minx=min(step_t_sec) & maxx=max(step_t_sec)

if debug gt 0 then print,maxx,'MAXX'

blanks=['  ','  ', '  ','  ','  ','  ','  ','  ','  ','  ']
yearbig=dummy(0)/100
yearextra=dummy(0) mod 100
year_s=strcompress(19 + yearbig) + strcompress(yearextra)
title_s=strcompress(Dummy_s(1) + '/' + dummy_s(2) + '/' + year_s,/rem)
title_ss=title_s

if datatype ne 'ee' and datatype ne 'en' then begin

  if potential_flag eq 1 and efield_flag ne 1  then $
    title_s=title_s + ', !MF!7!dAMIE!n vs !MF!7!d' $   ;!M is PS symbol
    else if efield_flag eq 1 then $
    title_s=title_s + ', E!7!dAMIE!n vs E!7!d'  else $;!4 is bold helvetica
      title_s=title_s + ', !MS!7!dAMIE!n vs !MS!7!d'     ;!7 is times
    print,'got in potential-efield title-loop'

  if joule_flag eq 1 then title_s=title_ss + ', Q!dAMIE!n vs. Q!d'

endif else $
  if emag_flag eq 1 then title_s = title_s + ', |!15E!X|, AMIE vs. ' $ 
  else if datatype eq 'ee' then $
  title_s=title_s + ', E!dEast!n, AMIE vs. ' $
  else title_s=title_s + ', E!dNorth!n, AMIE vs. '



if small_flag then $ 
title_s=title_s + title_sc + '!n (' + datatype2 + ')' else $
title_s=title_s + title_sc + '!n ' + title_add

;xyouts,.8,.8,strcompress(Dummy_s(1) + '/' + dummy_s(2) + '/' + year_s,/rem),$
;			/norm,charsize=1.6

!p.position=pos_arr(*,0)

scale_max=30
if efield_flag eq 0 and datatype eq 'ee' then  scale_max=40

if datatype eq 'pot' then $
topofyrange=fix((max(amie_dat_sort) > max(sat_dat_sort)))+ 1 else $   ;11-5-99
topofyrange=fix((max(amie_dat_sort) > max(sat_dat_sort)) < scale_max)+ 1     
								      ;11-5-99

;---next only is other than 0 for potential plots
bottomofrange=fix(min(amie_dat_sort) < min(sat_dat_sort))
bottomofrange=(bottomofrange <0)				;make sure
if bottomofrange lt 0 then bottomofrange=bottomofrange - 1

if potential_flag eq 1 then $
	ytitle = '!MF!7 (kV)' else if efield_flag eq 1 then $
	ytitle = 'E Field (mV/m)' else if joule_flag eq 1 then $
	ytitle = 'Joule Heating (mW/m!u2!n)' else if emag_flag then $
	ytitle = 'E Field (mV/m)' else $
        ytitle='!MS!7 (mho)'

if efield_flag eq 0 and potential_flag eq 0 then begin	;plot a frame, SIMPLE!

  plot,step_t_sec_sort,amie_dat_sort, $
 	xticks=num_xticks,xtickname=blanks,/nodata,$
	title=title_s,noerase=noerase_flag,ytitle=ytitle,$
	yrange=[bottomofrange,topofyrange],xrange=[0,maxx],/xstyle,/ystyle

;  print,amie_dat_sort,'AMIE D SORT'

  plots,[!x.crange(0),!x.crange(1)],[0,0],linestyle=2,thick=1

  if keyword_set(times_) eq 1 then begin
    print,'Drawing vertical lines'

    for i=0,n_elements(time_arr)-1 do begin

      xtimepos= time_arr(i)- min(ut)
      print,xtimepos
      plots,[xtimepos,xtimepos],[!y.crange(1),!y.crange(0)],linestyle=2,thick=4
    endfor
  endif
endif

;---find times at which to break up orbits.

breaker=ut_sort-shift(ut_sort,1)

;---begin plots
;---plot for each spacecraft separately
;---also attempt to plot each orbit separately

for i=0,sc_to_plot-1 do begin
							;I know I could use
  sc_range=where(sc_arr_sort eq sc_arr(uniquity(i)),range_count)  
							;sc_arr_sort(uniquity..
							;SO?!
  sc_id= sc_arr(uniquity(i))
  if sc_id eq 6 then min_value = -31 else min_value = -998
  sc_breaker=breaker(sc_range+1)
  if sc_id ge 0 then begin				;HACKEROOOO!!!!

;----maybe do the e-fields _here_
;
;  AMIE should always provide the Potential only
;  DMSP on the other hand will always provide the E-Field. The potential
;  would have to be calculated from the SC data, and I did that at one
;  point.
;

      if keyword_set(efield) or potential_flag eq 1 then begin
        angular_distances=fltarr(range_count) ;efield will be 
	actual_distances=fltarr(range_count)  ;one smaller
	new_amie_data=fltarr(range_count)     ;as well as the new amie data
	new_sat_data=fltarr(range_count)	;and the new sat data
	all_new_amie=amie_dat_sort & all_new_amie(*)=0
        all_new_sat=amie_dat_sort & all_new_sat(*)=0
        a_ang=mlat(sc_range)                  ;*!pi/180.
        X_ang=mlt_(sc_range)                  ;*!pi/180.
        for jj=0,range_count-2 do begin
;	  angular_distances(jj)=acos(cos(a_ang(jj))*cos(a_ang(jj+1)) + $
;	   	 		sin(a_ang(jj))*sin(a_ang(jj+1)) * $
;       				cos(X_ang(jj)-X_ang(jj)))
	  actual_distances(jj)=distance(a_ang(jj),X_ang(jj),$
					a_ang(jj+1),X_ang(jj+1))


;------doing nearest neighbors differences to calculate electric field

	  if potential_flag eq 0 then begin		;convert amie data to E

  	    new_amie_data(jj)=amie_dat_sort(sc_range(jj))- $ 
				(amie_dat_sort(sc_range(jj+1)))

;---this is also unnecessary if the satellite data are electric fields already
;---03-29-2000

;	  new_sat_data(jj)=sat_dat_sort(sc_range(jj))- $
;				(sat_dat_sort(sc_range(jj+1)))

	    new_sat_data(jj)=sat_dat_sort(sc_range(jj))


;------------------------------------------------------------------------
	  endif else begin				;convert SC data to Phi
            new_amie_data(jj)=amie_dat_sort(sc_range(jj))
	    new_sat_data(jj+1)=sat_dat_sort(sc_range(jj+1))+new_sat_data(jj)

	  endelse
        endfor

        if potential_flag eq 0 then begin
	    new_amie_data=new_amie_data/actual_distances
	    new_amie_data=new_amie_data*1000.         ;  now mV/meter
						      ;  added -1 on 03-29-2000
						;and removed it, -1 is done
						;in differencing scheme above
        endif else begin

	    new_sat_data=new_sat_data*actual_distances	;it's OK to do it all
	    new_sat_data=new_sat_data/1000.		;at once, I think
	    new_sat_data=new_sat_data*(-1)
	    print,'******************'
	    print,'DOING SOMETHING'
	    print,'******************'
							;otherwise could
							;be done in the loop
        endelse
;---apply median filter if necessary
	spike_size=25			;tight!
  	thing1=new_amie_data-shift(new_amie_data,1)
	thing2=(new_amie_data-shift(new_amie_data,-1))
print,'***********************************************'
	found_1=where(THING1 GT spike_size)
	found_2=WHERE(THING2 GT spike_size)
print,'***********************************************'
	findspike=where(abs(thing1) gt 30,spikes)	;30 spike threshold
	if spikes gt 0 then begin
	          for ij=0,spikes-1 do $	
		  new_amie_data(findspike(ij))=$
			median(new_amie_data(0>(findspike(ij)-2):$
					(range_count-2)<(findspike(ij)+2)))
	endif
;---assuming kV is potential, then dividing by km->volts/meter
;	actual_distances=angular_distances*7000.	

	print,amie_dat_sort(sc_range),'^Original AMIE^'
	print,sat_dat_sort(sc_range),'^Original Sat Data^'
	print,new_sat_data, '^New Sat Data^'
        print,new_amie_data, '^New AMIE Data^'

	help,amie_dat_sort,sat_dat_sort,new_sat_data,new_amie_data
;	print,actual_distances, '^Actual Distances^'



;--------DMSP data is ALREADY straight  electric field
;        new_sat_data=new_sat_data/actual_distances
;	new_sat_data=new_sat_data*1000.  ;/2. ;2 was a hack, but still of 
					 ;concern as to why aaron and I were
					 ;different
	all_new_sat(sc_range)=new_sat_data
	all_new_amie(sc_range)=new_amie_data
;---first change values in satellite data

;---then adjust AMIE values
        
      endif	;what is this the end of? keywordset(efield) or potential_flag



      if keyword_set(efield) or potential_flag eq 1 then begin
        bottomofrange=fix(min(new_amie_data) < min(new_sat_data))
        bottomofrange=(bottomofrange <0)		;make sure
        if bottomofrange lt 0 then bottomofrange=bottomofrange - 1

	  if potential_flag eq 0 then ytitle = 'E along track (mV/m)'

        if i eq 0 then plot,step_t_sec_sort,amie_dat_sort, $
	  xticks=num_xticks,xtickname=blanks,/nodata,$
	  title=title_s,noerase=noerase_flag,ytitle=ytitle,$
	  yrange=[bottomofrange,-1*bottomofrange],xrange=[0,maxx],$
          /xstyle,/ystyle
;	  yrange=[-50,50],xrange=[0,maxx],/xstyle,/ystyle

        plots,[!x.crange(0),!x.crange(1)],[0,0],linestyle=2,thick=1

	oplot,step_t_sec_sort(sc_range),new_amie_data
        if datatype eq 'sonde' then oplot,step_t_sec_sort(sc_range),$
		new_amie_data,psym=1

;	if joule_flag eq 1 then oplot,step_t_sec_sort(sc_range),$
;		new_amie_data,psym=7

        oplot,step_t_sec_sort(sc_range),new_sat_data,$
	  linestyle=(sc_id+1)mod 4+1,thick=!p.thick + 1,min_value=min_value
        if data_type eq 'sonde' then oplot,step_t_sec_sort(sc_range),$
		new_sat_data,psym=7


      endif else begin	  ;simply oplot conductances in frame made earlier

        oplot,step_t_sec_sort(sc_range),amie_dat_sort(sc_range)
        if joule_flag eq 1 then oplot,step_t_sec_sort(sc_range),$
		amie_dat_sort,psym=1
        oplot,step_t_sec_sort(sc_range),sat_dat_sort(sc_range),$
	  linestyle=(sc_id+1)mod 4+1,thick=!p.thick + 1,min_value=min_value
        if joule_flag eq 1 then oplot,step_t_sec_sort(sc_range),$
		sat_dat_sort,psym=7
      endelse


    totxsize=!p.position(2)-!p.position(0)
    totysize=!p.position(3)-!p.position(1)
    ystep=totysize/15.
    xyouts,!p.position(2)-totxsize*.14,!p.position(3)-ystep*(i+1),$
	spacecraft_strings(sc_id)+':',charsize=1.0,/norm
    plots,[!p.position(2)-totxsize*.08,!p.position(2)],$
      [!p.position(3)-ystep*(i+1)+0.0055,!p.position(3)-ystep*(i+1)+0.0055],$;
      linestyle=(sc_id + 1) mod 4 + 1,thick=2,/norm

  endif




endfor

;---doing difference plots

  if efield_flag eq 1 or potential_flag eq 1 then begin
    amie_dat_sort=all_new_amie 
    sat_dat_sort=all_new_sat
  endif

  difference=amie_dat_sort - sat_dat_sort    ;positive if amie is bigger


  max_diff=max(abs(difference))

  help_dif=where(difference lt 1000 and difference gt -1000,do_diff_help)
  avg= total(difference(help_dif))/n_elements(difference(help_dif))

;---calc standard deviation of difference
  sigma= total(difference(help_dif)^2)-n_elements(difference(help_dif))*avg^2
  sigma= sigma /float( n_elements(difference(help_dif-1)))
  sigma= sqrt(sigma)

;---calculate correlation between amie and data set
  helper=size(amie_dat_sort) & NN=helper(1)
  term1=total(amie_dat_sort*sat_dat_sort)
  term2=NN*mean(amie_dat_sort)*mean(sat_dat_sort)
  term3=total(amie_dat_sort^2)-NN*mean(amie_dat_sort)^2
  term4=total(sat_dat_sort^2)-NN*mean(sat_dat_sort)^2
  RR=(term1-term2)/(term3*term4)^2
  print,RR,'Correlation Coefficient!!!'



;-------------------------------------------------------------------



;  if avg lt 0 then sign_help =1
;  xyouts,!p.position(2)-0.12, !p.position(3)-0.02-0.004*!p.charsize,'Avg = ' + $ 
;		strmid( s_avg,0,3 + 1*sign_help ),/norm
;  xyouts,!p.position(2)-0.12,!p.position(3)-0.047-0.008*!p.charsize,'!Ms!7 = ' + $
;		strmid(strcompress(sigma,/rem),0,3),/norm

;----oplotscl amie_dat

blanks=strarr(10) & blanks(*)=' '
!p.position=pos_arr(*,1)

if same_scale_flag eq 1 then $
b_amie_arr=bytscl(amie_arr,min=0,max=(max(amie_arr)>max(sat_arr))) else $
b_amie_arr=bytscl(amie_arr,min=0,max=max(amie_arr))

ytitle='Mag. Lat. (deg)'
oplotscl,b_amie_arr,255,0,indgen(times),indgen(ysize),'','',''
ytop=strmid(strcompress(max(mlat),/rem),0,4)
ybot=strmid(strcompress(min(mlat),/rem),0,4)
ymid=(max(mlat)+min(mlat))/2.
ymid=strmid(strcompress(ymid,/rem),0,4)
axis,yaxis=0,yticks=2,ytickname=[ybot,ymid,ytop],ytitle=ytitle

axis,xaxis=1,xticks=1,xtickname=blanks,xthick=4

newposition=[!p.position(2)+0.02,!p.position(1)+0.01,$
		!p.position(2)+0.05,!p.position(3)-0.01]

if same_scale_flag eq 1 then $
max_cbar=(max(amie_dat) > max(sat_dat)) else $
max_cbar=(max(amie_dat))


cbar,newposition,min(amie_arr),max_cbar,'AMIE Data',$
	0.8,numticks=5,/swap

;axis,yaxis=1,yticks=1,ytickname=blanks,ytitle='AMIE Data'
ytickname=[min(amie_arr),(min(amie_arr)+max(amie_arr))/2.,max(amie_arr)]
ytickname=strcompress(ytickname,/rem)
ytickname=strmid(ytickname,0,4)
;axis,yaxis=1,yticks=1,ytickname=blanks,ytitle='AMIE Data'
;axis,yaxis=1,yticks=2,ytickname=ytickname,ycharsize=0.5

;----oplotscl sat_dat -----

!p.position=pos_arr(*,2)
ytitle='Mag. Lat. (deg)'

if same_scale_flag eq 1 then $
b_sat_arr=bytscl(sat_arr,min=0,max=(max(amie_arr)>max(sat_arr))) else $
if abs(max(amie_arr)-max(sat_arr)) gt 20 then $
b_sat_arr=bytscl(sat_arr,min=0,max=max(smooth(sat_arr,5,/edge))) else $
b_sat_arr=bytscl(sat_arr,min=0,max=max(sat_arr))


oplotscl,b_sat_arr,255,0,indgen(times),indgen(ysize),'','',''
axis,yaxis=0,yticks=2,ytickname=[ybot,ymid,ytop],ytitle=ytitle
;axis,yaxis=1,yticks=1,ytickname=blanks,ytitle='Sonde data'
axis,xaxis=0,xtickname=time_labs,xticks=num_xticks
axis,xaxis=1,xticks=1,xtickname=blanks,xthick=5,color=255

newposition=[!p.position(2)+0.02,!p.position(1)+0.01,$
		!p.position(2)+0.05,!p.position(3)-0.01]

if same_scale_flag eq 1 then $
max_cbar=(max(amie_dat) > max(sat_dat)) else $
if abs(max(amie_arr)-max(sat_arr)) gt 20 then $
max_cbar=max(smooth(sat_arr,5,/edge)) else $
max_cbar=(max(sat_dat))

cbar,newposition,min(sat_arr),max_cbar,'Sonde Data',$
		0.8,numticks=5,/swap
ytickname=[min(sat_arr),(min(sat_arr)+max(sat_arr))/2.,max(sat_arr)]
ytickname=strcompress(ytickname,/rem)
ytickname=strmid(ytickname,0,4)
;axis,yaxis=1,yticks=1,ytickname=blanks,ytitle='Sonde Data'
;axis,yaxis=1,yticks=2,ytickname=ytickname,ycharsize=0.5


!p.position=old_position

wait,2

erase       ;necessary  (yep)
end

;---------------END PLOT_2D--------------------------------------
;*****************************************************************
;*****************************************************************
;*****************************************************************
;---------------BEGIN PLOT_CONDUCTANCE---------------------------


pro plot_conductance,amie_dat,sat_dat,mlat,mlt_,ut,datatype,sc_arr,$
	datafile,avg,sigma,RR,timestamp,spacecraft_,$
	no_erase=no_erase,small=small,$
	nomlt=nomlt,nomlat=nomlat,$
	times=times,utx=utx,efield=efield,emag=emag
;
;
;
; Program to plot amie conductances vs satellite _or_ radar conductances.
; Start with satellite :P
;
; sc_arr is an array of small integers corresponding 
;
; no_erase keyword added to facilitate putting more than one of these plots
; on a page
;
; adding datafile to put nomags, Ahn 9*, etc in the plot titles.
; adding /nomlt and /nomlat flags
;
; adding studytimes.txt file. Delete contents if you don't want vertical
; lines on the plots!@!!@!@!#!. /times keyword
;
; adding /utx to force ut on difference plot
; added efield in case one is passing pre-calculated efields, not potentials
;
; 11-5-99 : Must expect bad sonde data points
;
;

print,datafile, '---Datafile'

if keyword_set(emag) then emag_flag=1 else emag_flag=0

if keyword_set(efield) then efield_flag=1 else efield_flag=0
print,efield_flag,'NOERADMNE FLAG'

if keyword_set(no_erase) then noerase_flag=1 else noerase_flag=0
print,noerase_flag,'NOERASE FLAG'

small_flag=0
if keyword_set(small) then small_flag=1

potential_flag=0
joule_flag = 0

if datatype eq 'pot' and efield_flag ne 1 then begin
  print, 'Plotting Potential'
  potential_flag=1				;may be unused, who knows
endif

;---convert amie efields to mV/m vs V/m, their default units
if datatype eq 'ee' or datatype eq 'en' then amie_dat = amie_dat*1000
if datatype eq 'sjh' then begin
  amie_dat = amie_dat*1000
  joule_flag =1 
endif



print,keyword_set(efield),' Efield keyword'


;---calc efield flag to stop confusion between having the efield
;---having to calculate the damn thing

calc_efield_flag=0
if datatype eq 'pot' and efield_flag eq 1 then calc_efield_flag = 1


mlat_flag = 1
if keyword_set(nomlat) then  mlat_flag=0

mlt_flag = 1
if keyword_set(nomlt) then  mlt_flag=0

print,'********* datatype ',datatype,' **************'

;----adding spacecraft requires that these be adjusted as well!!@!!@!

spacecraft_strings=['F08','F10','F11','N12','MEPS','AXIS','Sonde',$
			'F12','F13','F14']
;--------------------------------------------------------------------


linestyle_arr=indgen(4) + 1

if datatype eq 'hal' then datatype2= 'Hall'
if datatype eq 'ped' then datatype2='Pedersen'
if datatype eq 'pot' or datatype eq 'ee' or datatype eq 'en' or 	$
datatype eq 'sjh' then datatype2=''


;----drop in code to account for differences in tom's and Ridley's naming
;----schemes

if strpos(datafile,'x') eq -1 then begin	;immel naming scheme

  all_finder=strpos(datafile,'all')
  not_all_finder=strpos(datafile,'all-super')
  UVI_finder=strpos(datafile,'UVI')
  dmsp_finder=strpos(datafile,'dmsp')
  dmsp_sigma_finder=strpos(datafile,'dmsp_sigma')	;only dmsp conductance
  sonde_finder=strpos(datafile,'sonc')
  nm_finder=strpos(datafile,'.nm.')

  sonde_e_finder=strpos(datafile,'sone')

  handy_arr=intarr(6)
  handy_arr=[all_finder,not_all_finder,UVI_finder,dmsp_finder,$
		sonde_finder,nm_finder]

  handy_arr=(1<handy_arr)
  print,handy_arr,' Data flags'

  possible_titles=strarr(8)
  possible_titles(0)='(' + datatype2 + $
		' Conductance: Mags, Sats, Radar and UVI inputs)'
  possible_titles(1)='(' + datatype2 + $
		' Conductance: Mags, Sats, and UVI inputs)'
  possible_titles(2)='(' + datatype2 + $
		' Conductance: Mags, Sonde and UVI inputs)'
  possible_titles(3)='(' + datatype2 + $
		' Conductance: Mags and UVI inputs)'
  possible_titles(4)='(' + datatype2 + $
		' Conductance: Mags and Sonde inputs only)'
  possible_titles(5)='(' + datatype2 + $
		' Conductance: Mags only)'
  possible_titles(6)='(' + datatype2 + $
		' Conductance: Mags and Sat inputs)'
  possible_titles(7)='(Statistical '+ datatype2  +   ' Conductance only)'
  
  title_add='(Full Run)'
  if all_finder ge 0 and not_all_finder ne 1 then $
	title_add = possible_titles(0) else title_add = possible_titles(1)

  if total(handy_arr * [1,-1,-1,-1,-1,-1]) eq 6 then $
	title_add=possible_titles(0)
  if total(handy_arr * [1,1,-1,-1,-1,-1]) eq 6 then $
	title_add=possible_titles(1)
  if total(handy_arr * [-1,-1,-1,-1,1,-1]) eq 6 then $
	title_add=possible_titles(4)
  if total(handy_arr * [-1,-1,-1,-1,-1,-1]) eq 6 then $
	title_add=possible_titles(5)
  if total(handy_arr * [-1,-1,-1,-1,-1,1]) eq 6 then $
	 title_add=possible_titles(7)
  if total(handy_arr * [-1,-1,1,-1,-1,-1]) eq 6 then $ 
	title_add=possible_titles(3)
  if total(handy_arr * [-1,-1,1,-1,1,-1]) eq 6 then $
	title_add=possible_titles(2)
  if total(handy_arr * [-1,-1,-1,1,-1,-1]) eq 6 then $
	title_add=possible_titles(6)

  


endif else begin				;ridley naming scheme

  nc_finder=strpos(datafile,'.nc.')		;no conductance
  mo_finder=strpos(datafile,'.mo.')		;magnetometers only
  _98_finder=strpos(datafile,'.98.')

  nc_finder=(1<nc_finder)				;either 1 or -1
  mo_finder=(1<mo_finder)				;either 1 or -1
  _98_finder=(1<_98_finder)				;either 1 or -1

  if nc_finder eq -1 and _98_finder eq -1 then $
    _91_finder=1 else _91_finder=-1

  if nc_finder eq 1 then title_add='(Statistical ' + datatype2 + ' Conductance'
  if _98_finder eq 1 then title_add='(Ahn 98 '+ datatype2 + ' Conductance' 
  if _91_finder eq 1 then title_add='(Ahn 91 '+ datatype2 +' Conductance' 
  if mo_finder eq 1 then title_add=title_add + ', mags only)' else $
	if nc_finder eq 1 then title_add=title_add + ', no data)' else $
	title_add=title_add + ', all data)'

endelse


datsize=size(amie_dat) & datsize=datsize(1) ;
year_arr=intarr(datsize)
month_arr=intarr(datsize)
day_arr=intarr(datsize)
hour_arr=intarr(datsize)
min_arr=intarr(datsize)
sec_arr=intarr(datsize)

for i=0,datsize-1 do begin
  timer=ut(i)
  thing=0
  c_r_to_a,thing,timer
  year_arr(i)=thing(0)
  month_arr(i)=thing(1)
  day_arr(i)=thing(2)
  hour_arr(i)=thing(3)
  min_arr(i)=thing(4)
  sec_arr(i)=thing(5)
endfor

debug=0

if keyword_set(times) eq 1 then begin      ;want vertical lines at particular times
  print,'---Plotting times---'
  close,7
  openr,7,'studytimes.txt'
  num='  '
  readf,7,format='(a2)',num
  if strcompress(num,/rem) ne '' then begin
    time_arr=dblarr(num)
    stringer=' '
    for i=0,num-1 do begin
;---format should be yymmddhhmmss in studytimes
      readf,7,format='(a12)',stringer
      c_a_to_r,[fix(strmid(stringer,0,2)),fix(strmid(stringer,2,2)),$
		fix(strmid(stringer,4,2)),fix(strmid(stringer,6,2)),$
		fix(strmid(stringer,8,2)),fix(strmid(stringer,10,2))],bla
      time_arr(i)=bla
    endfor
  endif
endif

;----set up plotting ticks and annotations----;

delta_t_sec=max(ut)-min(ut)                     ;ut(datsize-1)-ut(0)
step_t_sec=ut-min(ut)                           ;Array begins at 0 seconds
time_sort=sort(step_t_sec)			;necessary if 2 or more sc
  if debug then print,time_sort

num_xticks=4			                  ;lesser of the two
time_labs=strarr(num_xticks+1)
for i=0,num_xticks do begin
  dummy='0'
  c_r_to_a,dummy,min(ut)+delta_t_sec*i/num_xticks+1.	;convert huge float to integers
  finder=where(dummy lt 10,finderct)
  dummy_s=string(dummy)
  if finderct gt 0 then dummy_s(finder)='0' + dummy_s(finder)  ;0:3=>00:03
  time_labs(i)=strcompress(dummy_s(3) + ':' + dummy_s(4),/rem)
endfor
timestamp=time_labs(0)	;for passing back to main routine


;---sort data to be plotted by time
;---time_sort defined above

  ut_sort=ut(time_sort)
  step_t_sec_sort=step_t_sec(time_sort)
  amie_dat_sort=amie_dat(time_sort)
  sat_dat_sort=sat_dat(time_sort)
  sc_arr_sort=sc_arr(time_sort)
  mlat_sort=mlat(time_sort)
  mlt_sort=mlt_(time_sort)

  if debug gt 0 then print,sc_arr_sort,' sc_arr'
  if debug gt 0 then print,size(uniq(sc_arr)),'Number of spacecraft'

  uniquity=uniq(sc_arr)  
  sc_to_plot=size(uniq(sc_arr))
  if sc_to_plot(0) ne 0 then sc_to_plot=sc_to_plot(1) else $
	sc_to_plot=1

;----save initial !p.position and set new ones
;----added additional plot box    5-24-99

old_position=!p.position
yplots=6
ytot=!p.position(3)-!p.position(1)
ytop=!p.position(3)
ystep=ytot/yplots
pos_arr=fltarr(4,yplots)
pos_arr(*,0)=[!p.position(0),ytop-2*ystep,!p.position(2),ytop]
pos_arr(*,1)=[!p.position(0),ytop-4*ystep,!p.position(2),ytop-2*ystep]
pos_arr(*,2)=[!p.position(0),ytop-5*ystep,!p.position(2),ytop-4*ystep]
pos_arr(*,3)=[!p.position(0),ytop-6*ystep,!p.position(2),ytop-5*ystep]

if debug gt 0 then print,pos_arr

;---------------set up other things for plots

;--work with the graph title a little. If sc_arr has only -999 and 1-5, 
;--then you can put the individual title in there

if sc_to_plot lt 2 then title_sc=spacecraft_strings(sc_arr(uniquity(0))) $
	else title_sc='DMSP'
!x.thick=2.5
!y.thick=2.5
!p.thick=2
!p.charthick=2
!p.charsize=1.4

minx=min(step_t_sec) & maxx=max(step_t_sec)

if debug gt 0 then print,maxx,'MAXX'

blanks=[' ',' ', ' ',' ',' ',' ',' ',' ',' ',' ']
yearbig=dummy(0)/100
yearextra=dummy(0) mod 100
year_s=strcompress(19 + yearbig) + strcompress(yearextra)
title_s=strcompress(Dummy_s(1) + '/' + dummy_s(2) + '/' + year_s,/rem)
title_ss=title_s

if datatype ne 'ee' and datatype ne 'en' then begin

  if potential_flag eq 1 and efield_flag ne 1  then $
    title_s=title_s + ', !MF!7!dAMIE!n vs !MF!7!d' $   ;!M is PS symbol
    else if efield_flag eq 1 then $
    title_s=title_s + ', E!7!dAMIE!n vs E!7!d'  else $;!4 is bold helvetica
      title_s=title_s + ', !MS!7!dAMIE!n vs !MS!7!d'     ;!7 is times
    print,'got in potential-efield title-loop'

endif else $
  if emag_flag eq 1 then title_s = title_s + ', |!15E!X|, AMIE vs. ' $ 
  else if datatype eq 'ee' then $
  title_s=title_s + ', E!dEast!n, AMIE vs. ' $
  else title_s=title_s + ', E!dNorth!n, AMIE vs. '



  if joule_flag eq 1 then title_s=title_ss + ', Q!dAMIE!n vs. Q!d'

;endif else $
;  if datatype eq 'ee' then $
;  title_s=title_s + ' E!dEast!n, AMIE vs. ' $
;  else title_s=title_s + ' E!dNorth!n, AMIE vs. '



if small_flag then $ 
title_s=title_s + title_sc + '!n (' + datatype2 + ')' else $
title_s=title_s + title_sc + '!n ' + title_add

;xyouts,.8,.8,strcompress(Dummy_s(1) + '/' + dummy_s(2) + '/' + year_s,/rem),$
;			/norm,charsize=1.6

!p.position=pos_arr(*,0)

scale_max=30
if efield_flag eq 1 then scale_max=(max(amie_dat_sort) > max(sat_dat_sort))

if datatype eq 'pot' then $
topofyrange=fix((max(amie_dat_sort) > max(sat_dat_sort)))+ 1 else $   ;11-5-99
topofyrange=fix((max(amie_dat_sort) > max(sat_dat_sort)) < scale_max)+ 1     
								;11-5-99

;---next only is other than 0 for potential plots
bottomofrange=fix(min(amie_dat_sort) < min(sat_dat_sort))
bottomofrange=(bottomofrange <0)				;make sure
if bottomofrange lt 0 then bottomofrange=bottomofrange - 1

if potential_flag eq 1 then $
	ytitle = '!MF!7 (kV)' else if efield_flag eq 1 then $
	ytitle = 'E Field (mV/m)' else if joule_flag eq 1 then $
	ytitle = 'Joule Heating (mW/m!u2!n)' else $
        ytitle='!MS!7 (mho)'

if efield_flag eq 0 and potential_flag eq 0 then begin	;plot a frame, SIMPLE!

  plot,step_t_sec_sort,amie_dat_sort, $
 	xticks=num_xticks,xtickname=blanks,/nodata,$
	title=title_s,noerase=noerase_flag,ytitle=ytitle,$
	yrange=[bottomofrange,topofyrange],xrange=[0,maxx],/xstyle,/ystyle

;  print,amie_dat_sort,'AMIE DAT SORT'

  plots,[!x.crange(0),!x.crange(1)],[0,0],linestyle=2,thick=1

  if keyword_set(times) eq 1 then begin
    print,'Drawing vertical lines'

    for i=0,n_elements(time_arr)-1 do begin

      xtimepos= time_arr(i)- min(ut)
      print,xtimepos
      plots,[xtimepos,xtimepos],[!y.crange(1),!y.crange(0)],linestyle=2,thick=4
    endfor
  endif
endif

;---find times at which to break up orbits.

breaker=ut_sort-shift(ut_sort,1)

;---begin plots
;---plot for each spacecraft separately
;---also attempt to plot each orbit separately

for i=0,sc_to_plot-1 do begin
							;I know I could use
  sc_range=where(sc_arr_sort eq sc_arr(uniquity(i)),range_count)  
							;sc_arr_sort(uniquity..
							;SO?!
  sc_id= sc_arr(uniquity(i))
  if sc_id eq 6 then min_value = -31 else min_value = -998
  sc_breaker=breaker(sc_range+1)
  if sc_id ge 0 then begin				;HACKEROOOO!!!!

;----maybe do the e-fields _here_
;
;  AMIE should always provide the Potential only
;  DMSP on the other hand will always provide the E-Field. The potential
;  would have to be calculated from the SC data, and I did that at one
;  point.
;

      if (keyword_set(efield) or potential_flag eq 1) $       ;added 05-12-2000
	and calc_efield_flag eq 1 then begin                  ;do NOT calculate
							      ;efields from 
							      ;EFIELDS!!!

        angular_distances=fltarr(range_count) ;efield will be 
	actual_distances=fltarr(range_count)  ;one smaller
	new_amie_data=fltarr(range_count)     ;as well as the new amie data
	new_sat_data=fltarr(range_count)	;and the new sat data
	all_new_amie=amie_dat_sort & all_new_amie(*)=0
        all_new_sat=amie_dat_sort & all_new_sat(*)=0
        a_ang=mlat(sc_range)                  ;*!pi/180.
        X_ang=mlt_(sc_range)                  ;*!pi/180.
        for jj=0,range_count-2 do begin
;	  angular_distances(jj)=acos(cos(a_ang(jj))*cos(a_ang(jj+1)) + $
;	   	 		sin(a_ang(jj))*sin(a_ang(jj+1)) * $
;       				cos(X_ang(jj)-X_ang(jj)))
	  actual_distances(jj)=distance(a_ang(jj),X_ang(jj),$
					a_ang(jj+1),X_ang(jj+1))


;------doing nearest neighbors differences to calculate electric field

	  if potential_flag eq 0 then begin		;convert amie data to E

  	    new_amie_data(jj)=amie_dat_sort(sc_range(jj))- $ 
				(amie_dat_sort(sc_range(jj+1)))

;---this is also unnecessary if the satellite data are electric fields already
;---03-29-2000

;	  new_sat_data(jj)=sat_dat_sort(sc_range(jj))- $
;				(sat_dat_sort(sc_range(jj+1)))

	    new_sat_data(jj)=sat_dat_sort(sc_range(jj))


;------------------------------------------------------------------------
	  endif else begin				;convert SC data to Phi
            new_amie_data(jj)=amie_dat_sort(sc_range(jj))
	    new_sat_data(jj+1)=sat_dat_sort(sc_range(jj+1))+new_sat_data(jj)

	  endelse
        endfor

        if potential_flag eq 0 then begin
	    new_amie_data=new_amie_data/actual_distances
	    new_amie_data=new_amie_data*1000.         ;  now mV/meter
						      ;  added -1 on 03-29-2000
						;and removed it, -1 is done
						;in differencing scheme above
        endif else begin

	    new_sat_data=new_sat_data*actual_distances	;it's OK to do it all
	    new_sat_data=new_sat_data/1000.		;at once, I think
	    new_sat_data=new_sat_data*(-1)
	    print,'******************'
	    print,'DOING SOMETHING'
	    print,'******************'
							;otherwise could
							;be done in the loop
        endelse
;---apply median filter if necessary
	spike_size=25			;tight!
  	thing1=new_amie_data-shift(new_amie_data,1)
	thing2=(new_amie_data-shift(new_amie_data,-1))
print,'***********************************************'
	found_1=where(THING1 GT spike_size)
	found_2=WHERE(THING2 GT spike_size)
print,'***********************************************'
	findspike=where(abs(thing1) gt 30,spikes)	;30 spike threshold
	if spikes gt 0 then begin
	          for ij=0,spikes-1 do $	
		  new_amie_data(findspike(ij))=$
			median(new_amie_data(0>(findspike(ij)-2):$
					(range_count-2)<(findspike(ij)+2)))
	endif
;---assuming kV is potential, then dividing by km->volts/meter
;	actual_distances=angular_distances*7000.	

	print,amie_dat_sort(sc_range),'^Original AMIE^'
	print,sat_dat_sort(sc_range),'^Original Sat Data^'
	print,new_sat_data, '^New Sat Data^'
        print,new_amie_data, '^New AMIE Data^'

	help,amie_dat_sort,sat_dat_sort,new_sat_data,new_amie_data
;	print,actual_distances, '^Actual Distances^'



;--------DMSP data is ALREADY straight  electric field
;        new_sat_data=new_sat_data/actual_distances
;	new_sat_data=new_sat_data*1000.  ;/2. ;2 was a hack, but still of 
					 ;concern as to why aaron and I were
					 ;different
	all_new_sat(sc_range)=new_sat_data
	all_new_amie(sc_range)=new_amie_data

;---first change values in satellite data

;---then adjust AMIE values
        
      endif	;what is this the end of? keywordset(efield) or potential_flag


    spacecraft_=spacecraft_strings(sc_id)	;hack this in to pass back
						;to main routine


      if keyword_set(efield) or potential_flag eq 1 then begin
        if calc_efield_flag eq 0 then begin            ;all these hacks. ....
          new_amie_data=amie_dat_sort(sc_range)
          new_sat_data=sat_dat_sort(sc_range)
        endif
        bottomofrange=fix(min(new_amie_data) < min(new_sat_data))
        bottomofrange=(bottomofrange <0)		;make sure
        if bottomofrange lt 0 then bottomofrange=bottomofrange - 1

	  if potential_flag eq 0 then ytitle = 'E along track (mV/m)'

        if i eq 0 then plot,step_t_sec_sort,amie_dat_sort, $
	  xticks=num_xticks,xtickname=blanks,/nodata,$
	  title=title_s,noerase=noerase_flag,ytitle=ytitle,$
	  yrange=[bottomofrange,-1*bottomofrange],xrange=[0,maxx],$
          /xstyle,/ystyle
;	  yrange=[-50,50],xrange=[0,maxx],/xstyle,/ystyle

        plots,[!x.crange(0),!x.crange(1)],[0,0],linestyle=2,thick=1

	oplot,step_t_sec_sort(sc_range),new_amie_data
	if joule_flag eq 1 or spacecraft_ eq 'Sonde' $
		then oplot,step_t_sec_sort(sc_range),$
		new_amie_data,psym=7

        oplot,step_t_sec_sort(sc_range),new_sat_data,$
	  linestyle=(sc_id+1)mod 4+1,thick=!p.thick + 1,min_value=min_value
        if joule_flag eq 1 or spacecraft_ eq 'Sonde' $
		then oplot,step_t_sec_sort(sc_range),$
		new_sat_data,psym=7

print,'FUCKING SPACECRAFT_',spacecraft_


      endif else begin	  ;simply oplot conductances in frame made earlier

        oplot,step_t_sec_sort(sc_range),amie_dat_sort(sc_range)
        if joule_flag eq 1 or emag_flag eq 1 $
		then oplot,step_t_sec_sort(sc_range),$
		amie_dat_sort,psym=1
        oplot,step_t_sec_sort(sc_range),sat_dat_sort(sc_range),$
	  linestyle=(sc_id+1)mod 4+1,thick=!p.thick + 1,min_value=min_value
        if joule_flag eq 1  $
		then oplot,step_t_sec_sort(sc_range),$
		sat_dat_sort,psym=7

      endelse

;---joke of an attempt to do multiple plots abandoned for now
;    sc_breaker=where(abs(sc_breaker) gt 200 and sc_breaker lt 20000,breaks)
;    if breaks eq 0 then begin		;0 means no breaks in a single SCs data
;    endif else begin			;have breaks to NOT plot over
;      sc_breaker_new=fltarr(breaks + 1)
;      sc_breaker_new(1:breaks)=sc_breaker
;      sc_breaker_new(0)=0			;need first one!
						;4000 seconds
						;minus one to indicate
						;last good index in orb
;      for jj=1,breaks-1 do begin
;	oplot,step_t_sec_sort(sc_breaker_new(jj):sc_breaker_new(jj+1)-1),$
;	      amie_dat_sort(sc_breaker_new(jj):sc_breaker_new(jj+1)-1)
;        oplot,step_t_sec_sort(sc_breaker_new(jj):sc_breaker_new(jj+1)-1),$
;	      sat_dat_sort(sc_breaker_new(jj):sc_breaker_new(jj+1)-1)
;print,step_t_sec_sort(sc_breaker_new(jj):sc_breaker_new(jj+1)-1)
;      endfor
;    endelse
;stop


    totxsize=!p.position(2)-!p.position(0)
    totysize=!p.position(3)-!p.position(1)
    ystep=totysize/15.
    xyouts,!p.position(2)-totxsize*.14,!p.position(3)-ystep*(i+1),$
	spacecraft_strings(sc_id)+':',charsize=1.0,/norm



    plots,[!p.position(2)-totxsize*.08,!p.position(2)],$
      [!p.position(3)-ystep*(i+1)+0.0055,!p.position(3)-ystep*(i+1)+0.0055],$;
      linestyle=(sc_id + 1) mod 4 + 1,thick=2,/norm

  endif


endfor

;---difference plots

!p.position=pos_arr(*,1)



  if efield_flag eq 1 and calc_efield_flag eq 1 then amie_dat_sort=all_new_amie
  if efield_flag eq 1 and calc_efield_flag eq 1 then sat_dat_sort=all_new_sat

  difference=amie_dat_sort - sat_dat_sort    ;positive if amie is bigger



;  if efield_flag eq 1 or potential_flag eq 1 $
;		then difference=all_new_amie-all_new_sat

  max_diff=max(abs(difference))

  diff_base='Difference '
  if small_flag then diff_base = 'Diff. '

  if potential_flag eq 1 and efield_flag eq 0 then $
    ytitle=diff_base + '(kV)' else $
    if efield_flag then ytitle=diff_base + ' (mV/m)' else $
	ytitle=diff_base + '(mho)'
  xtickname=blanks
  xtitle=' '
  if keyword_set(utx) then xtickname=time_labs
  if keyword_set(utx) then xtitle='UT'
  plot,step_t_sec_sort,difference,xtickname=xtickname,ytitle=ytitle,$
	xticks=num_xticks,/noerase,/nodata,yrange=[0,topofyrange+ 1],/ystyle,$
	xrange=[0,maxx],/xstyle,min_value=0,yminor=1,xtitle=xtitle
  oplot,step_t_sec_sort,difference
  oplot,step_t_sec_sort, -1*difference,linestyle=1  
  print,'average difference' , total(difference)/n_elements(difference)
  help_dif=where(difference lt 1000 and difference gt -1000,do_diff_help)
  if do_diff_help gt 0 then $
	print,'average difference' , total(difference(help_dif))/n_elements(difference(help_dif))
	print,total(difference),total(difference(help_dif)),do_diff_help,'HELP!'


;---STATS---
;---calculate average difference-----------------------------------
  avg= total(difference(help_dif))/n_elements(difference(help_dif))
  s_avg=strcompress(avg,/rem)

;---calc standard deviation of difference
  sigma= total(difference(help_dif)^2)-n_elements(difference(help_dif))*avg^2
  sigma= sigma /float( n_elements(difference(help_dif-1)))
  sigma= sqrt(sigma)
 
;---calculate correlation between amie and data set
  helper=size(amie_dat_sort(help_dif)) & NN=helper(1)
  term1=total(amie_dat_sort(help_dif)*sat_dat_sort(help_dif))
  term2=NN*mean(amie_dat_sort(help_dif))*mean(sat_dat_sort(help_dif))
  term3=total(amie_dat_sort(help_dif)^2)-NN*(mean(amie_dat_sort(help_dif))^2)
  term4=total(sat_dat_sort(help_dif)^2)-NN*(mean(sat_dat_sort(help_dif))^2)
  RR=(term1-term2)/(term3*term4)^(0.5)
;  print,RR,'Correlation Coefficient!!!'
  





;-------------------------------------------------------------------

  sign_help=0
  if avg lt 0 then sign_help =1
  xyouts,!p.position(2)-0.12, !p.position(3)-0.02-0.004*!p.charsize,'Avg = ' + $ 
		strmid( s_avg,0,3 + 1*sign_help ),/norm
  xyouts,!p.position(2)-0.12,!p.position(3)-0.047-0.008*!p.charsize,'!Ms!7 = ' + $
		strmid(strcompress(sigma,/rem),0,3),/norm

;---mlt plots

if mlt_flag eq 1 then begin

  !p.position=pos_arr(*,2)
  ytitle='MLT (hrs)'
  if small_flag then ytitle='MLT'

  plot,step_t_sec_sort,mlt_sort/15.,xtickname=blanks,ytitle=ytitle,$
	xticks=num_xticks,/noerase,/nodata,yrange=[0,24],/ystyle,$
	xrange=[0,maxx],/xstyle

  for i=0,sc_to_plot-1 do begin
    sc_range=where(sc_arr_sort eq sc_arr(uniquity(i)))
    oplot,step_t_sec_sort(sc_range),mlt_sort(sc_range)/15.
  endfor

endif

;--- mlat plots

if mlat_flag eq 1 then begin

  !p.position=pos_arr(*,3-(1-mlt_flag))
  ytitle='MLat (deg)'
  if small_flag then ytitle='MLat'

  plot,step_t_sec_sort,mlat_sort,xtickname=time_labs,ytitle=ytitle,$
	xtitle='UT',xticks=num_xticks,/noerase,/nodata,yrange=[50,90],$
	/ystyle,xrange=[0,maxx],/xstyle,yminor=2

  for i=0,sc_to_plot-1 do begin
    sc_range=where(sc_arr_sort eq sc_arr(uniquity(i)))
    oplot,step_t_sec_sort(sc_range),mlat_sort(sc_range)
  endfor

endif 

!p.position=old_position

end

;-----------------end plot conductance----------------------------
;*****************************************************************
;*****************************************************************
;*****************************************************************
;---begin other subs


pro gut_filename,filename,ext

;    Purpose:given an evil filename like this.file.is.too.damn.long
;            will return the _final_ extension. (here, long)
;

  counter=0
  truth=0
  gutfilename=filename

  while truth ge 0 do begin
    position=strpos(gutfilename,'.')
    counter=position+counter+1
    gutfilename=strmid(gutfilename,position+1,strlen(gutfilename))
    truth=strpos(gutfilename,'.')
  endwhile 

  ext=strmid(filename,counter ,strlen(filename)  )


  return

end

;----------make this get_jh subroutine more efficient, please!!!!

pro get_jh_loc_2,namiein, data_dir, date, time, dt, minlat, $
		  spacecraft,datatype_nopass, data1,data2,data3,$	
		  mlat,mlt_,ut__time,$
		  sc_arr,kloc_arr,spacecraft_strings

;
;  Working on the assumption that we'll be looking at joule heating
;  at the resolution of the conductance data, put the efields and
;  conductances in overlying 2d grids, interpolate the efields to 
;  all positions in the grid (it's more sparse, but conductance data
;  are less frequent), then calculate jh,
;  returning the jh at all points where conductances are reported.
;  in the same format as data1 and data2 would be returned otherwise
;---have to rebin this data.
;
;  BTW- this is MUCH faster!!!!
;

datatype='ped'
get_data_loc,namiein, data_dir, date, time, dt, minlat, $
		  spacecraft,datatype, data1,data2,mlat,mlt_,ut__time,$
		  sc_arr,kloc_arr,spacecraft_strings


thing=where(data1 ne -999,pedersengood)  ;-999 indicates unfilled data.
print,'pedersengood',pedersengood	 
if pedersengood le 1 then goto,SKIPJH

pedersen=data1
pedersen_mlat=mlat
pedersen_mlt_=mlt_
pedersen_ut__time=ut__time
ped_sc_arr=sc_arr
ped_kloc_arr=kloc_arr


datatype='pot'		;woo don't screw this up

get_data_loc,namiein, data_dir, date, time, dt, minlat, $
		  spacecraft,datatype, data1,data2,mlat,mlt_,ut__time,$
		  sc_arr,kloc_arr,spacecraft_strings


;cleanup efields	-32.7700 is GARBAGE!!!

_helper=where(data1 eq -32.77)
if _helper(0) gt -1 then begin
  data1(_helper)=-999
  data2(_helper)=-999
endif

thing2=where(data1 ne -999,efieldgood)
print,'efieldgood',efieldgood
efield=data1 & efield(*)=-999
efield_mlat=mlat
efield_mlt_=mlt_
efield_ut__time=ut__time
if efieldgood gt 0 then begin 
  print,data1(thing2),'efields'
  efield(thing2)=( (data1(thing2)/1000.)^2 + (data2(thing2)/1000.)^2)^(0.5)
						;efields are in mV/m
						;convert such that jh comes out
  						;in W/meter^2
endif


yindices=fix((pedersen_mlat(thing)-min(pedersen_mlat(thing)))*4) 
				; 4 gets us in ballpark of 1 degree per bin
ysize=max(yindices)+1		;plus one `cause the indices start with zzzero
ylats=(yindices)/4. +min(pedersen_mlat(thing))
ylats=ylats(uniq(ylats,sort(ylats)))

;  interpolate efield latitudes in this array to find comparable indices in 
;  conductance array

thing3=uniq(pedersen_mlt_(thing))	;uniq is WEAK!!! It requires monotonic
					;ordering! This is news to me.
					;THESE times are in ascending order
					;so this works here.


				;find out how many mlts to be plottin
times=size(thing3) & times=times(1)
xindices=pedersen_mlt_(thing)
for i=0,times-1 do begin
  xindices(where(xindices eq xindices(thing3(i))))=i
endfor

;create (recreate??) array of times vs indices for lookup for efields
xtimes=pedersen_mlt_(thing)			;select good mlt values
xtimes=xtimes(thing3)				;get one of each uniq. mlt

;interpolate individual efield times in xtimes
;to find comparable index in conductance array

ped_arr=fltarr(times,ysize)
elec_arr=ped_arr
ped_arr(xindices,yindices)=pedersen(thing)

elec_xpos=interpol(indgen(times),xtimes,efield_mlt_(thing2))
elec_ypos=interpol(indgen(ysize),ylats,efield_mlat(thing2))
					;want indices from electric times
					;and lats, not new efields yet.

elec_in_cond=where(elec_xpos gt 0 and elec_xpos lt (times-1) $
	           and elec_ypos gt 0 and elec_ypos lt (ysize-1))

;where interpolates indicate that efields are within range of pedersen measur.
;-999 values would be filtered out above, but I have done it before...

elec_arr(elec_xpos(elec_in_cond),elec_ypos(elec_in_cond))= $
					efield(thing2(elec_in_cond))

;fill the efield array at xpos,ypos with good values which also lie in elec_in

jh_arr=elec_arr^2*ped_arr*1e3	;UNITS TO mW/m

jh=pedersen & jh(*)=-999
jh(thing)=jh_arr(xindices,yindices)




ut__time=pedersen_ut__time
mlat=pedersen_mlat
mlt_=pedersen_mlt_
kloc_arr=ped_kloc_arr
sc_arr=ped_sc_arr


data1=jh
data2=pedersen
data3=efield


;stop

;
;  going to go the other way later
;  jh(pedersengood)=jh_arr(xindices,yindices)
;

SKIPJH:


end

;---------------------------------------------------------------
pro get_jh_loc,namiein, data_dir, date, time, dt, minlat, $
		  spacecraft,datatype_nopass, data1,data2,data3,$	
		  mlat,mlt_,ut__time,$
		  sc_arr,kloc_arr,spacecraft_strings
print,'retrieving conductances'

;  procedure to call conductances AND efields to get sjh.
;  notes - MUCH more complex than initially suspected as efields
;  and conductances have different latitudinal range
;
;  assigning an efield for each conductance measurement is EASIER.
;  Doing it the other way is 'making up' data
;  
;  search by mlt and mlat, ut is not really important since the 
;  mlt of efields and conductance measurements is about the same
;
;  I should rebin the data into 2d arrays of mlatitude and local time.
;  That would be faster and LESS of a hack!!!
;
;

datatype='ped'
get_data_loc,namiein, data_dir, date, time, dt, minlat, $
		  spacecraft,datatype, data1,data2,mlat,mlt_,ut__time,$
		  sc_arr,kloc_arr,spacecraft_strings

print,'retrieving potentials'
thing=where(data1 ne -999,pedersengood)
print,'pedersengood',pedersengood
pedersen=data1
pedersen_mlat=mlat
pedersen_mlt_=mlt_
pedersen_ut__time=ut__time
ped_sc_arr=sc_arr
ped_kloc_arr=kloc_arr


datatype='pot'		;woo don't screw this up

get_data_loc,namiein, data_dir, date, time, dt, minlat, $
		  spacecraft,datatype, data1,data2,mlat,mlt_,ut__time,$
		  sc_arr,kloc_arr,spacecraft_strings


;cleanup efields	-32.7700 is GARBAGE!!!

_helper=where(data1 eq -32.77)
if _helper(0) gt -1 then begin
  data1(_helper)=-999
  data2(_helper)=-999
endif

thing2=where(data1 ne -999,efieldgood)
print,'efieldgood',efieldgood
efield=data1 & efield(*)=-999
efield_mlat=mlat
efield_mlt_=mlt_
efield_ut__time=ut__time
if efieldgood gt 0 then begin 
  print,data1(thing2),'efields'
  efield(thing2)=( (data1(thing2)/1000.)^2 + (data2(thing2)/1000.)^2)^(0.5)
						;efields are in mV/m
						;convert such that jh comes out
  						;in W/meter^2
endif

;---have to rebin this data.




newefield=pedersen
newmlt=pedersen_mlt_
newmlat=pedersen_mlat
newut=pedersen_ut__time

for j=0,pedersengood-1 do begin  
;
;  first find all points where mlat corresponds closely, then 
;  find the one of those where mlt corresponds best. This is simple,
;  but it is not easy!
;  this is also extremely inefficient
;


  mlat_Finder=where(abs(efield_mlat-pedersen_mlat(j)) eq $
			min(abs(efield_mlat-pedersen_mlat(j)))   ) 

  mlt_Finder=where(abs(efield_mlt_(mlat_finder)-pedersen_mlt_(j)) eq $	
			min(abs(efield_mlt_(mlat_finder)-pedersen_mlt_(j)))) 

  mlat_pos=mlt_finder(0)
  efield_pos=mlat_finder(mlat_pos)
  
  
;  print,mlt_finder,' ',mlat_finder,'compare'
  newefield(j)=efield(efield_pos)
endfor


if thing(0) eq -1 then goto,NODATA

sjh=pedersen

;  want mV/m so one multiplies by 1e3 at the end
;
;	  1/ohms         *     V/m  * V/m           =  Watts/m^2
;    
sjh(thing)=pedersen(thing)*(newefield(thing)^2)*1e3

bad_efields=where(newefield eq -999)
sjh(bad_efields) = -999

print,newefield(thing),'selected electric fields'
print,sjh(thing),'calculated simple joule heating'



;---variables to return


ut__time=pedersen_ut__time
mlat=pedersen_mlat
mlt_=pedersen_mlt_
kloc_arr=ped_kloc_arr
sc_arr=ped_sc_arr


data1=sjh
data2=pedersen
data3=newefield

NODATA:


return
end
;-------------------------------------------------------------

pro get_data_loc, namiein, data_dir, date, time, dt, minlat, $
		  spacecraft,datatype, data1,data2,mlat,mlt_,ut__time,$
		  sc_arr,kloc_arr,spacecraft_strings
;
;   Code originally by AJR now edited by TJI 4-29-99
;   Given a spacecraft name (DMSP or DMSP9???) and the time
;   range, this subroutine should return the available data
;   or a flagged array (-1, -999 ???) saying there is no
;   data during that AMIE period
;
;   data1 and data2 map to 
;   Ecross, Ealong or 
;   Hall, Pedersen Conductivities
;
;   QnA : Size of data arrays : Assume as large as 1000. Someday far
;	  in the future AMIE and spacecraft data will have higher res.
;
;         More than one DMSP/NOAA: You will have to specify which spacecraft.
;		                   This will return 1-D arrays ONLY.
;         What about AXIS!??! : That's not the X-Ray imager, stupid!!!
;				That and MEPS are PEM instruments
;         DMSP : Could be listed as DMSP08 or DMSP8. For now quit trying
;                to select particular satellite
;         Coverage 	  : Looking goooo
;         Multiple passes : UGH. I can have multiple spacecraft passes
;	                    for any particular amie run. I need to
;			    hack something together. (1000,3 will do)
;	  Conductances : first one is Pedersen, second is Hall, i.e. Data1
;			 will be pedersen if ped OR hal is passed as datatype
;         UT           : UT is in a disasterous Real format which represents
;			 seconds from Jan 1, 1965, maybe. Disaster!
;	  added KLOC   : should be helpful in determining 0 point of potential
;	  ALL          : if this is the search string (spacecraft),
;		         use all available data
;	  Sondre/SONDE : Trying to do that data here.

  scale_nt = 25.0
  scale_mv = 3.0

  conductance_flag=0
  potential_flag=0
  if strlowcase(datatype) eq 'ped' or strlowcase(datatype) eq 'hal' then $
    conductance_flag=1
  if strlowcase(datatype) eq 'pot' then potential_flag=1


;---careful with this, data_size could be set too small!~!!!

  data_size=20000
  s_size=7				;implement sometime

  data1=fltarr(data_size,s_size)  		;init data arrays...
  data2=fltarr(data_size,s_size)
  sc_arr=intarr(data_size,s_size)		;each datum will be indexed by
					;SC, columns will not be reserved
					;for any particular spacecraft
  mlat=fltarr(data_size,s_size)
  mlt_=fltarr(data_size,s_size)
  ut__time=dblarr(data_size,s_size)		;double underscore to diff from uttime
					;which is ______?
  kloc_arr=intarr(data_size,s_size)

  data1(*)=-999
  data2(*)=-999

  print, date,' ',time

  mr = 90.0 - minlat

  sdate = strmid(date,4,2)+'-'+strmid(date,0,3)+'-'+strmid(date,10,2)+' '
  sdate = sdate + strmid(time,0,5)

  c_s_to_a, itime, sdate
  c_a_to_r, itime, rtime

  stime = rtime - dt		;start time (minus one dt?)
  etime = rtime + 2.0*dt	;end time   (plus two dt???)

  close,11
  openr,11,namiein		;open amie infile

  line = ''
  for i=1,4 do readf,11,line

  files =intarr(6)

  readf,11,files		;2 7 1 10 7 0  -> 10 Efield 7 conductance filez
				;    * ** *       and 1 magnetometer file

;---skip2 for efield files if doing conductances (need to do converse _later_)

  skip = files(0) + files(1) + files(2)
  print,skip,' SKIP'

;---hack here! amie infile header size changes, (some have more directories)
  if strpos(namiein,'980') gt 0 then begin
    print,'Probably a recent amieinfile (e.g. vs. Nov93)'
    skip=skip+2		;2 lines which just give a dir. probably exist!
  endif

  skip2=  files(3)*conductance_flag
  print,skip2,' SKIP2'

  for i=1,skip do begin
    readf,11,line
    print,line
  endfor

  if (files(2) gt 0) then begin			;there is a mag file
    magfile = data_dir + strmid(line,8,18)
    magfile = strcompress(magfile,/remove_all)
  endif

  if conductance_flag then for i=1,skip2 do begin
     if i eq 1 then print,'Reading efield lines'
     readf,11,line  ;--skip efield files
     print,line 

  endfor

  itime = intarr(6)
  latlon = fltarr(3)
  kloc = 0
  ang1n = 0.0
  en = 0.0
  ee = 0.0
  estring = ''


  for k=0,0 do begin				;once for E OR sigma

    num_to_read=files(3 + conductance_flag)

;---this index moved out of conductance/efield loop. HOW did my code WORK???

    spacecraft_strings=['DMSP-F08','DMSP-F10','DMSP-F11','NOAA-12',$
		'MEPS','AXIS','SONDRESTR','DMSP-F12','DMSP-F13',$
		'DMSP-F14']
;---be sure to mirror the above in the proper subroutines

    spacecraft_index=0		; POSSIBLE TO HAVE MORE THAN ONE PASS

    for i=0,num_to_read-1 do begin		;efields OR conductance

      readf,11,line

      line = strcompress(line)
      print,i,line, 'THIS IS THE LINE IT JUST READ'

;-----pac man 5 character strings off the front of the read line 
 
      oldline=line
      for j=0,5 do line = strmid(line, strpos(line,' ')+1,strlen(line))
      filein = strmid(line,0,strpos(line,' '))
      filein = data_dir + filein

;-----must be more discriminating than Aaron ;)

      print,"Searching "+filein +  " file for : " + spacecraft
      comparator=strpos(strupcase(oldline),strupcase(spacecraft))
      print,'Comparator : '  + string(comparator);

;-----to implement 'ALL' should rewrite comparator to loop, will still
;-----be -1 at this point if 'ALL' is passed. 

      if strupcase(spacecraft) eq 'ALL' then begin
        for j=0,n_elements(spacecraft_strings)-1 do begin
          newstring=strupcase(strmid(spacecraft_strings(j),0,4))
          comparator=strpos(strupcase(oldline),newstring)
          print,'all_comparator',oldline,' ',newstring,comparator
          if comparator gt -1 then goto, DOING_ALL
        endfor
        DOING_ALL:
      endif 
 
      if comparator gt -1 then begin	; BEGIN SPACECRAFT FILE READ LOOP

;-----Uniquely identify spacecraft

	spacecraft_ct=size(spacecraft_strings) & spacecraft_ct=spacecraft_ct(1)

	SC_ID=-1			; initialize the id number
      
        close,12
        openr,12,filein
        readf,12,line
        SC=strmid(line,6,10)		;may have following text, kill that.
					;only 6 spaces for number, I may
					;have to be more careful HERE! error

        SC=strmid(SC,0,9)
	print,sc, 'Before Parsing'
        parse=strpos(SC,' ')

;--take care of UARS, selecting AXIS or MEPS from the TAIL OF THE STRING

        if parse gt 0 and strpos(SC, 'UARS') eq -1 then $
	  SC=strmid(SC,0,parse)	else SC=strmid(SC,parse,strlen(SC))

        SC=strcompress(SC,/rem)
        print,SC

;---here is my problem with MEPS. I find MEPS but then I switch to UARS
;---I HAVE To be SPECIFIC, though, since I have DMSP-08-10-11

	for ii=0,spacecraft_ct-1 do begin
	  
	  thing=strpos(spacecraft_strings(ii),strcompress(strupcase(SC),/rem))
	  print,spacecraft_strings(ii),strupcase(SC)
	  if thing gt -1 then SC_ID=ii
	
        endfor

        readf,12,line
        if (strpos(line,'year') lt 0) then readf,12,line

;        id_switch=0		      ;what was I going to do with this?!?!
        
        done = 0
	counter=0		      ;counter indicates position in data arr

        while (not done) do begin
				      ;---neat trick with ITIME
          readf,12,itime,latlon,kloc,ang1n,estring,			$
                format = '(I4,5I3,F6.2,F7.2,F6.2,I5,F7.2,A21)'
          c_a_to_r,itime, uttime
          

          if (uttime ge stime) and 					$
             (uttime le etime) and 					$
             (latlon(0) gt minlat) then begin

;------------------------------------latitude is set to do NH only!!!
;------------------------------------Seems I'm getting a lot more data

	    t = latlon(2)*2.0*!pi/24.0 - !pi/2
	    r = 90.0 - latlon(0)

            x0 = r*cos(t)
            y0 = r*sin(t)

;            plots, [x0], [y0], psym = psym(k)

;----load arrays  (SPACECRAFT TIMES WILL NOT MATCH AMIE TIMES)

            mlat(counter,spacecraft_index)=latlon(0)
            mlt_(counter,spacecraft_index)=latlon(2)
	    kloc_arr(counter,spacecraft_index)=kloc

            ee = float(strmid(estring,0,7))
            data1(counter,spacecraft_index)=ee           
            ens = strcompress(strmid(estring,14,7))
            data2(counter,spacecraft_index)=ens
	    ut__time(counter,spacecraft_index)=uttime
	    sc_arr(counter,spacecraft_index)=SC_ID

;	    print,format='(i2,$)',sc_id

	    counter = counter + 1		;dont forget to advance!!!

            if strlen(ens) gt 1 then en = float(ens) else en = 0.0

            theta = (2.0*!pi - t) mod (2.0*!pi)
            d = (ee^2.0 + en^2.0)^0.5

; want pure north (h) to be 0 degrees, and rotate clock wise is positive

            phi = -1.0*asin(ee/d)
	    if (en lt 0.0) then phi = !pi - phi

            phi = phi - ang1n*!pi/180.0

            phi = !pi + (phi - theta)

            phi = phi + !pi

            xp = x0 + d*cos(phi)/scale_mv
            yp = y0 + d*sin(phi)/scale_mv

;if k eq 0 then $
;           plots, [x0,xp], [y0,yp]

          endif
          if (uttime gt etime) then done = 1
          if (eof(12)) then done = 1
        endwhile

      close,12
      print,spacecraft_index,'Used this index to fill all (*,3) arrays
      spacecraft_index=spacecraft_index + 1

      endif else print, 'No match to your input string' ; end comparator loop

    endfor    ;end loop going through all efields OR conductances

  endfor      ;end loop going through all efields AND conductances

;---- no need passing 1000 -999 values
  thing1=where(data1 ne -999,count1)
  thing2=where(data2 ne -999,count2)
  if count1 eq -1 then data1=-999
  if count2 eq -1 then data2=-999
  if count1 eq -1 and count2 eq -1 then mlat=-1   
  if count1 eq -1 and count2 eq -1 then mlt_=-1   

  done = 0
  cnt = 0

  while (not done) do begin
    readf,11,line
    if eof(11) then done = 1
    if (strpos(line, '&') ge 0) then cnt = cnt + 1
    if cnt eq 4 then done = 1
  endwhile

;  t = findgen(10)*2.0*!pi/9
;  r = 0.5
;  usersym,r*cos(t),r*sin(t),/fill

  if (not eof(11)) then begin
    readf,11,line
    nstat = fix(strmid(line,0,3))
    readf,11,line
    lat = fltarr(nstat)
    lon = fltarr(nstat)
    sta = strarr(nstat)
    n = 0
    for i=0,nstat-1 do begin
      readf,11,line
      lat(n) = 90.0-float(strmid(line,36,6))
      lon(n) = float(strmid(line,42,7))*!pi/180.0
      sta(n) = strmid(line,4,3)
      if (lat(n) lt mr) then begin
      n = n + 1 
      endif
    endfor

    lat = lat(0:n-1)
    lon = lon(0:n-1)
    sta = sta(0:n-1)

    c_r_to_a, itime, stime+dt
    h = float(itime(3))*60.0
    m = (float(itime(4))+h - 4.0*60.0 - 47.0)/4.0 * !pi/180.0

    lon = lon + m - !pi/2.0

    xpos = lat*cos(lon)
    ypos = lat*sin(lon)

    xpos2 = xpos
    ypos2 = ypos

    stime = stime + dt

;----forget the rest of this!~!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GOTO,ENDOFTHISROUTINE

    close,12
    openr,12, magfile

    done = 0
    total = 0

    while (not done) do begin
      readf,12,line
      itime(0) = fix(strmid(line,0,2))  
      itime(1) = fix(strmid(line,2,2))
      itime(2) = fix(strmid(line,4,2))  
      itime(3) = fix(strmid(line,7,2))  
      itime(4) = fix(strmid(line,9,2))
      itime(5) = 0
      c_a_to_r,itime, uttime
      if (uttime ge stime) and 					$
         (uttime le etime) then begin
        etime = uttime
        stat_test = strmid(line,12,3)
        i = -1
        found = 0
        j = 0
        while (i eq -1) and (j lt n) do begin
          if (sta(j) eq stat_test) then begin
            i = j
            found = 1
          endif
          j = j + 1
        endwhile
        if (i eq -1) then done = 1				$
        else begin

	  total = total + 1
	  if total eq n then done = 1

	  h = float(strmid(line,19,6))
	  e = float(strmid(line,25,6))

;          if (abs(h) lt 2000.0) and (abs(e) lt 2000.0) then begin

;            theta = (2.0*!pi - lon(i)) mod (2.0*!pi)
;            d = (h^2.0 + e^2.0)^0.5

; want pure north (h) to be 0 degrees, and rotate clock wise is positive

;            phi = -1.0*asin(e/d)
;	    if (h lt 0.0) then phi = !pi - phi

;            phi = !pi + (phi - theta)

; want to rotate counter clock wise 90 deg to the direction of convection

;            phi = phi + !pi/2.0

;            xpos2(i) = xpos(i) + d*cos(phi)/scale_nt
;            ypos2(i) = ypos(i) + d*sin(phi)/scale_nt

;            plots, [xpos(i)], [ypos(i)], psym = 8
;            plots, [xpos(i),xpos2(i)], [ypos(i),ypos2(i)]

;          endif

        endelse

      endif

    endwhile

; plot scale

    xnt = 0.0
    ynt = -100.0

    x0 = mr
    y0 = mr

;    plots, [x0], [y0], psym = 8
;    plots, [x0,x0+xnt/scale_nt], [y0,y0+ynt/scale_nt]

;    xyouts, mr-2.0, mr-2.0, '100 nT', alignment = 1.0, charsize = 0.6

  endif

  ENDOFTHISROUTINE:	;The devil made me goto

  close,11,12

  return

end


function sign, value

  loc = where(value ne 0.0,count)

  x = fltarr(n_elements(loc))+1.0

  if (count ne 0) then x(loc) = value(loc)/abs(value(loc)) 

  return,x

end

pro read_gang, filein, ltpos, lnpos, data, time, date, lats, lons, type

  type = 'Electric Potential'

  line = ''
  filein = filein+'.amiedat'

  year = 0
  print, 'Enter Year :'
  read, year
  if year lt 100 then year = year + 1900
  if year lt 1950 then year = year + 100
  year = tostr(year)

  month = 0
  print, 'Enter Month (1-12) :'
  read, month

  mon = 'JanFebMarAprMayJunJulAugSepOctNovDec'

  day = 0
  print, 'Enter Day :'
  read, day

  datei = strmid(mon,(month-1)*3,3)+' '+tostr(day)+', '+year

  close,1
  openr,1,filein

  readf,1, line
  readf,1, line
  lats = fix(strmid(line,6,3))

  readf,1, line
  readf,1, line
  lons = fix(strmid(line,7,3))
  for i=0,1 do readf,1,line
  ltpos = fltarr(lons,lats)
  lnpos = fltarr(lons,lats)
  for i=1,lons do for j=1,lats do begin
    ltpos(i-1,j-1) = float(j-1)*(90.0-50.0)/float(lats-1)
    lnpos(i-1,j-1) = 180.0 - float(i)*360.0/float(lons)
  endfor

  loc = where(lnpos lt 0.0, count)

  if count gt 0 then lnpos(loc) = lnpos(loc) + 360.0

  data = fltarr(1,lons,lats)
  fakedata = fltarr(1,6)
  dum = 1.0
  count = 0
  while (not eof(1)) do begin

    readf,1,line
    print, line
    hr = strmid(line,8,2)
    mi = float(strmid(line,10,3))*60.0
    readf,1,line
    if count gt 0 then begin
      data = [data, fltarr(1,lons,lats)]
      time = [time,hr+':'+chopr('0'+tostr(round(mi)),2)+' UT']
    endif else time = hr+':'+chopr('0'+tostr(mi),2)+' UT'

    for i=0,35 do begin
      for j=0,3 do begin
        readf,1, format = '(6E13.5)',fakedata
        data(count,i,j*6:(j+1)*6-1) = fakedata(0,*)
      endfor
      readf,1, format = '(1E13.5)',dum
      data(count,i,24) = dum
    endfor

    count = count + 1

  endwhile

  close,1

  date = strarr(count)

  for i=0,count-1 do date(i) = datei

  print, 'There were ',tostr(count),' times found'

  return

end

pro read_aaron, filein, ltpos, lnpos, data, time, date, lats, lons, type

  type = 'Electric Potential'

  line = ''
  fileti = filein+'.time'
  filein = filein+'.dat'

  close,1
  openr,1,filein

  readf,1, line
  readf,1, line
  lons = fix(strmid(line,13,3))

  for i=0,7 do readf,1,line
  readf,1, line
  lats = fix(strmid(line,12,3))
  for i=0,5 do readf,1,line
  ltpos = fltarr(lons,lats)
  lnpos = fltarr(lons,lats)
  for i=1,lons do for j=1,lats do begin
    ltpos(i-1,j-1) = float(j-1)*(90.0-50.0)/float(lats-1)
    lnpos(i-1,j-1) = 180.0-float(i)*360.0/float(lons)
  endfor

  loc = where(lnpos lt 0.0, count)

  if count gt 0 then lnpos(loc) = lnpos(loc) + 360.0

  data = fltarr(1,lons,lats)
  fakedata = fltarr(1,6)
  count = 0
  while (not eof(1)) do begin

    readf,1,line
    print, line
    if count gt 0 then data = [data, fltarr(1,lons,lats)]

    for i=0,24 do for j=1,36,6 do begin
      readf,1, format = '(6E13.5)',fakedata
      data(count,(j-1):(j+4),i) = fakedata(0,*)
    endfor

    count = count + 1

  endwhile

  close,1,2
  openr,2,fileti
  readf,2, line
  readf,2, line
  year = strmid(line,1,4)
  mon = 'JanFebMarAprMayJunJulAugSepOctNovDec'
  date = strarr(count)
  time = strarr(count)
  dt = fix(strmid(line,7,3))
  nt = fix(strmid(line,12,3))
  for i=0,count-1 do begin
    if (i eq 0 or nt eq 1) then begin
      readf,2,line
      month = fix(strmid(line,1,2))
      date(i) = strmid(mon,(month-1)*3,3)+' '+strmid(line,3,2)+', '+year
      h = fix(strmid(line,6,2))
      m = fix(strmid(line,8,2))
    endif else begin
      m = m + dt
      if (m ge 60) then begin
        m = m - 60
        h = h + 1
      endif
    endelse
    time(i) = chopr('0'+tostr(h),2)+':'+chopr('0'+tostr(m),2)+' UT'
  endfor
  close, 2

  return

end

pro read_barbara, filein, ltpos, lnpos, data, time, date, lats, lons,	$
    type, spd, by, bz

;  TJI says- I want KLOC, too!
;

  close,1
  openr,1,filein
 
  line = ''
  readf,1, line
  start = strpos(line, "AMIE")-20
  lons = fix(strmid(line,start+16,3))+1
  lats = fix(strmid(line,start+12,3))+1
  count = fix(strmid(line,start,4))
 
  format = '('+tostr(lons)+'E12.4,A5)'

  ltpos = fltarr(lons,lats)
  lnpos = fltarr(lons,lats)
  lts = fltarr(lats)
  fakedata = fltarr(1,lons)
  date = strarr(count)
  time = strarr(count)
  data = fltarr(count,lons,lats)
  by   = strarr(count)
  bz   = strarr(count)
  spd  = strarr(count)
  mon = 'JanFebMarAprMayJunJulAugSepOctNovDec'
 
  done = 0
  while not done do begin
 
    readf,1, line
    if strpos(line,"ntime iyear") gt 0 then done = 1
 
  endwhile
 
  type = ''

  for i=0,count-1 do begin
 
    year = strmid(line,5,4)
    month = fix(strmid(line,10,2))
    date(i) = strmid(mon,(month-1)*3,3)+' '+strmid(line,13,2)+', '+year
    h = fix(strmid(line,16,2))
    m = fix(strmid(line,19,2))
    time(i) = chopr('0'+tostr(h),2)+':'+chopr('0'+tostr(m),2)+' UT'

    readf,1, line
    spd(i) = 'Speed : '+strcompress(strmid(line, 0,6),/remove)
    by(i)  = 'By : '+strcompress(strmid(line,12,6),/remove)+' nT'
    bz(i)  = 'Bz : '+strcompress(strmid(line,18,6),/remove)+' nT'
    readf,1, line

    for j=0,lats-1 do begin
 
      readf,1, line
      lts(j) = float(strmid(line,5,5))
      readf,1, format=format,fakedata, type
      data(i,0:lons-1,j) = fakedata(0,0:lons-1)
 
    endfor
 
    if i lt count-1 then readf,1, line
 
  endfor

  close,1

  for i=0,lons-1 do for j=0,lats-1 do begin
    ltpos(i,j) = 90.0 - lts(j)
    lnpos(i,j) = float(i)*360.0/float(lons-1)
  endfor
 
  loc = where(lnpos lt 0.0, count)
 
  if count gt 0 then lnpos(loc) = lnpos(loc) + 360.0

  type = strmid(type,1,strlen(type)-1)

  if (strpos(type,'pot') gt -1) or (strpos(type,'efpo') gt -1) then begin
    data = data/1000.0
    type = 'Electric Potential'
  endif
  if strpos(type,'sigp') gt -1 then type = 'Pedersen Conductance'
  if strpos(type,'sigh') gt -1 then type = 'Hall Conductance'
  if strpos(type,'dfac') gt -1 then type = 'Field Aligned Current'

  return

end

pro read_ipot, filein, ltpos, lnpos, data, time, date, lats, lons, type

  type = 'Electric Potential'

  filelist = findfile(filein)
  count = n_elements(filelist)

  data = fltarr(count,24,33) 
  time = strarr(count)
  date = strarr(count)
  imf = strarr(count,3)

  for i=0,count-1 do begin

    data1 = read_izmem(filelist(i))
    data(i,*,*) = data1.pot*1000.0
    time(i) = data1.time + ' UT'
    imf(i,*) = data1.imf

    date(i) = data1.date
    itime = [fix(strmid(data1.date,2,2)),	$
	     fix(strmid(data1.date,5,2)),	$
	     fix(strmid(data1.date,8,2)),0,0,0]
    c_a_to_s, itime, sdate
    date(i) = strmid(sdate,3,3)+' '+		$
	      strmid(sdate,0,2)+', '+		$
	      strmid(data1.date,0,4)
  endfor

  lnpos = fltarr(24,33)
  ltpos = fltarr(24,33)
  for i=0,32 do lnpos(*,i) = 180-(findgen(24)+0.5)*360.0/24.0 
  for i=0,23 do ltpos(i,*) = findgen(33)+1.0

  loc = where(lnpos lt 0.0)
  lnpos(loc) = lnpos(loc) + 360.0

  fileout = ''

  lats = 33
  lons = 24

  return

end



pro comp_data_amie_6

;
;  Main driver routine (could be superseded?)
;
;  Added orbit_mode flag, which will switch the functionality
;  from repeatedly scanning the data files to summarizing the length of time
;  of the amie run and reading in _all_ the comparable data.
;  
;
;

str_months=['jan','feb','mar','apr','may','jun',$
	  'jul','aug','sep','oct','nov','dec']

filein = ''
fileout = ''
line = ''
filein=dialog_pickfile(title='Find AMIE OUTPUT file',$
path='/we/amie/9805/scratch/',filter='*0.*sjh')

print,'Infile ', filein

;---need to establish datatype I am going to be extracting from satellite
;---passes

gut_filename,filein,datatype
print,'Datatype is : ' + datatype
conductance_flag=0			;flag to plot conductances
potential_flag=0			;flag to plot potentials
efield_flag=0				;efield flag is extremely confusing
					;because sometimes (DMSP) you will
					;want to calculate efields from .pot
					;files, and sometimes we want them
					;from en and ee files. Tough problem
calc_efield_flag=0			;here is part of the solution!

jh_flag = 0				;joule heating plots
emag_flag = 0				;efield magnitude plots
twod_flag = 0				;for 2d data plots
stats_file_flag = 1			;print comparison statistics to file


if strlowcase(datatype) eq 'ped' or strlowcase(datatype) eq 'hal'$
        then conductance_flag=1
if strlowcase(datatype) eq 'pot' then potential_flag=1
if strlowcase(datatype) eq 'sjh' then jh_flag=1		;joule heating flag

if strlowcase(datatype) eq 'ee' then begin
  test_sjh=ask('Plot Magnitude of Electric Field (vs. component)?','N')
  if strupcase(strcompress(test_sjh,/rem)) eq 'Y' then begin
	emag_flag=1
        stopper=strpos(filein,'ee')
        newfile=strmid(filein,0,stopper)+'en'
	print,newfile,'newfile'
  endif
  efield_flag = 1				;new 5-11-2000

endif



if potential_flag then begin

  efield_flag=0
  test_pot=ask('Plot Electric Fields (vs. potential)?','Y')
  if strupcase(strcompress(test_pot,/rem)) eq 'Y' then efield_flag=1
  if efield_flag eq 1 then potential_flag=0
  if efield_flag eq 1 then calc_efield_flag = 1
endif

datatype=strlowcase(datatype);

filetype=3
que$ = ''


  sub = 0
  asub = 0

ppp = 12
pot = 5



;------read AMIE outfile--------


if (filetype eq 3) then $
  read_barbara, filein, ltpos, lnpos, data, amie_time, date, lats, lons,$
        type, spd, by, bz


if emag_flag eq 1 then begin
  read_barbara, newfile, ltpos, lnpos, data_en, amie_time, date, lats, lons,$
        type, spd, by, bz
  data=(data^2+data_en^2)^(0.5)
endif


;;;if datatype eq 'sjh' then data=data*1e3		;Watts per m^2 to mW
;;;---do this in plotting subroutine only



;--------------------------------

;  time and date are 1-D arrays
;
;  print,'AMIE time,date and type' ,time,date,type

timesize=size(amie_time) & timesize=timesize(1);




;----use the returned info from read_barbara to define times in 
;


tmp_data = fltarr(lons,lats)

maxran = 40.0

que=''

plot_data = 0

title='Find namiein file'
if jh_flag eq 1 then title='Find amiein file with BOTH Efields and Conductances'

  namiein=dialog_pickfile(title=title,$
      path='/we/amie/9805/')

;  data_path='/zed/e/amie/9805/d.data/'
data_path='/we/amie/9805/d.data/'

;---holdover from Nov93 days
;  if potential_flag eq 1 or efield_flag eq 1 then data_path=data_path + 'pot/'

  data_dir = ask('data directory',data_path)

  orbit_mode=ask('Do you want to run in single orbit analysis mode','N');
  if strupcase(strmid(orbit_mode,0,1)) eq 'Y' or $
       strupcase(strmid(orbit_mode,0,1)) eq '1' then orbit_mode=1 else $
       orbit_mode=0 

;----delta time window is HERE, immediately converted to seconds

  dt = float(ask('half window size (minutes)','30'))*60.0

;---get dt of entire orbit if orbit_mode is selected
;---also define date_size

  d_amie_time=dblarr(n_elements(amie_time))  

  if orbit_mode eq 1 then begin

    date_size=size(date) & date_size=date_size(1)
    first_last_time=intarr(6,2)
    dfirst_last_time=dblarr(2)

;---convert amie_time string (UGH!) to a useful number
    for ii=0,1 do begin
      yearnum=fix(strmid(date(ii*(date_size-1)),8,4) )
      monthnum=where(str_months eq $
	    strlowcase(strmid(date(ii*(date_size-1)),0,3))) + 1

      daynum=fix(strmid(date(ii*(date_size-1)),4,2))
      hournum=fix(strmid(amie_time(ii*(date_size-1)),0,3))
      minnum=fix(strmid(amie_time(ii*(date_size-1)),3,2))
      secnum=0      
      print,yearnum,monthnum,daynum,hournum,minnum,secnum,'monthnum1'
      first_last_time(*,ii)=[yearnum,monthnum,daynum,hournum,minnum,secnum]
      c_a_to_r,first_last_time(*,ii),bla
      dfirst_last_time(ii)=bla
    endfor
;---could use this handy scheme elsewhere!
    dt=0d
    dt=(dfirst_last_time(1)-dfirst_last_time(0))/2. ;divide for half window.
  endif   ;end 'orbit mode eq 1 if statement'

;---do that again for ALL times regardless of orbit_mode

  d_amie_time=dblarr(n_elements(amie_time))
   
  date_size=size(date) & date_size=date_size(1)
  six_time=intarr(6)

  for ii=0,n_elements(amie_time)-1 do begin
  
    yearnum=fix(strmid(date(ii),8,4) )
    monthnum=where(str_months eq $
	strlowcase(strmid(date(ii),0,3))) + 1

    daynum=fix(strmid(date(ii),4,2))
    hournum=fix(strmid(amie_time(ii),0,3))
    minnum=fix(strmid(amie_time(ii),3,2))
    secnum=0      
;      print,yearnum,monthnum,daynum,hournum,minnum,secnum,'monthnum1'
    six_time(*)=[yearnum,monthnum,daynum,hournum,minnum,secnum]
    c_a_to_r,six_time,bla
    d_amie_time(ii)=bla
  endfor

  plot_data = 1

print,'Dmsp(13,14...),Noaa,Meps,Sonde,UVI,ALL (caps, whatever)'

search_string=ask('Select one of the above data sets','sonde')

if stats_file_flag eq 1 then begin
  get_lun,unit

  name_path_extract,filein,simple_filename,path
  openw,unit,search_string + '_stats.'+simple_filename+ '.txt'


  printf,unit,format='(a8,a6,a8,a8,a8,a6,a6)',$
	'Source,','begUT,','avg,','sigma,','lin corr,','mlat 1,','mlat 2'
  print,'Opened stats file'

endif


if (sub eq 1) and (asub eq 1) then begin
  n1 = 0
  n2 = 0               
  print, 'Enter averaging start n, stop n :'
  read, n1,n2
  data(0,*,*) = data(n1,*,*)
  for n=n1+1,n2 do begin
    data(0,*,*) = data(0,*,*) + data(n,*,*)
  endfor
  data(0,*,*) = data(0,*,*)/(n2-n1+1)
endif

if (sub eq 1) and (asub eq 2) then begin
  runt = 0
  read, 'Enter time period of running average : ', runt
endif



print, 'Date of AMIE plots : ', date(0)
print, 'Start time of file : ',amie_time(0)
print, 'End time of file : ',amie_time(n_elements(amie_time)-1) 
n2 = n_elements(amie_time)
print, 'Number of plots in File : ',n2
n1 = fix(ask('starting plot number','0'))
n2 = fix(ask('starting plot number',tostr(n2-1)))
if n2 ge n_elements(amie_time) then n2 = n_elements(amie_time)-1
skip_number=fix(ask('Plot every n_th AMIE timestep','7'))
plot_number=fix(ask('How many plots per page (1,2,or 4)?','1'))

;********** PS QnA


fileout = ask(' any characters to create postscript (return for screen)', ' ')
if strcompress(fileout) ne ' ' then begin
  name_path_extract,filein,ps_filename,path
  print,'Funny output: ',filein,ps_filename,path

  efield_sub=strpos(ps_filename,'pot')
  if efield_sub gt 0 and efield_flag eq 1 then begin   ;this will never get hit
						       ;if input files are ee
						       ;or en
      sav1=strmid(ps_filename,0,efield_sub)
      sav2='efield'
      sav3=strmid(ps_filename,efield_sub+3,strlen(ps_filename)-efield_sub + 3)
      ps_filename=sav1+sav2+sav3
      print,ps_filename

  endif

  ps_filename=ps_filename+ '.' +strcompress(strlowcase(search_string),/rem) 
  ps_filename=ps_filename + '.' + strcompress(n1,/rem) + '.ps'
  ps_filename=ask('last chance on that postscript filename!',ps_filename)
  set_plot,'ps'
  print,'Sending output to ' + ps_filename + ', see /we/amie/postscript'
  device,/landscape,filename='/we/amie/postscript/' +ps_filename,/times
endif
!p.font=0

;********* end PS QnA



spacer=.1	                       ;space between plots
case plot_number of
 1: pos_space,plot_number,.1,plotsizes
 2: pos_space,plot_number,.1,plotsizes,nx=1,ny=2
 4: pos_space,plot_number,.1,plotsizes,nx=2,ny=2
endcase



if (n1 eq -1) then begin

  print, 'you have selected to enter individual numbers.'
  print, ''

  done = 0

  while (done eq 0) do begin

    que = ''
    read, 'Enter number (return to quit) : ',que
    if (strlen(que) eq 0) then done = 1			$
    else begin

      if (n_elements(list) eq 0) then list = fix(que)		$
      else list = [list,fix(que)]

    endelse

  endwhile

  n1 = 0						;starting plot #
  n2 = n_elements(list)-1

endif	; end IF (N1 eq -1)


potout = strmid(fileout,0,strpos(fileout,'.ps'))+'.pot'
if (sub eq 1) then openw,1,potout


n1sub = n1-sub
if asub ne 1 then n1sub = n1
if n1sub eq 0 and asub eq 0 and sub eq 1 then n1sub = 1


;------in orbit_mode this should be a one-time loop------

plot_counter=0		;to decide when to plot_conductance,/no_erase

if orbit_mode eq 1 then begin
  n1sub=0
  n2=0
  skip_number=1
endif

for ij=n1sub,n2,skip_number do begin
    
  if (ij eq n1-1) then n = 0 else n = ij
  if asub eq 1 then subn = 0 else subn = ij-1

  if asub ne 1 then pn = (n-n1) mod ppp			$
  else if ij ge n1 then pn = (ij-(n1-sub)+2) mod ppp else pn = 1

  if (asub eq 2) then begin

    subn = 0
    ni = ij - runt/2
    if (ni le 0) then ni = 1
    nj = ni + runt
    if (nj gt n2) then nj = n2
    nc = nj - ni + 1

  endif

  if (n_elements(list) gt 0) and (ij ge 0) then n = list(ij);

  print,'CALLING GET_DATA_LOC'; 

;---either read all data at one or read successively




    if orbit_mode then begin   ; restore a whole day of data(?)	
 
    ;---in the best situ, this gets everything
    ;---FIXME: FOR POTENTIALS YOU ALSO WANT GEOGRAPHIC LOCATIONS!!!!
    ;--- now if jh flag is on, sjh gets returned in data1

      if jh_flag eq 0 then 						$
        get_data_loc, namiein, data_dir, date(date_size/2),		$
		amie_time(date_size/2), dt,				$
		90.0-maxran,search_string,datatype,			$
		data1,data2,mlat,mlt_,ut_time,SC_arr,kloc_arr,		$
		sc_strings						$
      else 								$
	get_jh_loc_2, namiein, data_dir, date(date_size/2),	        $
		amie_time(date_size/2), dt,				$
		90.0-maxran,search_string,datatype,			$
		data1,data2,mlat,mlt_,ut_time,SC_arr,kloc_arr,		$
		sc_strings
      
        


    endif else begin
      if jh_flag eq 0 then 						$
        get_data_loc, namiein, data_dir, date(n), amie_time(n), dt,	$
		90.0-maxran,search_string,datatype,			$
		data1,data2,mlat,mlt_,ut_time,SC_arr,kloc_arr,		$
		sc_strings else 					$
        get_jh_loc_2, namiein, data_dir, date(n), amie_time(n), dt,	$
		90.0-maxran,search_string,datatype,			$
		data1,data2,data3,mlat,mlt_,ut_time,SC_arr,kloc_arr,		$
		sc_strings


	
    endelse  ;end IF ORBIT_MODE



;      get_sonde, namiein, data_dir, date(n), amie_time(n), dt,	$
;		90.0-maxran,search_string,datatype,			$
;		data1,data2,mlat,mlt_,ut_time,SC_arr,kloc_arr;




  data_help=size(data1)
  data_size_x=data_help(1)
  data_size_y=data_help(2)
  data_time=ut_time		;already double precision!!!


;-----start managing data that is returned from the data read

  if conductance_flag and datatype eq 'hal' then conductance=data2 $
	 else if conductance_flag then conductance=data1
;---efield hack

  if datatype eq 'ee' then conductance=data2	;works regardless of emag_flag
  if datatype eq 'en' then conductance=data1
  if emag_flag then begin
	bad_e=where(data1 eq -999 or data2 eq -999 $
		or data1 eq -32.77 or data2 eq -32.77)
	conductance=(data1^2+data2^2)^(0.5)
	data1(bad_e)=-999 & data2(bad_e)=-999		;CAUTION,changing data!
    print,'Calculating Magnitude of Efield'

  endif
;  if potential_flag then efield= sqrt((data1)^2 + (data2)^2)
  if potential_flag eq 1 or efield_flag eq 1 then potential=data1
 						;going to convert pot to ealong
						;convert to degrees
  mlt_=mlt_*15.


;                   ---here goes the interpolation---

;---there are issues for looking at all day amie runs. THE CENTER TIME IS
;---all that is interpolated to achieve comparisons to 
;---this is TOTAL CRAP if your window is 24 hours (compares all to 12:00 UT!)

;  gooddata=where(data1 gt -999 and data2 gt -999,needhelp)

;---take care of data obtained after amie run is over!!!

  gooddata=where(data1 gt -999 and data2 gt -999 and $
		  ut_time lt max(d_amie_time)	,needhelp)

;  if emag_flag then $
;	  gooddata=where(data1 gt -999 and data2 gt -999 and $
;		  data1 ne -32.77 and data2 ne -32.77 and $
;		  ut_time lt max(d_amie_time)	,needhelp)

;-------
  if needhelp gt 0 then begin
    gooddata_y=fix(gooddata/data_size_y)
    gooddata_x=gooddata mod data_size_y
    ut_help=min(ut_time(gooddata))

    utnew = ut_time
    utnew(gooddata)=utnew(gooddata) - ut_help	
					;UT is in double precision seconds
					;since 1965. ACK!!!!

;--------AMIE grids centered 7.5 degrees from where lnpos numbers

    mlt_=mlt_-7.5			;assuming it's been converted to deg
    wrapped=where(mlt_ lt 0 and mlt_ gt -10)
    mlt_(wrapped)=mlt_(wrapped) +360. 

;--------Find the virtual positions of data samples in the AMIE array

    amie_xpos=interpol(findgen(lons),reform(lnpos(*,0)),mlt_(gooddata))  
    amie_ypos=interpol(findgen(lats),reform(ltpos(0,*)),mlat(gooddata))

    debug_flag=0

;---the following step intepolates amie data either fixed in time or varying
;---with time . The plain 'data' variable is AMIE DATA!

    new_interp=1				;1=gets amie closest to sc obsv

    if new_interp eq 0 then begin
      amie_data=interpolate(reform(data(ij,*,*)),amie_xpos,amie_ypos)

    endif else begin    ;   Aaa
      amie_data=fltarr(needhelp)
      for ii=0,needhelp-1 do begin
	closest_time= abs(d_amie_time - data_time(gooddata(ii)))
	real_diff=d_amie_time-data_time(gooddata(ii))	;added 4-10-2000

  ;---timefind can be greater than one element. This Calls for a HACK
  ;---that hack is (timefind(0))

        timefind = where(closest_time eq min(closest_time))

;-----do offset to interpolate between amie time steps	

 	if timefind(0) eq 0 then offset=closest_time(timefind(0))/$
		(closest_time(timefind(0)+1)-closest_time(timefind(0))) $
	else offset=real_diff(timefind(0))/$
			(real_diff(timefind(0))-real_diff(timefind(0)-1))

;-----and furthermore, the data go well beyond the amie times. The 
;-----following proves it. How to take care of this!?!?!?!?!?
;-----fixed it. Compared max(d_amie_time) to ut_time of data in def of gooddata

	if debug_flag then print,format='(i4,i4,$)',$	
		n_elements(d_amie_time),timefind

  ;---closest_time maps straight to d_amie_time           



;        amie_data(ii)=interpolate(reform(data(timefind(0),*,*)),$
;	                        amie_xpos(ii),amie_ypos(ii))
        amie_data(ii)=interpolate(data(*,*,*),$
	              timefind(0)+offset,amie_xpos(ii),amie_ypos(ii))

;	print,timefind(0)+offset,' timefind'

      endfor

    endelse		  ;   Aaa


;--------That's the interpolation

    test=0
    if test then read,blank
         
;---do not bother plotting of all data for entire day is here


    if needhelp gt 1 then begin

      if (potential_flag eq 1 or efield_flag eq 1) and calc_efield_flag eq 0 $
	 and emag_flag eq 0 then conductance=potential	     
      ;else conductance already has the right values in it. 
      
      

      if jh_flag eq 1 then begin		;jh has been put into data 1
        conductance = data1
      endif

				;WHAT A HACK!!!! But the code works differently
				;than I had envisioned (_I_ am not doing 
				;the potential calculation
				;I'M NOT??? 11-19-99
				; NO YOU ARE NOT!!!  03-29-2000

      print,needhelp, ' Number of points to plot'
	
       
      sat_dat=conductance(gooddata)
      mlt_dat=mlt_(gooddata)
      mlat_dat=mlat(gooddata)
      kloc_dat=kloc_arr(gooddata)
      ut_dat=ut_time(gooddata)		;these are DATA UT TIMES
      which_spacecraft=sc_arr(gooddata)	;NOT the UT of the AMIE DATA!


;---correct for offset in f14
;      if potential_flag eq 1 or efield_flag eq 1 and f14_fix eq 1 then begin
      got14 = 1                                              ;need this defined
      if potential_flag eq 1 or efield_flag eq 1  then begin
	dmsp14_corr=where(which_spacecraft eq 9,got14)
	dmsp14_value=(-10)			;offset for fix
	if got14 gt 0 then $
		sat_dat(dmsp14_corr)=sat_dat(dmsp14_corr)+dmsp14_value	
						;minus X mV/m
      endif


      name_path_extract,filein,datafile,path
	print,datafile, '   ***Datafile'
      ;******amie_data are already interpolated to these times******

      plot_box=(plot_counter mod plot_number)	;where on page to plot 



      get_position,plot_number,spacer,plotsizes,plot_box,plot_arr,/rect
      !p.position=plot_arr

;---plot_conductance will key off of datatype for the plotting routine

;      print,mlat_dat


      if search_string eq 'sonde' and twod_flag eq 1 then $
      plot_2d,amie_data,sat_dat,mlat_dat,mlt_dat,$
         ut_dat,datatype,which_spacecraft,datafile,/no_erase, $ 
	 nomlt=0, nomlat=0,times_=0,$
	 efield=efield_flag,utx=0,emag=emag_flag else $
      if plot_box ne 0 then $
      plot_conductance,amie_data,sat_dat,mlat_dat,mlt_dat,$
         ut_dat,datatype,which_spacecraft,datafile,avg,sigma,RR,timestamp,$
	 spacecraft_,/no_erase, $ 
	 nomlt=0, nomlat=0,$
	 efield=efield_flag,utx=0 $
      else $
      plot_conductance,amie_data,sat_dat,mlat_dat,mlt_dat,$
         ut_dat,datatype,which_spacecraft,datafile,avg,sigma,RR,timestamp,$
	 spacecraft_,nomlt=0,nomlat=0,$
         efield=efield_flag,utx=0

      if twod_flag eq 1 then $
	xyouts,0.99,.0,filein,/norm,orientation=90,charsize=0.8 else $
        xyouts,-0.03,.0,filein,/norm,orientation=90,charsize=0.8

;---print STATS that are passed back---
  if stats_file_flag eq 1 then begin
    helphere=size(mlat_dat) & helphere=helphere(1)

      if abs(mlat_dat(0)-mlat_dat(helphere-1)) lt 6 then $
      printf,unit,format='(a8,a6,f8.4,f8.4,f8.4,f6.1,f6.1)',spacecraft_,$
	timestamp,avg,sigma,RR,mlat_dat(0),mlat_dat(helphere-1)

  endif
;---end STATS---

      plot_counter=plot_counter + 1

;---tack datafilename onto page

      if debug_flag then stop      ;for debugging 

    endif	;end conductance plot

  endif    ;end if needhelp

endfor	;end steps through AMIE

;  if sub eq 1 then close,1

if !d.name eq 'PS' then begin
  device, /close
  set_plot, 'X'
  print,ps_filename, '   <--- your postscript output' 
endif

;---think about saving everything

saveflag=strcompress(strupcase(ask('Enter Y to save','N')))

if saveflag eq 'Y' then begin
  orig_amie_time=amie_time		;this is important to avoid confusion!
  orig_amie_data=data	
  orig_amie_date=date
  name_path_extract,filein,save_filename,path

  print,filein
  print,save_filename
  print,path

  efield_sub=strmid(save_filename,'pot')
  if efield_sub gt 0 and efield_flag eq 1 then begin
      sav1=strmid(save_filename,0,efield_sub)
      sav2='efield'
      sav3=strmid(save_filename,efield_sub+3,strlen(save_filename)-efield_sub_3)
      save_filename=sav1+sav2+sav3
      print,save_filename, ' : This is your savefile!'
  endif

  savefile='./savefiles/' + save_filename +'.'
  savefile= savefile + strlowcase(search_string) + '.idl'  
  save,file=savefile,amie_data,sat_dat,mlat_dat,mlt_dat,ut_dat,$
		which_spacecraft,orig_amie_data,orig_amie_time,$
		sc_strings,d_amie_time,kloc_dat,difference,data_time,$
		gooddata

  ;***data are either hal, ped, or pot in default amie resolution;

endif

if stats_file_flag eq 1 then begin
printf,unit,filein
printf,unit,'avg is average (amie-data), where negative, data are larger'
if (efield_flag eq 1 or potential_flag eq 1) and got14 gt 0 then printf,unit,$
	'dmsp14 offset correction of '+strcompress(dmsp14_value)+'mV/meter'
	


close,unit
free_lun,unit
endif



stop

return

end










