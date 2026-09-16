#! /usr/local/bin/tcsh -f
echo ' Building image_bckgnd_codes.tar.gz '
echo ' Goes to http://sprg/~immel/image/image_bckgnd/image_bckgnd_codes.tar.gz'
tar -cvf image_bckgnd_codes.tar image_bckgnd_p.pro
tar -uvf image_bckgnd_codes.tar degree_trig.pro
#---get flatfield is now in it's own separate distribution
#tar -uvf image_bckgnd_codes.tar get_flatfield.pro
tar -uvf image_bckgnd_codes.tar get_f107_for_time_p.pro
tar -uvf image_bckgnd_codes.tar correct_f107_p.pro
tar -tvf image_bckgnd_codes.tar > image_bckgnd_codes.txt
gzip image_bckgnd_codes.tar
mv -f image_bckgnd_codes.tar.gz ~/public_html/image/image_bckgnd/
mv -f image_bckgnd_codes.txt  ~/public_html/image/image_bckgnd/
ls -al ~/public_html/image/image_bckgnd/
