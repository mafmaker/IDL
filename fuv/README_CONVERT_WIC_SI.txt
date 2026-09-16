From hfrey@ssl.berkeley.edu Mon Mar  4 10:26:18 2002
Date: Fri, 1 Mar 2002 04:06:38 -0800 (PST)
From: Harald Frey <hfrey@ssl.berkeley.edu>
To: Thomas Immel <immel@ssl.berkeley.edu>
Subject: Re: s13-wic mapping

Hi Tom,

this software exists in my ~hfrey/idl/image/fuview/ directory. The files
are

convert_si12_si13_new.pro
convert_wic_si12_new.pro
convert_wic_si13_new.pro

I played with many parameter sets, that's why the call is rather
complicated with

	; create mapping arrays
x_in=findgen(128)#replicate(1.,128)
y_in=replicate(1.,128)#findgen(128)
time_diff=0.
convert_wic_si12_new,x_in,y_in,x_out,y_out,x_out2,y_out2,x_out3,y_out3,$
	x_out4,y_out4,x_out5,y_out5,x_out6,y_out6,x_out7,y_out7,$
	x_out8,y_out8,x_out9,y_out9,x_out10,y_out10,time_diff,$
	/reverse
wic_x=x_out8
wic_y=y_out8
convert_si12_si13_new,x_in,y_in,x_out,y_out,x_out2,y_out2,x_out3,y_out3,$
	x_out4,y_out4,x_out5,y_out5,x_out6,y_out6,x_out7,y_out7,$
	x_out8,y_out8,x_out9,y_out9,x_out10,y_out10,time_diff
s13_x=x_out8
s13_y=y_out8

Here is which x and y-out you have to use

before 2000-171		no reliable mapping available
2000-171 to 2000-262	x_out2 and y_out2
2000-262 to 2000-297	x_out6 and y_out6
after 2000-297		x_out8 and y_out8

If you use wic-si12 then you don't set the /reverse keyword, but if you
convert from si12 to wic, then set /reverse. time_diff is always 0, but
you have to initialize before the call.

I hope this helps.

Harald

=========================================================
Harald U. Frey 
Space Sciences Lab	   phone: 510-643-3323
University of California   fax:   510-643-2624      
Berkeley, CA 94720-7450    email: hfrey@ssl.berkeley.edu


On Thu, 28 Feb 2002, Thomas Immel wrote:

> 
> Hi Harald,
> 
>   Stephen is looking at some pretty discrete features in his sources of
> the aurora paper. For energy calculations, I think it would be best to
> apply the technique that you and Benoit worked up. I guess you use this
> alot with your statistical cusp studies. 
> 
>   Can you point me to the software which will do this mapping of SI images
> into WIC space. And help me understand a little how it handles changes in
> the SI field of view (in regard to TDI) that were made earlier in the
> mission?
> 
> I will install that last day of data you requested right now :)
> 
> Thomas
> 
> ----------------------------------
> ->  Thomas Immel                 |     
> ->  Space Sciences Laboratory    ----------------------------------------
> ->  University of California     |   "What do you despise? By this     <- 
> ->  Berkeley, CA 94720-7450      |     are you truly known."           <- 
> ->  Work : 510-643-3504	         |       from "Manual of Muad'Dib"     <- 
> ->  Fax : 510-643-2624           |        by the Princess Irulan       <- 
> --------------------------------------------------------------------------
> 
> 

