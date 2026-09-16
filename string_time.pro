pro string_time,first,last,numticks,ticks
;
; Program to return evenly spaced ticks in HH:MM format given
; a start and end time in mmmm

diff=last-first
step=(last-first)/float((numticks-1))
ticks=strarr(numticks)
iticks=intarr(numticks)
bla=indgen(numticks)
iticks=round(bla*step) + first

for i=0,numticks-1 do begin
  min_to_string,iticks(i),spare
  ticks(i)=spare
endfor

end
