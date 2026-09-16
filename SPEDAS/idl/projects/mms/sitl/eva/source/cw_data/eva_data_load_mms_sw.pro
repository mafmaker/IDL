PRO eva_data_load_mms_sw, sc=sc
  compile_opt idl2

  ; B
  ;------------
  tn = tnames(sc+'_dfg_srvy_dmpa',ct)
  if ct ne 1 then begin
    mms_sitl_get_dfg, sc_id=sc
    options,sc+'_dfg_srvy_gsm_dmpa',$
      labels=['B!DX!N', 'B!DY!N', 'B!DZ!N','|B|'],ytitle=sc+'!CDFG!Csrvy',ysubtitle='GSM [nT]',$
      colors=[2,4,6],labflag=-1,constant=0, cap=1
    options,sc+'_dfg_srvy_dmpa',$
      labels=['B!DX!N', 'B!DY!N', 'B!DZ!N','|B|'],ytitle=sc+'!CDFG!Csrvy',ysubtitle='DMPA [nT]',$
      colors=[2,4,6],labflag=-1,constant=0, cap=1
  endif

  ; V
  ;------------
  tn1 = tnames(sc+'_fpi_ion_vel_dbcs',ct1)
  tn2 = tnames(sc+'_fpi_density',ct2)
  if ct1*ct2 ne 1 then begin
    eva_data_load_mms_fpi, sc=sc
  endif

  ; Mach number
  ;------------
  tpN = sc+'_fpi_density'
  tpB = sc+'_dfg_srvy_gsm_dmpa'
  tpV = sc+'_fpi_ion_vel_dbcs'
  tpVe= sc+'_fpi_elec_vel_dbcs'
  tinterpol_mxn,tpB,tpN,newname=tpB+'_interp'; ....... interpolate
  get_data,tpB+'_interp',data=dataB,lim=limB, dl=dlB;........ geta data
  get_data,tpN,data=dataN,lim=limN,dl=dlN
  get_data,tpV,data=dataVi,lim=limV,dl=dlV
  get_data,tpVe,data=dataVe,lim=limVe,dl=dlVe
  Ni = dataN.Y; cm^-3 ........................................ calculation
  Babs = sqrt(dataB.y[*,0]^2+dataB.y[*,1]^2+dataB.y[*,2]^2); nT
  Va = 22.0*Babs/sqrt(Ni)
  Vswi = sqrt(dataVi.y[*,0]^2+dataVi.y[*,1]^2+dataVi.y[*,2]^2); km/s
  Vswe= sqrt(dataVe.y[*,0]^2+dataVe.y[*,1]^2+dataVe.y[*,2]^2); km/s
  Mai = Vswi/Va
  Mae = Vswe/Va 
  store_data,sc+'_sw_Va',data={x:dataN.X, y:Va};............. output
  options,sc+'_sw_Va',ytitle=sc+'!CV!DA!N',ysubtitle='[km/s]'
  
  store_data,sc+'_sw_Vswi',data={x:dataN.X, y:Vswi}
  store_data,sc+'_sw_Vswe',data={x:dataN.X, y:Vswe}
  options,sc+'_sw_Vswi',ytitle=sc+'!CVswi',ysubtitle='[km/s]'
  options,sc+'_sw_Vswe',ytitle=sc+'!CVswe',ysubtitle='[km/s]'

  store_data,sc+'_sw_Vsw',data=sc+'_sw_Vsw'+['i','e']
  options,sc+'_sw_Vsw', ytitle=sc+'!CVsw',ysubtitle='[km/s]',colors=[6,2],labels=['|Vi|','|Ve|'],labflag=-1


  store_data,sc+'_sw_Mai',data={x:dataN.X, y:Mai}
  store_data,sc+'_sw_Mae',data={x:dataN.X, y:Mae}
  store_data,sc+'_sw_Ma',data=sc+'_sw_Ma'+['i','e']

  
  
  
  options,sc+'_sw_Mai',constant=1.,ytitle=sc+'!CM!DAi!N'
  options,sc+'_sw_Mae',constant=1.,ytitle=sc+'!CM!DAe!N'
  options,sc+'_sw_Ma', constant=1.,ytitle=sc+'!CM!DA!N'
  
  
  ; Shock Angle
  ;--------------------
  
  
  Re = 6378.137
  dr = !dpi/180.
  rd = 1/dr
  tsearch = 1. ; minutes
  tsearch = 60.d0*double(tsearch); seconds
  tppos = sc+'_ql_pos_gse'
  tinterpol_mxn,tppos,tpN,newname=tppos+'_interp'; ....... interpolate
  get_data,tppos+'_interp',data=D
  nmax=n_elements(D.x)
  Vupi= fltarr(3)
  Vupe= fltarr(3)
  Bup = fltarr(3)
  Main= fltarr(nmax)
  Maen= fltarr(nmax)
  tBn = fltarr(nmax)
  for n=0,nmax-1 do begin
    xgse = D.y[n,0]/Re
    ygse = D.y[n,1]/Re
    zgse = D.y[n,2]/Re
    tgse = D.x[n]

    Vupi= [dataVi.y[n,0],dataVi.y[n,1],dataVi.y[n,2]]
    Vupe= [dataVe.y[n,0],dataVe.y[n,1],dataVe.y[n,2]]
    Bup = [dataB.y[n,0],dataB.y[n,1],dataB.y[n,2]]
    Babs = sqrt(Bup[0]^2+Bup[1]^2+Bup[2]^2)
    
    a0 = atan((Vupi[1]+29.78)/(-Vupi[0]))
    a0 *= rd
    result = model_boundary_normal(xgse, ygse, zgse, a0=a0)
    nrm = [result.nx[0],result.ny[0], result.nz[0]]

    thetaBnp = acos((Bup[0]*nrm[0]+Bup[1]*nrm[1]+Bup[2]*nrm[2])/Babs)
    thetaBnm = acos(-(Bup[0]*nrm[0]+Bup[1]*nrm[1]+Bup[2]*nrm[2])/Babs)
    Vupni = Vupi[0]*nrm[0]+Vupi[1]*nrm[1]+Vupi[2]*nrm[2]
    Vupne = Vupe[0]*nrm[0]+Vupe[1]*nrm[1]+Vupe[2]*nrm[2]
    thetaBn = thetaBnp*rd
    if thetaBn gt 90. then thetaBn = thetaBnm*rd
    tBn[n] = thetaBn
    Main[n] = abs(Vupni)/Va[n]
    Maen[n] = abs(Vupne)/Va[n]

  endfor
  store_data,sc+'_sw_Main',data={x:dataN.X, y:Main}
  store_data,sc+'_sw_Maen',data={x:dataN.X, y:Maen}
  options,sc+'_sw_Main',ytitle=sc+'!CM!DA n i!N',constant=[10,20,30,40,50,60,70,80,90,100]
  options,sc+'_sw_Maen',ytitle=sc+'!CM!DA n e!N',constant=[10,20,30,40,50,60,70,80,90,100]
  store_data,sc+'_sw_Man',data=sc+'_sw_Ma'+['i','e']+'n'
  options,sc+'_sw_Man',ytitle=sc+'!CM!DA n!N',colors=[6,2],labels=['Vi/V!DA!N','Ve/V!DA!N'],labflag=-1
  
  store_data,sc+'_sw_tBn',data={x:dataN.X, y:tBn}
  ylim,sc+'_sw_tBn',0,90,0
  options,sc+'_sw_tBn', ytitle=sc+'!Ctheta',ysubtitle='Bn'
  options,sc+'_sw_tBn','constant',[20,45,70]

END
