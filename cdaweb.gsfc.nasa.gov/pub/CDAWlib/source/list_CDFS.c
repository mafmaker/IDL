/*$Author: kovalick $*/
/*$Date: 1999/06/24 19:55:51 $*/
/*$Header: /home/rumba/cdaweb/dev/control/RCS/list_CDFS.c,v 1.10 1999/06/24 19:55:51 kovalick Exp kovalick $*/
/*$Locker: kovalick $*/
/*$Revision: 1.10 $*/
/*---------------------------------------------------------------------------*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <ftw.h>
#include <errno.h>
#include <cdf.h>


FILE   *cdfs;
FILE   *logs;


/*  Handle CDFlib errors...                                  */
void errHandle (char label[], CDFstatus status)   {

  char *text;

  text = (char *) malloc (CDF_STATUSTEXT_LEN+1);
 
  if (status == 999)   
    strcpy (text, "Exit processing\n");
     
  else 
    CDFerror (status, text);

  fprintf(logs, "%s %s\n", label, text);
}



/*   Report an error if malloc doesn't work...                   */
void reportMallocError()  {

  int      status;
  char     label[CDF_STATUSTEXT_LEN+128];


  status = 999;
  strcpy (label, "ERROR allocating memory for data buffer:");
  errHandle (label, status);
  exit (status);
}


/*  Change logical source names from whatever to ALL CAPS...    */
char *allCAPS (char *string, int size)  {

  int  loop;
  char *STRING;

  STRING = (char *)  malloc (size);
  if (STRING == NULL)  reportMallocError;

  for (loop = 0; loop < size; loop++)  

    STRING[loop] = toupper (string[loop]);

  return (STRING);

}



/*   Get epoch time and date from the file in question...            */
double getZepoch (int recNumber)  {

  CDFstatus  status;
  int        CDF_stat = 0;
  double     epochData;



  status = CDFlib (SELECT_, zVAR_RECNUMBER_, recNumber,
		   GET_,    zVAR_DATA_,      &epochData,
		   NULL_);
  
  if (status != CDF_stat)  {

/*  If an error occurs, set epoch data to a bogus value    */
    epochData = -999.0;
  }

  return (epochData);  
}



/*  for each .cdf file, open, extract epoch data and logical source name...  */
int lookat_CDFS (char *fileName)  {

/*  programmer:  c. gallap,  hstx          date:  march 11, 1997     */

  CDFid      id;
  CDFstatus  status;
  int        CDF_stat = 0;
  char       label[CDF_STATUSTEXT_LEN+128];
  char       *DATASET_NAME;
  const int  mode = 1;
  const int  zero = 0;
  int        recNumber;
  char       *epoch;
  char       *Epoch;
  char       *EPOCH;
  char       error[] = {"ERROR\0"};
  char       eics[] = {"eics"};
  char       isis[] = {"isis"};
  double     beginEPOCH;
  double     endEPOCH;
  size_t     dataset_len;
  char       *temp, *temp3;
  char       *caps;
  long       n, datatype, num_vars;
  int        finished;
  char       var_name[CDF_VAR_NAME_LEN+1];
  char       *graphics_file;
  char       g_file[255];
  int        g_len, temp2, i;


/*  Get what would be the logical_source name from fileName     */


/*  Treat DE_EICS differently...                                */

  if (strstr (fileName, eics) != NULL)  {

    DATASET_NAME = (char *) malloc (11);
    if (DATASET_NAME == NULL)  reportMallocError;
    strcpy (DATASET_NAME, "DE_VS_EICS");

  }

/*  Treat ISIS differently...                                  */

  else if (strstr (fileName, isis) != NULL)  {

    temp = strrchr (fileName, '/');
    dataset_len = strlen(temp) - 23;

    caps = (char *) malloc (dataset_len +1);
    if (caps == NULL)  reportMallocError;
    /*TJK don't think this is needed    DATASET_NAME = (char *) malloc (dataset_len +1);
    if (DATASET_NAME == NULL)  reportMallocError; */
    strncpy (caps, ++temp, dataset_len);
    DATASET_NAME = allCAPS (caps, dataset_len);
    DATASET_NAME[dataset_len] = '\0';
  }

  else  { 
    
    temp = strrchr (fileName, '/');
    dataset_len = strlen(temp) - 18;

    caps = (char *) malloc (dataset_len +1);
    if (caps == NULL)  reportMallocError;
    /* TJK don't think this is needed    DATASET_NAME = (char *) malloc (dataset_len +1);
    if (DATASET_NAME == NULL)  reportMallocError; */
    strncpy (caps, ++temp, dataset_len);
    DATASET_NAME = allCAPS (caps, dataset_len);
    DATASET_NAME[dataset_len] = '\0';

  } 

/*  Open fileName in order to extract epoch data               */

  status = CDFlib (OPEN_, CDF_, fileName, &id,
		   NULL_);

  if (status != CDF_stat)   {
    strcpy (label, fileName);
    strcat (label, ">\n  ");
    errHandle (label, status);
    return(-1);
  }

  status = CDFlib (SELECT_, CDF_,              id,
		            CDF_zMODE_,        mode,
		   NULL_);

  if (status != CDF_stat)  {
        strcpy (label, fileName);
    strcat (label, ">error selecting id/mode>\n");
    errHandle (label, status);
    status = CDFclose (id);
    return(-1);
  }


  /*Look for a global attribute called POINTER_CDF, if found use the
    value of POINTER_CDF as the filename that gets written out to the
    CDF_list file - this is an addition to support graphics files in
    CDAWeb in addition to cdf files. */
	  
    status = CDFlib (SELECT_, ATTR_NAME_, "POINTER_CDF",
                                  gENTRY_, 0,
                         GET_,    gENTRY_NUMELEMS_, &g_len,
                         NULL_);

    if (status != CDF_stat) /* if POINTER_CDF doesn't exist*/ 
      g_len = 0;
    else {
      graphics_file = (char *) malloc (g_len+1);
      if (graphics_file == NULL)  
	reportMallocError;
      else 
	{ memset(graphics_file, 0, g_len+1); /*TJK had to add this in, 
					       otherwise graphics_file 
					       eventually gets corrupted*/
	  status = CDFlib (GET_,    gENTRY_DATA_, graphics_file,
			 NULL_);
	}

        if (status != CDF_stat)
	  g_len = 0;
	else 
	  {g_len = strlen(graphics_file);
	  /*	  printf ("graphics file from cdf = %s, size = %d\n",graphics_file,g_len);*/
	  }
    }

  /*Try finding the traditional variable named Epoch*/
    epoch = (char*) malloc (5);
    if (epoch == NULL)  reportMallocError;
    strcpy (epoch, "epoch");

    Epoch = (char*) malloc (5);
    if (Epoch == NULL)  reportMallocError;
    strcpy (Epoch, "Epoch");

    EPOCH = (char*) malloc (5);
    if (EPOCH == NULL)  reportMallocError;
    strcpy (EPOCH, "EPOCH");

  status = CDFlib (SELECT_, zVAR_NAME_,   epoch,
		   GET_,    zVAR_MAXREC_, &recNumber,
		   NULL_);
		   
  if (status != CDF_stat) {  
    
    status = CDFlib (SELECT_, zVAR_NAME_,   Epoch,
		     GET_,    zVAR_MAXREC_, &recNumber,
		     NULL_);
  }

  if (status != CDF_stat) {  
    
    status = CDFlib (SELECT_, zVAR_NAME_,   EPOCH,
		     GET_,    zVAR_MAXREC_, &recNumber,
		     NULL_);
  }

  /* if the epoch variable doesn't exist, look for the 1st
     variable that has the datatype of CDF_EPOCH and
     use it - TJK added this on 4/7/1998 takes care of 
     the equator-s CDFs as well as timas h0, etc. */

  if (status != CDF_stat)  {
    status = CDFlib(GET_, CDF_NUMzVARS_, &num_vars,
		    NULL_);
    finished = FALSE;
    n = 0;
    while (n <= num_vars-1 && !finished) {
      status = CDFlib (SELECT_, zVAR_, n,
		       GET_,    zVAR_DATATYPE_, &datatype,
		       NULL_);
      if (datatype == CDF_EPOCH) {
	status = CDFlib (GET_,    zVAR_MAXREC_, &recNumber,
	    	         GET_,    zVAR_NAME_, var_name,
			 NULL_);
	finished = TRUE;
	fprintf(logs,"Using %s as epoch variable, index = %d.\n",var_name,n);
      } /*endif CDF_EPOCH datatype found*/
     n = n+1;

    } /*end while*/
  } /*end if*/


  if (status != CDF_stat)  {
    strcpy (label, "Fail while getting max record number. ");
    strcat (label, "Selected variable name ");
    strcat (label, EPOCH);
    errHandle (label, status);
    status = CDFclose (id);
    return(-1);
  }


  beginEPOCH =  getZepoch (zero);
  endEPOCH = getZepoch (recNumber);

  if (g_len > 0) {
        for (i = 0; i < 254; i++)  g_file[i] = NULL; /* initialize*/

    temp = strrchr (fileName, '/'); /*find the string following the last */
    temp2 = strlen(fileName) - (strlen(temp)-1);/* length of the directory portion of the file name*/
    strncpy(g_file, fileName, temp2);
    strncat(g_file, graphics_file, g_len-3); /*TJK for right now don't copy the extension as is from the sfdu*/
    strncat(g_file, "mpg", 3); /* hardcode the ending to be "mpg" */
    g_file[temp2+g_len] = '\0';
    strcpy(fileName, g_file);
    free(graphics_file);
    }


  if (beginEPOCH > 0.0e0 && endEPOCH > 0.0e0)
    fprintf (cdfs, "%s %22.16Le %22.16Le %s\n", DATASET_NAME, beginEPOCH, endEPOCH,
	     fileName);

  else fprintf (logs, "Invalid EPOCH data in file %s.  BeginEPOCH> %22.16Le  endEPOCH> %22.16Le\n",
		fileName, beginEPOCH, endEPOCH);


  free(DATASET_NAME);
  status = CDFclose (id);

  return(0);

} 


int pickout_CDFS (char *fileName, struct stat *tree_stat, int code,
		  struct FTW *ftw_stat)  {

  char   cdfSuffix[] = {".cdf"};
  char   master[] = {"MASTER"};
  int    check = 0;

  if (code == FTW_D)  ;

  /*  name found is a directory, move on...  */

  else if (code == FTW_DP)  
    fprintf (logs, "%s has already been processed.\n", fileName);

  else if (code == FTW_DNR ) 
  
    fprintf (logs, "%s is a directory that can't be read.\n", fileName);

  else if (code == FTW_F)  {

    if (strstr (fileName, cdfSuffix) != NULL &&
	strstr (fileName, master) == NULL)  {

      /*  Continue to process file if it's a cdf file, but not a master... */

      check = lookat_CDFS (fileName);    
      if (check != 0) fprintf (logs, "CDF error in %s\n", fileName);

    }
  }


  else if (code == FTW_SL) 

    /*  process links to other directories...  */

    check = ftw (fileName, pickout_CDFS);


  else if (code == FTW_NS) 
    fprintf (logs, "%s is a file where STAT function failed.\n", fileName);

  else fprintf (logs, "%s is something else.\n", fileName);

  return (0); 
}


main ()  {

  int     check;
  size_t  path_size;
  char    *CDF_list;
  char    *LOG_file;


  /*  Open log and CDF_list files in the home directory  */

  path_size = strlen(getenv("META"));

  CDF_list = (char *) malloc (path_size + 10);
  if (CDF_list == NULL)  reportMallocError;

  LOG_file = (char *) malloc (path_size + 9);
  if (LOG_file == NULL)  reportMallocError;

  strcpy (CDF_list, getenv("META"));
  strcpy (LOG_file, getenv("META"));

  strcat (CDF_list, "/CDF_list");
  strcat (LOG_file, "/CDF_log");

  cdfs   = fopen (CDF_list, "w");
  logs = fopen (LOG_file, "w");

  fprintf (logs, "Writing CDF list to %s\n", CDF_list);
  fprintf (logs, "Writing CDF list processing messages to %s\n", LOG_file);

  /*  Begin searching TOP directory for all .cdf files...  */

  check = ftw (getenv("TOP"), pickout_CDFS);

  fclose (cdfs);
  fclose (logs);

}




