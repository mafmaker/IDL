;20160404 Ali
;This code uses analytical solutions to the equations of motion
;of pickup ions in the upstream undistrubed solar wind uniform fields
;and finds pickup ion fluxes near Mars at the location of MAVEN.
;For more info, refer to Ali's PhD thesis (2016), also see Rahmati et al. (2014, 2015)
;Note that the results are only valid when MAVEN is outside the bow shock
;and in the upstream undisturbed solar wind, when upstream drivers are available.
;This code assumes that the user has access to the MAVEN PFP data.
;mvn_pui_tplot can be used to store and plot 3d pickup ion model-data comparisons.
;please send bugs/comments to rahmati@ssl.berkeley.edu
;
;Keywords:
;   binsize: specifies the time cadense (time bin size) for simulation in seconds. if not set, default is used (32 sec)
;   trange: time range for simulation. if not set, timespan will be called
;   np: number of simulated particles in each time bin. if not set, default is used (1000 particles)
;   nodataload: does not load any data. use if you want to re-run the simulation with all the required data already loaded
;   do3d: models pickup oxygen and hydrogen 1D spectra for SWIA and STATIC, a bit slower than 1D spectra
;   exoden: sets exospheric neutral densities to n(r)=1 cm-3 for exospheric density reverse model retrieval 

pro mvn_pui_model,binsize=binsize,trange=trange,np=np,nodataload=nodataload,nosep=nosep,nostatic=nostatic,do3d=do3d,exoden=exoden

@mvn_pui_commonblock.pro ;common mvn_pui_common

srmd=700; %sep response matrix dimentions
sopeb=30 ;sep open # of energy bins
swieb=48 ;swia # of energy bins
staeb=64 ;static # of energy bins
sweeb=64 ;swea # of energy bins
toteb=100;total flux # of energy bins
swina=16;swia and static # of azimuth bins
swine=4;swia and static # of elevation bins
swiatsa=!pi*2.8 ; SWIA and STATIC total solid angle (2.8pi sr)
swidee=.14464; %SWIA dE/E
stadee=.1633; %STATIC dE/E
swedee=.1165; %SWEA dE/E
totdee=.1 ;total flux binning dE/E

if ~keyword_set(binsize) then binsize=32 ;simulation resolution/cadense (seconds)
if ~keyword_set(np) then np=1000; %number of simulated particles (1000 is enough for one gyro-period)
if ~keyword_set(trange) then get_timespan,trange else timespan,trange ;time range
if ~keyword_set(nodataload) then mvn_pui_data_load,do3d=do3d,nosep=nosep,nostatic=nostatic ;load tplot variables
mvn_pui_data_res,trange=trange,binsize=binsize ;change data resolution and load instrument pointings
mvn_pui_data_analyze ;analyze data

ttdtsf=1. ;time to do the simulation factor!
if keyword_set(do3d) then ttdtsf=2.4 ;2.4 times slower if you do3d!

dprint,dlevel=2,'All data loaded successfully, the pickup ion model is now calculating...'
dprint,dlevel=2,'The simulation should take ~'+strtrim(ceil(10.*np*inn/1000./2880.*ttdtsf),2)+' seconds on a modern machine.'
simtime=systime(1) ;simulation start time, let's do this!

;modeling pickup oxygen
mamu=16; %mass of [H=1 C=12 N=14 O=16] (amu)
ntg=0.999 ;for SEP one full gyro-period is necessary
if keyword_set(exoden) then ntg=0.499 ;half a gyro-period is enough for SWIA/STATIC
mvn_pui_solver,mamu=mamu,np=np,ntg=ntg ;solve pickup ion trajectories
nfac=replicate(1.,inn,np) ;neutral density scale factor (scales according to radius)
nfac[where(rxyz lt 6000e3,/null)]=10. ;increase in electron impact ionization rate inside the bow shock due to increased electron flux
nfac[where(rxyz lt 3600e3,/null)]=0. ;no pickup source below the exobase (zero neutral density)
rxyz[where(rxyz lt 3600e3,/null)]=3600e3 ;to ensure the radius doesn't go below the exobase
qqo=5e22; %for Mars oxygen exosphere (m-0.9) fit to Rahmati et al., 2014
ntot=1e-4*nfac*(ifreq_o#replicate(1.,np))*drxyz*qqo/((rxyz-2400e3)^2.1); %total pickup O+ flux (cm-2 s-1)
if keyword_set(exoden) then ntot=1e2*(ifreq_o#replicate(1.,np))*drxyz ; %total pickup O+ flux (cm-2 s-1) assuming n(r)=1 cm-3
mvn_pui_binner,np=np,do3d=do3d ;bin the results

kefluxo=keflux/totdee; total pickup oxygen angle integrated differential energy flux (eV/[cm2 s eV])
kefswio=kefswi/swidee/swiatsa; %differential energy flux (eV/[cm2 s sr eV])
kefstao=kefsta/stadee/swiatsa; %differential energy flux (eV/[cm2 s sr eV])
if keyword_set(do3d) then begin
  kefswio3d=kefswi3d/stadee/swiatsa*swina*swine; %differential energy flux (eV/[cm2 s sr eV])
  kefstao3d=kefsta3d/stadee/swiatsa*swina*swine; %differential energy flux (eV/[cm2 s sr eV])
  krxswio3d=krxswi3d
  kryswio3d=kryswi3d
  krzswio3d=krzswi3d
  knnswio3d=knnswi3d
endif

seprm=replicate(0.,srmd,srmd); %sep response matrix, very crude!
for j=0,srmd-1 do for i=0,srmd-1 do seprm[j,i]=.05*exp(-.01*(i-.8*j+30.)^2)
seprm[*,0:10]=0; %sep electronic noise threshold = 11 keV
sepde=total(seprm,2); %sep pickup oxygen detection efficiency
seprm*=sepde#replicate(1.,srmd) ;this makes the response matrix look more realistic!
sepflux1=seprm##keflux1; sep1 differential flux (/[cm2 s keV])
sepflux2=seprm##keflux2; %sep2 flux
sepet=[1,8,10,11,13,15,17,20,24,30,37,47,60,77,100,130,169,220,300,400,500,650]; %sep energy table (keV)
sepeb1=replicate(0.,inn,sopeb); sep energy binning
sepeb2=replicate(0.,inn,sopeb)
for i=0,20 do begin ;very crude way of binning, needs to be changed!
sepeb1[*,i]=total(sepflux1[*,sepet[i]-1:sepet[i+1]-1],2);
sepeb2[*,i]=total(sepflux2[*,sepet[i]-1:sepet[i+1]-1],2);
endfor

;reducing the count rates by a factor of 100 when the SEP attenuator is closed
if keyword_set(sep1data) then begin
  sepeb1att=sepeb1/(99.*(sep1att#replicate(1,sopeb))-98)
  sepeb2att=sepeb2/(99.*(sep2att#replicate(1,sopeb))-98)
endif

store_data,'O+_Max_Energy_(keV)',centertime,kemax/1e3 ;pickup oxygen max energy (keV)
dprint,dlevel=2,'Pickup O+ done, now simulating pickup H+'

;Now let's model pickup hydrogen
mamu=1; %mass of [H=1 C=12 N=14 O=16] (amu)
ntg=2.999 ;a few gyro-periods required for pickup hydrogen
if keyword_set(exoden) then ntg=0.999 ;for exoden
mvn_pui_solver,mamu=mamu,np=np,ntg=ntg ;solve pickup ion trajectories
rxyz[where(rxyz lt 3600e3,/null)]=3600e3 ;to ensure the radius doesn't go below the exobase
qqh=4e27; %for Mars hydrogen exosphere (m-0.3) fit to Feldman et al., 2011
ntot=1e-4*(ifreq_h#replicate(1.,np))*drxyz*qqh/((rxyz-2700e3)^2.7); %total pickup H+ flux (cm-2 s-1)
if keyword_set(exoden) then ntot=1e2*(ifreq_h#replicate(1.,np))*drxyz ; %total pickup H+ flux (cm-2 s-1) assuming n(r)=1 cm-3
mvn_pui_binner,np=np,do3d=do3d ;bin the results
;-------------
;let's add other stuff and see what happens!
;mamu=16+16; %mass of [H=1 C=12 N=14 O=16] (amu)
;mvn_pui_solver,mamu=mamu,np=np,ntg=0.999 ;solve pickup ion trajectories
;qqh=1; %production rate (cm-3 s-1)
;nfac=replicate(0.,inn,np) ;density is zero everywhere, except...
;nfac[where((rxyz lt 10000e3),/null)]=1. ;density is non-zero below...
;ntot=drxyz*qqh*nfac; %pickup flux (cm-2 s-1)
;mvn_pui_binner,mamu=mamu,np=np,do3d=do3d ;bin the results
;-------------
kefluxh=keflux/totdee; total pickup hydrogen angle integrated differential energy flux (eV/[cm2 s eV])
kefswih=kefswi/swidee/swiatsa; %differential energy flux (eV/[cm2 s sr eV])
kefstah=kefsta/stadee/swiatsa; %differential energy flux (eV/[cm2 s sr eV])
if keyword_set(do3d) then begin
  kefswih3d=kefswi3d/stadee/swiatsa*swina*swine; %differential energy flux (eV/[cm2 s sr eV])
  kefstah3d=kefsta3d/stadee/swiatsa*swina*swine; %differential energy flux (eV/[cm2 s sr eV])
  krxswih3d=krxswi3d
  kryswih3d=kryswi3d
  krzswih3d=krzswi3d
  knnswih3d=knnswi3d
endif

if ~keyword_set(exoden) then mvn_pui_tplot,/store1d,/tplot1d ;store the results in tplot variables and plot them
dprint,dlevel=2,'Simulation time: '+strtrim(systime(1)-simtime,2)+' seconds'

end
