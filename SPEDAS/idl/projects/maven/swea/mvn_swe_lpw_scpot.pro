;+
; PROCEDURE:
;       mvn_swe_lpw_scpot
; PURPOSE:
;
;       !!! To load data quickly, use mvn_swe_lpw_scpot_restore !!!
;
;       ******************************************
;       *** This routine is still experimental ***
;       ******************************************
;       Empirically derives positive spacecraft potentials using SWEA and LPW.
;       Inflection points in LPW I-V curves are tuned to positive spacecraft
;       potentials estimated from SWEA energy spectra.
; CALLING SEQUENCE:
;       timespan,'16-01-01',14   ;- make sure to set a long time range
;       mvn_swe_lpw_scpot
; OUTPUT TPLOT VARIABLES:
;       mvn_swe_lpw_scpot : default scpot data
;                           (currently mvn_swe_lpw_scpot_pow)
;       mvn_swe_lpw_scpot_lin : spacecraft potentials derived from
;                               linear fitting of Vswe v. -Vinfl
;       mvn_swe_lpw_scpot_pow : spacecraft potentials derived from
;                               power law fitting of Vswe v. -Vinfl
;                               - does a better job at small (~3-5 V)
;                                 and large (~10-20 V) potentials
; KEYWORDS:
;       trange: time range
;       norbwin: odd number of orbits used for Vswe-Vinfl fitting (Def. 37)
;       minndata: minimum number of data points for Vswe-Vinfl fitting
;                 (Def. 1e4)
;       maxgap: maximum time gap allowed for interpolation (Def. 257)
;       plot: if set, plot the time series and fitting
;       nol0load: if set, use pre-existing input tplot variables:
;                 'mvn_swe_sc_pot', 'mvn_lpw_swp1_IV'
;       vrinfl: voltage range for searching the inflection point
;               (Def. [-15,5])
;       ntsmo: time smooth width (Def. 3)
;       noangcorr: if set, do not conduct angular distribution correction
;                  in mvn_swe_sc_pot
; NOTES:
;       1) Inflection points are unreliable before 2015-01-24.
;       2) The peak fitting algorithm sometimes breaks down
;          when multiple peaks are present in dI/dV curves.
;          Check the quality flag: mvn_lpw_swp1_IV_vinfl_qflag
;                                  1 = good, 0 = bad
;       3) Sharp transitions will be smoothed out by default.
;          Setting ntsmo=1 will improve the time resolution
;          at the expense of better statistics.
;       4) Potential values < +3 V and > +20 V are extrapolated from
;          the empirical relation between 3-20 V.
;          They are not verified nor tuned by SWEA measurements.
;          Also, potentials < +1 are replaced by +1.
;          Potential values < +3 V just mean that scpot is smaller than ~+3 V
; CREATED BY:
;       Yuki Harada on 2016-02-29
;
; $LastChangedBy: haraday $
; $LastChangedDate: 2017-01-14 12:28:29 -0800 (Sat, 14 Jan 2017) $
; $LastChangedRevision: 22602 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/swea/mvn_swe_lpw_scpot.pro $
;-

pro mvn_swe_lpw_scpot, trange=trange, norbwin=norbwin, minndata=minndata, maxgap=maxgap, plot=plot, nol0load=nol0load, vrinfl=vrinfl, ntsmo=ntsmo, noangcorr=noangcorr, novinfl=novinfl, icur_thld=icur_thld, swel0=swel0, figdir=figdir, atrtname=atrtname, scatdir=scatdir


if ~keyword_set(figdir) then begin
   figdir = '/disks/maja/home/haraday/fig/maven/mvn_swe_lpw_scpot/'
   if ~file_test(figdir,/directory) then figdir = 0
endif


;;; set default parameters
if ~keyword_set(norbwin) then norbwin = 37 ;- odd number
if ~keyword_set(minndata) then minNdata = 1.e4
if ~keyword_set(maxgap) then maxgap = 257.
if ~keyword_set(vrinfl) then vrinfl = [-15,5] ;- inflection point V range
if ~keyword_set(ntsmo) then ntsmo = 3 ;- odd number, smooth IV curves in time
if keyword_set(noangcorr) then angcorr = 0 else angcorr = 1
if ~keyword_set(atrtname) then atrtname = 'mvn_lpw_atr_swp'
if ~keyword_set(icur_thld) then icur_thld = -0.5 ;- 10^icur_thld drop from median -> invalid

;;; obsolete
;; if ~keyword_set(icur_thld) then icur_thld = -8.3 ;- I_V0 > -10^icur_thld
;; tr_icur9 = time_double(['2016-04-12/00:00','2016-05-29/02:00']) ;- icur_thld=-9 during this time
;; tr_icur9_2 = time_double(['2016-11-04/00:00','2016-12-01/00:00'])

tr = timerange(trange)

orbdata = mvn_orbit_num()
worb = where( orbdata.peri_time gt tr[0] $
              and orbdata.peri_time+4.6*3600. lt tr[1] , nworb )
orbnums = orbdata[worb].num
tperi0 = orbdata[worb].peri_time
tperi1 = orbdata[worb+1].peri_time

if nworb lt norbwin then begin
   dprint,'Time range is too short: minimum Norb = '+string(norbwin,f='(i0)')
   return
endif


;;; load data
if ~keyword_set(nol0load) then begin
   maven_orbit_tplot, /current, /loadonly ;,result=scpos

   ;;; load LPW L0 data
   tf = ['mvn_lpw_swp1_IV','mvn_lpw_swp1_mode',atrtname] ;- wanted tplot variables
   f = mvn_pfp_file_retrieve(/l0,trange=tr)
   if getenv('ROOT_DATA_DIR') eq '' then setenv,'ROOT_DATA_DIR='+root_data_dir() ;- for LPW loader
   for ifile=0,n_elements(f)-1 do begin
      l0pref = 'mvn_pfp_all_l0_'
      idx = strpos(f[ifile],l0pref)
      today = time_double(strmid(f[ifile],idx+strlen(l0pref),8),tf='YYYYMMDD')
      YYYY_MM_DD = time_string(today,tf='YYYY-MM-DD')
      packet = 'nohsbm'
      s = execute( 'mvn_lpw_load, YYYY_MM_DD,/notatlasp,/noserver,/leavespice,packet=packet' )
      if ~s then s = execute( 'mvn_lpw_load, YYYY_MM_DD,/notatlasp,/noserver,/leavespice,packet=packet,/nospice' ) ;- try /nospice
      for itf=0,n_elements(tf)-1 do begin
         get_data,tf[itf],dtype=dtype
         if dtype eq 1 then tplot_rename,tf[itf],time_string(today,tf='YYYYMMDD_')+tf[itf]
      endfor
      store_data,'mvn_lpw_*',/del
      mvn_spc_clear_spice_kernels
      timespan,tr
   endfor
   ;;; concat and sort
   for itf=0,n_elements(tf)-1 do begin
      tn = tnames('????????_'+tf[itf],ntn)
      if ntn gt 0 then begin
         for itn=0,ntn-1 do begin
            get_data,tn[itn],data=d,dlim=dlim
            if itn eq 0 then begin
               newx = d.x
               newy = d.y
               if tag_exist(d,'V') then newv = d.v
            endif else begin
               newx = [newx,d.x]
               newy = [newy,d.y]
               if tag_exist(d,'V') then begin
                  if size(d.v,/n_dim) eq 2 then newv = [newv,d.v]
               endif
            endelse
         endfor
         if tag_exist(d,'V') then $
            store_data,tf[itf],data={x:newx,y:newy,v:newv},dlim=dlim $
         else store_data,tf[itf],data={x:newx,y:newy},dlim=dlim
         tplot_sort,tf[itf]
         store_data,tn,/del
      endif
   endfor

   ;;; load SWEA data
   if keyword_set(swel0) then mvn_swe_load_l0, tr $
   else mvn_swe_load_l2, tr, /spec, ddd=angcorr
   mvn_swe_sumplot,/loadonly
   mvn_swe_sc_pot,angcorr=angcorr
endif                           ;- nol0load


;;; get SWEA potentials and LPW IV curves
get_data,'mvn_swe_sc_pot',data=dvswe,dtype=dvswetype
get_data,'mvn_lpw_swp1_IV',data=div,dtype=divtype
if dvswetype*divtype eq 0 then begin
   dprint,'No valid tplot variables for mvn_swe_sc_pot and/or mvn_lpw_swp1_IV'
   return
endif


;;; if plot, set up plot windows and tplot options
if keyword_set(plot) then begin
   options,'swe_a4',zrange=[1.e5,1.e9],minzlog=1.e-30,yticklen=-.01
   options,'mvn_swe_sc_pot',psym=3,constant=[3],yrange=[0,20]
   store_data,'swe_comb',data=['swe_a4','mvn_swe_sc_pot'], $
              dlim={yrange:[3,4627.5],ystyle:1}
   options,'mvn_lpw_swp1_IV',spec=1,zrange=[-1.e-7,1.e-7],yrange=[-20,20], $
           yticklen=-.01,no_interp=1,ytitle='LPW!cswp1',datagap=maxgap
   options,'alt2',panel_size=.5,ytitle='Alt!c[km]',constant=250
   get_data,'mvn_lpw_swp1_mode',data=dmode,dtype=dtypemode
   if dtypemode ne 0 then $
      store_data,'mvn_lpw_swp1_mode_bar', $
                 data={x:dmode.x,y:[[dmode.y],[dmode.y]],v:[0,1]}, $
                 dlim={spec:1,panel_size:.1,no_color_scale:1,zrange:[0,15], $
                       ytitle:'',yticks:1,yminor:1, $
                       ytickname:[' ',' ']}
endif                           ;- plot



;;; generate iv inflection voltages
if ~keyword_set(novinfl) then begin
;;; set up data containers
ders = fltarr(n_elements(div.x),128)*!values.f_nan
vols = transpose(rebin( (findgen(128)+.5)/128.* 40.-20. , $
                        128, n_elements(div.x)))
vinfl = replicate(!values.f_nan,n_elements(div.x))
vfloat = replicate(!values.f_nan,n_elements(div.x))
cursmo = div.y*!values.f_nan
chi2 = replicate(!values.f_nan,n_elements(div.x))

;;; check valid IV curves
validiv = replicate(1b,n_elements(div.x))
icur = reform(div.y[*,0])
icur_med = icur*!values.f_nan
;;; filter out positive/small Ii at V0 on an orbit-by-orbit basis
for iperi=0,n_elements(tperi0)-1 do begin
   ww = where( div.x ge tperi0[iperi] and div.x lt tperi1[iperi] $
               and finite(icur), nww )
   if nww eq 0 then continue
   medtmp = median( icur[ww] )
   icur_med[ww] = medtmp
   thld_now = medtmp * 10.^icur_thld < 0.
   ww = where( div.x ge tperi0[iperi] and div.x lt tperi1[iperi] $
               and icur gt thld_now, nww )
   if nww eq 0 then continue
   validiv[ww] = 0b
endfor
;;; obsolete
;; w9 = where( (div.x gt tr_icur9[0] and div.x lt tr_icur9[1]) $
;;             or (div.x gt tr_icur9_2[0] and div.x lt tr_icur9_2[1]) , nw9 )
;; if nw9 gt 0 then begin
;;    icur_thld_arr = replicate(icur_thld,n_elements(div.x))
;;    icur_thld_arr[w9] = -9.
;;    w = where( div.y[*,0] gt -10.^icur_thld_arr, nw )
;; endif else w = where( div.y[*,0] gt -10.^icur_thld, nw )
;; if nw gt 0 then validiv[w] = 0b ;- filter out positive/small Ii at V0


;;; quick fix to erroneous I-V curves when the mode changes before
;;; first atr info available in the beginning of the day
get_data,'mvn_lpw_swp1_mode',data=dmode,dtype=dmodetype
get_data,atrtname,data=datr,dtype=datrtype
if dmodetype*datrtype ne 0 then begin
   day0 = time_double(time_string(tr[0],tf='YYYY-MM-DD'))
   day1 = time_double(time_string(tr[1],tf='YYYY-MM-DD'))
   ndays = long((day1 - day0)/86400d) + 1
   for iday=0,ndays-1 do begin
      now = day0 + iday*86400d
      w0 = where( datr.x gt now , nw0 )
      w1 = where( dmode.x gt now , nw1 )
      if nw0*nw1 eq 0 then continue
      first_atr_time = datr.x[w0[0]]
      w2 = where( dmode.y[w1] ne dmode.y[w1[0]] , nw2 )
      if nw2 eq 0 then continue
      first_mode_change_time = dmode.x[w1[w2[0]]]
      if first_atr_time ge first_mode_change_time-1d then begin
         w = where( div.x gt now and div.x lt first_mode_change_time , nw )
         if nw gt 0 then validiv[w] = 0b
      endif
   endfor
endif



;;; loop through time steps
syst0 = systime(/sec)
secnow = 0.
for it=(ntsmo-1)/2,n_elements(div.x)-(ntsmo-1)/2-1 do begin
   if systime(/sec)-syst0 gt secnow+1 then begin
      secnow = secnow + 1
      dprint,'Calc Vinfl: ' $
             +string(100.*it/(n_elements(div.x)-1),f='(f8.4)') $
             +' %, '+time_string(div.x[it])
   endif

   if ~validiv[it] then continue

   vol = reform(div.v[it,*])

   ;;; smooth in time
   cur = reform(div.y[it,*]) * 0.
   nsum = 0.
   for itsmo=-(ntsmo-1)/2,(ntsmo-1)/2 do begin
      vdif0 = total(abs(div.v[it+itsmo,*]-div.v[it,*]))
      if vdif0 eq 0 and validiv[it+itsmo] then begin ;- only same V steps
         cur = cur + reform(div.y[it+itsmo,*])
         nsum = nsum + 1.
      endif
   endfor
   cur = cur / nsum
   cursmo[it,*] = cur


   ;;; compute the derivative from unique data points
   cur = cur[sort(vol)]
   vol = vol[sort(vol)]
   uni1 = uniq(vol)
   uni0 = [ 0, uni1[0:n_elements(uni1)-2]+1 ]
   uvol = vol[uni1]
   ucur = uvol*!values.f_nan
   for i=0,n_elements(uni1)-1 do ucur[i] = mean(cur[uni0[i]:uni1[i]])
   vol = uvol
   cur = ucur
   if n_elements(vol) lt 5 then continue
   der = deriv(vol,cur)

   ;;; smooth high-res noisy area
   w = where( abs(vol) lt 5 and (abs(vol-shift(vol,1)) lt .2 $
                                 or abs(vol-shift(vol,-1)) lt .2) ,nw)
   if nw gt 3 and max(vol[w])-min(vol[w]) gt .6 then begin
      cur2 = time_average(vol[w],cur[w],newt=vol2,tr=minmax(vol[w]),res=.2)
      der2 = deriv(vol2,cur2)
      cur[w[1]:w[nw-2]] = interp(cur2,vol2,vol[w[1]:w[nw-2]])
      der[w[1]:w[nw-2]] = interp(der2,vol2,vol[w[1]:w[nw-2]])
   endif

   ;;; get the floating potential
   cur = smooth(cur,7,/nan)
   w = where( vol gt -30 and vol lt 30 )
   mincur = min(abs(cur[w]),imin)
   maxcur = max(abs(cur[w]))
   if alog10(maxcur)-alog10(mincur) gt .5 then vfloat[it] = vol[w[imin]] $
   else continue                ;- flat curve -> skip

   ;;; discard edges
   w = where(finite(der),nw)
   if nw eq 0 then continue
   der[min(w)] = 0.
   der[max(w)] = 0.

   ;;; smooth the derivative here
   der = smooth(der,7,/nan)

   ;;; discard V >~ Vfloat, assuming Vinfl <~ Vfloat (positive Vsc)
   w = where( vol gt vfloat[it]+2 and finite(der) , nw)
   if nw gt 0 then der[w] = 0.

   ;;; average into 1 V regular bins and oversample
   der1v = time_average(vol,der,newt=vol1v,tr=[-20,20],res=1.)
   w = where(finite(der1v),nw)
   if nw eq 0 then continue
   ders[it,*] = interp( der1v[w], vol1v[w], vols[it,*], /no_ex )
   ders[it,*] = ders[it,*] / max(ders[it,*],/nan) ;- normalize

   ;;; grab the dI/dV peak
   w = where( vols[it,*] gt vrinfl[0] and vols[it,*] lt vrinfl[1] $
              and finite(ders[it,*]), nw)
   if nw gt 6 then begin
      x = reform(vols[it,w])
      y = reform(ders[it,w])
      ymax = max(y,imax,/nan)
      if ymax gt .5 then begin  ;- only clear peaks
         p = {a:2.d*(2.*!pi)^.5,s:1.d,x0:double(x[imax])}
         fit,x,y,param=p,funct='gauss2',verb=-1 ;- initial fit
         y2 = y
         w = where( x gt p.x0+p.s or x lt p.x0-p.s , nw )
         if nw gt 0 then y2[w] = 0.                 ;- suppress the wings
         fit,x,y2,param=p,funct='gauss2',verb=-1, $ ;- 2nd fit
             fitvalues=yfit
         if p.x0 gt vrinfl[0] and p.x0 lt vrinfl[1] then begin
            vinfl[it] = p.x0    ;- This is what I want
            chi2[it] = total((y-yfit)^2)/(n_elements(y)-3.) ;- chi2 for qflag
         endif
      endif
   endif
endfor                          ;- it loop

w = where(ders eq 0 , nw)
if nw gt 0 then ders[w] = !values.f_nan ;- Don't plot invalid parts

;;; store tplot variables
store_data,'mvn_lpw_swp1_IV_log', $
           data={x:div.x,y:alog10(abs(div.y)),v:div.v}, $
           dlim={zrange:[-9,-5],yrange:[-20,20],yticklen:-.01, $
                 ytitle:'LPW!cswp1!c[V]',datagap:maxgap,spec:1,no_interp:1, $
                 ztitle:'log!d10!n(|I|)!c(corrected)'}
store_data,'icur',data={x:div.x,y:alog10(abs(icur<0))}, $
           dlim={yrange:[-10,-7],ystyle:1, $
                 labels:['I!dV0!n'],labflag:1,ytitle:'log(-I)', $
                 datagap:maxgap,psym:0,constant:findgen(7)/2.-9.5}
store_data,'icur_med',data={x:div.x,y:alog10(abs(icur_med<0))}, $
           dlim={yrange:[-10,-7],ystyle:1,linestyle:2,colors:[2]}
store_data,'validiv',data={x:div.x,y:validiv}, $
           dlim={panel_size:.2,yrange:[-1,2],ystyle:1,psym:3, $
                 labels:'valid',labflag:1, $
                 ytitle:' ',yticks:1,yminor:1,ytickname:[' ',' ']}
store_data,'mvn_lpw_swp1_IV_log_smo', $
           data={x:div.x,y:alog10(abs(cursmo)),v:div.v}, $
           dlim={zrange:[-9,-5],yrange:[-20,20],yticklen:-.01, $
                 ytitle:'LPW!ctntsmo '+string(ntsmo,f='(i0)')+'!cswp1!c[V]', $
                 datagap:maxgap,spec:1,no_interp:1, $
                 ztitle:'log!d10!n(|I|)!c(corrected)'}
store_data,'mvn_lpw_swp1_dIV_smo',data={x:div.x,y:ders,v:vols}, $
           dlim={yrange:[-20,20],zrange:[0,1],spec:1,yticklen:-.01, $
                 ytitle:'LPW!cswp1!c[V]',ztitle:'Norm.!cdI/dV', $
                 constant:0,datagap:maxgap,no_interp:1}
store_data,'mvn_lpw_swp1_IV_vfloat',data={x:div.x,y:vfloat}, $
           dlim={colors:[5],datagap:maxgap}
store_data,'mvn_lpw_swp1_IV_vinfl',data={x:div.x,y:vinfl}, $
           dlim={colors:[3],datagap:maxgap}
store_data,'mvn_lpw_swp1_IV_vinfl_chi2',data={x:div.x,y:chi2}, $
           dlim={datagap:maxgap}
store_data,'mvn_lpw_swp1_IV_vinfl_qflag', $ ;- experimental
           data={x:div.x,y:exp(-chi2^2/2/.05^2)}, $
                       ;;; This is just an arbitrary function
                       ;;; which shows goodness of dI/dV peak fit
                       ;;; 1 = good, 0 = bad
           dlim={datagap:maxgap,yrange:[0,1],ytitle:'Vinfl!cqflag'}
store_data,'IV_log_smo_comb', $
           data=['mvn_lpw_swp1_IV_log_smo','mvn_lpw_swp1_IV_vfloat'], $
           dlim={yrange:[-20,20]}
store_data,'dIV_smo_comb', $
           data=['mvn_lpw_swp1_dIV_smo','mvn_lpw_swp1_IV_vinfl'], $
           dlim={yrange:[-20,20]}
endif                           ;- novinfl



;;; loop through orbits
get_data,'mvn_lpw_swp1_IV_vinfl',data=dvinfl
iorb0 = (norbwin-1)/2
iorb1 = nworb-1 - (norbwin-1)/2
for iorb=iorb0,iorb1 do begin
   orbstr = string(orbnums[iorb],f='(i5.5)')
   trorb = [ tperi0[iorb] , tperi1[iorb] ]
   trfit = [ tperi0[iorb-(norbwin-1)/2] , tperi1[iorb+(norbwin-1)/2] ]

   w = where(finite(dvswe.y) and dvswe.x gt trfit[0] and dvswe.x lt trfit[1] , nw )
   times = dvswe.x[w]
   Vswe = dvswe.y[w]

   a = [!values.d_nan,!values.d_nan]
   corr = !values.d_nan
   pow = {func:'power_law',h:!values.d_nan,p:!values.d_nan,bkg:!values.d_nan}
   Nscat = 0l

   ;;; LPW IV Vinfl v Vswe
   w = where( div.x gt trfit[0] and div.x lt trfit[1], nw )
   if nw gt minNdata then begin
      vinfl2 = interp(dvinfl.y,dvinfl.x,times,/no_ex,interp=maxgap)
      w = where( finite(vinfl2) ,nw )
      if nw gt minNdata then begin
         x = Vswe[w]
         y = -vinfl2[w]
         t = times[w]

         alad = ladfit(x,y)        ;- initial fit

         ;;; filter out outliers and fit
         w = where( abs(x-(y/alad[1]-alad[0]/alad[1])) lt 5 , nw )
         Nscat = nw
         if nw gt minNdata then begin
            x2 = x[w]
            y2 = y[w]
            t2 = t[w]
            a = ladfit(x2,y2) ;- linear fit
            corr = correlate(x2,y2)
            apow = ladfit(x2^.35,y2) ;- get initial guess
            pow = {func:'power_law',h:apow[1],p:.35d,bkg:apow[0]}
            fit,x2,y2,para=pow,itmax=50,verb=-1
            if keyword_set(scatdir) then begin
               file_mkdir,scatdir
               w2 = where(t2 gt trorb[0] and t2 lt trorb[1], nw2)
               if nw2 gt 0 then begin
                  scat = {t:t2[w2],vswe:x2[w2],vinfl:-y2[w2]}
                  save,scat,filename=scatdir+orbstr+'.sav',/compress
               endif
            endif
         endif

         w = where( dvinfl.x gt trorb[0] and dvinfl.x lt trorb[1] , nw )
         tvinfl = dvinfl.x[w]
         scpot_lin = ( (-dvinfl.y[w]) - a[0] ) / a[1]
;         scpot_pow = 10.^( alog10(((-dvinfl.y[w])-pow.bkg)/pow.h)/pow.p )
         scpot_pow = 10.^( alog10(((-dvinfl.y[w])-pow.bkg > 0.)/pow.h)/pow.p )

         ;;; put 1. for scpot < 1
         w = where( scpot_lin lt 1 , nw )
         if nw gt 0 then scpot_lin[w] = 1.
         w = where( scpot_pow lt 1 , nw )
         if nw gt 0 then scpot_pow[w] = 1.
         w = where( ~finite(scpot_lin) , nw )
         if nw gt 0 then scpot_pow[w] = !values.f_nan

         ;;; Filter out shadow regions
         get_data, 'wake', data=dwake, dtype=dtype
         if dtype ne 0 then begin
            shadow = interp(float(finite(dwake.y)), dwake.x, tvinfl, /no_ex)
            w = where(shadow gt 0., nw)
            if nw gt 0 then scpot_lin[w] = !values.f_nan
            if nw gt 0 then scpot_pow[w] = !values.f_nan
         endif
         ;;; Filter out altitudes below 250 km 
         get_data, 'alt', data=dalt, dtype=dtype
         if dtype ne 0 then begin
            alt = interp(dalt.y, dalt.x, tvinfl, /no_ex)
            w = where(alt lt 250, nw)
            if nw gt 0 then scpot_lin[w] = !values.f_nan
            if nw gt 0 then scpot_pow[w] = !values.f_nan
         endif


         ;;; store the results
         store_data,orbstr+'_mvn_swe_lpw_scpot_lin', $
                    data={x:tvinfl,y:scpot_lin}, $
                    dlim={colors:2,datagap:maxgap, $
                          ytitle:'linear fit!cscpot!c[V]'}
         store_data,orbstr+'_mvn_swe_lpw_scpot_pow', $
                    data={x:tvinfl,y:scpot_pow}, $
                    dlim={colors:6,datagap:maxgap, $
                          ytitle:'power law fit!cscpot!c[V]'}
         store_data,orbstr+'_mvn_swe_lpw_scpot_lin_para', $
                    data={x:mean(trorb),y:[[a[0]],[a[1]],[corr]]}, $
                    dlim={psym:1,datagap:maxgap,labflag:1, $
                          labels:['offset','slope','corr'],colors:[2,6,0]}
         store_data,orbstr+'_mvn_swe_lpw_scpot_pow_para', $
                    data={x:mean(trorb),y:[[pow.p],[pow.h],[pow.bkg]]}, $
                    dlim={psym:1,datagap:maxgap,labflag:1, $
                          labels:['power','slope','offset'],colors:[0,2,6]}
         store_data,orbstr+'_mvn_swe_lpw_scpot_Ndata', $
                    data={x:mean(trorb),y:Nscat}, $
                    dlim={psym:1,datagap:maxgap}


         ;;; scat plot
         if keyword_set(plot) then begin
            bin2d,x,y,y,binsize=[.25,.25],xcent=xcent,ycent=ycent,flagnodata=!values.f_nan,binhist=binhist,xrange=[0,20],yrange=[-10,20]
            w = where(xcent gt 10 ,nw)
            for iw=0,nw-1,2 do begin
               binhist[w[iw],*] = binhist[w[iw],*]+binhist[w[iw]+1,*]
               binhist[w[iw]+1,*] = binhist[w[iw],*]
            endfor
            specplot,xcent,ycent,binhist, $
                     limits={xrange:[0,20],yrange:[-5,15], $
                             xtitle:'Vswe [V]',ytitle:'-Vinfl [V]', $
                             xmargin:[10,8],isotropic:1, $
                             title:time_string(trfit[0])+' -> ' $
                             +time_string(trfit[1]), $
                             no_interp:1,zlog:1, $
                             ztitle:'Ndata'}

            for il=-5,15,5 do oplot,[-10,20],[il,il],linestyle=1
            for il=-5,15,5 do oplot,[il,il],[-10,20],linestyle=1

            xplot = findgen(401)/10.-10.
            oplot,xplot,a[0]+a[1]*xplot,color=2
            oplot,xplot,pow.bkg+pow.h*xplot^pow.p,color=6
            oplot,xplot,alad[0]+alad[1]*(xplot+5),linestyle=2
            oplot,xplot,alad[0]+alad[1]*(xplot-5),linestyle=2
            xyouts,/norm,color=2,.15,.97,'linear fit!c' + $
                   'y = '+string(a[0],f='(f5.2)') $
                   +string(a[1],f='(f+5.2)')+'x' $
                   +'!cCorr. = '+string(corr,f='(f5.2)') $
                   +'!cNdata = '+string(Nscat,f='(i0)')
            xyouts,/norm,color=6,.55,.97,'power law fit!c' + $
                   'y = '+string(pow.bkg,f='(f6.2)') $
                   +string(pow.h,f='(f+6.2)')+'x^' $
                   +string(pow.p,f='(f4.2)')
            if keyword_set(figdir) then begin
               file_mkdir,figdir+time_string(mean(trorb),tf='scat/YYYY/MM/')
               makepng,figdir+time_string(mean(trorb),tf='scat/YYYY/MM/YYYYMMDD_')+orbstr
            endif
         endif

      endif                     ;- interp Vinfl to times -> minNdata
   endif                        ;- LPW Vinfl v Vswe


   ;;; tplot
   if keyword_set(plot) then begin
      store_data,'scpots', $
                 data=['mvn_swe_sc_pot',orbstr+'_mvn_swe_lpw_scpot_lin', $
                       orbstr+'_mvn_swe_lpw_scpot_pow'], $
                 dlim={labels:['swe','linear','power law'], $
                       colors:[0,2,6],labflag:1,dataga:maxgap,yrange:[0,20], $
                       constant:3}
      tplot,[ $
            'swe_comb', $
            'mvn_lpw_swp1_mode_bar', $
            'icur', $
            'mvn_lpw_swp1_IV', $
            'mvn_lpw_swp1_IV_log', $
            'IV_log_smo_comb', $
            'dIV_smo_comb', $
            'mvn_lpw_swp1_IV_vinfl_qflag', $
            'validiv', $
            'scpots', $
            'alt2' $
            ],trange=trorb,title='orbit #'+orbstr
      tplot_panel,var='icur',oplot='icur_med'
      if keyword_set(figdir) then begin
         file_mkdir,figdir+time_string(mean(trorb),tf='times/YYYY/MM/')
         makepng,figdir+time_string(mean(trorb),tf='times/YYYY/MM/YYYYMMDD_')+orbstr
      endif
   endif                        ;- plot

endfor                          ;- iorb



;;; concat and sort
tf = ['mvn_swe_lpw_scpot_lin','mvn_swe_lpw_scpot_pow', $
      'mvn_swe_lpw_scpot_lin_para','mvn_swe_lpw_scpot_pow_para', $
      'mvn_swe_lpw_scpot_Ndata' ]
for itf=0,n_elements(tf)-1 do begin
   tn = tnames('?????_'+tf[itf],ntn)
   if ntn gt 0 then begin
      for itn=0,ntn-1 do begin
         get_data,tn[itn],data=d,dlim=dlim
         if itn eq 0 then begin
            newx = d.x
            newy = d.y
            if tag_exist(d,'V') then newv = d.v
         endif else begin
            newx = [newx,d.x]
            newy = [newy,d.y]
            if tag_exist(d,'V') then begin
               if size(d.v,/n_dim) eq 2 then newv = [newv,d.v]
            endif
         endelse
      endfor
      if tag_exist(d,'V') then $
         store_data,tf[itf],data={x:newx,y:newy,v:newv},dlim=dlim $
      else store_data,tf[itf],data={x:newx,y:newy},dlim=dlim
      tplot_sort,tf[itf]
      store_data,tn,/del
   endif
endfor

store_data,'scpots', $
           data=['mvn_swe_sc_pot','mvn_swe_lpw_scpot_lin', $
                 'mvn_swe_lpw_scpot_pow'], $
           dlim={labels:['swe','linear','power law'], $
                 colors:[0,2,6],labflag:1,dataga:maxgap,yrange:[0,20], $
                 constant:3}

def_scpot = 'mvn_swe_lpw_scpot_pow'
get_data,def_scpot,data=d
store_data,'mvn_swe_lpw_scpot',data=d, $
           dlim={datagap:maxgap,ytitle:'SWEA-LPW!cscpot!c[V]'}


end



