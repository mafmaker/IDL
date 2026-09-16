PRO PHIROT,news,newd,newz,svec,dvec,zvec,NEWVEC

;Procedure to rotate spherical coordinates about z-axis.

PHI=ATAN(Zvec(1),zvec(0)) & ROTNAX=FLTARR(3,3)

ROTNAX(0:2,0)=[COS(PHI),SIN(PHI),0]
ROTNAX(0:2,1)=[-SIN(PHI),COS(PHI),0]
ROTNAX(0:2,2)=[0,0,1]

NEWS= [Svec(0),Svec(1),Svec(2)] # ROTNAX
newd= [Dvec(0),Dvec(1),Dvec(2)] # ROTNAX
NEWZ= [Zvec(0),Zvec(1),Zvec(2)] # ROTNAX

NEWVEC= [Dvec(0),Dvec(1),Dvec(2)] # ROTNAX

RETURN
end
