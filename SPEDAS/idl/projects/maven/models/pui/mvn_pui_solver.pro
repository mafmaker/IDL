;20160404 Ali
;solves pickup ion trajectories analytically
;to be called by mvn_pui_model

pro mvn_pui_solver,mamu=mamu,np=np,ntg=ntg

@mvn_pui_commonblock.pro ;common mvn_pui_common

onesnp=replicate(1.,np)

magx=mag[*,0]#onesnp
magy=mag[*,1]#onesnp
magz=mag[*,2]#onesnp
vswx=vsw[*,0]#onesnp
vswy=vsw[*,1]#onesnp
vswz=vsw[*,2]#onesnp
scpx=scp[*,0]#onesnp
scpy=scp[*,1]#onesnp
scpz=scp[*,2]#onesnp
uswn=usw#onesnp

;rotate coordinates so that Usw becomes anti-sunward (align Usw with -X)
bx=-[vswx*magx+vswy*magy+vswz*magz]/uswn
by=-[vswx*magy-vswy*magx+vswz*(vswy*magz-vswz*magy)/(uswn-vswx)]/uswn
bz=-[vswx*magz-vswz*magx-vswy*(vswy*magz-vswz*magy)/(uswn-vswx)]/uswn
Btot=sqrt(bx^2+by^2+bz^2); magnetic field magnitude (T)
tub=acos(-bx/Btot); theta Usw,B (radians) angle between Usw and B (cone angle)
phiub=atan(by,bz); phi Usw,B (radians) solar wind magnetic field clock angle
tez=atan(-bz,by); theta E,z (radians) solar wind electric filed clock angle

sintub=sin(tub)
costub=cos(tub)
sintez=sin(tez)
costez=cos(tez)

q=1.602e-19; %electron charge (C)
mp=1.67e-27; %proton mass (kg)
;mamu=16; %mass of [H=1 C=12 N=14 O=16] (amu)
m=mamu*mp; %pickup ion mass (kg)
fg=q*Btot/m; %gyro-frequency (rad/s)
tg=2.*!pi/fg; %gyro-period (s)
rg=uswn*sintub/fg; %gyro-radius (m)
kemax=.5*m*((2.*usw*sintub)^2)/q; %pickup ion maximum energy (eV)
;ntg=0.999; number of gyro-periods to be simulated
dt=ntg*tg/np; %time increment (s)
t=dt*(replicate(1.,inn)#dindgen(np)); %time (s)

omegat=fg*t ;omega*t (radians)
sinomt=sin(omegat) ;sin(omega*t)
cosomt=cos(omegat) ;cos(omega*t)
rgfg=rg*fg ;r*omega (m/s)
axyz=rg*fg*fg; ;r*omega2 or acceleration (m/s2)

;solving trajectories assuming the electric field E is aligned with +Z
r1x=-rg*sintub*(sinomt-omegat); starting point of pickup ions (m)
r1y=-rg*costub*(sinomt-omegat);
r1z=-rg*(1-cosomt);
v1x=+rgfg*sintub*(cosomt-1); %velocity when reaching MAVEN (m/s)
v1y=+rgfg*costub*(cosomt-1);
v1z=+rgfg*sinomt
a1x=-axyz*sintub*sinomt; %acceleration when reaching MAVEN (m/s2)
a1y=-axyz*costub*sinomt
a1z=+axyz*cosomt

;rotate the coordinates about the x-axis by tez (bring E back to its original direction)
r2x=r1x
r2y=+r1y*costez+r1z*sintez
r2z=-r1y*sintez+r1z*costez
v2x=v1x
v2y=+v1y*costez+v1z*sintez
v2z=-v1y*sintez+v1z*costez

;rotate the coordinates back to vsw (inverse of what was done to B at the beginning)
r3x=scpx-(vswx*r2x-vswy*r2y-vswz*r2z)/uswn
r3y=scpy-(vswx*r2y+vswy*r2x+vswz*(vswy*r2z-vswz*r2y)/(uswn-vswx))/uswn
r3z=scpz-(vswx*r2z+vswz*r2x-vswy*(vswy*r2z-vswz*r2y)/(uswn-vswx))/uswn
v3x=    -(vswx*v2x-vswy*v2y-vswz*v2z)/uswn
v3y=    -(vswx*v2y+vswy*v2x+vswz*(vswy*v2z-vswz*v2y)/(uswn-vswx))/uswn
v3z=    -(vswx*v2z+vswz*v2x-vswy*(vswy*v2z-vswz*v2y)/(uswn-vswx))/uswn

rxyz=sqrt(r3x^2+r3y^2+r3z^2); %radial distance of pickup ions from the center of Mars (m)
vxyz=sqrt(v3x^2+v3y^2+v3z^2); %velocity of pickup ions (m/s)
drxyz=vxyz*dt ;pickup ion distance increment (m)
dvxyz=axyz*dt ;pickup ion velocity increment (m/s)
ke=.5*m/q*(vxyz^2); %kinetic energy of pickup ions at MAVEN (eV)
de=m/q*(v1x*a1x+v1y*a1y+v1z*a1z)*dt ;energy increment (eV)

end