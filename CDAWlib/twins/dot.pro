;  $Source: /usr/lib/cvsroot/twins-idl/lib/lanl/dot.pro,v $
;  $Revision: 1.1 $
;  $Date: 2006/08/11 19:34:54 $

function dot, x, y

;+
;  Purpose:
;	
;  Arguments:
;  Preconditions:
;  Postconditions:
;  Invariants:
;  Example:
;  Notes:
;
;  Author:	Pontus Brandt at APL?
;  Modification $Author: jredfern $
;-
 Compile_Opt StrictArr
 return, total(x*y)
end
