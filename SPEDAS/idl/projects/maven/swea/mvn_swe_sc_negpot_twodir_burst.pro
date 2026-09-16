;+
;PROCEDURE:
;   mvn_swe_sc_negpot_twodir_burst
;
;PURPOSE:
;   Estimates potentials from the shift of He II features 
;   for both anti-parallel and parallel directions with 
;   SWEA PAD data. Right now it only works for burst data. 
;
;INPUTS:
;   none
;
;KEYWORDS:
;
;   SHADOW:   If keyword set, all the estimations outside of shadow
;             are set to NANs
;   SWIDTH:   Field-aligned angle to calculate spectra for both
;             directions. The default value is 45 degrees. 
;
;OUTPUTS:
;   None - Potential results are stored as a TPLOT variable 'negpot_pad'. 
;          Other four TPLOT variables are also created for diagnostic purpose. 
;
; $LastChangedBy: $
; $LastChangedDate: $
; $LastChangedRevision: $
; $URL: $
;
;CREATED BY:    Shaosui Xu  01-03-2017
;-
Pro mvn_swe_sc_negpot_twodir_burst,shadow=shadow,swidth=swidth

    @mvn_swe_com
    print,'This program is still under experimenting stage'
    
    a3 = mvn_swe_pad_arc
    if (size(mvn_swe_pad_arc,/type) ne 8) then begin
       get_timespan,trange
       mvn_swe_load_l2,trange,/pad,/burst,/noerase
    endif

    if ~(keyword_set(swidth)) then $
           swidth=45.*!dtor $
    else swidth = swidth*!dtor

    tmin = min(a3.time, max=tmax)
    data = a3.data
    ;tic
    a3.data = smooth(data,[1,1,5],/nan)
    ;toc
    tsp = [tmin, tmax]
    npkt = n_elements(a3)                 ; number of spectra
    t = a3.time
    if npkt eq 0 then return

    pot = fltarr(npkt,2)
    pot[*,*] = !values.f_nan
    heii_pot = pot
    d2fps = fltarr(npkt,100)
    d2fms = d2fps
    std = fltarr(npkt,2)
    tic
    for i=0L,(npkt-1L) do begin

        pad = a3[i]  ; smooth in energy
        ;pad = padall[i]
        energy=pad.energy[*,0]

        Fp = replicate(!values.f_nan,64)
        Fm = replicate(!values.f_nan,64)
        Fz = replicate(!values.f_nan,64)

        pndx = where(reform(pad.pa[63,*]) lt swidth, count)
        if (count gt 0L) then Fp = average(reform(pad.data[*,pndx]*pad.dpa[*,pndx]), 2, /nan)$
            /average(pad.dpa[*,pndx], 2, /nan)
        mndx = where(reform(pad.pa[63,*]) gt (!pi - swidth), count)
        if (count gt 0L) then Fm =average(reform(pad.data[*,mndx]*pad.dpa[*,mndx]), 2, /nan)$
            /average(pad.dpa[*,mndx], 2, /nan)
        zndx = where((reform(pad.pa[63,*]) lt (!pi - swidth)) and $
            (reform(pad.pa[63,*]) gt swidth), count)
        if (count gt 0L) then Fz=average(reform(pad.data[*,zndx]*pad.dpa[*,zndx]), 2, /nan)$
            /average(pad.dpa[*,zndx], 2, /nan)
        ie = 64-18 ;20 eV

        mvn_swe_d2f_heii,Fp,Fm,energy,d2fp,d2fm,ee
        nee = n_elements(ee)
        d2fps[i,0:nee-1] = d2fp
        d2fms[i,0:nee-1] = d2fm

        ;parallel
        spec=d2fp
        en = ee
        lim=-0.05
        ebase=23-0.705

        inn = where(spec le lim, npt)
        inp = where(spec gt 0.04, np)
        emax = max(en[inn], min=emin)
        emax = min([emax,27.])
        emap = max(en[inp], min=emip)
        if (npt gt 0 and np gt 0 and Fp[ie] ge 5.e6) then begin
            inmm = where(en ge emin and en le 2*median(en[inn])-emin)
            inpp = where(spec[inmm] gt 0.04,ct)
            std[i,0] = stddev(spec[inmm])
            if (emax-emin le 10) and (emax-emin gt 2.5) and $
                (emin le ebase and emin gt 3.5) and $
                (abs(median(en[inn[*]])-0.5*(emax+emin)) le 2) then begin
                pot[i,0] = emin-ebase
                heii_pot[i,0] = emin
                if emin-ebase ge -14 and ct gt 5 then $
                    pot[i,0] = !values.f_nan

            endif
        endif

        ;anti-parallel
        spec=d2fm
        inn = where(spec le lim, npt)
        inp = where(spec gt 0.04, np)
        emax = max(en[inn], min=emin)
        emax = min([emax,27.])
        emap = max(en[inp], min=emip)
        if (npt gt 0 and np gt 0 and Fm[ie] ge 5.e6) then begin
            inmm = where(en ge emin and en le 2*median(en[inn])-emin)
            inpp = where(spec[inmm] gt 0.04,ct)
            std[i,1] = stddev(spec[inmm])
            if (emax-emin le 10) and (emax-emin gt 2.5) and $
                (emin le ebase and emin gt 3.5) and $
                (abs(median(en[inn[*]])-0.5*(emax+emin)) le 2) then begin
                pot[i,1] = emin-ebase
                heii_pot[i,1] = emin
                if emin-ebase ge -14 and ct gt 5 then $
                    pot[i,1] = !values.f_nan
            endif
        endif
    endfor
    toc
    print,'finished calculating potentials'
    d2fps = d2fps[*,0:nee-1]
    d2fms = d2fms[*,0:nee-1]

    if keyword_set(shadow) then begin
        get_data, 'wake', data=wk0, index=i
        if (i eq 0) then begin
            maven_orbit_tplot, /loadonly
            get_data, 'wake', data=wk0
        endif
        wake = interpol(wk0.y,wk0.x,t)
        inw = where(wake ne wake, cts)
        if cts gt 0 then pot[inw,*] = !values.f_nan
    endif

    ;create tplot variable
    store_data,'negpot_pad',data={x:t, y:pot[*,0:1]}
    name='negpot_pad'
    options,name,'ytitle','negpot'
    options,name,'labels',['para','anti-para']
    options,name,'colors',[254,64]
    options,name,'psym',3

    store_data,'d2fp',data={x:t,y:d2fps,v:ee}
    ename='d2fp'
    options,ename,'spec',1
    ylim,ename,10,30,0
    options,ename,'ytitle','Energy (eV)'
    options,ename,'ztitle',ename
    store_data,'heiip',data={x:t, y:heii_pot[*,0]}
    name='heiip'
    options,name,'psym',1

    store_data,'d2fp_pot',data=['d2fp','heiip']
    ylim,'d2fp_pot',10,30,0
    zlim,'d2fp_pot',-0.05,0.05,0

    store_data,'d2fm',data={x:t,y:d2fms,v:ee}
    ename='d2fm'
    options,ename,'spec',1
    ylim,ename,10,30,0
    options,ename,'ytitle','Energy (eV)'
    options,ename,'ztitle',ename
    store_data,'heiim',data={x:t, y:heii_pot[*,1]}
    name='heiim'
    options,name,'psym',1

    store_data,'d2fm_pot',data=['d2fm','heiim']
    ylim,'d2fm_pot',10,30,0
    zlim,'d2fm_pot',-0.05,0.05,0

    ;stop
end
