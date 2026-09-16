function column_den_f4,density,altitude,stopper=stopper;,press=press

;  
;  function to test faster calculation of column densities, using 
;  better numerical techniques than the last version (f2). 
;  Integrates entire column that you hand
;  it, so you have to determine the integration limits prior to calling this 
;  routine!
;  Column densities are in #/m^2

;--- whatever this routine is handed, (altitudes must be in km), 
;--- interpolate densities to a 1km grid

;
;  Version 4 of this software does not try to make any conversions
;  between units. This makes it more generic than V3 which is for
;  thermospheric densities only
;
;


minalt=min(altitude)
maxalt=max(altitude)
newalts=findgen(maxalt-minalt) + minalt
indices=indgen(maxalt-minalt)
newden=interpol(density,altitude,newalts)
numalts=size(newalts) & numalts=numalts(1)

;---- do not make adjustments to numbers that are handed over. 
;--- densities start in cm^-3, convert to m^-3 for calculation
;newden=newden   ;*1e6

;--- this still makes sense, though, to count all the vertical elements.
element_size=1000.	;1000 meter tall sections
densities=(newden(0:numalts-2) + newden(1:numalts-1))/2. 
densities=densities * element_size
col=total(densities) 	;per m^2
;col=col/ 1e4		;per cm^2

;--- I do not see any problem with any of the above!

if keyword_set(stopper) gt 0 then stop

return,col
end
