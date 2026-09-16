pro real_epoch_get, c, years, months,  days, hours, minutes, seconds

c = double(c)
years = float(c)
months = fix(c)
days = fix(c)
hours = fix(c)
minutes = fix(c)
seconds = fix(c)

;
;  CURSE RSI for making me write this damn thing
;

for i = 0, n_elements(c)-1 do begin
  cdf_epoch, c(i), a, b, cc, d, e, f, /breakdown
;  print, c(i), a, b, cc, d, e, f
  years(i) = a
  months(i) = b
  days(i) = cc
  hours(i) = d
  minutes(i) = e
  seconds(i) = f
endfor


return
end
