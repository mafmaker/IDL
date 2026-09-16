pro sinefunct, x,a,f,pder
 pder=fltarr(8,2)
 pder(*,0)=sin(x)
 pder(*,1)=1.
 f=a(0)*sin(x) +  a(1)
end
; main
 a=fltarr(2)
 x=fltarr(8)
 y=fltarr(8)
 w=fltarr(8)
 r=fltarr(8)
p=3.14159
 x=[0.,p/4,p/2,p ,5*p/4,3*p/2,7*p/4,2*p]
 y=[.1,.7 ,.95,0.,-.7  ,-.98 ,-.72 ,-.1]
 w(*)=1.
 a(0)=0.95
 a(1)=.2
r=curvefit(x,y,w,a,function_name='sinefunct')
 print,a
end
