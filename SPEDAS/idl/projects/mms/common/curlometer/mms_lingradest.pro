;+
; PROCEDURE:
;       mms_lingradest
;       
; PURPOSE:
;       Calculations of Grad, Curl, Curv,..., for MMS using
;       the Linear Gradient/Curl Estimator technique
;       see Chanteur, ISSI, 1998, Ch. 11
;
; Based on Cluster routine (A. Runov, 2003) 
;
; Input: Bxyz from four points with the same time resolution
;        and same sampling intervals (joined time series)
;        Coordinates of the four points (R) with the same time
;        resolution and sampling as Bxyz
;        datArrLength := the length of B and R arrays (must be
;        the same for all vectors)
;        
; Output: bxbc, bybc, bzbc: B-field in the barycenter
;         LGBx, LGBy LGBz: B-gradient at the barycenter
;         LCxB, LCvB, LCzB: curl^B at the barycenter
;         curv_x_B, curv_y_B, curv_z_B: B-curvature at the
;         barycenter, RcurvB: the curvature radius
;         
; $LastChangedBy: egrimes $
; $LastChangedDate: 2016-11-29 08:45:38 -0800 (Tue, 29 Nov 2016) $
; $LastChangedRevision: 22411 $
; $URL: svn+ssh://thmsvn@ambrosia.ssl.berkeley.edu/repos/spdsoft/trunk/projects/mms/common/curlometer/mms_lingradest.pro $
;-

pro mms_lingradest, fields=fields, positions=positions
  if undefined(fields) || undefined(positions) then begin
    dprint, dlevel = 0, 'B-field and spacecraft position keywords required.'
    return
  endif
  ;... interpolate the magnetic field data all onto the same timeline (MMS1):
  ;... should be in GSE coordinates
  tinterpol, fields[1], fields[0], newname=fields[1]+'_i'
  tinterpol, fields[2], fields[0], newname=fields[2]+'_i'
  tinterpol, fields[3], fields[0], newname=fields[3]+'_i'
    
  ;... interpolate the definitive ephemeris onto the magnetic field timeseries
  ;... should be in GSE coordinates
  tinterpol, positions[0], fields[0], newname=positions[0]+'_i'
  tinterpol, positions[1], fields[0], newname=positions[1]+'_i'
  tinterpol, positions[2], fields[0], newname=positions[2]+'_i'
  tinterpol, positions[3], fields[0], newname=positions[3]+'_i'
  
  ; ... get data
  get_data, fields[0], data=B1
  datarrLength = n_elements(B1.x)
  Bx1 = B1.y[*,0] & By1 = B1.y[*,1] & Bz1 = B1.y[*,2] & Bt1 = B1.y[*,3]
  get_data, positions[0]+'_i', data=R1
  R1=R1.y
  
  get_data, fields[1]+'_i', data=B2
  Bx2 = B2.y[*,0] & By2 = B2.y[*,1] & Bz2 = B2.y[*,2] & Bt2 = B2.y[*,3]
  get_data, positions[1]+'_i', data=R2
  R2=R2.y
  
  get_data, fields[2]+'_i', data=B3
  Bx3 = B3.y[*,0] & By3 = B3.y[*,1] & Bz3 = B3.y[*,2] & Bt3 = B3.y[*,3]
  get_data, positions[2]+'_i', data=R3
  R3=R3.y
  
  get_data, fields[3]+'_i', data=B4
  Bx4 = B4.y[*,0] & By4 = B4.y[*,1] & Bz4 = B4.y[*,2] & Bt4 = B4.y[*,3]
  get_data, positions[3]+'_i', data=R4
  R4=R4.y
  
  ; ... calculation starts
  
  lingradest,     Bx1, Bx2, Bx3, Bx4,                            $
                  By1, By2, By3, By4,                            $
                  Bz1, Bz2, Bz3, Bz4,                            $
                  R1,  R2,  R3,  R4,                             $
                  datarrLength,                                  $
                  bxbc, bybc, bzbc, bbc,                         $
                  LGBx, LGBy, LGBz,                              $
                  LCxB, LCyB, LCzB, LD,                          $
                  curv_x_B, curv_y_B, curv_z_B, RcurvB
                  
  ; ... calculation ends
   
  ; ... store the results:
  ;                  
  store_data, 'Bt', data={x: B1.x,  y: Bbc[*]}
  store_data, 'Bx', data={x: B1.x,  y: Bxbc[*]}
  options, 'Bx', 'color', 2
  store_data, 'By', data={x: B1.x, y: Bybc[*]}
  options, 'By', 'color', 4
  store_data, 'Bz', data={x: B1.x, y: Bzbc[*]}
  options, 'Bz', 'color', 6
  
  store_data, 'Bbc', data=['Bt','Bx','By','Bz']
  
  ; ... B-field gradients
  store_data, 'gradBx', data={x: B1.x, y: LGBx[*,*]}
  store_data, 'gradBy', data={x: B1.x, y: LGBy[*,*]}
  store_data, 'gradBz', data={x: B1.x, y: LGBz[*,*]}
  
  CB =  sqrt(LCxB[*]^2 + LCyB[*]^2 +  LCzB[*]^2);
  store_data, 'absCB', data={x: B1.x,  y: CB[*]} ; in nT/1000km
  store_data, 'CxB', data={x: B1.x,  y: LCxB[*]} ; in nT/1000km
  options, 'CxB', 'colors', 2
  store_data, 'CyB', data={x: B1.x,  y: LCyB[*]} ; in nT/1000km
  options, 'CyB', 'colors', 4
  store_data, 'CzB', data={x: B1.x,  y: LCzB[*]} ; in nT/1000km
  options, 'CzB', 'colors', 6
  
  store_data, 'divB_nT/1000km', data={x: B1.x,  y: LD[*]} ; divB in nT/1000km
  
  store_data, 'curlB_nT/1000km', data=['absCB', 'CxB','CyB','CzB']
  
  
  store_data, 'jx', data={x: B1.x,  y: 0.8*LCxB[*]} ; jx in nA/m^2
  store_data, 'jy', data={x: B1.x,  y: 0.8*LCyB[*]} ; jy in nA/m^2
  options, 'jy', 'colors', 4
  store_data, 'jz', data={x: B1.x,  y: 0.8*LCzB[*]} ; jz in nA/m^2
  options, 'jz', 'colors', 6
  
  store_data, 'j_nA/m^2', data=['jx', 'jy', 'jz']
  
  store_data, 'curvx', data={x: B1.x,  y: curv_x_B}
  store_data, 'curvy', data={x: B1.x,  y: curv_y_B}
  options, 'curvy', 'colors', 4
  store_data, 'curvz', data={x: B1.x,  y: curv_z_B}
  options, 'curvz', 'colors', 6
  
  store_data, 'curvB', data=['curvx',  'curvy',  'curvz']
  
  store_data, 'Rc_1000km', data={x: B1.x, y: RcurvB}

end
