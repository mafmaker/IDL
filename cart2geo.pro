PRO CART2GEO,LAT,LON,X,Y,Z

;PROGRAM TO CONVERT FROM SPHERICAL COORDINATES TO X,Y,Z COORDINATES
;
; If statement replaced with where to handle arrays (8-2-96) TJI
;


R=(X^2 + Y^2 + Z^2)^0.5

LAT = ASIN(Z/R) * 180.0/!PI
LON= ATAN(Y,X)

;IF Y LT 0.0 THEN LON=LON + 2*!PI

helper=where(y lt 0)
if helper(0) ne -1 then lon(helper)=lon(helper) + 2*!Pi

LON=LON*180.0/!PI

END
