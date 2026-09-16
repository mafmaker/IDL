;
;
;  This program contains the simple trig functions, where the
;  passed argument is in degrees (not radians like the default in IDL)
;  TJI

function cosd,angle
  angle2=angle/!radeg
  cosine=cos(angle2)
return,cosine
end

function sind,angle
  angle2=angle/!radeg
  sine=sin(angle2)
return,sine
end

function tand,angle
  angle2=angle/!radeg
  tangent=tan(angle2)
return,tangent
end

function atand,x,y
  angle=atan(x,y)
  angle=angle*!radeg
return, angle
end
