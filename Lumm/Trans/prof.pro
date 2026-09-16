pro prof

display, '../test/m51', altitude, exr_n2
z51=altitude
ex51=fltarr(51)
for i=0,11 do ex51=ex51+exr_n2(*,i)

display, '../test/m71', altitude, exr_n2
z71=altitude
ex71=fltarr(71)
for i=0,11 do ex71=ex71+exr_n2(*,i)

display, '../test/m101', altitude, exr_n2
z101=altitude
ex101=fltarr(101)
for i=0,11 do ex101=ex101+exr_n2(*,i)

display, '../test/m151', altitude, exr_n2
z151=altitude
ex151=fltarr(151)
for i=0,11 do ex151=ex151+exr_n2(*,i)

display, '../test/m201', altitude, exr_n2
z201=altitude
ex201=fltarr(201)
for i=0,11 do ex201=ex201+exr_n2(*,i)

plot, ex51, z51, yrange=[100,150], ysty=1, xtitle='excitation rate (cm!e-3!n)', $
      ytitle='altitude (km)', title='51, 71, 101, 151, 201 points', line=1
oplot, ex71, z71, line=4
oplot, ex101, z101, line=3
oplot, ex151, z151, line=2
oplot, ex201, z201, line=0

zm=150
xm=!x.crange(1)*.75
xm1=!x.crange(1)*.85
oplot, [xm, xm1], [zm-5, zm-5], line=1
xyouts, xm1, zm-5, '  51'
oplot, [xm, xm1], [zm-7.5, zm-7.5], line=4
xyouts, xm1, zm-7.5, '  71'
oplot, [xm, xm1], [zm-10, zm-10], line=3
xyouts, xm1, zm-10, '  101'
oplot, [xm, xm1], [zm-12.5, zm-12.5], line=2
xyouts, xm1, zm-12.5, '  151'
oplot, [xm, xm1], [zm-15, zm-15], line=0
xyouts, xm1, zm-15, '  201'

stop
end
