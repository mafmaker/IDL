pro reflect_map
;+
; $Id: reflect_map.pro 7092 2010-01-12 20:18:45Z jimm $
;
; NAME:
;
;  REFLECT_MAP
;
; PURPOSE:
;
;  Reflect the viewer through the plane of a map projection to the
;  opposite side.  This results in reversing the x axis.  This
;  procedure 
;
; CATEGORY:
;
;  Mapping
;
; CALLING SEQUENCE:
;
;  REFLECT_MAP
;
;  Should be called immediately after calling MAP_SET.
; 
; SIDE EFFECTS:
;
;  Changes !x.s.
;
; PROCEDURE:
;
; Map projections of the sphere usually are understood to have the
; viewer of the plane of projection outside the sphere.  Sometimes
; the viewer may be understood to be inside the sphere, i.e., on the
; other side of the plane of projection.  When the veiwer is on the
; other side of the plane, this requires reflecting the plane about
; the y-axis so that +x is to the right rather than to the left.
;
; This procedure should be called only once immediately after setting
; up the map projection using MAP_SET.
;
; EXAMPLE:
;
; The Astrid PIPPI instrument has a natural right-handed spherical
; coordinate system.  Measurements are naturally thought of as
; occuring on the surface of the sphere where each angular position
; corresponds to a different measurement look direction. IDL's map
; projection procedures can be very useful for displaying the
; instrument measurements.  However in this case, the viewer of the
; map projection plane is on the opposite of the viewing plane because
; the viewing is from inside the sphere (i.e. from the point of view
; of the instrument).  Another way of thinking of it is that the
; viewer is reflected through the sphere (r -> 1/r).  For proper
; display with IDL's mapping procedures this requires that the viewing
; plane x axis be reversed so that +x remains to the right hand of the
; viewer.
;
;
; MODIFICATION HISTORY:
;
;       Sat May 27 16:12:29 1995, Chris Chase <chase@retro.jhuapl.edu>
;
;		Created.
;
;-


;; Reflect the data portion of the normalized x axis
!x.s = -(!x.s-[!x.window(1), 0])+[!x.window(0), 0]
return
end
