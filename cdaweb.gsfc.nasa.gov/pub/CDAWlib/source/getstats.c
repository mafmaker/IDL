/*
** getstats 1.2.1
**
** 4/16/94 Kevin Hughes, kevinh@eit.com
** All suggestions, help, etc. gratefully accepted.
** Get the latest version and documentation info at
**     http://www.eit.com/software/getstats/getstats.html
**     ftp://ftp.eit.com/pub/web.software/getstats/
**
** 3/14/95 GJM Changed "%d" to "%ld" for long int's.
**
** Type "getstats -z" for command-line options.
** Change user defaults below before compiling!
** Compiles fine with gcc. Try "gcc getstats.c -o getstats".
** The version history is at the end of this source.
**
** Thanks to Dan Riley, John Franks, Daniel Simmons, H. Morrow Long,
** Bill Hefley, Mark Donszelmann, Willem van Leeuwen, Tim Evans,
** James Pitkow, Eric Hagberg, Bruce O'Neel, Danny Mayer, Jeffry Abramson,
** and many more for contributing fixes and improvements!
**
** Acknowledgements to Roy Fielding (wwwstat, fielding@simplon.ics.uci.edu)
** and Eric Katz (WebReport, ekatz@ncsa.uiuc.edu) for good ideas.
*/

/** User-defined defaults. Change to your liking! **/

#ifndef SERVERSITE
#define SERVERSITE "http://cdaweb.gsfc.nasa.gov/"
#endif
	/* The URL of your http server. Put a slash at the end!
	*/
#ifndef ROOTDIR
#define ROOTDIR "/usr/Local/etc/httpd/htdocs"
#endif
	/* Overridden by -dr option.
	** The top of your Web/Gopher directory. Comment out this line if
	** you have no existing directory.
	*/
#ifndef HOMEPAGE
#define HOMEPAGE "/cdaweb.html"
#endif
	/* The file to refer to when a request is "/" or empty.
	** Make sure a slash is at the beginning of this string.
	*/
#ifndef LOGFILE
#define LOGFILE "/usr/local/etc/httpd/logs/access_log"
#endif
	/* Overridden by -l option.
	** The httpd log file you want to analyze.
	*/
#ifndef HTMLTITLE
#define HTMLTITLE "CDAWEB Web Server Statistics"
#endif
	/* The default title for getstats HTML pages.
	*/
#ifndef SERVERTYPE
#define SERVERTYPE "NCSA"
#endif
	/* Overridden by -C, -N, -P, -G, -A, and -O options.
	** Default server type and format to use. Currently can be either
	** "CERN", "NCSA", "PLEXUS", "GN", "MAC", or "GOPHER".
	*/
#ifndef COMMON
#define COMMON 0
#endif
	/* Overridden by -M option.
	** If your log file is in the "common" format, define COMMON as
	** 1, else as 0.
	*/
#ifndef CGI
#define CGI
#endif
	/* If you're using getstats as a CGI script, this will tell your
	** browser to expect the output to be HTML.
	*/
#ifndef GMTOFFSET
/* #define GMTOFFSET -28800 */
#endif
	/* Define this to be the difference in seconds between
	** the time as reported in the log file and your local time.
	** For example, if the log GMT time is 5 pm and your local time is
	** 2 pm, enter -10800 for the value. If the difference is 0,
	** or you wish to report all dates as they are in the log file,
	** comment out this line.
	*/
#ifndef LOGTZ
#define LOGTZ "local"
#endif
	/* Define this to be the time zone the log reports in.
	** For instance, "GMT", "local", "PST", etc. This is used only if
	** GMTOFFSET is not defined.
	*/
#ifndef TOPLINES
#define TOPLINES 0
#endif
	/* Overridden by -t option.
	** Define as the number of top lines to report in full, domain,
	** and request reports. Define as 0 to show all lines.
	*/
#ifndef DOMAINFILE
/*#define DOMAINFILE "/usr/local/etc/httpd/cgi-bin/domain.codes.txt"*/
#define DOMAINFILE "/home/rumba/cdaweb/etc/domain.codes.txt"
#endif
	/* Overridden by -df option.
	** The file to lookup domain code descriptions from.
	** Each line should be in the form "xx description..."
	** such as "COM Corporate site". Define as NULL if not needed.
	*/
#ifndef ERRORREPORT
#define ERRORREPORT "YES"
#endif
	/* Overridden by -e option.
	** This will generate a report of malformed requests. Define as
	** "NONE" for no report, "YES" to add a report to standard
	** output, or a file name to append errors to an error log.
	*/
#ifndef CONCISEREPORT
#define CONCISEREPORT "NONE"
#endif
	/* Overridden by -c option.
	** This will generate only a paragraph of statistics.
	** Define as "YES" if you want it or "NONE" if not.
	*/
#ifndef MONTHLYREPORT
#define MONTHLYREPORT "YES"
#endif
	/* Overridden by -m option.
	** This will add a monthly report to getstats output.
	** Define as "YES" if you want it or "NONE" if not.
	*/
#ifndef WEEKLYREPORT
#define WEEKLYREPORT "NONE"
#endif
	/* Overridden by -w option.
	** This will add a weekly report to getstats output.
	** Define as "YES" if you want it or "NONE" if not.
	*/
#ifndef DAILYREPORT
#define DAILYREPORT "NONE"
#endif
	/* Overridden by -d option.
	** This will add a daily report to getstats output.
	** Define as "YES" if you want it or "NONE" if not.
	*/
#ifndef HOURLYREPORT
#define HOURLYREPORT "NONE"
#endif
	/* Overridden by -h option.
	** This will add an hourly report to getstats output.
	** Define as "YES" if you want it or "NONE" if not.
	*/
#ifndef DAYSUMREPORT
#define DAYSUMREPORT "NONE"
#endif
	/* Overridden by -ds option.
	** This will add a daily summary report to getstats output.
	** Define as "YES" if you want it or "NONE" if not.
	*/
#ifndef HOURSUMREPORT
#define HOURSUMREPORT "NONE"
#endif
	/* Overridden by -hs option.
	** This will add an hourly summary report to getstats output.
	** Define as "YES" if you want it or "NONE" if not.
	*/
#ifndef FULLREPORT
#define FULLREPORT "NONE"
#endif
	/* Overridden by -f, -fa, -fd, and -fb options.
	** This will add a full report to getstats output. This can be
	** "FULLADDR" (sorted by address), "FULLACCESS" (sorted by accesses),
	** "FULLDATE" (sorted by access date), or "FULLBYTES" (sorted by
	**  byte traffic per site). Define as "NONE" if you don't want it.
	*/
#ifndef REQUESTREPORT
#define REQUESTREPORT "NONE"
#endif
	/* Overridden by -r, -ra, -rd, -rb, and -rf options.
	** The default request report getstats generates. This can be
	** "REQUEST" (sorted by request), "REQACCESS" (sorted by accesses),
	** "REQDATE" (sorted by date), "REQBYTES" (sorted by byte
	** traffic per request), or "REQFILE" (sorted by individual
	** filesizes). Define as "NONE" if you don't want this report
	** added to your output automatically.
	*/
#ifndef DOMAINREPORT
#define DOMAINREPORT "DOMAIN"
#endif
	/* Overridden by -dn, -da, -dd, and -db options.
	** The default domain report getstats generates. This can be
	** "DOMAIN" (sorted by domain), "DOMACCESS" (sorted by accesses),
	** "DOMDATE" (sorted by date), "DOMBYTES" (sorted by byte
	** traffic per domain), or "DOMUNIQ" (sorted by number of unique
	** domains). Define as "NONE" if you don't want this report added
	** to your output automatically.
	*/
#ifndef TREEREPORT
#define TREEREPORT "YES"
#endif
	/* Overridden by -dt option.
	** If defined as "YES", generates a request report sorted
	** by the directory levels in your web tree. Define as "NONE"
	** to omit it. This report is not shown under VMS.
	*/
#ifndef DOMAINLEVELS
#define DOMAINLEVELS 1
#endif
	/* Overridden by -dl option.
	** The numbers of domain levels getstats analyzes. If this were
	** 2, the domain ".edu" and ".berkeley.edu" would be reported
	** for the address "ocf.berkeley.edu".
	*/
#ifndef PRINTBYTES
#define PRINTBYTES 0
#endif
	/* Overridden by -b option.
	** This will add byte traffic stats to all reports.
	** Define as 0 if not wanted.
	*/
#ifndef PRINTHTML
#define PRINTHTML 0
#endif
	/* Overridden by -ht option.
	** If defined as 1, getstats prints its reports in HTML.
	** Define as 0 if not wanted.
	*/
#ifndef PRINTURLS
/* #define PRINTURLS "pre" */
#endif
	/* If printing HTML request reports, this will make any
	** request entry into a URL, so you can click on it.
	** Specify the style of the report as well, such as "pre".
	** Comment out if not needed.
	*/
#ifndef USEHTMLICON
/* #define USEHTMLICON "getstats.gif" */
#endif
	/* If defined, this image will be shown in HTML report pages.
	** Uncomment if not wanted - the getstats logo is available
	** at the distribution FTP site (see above).
	*/

/* Beginning of string mask options */

/* For each of the following mask options, the following applies:
**
** 1) You can use asterisks in specifying the string, at either
**    ends of the string:
**    "192.100.*", "*100*", "*.com", "*.html", "*cgi-bin*"
** 2) You can make lists of masks:
**    "*eit.com,*.edu", "*.html,*cgi-bin*", ".58.2,*100"
** 3) A mask without asterisks will match EXACTLY:
**    "ocf.berkeley.edu", "/pictures/faces.gif"
** 4) Define as "NONE" if you don't want a default.
*/

#ifndef ADDRMASK
#define ADDRMASK "NONE"
#endif
	/* Overridden by -ss option. (string skip)
	** Name and IP addresses matching conditions in this string
	** WON'T be reported.
	*/
#ifndef ADDRONLYMASK
#define ADDRONLYMASK "NONE"
#endif
	/* Overridden by -sa option. (string address)
	** ONLY name and IP addresses matching conditions in this string
	** WILL be reported.
	*/
#ifndef REQMASK
#define REQMASK "NONE"
#endif
	/* Overridden by -sp option. (string skip)
	** Requests with this string in it WON'T be reported.
	*/
#ifndef REQONLYMASK
#define REQONLYMASK "NONE"
#endif
	/* Overridden by -sr option. (string request)
	** ONLY requests with this string in it WILL be reported.
	*/

/* End of string mask options */

#ifndef DATEMASK
#define DATEMASK "ALLDATES"
#endif
	/* Overridden by -sd option. (string date)
	** ONLY requests matching the date conditions in the string WILL be
	** reported. Define as "ALLDATES" to report all dates. The format
	** must be in "m/d/y", although asterisks can be used as wildcards
	** in each field as well as ranges such as "1/[5-30]/[92-93]".
	** The string can also be specified as "today", "yesterday",
	** "lastweek", "thisweek", "thismonth", or "lastmonth".
	*/
#ifndef HOURMASK
#define HOURMASK "ALLHOURS"
#endif
	/* Overridden by -sh option. (string hour)
	** ONLY requests matching the hour conditions in the string WILL be
	** reported. Define as "ALLHOURS" to report all hours.
	** Examples: "1-23" (1 am to 11 pm), "9" (9 am only),
	** "-17" (midnight to 5 pm), "15-" (3 pm to midnight).
	*/
#ifndef DAYMASK
#define DAYMASK "ALLDAYS"
#endif
	/* Overridden by -sw option.
	** ONLY requests matching the day conditions in the string WILL be
	** reported. Define as "ALLDAYS" to report all days.
	** Examples: "mon", "Mon", or "MON" (Mondays only),
	** "mon-fri" (weekdays only), "wed-sun" (Wednesdays to Sundays only),
	** "mon-" (Mondays to Sundays), "-thu" (Mondays to Thursdays).
	** You can also specify the string as "weekends" or "weekdays".
	*/
#ifndef MONTHMARK
#define MONTHMARK 1000
#endif
	/* Number of files a mark represents in weekly statistics.
	** For larger servers, multiply this by 10.
	*/
#ifndef WEEKMARK
#define WEEKMARK 50
#endif
	/* Number of files a mark represents in weekly statistics.
	** For larger servers, multiply this by 10.
	*/
#ifndef DAYMARK
#define DAYMARK 10
#endif
	/* Number of files a mark represents in daily statistics.
	** For larger servers, multiply this by 10.
	*/
#ifndef HOURMARK
#define HOURMARK 2
#endif
	/* Number of files a mark represents in hourly statistics.
	** For larger servers, multiply this by 10.
	*/
#ifndef MONTHBYTEMARK
#define MONTHBYTEMARK (MONTHMARK * 10000)
#endif
	/* Number of bytes a mark represents in weekly statistics.
	*/
#ifndef WEEKBYTEMARK
#define WEEKBYTEMARK (WEEKMARK * 10000)
#endif
	/* Number of bytes a mark represents in weekly statistics.
	*/
#ifndef DAYBYTEMARK
#define DAYBYTEMARK (DAYMARK * 10000)
#endif
	/* Number of bytes a mark represents in daily statistics.
	*/
#ifndef HOURBYTEMARK
#define HOURBYTEMARK (HOURMARK * 10000)
#endif
	/* Number of bytes a mark represents in hourly statistics.
	*/
#ifndef DAYSUMMARK
#define DAYSUMMARK (DAYMARK * 10)
#endif
	/* Number of files a mark represents in daily summary statistics.
	*/
#ifndef HOURSUMMARK
#define HOURSUMMARK (HOURMARK * 10)
#endif
	/* Number of files a mark represents in hourly summary statistics.
	*/
#ifndef DAYSUMBYTEMARK
#define DAYSUMBYTEMARK (DAYSUMMARK * 10000)
#endif
	/* Number of bytes a mark represents in daily summary statistics.
	*/
#ifndef HOURSUMBYTEMARK
#define HOURSUMBYTEMARK (HOURSUMMARK * 10000)
#endif
	/* Number of bytes a mark represents in hourly summary statistics.
	*/
#ifndef MARK
#define MARK '#'
#endif
	/* What you want the file mark character to be.
	*/
#ifndef BYTEMARK
#define BYTEMARK '+'
#endif
	/* What you want the byte mark character to be.
	*/
#ifndef LOOKUP
#define LOOKUP "NO"
#endif
	/* Overridden by -ip option.
	** Define as "NO" if you want getstats to stop looking up names
	** for numerical addresses. This can save a lot of time!
	** Define as "YES" if you want lookup.
	*/
#ifndef TRUNCATE
#define TRUNCATE 80
#endif
	/* Define as 0 if you want getstats to not truncate to a
	** certain character length in graphs and the request report.
	** Otherwise, define as the length you want (such as 80).
	*/
#ifndef SHOWTREEFILES
/* #define SHOWTREEFILES */
#endif
	/* Defining this will show files as well as directories in
	** directory tree reports. Comment out the line if you only
	** wish to show directories.
	*/
#ifndef SHOWIPDOMAINS
/* #define SHOWIPDOMAINS */
#endif
	/* Defining this will show numerical IP domains in domain
	** reports. Comment out the line if you want to hide IP domains.
	*/
#ifndef EURODATE
/* #define EURODATE */
#endif
	/*
	** Define this if you'd like dates reported as "D/M/Y" and
	** not "M/D/Y". Comment out if you don't.
	*/
#ifndef SHOWSECONDS
/* #define SHOWSECONDS */
#endif
	/* Define this if you want getstats to add access time with
	** hour, minute, and seconds to non-graph reports.
	** Comment out the line if you don't.
	*/
#ifndef GNREPORTALL
/* #define GNREPORTALL */
#endif
	/* Define this if you want your GN server to report Gopher as well
	** as HTML requests. Comment out the line if you don't.
	*/
#ifndef REPORTTAG
#define REPORTTAG "pre" /* GJM */
#endif
	/* The style you want the reports to print out in. Usually
	** "listing" seems to work well, but can be small to read.
	** Try "pre" as well.
	*/

/** End of user-definable options **/

#define PROGNAME  "getstats"
#define VERSION   "1.2"
#define DOCURL    "http://www.eit.com/software/getstats/getstats.html"
#define PLEXURL   "http://www.bsdi.com/server/doc/plexus.html"
#define GNURL     "http://hopf.math.nwu.edu/"
#define NCSAURL   "http://hoohoo.ncsa.uiuc.edu/docs/Overview.html"
#define CERNURL   "http://info.cern.ch/hypertext/WWW/Daemon/User/Guide.html"
#define MACURL    "http://www.uth.tmc.edu/mac_info/machttp_info.html"
#define GOPHURL   "gopher://boombox.micro.umn.edu"

#define MAXLINE        1000
#define HASHLINE       200
#define ADDRLEN        80
#define DATELEN        25
#define MACDATELEN     18
#define COMMONDATELEN  27
#define REQUESTLEN     500
#define DOMAINLEN      80
#define DOMLEN         10
#define DOMLINELEN     80
#define DOMDESCLEN     40
#define SERVERTYPELEN  10
#define REPORTTYPELEN  80
#define DIRLEN         80
#define URLLEN         80
#define MASKLEN        80
#define FLAGLEN        5
#define BREAKLEN       46
#define LONGDATELEN    80
#define SHORTDATELEN   9
#define DATENOTZLEN    19
#define TZLEN          3
#define DATEARGLEN     10
#define DAYSPERWEEK    7
#define DAYSPERYEAR    365
#define WEEKSPERYEAR   52
#define HOURSPERDAY    24
#define SECSPERMIN     60
#define SECSPERHOUR    3600
#define SECSPERDAY     86400
#define SECSPERWEEK    SECSPERDAY * DAYSPERWEEK
#define SECSPERYEAR    SECSPERWEEK * WEEKSPERYEAR
#define CENTURY        1900
#define CENTURYSTR     "1900"
#define BASEYEAR       1970
#define HASHSIZE       101
#define PROGRESSLEN    40
#define IPDOMSTR       "(numerical domains)"
#define NOROOTDIR      "<nodir>"

#ifdef EURODATE
#define DATEFORMAT "D/M/Y"
#else
#define DATEFORMAT "M/D/Y"
#endif

#ifndef ROOTDIR
#define ROOTDIR NOROOTDIR
#endif

#define IS_LEAP(y) (y > 1752 && (y % 4 == 0 && (y % 100 != 0 || y % 400 == 0)))

#ifndef SYSV
#ifdef VMS
	extern noshare int h_errno;
#else
	extern int h_errno;
#endif
#endif

#include <stdio.h>
#include <time.h>
#include <limits.h>

#ifdef VMS
#include <types.h>
#include <stat.h>
#include <socket.h>
#include <in.h>
#ifdef MULTINET
#include "multinet_root:[multinet.include]netdb.h"
#else
#ifdef UCX
#include <netdb.h>
#endif
#endif
#include <ctype.h>
#else
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#endif

struct entry {
	char *address;
	long date;
	int docnum;
	long filesize;
	struct entry *left;
	struct entry *right;
} *list, *sortedlist;

struct requestentry {
	char *request;
	long date;
	int requestnum;
	long requestsize;
	long filesize;
	struct requestentry *left;
	struct requestentry *right;
} *requestlist, *sortedrequestlist, *treereqlist;

struct domainentry {
	char *domain;
	long date;
	int requestnum;
	long filesize;
	int unique;
	struct domainentry *left;
	struct domainentry *right;
} *domainlist, *sorteddomainlist;

struct hosttable {
	char *numaddress;
	char *nameaddress;
	struct hosttable *next;
};

struct sizetable {
	long filesize;
	char *request;
	struct sizetable *next;
};

struct requesttable {
	char *request;
	long date;
	long filesize;
	int requestnum;
	int removed;
	struct requesttable *next;
};

struct domaintable {
	char *domain;
	char *description;
	struct domaintable *next;
};

struct dnametable {
	char *domain;
	struct dnametable *next;
};

struct node {
	char *shortdate;
	int requests;
	int hour;
	int total;
	long filesize;
	struct node *next;
} *monthlyreport, *weeklyreport, *dailyreport, *hourlyreport;

struct errorlist {
	char *error;
	struct errorlist *next;
} *errorreport;

char *months[] = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug",
	"Sep", "Oct", "Nov", "Dec" };
char *days[] = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };
int monthdays[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 30, 30, 31 };

int checkfiles, printhtml, printbytes;
long hoursumstats[48], daysumstats[14];
char *domainfile, full_report[REPORTTYPELEN], request_report[REPORTTYPELEN],
	domain_report[REPORTTYPELEN], server_url[URLLEN], rootdir[DIRLEN];
static int largestdocnum, largestreqnum, largestdomnum, largestudomnum,
	uniquehostnum, uniquedomnum, uniquereqnum, lastweekshosts,
	loglines, toplines, linespermark, largetreereqnum, largetreebytenum;
static long largestmonthnum, largestweeknum, largestdaynum, largesthournum,
	largestbytenum, largestfilesizenum;
static struct hosttable *addrtable[HASHSIZE];
static struct sizetable *reqtable[HASHSIZE];
static struct domaintable *domtable[HASHSIZE];
static struct dnametable *dntable[HASHSIZE];
static struct requesttable *treetable[HASHSIZE];

unsigned hash();
struct entry *addentry();
struct requestentry *addrequestentry();
struct domainentry *adddomainentry();
struct requestentry *addsortrequestentry();
struct node *addnode();
struct errorlist *adderror();
char *getweekdatemask();
int getcommondateaddress();
int getcerndateaddress();
int getncsadateaddress();
int getplexdateaddress();
int getgndateaddress();
int getmacdateaddress();
int getgophdateaddress();
char *lookupnumaddr();
void printgraph();
void printfullheader();
char *hashlookupnumaddr();
char *getlocaltime();
char *getshortdate();
long getyearsecs();
char *getdatestr();
int isokdatechar();
int numstrchr();
long getsize();
long isempty();
long getthetime();
void *emalloc();
void fixslash();
char *strdup();
void usage();
void progerr();
void removespaces();
void makelower();
void parsedatemask();
void parsehourmask();
void parsedaymask();
void setupprogress();
void installdomaintable();
void updateprogress();
int isokhour();
int isokday();
void convtoshortdate();
char *convtoeurodate();
int isokdate();
int isip();
char *headerend();
int isokstring();
int ishtmlrequest();
int isscriptrequest();
void analyzemonthly();
void analyzeweekly();
void analyzedaysum();
void analyzedaily();
void analyzehoursum();
void analyzehourly();
int isinlastweek();
int convtoyearsecs();
void getdomain();
void addtreeentry();
void printerrors();
void printheader();
void printcovers();
void printstats();
void printdates();
void printrunning();
void noactivity();
void printbottomhtml();
void printmonthlyheader();
void printweeklyheader();
void printgraphreport();
void printbreak();
void printdaysumheader();
void printsummary();
void printdailyheader();
void printhoursumheader();
void printhourlyheader();
void sortreport();
int numlen();
void printreport();
void sortrequests();
void printreqheader();
void printrequests();
void sortdomains();
void printdomheader();
void printdomains();
void printtreeheader();
void printtree();
void printerrorheader();
int daydifference();
int getmondaynum();
char *getmonth();
int getweekday();
int getyearday();
void addhashreq();
void addhashdn();
void addhashdom();
int addrcmp();
int isdirectory();
int isinname();
int isnumber();
void parsedaterange();
int getday();
int hashlookupdn();
int isfile();

int main(argc, argv)
     int argc;
     char **argv;
{
	char c, d, *logfile;
	char server_type[SERVERTYPELEN], tree_report[REPORTTYPELEN],
		concise_report[REPORTTYPELEN], monthly_report[REPORTTYPELEN],
		weekly_report[REPORTTYPELEN], daily_report[REPORTTYPELEN],
		hourly_report[REPORTTYPELEN], daysum_report[REPORTTYPELEN],
		hoursum_report[REPORTTYPELEN], error_report[REPORTTYPELEN],
		lookup[FLAGLEN], logline[MAXLINE], request[REQUESTLEN],
		address[ADDRLEN], addrmask[MASKLEN], addronlymask[MASKLEN],
		datemask[MASKLEN], hourmask[MASKLEN], daymask[MASKLEN],
		reqonlymask[MASKLEN], reqmask[MASKLEN],
		date[DATELEN], firstdate[DATELEN], lastdate[DATELEN],
		shortdate[SHORTDATELEN], newshortdate[SHORTDATELEN],
		monthstr[DATEARGLEN], daystr[DATEARGLEN], yearstr[DATEARGLEN];
	int i, use_stdin, docfieldlen, reqfieldlen, domfieldlen, bytefieldlen,
		uniqfieldlen, sizefieldlen, islastweek, islastline,
		isfirstline, domainlevels, highhour, lowhour, lowday, highday,
		errors, allreports, showprogress, common;
	static int htmldocnum, scriptnum, assetnum, lastweeksrequests;
	long starttime, stoptime, nowtime, longdate, filesize, bytecount;
	static struct tm *currenttime;
	FILE *fp, *fperr;
	int (*serverfunction) ();

	filesize = 0;
	use_stdin = showprogress = allreports = bytecount = 0;
	monthstr[0] = daystr[0] = yearstr[0] = '\0';
	monthlyreport = weeklyreport = dailyreport = hourlyreport = NULL;
	list = NULL;
	requestlist = treereqlist = sortedrequestlist = NULL;
	domainlist = sorteddomainlist = NULL;
	common = COMMON;
	domainlevels = DOMAINLEVELS;
	toplines = TOPLINES;
	printhtml = PRINTHTML;
	printbytes = PRINTBYTES;
	strcpy(lookup, LOOKUP);
	strcpy(rootdir, ROOTDIR);
	strcpy(server_type, SERVERTYPE);
	strcpy(concise_report, CONCISEREPORT);
	strcpy(monthly_report, MONTHLYREPORT);
	strcpy(weekly_report, WEEKLYREPORT);
	strcpy(daysum_report, DAYSUMREPORT);
	strcpy(daily_report, DAILYREPORT);
	strcpy(hoursum_report, HOURSUMREPORT);
	strcpy(hourly_report, HOURLYREPORT);
	strcpy(full_report, FULLREPORT);
	strcpy(request_report, REQUESTREPORT);
	strcpy(domain_report, DOMAINREPORT);
	strcpy(tree_report, TREEREPORT);
	strcpy(error_report, ERRORREPORT);
	strcpy(datemask, DATEMASK);
	strcpy(hourmask, HOURMASK);
	strcpy(daymask, DAYMASK);
	strcpy(reqmask, REQMASK);
	strcpy(reqonlymask, REQONLYMASK);
	strcpy(addrmask, ADDRMASK);
	strcpy(addronlymask, ADDRONLYMASK);
	logfile = LOGFILE;
	domainfile = DOMAINFILE;

	while (--argc > 0) {
		++argv;
		if ((*argv)[0] != '-')
			usage();
		c = (*argv)[1];
		d = (*argv)[2];
		if (c == 'a' && strlen(*argv) == 2)
			allreports = 1;
		else if (c == 'f' && strlen(*argv) == 2)
			strcpy(full_report, "FULLADDR");
		else if (c == 'f' && d == 'a')
			strcpy(full_report, "FULLACCESS");
		else if (c == 'f' && d == 'd')
			strcpy(full_report, "FULLDATE");
		else if (c == 'f' && d == 'b') {
			strcpy(full_report, "FULLBYTES");
			printbytes = 1;
		}
		else if (c == 'c' && strlen(*argv) == 2)
			strcpy(concise_report, "YES");
		else if (c == 'm' && strlen(*argv) == 2)
			strcpy(monthly_report, "YES");
		else if (c == 'w' && strlen(*argv) == 2)
			strcpy(weekly_report, "YES");
		else if (c == 'd' && strlen(*argv) == 2)
			strcpy(daily_report, "YES");
		else if (c == 'h' && strlen(*argv) == 2)
			strcpy(hourly_report, "YES");
		else if (c == 'd' && d =='s')
			strcpy(daysum_report, "YES");
		else if (c == 'h' && d == 's')
			strcpy(hoursum_report, "YES");
		else if (c == 'C' && strlen(*argv) == 2)
			strcpy(server_type, "CERN");
		else if (c == 'N' && strlen(*argv) == 2)
			strcpy(server_type, "NCSA");
		else if (c == 'P' && strlen(*argv) == 2)
			strcpy(server_type, "PLEXUS");
		else if (c == 'G' && strlen(*argv) == 2)
			strcpy(server_type, "GN");
		else if (c == 'A' && strlen(*argv) == 2)
			strcpy(server_type, "MAC");
		else if (c == 'O' && strlen(*argv) == 2)
			strcpy(server_type, "GOPHER");
		else if (c == 'M' && strlen(*argv) == 2)
			common = 1;
		else if (c == 'r' && strlen(*argv) == 2)
			strcpy(request_report, "REQUEST");
		else if (c == 'r' && d == 'a')
			strcpy(request_report, "REQACCESS");
		else if (c == 'r' && d == 'd')
			strcpy(request_report, "REQDATE");
		else if (c == 'r' && d == 'b') {
			strcpy(request_report, "REQBYTES");
			printbytes = 1;
		}
		else if (c == 'r' && d == 'f') {
			strcpy(request_report, "REQFILE");
			printbytes = 1;
		}
		else if (c == 'd' && d == 'n')
			strcpy(domain_report, "DOMAIN");
		else if (c == 'd' && d == 'a')
			strcpy(domain_report, "DOMACCESS");
		else if (c == 'd' && d == 'd')
			strcpy(domain_report, "DOMDATE");
		else if (c == 'd' && d == 'b') {
			strcpy(domain_report, "DOMBYTES");
			printbytes = 1;
		}
		else if (c == 'd' && d == 'u')
			strcpy(domain_report, "DOMUNIQ");
		else if (c == 'd' && d == 't')
			strcpy(tree_report, "YES");
		else if (c == 'd' && d == 'l') {
			domainlevels = atoi((++argv)[0]);
			argc--;
		}
		else if (c == 's' && d == 's') {
			strcpy(addrmask, (++argv)[0]);
			argc--;
		}
		else if (c == 's' && d == 'a') {
			strcpy(addronlymask, (++argv)[0]);
			argc--;
		}
		else if (c == 's' && d == 'p') {
			strcpy(reqmask, (++argv)[0]);
			argc--;
		}
		else if (c == 's' && d == 'r') {
			strcpy(reqonlymask, (++argv)[0]);
			argc--;
		}
		else if (c == 's' && d == 'd') {
			strcpy(datemask, (++argv)[0]);
			argc--;
		}
		else if (c == 's' && d == 'h') {
			strcpy(hourmask, (++argv)[0]);
			argc--;
		}
		else if (c == 's' && d == 'w') {
			strcpy(daymask, (++argv)[0]);
			argc--;
		}
		else if (c == 'i' && strlen(*argv) == 2)
			use_stdin = 1;
		else if (c == 'p' && strlen(*argv) == 2)
			showprogress = 1;
		else if (c == 'i' && d == 'p')
			strcpy(lookup, "YES");
		else if (c == 'h' && d == 't')
			printhtml = 1;
		else if (c == 'b' && strlen(*argv) == 2)
			printbytes = 1;
		else if (c == 'e' && strlen(*argv) == 2) {
			if (argc - 2 == -1)
				strcpy(error_report, "YES");
			else if ((*(argv + 1))[0] == '-')
				strcpy(error_report, "YES");
			else {
				strcpy(error_report, (++argv)[0]);
				argc--;
			}
		}
		else if (c == 'd' && d == 'r') {
			if (argc - 2 == -1)
				strcpy(rootdir, NOROOTDIR);
			else if ((*(argv + 1))[0] == '-')
				strcpy(rootdir, NOROOTDIR);
			else {
				strcpy(rootdir, (++argv)[0]);
				argc--;
			}
		}
		else if (c == 'l' && strlen(*argv) == 2) {
			logfile = (++argv)[0];
			argc--;
		}
		else if (c == 'd' && d == 'f') {
			domainfile = (++argv)[0];
			argc--;
		}
		else if (c == 't' && strlen(*argv) == 2) {
			toplines = atoi((++argv)[0]);
			argc--;
		}
		else if (c == 'z' && strlen(*argv) == 2)
			usage();
		else
			usage();
		if (argc == 0)
			break;
	}

	if (use_stdin == 1) {
#ifdef VMS
		progerr("Can't use standard input under VMS.");
#else
		fp = stdin;
#endif
		showprogress = 0;
	}

	else {
#ifdef VMS
	if ((fp = fopen(logfile, "r", "shr=put", "shr=upd")) == NULL)
#else
	if ((fp = fopen(logfile, "r")) == NULL)
#endif
		progerr("Couldn't open the log file.");

	if (isempty(logfile))
		progerr("The log file is empty.");
	/* GJM - do not check if using stdin */
      }

	if (allreports) {
		if (strcmp(monthly_report, "YES"))
			strcpy(monthly_report, "YES");
		if (strcmp(weekly_report, "YES"))
			strcpy(weekly_report, "YES");
		if (strcmp(daysum_report, "YES"))
			strcpy(daysum_report, "YES");
		if (strcmp(daily_report, "YES"))
			strcpy(daily_report, "YES");
		if (strcmp(hoursum_report, "YES"))
			strcpy(hoursum_report, "YES");
		if (strcmp(hourly_report, "YES"))
			strcpy(hourly_report, "YES");
		if (!strcmp(full_report, "NONE") ||
		!strstr(full_report, "FULL"))
			strcpy(full_report, "FULLACCESS");
		if (!strcmp(request_report, "NONE") ||
		!strstr(request_report, "REQ"))
			strcpy(request_report, "REQACCESS");
		if (!strcmp(domain_report, "NONE") ||
		!strstr(domain_report, "DOM"))
			strcpy(domain_report, "DOMACCESS");
		if (strcmp(tree_report, "YES"))
			strcpy(tree_report, "YES");
	}
	fixslash(rootdir);
	if (!isdirectory(rootdir)) {
		checkfiles = 0;
		if (!common)
			printbytes = 0;
	}
	else
		checkfiles = 1;

	nowtime = starttime = getthetime();
	currenttime = localtime((time_t *) &nowtime);
	sprintf(newshortdate, "%02d/%02d/%02d", currenttime->tm_mon + 1,
	currenttime->tm_mday, currenttime->tm_year);

	if (strcmp(addrmask, "NONE"))
		removespaces(addrmask);
	if (strcmp(addronlymask, "NONE"))
		removespaces(addronlymask);
	if (strcmp(reqmask, "NONE"))
		removespaces(reqmask);
	if (strcmp(reqonlymask, "NONE"))
		removespaces(reqonlymask);
	if (strcmp(datemask, "ALLDATES"))
		removespaces(datemask);
	if (strcmp(hourmask, "ALLHOURS"))
		removespaces(hourmask);
	if (strcmp(daymask, "ALLDAYS")) {
		removespaces(daymask);
		makelower(daymask);
	}

	if (strcmp(datemask, "ALLDATES")) {
		if (!strcmp(datemask, "today")) {
			currenttime = localtime((time_t *) &nowtime);
			sprintf(datemask, "%02d/%02d/%02d",
			currenttime->tm_mon + 1, currenttime->tm_mday,
			currenttime->tm_year);
		}
		else if (!strcmp(datemask, "yesterday")) {
			nowtime -= SECSPERDAY;
			currenttime = localtime((time_t *) &nowtime);
			sprintf(datemask, "%02d/%02d/%02d",
			currenttime->tm_mon + 1, currenttime->tm_mday,
			currenttime->tm_year);
		}
		else if (!strcmp(datemask, "thisweek")) {
			currenttime = localtime((time_t *) &nowtime);
			strcpy(datemask, (char *)
			getweekdatemask(currenttime->tm_mon + 1,
			currenttime->tm_mday, currenttime->tm_year));
		}
		else if (!strcmp(datemask, "lastweek")) {
			nowtime -= SECSPERWEEK;
			currenttime = localtime((time_t *) &nowtime);
			strcpy(datemask, (char *)
			getweekdatemask(currenttime->tm_mon + 1,
			currenttime->tm_mday, currenttime->tm_year));
		}
		else if (!strcmp(datemask, "thismonth")) {
			currenttime = localtime((time_t *) &nowtime);
			sprintf(datemask, "%02d/*/%02d",
			currenttime->tm_mon + 1, currenttime->tm_year);
		}
		else if (!strcmp(datemask, "lastmonth")) {
			currenttime = localtime((time_t *) &nowtime);
			sprintf(datemask, "%02d/*/%02d",
			(currenttime->tm_mon + 1 == 1) ? 12 :
			(currenttime->tm_mon + 1), (currenttime->tm_mon + 1
			== 1) ? (currenttime->tm_year - 1) :
			(currenttime->tm_year));
		}
		else if (numstrchr(datemask, '/') != 2)
			progerr("Invalid date string.");
		parsedatemask(datemask, monthstr, daystr, yearstr);
	}

	if (strcmp(hourmask, "ALLHOURS")) {
		parsehourmask(hourmask, &lowhour, &highhour);
		if (lowhour > highhour)
			progerr("Invalid hour string.");
	}
	if (strcmp(daymask, "ALLDAYS")) {
		parsedaymask(daymask, &lowday, &highday);
		if (lowday > highday)
			progerr("Invalid day string.");
	}

	if (domainlevels < 1)
		domainlevels = 1;

	errors = 0;
	islastline = 0;
	isfirstline = 1;

	if (strcmp(error_report, "YES") && strcmp(error_report, "NONE")) {
		if ((fperr = fopen(error_report, "a+")) == NULL)
			progerr("Couldn't write to error log.");
		else
			fprintf(fperr, "%s run on %s local time:\n\n",
			PROGNAME, getlocaltime());
	}
	else
		fperr = NULL;

	if (!strcmp(server_type, "CERN")) {
		serverfunction = getcerndateaddress;
		strcpy(server_url, CERNURL);
	}
	else if (!strcmp(server_type, "NCSA")) {
		serverfunction = getncsadateaddress;
		strcpy(server_url, NCSAURL);
	}
	else if (!strcmp(server_type, "PLEXUS")) {
		serverfunction = getplexdateaddress;
		strcpy(server_url, PLEXURL);
	}
	else if (!strcmp(server_type, "GN")) {
		serverfunction = getgndateaddress;
		strcpy(server_url, GNURL);
	}
	else if (!strcmp(server_type, "MAC")) {
		serverfunction = getmacdateaddress;
		strcpy(server_url, MACURL);
	}
	else if (!strcmp(server_type, "GOPHER")) {
		serverfunction = getgophdateaddress;
		strcpy(server_url, GOPHURL);
	}
	if (common)
		serverfunction = getcommondateaddress;

	if (showprogress) {
		i = 0;
		fprintf(stderr, "%s %s : %s\n", PROGNAME, VERSION,
		getlocaltime());
		setupprogress(logfile);
	}

	if (domainfile != NULL)
		installdomaintable(domainfile);

	while (fgets(logline, MAXLINE, fp) != NULL) {

		if (showprogress)
			updateprogress(i++);

		if ((*serverfunction)(logline, date, address, request,
		&filesize) == 0) {
			errors++;
			errorreport = (struct errorlist *)
			adderror(errorreport, logline);
			continue;
		}

		if (strcmp(hourmask, "ALLHOURS") &&
		!isokhour(date, lowhour, highhour))
			continue;

		if (strcmp(daymask, "ALLDAYS") &&
		!isokday(date, lowday, highday))
			continue;

		convtoshortdate(date, shortdate);
		if (strcmp(datemask, "ALLDATES") &&
		!isokdate(monthstr, daystr, yearstr, shortdate))
			continue;

		if (isip(address)) {
			if (strstr(address, "0.0.0")) {
				errors++;
				errorreport = (struct errorlist *)
				adderror(errorreport, logline);
				continue;
			}
			if (!strcmp(lookup, "YES"))
				strcpy(address, (char *)
				lookupnumaddr(address));
			makelower(address);
		}
		else {
			if (address[0] == ' ' || address[0] == (char) NULL) {
				errors++;
				errorreport = (struct errorlist *)
				adderror(errorreport, logline);
				continue;
			}
			makelower(address);
		}

		if (!isokstring(address, addrmask, 1))
			continue;
		if (!isokstring(address, addronlymask, 0))
			continue;
		if (!isokstring(request, reqmask, 1))
			continue;
		if (!isokstring(request, reqonlymask, 0))
			continue;

		if (ishtmlrequest(request))
			htmldocnum++;
		else if (isscriptrequest(request))
			scriptnum++;
		else
			assetnum++;

		if (printbytes) {
			if (!common)
				filesize = getsize(request);
			bytecount += filesize;
		}

		if (!strcmp(monthly_report, "YES"))
			analyzemonthly(shortdate, filesize, islastline);
		if (!strcmp(weekly_report, "YES"))
			analyzeweekly(shortdate, filesize, islastline);
		if (!strcmp(daysum_report, "YES"))
			analyzedaysum(shortdate, filesize);
		if (!strcmp(daily_report, "YES"))
			analyzedaily(shortdate, filesize, islastline);
		if (!strcmp(hoursum_report, "YES"))
			analyzehoursum(date, filesize);
		if (!strcmp(hourly_report, "YES"))
			analyzehourly(date, filesize, islastline);

		if (isinlastweek(shortdate, newshortdate)) {
			islastweek = 1;
			lastweeksrequests++;
		}
		else
			islastweek = 0;

		longdate = convtoyearsecs(date);

		list = (struct entry *) addentry(list, address, longdate,
		islastweek, filesize);

		if (strcmp(request_report, "NONE"))
			requestlist = (struct requestentry *)
			addrequestentry(requestlist, request, longdate,
			filesize);

		if (strcmp(domain_report, "NONE"))
			getdomain(address, longdate, domainlevels, filesize);

		if (strcmp(tree_report, "NONE")) {
			treereqlist = (struct requestentry *)
			addrequestentry(treereqlist, request, longdate,
			filesize);
			addtreeentry(request, longdate, filesize);
		}

		if (isfirstline) {
			strcpy(firstdate, date);
			isfirstline = 0;
		}
		strcpy(lastdate, date);

	}
	fclose(fp);

	if (strcmp(error_report, "NONE") && !errors)
		errorreport = (struct errorlist *)
		adderror(errorreport, "No malformed requests reported.");

	if (fperr != NULL) {
		printerrors(errorreport, fperr);
		fprintf(fperr, "\n");
		if (!errors)
			fprintf(fperr, "\n");
		fclose(fperr);
	}

	if (showprogress) {
		if (!(loglines % linespermark))
			fprintf(stderr, "*\n");
		else
			fprintf(stderr, "\n");
		fprintf(stderr, "Printing reports...\n");
		fflush(stderr);
	}

	stoptime = getthetime();
	islastline = 1;

	if (!strcmp(monthly_report, "YES"))
		analyzemonthly(shortdate, filesize, islastline);
	if (!strcmp(weekly_report, "YES"))
		analyzeweekly(shortdate, filesize, islastline);
	if (!strcmp(daily_report, "YES"))
		analyzedaily(shortdate, filesize, islastline);
	if (!strcmp(hourly_report, "YES"))
		analyzehourly(date, filesize, islastline);

	if (printhtml) {
#ifdef CGI
		printf("Content-type: text/html\n\n");
#endif
		printf("<head>\n<title>%s</title>\n</head>\n", HTMLTITLE);
		printf("<body><h1>");
#ifdef USEHTMLICON
		printf("<img src=\"%s\" alt=\"[*]\">  ", USEHTMLICON);
#endif
		printf("%s</h1>\n<p>\n<hr>\n", HTMLTITLE);
		printf("<a name=\"general\"><h2>HTTP Server General ");
		printf("Statistics</h2></a><pre>\n");
	}
	else
		printf("HTTP Server General Statistics\n");
	printheader(server_type, common);
	if (htmldocnum || scriptnum || assetnum)
		printcovers(firstdate, lastdate);

	if (printhtml)
		putchar('\n');
	printstats(lastweeksrequests, htmldocnum, scriptnum, assetnum,
	bytecount, errors);
	if (htmldocnum || scriptnum || assetnum)
		printdates(firstdate, lastdate, htmldocnum + scriptnum +
		assetnum + errors, bytecount);
	printrunning(starttime, stoptime);

	if (printhtml) {
		printf("</pre>\n");
		if (strcmp(concise_report, "YES")) {
			printf("<p>\n<blockquote>");
			printf("<b>Go to:</b> ");
			if (!strcmp(monthly_report, "YES")) {
				printf("<a href=\"#monthly\">");
				printf("[Monthly report]</a>\n");
			}
			if (!strcmp(weekly_report, "YES")) {
				printf("<a href=\"#weekly\">");
				printf("[Weekly report]</a>\n");
			}
			if (!strcmp(daysum_report, "YES")) {
				printf("<a href=\"#daysum\">");
				printf("[Daily summary]</a>\n");
			}
			if (!strcmp(daily_report, "YES")) {
				printf("<a href=\"#daily\">");
				printf("[Daily report]</a>\n");
			}
			if (!strcmp(hoursum_report, "YES")) {
				printf("<a href=\"#hoursum\">");
				printf("[Hourly summary]</a>\n");
			}
			if (!strcmp(hourly_report, "YES")) {
				printf("<a href=\"#hourly\">");
				printf("[Hourly report]</a>\n");
			}
			if (strcmp(full_report, "NONE")) {
				printf("<a href=\"#full\">");
				printf("[Full (host) report]</a>\n");
			}
			if (strcmp(request_report, "NONE")) {
				printf("<a href=\"#request\">");
				printf("[Request report]</a>\n");
			}
			if (strcmp(domain_report, "NONE")) {
				printf("<a href=\"#domain\">");
				printf("[Domain report]</a>\n");
			}
			if (strcmp(tree_report, "NONE")) {
				printf("<a href=\"#tree\">");
				printf("[Directory tree report]</a>\n");
			}
			if (!strcmp(error_report, "YES")) {
				printf("<a href=\"#error\">");
				printf("[Error report]</a>\n");
			}
			printf("</blockquote>\n<p>\n");
		}
		printf("<p>\n<hr>\n");
	}

	if (!(htmldocnum + scriptnum + assetnum))
		noactivity();

	if (!strcmp(concise_report, "YES")) {
		if (printhtml)
			printbottomhtml();
#ifdef VMS
		exit(1);
#else
		exit(0);
#endif
	}
	if (!strcmp(monthly_report, "YES")) {
		printmonthlyheader(firstdate, lastdate);
		printgraphreport(monthlyreport, "monthly");
		if (printhtml)
			printf("</%s><hr>\n", REPORTTAG);
		else {
			putchar('\n');
			printbreak();
		}
	}
	if (!strcmp(weekly_report, "YES")) {
		printweeklyheader(firstdate, lastdate);
		printgraphreport(weeklyreport, "weekly");
		if (printhtml)
			printf("</%s><hr>\n", REPORTTAG);
		else {
			putchar('\n');
			printbreak();
		}
	}
	if (!strcmp(daysum_report, "YES")) {
		printdaysumheader(firstdate, lastdate);
		printsummary("daily");
		if (printhtml)
			printf("</%s><hr>\n", REPORTTAG);
		else {
			putchar('\n');
			printbreak();
		}
	}
	if (!strcmp(daily_report, "YES")) {
		printdailyheader(firstdate, lastdate);
		printgraphreport(dailyreport, "daily");
		if (printhtml)
			printf("</%s><hr>\n", REPORTTAG);
		else {
			putchar('\n');
			printbreak();
		}
	}
	if (!strcmp(hoursum_report, "YES")) {
		printhoursumheader(firstdate, lastdate);
		printsummary("hourly");
		if (printhtml)
			printf("</%s><hr>\n", REPORTTAG);
		else {
			putchar('\n');
			printbreak();
		}
	}
	if (!strcmp(hourly_report, "YES")) {
		printhourlyheader(firstdate, lastdate);
		printgraphreport(hourlyreport, "hourly");
		if (printhtml)
			printf("</%s><hr>\n", REPORTTAG);
		else {
			putchar('\n');
			printbreak();
		}
	}
	if (strcmp(full_report, "NONE")) {
		sortreport(list);
		docfieldlen = numlen(largestdocnum) + 1;
		bytefieldlen = numlen(largestbytenum) + 1;
		printfullheader(full_report, firstdate, lastdate);
		printreport(sortedlist, docfieldlen, bytefieldlen);
		if (printhtml)
			printf("</%s><hr>\n", REPORTTAG);
		else {
			putchar('\n');
			printbreak();
		}
	}
	if (strcmp(request_report, "NONE")) {
		largestbytenum = 0;
		sortrequests(requestlist);
		reqfieldlen = numlen(largestreqnum) + 1;
		bytefieldlen = numlen(largestbytenum) + 1;
		sizefieldlen = numlen(largestfilesizenum) + 1;
		printreqheader(request_report, firstdate, lastdate);
		printrequests(sortedrequestlist, reqfieldlen, bytefieldlen,
		sizefieldlen);
		if (printhtml)
#ifdef PRINTURLS
			printf("</%s><hr>\n", PRINTURLS);
#else
			printf("</%s><hr>\n", REPORTTAG);
#endif
		else {
			putchar('\n');
			printbreak();
		}
	}
	if (strcmp(domain_report, "NONE")) {
		largestbytenum = 0;
		sortdomains(domainlist);
		domfieldlen = numlen(largestdomnum) + 1;
		bytefieldlen = numlen(largestbytenum) + 1;
		uniqfieldlen = numlen(largestudomnum) + 1;
		printdomheader(domain_report, domainlevels, firstdate,
		lastdate);
		printdomains(sorteddomainlist, domfieldlen, bytefieldlen,
		uniqfieldlen);
		if (printhtml)
			printf("</%s><hr>\n", REPORTTAG);
		else {
			putchar('\n');
			printbreak();
		}
	}
	if (strcmp(tree_report, "NONE")) {
		strcpy(request_report, "REQUEST");
		sortrequests(treereqlist);
		printtreeheader(firstdate, lastdate);
		reqfieldlen = numlen(largetreereqnum) + 1;
		bytefieldlen = numlen(largetreebytenum) + 1;
		printtree(treereqlist, reqfieldlen, bytefieldlen);
		if (printhtml)
			printf("</%s><hr>\n", REPORTTAG);
		else {
			putchar('\n');
			printbreak();
		}
	}
	if (strcmp(error_report, "NONE") && fperr == NULL) {
		printerrorheader(firstdate, lastdate);
		printerrors(errorreport, stdout);
		if (printhtml)
			printf("</%s><hr>\n", REPORTTAG);
		else {
			putchar('\n');
			if (!errors)
				putchar('\n');
			printbreak();
		}
	}

	if (printhtml)
		printbottomhtml();

#ifdef VMS
	exit(1);
#else
	exit(0);
#endif
}

void printfullheader(report_type, firstdate, lastdate)
     char *report_type;
     char *firstdate;
     char *lastdate;
{
	putchar('\n');
	if (printhtml) {
		printf("<a name=\"full\"><h2>HTTP Server Full Statistics");
		printf("</a> (See <a href=\"#general\">general");
		printf("</a> statistics)</h2><i>\n");
	}
	else
		printf("HTTP Server Full Statistics\n");
	printcovers(firstdate, lastdate);
	if (printhtml)
		printf("<br>");
	printf("Sorted by ");
	if (!strcmp(report_type, "FULLADDR"))
		printf("address.\n");
	else if (!strcmp(report_type, "FULLACCESS"))
		printf("number of requests.\n");
	else if (!strcmp(report_type, "FULLDATE"))
		printf("last access date.\n");
	else if (!strcmp(report_type, "FULLBYTES"))
		printf("byte traffic.\n");
	if (printhtml)
		printf("</i>\n<p>\n");
	if (printhtml)
		printf("<%s>", REPORTTAG);
	putchar('\n');
	printf("# of Requests : Last Access ");
	if (printbytes)
		printf("(%s) : Bytes : Hostname\n", DATEFORMAT);
	else
		printf("(%s) : Hostname\n", DATEFORMAT);
	printbreak();
	putchar('\n');
}

void printmonthlyheader(firstdate, lastdate)
     char *firstdate;
     char *lastdate;
{
	putchar('\n');
	if (printhtml) {
		printf("<a name=\"monthly\"><h2>HTTP Server Monthly ");
		printf("Statistics");
		printf("</a> (See <a href=\"#general\">general");
		printf("</a> statistics)</h2>\n");
	}
	else
		printf("HTTP Server Monthly Statistics\n");
	printcovers(firstdate, lastdate);
	if (printhtml)
		printf("<%s>", REPORTTAG);
	putchar('\n');
	printf("Each mark (%c) represents %d requests.\n", MARK, MONTHMARK);
	if (printbytes)
		printf("Each mark (%c) represents %d bytes.\n", BYTEMARK,
		MONTHBYTEMARK);
	printbreak();
	putchar('\n');
}

void printweeklyheader(firstdate, lastdate)
     char *firstdate;
     char *lastdate;
{
	putchar('\n');
	if (printhtml) {
		printf("<a name=\"weekly\"><h2>HTTP Server Weekly Statistics");
		printf("</a> (See <a href=\"#general\">general");
		printf("</a> statistics)</h2>\n");
	}
	else
		printf("HTTP Server Weekly Statistics\n");
	printcovers(firstdate, lastdate);
	if (printhtml)
		printf("<%s>", REPORTTAG);
	putchar('\n');
	printf("Each mark (%c) represents %d requests.\n", MARK, WEEKMARK);
	if (printbytes)
		printf("Each mark (%c) represents %d bytes.\n", BYTEMARK,
		WEEKBYTEMARK);
	printbreak();
	putchar('\n');
}

void printdaysumheader(firstdate, lastdate)
     char *firstdate;
     char *lastdate;
{
	putchar('\n');
	if (printhtml) {
		printf("<a name=\"daysum\"><h2>HTTP Server Daily Summary");
		printf("</a> (See <a href=\"#general\">general");
		printf("</a> statistics)</h2>\n");
	}
	else
		printf("HTTP Server Daily Summary\n");
	printcovers(firstdate, lastdate);
	if (printhtml)
		printf("<%s>", REPORTTAG);
	putchar('\n');
	printf("Each mark (%c) represents %d requests.\n", MARK, DAYSUMMARK);
	if (printbytes)
		printf("Each mark (%c) represents %d bytes.\n", BYTEMARK,
		DAYSUMBYTEMARK);
	printbreak();
	putchar('\n');
}

void printdailyheader(firstdate, lastdate)
     char *firstdate;
     char *lastdate;
{
	putchar('\n');
	if (printhtml) {
		printf("<a name=\"daily\"><h2>HTTP Server Daily Statistics");
		printf("</a> (See <a href=\"#general\">general");
		printf("</a> statistics)</h2>\n");
	}
	else
		printf("HTTP Server Daily Statistics\n");
	printcovers(firstdate, lastdate);
	if (printhtml)
		printf("<%s>", REPORTTAG);
	putchar('\n');
	printf("Each mark (%c) represents %d requests.\n", MARK, DAYMARK);
	if (printbytes)
		printf("Each mark (%c) represents %d bytes.\n", BYTEMARK,
		DAYBYTEMARK);
	printbreak();
	putchar('\n');
}

void printhoursumheader(firstdate, lastdate)
     char *firstdate;
     char *lastdate;
{
	putchar('\n');
	if (printhtml) {
		printf("<a name=\"hoursum\"><h2>HTTP Server Hourly Summary");
		printf("</a> (See <a href=\"#general\">general");
		printf("</a> statistics)</h2>\n");
	}
	else
		printf("HTTP Server Hourly Summary\n");
	printcovers(firstdate, lastdate);
	if (printhtml)
		printf("<%s>", REPORTTAG);
	putchar('\n');
	printf("Each mark (%c) represents %d requests.\n", MARK, HOURSUMMARK);
	if (printbytes)
		printf("Each mark (%c) represents %d bytes.\n", BYTEMARK,
		HOURSUMBYTEMARK);
	printbreak();
	putchar('\n');
}

void printhourlyheader(firstdate, lastdate)
     char *firstdate;
     char *lastdate;
{
	putchar('\n');
	if (printhtml) {
		printf("<a name=\"hourly\"><h2>HTTP Server Hourly Statistics");
		printf("</a> (See <a href=\"#general\">general");
		printf("</a> statistics)</h2>\n");
	}
	else
		printf("HTTP Server Hourly Statistics\n");
	printcovers(firstdate, lastdate);
	if (printhtml)
		printf("<%s>", REPORTTAG);
	putchar('\n');
	printf("Each mark (%c) represents %d requests.\n", MARK, HOURMARK);
	if (printbytes)
		printf("Each mark (%c) represents %d bytes.\n", BYTEMARK,
		HOURBYTEMARK);
	printbreak();
}

void printreqheader(report_type, firstdate, lastdate)
     char *report_type;
     char *firstdate;
     char *lastdate;
{
	putchar('\n');
	if (printhtml) {
		printf("<a name=\"request\"><h2>HTTP Server Request ");
		printf("Statistics");
		printf("</a> (See <a href=\"#general\">general");
		printf("</a> statistics)</h2><i>\n");
	}
	else
		printf("HTTP Server Request Statistics\n");
	printcovers(firstdate, lastdate);
	if (printhtml)
		printf("<br>");
	printf("Sorted by ");
	if (!strcmp(report_type, "REQUEST"))
		printf("request name,");
	else if (!strcmp(report_type, "REQACCESS"))
		printf("number of requests,");
	else if (!strcmp(report_type, "REQDATE"))
		printf("last access date,");
	else if (!strcmp(report_type, "REQBYTES"))
		printf("byte traffic,");
	else if (!strcmp(report_type, "REQFILE"))
		printf("file size,");
	printf(" %d unique requests.\n", uniquereqnum);
	if (printhtml)
		printf("</i>\n<p>\n");
	if (printhtml)
#ifdef PRINTURLS
		printf("<%s>", PRINTURLS);
#else
		printf("<%s>", REPORTTAG);
#endif
	putchar('\n');
	if (printbytes) {
		printf("# of requests : Last Access (%s) : Bytes/File : ",
		DATEFORMAT);
		printf("Request\n");
	}
	else
		printf("# of requests : Last Access (%s) : Request\n",
		DATEFORMAT);
	printbreak();
	putchar('\n');
}

void printdomheader(report_type, levels, firstdate, lastdate)
     char *report_type;
     int levels;
     char *firstdate;
     char *lastdate;
{
	putchar('\n');
	if (printhtml) {
		printf("<a name=\"domain\"><h2>HTTP Server Domain Statistics");
		printf("</a> (See <a href=\"#general\">general");
		printf("</a> statistics)</h2><i>\n");
	}
	else
		printf("HTTP Server Domain Statistics\n");
	printcovers(firstdate, lastdate);
	if (printhtml)
		printf("<br>");
	printf("%d level%s, sorted by ", levels, (levels == 1) ? "" : "s");
	if (!strcmp(report_type, "DOMAIN"))
		printf("domain name,");
	else if (!strcmp(report_type, "DOMACCESS"))
		printf("number of requests,");
	else if (!strcmp(report_type, "DOMUNIQ"))
		printf("number of unique domains,");
	else if (!strcmp(report_type, "DOMDATE"))
		printf("last access date,");
	else if (!strcmp(report_type, "DOMBYTES"))
		printf("byte traffic,");
	printf(" %d unique domains.\n", uniquedomnum);
	if (printhtml)
		printf("</i>\n<p>\n");
	if (printhtml)
		printf("<%s>", REPORTTAG);
	putchar('\n');
	if (printbytes) {
		printf("# reqs : # uniq : Last Access (%s) : Bytes : ",
		DATEFORMAT);
		printf("Domain\n");
	}
	else
		printf("# reqs : # uniq : Last Access (%s) : Domain\n",
		DATEFORMAT);
	printbreak();
	putchar('\n');
}

void printbreak()
{
	int i = BREAKLEN;

	if (printbytes)
		i += 13;
	while (i--)
		putchar('-');
	putchar('\n');
}

void printtreeheader(firstdate, lastdate)
     char *firstdate;
     char *lastdate;
{
	putchar('\n');
	if (printhtml) {
		printf("<a name=\"tree\"><h2>HTTP Server Tree Report");
		printf("</a> (See <a href=\"#general\">general");
		printf("</a> statistics)</h2>\n");
	}
	else
		printf("HTTP Server Tree Report\n");
	printcovers(firstdate, lastdate);
	if (printhtml)
		printf("<%s>", REPORTTAG);
	putchar('\n');
	printf("# of Requests : Last Access ");
	if (printbytes)
		printf("(%s) : Bytes : Dir/File\n", DATEFORMAT);
	else
		printf("(%s) : Dir/File\n", DATEFORMAT);
	printbreak();
	putchar('\n');
}

void printerrorheader(firstdate, lastdate)
     char *firstdate;
     char *lastdate;
{
	putchar('\n');
	if (printhtml) {
		printf("<a name=\"error\"><h2>HTTP Server Error Report");
		printf(" (All Dates)</a> (See <a href=\"#general\">general");
		printf("</a> statistics)</h2>\n");
	}
	else
		printf("HTTP Server Error Report (All Dates)\n");
	if (printhtml)
		printf("<%s>", REPORTTAG);
	putchar('\n');
	printbreak();
	putchar('\n');
}

void printheader(server_type, iscommon)
     char *server_type;
     int iscommon;
{
	if (printhtml) {
		printf("<b>Server:</b> <a href=\"%s\">%s</a>",
		SERVERSITE, SERVERSITE);
		printf(" (<a href=\"%s\">%s</a>%s)\n", server_url,
		server_type, (iscommon) ? " Common" : "");
		printf("<b>Local date:</b> <i>%s</i>\n", getlocaltime());
	}
	else {
		printf("Server: %s (%s%s)\n", SERVERSITE, server_type,
		(iscommon) ? " Common" : "");
		printf("Local date: %s\n", getlocaltime());
	}
}

void printstats(lastweeksrequests, htmldocnum, scriptnum, assetnum, bytecount, errors)
     int lastweeksrequests;
     int htmldocnum;
     int scriptnum;
     int assetnum;
     long int bytecount;
     int errors;
{
	printf("Requests last 7 days: %d\n", lastweeksrequests);
	printf("New unique hosts last 7 days: %d\n", lastweekshosts);
	printf("Total unique hosts: %d\n", uniquehostnum);
	printf("Number of HTML requests: %d\n", htmldocnum);
	printf("Number of script requests: %d\n", scriptnum);
	printf("Number of non-HTML requests: %d\n", assetnum);
	printf("Number of malformed requests (all dates): %d\n", errors);
	printf("Total number of all requests/errors: %d\n", htmldocnum +
	scriptnum + assetnum + errors);
	if (printbytes)
		printf("Total number of bytes requested: %ld\n", bytecount); /* GJM */
}

void printdates(firstlongdate, lastlongdate, requests, bytecount)
     char *firstlongdate;
     char *lastlongdate;
     int requests;
     long int bytecount;
{
	int firstsecs, lastsecs;
	float hours;

	firstsecs = (int) convtoyearsecs(firstlongdate);
	lastsecs = (int) convtoyearsecs(lastlongdate);
	hours = (float) ((float) (lastsecs - firstsecs) / (float) SECSPERHOUR);
	if (hours) {
		if (hours < 1)
			hours = 1;
		printf("Average requests/hour: %.1f, ",
		(float) requests / (float) hours);
		printf("requests/day: %.1f\n",
		((float) requests / (float) hours) * ((hours < HOURSPERDAY) ?
		hours : HOURSPERDAY));
	}
	if (printbytes && hours) {
		printf("Average bytes/hour: %.0f, ",
		(float) bytecount / (float) hours);
		printf("bytes/day: %.0f\n",
		((float) bytecount / (float) hours) * ((hours < HOURSPERDAY) ?
		hours : HOURSPERDAY));
	}
}

void printrunning(starttime, stoptime)
     long int starttime;
     long int stoptime;
{
	int minutes, seconds;

	minutes = (stoptime - starttime) / SECSPERMIN;
	seconds = (stoptime - starttime) % SECSPERMIN;
	printf("Running time: ");
	if (minutes)
		printf("%d minute%s", minutes, (minutes == 1) ? "" : "s");
	if (minutes && seconds)
		printf(", ");
	if (seconds)
		printf("%d second%s", seconds, (seconds == 1) ? "" : "s");
	if (!minutes && !seconds)
		printf("Less than a second");
	printf(".\n");
}

void printcovers(firstlongdate, lastlongdate)
     char *firstlongdate;
     char *lastlongdate;
{
	char firstdate[SHORTDATELEN], lastdate[SHORTDATELEN];

	convtoshortdate(firstlongdate, firstdate);
	convtoshortdate(lastlongdate, lastdate);
	if (!strcmp(firstdate, lastdate)) {
		if (printhtml)
			printf("<b>");
		printf("This report covers the day of %s.",
		convtoeurodate(firstdate));
		if (printhtml)
			printf("</b>");
		putchar('\n');
	}
	else {
		if (printhtml)
			printf("<b>Covers:</b> <i>");
		else
			printf("Covers: ");
		printf("%s to %s", convtoeurodate(firstdate),
		convtoeurodate(lastdate));
		printf(" (%d days).", daydifference(firstdate, lastdate) + 1);
		if (printhtml)
			printf("</i>");
		putchar('\n');
	}
	if (printhtml)
		printf("<b>");
#ifndef GMTOFFSET
	printf("All dates are in %s time.\n", LOGTZ);
#else
	printf("All dates are in local time.\n");
#endif
	if (printhtml)
		printf("</b>");
}

void analyzemonthly(shortdate, filesize, islastline)
     char *shortdate;
     long int filesize;
     int islastline;
{
	int monthnum;
	static int starting, monthlyrequests, prevmonthnum;
	static long bytecount;

	monthnum = ((shortdate[0] - '0') * 1000) + ((shortdate[1] - '0') * 100)
	+ ((shortdate[6] - '0') * 10) + (shortdate[7] - '0');

	if (!starting) {
		starting = 1;
		monthlyreport = (struct node *) addnode(monthlyreport,
			shortdate, -1, 0, 0, -1, "monthly");
		bytecount += filesize;
		monthlyrequests++;
		prevmonthnum = monthnum;
		return;
	}
	if (monthnum != prevmonthnum) {
		monthlyreport = (struct node *) addnode(monthlyreport, NULL,
			monthlyrequests, 0, 0, bytecount, "monthly");
		if (monthlyrequests > largestmonthnum)
			largestmonthnum = monthlyrequests;
		if (bytecount > largestmonthnum)
			largestmonthnum = bytecount;
		if (islastline)
			return;
		monthlyreport = (struct node *) addnode(monthlyreport,
			shortdate, -1, 0, 0, -1, "monthly");
		monthlyrequests = bytecount = 0;
	}

	if (islastline) {
		monthlyreport = (struct node *) addnode(monthlyreport, NULL,
			monthlyrequests, 0, 0, bytecount, "monthly");
		if (monthlyrequests > largestmonthnum)
			largestmonthnum = monthlyrequests;
		if (bytecount > largestmonthnum)
			largestmonthnum = bytecount;
	}
	else {
		prevmonthnum = monthnum;
		bytecount += filesize;
		monthlyrequests++;
	}
}

void analyzeweekly(shortdate, filesize, islastline)
     char *shortdate;
     long int filesize;
     int islastline;
{
	int mondaynum;
	static int starting, weeklyrequests, prevmondaynum;
	static long bytecount;

	mondaynum = getmondaynum(shortdate);

	if (!starting) {
		starting = 1;
		weeklyreport = (struct node *) addnode(weeklyreport, shortdate,
			-1, 0, 0, -1, "weekly");
		bytecount += filesize;
		weeklyrequests++;
		prevmondaynum = mondaynum;
		return;
	}
	if (mondaynum != prevmondaynum) {
		weeklyreport = (struct node *) addnode(weeklyreport, NULL,
			weeklyrequests, 0, 0, bytecount, "weekly");
		if (weeklyrequests > largestweeknum)
			largestweeknum = weeklyrequests;
		if (bytecount > largestweeknum)
			largestweeknum = bytecount;
		if (islastline)
			return;
		weeklyreport = (struct node *) addnode(weeklyreport, shortdate,
			-1, 0, 0, -1, "weekly");
		weeklyrequests = bytecount = 0;
	}

	if (islastline) {
		weeklyreport = (struct node *) addnode(weeklyreport, NULL,
			weeklyrequests, 0, 0, bytecount, "weekly");
		if (weeklyrequests > largestweeknum)
			largestweeknum = weeklyrequests;
		if (bytecount > largestweeknum)
			largestweeknum = bytecount;
	}
	else {
		prevmondaynum = mondaynum;
		bytecount += filesize;
		weeklyrequests++;
	}
}

void analyzedaysum(shortdate, filesize)
     char *shortdate;
     long int filesize;
{
	int weekday;

	weekday = getweekday(shortdate);
	weekday = (weekday - 1 == -1) ? 6 : weekday - 1;

	daysumstats[weekday] += 1;
	if (printbytes)
		daysumstats[weekday + 7] += filesize;
}

void analyzedaily(shortdate, filesize, islastline)
     char *shortdate;
     long int filesize;
     int islastline;
{
	int yearday;
	static int starting, prevyearday, dailyrequests;
	static long bytecount;

	yearday = getyearday(shortdate);

	if (!starting) {
		starting = 1;
		dailyreport = (struct node *) addnode(dailyreport, shortdate,
			-1, 0, 0, -1, "daily");
		bytecount += filesize;
		dailyrequests++;
		prevyearday = yearday;
		return;
	}
	if (yearday != prevyearday) {
		dailyreport = (struct node *) addnode(dailyreport, NULL,
			dailyrequests, 0, 0, bytecount, "daily");
		if (dailyrequests > largestdaynum)
			largestdaynum = dailyrequests;
		if (bytecount > largestdaynum)
			largestdaynum = bytecount;
		if (islastline)
			return;
		dailyreport = (struct node *) addnode(dailyreport, shortdate,
			-1, 0, 0, -1, "daily");
		dailyrequests = bytecount = 0;
	}

	if (islastline) {
		dailyreport = (struct node *) addnode(dailyreport, NULL,
			dailyrequests, 0, 0, bytecount, "daily");
		if (dailyrequests > largestdaynum)
			largestdaynum = dailyrequests;
		if (bytecount > largestdaynum)
			largestdaynum = bytecount;
	}
	else {
		prevyearday = yearday;
		bytecount += filesize;
		dailyrequests++;
	}
}

void analyzehoursum(date, filesize)
     char *date;
     long int filesize;
{
	int hour;
	char hourstr[3];

	sprintf(hourstr, "%c%c", (date[11] == ' ') ? '0' : date[11], date[12]);
	hour = atoi(hourstr);

	hoursumstats[hour] += 1;
	if (printbytes)
		hoursumstats[hour + 24] += filesize;
}

void analyzehourly(date, filesize, islastline)
     char *date;
     long int filesize;
     int islastline;
{
	char hourstr[3], shortdate[SHORTDATELEN];
	int yearday, hour;
	static int starting, prevhour, prevyearday, dailyrequests,
	hourlyrequests;
	static long bytecount;

	sprintf(hourstr, "%c%c", (date[11] == ' ') ? '0' : date[11], date[12]);
	hour = atoi(hourstr);
	convtoshortdate(date, shortdate);
	yearday = getyearday(shortdate);

	if (!starting) {
		starting = 1;
		hourlyreport = (struct node *) addnode(hourlyreport, shortdate,
			-1, hour, -1, -1, "hourly");
		bytecount += filesize;
		hourlyrequests++;
		dailyrequests++;
		prevhour = hour;
		prevyearday = yearday;
		return;
	}
	if (yearday != prevyearday) {
		hourlyreport = (struct node *)
		addnode(hourlyreport, NULL, hourlyrequests, -1,
		dailyrequests, bytecount, "hourly");
		if (islastline)
			return;
		hourlyreport = (struct node *) addnode(hourlyreport, shortdate,
			-1, hour, -1, -1, "hourly");
		hourlyrequests = bytecount = 0;
		dailyrequests = 0;
	}
	else if (hour != prevhour) {
		hourlyreport = (struct node *) addnode(hourlyreport, NULL,
			hourlyrequests, -1, -1, bytecount, "hourly");
		if (hourlyrequests > largesthournum)
			largesthournum = hourlyrequests;
		if (bytecount > largesthournum)
			largesthournum = bytecount;
		if (islastline)
			return;
		hourlyreport = (struct node *) addnode(hourlyreport, NULL,
			-1, hour, -1, -1, "hourly");
		hourlyrequests = bytecount = 0;
	}

	if (islastline) {
		hourlyreport = (struct node *) addnode(hourlyreport, NULL,
			hourlyrequests, -1, dailyrequests, bytecount, "hourly");
		if (hourlyrequests > largesthournum)
			largesthournum = hourlyrequests;
		if (bytecount > largesthournum)
			largesthournum = bytecount;
	}
	else {
		prevhour = hour;
		prevyearday = yearday;
		bytecount += filesize;
		hourlyrequests++;
		dailyrequests++;
	}
}

void printhour(hour)
     int hour;
{
	if (!hour)
		printf("  midnite: ");
	else if (hour == 12)
		printf("     noon: ");
	else
		printf(" %s%d:00 %s: ", ((hour > 9 && hour < 12) ||
		(hour > 21 && hour <= 23)) ? "" : " ",
		(hour > 12) ? hour - 12 : hour, (hour > 12) ? "pm" : "am");
}

int getcommondateaddress(logline, date, address, request, filesize)
     char *logline;
     char *date;
     char *address;
     char *request;
     long *filesize;
{
	int i, j, status, size;
	char *c, tmpdate[COMMONDATELEN];

	if (!isvalidreq(logline))
		return 0;
	if (strlen(logline) < COMMONDATELEN)
		return 0;
	if ((strchr(logline, '[') == NULL) || (strchr(logline, ']') == NULL))
		return 0;
	if (logline[0] == '-')
		return 0;

	for (i = 0; logline[i] != ' ' && logline[i] != '\t' && i < ADDRLEN; i++)
		address[i] = logline[i];
	address[i] = '\0';

	while (logline[i++] != '[')
		;

	for (j = 0; logline[i] != ']' && j <= COMMONDATELEN; )
		tmpdate[j++] = logline[i++];
	tmpdate[j] = '\0';

	date[0] = 'x';
	date[1] = 'x';
	date[2] = 'x';
	date[3] = ' ';
	date[4] = tmpdate[3];
	date[5] = tmpdate[4];
	date[6] = tmpdate[5];
	date[7] = ' ';
	date[8] = tmpdate[0];
	date[9] = tmpdate[1];
	date[10] = ' ';
	date[11] = tmpdate[12];
	date[12] = tmpdate[13];
	date[13] = ':';
	date[14] = tmpdate[15];
	date[15] = tmpdate[16];
	date[16] = ':';
	date[17] = tmpdate[18];
	date[18] = tmpdate[19];
	date[19] = ' ';
	date[20] = tmpdate[7];
	date[21] = tmpdate[8];
	date[22] = tmpdate[9];
	date[23] = tmpdate[10];
	date[24] = '\0';

#ifdef GMTOFFSET
	strcpy(date, getdatestr(convtoyearsecs(date) + GMTOFFSET, 1));
#endif

	c = (char *) headerend(logline);
	if (isspace(*c))
		c++;
	for (i = 0; *c && !isspace(*c) && *c != '?' && *c != '"'; c++)
		request[i++] = *c;
	request[i] = '\0';
	if (!i || !strcmp(request, "/"))
		strcpy(request, HOMEPAGE);

	c = (char *) strrchr(logline, '"') + 2;
	if (*c != '-') {
		status = 0;
		while (isdigit(*c)) {
			status = (status * 10) + (*c - '0');
			c++;
		}
		if (status < 200 || status > 299)
			return 0;
		c++;
	}
	else
		c += 2;

	size = 0;
	if (*c != '-') {
		while (isdigit(*c)) {
			size = (size * 10) + (*c - '0');
			c++;
		}
	}
	*filesize = (long) size;

	return 1;
}

int getcerndateaddress(logline, date, address, request)
     char *logline;
     char *date;
     char *address;
     char *request;
{
	int i, j;
	char *c;

	if (!isvalidreq(logline))
		return 0;
	if (strlen(logline) < DATELEN)
		return 0;
	if (!isupper(logline[0]) || logline[DATELEN - 1] != ' ')
		return 0;

	for (i = 0; i < DATELEN - 1; i++)
		date[i] = logline[i];
	date[i++] = '\0';

#ifdef GMTOFFSET
	strcpy(date, getdatestr(convtoyearsecs(date) + GMTOFFSET, 1));
#endif

	for (j = 0; logline[i] == '.' || isdigit(logline[i]); i++)
		address[j++] = logline[i];
	address[j] = '\0';

	c = (char *) headerend(logline);
	if (isspace(*c))
		c++;
	for (i = 0; *c && !isspace(*c) && *c != '?'; c++)
		request[i++] = *c;
	request[i] = '\0';
	if (!i || !strcmp(request, "/"))
		strcpy(request, HOMEPAGE);

	return 1;
}

int getncsadateaddress(logline, date, address, request)
     char *logline;
     char *date;
     char *address;
     char *request;
{
	int i, j;
	char *c;

	if (!isvalidreq(logline))
		return 0;
	if ((strchr(logline, '[') == NULL) || (strchr(logline, ']') == NULL))
		return 0;
	if (strlen(logline) < DATELEN)
		return 0;

	for (i = 0; logline[i] != '[' && logline[i] != ' ' &&
	logline[i] != '\t' && i < ADDRLEN; i++)
		address[i] = logline[i];
	address[i] = '\0';

	while (logline[i++] != '[')
		;

	for (j = 0; logline[i] != ']' && j <= DATELEN; )
		date[j++] = logline[i++];
	date[j] = '\0';

#ifdef GMTOFFSET
	strcpy(date, getdatestr(convtoyearsecs(date) + GMTOFFSET, 1));
#endif

	c = (char *) headerend(logline);
	if (isspace(*c))
		c++;
	for (i = 0; *c && !isspace(*c) && *c != '?'; c++)
		request[i++] = *c;
	request[i] = '\0';
	if (!i || !strcmp(request, "/"))
		strcpy(request, HOMEPAGE);

	return 1;
}

int getplexdateaddress(logline, date, address, request)
     char *logline;
     char *date;
     char *address;
     char *request;
{
	int i, j;
	char *c;

	if (!isvalidreq(logline))
		return 0;
	if (logline[0] == '-')
		return 0;
	if (strlen(logline) < DATELEN)
		return 0;

	for (i = 0; logline[i] != ' ' && i < ADDRLEN; i++)
		address[i] = logline[i];
	address[i] = '\0';

	while (logline[i] == ' ')
		i++;
	for (j = 0; j < DATENOTZLEN; )
		date[j++] = logline[i++];
	i += TZLEN;
	for (i++; j < DATELEN - 1; )
		date[j++] = logline[i++];
	date[j] = '\0';

#ifdef GMTOFFSET
	strcpy(date, getdatestr(convtoyearsecs(date) + GMTOFFSET, 1));
#endif

	c = (char *) headerend(logline);
	if (isspace(*c))
		c++;
	for (i = 0; *c && !isspace(*c) && *c != '?'; c++)
		request[i++] = *c;
	request[i] = '\0';
	if (!i || !strcmp(request, "/"))
		strcpy(request, HOMEPAGE);

	return 1;
}

int getgndateaddress(logline, date, address, request)
     char *logline;
     char *date;
     char *address;
     char *request;
{
	int i, j;
	char *c;

#ifdef GNREPORTALL
	if (strstr(logline, "Sent") == NULL && !isvalidreq(logline))
#else
	if (!isvalidreq(logline))
#endif
		return 0;
	if ((strchr(logline, '(') == NULL) || (strchr(logline, ')') == NULL))
		return 0;
	if (strlen(logline) < DATELEN)
		return 0;

	for (i = 0; logline[i] != ':' && i < ADDRLEN; i++)
		address[i] = logline[i];
	address[i] = '\0';

	i = strlen(logline) - 9;
	if (logline[i] == ':' && logline[i - 3] == ':')
		c = (char *) &logline[0] + strlen(logline) - DATELEN;
	else
		c = (char *) strchr(logline, ':') + 2;
	for (j = 0; j <= DATELEN; c++)
		date[j++] = *c;
	date[j] = '\0';

#ifdef GMTOFFSET
	strcpy(date, getdatestr(convtoyearsecs(date) + GMTOFFSET, 1));
#endif

	c = (char *) headerend(logline);
#ifdef GNREPORTALL
	if (c == NULL) {
		c = (char *) strchr(logline, '(') + 1;
		if (c == NULL)
			return 0;
	}
#else
	if (c == NULL)
		return 0;
#endif
	if (isspace(*c))
		c++;
	for (i = 0; *c && *c != ')' && *c != '?' && !isspace(*c); c++)
		request[i++] = *c;
	request[i] = '\0';

	if (!i || !strcmp(request, "/"))
		strcpy(request, HOMEPAGE);

	return 1;
}

int getmacdateaddress(logline, date, address, request)
     char *logline;
     char *date;
     char *address;
     char *request;
{
	int i, j, monthnum;
	char *c, tmpdate[DATELEN];

	if (!strstr(logline, "OK"))
		return 0;
	if ((strchr(logline, ':') == NULL) || !isdigit(logline[0]))
		return 0;
	if (strlen(logline) < MACDATELEN)
		return 0;

	for (i = j = 0; logline[i] && !isspace(logline[i]); i++)
		tmpdate[j++] = logline[i];
	tmpdate[j++] = ' ';
	while (isspace(logline[i]))
		i++;
	for (; logline[i] && !isspace(logline[i]); i++)
		tmpdate[j++] = logline[i];
	tmpdate[j] = '\0';
	monthnum = ((tmpdate[0] - '0') * 10) + (tmpdate[1] - '0');

	date[0] = 'x';
	date[1] = 'x';
	date[2] = 'x';
	date[3] = ' ';
	date[4] = months[monthnum - 1][0];
	date[5] = months[monthnum - 1][1];
	date[6] = months[monthnum - 1][2];
	date[7] = ' ';
	date[8] = tmpdate[3];
	date[9] = tmpdate[4];
	date[10] = ' ';
	date[11] = tmpdate[9];
	date[12] = tmpdate[10];
	date[13] = ':';
	date[14] = tmpdate[12];
	date[15] = tmpdate[13];
	date[16] = ':';
	date[17] = tmpdate[15];
	date[18] = tmpdate[16];
	date[19] = ' ';
	date[20] = CENTURYSTR[0];
	date[21] = CENTURYSTR[1];
	date[22] = tmpdate[6];
	date[23] = tmpdate[7];
	date[24] = '\0';

#ifdef GMTOFFSET
	strcpy(date, getdatestr(convtoyearsecs(date) + GMTOFFSET, 1));
#endif

	while (isspace(logline[i]))
		i++;
	while (!isspace(logline[i]))
		i++;
	while (isspace(logline[i]))
		i++;

	for (j = 0; logline[i] && logline[i] != '\n' &&
	!isspace(logline[i]); i++)
		address[j++] = logline[i];
	address[--j] = '\0';

	while (logline[i] == '.' || isspace(logline[i]))
		i++;

	for (j = 0; logline[i] && logline[i] != '\n'; i++)
		request[j++] = ((logline[i] == ':') ? '/' : logline[i]);
	request[j] = '\0';

	if (!i || !strcmp(request, "/"))
		strcpy(request, HOMEPAGE);

	return 1;
}

int getgophdateaddress(logline, date, address, request)
     char *logline;
     char *date;
     char *address;
     char *request;
{
	int i, j;
	char *c, *d;

	if (strchr(logline, ':') == NULL)
		return 0;
	if (strlen(logline) < DATELEN)
		return 0;
	if (!isupper(logline[0]) || logline[DATELEN - 1] != ' ')
		return 0;

	for (i = 0; i < DATELEN - 1; i++)
		date[i] = logline[i];
	date[i++] = '\0';

#ifdef GMTOFFSET
	strcpy(date, getdatestr(convtoyearsecs(date) + GMTOFFSET, 1));
#endif

	while (!isspace(logline[i++]))
		;
	for (j = 0; logline[i] && logline[i] != ' '; i++)
		address[j++] = logline[i];
	address[j] = '\0';

	if (strstr(logline, "search ")) {
		c = (char *) strstr(logline, "search ") + 7;
		d = (char *) strstr(logline, " for");
	}
	else if (strstr(logline, "range ")) {
		c = (char *) strstr(logline, "of file ") + 8;
		d = c + strlen(logline);
	}
	else if (strstr(logline, "retrieved")) {
		c = (char *) strchr(logline, '/');
		d = c + strlen(logline);
	}
	else if (strstr(logline, "Root Connection")) {
		c = (char *) strstr(logline, "Root Connection");
		d = c + strlen(logline);
	}
	else
		return 0;

	if (c == NULL)
		return 0;
	for (i = 0; *c && c != d; c++)
		request[i++] = *c;
	request[i] = '\0';

	if (request[strlen(request) - 1] == '\n')
		request[strlen(request) - 1] = '\0';

	return 1;
}

void getdomain(address, date, level, filesize)
     char *address;
     long int date;
     int level;
     long int filesize;
{
	int i, maxlevel;
	char *s, *t, domain[DOMAINLEN], tempdomain[DOMAINLEN];

#ifndef SHOWIPDOMAINS
	if (isip(address)) {
		addhashdn(address);
		address = IPDOMSTR;
		adddomainentry(domainlist, address, date, filesize);
		return;
	}
#endif

	if (!strchr(address, '.')) {
		domainlist = (struct domainentry *)
		adddomainentry(domainlist, address, date, filesize);
		addhashdn(address);
		return;
	}

	domain[0] = '\0';
	maxlevel = numstrchr(address, '.') + 1;
	while (1) {
		t = (char *) strdup(address);
		if (!maxlevel)
			break;
		for (i = 0; i < maxlevel; i++)
			s = (char *) strtok((i) ? NULL : t, ".");
		if (s == NULL)
			break;
		sprintf(tempdomain, "%s.%s", domain, s);
		strcpy(domain, tempdomain);

		if (level-- > 0)
			domainlist = (struct domainentry *)
			adddomainentry(domainlist, domain, date, filesize);

		maxlevel--;
		free(t);
	}
	addhashdn(domain);
}

char *getweekdatemask(month, day, year)
     int month;
     int day;
     int year;
{
	static char datemask[MASKLEN], shortdate[SHORTDATELEN],
		monshortdate[SHORTDATELEN], sunshortdate[SHORTDATELEN];
	int monmonth, monday, monyear, sunmonth, sunday, sunyear;

	sprintf(shortdate, "%02d/%02d/%02d", month, day, year);

	strcpy(monshortdate, getshortdate(shortdate, 1));
	strcpy(sunshortdate, getshortdate(shortdate, 0));
	sscanf(monshortdate, "%d/%d/%d", &monmonth, &monday, &monyear);
	sscanf(sunshortdate, "%d/%d/%d", &sunmonth, &sunday, &sunyear);

	sprintf(datemask, "[%d-%d]/[%d-%d]/[%d-%d]", monmonth, (sunmonth >
	monmonth) ? sunmonth : monmonth, monday, (sunday > monday) ? sunday :
	monday, monyear, (sunyear > monyear) ? sunyear : monyear);

	return datemask;
}

void convtoshortdate(date, shortdate)
     char *date;
     char *shortdate;
{
	int i, month;

	for (i = 0; strstr(date, months[i]) == NULL; i++)
		;
	month = i + 1;
	sprintf(shortdate, "%02d/%c%c/%c%c", month, (date[8] == ' ') ?
	'0' : date[8], date[9], date[22], date[23]);
}

char *convtoeurodate(shortdate)
     char *shortdate;
{
#ifndef EURODATE
	return shortdate;
#else
	static char tmpdate[SHORTDATELEN];

	strcpy(tmpdate, shortdate);
	tmpdate[0] = shortdate[3];
	tmpdate[1] = shortdate[4];
	tmpdate[3] = shortdate[0];
	tmpdate[4] = shortdate[1];

	return tmpdate;
#endif
}

int convtoyearsecs(date)
     char *date;
{
	char hourstr[3], minstr[3], secstr[3], shortdate[SHORTDATELEN];
	int hours, minutes, seconds;
	long yearsecs;

	convtoshortdate(date, shortdate);
	yearsecs = getyearsecs(shortdate);

	sprintf(hourstr, "%c%c", date[11], date[12]);
	sprintf(minstr, "%c%c", date[14], date[15]);
	sprintf(secstr, "%c%c", date[17], date[18]);

	hours = atoi(hourstr);
	minutes = atoi(minstr);
	seconds = atoi(secstr);

	return (int) (yearsecs + (hours * SECSPERHOUR) +
	(minutes * SECSPERMIN) + seconds);
}

unsigned hash(s)
     char *s;
{
	unsigned hashval;

	for (hashval = 0; *s != '\0'; s++)
		hashval = *s + 31 * hashval;
	return hashval % HASHSIZE;
}

void addhash(nameaddress, numaddress)
     char *nameaddress;
     char *numaddress;
{
	struct hosttable *hp;
	unsigned hashval;

	hp = (struct hosttable *) emalloc(sizeof(*hp));
	hp->numaddress = strdup(numaddress);
	hashval = hash(numaddress);
	hp->next = addrtable[hashval];
	addrtable[hashval] = hp;
	hp->nameaddress = strdup(nameaddress);
}

char *hashlookupnumaddr(numaddress)
     char *numaddress;
{
	struct hosttable *hp;

	for (hp = addrtable[hash(numaddress)]; hp != NULL; hp = hp->next)
		if (strcmp(numaddress, hp->numaddress) == 0)
			return hp->nameaddress;
	return NULL;
}

void addhashsize(filesize, request)
     long int filesize;
     char *request;
{
	struct sizetable *sp;
	unsigned hashval;

	sp = (struct sizetable *) emalloc(sizeof(*sp));
	sp->request = strdup(request);
	hashval = hash(request);
	sp->next = reqtable[hashval];
	reqtable[hashval] = sp;
	sp->filesize = filesize;
}

long hashlookupsize(request)
     char *request;
{
	struct sizetable *sp;

	for (sp = reqtable[hash(request)]; sp != NULL; sp = sp->next)
		if (strcmp(request, sp->request) == 0)
			return sp->filesize;
	return -1;
}

void addtreeentry(request, date, filesize)
     char *request;
     long int date;
     long int filesize;
{
	int i;
	char *s, *t, path[REQUESTLEN], tempstr[REQUESTLEN];

	i = 0;
	t = (char *) strdup(request);

	path[0] = '\0';
	while (1) {
		s = (char *) strtok((i++) ? NULL : t, "/");
		if (s == NULL)
			break;
		sprintf(tempstr, "%s/%s", path, s);
		strcpy(path, tempstr);
		addhashreq(path, date, filesize);
	}
	free(t);
}

void addhashreq(request, date, filesize)
     char *request;
     long int date;
     long int filesize;
{
	struct requesttable *rt;
	unsigned hashval;

	for (rt = treetable[hash(request)]; rt != NULL; rt = rt->next)
		if (strcmp(request, rt->request) == 0) {
			rt->date = date;
			rt->requestnum++;
			if (rt->requestnum > largetreereqnum)
				largetreereqnum = rt->requestnum;
			rt->filesize += filesize;
			if (rt->filesize > largetreebytenum)
				largetreebytenum = rt->filesize;
			return;
		}

	rt = (struct requesttable *) emalloc(sizeof(*rt));
	rt->request = strdup(request);
	hashval = hash(request);
	rt->next = treetable[hashval];
	treetable[hashval] = rt;
	rt->date = date;
	rt->filesize = filesize;
	rt->requestnum = 1;
}

int hashlookupreq(request, date, filesize, requestnum)
     char *request;
     long int *date;
     long int *filesize;
     long int *requestnum;
{
	struct requesttable *rt;

	for (rt = treetable[hash(request)]; rt != NULL; rt = rt->next)
		if (strcmp(request, rt->request) == 0) {
			if (rt->removed == 1)
				return 0;
			*date = rt->date;
			*filesize = rt->filesize;
			*requestnum = rt->requestnum;
			return 1;
		}
	*date = -1;
	*filesize = 0;
	*requestnum = 0;
	return 0;
}

void hashremreq(request)
     char *request;
{
	struct requesttable *rt;

	for (rt = treetable[hash(request)]; rt != NULL; rt = rt->next)
		if (strcmp(request, rt->request) == 0) {
			rt->removed = 1;
			return;
		}
}

void installdomaintable(domainfile)
     char *domainfile;
{
	int i, j;
	char domline[DOMLINELEN], domain[DOMLEN], description[DOMDESCLEN];
	FILE *dfp;

	if ((dfp = fopen(domainfile, "r")) == NULL)
		progerr("Couldn't open domain code file.");

	while (fgets(domline, DOMLINELEN, dfp) != NULL) {
		if (isspace(domline[0]))
			continue;
		domain[0] = '.';
		for (i = 0, j = 1; !isspace(domline[i]); i++)
			domain[j++] = tolower(domline[i]);
		domain[j] = '\0';
		while (isspace(domline[i]))
			i++;
		for (j = 0; domline[i] && domline[i] != '\n'; i++)
			description[j++] = domline[i];
		description[j] = '\0';
		addhashdom(domain, description);
	}

	fclose(dfp);
}

void addhashdom(domain, description)
     char *domain;
     char *description;
{
	struct domaintable *dp;
	unsigned hashval;

	dp = (struct domaintable *) emalloc(sizeof(*dp));
	dp->domain = strdup(domain);
	hashval = hash(domain);
	dp->next = domtable[hashval];
	domtable[hashval] = dp;
	dp->description = strdup(description);
}

char *hashlookupdom(domain)
     char *domain;
{
	struct domaintable *dp;

	for (dp = domtable[hash(domain)]; dp != NULL; dp = dp->next)
		if (strcmp(domain, dp->domain) == 0)
			return dp->description;
	return NULL;
}

void addhashdn(domain)
     char *domain;
{
	struct dnametable *dp;
	unsigned hashval;

	if (hashlookupdn(domain))
		return;

	dp = (struct dnametable *) emalloc(sizeof(*dp));
	dp->domain = strdup(domain);
	hashval = hash(domain);
	dp->next = dntable[hashval];
	dntable[hashval] = dp;
}

int hashlookupdn(domain)
     char *domain;
{
	struct dnametable *dp;

	for (dp = dntable[hash(domain)]; dp != NULL; dp = dp->next)
		if (strcmp(domain, dp->domain) == 0)
			return 1;
	return 0;
}

int hashuniqdn(domain)
     char *domain;
{
	int i, hits;
	struct dnametable *dp;

	for (i = hits = 0; i < HASHSIZE; i++)
		for (dp = dntable[i]; dp != NULL; dp = dp->next) {
#ifndef SHOWIPDOMAINS
			if (strcmp(domain, IPDOMSTR) == 0 &&
			isip(dp->domain)) {
				hits++;
				continue;
			}
#endif
			if ((char *) strstr(dp->domain, domain) == (char *)
			dp->domain)
				hits++;
		}
	return hits;
}

struct entry *addentry(e, address, date, islastweek, filesize)
     struct entry *e;
     char *address;
     long int date;
     int islastweek;
     long int filesize;
{
	int isbigger, isequal;

	isbigger = isequal = 0;
	if (e == NULL) {
		e = (struct entry *) emalloc(sizeof(struct entry));
		e->docnum = 1;
		e->address = (char *) strdup(address);
		e->date = date;
		e->filesize = filesize;
		e->left = e->right = NULL;
		uniquehostnum++;
		if (islastweek == 1)
			lastweekshosts++;
		return e;
	}

	isbigger = (strcmp(address, e->address) > 0) ? 1 : 0;
	if (!strcmp(address, e->address))
		isequal = 1;

	if (isequal) {
		e->filesize += filesize;
		e->date = date;
		e->docnum += 1;
	}
	else if (isbigger)
		e->left = addentry(e->left, address,
		date, islastweek, filesize);
	else
		e->right = addentry(e->right, address,
		date, islastweek, filesize);

	return e;
}

struct entry *addsortentry(e, address, date, docnum, filesize)
     struct entry *e;
     char *address;
     long int date;
     int docnum;
     long int filesize;
{
	int i, j, isbigger;

	if (e == NULL) {
		e = (struct entry *) emalloc(sizeof(struct entry));
		e->docnum = docnum;
		e->address = (char *) strdup(address);
		e->filesize = filesize;
		e->date = date;
		e->left = e->right = NULL;
	}
	else {
		if (!strcmp(full_report, "FULLADDR")) {
			i = isip(address);
			j = isip(e->address);
			if (i && j)
				isbigger = (addrcmp(address, e->address)
				> 0) ? 1 : 0;
			else if (i || j)
				isbigger = (i) ? 1 : 0;
			else
				isbigger = (strcmp(address, e->address)
				> 0) ? 1 : 0;
		}
		else if (!strcmp(full_report, "FULLACCESS")) {
			isbigger = (docnum < e->docnum) ? 1 : 0;
			if (docnum == e->docnum)
				isbigger = (date < e->date) ? 1 : 0;
		}
		else if (!strcmp(full_report, "FULLDATE")) {
			isbigger = (date < e->date) ? 1 : 0;
			if (date == e->date)
				isbigger = (docnum < e->docnum) ? 1 : 0;
		}
		else if (!strcmp(full_report, "FULLBYTES")) {
			isbigger = (filesize < e->filesize) ? 1 : 0;
			if (filesize == e->filesize)
				isbigger = (date < e->date) ? 1 : 0;
		}

		if (isbigger)
			e->left = addsortentry(e->left, address,
			date, docnum, filesize);
		else
			e->right = addsortentry(e->right, address,
			date, docnum, filesize);
	}

	return e;
}

struct requestentry *addrequestentry(e, request, date, filesize)
     struct requestentry *e;
     char *request;
     long int date;
     long int filesize;
{
	if (e == NULL) {
		e = (struct requestentry *)
		emalloc(sizeof(struct requestentry));
		e->request = (char *) strdup(request);
		e->date = date;
		e->requestnum = 1;
		e->filesize = filesize;
		e->requestsize = filesize;
		e->left = e->right = NULL;
	}
	else if (strcmp(request, e->request) > 0)
		e->left = addrequestentry(e->left, request, date, filesize);
	else if (strcmp(request, e->request) < 0)
		e->right = addrequestentry(e->right, request, date, filesize);
	else {
		e->date = date;
		e->requestsize += filesize;
		e->requestnum += 1;
	}

	return e;
}

struct requestentry *addsortrequestentry(e, request, date, requestnum, filesize, requestsize)
     struct requestentry *e;
     char *request;
     long int date;
     int requestnum;
     long int filesize;
     long int requestsize;
{
	int isbigger;

	if (e == NULL) {
		e = (struct requestentry *)
		emalloc(sizeof(struct requestentry));
		e->request = (char *) strdup(request);
		e->date = date;
		e->filesize = filesize;
		e->requestsize = requestsize;
		e->requestnum = requestnum;
		e->left = e->right = NULL;
	}
	else {
		if (!strcmp(request_report, "REQUEST"))
			isbigger = (strcmp(request, e->request) > 0) ? 1 : 0;
		else if (!strcmp(request_report, "REQACCESS")) {
			isbigger = (requestnum < e->requestnum) ? 1 : 0;
			if (requestnum == e->requestnum)
				isbigger = (date < e->date) ? 1 : 0;
		}
		else if (!strcmp(request_report, "REQDATE")) {
			isbigger = (date < e->date) ? 1 : 0;
			if (date == e->date)
				isbigger = (requestnum < e->requestnum) ? 1 : 0;
		}
		else if (!strcmp(request_report, "REQBYTES")) {
			isbigger = (requestsize < e->requestsize) ? 1 : 0;
			if (requestsize == e->requestsize)
				isbigger = (strcmp(request, e->request) > 0) ?
				1 : 0;
		}
		else if (!strcmp(request_report, "REQFILE")) {
			isbigger = (filesize < e->filesize) ? 1 : 0;
			if (filesize == e->filesize)
				isbigger = (strcmp(request, e->request) > 0) ?
				1 : 0;
		}

		if (isbigger)
			e->left = addsortrequestentry(e->left, request, date,
			requestnum, filesize, requestsize);
		else
			e->right = addsortrequestentry(e->right, request,
			date, requestnum, filesize, requestsize);
	}

	return e;
}

struct domainentry *adddomainentry(e, domain, date, filesize)
     struct domainentry *e;
     char *domain;
     long int date;
     long int filesize;
{
	if (e == NULL) {
		e = (struct domainentry *)
		emalloc(sizeof(struct domainentry));
		e->domain = (char *) strdup(domain);
		e->date = date;
		e->filesize = filesize;
		e->requestnum = 1;
		e->left = e->right = NULL;
	}
	else if (strcmp(domain, e->domain) > 0)
		e->left = adddomainentry(e->left, domain, date, filesize);
	else if (strcmp(domain, e->domain) < 0)
		e->right = adddomainentry(e->right, domain, date, filesize);
	else {
		e->date = date;
		e->filesize += filesize;
		e->requestnum += 1;
	}

	return e;
}

struct domainentry *addsortdomainentry(e, domain, date, requestnum, filesize, unique)
     struct domainentry *e;
     char *domain;
     long int date;
     int requestnum;
     long int filesize;
     int unique;
{
	int isbigger;

	if (e == NULL) {
		e = (struct domainentry *)
		emalloc(sizeof(struct domainentry));
		e->domain = (char *) strdup(domain);
		e->date = date;
		e->filesize = filesize;
		e->requestnum = requestnum;
		e->unique = unique;
		e->left = e->right = NULL;
	}
	else {
		if (!strcmp(domain_report, "DOMAIN"))
			isbigger = (strcmp(domain, e->domain) > 0) ? 1 : 0;
		else if (!strcmp(domain_report, "DOMACCESS")) {
			isbigger = (requestnum < e->requestnum) ? 1 : 0;
			if (requestnum == e->requestnum)
				isbigger = (date < e->date) ? 1 : 0;
		}
		else if (!strcmp(domain_report, "DOMDATE")) {
			isbigger = (date < e->date) ? 1 : 0;
			if (date == e->date)
				isbigger = (requestnum < e->requestnum) ? 1 : 0;
		}
		else if (!strcmp(domain_report, "DOMBYTES")) {
			isbigger = (filesize < e->filesize) ? 1 : 0;
			if (filesize == e->filesize)
				isbigger = (strcmp(domain, e->domain) > 0) ?
				1 : 0;
		}
		else if (!strcmp(domain_report, "DOMUNIQ")) {
			isbigger = (unique < e->unique) ? 1 : 0;
			if (unique == e->unique)
				isbigger = (strcmp(domain, e->domain) > 0) ?
				1 : 0;
		}

		if (isbigger)
			e->left = addsortdomainentry(e->left, domain, date,
			requestnum, filesize, unique);
		else
			e->right = addsortdomainentry(e->right, domain,
			date, requestnum, filesize, unique);
	}

	return e;
}

void sortreport(e)
     struct entry *e;
{
	if (e != NULL) {
		sortreport(e->right);
		if (e->filesize > largestbytenum)
			largestbytenum = e->filesize;
		if (e->docnum > largestdocnum)
			largestdocnum = e->docnum;
		sortedlist = (struct entry *)
		addsortentry(sortedlist, e->address,
		e->date, e->docnum, e->filesize);
		sortreport(e->left);
	}
}

void printreport(e, docfieldlen, bytefieldlen)
     struct entry *e;
     int docfieldlen;
     int bytefieldlen;
{
	int i;
	char date[LONGDATELEN];
	static int j;

	if (e != NULL) {
		printreport(e->right, docfieldlen, bytefieldlen);
		if (toplines && j++ >= toplines)
			return;
		i = docfieldlen - numlen(e->docnum) - 1;
		while (i-- > 0)
			putchar(' ');
#ifdef SHOWSECONDS
		strcpy(date, getdatestr(e->date, 2));
		printf("%d : %s :", e->docnum, date);
#else
		strcpy(date, getdatestr(e->date, 3));
		printf("%d : %s :", e->docnum, date);
#endif
		if (printbytes) {
			i = bytefieldlen - numlen(e->filesize);
			if (i < 0)
				i = 1;
			while (i-- > 0)
				putchar(' ');
			printf("%ld :", e->filesize); /* GJM */
		}
		printf(" %s\n", e->address);
		fflush(stdout);
		printreport(e->left, docfieldlen, bytefieldlen);
	}
}

struct node *addnode(n, shortdate, requests, hour, total, filesize, type)
     struct node *n;
     char *shortdate;
     int requests;
     int hour;
     int total;
     long int filesize;
     char *type;
{
	struct node *tempnode, *newnode;

	newnode = (struct node *) emalloc(sizeof(struct node));
	newnode->shortdate = (shortdate != NULL) ?
	(char *) strdup(shortdate) : NULL;
	newnode->requests = (requests >= 0) ? requests : -1;
	newnode->filesize = (filesize >= 0) ? filesize : -1;
	if (!strcmp(type, "hourly")) {
		newnode->hour = (hour >= 0) ? hour : -1;
		newnode->total = (total >= 0) ? total : -1;
	}
	newnode->next = NULL;

	if (n == NULL)
		n = newnode;
	else {
		for (tempnode = n; tempnode->next != NULL; tempnode =
		tempnode->next)
			;
		tempnode->next = newnode;
	}

	return n;
}

struct errorlist *adderror(e, error)
     struct errorlist *e;
     char *error;
{
	struct errorlist *tempnode, *newnode;

	newnode = (struct errorlist *) emalloc(sizeof(struct errorlist));
	newnode->error = (char *) strdup(error);
	newnode->next = NULL;

	if (e == NULL)
		e = newnode;
	else {
		for (tempnode = e; tempnode->next != NULL; tempnode =
		tempnode->next)
			;
		tempnode->next = newnode;
	}

	return e;
}

void printerrors(e, fp)
     struct errorlist *e;
     FILE *fp;
{
	while (e != NULL) {
		fprintf(fp, "%s", e->error);
		e = e->next;
	}
}

void printsummary(type)
     char *type;
{
	int i, endnum;
	long largenum;

	if (!strcmp(type, "hourly"))
		endnum = 23;
	else
		endnum = 6;

	for (i = largenum = 0; i <= endnum; i++)
		if (!strcmp(type, "hourly")) {
			if (hoursumstats[i] > largenum)
				largenum = hoursumstats[i];
			if (printbytes && hoursumstats[i + 24] > largenum)
				largenum = hoursumstats[i + 24];
		}
		else {
			if (daysumstats[i] > largenum)
				largenum = daysumstats[i];
			if (printbytes && daysumstats[i + 7] > largenum)
				largenum = daysumstats[i + 7];
		}
		
	for (i = 0; i <= endnum; i++)
		if (!strcmp(type, "hourly")) {
			printhour(i);
			printgraph(11, hoursumstats[i], HOURSUMMARK, MARK,
			largenum);
			if (printbytes) {
				printf("   bytes : ");
				printgraph(11, hoursumstats[i + 24],
				HOURSUMBYTEMARK, BYTEMARK, largenum);
			}
		}
		else {
			printf("   %s: ", days[(i == 6) ? 0 : i + 1]);
			printgraph(8, daysumstats[i], DAYSUMMARK, MARK,
			largenum);
			if (printbytes) {
				printf("bytes : ");
				printgraph(8, daysumstats[i + 7],
				DAYSUMBYTEMARK, BYTEMARK, largenum);
			}
		}
}

void printgraphreport(n, type)
     struct node *n;
     char *type;
{
	while (n != NULL) {
		if (!strcmp(type, "monthly")) {
			if (n->shortdate != NULL)
				printf("%s (%s): ", getmonth(n->shortdate),
				convtoeurodate(n->shortdate));
			if (n->requests >= 0)
				printgraph(16, n->requests, MONTHMARK, MARK,
				largestmonthnum);
			if (printbytes && n->filesize >= 0) {
				printf("        bytes : ");
				printgraph(16, n->filesize, MONTHBYTEMARK,
				BYTEMARK, largestmonthnum);
			}
		}
		else if (!strcmp(type, "weekly")) {
			if (n->shortdate != NULL)
				printf("Week of %s: ",
				convtoeurodate(getshortdate(n->shortdate, 1)));
			if (n->requests >= 0)
				printgraph(18, n->requests, WEEKMARK, MARK,
				largestweeknum);
			if (printbytes && n->filesize >= 0) {
				printf("          bytes : ");
				printgraph(18, n->filesize, WEEKBYTEMARK,
				BYTEMARK, largestweeknum);
			}
		}
		else if (!strcmp(type, "daily")) {
			if (n->shortdate != NULL)
				printf("%s (%s): ",
				convtoeurodate(n->shortdate),
				days[getweekday(n->shortdate)]);
			if (n->requests >= 0)
				printgraph(16, n->requests, DAYMARK, MARK,
				largestdaynum);
			if (printbytes && n->filesize >= 0) {
				printf("        bytes : ");
				printgraph(16, n->filesize, DAYBYTEMARK,
				BYTEMARK, largestdaynum);
			}
		}
		else if (!strcmp(type, "hourly")) {
			if (n->shortdate != NULL)
				printf("\n%s (%s)\n\n",
				convtoeurodate(n->shortdate),
				days[getweekday(n->shortdate)]);
			if (n->hour >= 0)
				printhour(n->hour);
			if (n->requests >= 0)
				printgraph(11, n->requests, HOURMARK, MARK,
				largesthournum);
			if (printbytes && n->filesize >= 0) {
				printf("   bytes : ");
				printgraph(11, n->filesize, HOURBYTEMARK,
				BYTEMARK, largesthournum);
			}
			if (n->total >= 0)
				printf("\n    total: %d\n", n->total);
		}
		n = n->next;
	}
}

void printgraph(beforelen, numbers, numspermark, mark, bignum)
     int beforelen;
     long int numbers;
     int numspermark;
     char mark;
     long int bignum;
{
	int i, tmpnumbers, marknum, truncatelen, graphlen, bignumlen;

	bignumlen = numlen(bignum);
	truncatelen = (TRUNCATE < 10) ? 0 : TRUNCATE;

	tmpnumbers = numbers;
	for (marknum = 0; tmpnumbers != 0 && tmpnumbers > numspermark;
	tmpnumbers -= numspermark)
		marknum++;
	if (tmpnumbers >= (numspermark / 2))
		marknum++;

	graphlen = beforelen + bignumlen + marknum + 5;
	if (truncatelen && graphlen > TRUNCATE) {
		marknum = truncatelen - (beforelen + bignumlen + 5);
		i = bignumlen - numlen(numbers);
		while (i-- > 0)
			putchar(' ');
		printf("%d : ", numbers);
		while (marknum--) {
			if (marknum == 3 || marknum == 4)
				putchar('|');
			else
				putchar(mark);
		}
		putchar('\n');
	}
	else {
		i = bignumlen - numlen(numbers);
		while (i-- > 0)
			putchar(' ');
		printf("%d : ", numbers);
		while (marknum--)
			putchar(mark);
		putchar('\n');
	}
}

void printtree(e, reqfieldlen, bytefieldlen)
     struct requestentry *e;
     int reqfieldlen;
     int bytefieldlen;
{
	int i, j, status;
	long date, filesize, requestnum;
	char *s, *t, datestr[LONGDATELEN],
		tempstr[REQUESTLEN], path[REQUESTLEN];

	if (e != NULL) {
		printtree(e->right, reqfieldlen, bytefieldlen);

		j = 0;
		t = (char *) strdup(e->request);

		path[0] = '\0';
		while (1) {
			s = (char *) strtok((j++) ? NULL : t, "/");
			if (s == NULL)
				break;
			sprintf(tempstr, "%s/%s", path, s);
			strcpy(path, tempstr);

			status = hashlookupreq(path, &date, &filesize,
			&requestnum);

			if (!status || strstr(path, "..") || !strcmp(s, "."))
				continue;
			if (checkfiles == 0)
				strcpy(tempstr, path);
			else
				sprintf(tempstr, "%s%s", rootdir, path);
			if (checkfiles)
#ifdef SHOWTREEFILES
				if (!isdirectory(tempstr) && !isfile(tempstr))
#else
				if (!isdirectory(tempstr))
#endif
					continue;

			hashremreq(path);

			i = reqfieldlen - numlen(requestnum) - 1;
			while (i-- > 0)
				putchar(' ');
			printf("%d : ", requestnum);

			if (date != -1) {
#ifdef SHOWSECONDS
				strcpy(datestr, getdatestr(date, 2));
				printf("%s : ", datestr);
#else
				strcpy(datestr, getdatestr(date, 3));
				printf("%s : ", datestr);
#endif
			}
			else
#ifdef SHOWSECONDS
				printf("xx/xx/xx xx:xx:xx : ");
#else
				printf("xx/xx/xx : ");
#endif
			if (printbytes) {
				i = bytefieldlen - numlen(filesize) - 1;
				while (i-- > 0)
					putchar(' ');
				printf("%ld : ", filesize); /* GJM */
			}

			i = (numstrchr(path, '/') - 1) * 2;
			while (i-- > 0)
				putchar(' ');

			if (checkfiles) {
				if (isfile(tempstr))
					printf("%s\n", s);
				else if (isdirectory(tempstr))
					printf("/%s\n", s);
			}
			else
				printf("%s\n", s);
		}
		free(t);
		printtree(e->left, reqfieldlen, bytefieldlen);
	}
}

int isdirectory(path)
     char *path;
{
	struct stat stbuf;

	if (stat(path, &stbuf))
		return 0;
	return ((stbuf.st_mode & S_IFMT) == S_IFDIR) ? 1 : 0;
}

int isfile(path)
     char *path;
{
	struct stat stbuf;

	if (stat(path, &stbuf))
		return 0;
	return ((stbuf.st_mode & S_IFMT) == S_IFREG) ? 1 : 0;
}

void sortrequests(e)
     struct requestentry *e;
{
	if (e != NULL) {
		sortrequests(e->right);
		uniquereqnum++;
		if (e->requestnum > largestreqnum)
			largestreqnum = e->requestnum;
		if (e->requestsize > largestbytenum)
			largestbytenum = e->requestsize;
		if (e->filesize > largestfilesizenum)
			largestfilesizenum = e->filesize;
		sortedrequestlist = (struct requestentry *)
		addsortrequestentry(sortedrequestlist, e->request,
		e->date, e->requestnum, e->filesize, e->requestsize);
		sortrequests(e->left);
	}
}

void printrequests(e, reqfieldlen, bytefieldlen, sizefieldlen)
     struct requestentry *e;
     int reqfieldlen;
     int bytefieldlen;
     int sizefieldlen;
{
	int i, reqlen, truncatelen, datelen;
	char date[LONGDATELEN];
	static int j;

#ifdef SHOWSECONDS
	datelen = 17;
#else
	datelen = 8;
#endif

	if (e != NULL) {
		printrequests(e->right, reqfieldlen, bytefieldlen,
		sizefieldlen);
		if (toplines && j++ >= toplines)
			return;
		i = reqfieldlen - numlen(e->requestnum) - 1;
		while (i-- > 0)
			putchar(' ');
#ifdef SHOWSECONDS
		strcpy(date, getdatestr(e->date, 2));
		printf("%d : %s : ", e->requestnum, date);
#else
		strcpy(date, getdatestr(e->date, 3));
		printf("%d : %s : ", e->requestnum, date);
#endif
		truncatelen = (TRUNCATE < 10) ? 0 : TRUNCATE;
		if (truncatelen) {
			reqlen = reqfieldlen + ((printbytes) ? (bytefieldlen +
			sizefieldlen + 6) : 0) + datelen + strlen(e->request) +
			7;
			if (reqlen > truncatelen) {
				reqlen = truncatelen - reqfieldlen -
				((printbytes) ? (bytefieldlen + sizefieldlen +
				6) : 0) - datelen - 7;
				(e->request)[reqlen] = '\0';
			}
		}
		if (printbytes) {
			i = bytefieldlen - numlen(e->requestsize) - 1;
			while (i-- > 0)
				putchar(' ');
			printf("%d / ", e->requestsize);
			i = sizefieldlen - numlen(e->filesize) - 1;
			while (i-- > 0)
				putchar(' ');
			printf("%ld : ", e->filesize); /* GJM */
		}
#ifdef PRINTURLS
		if (printhtml)
			printf("<a href=\"%s%s\">", SERVERSITE,
			(e->request) + 1);
#endif
		printf("%s", e->request);
#ifdef PRINTURLS
		if (printhtml)
			printf("</a>");
#endif
		putchar('\n');
		fflush(stdout);
		printrequests(e->left, reqfieldlen, bytefieldlen,
		sizefieldlen);
	}
}

void sortdomains(e)
     struct domainentry *e;
{
	int i, u;

	if (e != NULL) {
		sortdomains(e->right);
		i = numstrchr(e->domain, '.');
		if (!i || i == 1)
			uniquedomnum++;
		if (e->filesize > largestbytenum)
			largestbytenum = e->filesize;
		if (e->requestnum > largestdomnum)
			largestdomnum = e->requestnum;
		u = hashuniqdn(e->domain);
		if (u > largestudomnum)
			largestudomnum = u;
		sorteddomainlist = (struct domainentry *)
		addsortdomainentry(sorteddomainlist, e->domain,
		e->date, e->requestnum, e->filesize, u);
		sortdomains(e->left);
	}
}

void printdomains(e, domfieldlen, bytefieldlen, uniqfieldlen)
     struct domainentry *e;
     int domfieldlen;
     int bytefieldlen;
     int uniqfieldlen;
{
	int i, j;
	char date[LONGDATELEN];
	static int k;

	if (e != NULL) {
		printdomains(e->right, domfieldlen, bytefieldlen, uniqfieldlen);
		if (toplines && k++ >= toplines)
			return;
		i = domfieldlen - numlen(e->requestnum) - 1;
		while (i-- > 0)
			putchar(' ');
		printf("%d : ", e->requestnum);
		i = uniqfieldlen - numlen(e->unique) - 1;
		while (i-- > 0)
			putchar(' ');
		printf("%d : ", e->unique);

#ifdef SHOWSECONDS
		strcpy(date, getdatestr(e->date, 2));
		printf("%s : ", date);
#else
		strcpy(date, getdatestr(e->date, 3));
		printf("%s : ", date);
#endif
		if (printbytes) {
			i = bytefieldlen - numlen(e->filesize) - 1;
			if (i < 0)
				i = 1;
			while (i-- > 0)
				putchar(' ');
			printf("%ld : ", e->filesize); /* GJM */
		}
		j = numstrchr(e->domain, '.') - 1;
		while (j-- > 0)
			putchar(' ');
		if (domainfile != NULL && numstrchr(e->domain, '.') == 1 &&
		hashlookupdom(e->domain) != NULL)
			printf("%s (%s)\n", hashlookupdom(e->domain),
			e->domain);
		else
			printf("%s\n", e->domain);
		fflush(stdout);
		printdomains(e->left, domfieldlen, bytefieldlen, uniqfieldlen);
	}
}

char *lookupnumaddr(numaddress)
     char *numaddress;
{
	char *p;
	unsigned long addr;
	struct hostent *he;

	addr = inet_addr(numaddress);
	if (addr == -1)
		return numaddress;

	p = (char *) hashlookupnumaddr(numaddress);
	if (p != NULL)
		return p;

	he = gethostbyaddr((char *) &addr, sizeof(addr), AF_INET);
	if (he) {
		addhash(he->h_name, numaddress);
		return he->h_name;
	}
	else
		return numaddress;
}

int addrcmp(addr1, addr2)
     char *addr1;
     char *addr2;
{
	unsigned long num1, num2;

	num1 = inet_addr(addr1);
	num2 = inet_addr(addr2);

	if (num1 > num2)
		return 1;
	else if (num1 < num2)
		return -1;

	return 0;
}

int numlen(num)
     long int num;
{
	int i;

	i = 0;
	while (num /= 10)
		i++;

	return i;
}

char *getlocaltime()
{
	static char s[LONGDATELEN], tmp[LONGDATELEN];
	time_t tp;
 
	time(&tp);
#ifndef VMS
	strftime(s, LONGDATELEN, "%a %b %d %H:%M:%S %p %Z %Y", localtime(&tp));
#else
	strcpy(s, asctime(localtime(&tp)));
#endif

#ifdef EURODATE
	strcpy(tmp, s);
	tmp[4] = s[8];
	tmp[5] = s[9];
	tmp[6] = ' ';
	tmp[7] = s[4];
	tmp[8] = s[5];
	tmp[9] = s[6];

	return tmp;
#else
	return s;
#endif
}

long getthetime()
{
	long thetime;
	time_t tp;

	thetime = (long) time(&tp);
	return thetime;
}

char *getmonth(shortdate)
     char *shortdate;
{
	int monthnum;

	monthnum = ((shortdate[0] - '0') * 10) + (shortdate[1] - '0');

	return months[monthnum - 1];
}

int getweekday(shortdate)
     char *shortdate;
{
	int mn, dy, yr, n1, n2;

	sscanf(shortdate, "%d/%d/%d", &mn, &dy, &yr);
	yr += CENTURY;

	if (mn < 3) {
		mn += 12;
		yr -= 1;
	}
	n1 = (26 * (mn + 1)) / 10;
	n2 = (int) ((125 * (long) yr) / 100);

	return ((dy + n1 + n2 - (yr / 100) + (yr / 400) + -1) % 7);
}

int getnweekday(mn, dy, yr)
     int mn;
     int dy;
     int yr;
{
	int n1, n2;

	if (mn < 3) {
		mn += 12;
		yr -= 1;
	}
	n1 = (26 * (mn + 1)) / 10;
	n2 = (int) ((125 * (long) yr) / 100);

	return ((dy + n1 + n2 - (yr / 100) + (yr / 400) + -1) % 7);
}

long getyearsecs(shortdate)
     char *shortdate;
{
	int i, yearday, yearsecs, prevyeardays;
	int month, day, year;

	sscanf(shortdate, "%d/%d/%d", &month, &day, &year);
	year += CENTURY;

	for (yearday = i = 0; i < month - 1; i++) {
		if (i == 1 && IS_LEAP(year))
			yearday++;
		yearday += monthdays[i];
	}
	yearday += day;

	prevyeardays = 0;
	for (i = BASEYEAR; i != year; i++) {
		if (IS_LEAP(i))
			prevyeardays++;
		prevyeardays += DAYSPERYEAR;
	}

	yearsecs = (yearday + prevyeardays) * SECSPERDAY;
 
	return yearsecs;
}

char *getdatestr(yearsecs, type)
     long int yearsecs;
     int type;
{
	register int day, year, month, hours, minutes;
	static char date[LONGDATELEN];

	for (day = 0; yearsecs > SECSPERDAY; day++)
		yearsecs -= SECSPERDAY;

	for (year = BASEYEAR; day > DAYSPERYEAR; year++) {
		if (IS_LEAP(year))
			day--;
		day -= DAYSPERYEAR;
	}

	if (IS_LEAP(year) && day > (monthdays[0] + monthdays[1])) {
		day--;
		yearsecs -= SECSPERDAY;
	}

	for (month = 0; day > monthdays[month]; month++)
		day -= monthdays[month];

	for (hours = 0; yearsecs > SECSPERHOUR; hours++)
		yearsecs -= SECSPERHOUR;

	for (minutes = 0; yearsecs > SECSPERMIN; minutes++)
		yearsecs -= SECSPERMIN;

#ifndef EURODATE
	if (type == 1)
		sprintf(date, "%s %s %02d %02d:%02d:%02d %d",
		days[getnweekday(month + 1, day, year)], months[month],
		day, hours, minutes, yearsecs, year);
	else if (type == 2)
		sprintf(date, "%02d/%02d/%02d %02d:%02d:%02d",
		month + 1, day, year - CENTURY, hours, minutes, yearsecs);
	else if (type == 3)
		sprintf(date, "%02d/%02d/%02d",
		month + 1, day, year - CENTURY);
	else if (type == 4)
		sprintf(date, "%s %d, %d", months[month], day, year);
#else
	if (type == 1)
		sprintf(date, "%s %02d %s %02d:%02d:%02d %d",
		days[getnweekday(month + 1, day, year)], day,
		months[month], hours, minutes, yearsecs, year);
	else if (type == 2)
		sprintf(date, "%02d/%02d/%02d %02d:%02d:%02d",
		day, month + 1, year - CENTURY, hours, minutes, yearsecs);
	else if (type == 3)
		sprintf(date, "%02d/%02d/%02d",
		day, month + 1, year - CENTURY);
	else if (type == 4)
		sprintf(date, "%d %s, %d", day, months[month], year);
#endif

	return date;
}

int getyearday(shortdate)
     char *shortdate;
{
	int i, month, day, year, yearday;
	char tmpshortdate[SHORTDATELEN];

	strcpy(tmpshortdate, shortdate); 
	sscanf(tmpshortdate, "%d/%d/%d", &month, &day, &year);
	year += CENTURY;
	for (yearday = i = 0; i < month - 1; i++) {
		if (i == 1 && IS_LEAP(year))
			yearday++;
		yearday += monthdays[i];
	}
	yearday += day;

	return yearday;
}

int getmondaynum(shortdate)
     char *shortdate;
{
	int month, day, year, yearday, weekday, mondayday;

	sscanf(shortdate, "%d/%d/%d", &month, &day, &year);
	year += CENTURY;

	yearday = getyearday(shortdate);
	weekday = getweekday(shortdate);

	if (!weekday)
		weekday = 7;
	mondayday = yearday - (weekday - 1);
	if (mondayday <= 0) {
		mondayday += (DAYSPERYEAR - 1);
		year--;
		if (IS_LEAP(year))
			mondayday++;
	}

	return mondayday;
}

char *getshortdate(shortdate, getmon)
     char *shortdate;
     int getmon;
{
	int i, month, day, year, yearday, weekday, sundayday, mondayday;
	static char newshortdate[SHORTDATELEN];

	sscanf(shortdate, "%d/%d/%d", &month, &day, &year);
	year += CENTURY;

	yearday = getyearday(shortdate);
	weekday = getweekday(shortdate);

	if (!weekday)
		weekday = 7;

	mondayday = yearday - (weekday - 1);
	sundayday = yearday + (DAYSPERWEEK - weekday);

	if (!getmon && sundayday > DAYSPERYEAR) {
		month++;
		if (month == 13)
			month = 1;
		sundayday -= DAYSPERYEAR;
		year++;
	}

	if (getmon && mondayday <= 0) {
		month--;
		if (!month)
			month = 12;
		mondayday += (DAYSPERYEAR - 1);
		year--;
		if (IS_LEAP(year))
			mondayday++;
	}

	yearday = (getmon) ? mondayday : sundayday;

	for (i = 0; i < month - 1; i++)
		if (yearday > monthdays[i])
			yearday -= monthdays[i];
		else {
			if (i == 2 && IS_LEAP(year))
				yearday--;
			break;
		}

	sprintf(newshortdate, "%02d/%02d/%02d", i + 1, yearday, year - CENTURY);

	return newshortdate;
}

int daydifference(firstshortdate, secondshortdate)
     char *firstshortdate;
     char *secondshortdate;
{
	return (int) (getyearsecs(secondshortdate) -
	getyearsecs(firstshortdate)) / SECSPERDAY;
}

int isinlastweek(shortdate, newshortdate)
     char *shortdate;
     char *newshortdate;
{
	long newsecs, oldsecs;

	newsecs = getyearsecs(newshortdate);
	oldsecs = getyearsecs(shortdate);

	if ((newsecs - oldsecs) <= SECSPERWEEK)
		return 1;
	else
		return 0;
}

int isvalidreq(request)
     char *request;
{
	return (strstr(request, "GET") || strstr(request, "HEAD") ||
	strstr(request, "POST"));
}

int ishtmlrequest(request)
     char *request;
{
	return (strstr(request, ".html") || strstr(request, "GET") ||
	strstr(request, "HEAD"));
}

int isscriptrequest(request)
     char *request;
{
	return (strstr(request, "cgi-bin") || strstr(request, "htbin") ||
	strstr(request, "POST"));
}

char *headerend(request)
     char *request;
{
	char *c;

	if ((c = (char *) strstr(request, "GET")) != NULL)
		return (c + 3);
	else if ((c = (char *) strstr(request, "HEAD")) != NULL)
		return (c + 4);
	else if ((c = (char *) strstr(request, "POST")) != NULL)
		return (c + 4);

	return NULL;
}

int isokstring(string, mask, skip)
     char *string;
     char *mask;
     int skip;
{
	int i;
	char *s, *t;

	if (!strcmp(mask, "NONE"))
		return 1;

	i = 0;
	t = (char *) strdup(mask);

	if (skip) {
		while (1) {
			s = (char *) strtok((i++) ? NULL : t, ",");
			if (s == NULL)
				break;
			if (isinname(string, s))
				return 0;
		}
		return 1;
	}
	else {
		while (1) {
			s = (char *) strtok((i++) ? NULL : t, ",");
			if (s == NULL)
				break;
			if (isinname(string, s))
				return 1;
		}
		return 0;
	}
}

int isinname(string, mask)
     char *string;
     char *mask;
{
	int i, j;
	char firstchar, lastchar, *tempmask;

	if (!strcmp(mask, "*"))
		return 1;

	firstchar = mask[0];
	lastchar = mask[(strlen(mask) - 1)];
	tempmask = (char *) emalloc(strlen(mask));

	for (i = j = 0; mask[i]; i++)
		if (mask[i] != '*')
			tempmask[j++] = mask[i];
	tempmask[j] = '\0';

	if (firstchar == '*') {
		if (lastchar == '*') {
			if ((char *) strstr(string, tempmask))
				return 1;
		}
		else {
			if ((char *) strstr(string, tempmask) ==
			string + strlen(string) - strlen(tempmask))
				return 1;
		}
	}
	else if (lastchar == '*') {
		if ((char *) strstr(string, tempmask) == string)
			return 1;
	}
	else {
		if (!strcmp(string, tempmask))
			return 1;
	}

	return 0;
}

int isokdate(monthstr, daystr, yearstr, shortdate)
     char *monthstr;
     char *daystr;
     char *yearstr;
     char *shortdate;
{
	int month, day, year, uppernum, lowernum;

	sscanf(shortdate, "%d/%d/%d", &month, &day, &year);

	if (isnumber(monthstr))
		if (atoi(monthstr) != month)
			return 0;
	if (isnumber(daystr))
		if (atoi(daystr) != day)
			return 0;
	if (isnumber(yearstr)) {
		if (atoi(yearstr) > CENTURY)
			year += CENTURY;
		if (atoi(yearstr) != year)
			return 0;
	}

	if (strchr(monthstr, '-')) {
		parsedaterange(monthstr, &lowernum, &uppernum);
		if (month < lowernum || month > uppernum)
			return 0;
	}
	if (strchr(daystr, '-')) {
		parsedaterange(daystr, &lowernum, &uppernum);
		if (day < lowernum || day > uppernum)
			return 0;
	}
	if (strchr(yearstr, '-')) {
		parsedaterange(yearstr, &lowernum, &uppernum);
		if (year < lowernum || year > uppernum)
			return 0;
	}

	return 1;
}

int isokhour(date, lowhour, highhour)
     char *date;
     int lowhour;
     int highhour;
{
	int hour;
	char hourstr[3];

	sprintf(hourstr, "%c%c", (date[11] == ' ') ? '0' : date[11], date[12]);
	hour = atoi(hourstr);

	if (hour >= lowhour && hour <= highhour)
		return 1;
	return 0;
}

void parsedaymask(mask, lowday, highday)
     char *mask;
     int *lowday;
     int *highday;
{
	int i, j;
	char templowday[4], temphighday[4];

	if (!strchr(mask, '-')) {
		if (!strcmp(mask, "weekdays")) {
			*lowday = 1;
			*highday = 5;
		}
		else if (!strcmp(mask, "weekends")) {
			*lowday = 6;
			*highday = 7;
		}
		else {
			*lowday = getday(mask);
			*highday = getday(mask);
		}
	}
	else {
		for (i = 0, j = 0; mask[i] && mask[i] != '-'; i++)
			templowday[j++] = mask[i];
		templowday[j] = '\0';

		for (i++, j = 0; mask[i]; i++)
			temphighday[j++] = mask[i];
		temphighday[j] = '\0';

		if (temphighday[0] != '\0')
			*highday = getday(temphighday);
		else
			*highday = 7;

		if (templowday[0] != '\0')
			*lowday = getday(templowday);
		else
			*lowday = 1;
	}
}

int getday(string)
     char *string;
{
	int i;
	char *tempstr, *tempday;

	tempstr = (char *) strdup(string);
	makelower(string);

	tempday = (char *) emalloc(4);
	for (i = 0; days[i]; i++) {
		strcpy(tempday, days[i]);
		makelower(tempday);
		if (strstr(tempstr, tempday))
			break;
	}

	return ((!i) ? 7 : i);
}

int isokday(date, lowday, highday)
     char *date;
     int lowday;
     int highday;
{
	int i, dateday;

	for (i = 0; !strstr(date, days[i]); i++)
		;
	dateday = (!i) ? 7 : i;

	if (dateday >= lowday && dateday <= highday)
		return 1;
	return 0;
}

void parsedatemask(datemask, monthstr, daystr, yearstr)
     char *datemask;
     char *monthstr;
     char *daystr;
     char *yearstr;
{
	int i, j;

	for (i = 0; isokdatechar(datemask[i]); i++)
		monthstr[i] = datemask[i];
	monthstr[i++] = '\0';
	for (j = 0; isokdatechar(datemask[i]); i++)
		daystr[j++] = datemask[i];
	daystr[j] = '\0';
	i++;
	for (j = 0; isokdatechar(datemask[i]); i++)
		yearstr[j++] = datemask[i];
	yearstr[j] = '\0';
}

void parsehourmask(hourmask, lowhour, highhour)
     char *hourmask;
     int *lowhour;
     int *highhour;
{
	int i, j;

	if (!strchr(hourmask, '-')) {
		*lowhour = atoi(hourmask);
		*highhour = atoi(hourmask);
	}
	else {
		for (i = j = 0; hourmask[i] != '-'; i++)
			if (isdigit(hourmask[i]))
				j = (j * 10) + (hourmask[i] - '0');
		*lowhour = (j) ? j : 0;

		for (i++, j = 0; hourmask[i]; i++)
			if (isdigit(hourmask[i]))
				j = (j * 10) + (hourmask[i] - '0');
		*highhour = (j) ? j : 23;
	}
}

int isokdatechar(c)
     char c;
{
	if (c == '*' || isdigit(c) || c == '[' || c == ']' || c == '-')
		return 1;
	return 0;
}

void parsedaterange(datemask, lower, upper)
     char *datemask;
     int *lower;
     int *upper;
{
	int lowernum, uppernum;

	lowernum = uppernum = 0;
	while (*datemask != '-') {
		if (isdigit(*datemask))
			lowernum = (lowernum * 10) + (*datemask - '0');
		datemask++;
	}
	datemask++;
	while (*datemask) {
		if (isdigit(*datemask))
			uppernum = (uppernum * 10) + (*datemask - '0');
		datemask++;
	}

	*lower = lowernum;
	*upper = uppernum;
}

int isnumber(s)
     char *s;
{
	while (*s) {
		if (!isdigit(*s))
			return 0;
		s++;
	}

	return 1;
}

int numstrchr(s, c)
     char *s;
     char c;
{
	int i;

	for (i = 0; *s != '\0'; s++)
		if (*s == c)
			i++;
	return i;
}

int isip(address)
     char *address;
{
	int dots, prevdot;

	dots = 0;
	prevdot = 1;
	while (*address != (char) NULL) {
		if (*address == '.') {
			dots++;
			if (prevdot)
				return 0;
			prevdot = 1;
		}
		else {
			if (*address < '0' || *address > '9')
				return 0;
			prevdot = 0;
		}
		address++;
	}
	return (dots == 3) && !prevdot;
}

long getsize(request)
     char *request;
{
	char path[REQUESTLEN];
	long size;
	struct stat stbuf;

	size = hashlookupsize(request);

	if (size == -1) {
		sprintf(path, "%s%s", rootdir, request);
		if (stat(path, &stbuf)) {
			addhashsize(0, request);
			return 0;
		}
		else {
			addhashsize(stbuf.st_size, request);
			return stbuf.st_size;
		}
	}
	else
		return size;
}

long isempty(file)
     char *file;
{
	struct stat stbuf;

	if (stat(file, &stbuf))
		return 1;

	return (!(stbuf.st_size));
}

void makelower(string)
     char *string;
{
	int i, j;
	char *tempstr;

	tempstr = (char *) strdup(string);
	for (i = j = 0; string[j] && tempstr[i]; i++)
		string[j++] = tolower(tempstr[i]);
	string[j] = '\0';
	free(tempstr);
}

void removespaces(string)
     char *string;
{
	int i, j;
	char *tempstr;

	tempstr = (char *) strdup(string);
	for (i = j = 0; tempstr[i]; i++) {
		if (isspace(tempstr[i]))
			continue;
		else
			string[j++] = tempstr[i];
	}
	string[j] = '\0';
}

void fixslash(string)
     char *string;
{
        char *c;

	c = (char *) string + strlen(string) - 1;
	while (*c == '/' || isspace(*c)) {
		*c = '\0';
		c--;
	}
}

char *strdup(s)
     char *s;
{
	char *p;

	p = (char *) emalloc(strlen(s) + 1);
	strcpy(p, s);
	return p;
}

void setupprogress(logfile)
     char *logfile;
{
	int i;
	char logline[MAXLINE];
	FILE *fp;

	fprintf(stderr, "Log file length...");

	fp = fopen(logfile, "r");
	while (fgets(logline, MAXLINE, fp) != NULL)
		loglines++;
	fclose(fp);

	linespermark = loglines / PROGRESSLEN;
	if (!linespermark)
		linespermark = 1;

	fprintf(stderr, " %d lines. ~%d line%s per mark.\n",
	loglines, linespermark, (linespermark == 1) ? "" : "s");

	for (i = 0; i != PROGRESSLEN; i++) {
		if (!i)
			fputc('0', stderr);
		else if (i == (PROGRESSLEN / 2))
			fprintf(stderr, "50");
		else if (i == (PROGRESSLEN - 3))
			fprintf(stderr, "100");
		else
			fputc(' ', stderr);
	}
	fputc('\n', stderr);
	for (i = 0; i != PROGRESSLEN; i++) {
		if (!i)
			fputc('|', stderr);
		else if (i == (PROGRESSLEN / 2))
			fputc('|', stderr);
		else
			fputc('-', stderr);
	}
	fprintf(stderr, "|\n");
}

void updateprogress(line)
     int line;
{
	if (!(line % linespermark)) {
		fputc('*', stderr);
		fflush(stderr);
	}
}

void *emalloc(i)
     int i;
{
	void *p;
 
	if ((p = (void *) malloc(i)) == NULL)
		progerr("Ran out of memory!");
	return p;
}

void noactivity()
{
	if (printhtml) {
		printf("<p>\n<b>No activity reported on this date.</b>\n");
		printf("<p>\n<hr>\n");
		printbottomhtml();
	}
	else
		printf("\nNo activity reported on this date.\n");
#ifdef VMS
	exit(1);
#else
	exit(0);
#endif
}

void printbottomhtml()
{
	printf("<i>These statistics were produced by <a href=\"");
	printf("%s\">%s %s</a>.</i>\n</body>\n", DOCURL, PROGNAME, VERSION);
}

void progerr(errorstr)
     char *errorstr;
{
#ifdef CGI
	printf("Content-type: text/html\n\n");
	printf("<title>Getstats error</title>\n");
	printf("<h1>Getstats error</h1>\n<p>\n");
	printf("<code>%s: %s</code>\n", PROGNAME, errorstr);
#ifdef VMS
	exit(1);
#else
	exit(0);
#endif
#else
	fprintf(stderr, "%s: %s\n", PROGNAME, errorstr);
	exit(-1);
#endif
}

void usage()
{
	printf("  usage: %s [-C,-N,-P,-G,-A,-O], -M, ", PROGNAME);
	printf("-c, -m, -w, -ds -d, -hs, -h,\n");
	printf("         -e [\"file\"], -a, ");
	printf("-dt, [-f,-fa,-fd,-fb], [-r,-ra,-rd,-rb,-rf],\n");
	printf("         [-dn,-da,-dd,-db,-du], -dl #, -df \"file\",\n");
	printf("         -sa \"string\", -ss \"string\", ");
	printf("-sr \"string\", -sp \"string\",\n");
	printf("         -sd \"string\", -sh \"string\", -sw \"string\",\n");
	printf("         -b, -i, -ip, -p, -ht, -t #, -dr [\"dir\"], ");
	printf("-l \"file\"\n");
	printf("options: No option gives the default report.\n");
	printf("         -C, -N, -P, -G, -A, -O\n");
	printf("             : use CERN, NCSA, Plexus, GN, MacHTTP,\n");
	printf("               or UNIX Gopher server log format\n");
	printf("         -M  : use common logfile format\n");
	printf("         -c, -m, -w, -ds, -d, -hs, -h, -e, -a\n");
	printf("             : concise, monthly, weekly, daily summary, ");
	printf("daily, hourly summary,\n");
	printf("               hourly, error, and all reports\n");
	printf("         -f, -fa, -fd, -fb : full report\n");
	printf("             : sorted by address, accesses, date, or bytes\n");
	printf("         -r, -ra, -rd, -rb, -rf : file request report\n");
	printf("             : sorted by request, accesses, date, bytes, ");
	printf("or file size\n");
	printf("         -dn, -da, -dd, -db, -du : domain report\n");
	printf("             : sorted by domain, accesses, date, bytes, ");
	printf("or unique domains\n");
	printf("         -dl : number of domain levels to report\n");
	printf("         -df : file to look up domain codes from\n");
	printf("         -dt : directory tree report\n");
	printf("         -sa, -ss, -sr, -sp : filter log by ");
	printf("\"string\"\n");
	printf("             : only addresses, skip addresses, only reqs, ");
	printf("skip reqs\n");
	printf("         -sd : report entries with date \"m/d/y\"\n");
	printf("         -sh : report entries with hour \"h\"\n");
	printf("         -sw : report entries with day \"day\"\n");
	printf("         -b  : add byte traffic statistics to all reports\n");
	printf("         -i  : take input from standard input\n");
	printf("         -ip : look up all IP addresses\n");
	printf("         -p  : display progress meter\n");
	printf("         -ht : produce HTML output\n");
	printf("         -t  : take top # lines of list reports\n");
	printf("         -dr : root Web/Gopher directory\n");
	printf("         -l  : logfile to use\n");
	printf("   docs: %s\n", DOCURL);
	exit(-1);
}

/*
** Version history
**
** 1.0 : Original hack, "getsites", written 6/93 at Honolulu Community College.
** 1.1 : Better formatting, checks for malloc() errors.
** 1.2 : Fixed a timing error - reports last weeks's numbers/lifetime better.
** 1.3 : Complete rewrite. More stable, IP lookup more verbose, netmask and
**       log file command-line options. Printing slightly prettier.
** 1.4 : Now works with NCSA, Plexus, and GN log files! Other small fixes,
**       rearrangement of time functions, deletion of buggy strptime().
**       Now can use previous output to lookup hosts.
** 1.5 : Fixed Plexus parsing bug, host table lookup fix, added date coverage.
** 1.6 : Host lookup faster, no more SYSV-specific time functions,
**       h_errno now declared, hanging problems possibly fixed.
** 1.7 : VMS compatible, fixed CERN date stomping, reports day in dailies,
**       added second netmask, MAXLINE bigger for GN, improved week code,
**       removed "offsite", better program flow, file request reporting,
**       date masking, requests/hour (not officialy released).
**
** Getsites 2.0 becomes Getstats 1.0!
**
** 1.0 : Full report name sort, name filtering, optional lookup,
**       more date options, domain reporting, fixed all analyze code,
**       hour reports and filtering, errors and logging, report combos,
**       request masks, mask lists, day mask, all flag, seconds reporting,
**       byte reporting, pretty graphs, removed IP field, domain lookup,
**       summaries, alias paths, gopher, purify'd.
** 1.1 : Added CGI, GMTOFFSET, LOGTZ switches, no using -i with VMS,
**       fixed NCSA tab log, no dirent code, added unique domains, fixed
**       toplines, convtoyearsecs, "-ip", Gopher root, added "-dr",
**       ifndefs, static fixes, GN "Sent" and "HTTP", DEC UCX, common format.
** 1.2 : REPORTTYPELEN increased, NCSA null addresses, added HEAD and POST,
**       reports GN2 logs and MacHTTP, empty logs, graphs round up, EURODATE,
**       no activity fix, monthly report.
** Todo: The ability to add HTML to a statistics directory...
**       Gnuplot (X, Y) output? Report strings? Custom sort report?
**       Monthly stats? Arbitrary-sized numbers...
**       Option to display sizes in b, Kb, MB, or GB...
**       Build on previous stats? External configuration file?
**
** This code is freely distributable but cannot be sold by itself or in 
** conjunction with other items without express permission of the author.
*/
