;
FUNCTION chk_leap_year,year
;
;    function to check for leap year
;    input:  year
;    output:  returns 1 if leap year, 0 otherwise
;    keywords:  none 
;    library routines:  none
;
return_val = 0

;divisible by 4 and not centurial year
IF((year MOD 4) EQ 0)  AND  ((year MOD 100) NE 0) THEN return_val = 1

;divisible by 400
IF(year MOD 400) EQ 0 THEN return_val = 1

RETURN,return_val

END
