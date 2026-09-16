Running the CDAWeb Metadata Generator

Script file:  metadbase

This file sets environment variables used by the programs and then submits
several programs to run in "nice" mode.  The first executable file 
called is overlap.  It is hardcoded to read the overlap
file in the /home/cdaweb/metadata directory.  This file is created by
generateDatabases, while is sorts through and finds duplicate files.

Next, the script executes list_CDFS from the /home/cdaweb/bin library.
This step can take up to an hour, and the end result is the CDF_list
file.  A log file, CDF_log, is updated with files that weren't
processed.  The reason for failure is written to the log file.

If list_CDF completes without error, generateDatabases is kicked off.
This program creates the metadata catalogs named
<catalog>_cdfmetafile.txt, creates a new overlap file, and writes to a
log file: metadata_LOG.  The metadata_LOG will contain a listing of
which datasets/time ranges were found/included in each catalog.  The
total number of datasets and the total number of cdf files
processed are recorded at the bottom.

A perl script is initiated next that updates the mirror site to
include new files from a given number of days.  That number is given
as input in the calling sequence.

Finally, IDL procedures are called to update the inventory graphs.


To run interactively:

Any step can be run interactively.  The following environment 
variables need to be set:  
TOP = /home/cdaweb/data  This points to the directory structure 
that holds the cdf files, and is used by list_CDFS.
META = /home/cdaweb/metadata  This points to the directory where you
want the output files to be written to (make sure you have plenty of
space here).
MASTERDIR = /home/cdaweb/data/0MASTERS  This points to the directory that
contains the "master" cdfs.

Any piece can be submitted independently.  For example, if list_CDFS
completes without error, but generateDatabases fails, say because the
master directory was corrupted, generateDatabases could be submitted
independently when the problem was resolved.  In this case, one must
take care to copy the CDF_list file to the users META directory before
submitting generateDatabases.

There is C shell script that will check the source code out, 
compile and install the executables into /home/cdaweb/bin for you...
it is called compile_dbase and is in /home/cdaweb/dev/source (you
should be able to check out a copy by typing cdawget compile_dbase.

If you would prefer to do the steps by hand you may do the following:

To compile and link the C code:

Both list_CDFS.c and generateDatabases.c used the C version of CDFlib
routines.  At this writing, the programs have been compiled to use
version 2.7.

To compile,  at the prompt enter:

% cc -c -I${CDF_INC} source-name.c

To link after a successful compile, at the prompt enter:

% cc -o exe-file object-file.o ${CDF_LIB}/libcdf.so -lm -lc


To link AND run to/with CDFlib version 2.7, the following environment 
variable must be set to include (usually assigned in your .cshrc file):

LD_LIBRARY_PATH= /usr/local/share/cdf27/lib

The reader is referred to the

CDF C Reference Manual, Version 2.7  

for further information.




