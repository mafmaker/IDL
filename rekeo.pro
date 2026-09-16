pro rekeo,keo,time

;
;
;  Author : Thomas Immel
;  Date   : 01-2001
;
;  resize a keogram, with min(keogram) in areas missing data.
;  this is HARDLY general, but should work with more than one gap
;
;
;  It does not adjust the time array, it renames it and uses it, but
;  in the end does not adjust what was passed. Keo DOES get changed.
;
;  It works now in general, for n gaps. 
;

keogram=keo
time_arr=time

;--- find where timegaps of xxx seconds exist
break=where(deriv(time_arr) gt 120,counter)

;--- find where there are no timegaps
nobreak=where(deriv(time_arr) lt 120,top)

;--- at each gap, the derivative will be large twice (abs???)
;--- make two arrays of size= # of gaps

cumulative_dead=intarr(counter/2)
each_dead=intarr(counter/2)

;--- find the running difference between each timestep
diff=time_arr(nobreak(0:top-5)) - time_arr(nobreak(1:top-4))

;--- you better be running at a more or less constant timestep if you are 
;--- calling this code.
timestep=abs(median(diff))

deadtime=0
for i=0,counter/2-1 do begin

;  --- each_dead gets the length of each dead time over xxx seconds
  each_dead(i)=time_arr(break(i*2+1))-time_arr(break(i*2)) 

;  --- cumulative_dead gets the running dead time in the file, to make
  cumulative_dead(i)=time_arr(break(i*2+1))-time_arr(break(i*2)) + deadtime

;  --- deadtime is the total deadtime, to help make the final big_keo array
  deadtime=time_arr(break(i*2+1))-time_arr(break(i*2)) + deadtime
  
endfor

;--- totalspaces is the best guess at how many blank spaces we need in the
;--- new keogram
totaldeadtime=deadtime
totalspaces=deadtime/timestep

;---  ;origs is original size of the keogram
origs=size(keo)
val=min(keo)



;--- this is the new keogram we are going to kick back, which should be
;--- evenly spaced

bigkeo=fltarr(totalspaces + origs(1),origs(2))


;--- do the ends first (this is not very general... :-|)

if counter eq -8.1 then begin		    ;its never going to happen now
  bigkeo(0:break(0),*)=keo(0:break(0),*)    ;a more general treatment follows
  bigkeo(break(counter-1)+totalspaces:*,*)=keo(break(counter-1):*,*)

;  stop
endif else begin				;always go this way

;--- add one last datum to break. BREAK is not going to be used as it
;--- was before, but this is what we need!

  break=[break,origs(1)-1]

;--- now fill in bigkeo where we have data

  for i=0,counter-1 do begin
	print,i
;--- this is the number of array places the portion of deadspace should take

;    spaces=each_dead(i)/timestep
;    newtimes=time_arr(break(i*2)) + timestep*spaces
;    newkeo=fltarr(origs(1) +spaces,origs(2))
;  newkeo(*)=val
;--- actually, the previous lines are all bs. You have the running deadtime
;--- so just skip along and place the new sections where they belong
;--- however, cumulative dead is in seconds, not timesteps. Watch That!

  if break(i+1)-break(i) gt 1 then $
  bigkeo(break(i)+(cumulative_dead(i/2)/timestep):break(i+1)+(cumulative_dead(i/2)/timestep),*)=keo(break(i):break(i+1),*)

  endfor

endelse		;if counter gt 2

keo=bigkeo

return
end