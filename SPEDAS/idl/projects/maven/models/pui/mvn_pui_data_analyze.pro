;20160404 Ali
;MAVEN data analysis:
;SWEA/SWIA solar wind moments, ionization frequencies, etc.
;to be called by mvn_pui_model

pro mvn_pui_data_analyze

@mvn_pui_commonblock.pro ;common mvn_pui_common

mi=1.67e-24; %proton mass (g)
me=9.1e-28; %electron mass (g)
qe=1.602e-12; %electron charge (erg/ev)
hpc=6.626e-34; %Planck's constant (J.s) or (m2 kg/s)
csl=2.998e8; %speed of light (m/s)

cxsig=[2e-15,8e-16]; H, O solar wind proton charge exchange cross sections (cm2)

stack = scope_traceback(/structure)
;printdat,stack,nstr=3
dirname = file_dirname(stack[scope_level()-1].filename) + '/'
;printdat,dirname
;euvcs = read_asc(dirname+'mvn_euv_nm_h_o_pi_sig_mb.txt',format={wavelength:0.,Hphoto_cs:0.,Ox_photo_cs:0.})

;read cross-section files
openr,lun,dirname+'mvn_euv_nm_h_o_pi_sig_mb.txt',/get_lun
xsec_pi=replicate(0.,3,190) ;fism bins (nm), H, O photo-ionization cross sections (mb)  
readf,lun,xsec_pi
free_lun,lun

openr,lun,dirname+'mvn_swe_ev_h_o_ei_sig_mb.txt',/get_lun
xsec_ei=replicate(0.,3,sweeb) ;swea bins (eV), H, O electron impact cross sections (mb)
readf,lun,xsec_ei
free_lun,lun

;FISM daily irradiance (W/m2/nm)
if n_elements(fismir) eq 1 then begin
  dprint,dlevel=2,'No EUVM L3 (FISM) files were found, using default photo-ionization frequencies.'
  i_pi_h=1e-7*replicate(1.,inn)
  i_pi_o=2e-7*replicate(1.,inn)
endif else begin
fismen=hpc*csl/xsec_pi[0,*]*1e9; %FISM energy (J)
fismfl=fismir/(replicate(1.,inn)#fismen)/1e4; %FISM flux (/cm2 s nm)
ifreq_pi_h=1e-18*(replicate(1.,inn)#xsec_pi[1,*])*fismfl;
i_pi_h=total(ifreq_pi_h,2) ;photo-ionization frequency (s-1)
ifreq_pi_o=1e-18*(replicate(1.,inn)#xsec_pi[2,*])*fismfl;
i_pi_o=total(ifreq_pi_o,2)
endelse

;%%%%%%SWIA data analysis
;%swiaef: solar wind ion energy flux (eV/[cm2 s sr eV])
swphi=nsw*(1e2*usw); %solar wind ion flux (cm-2 s-1)
ifreq_cx=swphi#cxsig; %charge exchange ionization frequency (s-1)
i_cx_h=ifreq_cx[*,0]
i_cx_o=ifreq_cx[*,1]
;ivel=sqrt(2*swiet*qe/mi); %ion velocity (cm/s)
;swiaefai=swiaef.*(ones(inn,1)*2*16*(swiasa1+swiasa2)); %angle integrated differential energy flux (eV/[cm2 s eV])
;swiadf=swiaefai./(ones(inn,1)*swiet'); %SWIA differential flux (/[cm2 s eV])
;swiadn=swiadf./(ones(inn,1)*ivel'); %SWIA differential density (/[cm3 eV])
;swian=swidee*swiaefai*(1./ivel); %SWIA density (cm-3)
;swiaf=swidee*sum(swiaefai,2); %SWIA flux (cm-2 s-1)
;swiae=sum(swiaefai,2)./sum(swiadf,2); %SWIA temperature (eV)
;swiav=sqrt(2*swiae*qe/mi); %SWIA velocity (cm/s)
;swiaf2=swian.*swiav;
;%%%%

;%%%%%%SWEA data analysis
;%sweaef: solar wind electron energy flux (eV/[cm2 s sr eV])
;evel=sqrt(2*sweaet(:,1)*qe/me); %electron velocity (cm/s)
;sweadf=sweaef./(ones(inn,1)*sweaet(:,1)'); %SWEA differential flux (cm-2 s-1 sr-1 eV-1)
;sweadn=sweadf./(ones(inn,1)*evel'); %SWEA differential density (cm-3 sr-1 eV-1)
;dvswea=13; %SWEA energy correction due to S/C potential
;swean=4*pi*sweadee*sweaef(:,1:64-dvswea)*(1./evel(1:64-dvswea)); %SWEA density (cm-3)
;sweae=sum(sweaef,2)./sum(sweadf,2); %SWEA temperature (eV)
ifreq_ei_h=4*!pi*swedee*sweaef*(replicate(1.,inn)#xsec_ei[1,*])*1e-18; %H electron impact ionization frequency (s-1 per energy bin)
ifreq_ei_o=4*!pi*swedee*sweaef*(replicate(1.,inn)#xsec_ei[2,*])*1e-18; %O electron impact ionization frequency (s-1 per energy bin)
i_ei_h=total(ifreq_ei_h,2); %H electron impact ionization frequency (s-1)
i_ei_o=total(ifreq_ei_o,2); %O electron impact ionization frequency (s-1)
i_ei_h(where(~finite(i_ei_h),/null))=1.2e-8 ;in case SWEA data is not available, use default ionization frequency.
i_ei_o(where(~finite(i_ei_o),/null))=2e-8
;%%%%

;ifreq=4.5e-7; O total ionization frequency (s-1) per Rahmati et al., 2014
ifreq_h=i_pi_h+i_cx_h+i_ei_h; %H total ionization frequency (s-1)
ifreq_o=i_pi_o+i_cx_o+i_ei_o; %O total ionization frequency (s-1)

store_data,'Ionization_Frequencies_(s-1)',centertime,[[ifreq_o],[ifreq_h],[i_pi_o],[i_pi_h],[i_cx_o],[i_cx_h],[i_ei_o],[i_ei_h]]
ylim,'Ionization_Frequencies_(s-1)',1e-8,1e-6,1

end