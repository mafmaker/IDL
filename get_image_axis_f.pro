

function sfunct,a,x,m

;f= a(0) + a(1)*sin(x*a(2) + a(3)) * (1 + a(4)*x + a(5)*x^2)

y=a(0) + x*a(1)
f= a(2)*(sin(y) +  0.25 *m* (y - sin(y)*cos(y))*cos(y)) + a(3)

return,f
end


function get_image_axis_f,year,doy,hand=hand

;  Author : T. Immel, UCB
;  Date   : 8-3-2001
;  Purpose : to calculate image axis for summer 2001 period w/o 
;  attitude information from SC
;
;  Fits determined using fit_axis_3.pro in ~/neo/sci/fuv/attitude/
;

  doy=double(doy)	;it is important that this be double precision!
  atheta=dblarr(4)
  aphi=dblarr(4)

;  atheta=[ -0.012815814 , -0.017994743 ,  0.060052354 ,  2.5272048 ,$
;	 -0.00055809373 , 3.0005961e-06]
;  aphi = [-1.3255763,  -0.010987699,  0.048186883  ,5.5898723  ,$
;	  -0.037859808, 9.6197748e-05]

;atheta=[  -6.7718590 , 0.058982999  ,  0.017663433 ,  -0.012768484]
;aphi=[  3.3473948   , -0.041250520 ,    0.018266381   ,   -1.3291482]

aphi =[  3.3633164 ,  -0.040464470 ,  0.016538189 ,  -1.3304333]
atheta=[ -6.7698872  ,0.058969533 ,  0.017662917  ,  -0.012772638]


mtheta=0.09
mphi=1.6

  newtheta=sfunct(atheta,doy,mtheta)
  newphi=sfunct(aphi,doy,mphi)

;  print,newtheta,newphi

  z=sin(newtheta)
  xx= (1-sin(newtheta)^2)/(1.+tan(newphi)^2)
  yy= (1-sin(newtheta)^2)/(1.+ 1./tan(newphi)^2)
  x=sqrt(xx)
  y=sqrt(yy)

  sector=fix((newphi*!radeg + 180)/90.)

  yneg=where(sector eq 1 or sector eq 0,ynegcount)
  xneg=where(sector eq 0 or sector eq 3,xnegcount)
  if ynegcount gt 0 then y(yneg)=y(yneg) * (-1)
  if xnegcount gt 0 then x(xneg)=x(xneg) * (-1)

  axis=[x,y,z]
print,axis

;--- determine the axis by hand

if keyword_set(hand) eq 1 then begin

  get_lun,unit
  openr,unit,'$FUV_HOME/attitude/fixed_axis.txt'
  readf,unit,axis
  print,axis 
  close,unit
  free_lun,unit

endif

return,axis

end