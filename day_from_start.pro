pro day_from_start,year,day,dayofmission
;  program to return the day from the start of the mission (81266)
;  given the year and day. Leap years not rigorously tested 5-20-96
;
;
addone= 0
  if year gt 84 then addone =addone + 1
  if year gt 88 then addone =addone + 1 

  if year gt 81 then $
  dayofmission= 365*(year-82)+ (365-265) + day  + addone  $
  else dayofmission=day-265

end
;************************************************************************
