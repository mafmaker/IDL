pro min_to_string,a,b

  hrs=a / 60
  mins=a mod 60
  shrs=strcompress(hrs,/rem) &   smins=strcompress(mins,/rem)

  if hrs lt 10 then shrs='0' + shrs
;  if hrs lt 1 then shrs='0' + shrs

  if mins lt 10 then smins='0' + smins
;  if mins lt 1 then smins='0' + smins

  b=shrs + ':' + smins

end
