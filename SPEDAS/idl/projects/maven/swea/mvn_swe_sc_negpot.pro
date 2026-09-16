;+
;PROCEDURE:
;   mvn_swe_sc_negpot
;
;PURPOSE:
;   Estimates the negative spacecraft potential within the ionosphere
;   from SWEA energy spectra.  The basic idea is to use the second 
;   derivative of the spectrum to find the shift of the He II features
;   at 23 and 27 eV (mainly the 23 eV feature), from which then the 
;   negative potential can be calculated.  No attempt is made to 
;   estimate the potential when the spacecraft is in darkness or above
;   1000 km altitude.
;
;AUTHOR:
;   Shaosui Xu
;
;CALLING SEQUENCE:
;   This procedure requires tplot variables "mvn_swe_shape_par, swe_a4, alt,
;   sza, d2f".  If any of these variables does not exist, then this procedure
;   attempts to create them using the appropriate procedures.
;   
;INPUTS:
;   none
;
;KEYWORDS:
;
;   OVERLAY:   Overlay the result on the energy spectrogram.
;
;   FILL:      Store the potentials to the swe_sc_pot common block.
;              Default = 1 (yes).
;
;OUTPUTS:
;   None - Result is stored as a TPLOT variable 'neg_pot'.
;
; $LastChangedBy: dmitchell $
; $LastChangedDate: 2016-09-19 17:04:47 -0700 (Mon, 19 Sep 2016) $
; $LastChangedRevision: 21872 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/maven/swea/mvn_swe_sc_negpot.pro $
;
;-

pro mvn_swe_sc_negpot, overlay=overlay, fill=fill

    compile_opt idl2
    
    @mvn_swe_com
    
    if (size(fill,/type) eq 0) then fill = 1

; Make sure SWEA data are loaded.

    get_data, 'swe_a4', data=spec, index=i
    if (i eq 0) then begin
      print,"You must load SWEA data first."
      return
    endif
    f40=spec.y[*,40]  ; electron flux of 43 eV

; Get the shape parameter from tplot.  Calculate it if necessary.

    get_data, 'mvn_swe_shape_par', data=shp, index=i
    if (i eq 0) then begin
      mvn_swe_shape_par, var='swe_a4', erange=[15,100], /keep_nan
      get_data, 'mvn_swe_shape_par', data=shp, index=i
      if (i eq 0) then begin
        print,"Error getting shape parameter.  Abort!"
        return
      endif
    endif
    shape=shp.y

; Get ephemeris information from tplot.  Calculate it if necessary.

    get_data, 'alt', data=alt0, index=i
    if (i eq 0) then begin
      maven_orbit_tplot, /loadonly
      get_data, 'alt', data=alt0
    endif
    alt=alt0.y
    talt=alt0.x

    get_data,'sza',data=sza0
    sza=sza0.y

; Get d2(logF)/d(logE)2 from tplot.  Calculate it if necessary.

    get_data, 'd2f', data=d2f0, index=i
    if (i eq 0) then begin
      mvn_swe_sc_pot, /over
      get_data, 'd2f', data=d2f0
    endif
    t1=d2f0.x
    d2f=d2f0.y
    en1=d2f0.v
    alt1=spline(talt,alt,t1)
    sza1=spline(talt,sza,t1)
    pot1=dblarr(n_elements(t1))
    pot1[*]=!values.f_nan
    heii_pot1=pot1
    altcut=400;8000
    ;calculate terminator
    base=150 ;to set a slightly higher altitude to avoid falsely identifying potentials
    R_m=3396.
    term=90+acos((R_m+base)/(R_m+alt1))*!radeg
    indx=where((f40 gt 1.e6 and sza1 le term) and $
        (alt1 le altcut or (alt1 gt altcut and alt1 le 1000 and shape le 0.8)),cts)

    lim=-0.05
    ebase=23-0.705

    ;******************************************************************************************
    ;Mth 2
    ;ine=where(en ge 4)
    orb=floor(mvn_orbit_num(time=t1))+0.5
    for io=min(orb),max(orb) do begin
        ino=where(orb[indx] eq io, ox)
        if ox gt 1 then begin
            for i=0, ox - 1 do begin
                spec=reform(d2f[indx[ino[i]],*])
                en = reform(en1[indx[ino[i]],*])

                inn = where(spec le lim, npt)
                inp = where(spec gt 0.04, np)

                emax = max(en[inn], min=emin)
                emap = max(en[inp], min=emip)
                if (npt gt 0 and np gt 0) then begin
                    if (emax-emin le 10) and (emax-emin gt 2) and $
                        (emin le ebase and emin gt 3.5) then begin
                        ; (abs(median(en[inn])-0.5*(emin+emax)) le 1) and
                        pot1[indx[ino[i]]]=emin-ebase
                        heii_pot1[indx[ino[i]]] = emin
                        if (pot1[indx[ino[i]]] le -5 and alt1[indx[ino[i]]] gt altcut) then $
                            pot1[indx[ino[i]]]=!values.f_nan
                    endif else begin
                        if alt1[indx[ino[i]]] le 200 and emin gt 6 and emin le 9 $
                            and emap le 10 and emap gt 5 then begin
                            pot1[indx[ino[i]]]=emin-ebase-3
                            heii_pot1[indx[ino[i]]] = emin
                        endif
                    endelse
                endif
                ;stop
            endfor

            inc=where(pot1[indx[ino]] eq pot1[indx[ino]], npts)
            dx=indx[ino[inc]]
            if dx[0] ne -1 then pot1[indx[ino[inc[0]:inc[npts-1]]]]=$
                interpol(pot1[indx[ino[inc[0]:inc[npts-1]]]],$
                t1[indx[ino[inc[0]:inc[npts-1]]]],t1[indx[ino[inc[0]:inc[npts-1]]]],/nan)
            ;stop
        endif
    endfor



    pot={x:t1,y:pot1}
    str_element,pot,'thick',4,/add
    str_element,pot,'psym',3,/add
    store_data, 'neg_pot', data=pot
    options,'neg_pot','constant',15

    pot={x:t1,y:heii_pot1}
    str_element,pot,'thick',4,/add
    str_element,pot,'psym',3,/add
    store_data, 'heii_pot', data=pot

    if keyword_set(overlay) then begin
        store_data,'d2f_pot',data=['d2f','heii_pot']
        ylim,'d2f_pot',0,30
        zlim,'d2f_pot',-0.05,0.05
    endif
    
    if keyword_set(fill) then begin
        indx = where((finite(pot1) and (alt1 le altcut)), cts)
        if (cts gt 0) then begin
          mvn_swe_engy[indx].sc_pot  = pot1[indx]
          swe_sc_pot[indx].potential = pot1[indx]
        endif
    endif
    ;stop
end