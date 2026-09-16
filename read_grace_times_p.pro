read_champ_times_p

;
; quick program to read GRACE A,B and CHAMP locations provided by
; Forbes and Sutton.
;

infile='/home/immel/sci/fuv/oct_2003/champ/CHAMP_GRACE_2003_301_304.asc'

;[Column]		[Description]		[units]
; 1				 4-digit year		 (years)
; 2				 Day of the Year	 (days)
; 3				 GPS Second of Day	 (sec)
; 4				 CHAMP Llatitude	 (deg)
; 5				 CHAMP Longitude	 (deg)
; 6				 GraceA Latitude	 (deg)
; 7				 GraceA Longitude	 (deg)
; 8				 GraceB Latitude	 (deg)
; 9				 GraceB Longitude	 (deg)

;structures will be defined as soon as we know how large the data set is:
      ;champ.lat, champ.lon, champ.gpst,champ.year,champ.doy
      ;gracea.lat,gracea.lon,gracea.gpst,gracea.year,gracea.doy
      ;graceb.lat,graceb.lon,graceb.gpst,graceb.year,graceb.doy
