pro refine,arr,flag

; Program to do one or two things to a data array. In particular,
; will reset flagged values to the nearest unflagged value
;
;

arr2=arr
fix=where(arr eq flag,fixct)
good=where(arr ne flag,goodct)

sizer=size(arr)				;thinking 2D for now, only
xgood=good mod sizer(1)
ygood=good / sizer(1)

xfix=fix mod sizer(1)
yfix=fix / sizer(1)

if fixct ne 0 then begin		;start hacking away


  for i=0,fixct-1 do begin		;find shortest distance between
					;pix to fix and good pixel

    dist_arr=(xfix(i)-xgood)^2 + (yfix(i)-ygood)^2

					;this could be greater than one point

    finder=where(dist_arr eq min(dist_arr),foundmin)	
 
    					;load arr 2 with average of close 
					;good values

    arr2(xfix(i),yfix(i))=mean(arr(good(finder)))

  endfor

endif 

arr=arr2

return
end
