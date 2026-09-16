;+
; PROCEDURE:
;       mms_curl
;
; PURPOSE:
;       This routine calculates div B and curl B for a specified time interval
;
; NOTES:  
;       The input B-field data and position data are expected to be in 
;       GSE coordinates
; 
;       Original by Jonathan Eastwood, with changes from Tai Phan
;       Minor modifications for SPEDAS by egrimes
;
;
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-11-29 08:40:37 -0800 (Tue, 29 Nov 2016) $
; $LastChangedRevision: 22410 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/mms/common/curlometer/mms_curl.pro $
;-

pro mms_curl, trange=trange, fields=fields, positions=positions, suffix=suffix
  if undefined(suffix) then suffix = ''
  if undefined(fields) || undefined(positions) then begin
    dprint, dlevel = 0, 'B-field and spacecraft position keywords required.'
    return
  endif
  
  if ~undefined(trange) && n_elements(trange) eq 2 $
    then t_curl = timerange(trange) $
  else t_curl = timerange()

  ;*********************************************************
  ; Magnetic Field
  ;*********************************************************
  ;interpolate the magnetic field data all onto the same timeline (MMS1):
  ; should be in GSE coordinates
  tinterpol, fields[1], fields[0], newname=fields[1]+'_i'
  tinterpol, fields[2], fields[0], newname=fields[2]+'_i'
  tinterpol, fields[3], fields[0], newname=fields[3]+'_i'

  ;interpolate the definitive ephemeris onto the magnetic field timeseries
  ; should be in GSE coordinates
  tinterpol, positions[0], fields[0], newname=positions[0]+'_i'
  tinterpol, positions[1], fields[0], newname=positions[1]+'_i'
  tinterpol, positions[2], fields[0], newname=positions[2]+'_i'
  tinterpol, positions[3], fields[0], newname=positions[3]+'_i'
  
  ;some constants
  m0 = 4.*!dpi*1.e-7;

  b1 = tsample(fields[0], t_curl, times = timeb1)
  b1 = b1[*,0:2]
  b2 = tsample(fields[1]+'_i', t_curl, times = timeb2)
  b2 = b2[*,0:2]
  b3 = tsample(fields[2]+'_i', t_curl, times = timeb3)
  b3 = b3[*,0:2]
  b4 = tsample(fields[3]+'_i', t_curl, times = timeb4)
  b4 = b4[*,0:2]

  ;extract the spacecraft location arrays
  p1 = transpose(tsample(positions[0]+'_i',t_curl))
  p2 = transpose(tsample(positions[1]+'_i',t_curl))
  p3 = transpose(tsample(positions[2]+'_i',t_curl))
  p4 = transpose(tsample(positions[3]+'_i',t_curl))

  ;some arrays we need
  divb = dindgen(n_elements(timeb1), 5)
  baryb = dindgen(n_elements(timeb1), 3)
  baryb2 = dindgen(n_elements(timeb1), 3)
  baryb3 = dindgen(n_elements(timeb1), 3)
  baryb4 = dindgen(n_elements(timeb1), 3)
  sampleb = dindgen(n_elements(timeb1), 3)

  jtotal = dindgen(n_elements(timeb1), 4)
  btotal = dindgen(n_elements(timeb1), 1)
  jparallel = dindgen(n_elements(timeb1), 1)
  jperpvec = dindgen(n_elements(timeb1),4)
  jperp = dindgen(n_elements(timeb1), 1)
  alphaparallel = dindgen(n_elements(timeb1), 1)
  alpha = dindgen(n_elements(timeb1), 1)

  ;leave as a loop for now because you have to construct and manipulate a matrix for each time step.
  for i=0,n_elements(timeb1)-1 do begin

    p12 = p2[0:2,i]-p1[0:2,i]
    p13 = p3[0:2,i]-p1[0:2,i]
    p14 = p4[0:2,i]-p1[0:2,i]

    k2 = crossp(p13,p14)#(1./(p12##transpose(crossp(p13,p14))))
    k3 = crossp(p12,p14)#(1./(p13##transpose(crossp(p12,p14))))
    k4 = crossp(p12,p13)#(1./(p14##transpose(crossp(p12,p13))))

    k1 = 0-k4-k3-k2

    curlmag = crossp(k1,b1[i,*])+crossp(k2,b2[i,*])+crossp(k3,b3[i,*])+crossp(k4,b4[i,*])
    divergence = b1[i,*]#k1+b2[i,*]#k2+b3[i,*]#k3+b4[i,*]#k4

    gradbx = b1[i,0]*k1+b2[i,0]*k2+b3[i,0]*k3+b4[i,0]*k4
    gradby = b1[i,1]*k1+b2[i,1]*k2+b3[i,1]*k3+b4[i,1]*k4
    gradbz = b1[i,2]*k1+b2[i,2]*k2+b3[i,2]*k3+b4[i,2]*k4

    barycentre = (p1[0:2,i]+p2[0:2,i]+p3[0:2,i]+p4[0:2,i])/4.

    ;and here is the field at the barycentre (calculate 4 ways)
    baryb[i,0] = b1[i,0] + total(gradbx*(barycentre-p1[0:2,i]))
    baryb[i,1] = b1[i,1] + total(gradby*(barycentre-p1[0:2,i]))
    baryb[i,2] = b1[i,2] + total(gradbz*(barycentre-p1[0:2,i]))

    baryb2[i,0] = b2[i,0] + total(gradbx*(barycentre-p2[0:2,i]))
    baryb2[i,1] = b2[i,1] + total(gradby*(barycentre-p2[0:2,i]))
    baryb2[i,2] = b2[i,2] + total(gradbz*(barycentre-p2[0:2,i]))

    baryb3[i,0] = b3[i,0] + total(gradbx*(barycentre-p3[0:2,i]))
    baryb3[i,1] = b3[i,1] + total(gradby*(barycentre-p3[0:2,i]))
    baryb3[i,2] = b3[i,2] + total(gradbz*(barycentre-p3[0:2,i]))

    baryb4[i,0] = b4[i,0] + total(gradbx*(barycentre-p4[0:2,i]))
    baryb4[i,1] = b4[i,1] + total(gradby*(barycentre-p4[0:2,i]))
    baryb4[i,2] = b4[i,2] + total(gradbz*(barycentre-p4[0:2,i]))

    ;(these above all agree so this is the magnetic field at the barycentre)

    divb[i,0] = timeb1[i];
    divb[i,1] = divergence;
    divb[i,2] = curlmag[0];
    divb[i,3] = curlmag[1];
    divb[i,4] = curlmag[2];


    ;the cross product of the calculated curl and the sample field times 1e-21 (SI), divided by m0
    ;use the crossp2 IDL routine

    ;curl is in nT/km, nT/km*1e-12 = T/m
    ;field is in nT, nT*1e-9 = T
    ;j is curl B / m0 (curl B = m0*j)
    ;use the magnetic field at the barycentre

    ;compute the current components and total specifically
    jtotal[i,0:2] = 1e-12*divb[i,2:4]/m0;
    jtotal[i,3] = sqrt(jtotal[i,0]*jtotal[i,0]+jtotal[i,1]*jtotal[i,1]+jtotal[i,2]*jtotal[i,2])

    ;compute the parallel and perpendicular components of the current
    ;use total in IDL to do the dot product

    btotal= sqrt(total(baryb[i,0:2]*baryb[i,0:2]))
    ;parallel is J.B/|B|

    jparallel[i] = (total(jtotal[i,0:2]*baryb[i,0:2])/btotal)
    ;perp is J - J// B/|B| (components and total perpendicular current

    jperpvec[i,0:2] = jtotal[i,0:2] - (jparallel[i]*baryb[i,0:2])/btotal

    jperpvec[i,3] = sqrt(jperpvec[i,0]*jperpvec[i,0]+jperpvec[i,1]*jperpvec[i,1]+jperpvec[i,2]*jperpvec[i,2])

    ;alpha parameter
    alphaparallel[i] = abs(jparallel[i])/(1e-9*btotal);
    alpha[i] = abs(jtotal[i,3])/(1e-9*btotal);

  end

  store_data,'baryb'+suffix, data = {x:timeb1,y:baryb}
  store_data,'curlB'+suffix, data = {x:timeb1, y:divb[*,2:4]}
  store_data,'divB'+suffix, data = {x:timeb1, y:divb[*,1]}, dlimits={}, limits={}
  
  store_data,'jtotal'+suffix, data = {x:timeb1, y:jtotal[*,0:2]}

  store_data,'jpar'+suffix, data = {x:timeb1, y:jparallel}

  store_data,'jperp'+suffix, data = {x:timeb1, y:jperpvec[*,0:2]}

  split_vec, 'jperp'+suffix
  store_data, 'jperppar'+suffix, data = ['jpar','jperp_3']

  store_data,'alpha'+suffix, data = {x:timeb1, y:alpha}
  store_data,'alphaparallel'+suffix, data = {x:timeb1, y:alphaparallel}

  
  ;ylim, 'jtotal', [-1.75e-6,1.75e-6],0
  ;ylim, 'divB', [-1.0,1.0],0
  ;ylim, 'curlB', [-1.0,1.0],0
  options, 'curlB'+suffix, 'colors',[2,4,6]
  options, 'curlB'+suffix, 'labels',['delbx','delby','delbz']
  options, 'curlB'+suffix,'labflag',-1
  options, 'jtotal'+suffix, 'colors',[2,4,6]
  options, 'jtotal'+suffix, 'labels',['jx','jy','jz']
  options, 'jtotal'+suffix,'labflag',-1
  options, 'jperp'+suffix, 'colors',[2,4,6]
  options, 'jperp'+suffix, 'labels',['jperpx','jperpy','jperpz']
  options, 'jperp'+suffix,'labflag',-1

end