pro calc_rho_O_N2_2 , history,rat,basealt,$
                    topalt,OI_col,N2_col,O2_col,altres=altres,$
                    stopper=stopper

;
;  author : Thomas Immel  5-15-03
;
;  program to calculate some nice things for tgcm idl codes,
;  especially the NetCDF writer history_2_netcdf
;
;  Notes : make the lower boundary a variable to test changes thereof  
;          TIMEGCM output is mass mixing ratio, get volume ratio by   
;  	     dividing by mean 'molecular' mass
;;  Revision history
;   0.8  5-15-2003  : I hate how this code is written, so do it again!  
;   0.9  4-27-2004  : Adjusted to read v3 fields that go even higher
;   in altitude. It give smoother but similar results to
;   calc_rho_o_n2.pro WHy am I using that old version on the suns, then???
;
;
;;;--------------------------------------------------------------

print,'calc_rho_O_N2_2	 version 0.9'
;print,keyword_set(garbanzo)    ;-1  or 0 ???
; from Geoff:
;Brasseur and Solomon's book (1996) page 46 has a table of typical pressures
;versus height.  At 30 km, they have 12.0 mb.
;The table below from the TIMEGCM has ~9405 units at about 30 km.
;So what are the units?  Appendix B has a conversion table.
;1000 mb = 1 e6 dyn/cm^2
;So 9mb  = 9 e3  dyn/cm^2
;So the units of pressure in the list below must be dyn/cm^2.
;  Gary Thomas uses N/m^2, and to convert from one to another, we use
;     1 N/m^2  = 10 dyn/cm^2
;     So to convert to N/m^2 all the pressures in the list below have to
;     be divided by 10. 
;
;from TJI  
;  And to convert to torr (mm Hg) from N use
;  1 torr = 1mm Hg = 75.19 N/m^2 SO 
;  10^-5 torr (used for MSIS column densities) = 7.519 * 10^-4
;  which is almost exactly the pressure at -3 in the chart below!~@!@!
;
;------------------------------------------------------------------------
; SWDOT: J,K, Z, pressure=  36,  1, -17.0  9405.948059768649
; SWDOT: J,K, Z, pressure=  36,  2, -16.5  5704.995881914248
; SWDOT: J,K, Z, pressure=  36,  3, -16.0  3460.254915915299
; SWDOT: J,K, Z, pressure=  36,  4, -15.5  2098.750696923991
; SWDOT: J,K, Z, pressure=  36,  5, -15.0  1272.95664477766
; SWDOT: J,K, Z, pressure=  36,  6, -14.5  772.0872335425738
; SWDOT: J,K, Z, pressure=  36,  7, -14.0  468.2945791162783
; SWDOT: J,K, Z, pressure=  36,  8, -13.5  284.0350200112443
; SWDOT: J,K, Z, pressure=  36,  9, -13.0  172.2759480689119
; SWDOT: J,K, Z, pressure=  36,  10, -12.5  104.4906444348558
; SWDOT: J,K, Z, pressure=  36,  11, -12.0  63.37677950287139
; SWDOT: J,K, Z, pressure=  36,  12, -11.5  38.4399598823386
; SWDOT: J,K, Z, pressure=  36,  13, -11.0  23.31501422676195
; SWDOT: J,K, Z, pressure=  36,  14, -10.5  14.14127096016733
; SWDOT: J,K, Z, pressure=  36,  15, -10.0  8.577114404645386
; SWDOT: J,K, Z, pressure=  36,  16, -9.5  5.202282858280284
; SWDOT: J,K, Z, pressure=  36,  17, -9.0  3.155344054044448
; SWDOT: J,K, Z, pressure=  36,  18, -8.5  1.913812910719919
; SWDOT: J,K, Z, pressure=  36,  19, -8.0  1.160786207305506
; SWDOT: J,K, Z, pressure=  36,  20, -7.5  0.7040524241023327
; SWDOT: J,K, Z, pressure=  36,  21, -7.0  0.4270293812630648
; SWDOT: J,K, Z, pressure=  36,  22, -6.5  0.2590064123341644
; SWDOT: J,K, Z, pressure=  36,  23, -6.0  0.1570953301428428
; SWDOT: J,K, Z, pressure=  36,  24, -5.5  9.528313422931233E-2
; SWDOT: J,K, Z, pressure=  36,  25, -5.0  5.779214226359208E-2
; SWDOT: J,K, Z, pressure=  36,  26, -4.5  3.505270617334299E-2
; SWDOT: J,K, Z, pressure=  36,  27, -4.0  2.126054100003071E-2
; SWDOT: J,K, Z, pressure=  36,  28, -3.5  1.289516995859613E-2
; SWDOT: J,K, Z, pressure=  36,  29, -3.0  7.821315942093842E-3
; SWDOT: J,K, Z, pressure=  36,  30, -2.5  4.743867918179101E-3
; SWDOT: J,K, Z, pressure=  36,  31, -2.0  2.877301338002777E-3
; SWDOT: J,K, Z, pressure=  36,  32, -1.5  1.745171478730864E-3
; SWDOT: J,K, Z, pressure=  36,  33, -1.0  1.058500008306297E-3
; SWDOT: J,K, Z, pressure=  36,  34, -0.5  6.420127083438462E-4
; SWDOT: J,K, Z, pressure=  36,  35, -0.0  3.894003915356873E-4
; SWDOT: J,K, Z, pressure=  36,  36, +0.5  2.361832763704968E-4
; SWDOT: J,K, Z, pressure=  36,  37, +1.0  1.432523984300883E-4
; SWDOT: J,K, Z, pressure=  36,  38, +1.5  8.688697172521851E-5
; SWDOT: J,K, Z, pressure=  36,  39, +2.0  5.269961228092975E-5
; SWDOT: J,K, Z, pressure=  36,  40, +2.5  3.196393060335227E-5
; SWDOT: J,K, Z, pressure=  36,  41, +3.0  1.938710391586001E-5
; SWDOT: J,K, Z, pressure=  36,  42, +3.5  1.175887292800397E-5
; SWDOT: J,K, Z, pressure=  36,  43, +4.0  7.132116954499252E-6
; SWDOT: J,K, Z, pressure=  36,  44, +4.5  4.325847601560075E-6



zparam=28                                       ;index of altitude parameter
column_base=28					;base pressure level
zp=findgen(45)/2 -17.
boltz = 1.3807e-23
p_naught=5e-4					;base pressure in mbar
pressure=p_naught*exp(-1*(zp))/10.              ;divide by 10 just as above


sizer=size(history(0).a)

;---exclude minor species to avoid den_N2 < 0!!!

neutral_parameters=[3,4,5,6,7,8,9,10,11,13,14,15,16,17,18,19,20,21,22]

;            O2 O1 N4O NOz CO  CO2 H2O H2 HO CH4 O12D
neutral_amu=[32,16,72 ,30, 26, 42, 18, 2, 17,16, 16,   $
		44,28,48,16,17,33,1,28]			
;               NO2,NO,O3,O1,OH,HO2,H,N2D

major_neutral=[3,4]					;[o2, oi, h]
major_neutral_amu=[32,16]
nsize=size(neutral_parameters)  & nsize=nsize(1)

titlestring=' '

;--- v3 histories from SwRI are all turned around
for i=0,n_elements(history)-1 do titlestring=strcompress(titlestring+history(i).title,/rem)
if titlestring eq 'TNUNVNNETETIO2O1NOPOTENZW' or $
titlestring eq 'TNUNVNNETETIO2O1NOPOTENZWQJ' then begin
  major_neutral=[6,7]
  zparam=10
  column_base=column_base * 2
;--- adjust zp to make a variable number of pressure levels
;  zp=findgen(89)/4. -17. 
  sizer=size(history.a)
  zp=findgen(sizer(3))/4. - 17

  boltz = 1.3807e-23
  p_naught=5e-4					;base pressure in mbar
  pressure=p_naught*exp(-1*(zp))/10.              ;divide by 10 just as above
  nsize=size(major_neutral) & nsize=nsize(1)
endif




n2_amu=28.

;------------------tnd=Total Number Density
tnd=history(0).a & tnd(*)=0
for i=0,sizer(3)-1 do $
    tnd(*,*,i)=pressure(i)/(boltz*reform(history(0).a(*,*,i)))/(100.0^3.)

;--------------N2 mixing ratio--------------
;---Only use Major neutral species to achieve this---


total_mixing_ratio=total(history(major_neutral).a(*,*,*),4)   
n2=1-total_mixing_ratio	
O2=history(major_neutral(0)).a(*,*,*)
OI=history(major_neutral(1)).a(*,*,*)
T=history(0).a(*,*,*)

;----new deal---- from notes by GC on 11-18-99
;---MMM=mean molecular mass 

MMM=1/( (n2/28.)+ (o2/32.) + (oI/16.))

;---using the mean molecular mass and the total number density...
;---do you really want to change the contents of the history?!
;--- that is a bad idea, I think.

for i=0,nsize-1 do history(major_neutral(i)).a= $
	history(major_neutral(i)).a / major_neutral_amu(i) * $
        MMM * tnd > 0

;--------------experiment  - I think it works!!!!!
;--------------new deal from notes by GC  11-18-99

all_n2= n2 /28.*mmm*tnd		;get from num per gram to abundance 
all_OI= reform(history(major_neutral(1)).a)
all_O2= reform(history(major_neutral(0)).a)

;--------------interpolate to a linear grid of altitudes for integration

;--- would like better resolution, but this does not work yet! The
;--- structure you can see in the column densities is the 1 km
;    altitude coming out. Course it is partially cleared up in the ratio...
if keyword_set(altres) gt 0 then alt_res=altres else altres=1.

n2_box = all_n2(*, *, column_base:sizer(3)-2)  ; i don't like the topside  
o2_box = all_o2(*, *, column_base:sizer(3)-2)  ; results sometimes.
oi_box = all_oi(*, *, column_base:sizer(3)-2)  
alt_box = reform(history(zparam).a(*, *, column_base:sizer(3)-2))
topalt = reform(history(zparam).a(*, *, sizer(3)-2))
basealt = reform(history(zparam).a(*, *, column_base))

oi_col = fltarr(sizer(1), sizer(2))
o2_col = oi_col
n2_col = oi_col
;--------------adjust values since the interpol values are BAD outside
;--------------of the original range 
for i=0,sizer(1) - 1 do begin
  for j=0,sizer(2) - 1 do begin
    
    alt_range = (topalt(i, j)-basealt(i, j));/altres
    alt_grid = findgen(alt_range/altres)*altres + basealt(i, j)
    oi_grid = interpol(reform(oi_box(i, j, *)), $
                       reform(alt_box(i, j, *)), alt_grid)
    n2_grid = interpol(reform(n2_box(i, j, *)), $
                       reform(alt_box(i, j, *)), alt_grid)
    o2_grid = interpol(reform(o2_box(i, j, *)), $
                       reform(alt_box(i, j, *)), alt_grid)

    oi_col(i, j)= total(oi_grid) 
    o2_col(i, j)= total(o2_grid)
    n2_col(i, j)= total(n2_grid)

  endfor
endfor



rat = oi_col/n2_col



  if keyword_set(stopper) gt 0 then stop
end
