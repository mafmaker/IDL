pro ct_hpbased_p,hp,ct
;
;Given hp, returns ct
;

sizehelp=size(hp)
thing=where(hp ne -1,thingcount)
if sizehelp(0) eq 0 then ct=0 else begin
  ct=hp
  ct(*)=0
endelse

POWER =  [2, 3, 5, 7, 11, 16, 23, 33, 48, 82, 115, 155, 255]
CTPOTEN = [20, 30, 40, 50, 60, 70, 80, 90, 100, 115, 130, 150, 200]

for i=0,thingcount-1 do begin

  diff=abs(power-hp(thing(i)))
  helper=where(diff eq min(diff),counter)

  if sizehelp(0) eq 0 then $
  if counter eq 1 then ct=ctpoten(helper(0)) else ct=ctpoten(helper(1)) $
  else if counter eq 1 then ct(i)=ctpoten(helper(0)) else ct(i)=ctpoten(helper(1))
endfor


return
end