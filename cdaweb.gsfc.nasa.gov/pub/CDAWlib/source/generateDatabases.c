/*$Author: kovalick $*/
/*$Date: 1999/09/21 16:14:43 $*/
/*$Header: /home/rumba/cdaweb/dev/control/RCS/generateDatabases.c,v 1.14 1999/09/21 16:14:43 kovalick Exp kovalick $*/
/*$Locker: kovalick $*/
/*$Revision: 1.14 $*/
/*---------------------------------------------------------------------------*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <libgen.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <ftw.h>
#include <errno.h>
#include <cdf.h>


FILE   *cdfs;
FILE   *logged;
FILE   *database;
FILE   *gaps;
FILE   *input;


int    master_counter;

enum flag {true, false};

typedef struct  {
  char  *MASTERCDF;
  char  *DATASET;
  char  *SOURCE_NAME;
  char  *DESCRIPTOR;
  char  *DATA_TYPE;
  char  *PI_NAME;
  char  *PI_AFFILIATION;
  char  *MISSION_GROUP;
  char  *INSTRUMENT_TYPE;
  char  *DATASET_LABEL;
  char  *LINK_TEXT1;
  char  *LINK_TITLE1;
  char  *HTTP_LINK1;
  char  *LINK_TEXT2;
  char  *LINK_TITLE2;
  char  *HTTP_LINK2;
  char  *LINK_TEXT3;
  char  *LINK_TITLE3;
  char  *HTTP_LINK3;
  char  *LINK_TEXT4;
  char  *LINK_TITLE4;
  char  *HTTP_LINK4;
  char  *LINK_TEXT5;
  char  *LINK_TITLE5;
  char  *HTTP_LINK5;
}  gDATA;

gDATA  *global_data[1000];


typedef struct  {
  int   NUMBER_VARIABLES;
  char  *VARIABLE_NAMES;
}  vDATA;

vDATA  *variable_data[1000];


struct cdf_d {

  struct cdf_d *right;
  struct cdf_d *left;
  struct cdf_t *time_pointer;
  int          counter;
  char         *dataset;
  double       first;
  double       last;
};


struct cdf_t {

  struct cdf_t *right;
  struct cdf_t *left;
  double       begin;
  double       end;
  char         *name;
};


static struct cdf_d *root = NULL;


/*  Handle CDFlib or report malloc errors...    */
void errHandle (char *label, CDFstatus status)   {

  char *text;

  text = (char *) malloc (CDF_STATUSTEXT_LEN+1);
  if (text == NULL) {
    fprintf (logged, "ERROR allocating text buffer to report other errors.\n");
    exit (status);
  }
 
  if (status == 999)   {

    strcpy (text, "Exit processing\n");
    fprintf (logged, "ERROR: %s %s\n", label, text);
    exit (status);
  }
   
  else  {
 
    CDFerror (status, text);
    fprintf(logged, "ERROR: %s %s\n", label, text);
  }

  free(text);
}




/*   Report an error if malloc doesn't work...  */
void reportMallocError()  {

  int      status;
  char     label[CDF_STATUSTEXT_LEN+1];

/*  Called whenever a malloc error occurs.  Processing will abort when this
      happens...  */

  status = 999;
  strcpy (label, "ERROR allocating memory for data buffer:");
  errHandle (label, status);
  exit (status);
}



/*  Change logical source names from whatever to ALL CAPS...    */
char *allCAPS (char *string, int size)  {

  int  loop;
  char *STRING;

  STRING = (char *)  malloc (size+1);
  if (STRING == NULL)  reportMallocError;

  for (loop = 0; loop < size; loop++)  STRING[loop] = toupper (string[loop]);

  STRING[size] = '\0';

  return (STRING);
}


/*  Get variable names from MASTER cdf files...                        */
int get_VARIABLEnames (char *fileName, int numVars)  {

/*  programmer:  c. gallap, hstx           date:  February 14, 1997    */

  const int    CDF_stat = 0;
  const int    null = 0;
  CDFstatus    status;
  CDFstatus    statusDK;
  CDFstatus    statusCD;
  CDFstatus    statusVT;
  char         *variableName;
  char         *catDesc;
  char         *dictKey;
  char         *varType;
  int          varN;
  int          zNumElems;
  int          varKount;
  long int     rec_vary;
  size_t       string_length = 0;
  size_t       strlenCD;
  size_t       strlenDK;
  const char   line_feed[] = {"\n"};
  char         *data;
  char         *temp_string;
  char         end_of_vars[] = {"\0"};


  variableName = (char *) malloc (CDF_VAR_NAME_LEN + 2);
  if (variableName == NULL)  reportMallocError;

  temp_string = (char *) malloc (CDF_VAR_NAME_LEN + 2);
  if (temp_string == NULL)  reportMallocError;


/*  Main loop - get all variable names...  */

  varKount = 0;

  for (varN = 0; varN < numVars; varN++)  {

    status = CDFlib (SELECT_, zVAR_, varN,
		     NULL_);

    if (status == CDF_stat)   {

      status = CDFlib (GET_, zVAR_RECVARY_, &rec_vary,
		       NULL_);


/*  Variable must vary wrt time in order to plot...  */

      if (status == CDF_stat && rec_vary == -1)  {


/*  Look for VAR_TYPE = "DATA"... */

	statusVT = CDFlib (SELECT_, ATTR_NAME_, "VAR_TYPE",
			   NULL_);
    
	if (statusVT != CDF_stat)  
	  statusVT = CDFlib (SELECT_, ATTR_NAME_, "var_type",
			     NULL_);

	if (statusVT != CDF_stat)  
	  statusVT = CDFlib (SELECT_, ATTR_NAME_, "Var_type",
			     NULL_);

	if (statusVT == CDF_stat)  
	  statusVT = CDFlib (CONFIRM_, zENTRY_EXISTENCE_, varN,
			     NULL_);

	if (statusVT == CDF_stat)  {

	  status = CDFlib (SELECT_, zENTRY_, varN,
			   GET_, zENTRY_NUMELEMS_, &zNumElems,
			   NULL_);

	  varType = (char *) malloc (zNumElems+1);	
	  if (varType == NULL)  reportMallocError;

	  data = (char *) malloc (zNumElems+1);
	  if (data == NULL)  reportMallocError;
	  
	  status = CDFlib (GET_, zENTRY_DATA_, varType,
			   NULL_);
	  
	  if (status == CDF_stat)  data = allCAPS(varType, zNumElems);
	}

/*  Else, if not specified, assume vartype is "DATA"...   */

	else  strcpy (data, "DATA");
	
	if ( strcmp (data, "DATA") == null)  {

	  status = CDFlib (GET_, zVAR_NAME_, variableName,
			   NULL_);

	  if (status == CDF_stat)  {

	    ++varKount;
	    strcat (variableName, "\0");

/*  Get DICT_KEY info, if it exists...  */

	    statusDK = CDFlib (SELECT_, ATTR_NAME_, "DICT_KEY",
			       NULL_);
	    if (statusDK != CDF_stat)  
	      statusDK = CDFlib (SELECT_, ATTR_NAME_, "dict_key",
				 NULL_);
	    if (statusDK != CDF_stat)  
	      statusDK = CDFlib (SELECT_, ATTR_NAME_, "Dict_key",
				 NULL_);
	    if (statusDK == CDF_stat)  
	      statusDK = CDFlib (CONFIRM_, zENTRY_EXISTENCE_, varN,
				 NULL_);

	    strlenDK = 0;
	    if (statusDK == CDF_stat)  {
	
	      status = CDFlib (SELECT_, zENTRY_, varN,
			       GET_, zENTRY_NUMELEMS_, &zNumElems,
			       NULL_);
		
	      if (status == CDF_stat)  {
	  
		dictKey = (char *) malloc (zNumElems + 1);	
		if (dictKey == NULL)  reportMallocError;

		status = CDFlib (GET_, zENTRY_DATA_, dictKey,
				 NULL_);
		
		if (status == CDF_stat) {
		  dictKey[zNumElems] = '\0';      
		  strlenDK = strlen (dictKey);
		}
	      }
	    }
	 

/*  Get catalog description, if it's there...   */

	    statusCD = CDFlib (SELECT_, ATTR_NAME_, "CATDESC",
			       NULL_);
	    if (statusCD != CDF_stat)  
	      statusCD = CDFlib (SELECT_, ATTR_NAME_, "catdesc",
				 NULL_);
	    if (statusCD != CDF_stat)  
	      statusCD = CDFlib (SELECT_, ATTR_NAME_, "Catdesc",
				 NULL_);
	    if (statusCD == CDF_stat)  
	      statusCD = CDFlib (CONFIRM_, zENTRY_EXISTENCE_, varN,
				 NULL_);

	    strlenCD = 0;
	    if (statusCD == CDF_stat)  {
	      
	      status = CDFlib (SELECT_, zENTRY_, varN,
			       GET_, zENTRY_NUMELEMS_, &zNumElems,
			       NULL_);
	
	      if (status == CDF_stat)  {
	  
		catDesc = (char *) malloc (zNumElems +1);
		if (catDesc == NULL)  reportMallocError;

		status = CDFlib (GET_, zENTRY_DATA_, catDesc,
				 NULL_);

		if (status == CDF_stat) {
		  catDesc[zNumElems] = '\0';
		  strlenCD = strlen (catDesc);
		}
	      }
	    }

	    string_length = string_length + strlen(variableName) + strlenDK 
	      + strlenCD + 4;

	    temp_string = (char *) realloc (temp_string, string_length);
	    if (temp_string == NULL)  reportMallocError;

	    if (varKount == 1) strcpy (temp_string, variableName);
	      
	    else strcat (temp_string, variableName);
	  
	    strcat (temp_string, "|");
	    
	    if (strlenDK > 2)  {
	      strcat (temp_string, dictKey);
	      free (dictKey);
	    }

	    strcat (temp_string, "|");

	    if (strlenCD > 2)  {
	      strcat (temp_string, catDesc);
	      free (catDesc);
	    }
	      
	    strcat (temp_string, line_feed);
	 
	  }

	  else fprintf (logged, 
			"ERROR:  Could not retrieve variable name for var %i\n"
			,  varN);

	}

/*	Variable not DATA type   */

	/*TJK take these out since they're already freed
	free (data);
	free (varType);
	*/    
      }

/*	Variable does not vary with time   */   
    }

    else fprintf (logged, "ERROR: Could not select variable %i\n", varN);


  }   /*  End main loop  */

  if (varKount != 0)  {

    variable_data[master_counter]->VARIABLE_NAMES = 
      (char *) malloc(strlen(temp_string)+1);
    if (variable_data[master_counter]->VARIABLE_NAMES == NULL)  
      reportMallocError;

    strcpy (variable_data[master_counter]->VARIABLE_NAMES, temp_string);
    strcat (variable_data[master_counter]->VARIABLE_NAMES, end_of_vars);

    free (temp_string);

  }

  free (variableName);
  return (varKount);
}


/*  For a given dataset name, print all cdfs that belong to that dataset...  */
void print_time (struct cdf_t *first, char dataset[], int number_cdfs, 
		 double start, double end, int i, 
		 enum flag header)  {

/*  Date  July 24, 1997            programmer  c. gallap              */


  int  byear, bmonth, bday, bhour, bminute, bsec;
  int  eyear, emonth, eday, ehour, eminute, esec;
  int  mili, space;


  if (first == NULL)  return;

/*  Only print global information the first time through...   */
  if (header == false)  {

    if (i < 0)  i = makeMaster (first->name);

    fprintf (database, "DATASET>%s\n", global_data[i]->DATASET);
    fprintf (database, "SOURCE_NAME>%s\n", 
	     global_data[i]->SOURCE_NAME);
    fprintf (database, "DESCRIPTOR>%s\n", 
	     global_data[i]->DESCRIPTOR);
    fprintf (database, "DATA_TYPE>%s\n", 
	     global_data[i]->DATA_TYPE);

    fprintf (database, "PI_NAME>");
    if (global_data[i]->PI_NAME != NULL)
      fprintf (database, "%s\n", global_data[i]->PI_NAME);
    else fprintf (database, "\n");

    fprintf (database, "PI_AFFILIATION>"); 
    if (global_data[i]->PI_AFFILIATION != NULL)
      fprintf (database, "%s\n", global_data[i]->PI_AFFILIATION);
    else fprintf (database, "\n");

    fprintf (database, "MISSION_GROUP>%s\n", 
	     global_data[i]->MISSION_GROUP);
    fprintf (database, "INSTRUMENT_TYPE>%s\n", 
	     global_data[i]->INSTRUMENT_TYPE);
    fprintf (database, "DATASET_LABEL>%s",  
	     global_data[i]->DATASET_LABEL);
    if (global_data[i]->PI_NAME != NULL) 
      fprintf (database, " - %s", global_data[i]->PI_NAME);
    if (global_data[i]->PI_AFFILIATION != NULL)
      fprintf (database, " (%s)", global_data[i]->PI_AFFILIATION);
    fprintf (database, "\n");

    EPOCHbreakdown  (start,
		     &byear,    &bmonth,
		     &bday,     &bhour,
		     &bminute,  &bsec,
		     &mili);

    EPOCHbreakdown  (end,
		     &eyear,    &emonth,
		     &eday,     &ehour,
		     &eminute,  &esec,
		     &mili);
    fprintf (database,
	     "TIME_RANGE>%04li/%02li/%02li %02li:%02li:%02li>%04li/%02li/%02li %02li:%02li:%02li\n",
	     byear, bmonth, bday, bhour, bminute, bsec,
	     eyear, emonth, eday, ehour, eminute, esec);
    if (global_data[i]->MASTERCDF != NULL)
      fprintf (database, "MASTERCDF>%s\n", 
	       global_data[i]->MASTERCDF); 
    /*TJK 11/29/99 added three more "global attributes" so that alternate sources can 
      be included on the CDAWeb pages*/
    if (global_data[i]->LINK_TEXT1 != NULL)
      fprintf (database, "LINK1>%s|%s|%s\n",global_data[i]->LINK_TEXT1,global_data[i]->LINK_TITLE1,global_data[i]->HTTP_LINK1);
    if (global_data[i]->LINK_TEXT2 != NULL)
      fprintf (database, "LINK2>%s|%s|%s\n",global_data[i]->LINK_TEXT2,global_data[i]->LINK_TITLE2,global_data[i]->HTTP_LINK2);
    if (global_data[i]->LINK_TEXT3 != NULL)
      fprintf (database, "LINK3>%s|%s|%s\n",global_data[i]->LINK_TEXT3,global_data[i]->LINK_TITLE3,global_data[i]->HTTP_LINK3);
    if (global_data[i]->LINK_TEXT4 != NULL)
      fprintf (database, "LINK4>%s|%s|%s\n",global_data[i]->LINK_TEXT4,global_data[i]->LINK_TITLE4,global_data[i]->HTTP_LINK4);
    if (global_data[i]->LINK_TEXT5 != NULL)
      fprintf (database, "LINK5>%s|%s|%s\n",global_data[i]->LINK_TEXT5,global_data[i]->LINK_TITLE5,global_data[i]->HTTP_LINK5);

    fprintf (database, "!VARIABLES=%i\n", 
	     variable_data[i]->NUMBER_VARIABLES);
    if (variable_data[i]->NUMBER_VARIABLES > 0)
      fprintf (database, "%s", variable_data[i]->VARIABLE_NAMES);

    fprintf (database, "!CDFS=%i\n", number_cdfs);


/*  Print to log...  */

    fprintf (logged, "\nDATASET>%s\n", global_data[i]->DATASET);
    /*    fprintf (logged, "SOURCE_NAME>%s\n", global_data[i]->SOURCE_NAME);
    fprintf (logged, "DESCRIPTOR>%s\n", global_data[i]->DESCRIPTOR);
    fprintf (logged, "DATA_TYPE>%s\n", global_data[i]->DATA_TYPE);
    fprintf (logged, "PI_NAME>%s\n", global_data[i]->PI_NAME);
    fprintf (logged, "PI_AFFILIATION>%s\n", global_data[i]->PI_AFFILIATION);
    fprintf (logged, "MISSION_GROUP>%s\n", global_data[i]->MISSION_GROUP);
    fprintf (logged, "INSTRUMENT_TYPE>%s\n", global_data[i]->INSTRUMENT_TYPE);
    fprintf (logged, "DATASET_LABEL>%s\n", global_data[i]->DATASET_LABEL);
    */    
    fprintf (logged,
	     "TIME_RANGE>%04li/%02li/%02li %02li:%02li:%02li>%04li/%02li/%02li %02li:%02li:%02li\n",
	     byear, bmonth, bday, bhour, bminute, bsec,
	     eyear, emonth, eday, ehour, eminute, esec);
    fprintf (logged, "MASTERCDF>%s\n", global_data[i]->MASTERCDF);
    if (global_data[i]->LINK_TEXT1 != NULL)
      fprintf (logged, "LINK1>%s|%s|%s\n",global_data[i]->LINK_TEXT1,global_data[i]->LINK_TITLE1,global_data[i]->HTTP_LINK1);
    if (global_data[i]->LINK_TEXT2 != NULL)
      fprintf (logged, "LINK2>%s|%s|%s\n",global_data[i]->LINK_TEXT2,global_data[i]->LINK_TITLE2,global_data[i]->HTTP_LINK2);    
    if (global_data[i]->LINK_TEXT3 != NULL)
      fprintf (logged, "LINK3>%s|%s|%s\n",global_data[i]->LINK_TEXT3,global_data[i]->LINK_TITLE3,global_data[i]->HTTP_LINK3);
    if (global_data[i]->LINK_TEXT4 != NULL)
      fprintf (logged, "LINK4>%s|%s|%s\n",global_data[i]->LINK_TEXT4,global_data[i]->LINK_TITLE4,global_data[i]->HTTP_LINK4);
    if (global_data[i]->LINK_TEXT5 != NULL)
      fprintf (logged, "LINK5>%s|%s|%s\n",global_data[i]->LINK_TEXT5,global_data[i]->LINK_TITLE5,global_data[i]->HTTP_LINK5);

    fprintf (logged, "!VARIABLES=%i\n", variable_data[i]->NUMBER_VARIABLES);
    fprintf (logged, "!CDFS=%i\n", number_cdfs);

    header = true;

  }


/*  Begin descending though cdf tree and print...   */
  print_time (first->left, dataset, number_cdfs, start, end, i, 
	      header);

  EPOCHbreakdown  (first->begin,
		   &byear,    &bmonth,
		   &bday,     &bhour,
		   &bminute,  &bsec,
		   &mili);

  EPOCHbreakdown  (first->end,
		   &eyear,    &emonth,
		   &eday,     &ehour,
		   &eminute,  &esec,
		   &mili);
  /*TJK need to print to log files the first->name in order to debug
    ac_k0_mfi problem. */

  fprintf (database,
	   "%s>%04li/%02li/%02li %02li:%02li:%02li>%04li/%02li/%02li %02li:%02li:%02li\n",
	   first->name, byear, bmonth, bday, bhour, bminute, bsec,
	                eyear, emonth, eday, ehour, eminute, esec);

  print_time (first->right, dataset, number_cdfs, start, end, i, 
	      header);

}


/*  Descend through dataset tree and print...   */
void print_dataset (struct cdf_d *top, int master_number, char dataset[])  {

/*   date  July 24, 1997          programmer  c. gallap       */


  int       result;
  enum flag header;

  if (top == NULL)  return;

  print_dataset (top->left, master_number, dataset);


/*  Match incoming dataset name to the correct node in the tree...   */
  result = strcmp (dataset, top->dataset);

  if (result == 0)  {

    header = false;

/*  When a match is found, begin descending through cdf file name tree to
    print...   */
    print_time (top->time_pointer, top->dataset, top->counter, 
		top->first, top->last, master_number, header);
   
    fprintf (database, "!!!\n");

    return;
  }

  print_dataset (top->right, master_number, dataset);


}


/*  Sort through cdf file list and save results in a binary tree...  */
void tree_on_time
(struct cdf_t **time, double begin, double end, char name[], int *count,
 double *first, double *last)  {

/*  date   July 24, 1997            programmer  c. gallap   */


  int   dup_flag;
  int   len;

  if ((*time) == NULL)  {

    (*time) = (struct cdf_t *) malloc (sizeof (struct cdf_t));
    if ((*time) == NULL)  reportMallocError;

    (*time)->left  = NULL;
    (*time)->right = NULL;

    (*time)->begin = begin;
    (*time)->end   = end;

    (*time)->name  = (char *) malloc (strlen(name)+1);/*TJK added one*/
    if ( (*time)->name == NULL)  reportMallocError;

    strcpy ((*time)->name, name);
    (*count)++;

  }


/*  Save the earliest and lastest data times for this dataset name...   */
  if (begin < *first)  *first = begin;
  if (end > *last)  *last = end;


/*  if ( (*time)->begin == begin) TJK  {*/  /*  Examine for duplicates...   */

/*  If there is an exact duplication of filename, then node was just created...  */
    dup_flag = strcmp ( (*time)->name, name);
    if (dup_flag == 0) return;

    /*now do the comparison on the strings to see if they are for the same day -
      by comparing the characters in the file name down to the version */
    len = strlen(name);
    dup_flag = strncmp ( (*time)->name, name, len-8);

    if (dup_flag == 0 )/*TJK removed on 6/1/99 && (begin <= (*time)->end) && (end <= (*time)->end))*/  {

/*  If the filenames are the same up to the version number, record possible overlaps...   */

      /*TJK debug prints      printf("name = %s\n, timename = %s\n",name, (*time)->name);
      printf("begin = %22.16Le, end = %22.16Le\n",begin, end);
      printf("timebegin = %22.16Le, timeend = %22.16Le\n",(*time)->begin, (*time)->end); 
      printf("OVERLAP at:%s\n       and:%s\n", (*time)->name, name); */

      fprintf (gaps, "OVERLAP at:%s\n       and:%s\n", (*time)->name, name);

      /* save just the replacement file so that it can be written to the db files*/
      (*time)->begin = begin;
      (*time)->end   = end;
      strcpy ((*time)->name, name);
      return;

    }

  if ( (*time)->begin < begin)  
    tree_on_time ( &(*time)->right, begin, end, name, count, first, last);
  
  else 
    tree_on_time ( &(*time)->left, begin, end, name, count, first, last);

}


/*  Sort through dataset names and store results in a binary tree.  This 
    tree contains a pointer to the cdf list binary tree...           */
void tree_on_dataset 
(struct cdf_d **cdf, char dataset[], double begin, double end, char name[])  {

/*  date  July 24, 1997          programmer   c. gallap          */


  int  result;
  int  count;
  
  if ((*cdf) == NULL)  {

    (*cdf) = (struct cdf_d *) malloc (sizeof (struct cdf_d));
    if ((*cdf) == NULL)  reportMallocError;

    (*cdf)->left = NULL;
    (*cdf)->right = NULL;
    (*cdf)->time_pointer = NULL;

    (*cdf)->dataset = (char *) malloc (strlen(dataset));
    if ( (*cdf)->dataset == NULL)  reportMallocError;

    strcpy ((*cdf)->dataset, dataset);
    (*cdf)->counter = 0;

    (*cdf)->first = 8*10e13;
    (*cdf)->last = 0;

  }


  result = strcmp ((*cdf)->dataset, dataset);

  if (result == 0)     /*   Process by time   */  

    tree_on_time ( &(*cdf)->time_pointer, begin, end, name, 
		   &(*cdf)->counter, &(*cdf)->first, &(*cdf)->last);


  else if (result < 0) 
    tree_on_dataset (&(*cdf)->right, dataset, begin, end, name);


  else tree_on_dataset (&(*cdf)->left, dataset, begin, end, name);


}



/*  Extract global data from the master cdf file...                  */
CDFstatus extract_globalDATA (char *fileName, const int numAttrs)  {

/*  programmer:  c. gallap                    date:  March 4, 1997   */

/*  variable declarations                                            */

  const int        null = 0;
  const CDFstatus  CDF_stat = 0;
  CDFstatus        status;
  const int        mode = 1;
  const int        SUCCESS = 0;
  char             attrName[CDF_ATTR_NAME_LEN+1];
  int              attrScope;
  int              attrN;
  int              entryN;
  int              dataType;
  int              numElems;
  int              space;
  int              size;
  char             *ATTRNAME;
  int              numGentries;
  CDFstatus        returnCODE;
  char             *temp;
  char             *caps;
  const char       masterstring[] = {"0MASTERS"};
  size_t           dataset_len;
  int              max_entries;


/*  Null out pointers before starting (can cause problems if you don't)  */

  global_data[master_counter]->DATASET_LABEL = NULL;
  global_data[master_counter]->SOURCE_NAME = NULL;
  global_data[master_counter]->DESCRIPTOR = NULL;
  global_data[master_counter]->DATA_TYPE = NULL;
  global_data[master_counter]->PI_NAME = NULL;
  global_data[master_counter]->PI_AFFILIATION = NULL;
  global_data[master_counter]->MISSION_GROUP = NULL;
  global_data[master_counter]->INSTRUMENT_TYPE = NULL;
  global_data[master_counter]->DATASET_LABEL = NULL;
  global_data[master_counter]->MASTERCDF = NULL;
  global_data[master_counter]->LINK_TEXT1 = NULL;
  global_data[master_counter]->LINK_TITLE1 = NULL;
  global_data[master_counter]->HTTP_LINK1 = NULL;
  global_data[master_counter]->LINK_TEXT2 = NULL;
  global_data[master_counter]->LINK_TITLE2 = NULL;
  global_data[master_counter]->HTTP_LINK2 = NULL;
  global_data[master_counter]->LINK_TEXT3 = NULL;
  global_data[master_counter]->LINK_TITLE3 = NULL;
  global_data[master_counter]->HTTP_LINK3 = NULL;
  global_data[master_counter]->LINK_TEXT4 = NULL;
  global_data[master_counter]->LINK_TITLE4 = NULL;
  global_data[master_counter]->HTTP_LINK4 = NULL;
  global_data[master_counter]->LINK_TEXT5 = NULL;
  global_data[master_counter]->LINK_TITLE5 = NULL;
  global_data[master_counter]->HTTP_LINK5 = NULL;
  

  for (attrN = 0; attrN < numAttrs;  attrN++)    {

    status = CDFlib (SELECT_, ATTR_, attrN,
		     GET_,    ATTR_SCOPE_, &attrScope,
		     NULL_);

    if (status != CDF_stat)  {
      errHandle (fileName, status);
      return (status);
    }

    if (attrScope == GLOBAL_SCOPE)  {/* If scope is global, look at the entry*/

      status = CDFlib (GET_, ATTR_NAME_, attrName,
		       NULL_);
 
      if (status == CDF_stat)  {

	ATTRNAME = (char *) malloc (CDF_ATTR_NAME_LEN+1);
	if (ATTRNAME == NULL)  reportMallocError;

	ATTRNAME = allCAPS (attrName, strlen(attrName)+1);


	if (strcmp (ATTRNAME , "SOURCE_NAME") == null)  {
	  
	  entryN = 0;
	  
	  status = CDFlib (SELECT_, gENTRY_,          entryN,
			   GET_,    gENTRY_NUMELEMS_, &numElems,
			   NULL_);

	  if (status == CDF_stat)  {

	    global_data[master_counter]->SOURCE_NAME = 
	      (char *) malloc (numElems +1);
	    if (global_data[master_counter]->SOURCE_NAME == NULL)  
	      reportMallocError;

	    status = 
	      CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->SOURCE_NAME,
		      NULL_);

	    if (status == CDF_stat) 

	      global_data[master_counter]->SOURCE_NAME[numElems] = '\0';
	  }
	}

	else if (strcmp (ATTRNAME , "DESCRIPTOR") == null)  {

	  entryN = 0;

	  status = CDFlib (SELECT_, gENTRY_,          entryN,
			   GET_,    gENTRY_NUMELEMS_, &numElems,
			   NULL_);

	  if (status == CDF_stat)  {
	    
	    global_data[master_counter]->DESCRIPTOR = 
	      (char *) malloc (numElems +1);
	    if (global_data[master_counter]->DESCRIPTOR == NULL)  
	      reportMallocError;

	    status = 
	      CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->DESCRIPTOR,
		      NULL_);

	    if (status == CDF_stat)
	      global_data[master_counter]->DESCRIPTOR[numElems] = '\0';
	    
	  }
	}

	else if (strcmp (ATTRNAME , "DATA_TYPE") == null)  {

	  entryN = 0;

	  status = CDFlib (SELECT_, gENTRY_,          entryN,
			   GET_,    gENTRY_NUMELEMS_, &numElems,
			   NULL_);

	  if (status == CDF_stat)  {

	    global_data[master_counter]->DATA_TYPE = 
	      (char *) malloc (numElems +1);
	    if (global_data[master_counter]->DATA_TYPE == NULL)  
	      reportMallocError;

	    status = CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->DATA_TYPE,
			     NULL_);
	    
	    if (status == CDF_stat)  {
	      global_data[master_counter]->DATA_TYPE[numElems] = '\0';

	    }
	  }
	}

	else if (strcmp (ATTRNAME , "PI_NAME") == null)  {
	  
	  entryN = 0;

	  status = CDFlib (SELECT_, gENTRY_,          entryN,
			   GET_,    gENTRY_NUMELEMS_, &numElems,
			   NULL_);

	  if (status == CDF_stat  &&  numElems > 2)  {
	
	    global_data[master_counter]->PI_NAME = (char *) malloc (numElems +1);
	    if (global_data[master_counter]->PI_NAME == NULL)  reportMallocError;

	    status = CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->PI_NAME,
			     NULL_);

	    if (status == CDF_stat)  {
	      global_data[master_counter]->PI_NAME[numElems] = '\0';

	    }
	  }
	}

	else if (strcmp (ATTRNAME , "PI_AFFILIATION") == null)  {
	  
	  entryN = 0;
	
	  status = CDFlib (SELECT_, gENTRY_,          entryN,
			   GET_,    gENTRY_NUMELEMS_, &numElems,
			   NULL_);

	  if (status == CDF_stat  && numElems > 2)  {
	    
	    global_data[master_counter]->PI_AFFILIATION = 
	      (char *) malloc (numElems +1);
	    if (global_data[master_counter]->PI_AFFILIATION == NULL)  
	      reportMallocError;

	    status = 
	      CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->PI_AFFILIATION,
		      NULL_);

	    if (status == CDF_stat)  {
	      global_data[master_counter]->PI_AFFILIATION[numElems] = '\0';

	    }
	  }
	}

	else if (strcmp (ATTRNAME , "MISSION_GROUP") == null)  {

	  entryN = 0;

	  status = CDFlib (SELECT_, gENTRY_,          entryN,
			   GET_,    gENTRY_NUMELEMS_, &numElems,
			   NULL_);

	  if (status == CDF_stat)  {

	    global_data[master_counter]->MISSION_GROUP = 
	      (char *) malloc (numElems +1);
	    if (global_data[master_counter]->MISSION_GROUP == NULL)  
	      reportMallocError;

	    status = 
	      CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->MISSION_GROUP,
		      NULL_);

/*  check to see if last character is a space  */

	    if (status == CDF_stat)  {

	      space = 
		isspace(global_data[master_counter]->MISSION_GROUP[numElems-1]);

	      if (space != 0) 
		global_data[master_counter]->MISSION_GROUP[numElems-1] = '\0';

	      else global_data[master_counter]->MISSION_GROUP[numElems] ='\0';
	      
	    }
	  }
	}

	else if (strcmp (ATTRNAME , "INSTRUMENT_TYPE") == null)  {

	  entryN = 0;

	  status = CDFlib (SELECT_, gENTRY_,          entryN,
			   GET_,    gENTRY_NUMELEMS_, &numElems,
			   NULL_);

	  if (status == CDF_stat)  {

	    global_data[master_counter]->INSTRUMENT_TYPE = 
	      (char *) malloc (numElems +1);
	    if (global_data[master_counter]->INSTRUMENT_TYPE == NULL)  
	      reportMallocError;

	    status = 
	      CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->INSTRUMENT_TYPE,
		      NULL_);

	    if (status == CDF_stat)  {

/*  check to see if last character is a space  */

	      space = 
		isspace(global_data[master_counter]->INSTRUMENT_TYPE[numElems-1]);

	      if (space != 0) 
		global_data[master_counter]->INSTRUMENT_TYPE[numElems-1]= '\0';
	      else global_data[master_counter]->INSTRUMENT_TYPE[numElems]='\0';
	      
	    }

	  }
	}

	else if (strcmp (ATTRNAME , "LOGICAL_SOURCE_DESCRIPTION") == null)  {

	  entryN = 0;

	  status = CDFlib (SELECT_, gENTRY_,          entryN,
			   GET_,    gENTRY_NUMELEMS_, &numElems,
			   NULL_);

	  if (status == CDF_stat)  {

	    global_data[master_counter]->DATASET_LABEL = 
	      (char *) malloc (numElems +1);
	    if (global_data[master_counter]->DATASET_LABEL == NULL)  
	      reportMallocError;

	    status = 
	      CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->DATASET_LABEL,
		      NULL_);

	    if (status == CDF_stat)  
	      global_data[master_counter]->DATASET_LABEL[numElems] = '\0';
	
	  }
	}
	else if (strncmp (ATTRNAME , "LINK_TEXT", 9) == null)  {

	  /*get the number of entries, there may be up to 5 */

	  status = CDFlib (GET_, ATTR_MAXgENTRY_, &max_entries,
			   NULL_);

	 for (entryN = 0; entryN<=max_entries;entryN++) {

	  status = CDFlib (SELECT_, gENTRY_,          entryN,
			   GET_,    gENTRY_NUMELEMS_, &numElems,
			   NULL_);

	  if (status == CDF_stat)  {
	    switch (entryN) {
	      case  0: global_data[master_counter]->LINK_TEXT1 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->LINK_TEXT1 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->LINK_TEXT1,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->LINK_TEXT1[numElems] = '\0';
		       break;
	      case  1: global_data[master_counter]->LINK_TEXT2 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->LINK_TEXT2 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->LINK_TEXT2,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->LINK_TEXT2[numElems] = '\0';
		       break;
	      case  2: global_data[master_counter]->LINK_TEXT3 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->LINK_TEXT3 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->LINK_TEXT3,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->LINK_TEXT3[numElems] = '\0';
		       break;
	      case  3: global_data[master_counter]->LINK_TEXT4 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->LINK_TEXT4 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->LINK_TEXT4,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->LINK_TEXT4[numElems] = '\0';
		       break;
	      case  4: global_data[master_counter]->LINK_TEXT5 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->LINK_TEXT5 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->LINK_TEXT5,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->LINK_TEXT5[numElems] = '\0';
		       break;

	    } /*end switch */
	  } /*if CDF status */
	 } /*end for */
	} /*if attr_name = link_text*/

	else if (strncmp (ATTRNAME , "LINK_TITLE", 10) == null)  {

	  /*get the number of entries, there may be up to 5 */

	  status = CDFlib (GET_, ATTR_MAXgENTRY_, &max_entries,
			   NULL_);

	 for (entryN = 0; entryN<=max_entries;entryN++) {

	  status = CDFlib (SELECT_, gENTRY_,          entryN,
			   GET_,    gENTRY_NUMELEMS_, &numElems,
			   NULL_);

	  if (status == CDF_stat)  {
	    switch (entryN) {
	      case  0: global_data[master_counter]->LINK_TITLE1 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->LINK_TITLE1 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->LINK_TITLE1,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->LINK_TITLE1[numElems] = '\0';
		       break;
	      case  1: global_data[master_counter]->LINK_TITLE2 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->LINK_TITLE2 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->LINK_TITLE2,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->LINK_TITLE2[numElems] = '\0';
		       break;
	      case  2: global_data[master_counter]->LINK_TITLE3 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->LINK_TITLE3 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->LINK_TITLE3,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->LINK_TITLE3[numElems] = '\0';
		       break;
	      case  3: global_data[master_counter]->LINK_TITLE4 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->LINK_TITLE4 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->LINK_TITLE4,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->LINK_TITLE4[numElems] = '\0';
		       break;
	      case  4: global_data[master_counter]->LINK_TITLE5 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->LINK_TITLE5 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->LINK_TITLE5,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->LINK_TITLE5[numElems] = '\0';
		       break;

	    } /*end switch */
	  } /*if CDF status */
	 } /*end for */
	} /*if attr_name = link_TITLE*/

	else if (strncmp (ATTRNAME , "HTTP_LINK", 9) == null)  {
	
	  /*get the number of entries, there may be up to 3 */

	  status = CDFlib (GET_, ATTR_MAXgENTRY_, &max_entries,
			   NULL_);

	 for (entryN = 0; entryN<=max_entries;entryN++) {

	  status = CDFlib (SELECT_, gENTRY_,          entryN,
			   GET_,    gENTRY_NUMELEMS_, &numElems,
			   NULL_);

	  if (status == CDF_stat)  {
	    switch (entryN) {
	      case  0: global_data[master_counter]->HTTP_LINK1 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->HTTP_LINK1 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->HTTP_LINK1,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->HTTP_LINK1[numElems] = '\0';
		       break;
	      case  1: global_data[master_counter]->HTTP_LINK2 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->HTTP_LINK2 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->HTTP_LINK2,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->HTTP_LINK2[numElems] = '\0';
		       break;
	      case  2: global_data[master_counter]->HTTP_LINK3 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->HTTP_LINK3 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->HTTP_LINK3,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->HTTP_LINK3[numElems] = '\0';
		       break;
	      case  3: global_data[master_counter]->HTTP_LINK4 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->HTTP_LINK4 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->HTTP_LINK4,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->HTTP_LINK4[numElems] = '\0';
		       break;
	      case  4: global_data[master_counter]->HTTP_LINK5 = 
			 (char *) malloc (numElems +1);
	               if (global_data[master_counter]->HTTP_LINK5 == NULL)  
			 reportMallocError;

		       status = 
			 CDFlib (GET_, gENTRY_DATA_, global_data[master_counter]->HTTP_LINK5,
				 NULL_);

		       if (status == CDF_stat)  
			 global_data[master_counter]->HTTP_LINK5[numElems] = '\0';
		       break;

	    } /*end switch */
	  } /*if CDF status */
	 } /*end for */
	} /*if attr_name = HTTP_LINK*/

      }
      
    }
  }

  free(ATTRNAME);

/*  set the DATASET parameter by filename...  */

  temp = strrchr (fileName, '/');
  dataset_len = strlen (temp) - 18;

  caps = (char *) malloc (dataset_len +1);
  if (caps == NULL)  reportMallocError;

  global_data[master_counter]->DATASET = (char *) malloc (dataset_len +1);
  if (global_data[master_counter]->DATASET == NULL)  reportMallocError;

  strncpy (caps, ++temp, dataset_len);
  global_data[master_counter]->DATASET = allCAPS (caps, dataset_len);

  free (caps);

/*  set the  MASTERCDF parameter by filename...  */

  temp = strstr (fileName, "/0MASTER");

  if (temp != NULL)  {

    dataset_len = strlen (temp) - 5;
    global_data[master_counter]->MASTERCDF = (char *) malloc (dataset_len +1);
    if (global_data[master_counter]->MASTERCDF == NULL)  reportMallocError;

    strncpy (global_data[master_counter]->MASTERCDF, ++temp, dataset_len);
    global_data[master_counter]->MASTERCDF[dataset_len] = '\0';
  }

  else global_data[master_counter]->MASTERCDF = NULL;

  return (CDF_stat);
}


/*  Get global attributes from a file other than a master .cdf...   */
int makeMaster (char *fileName)  {


  CDFid           id;
  CDFstatus       status;
  const CDFstatus CDF_stat = 0;
  int             numAttrs;
  int             numVars;
  const int       mode = 1;
  const int       null = 0;
  CDFstatus       returnCODE = 0;


  status = CDFlib (OPEN_, CDF_, fileName, &id,
		   NULL_);


  if (status == CDF_stat)  {

    
    status = CDFlib (SELECT_, CDF_,          id,
		              CDF_zMODE_,    mode,
		     GET_,    CDF_NUMzVARS_, &numVars,
		              CDF_NUMATTRS_, &numAttrs,
		     NULL_);

    if (status == CDF_stat)  {

    
      master_counter++;


      global_data[master_counter] = (gDATA *)  malloc (sizeof (gDATA));
      if (global_data[master_counter] == NULL)  reportMallocError;


      returnCODE = extract_globalDATA(fileName, numAttrs);

      if (returnCODE == null)  {

	variable_data[master_counter] = (vDATA *) malloc (sizeof (vDATA));
	if (variable_data[master_counter] == NULL)  reportMallocError;

	variable_data[master_counter]->NUMBER_VARIABLES = 
	  get_VARIABLEnames (fileName, numVars);

      }
    }

  }

  return (master_counter);

}




/*  Process filenames found by FTW.  If the file is not a regular file, write
    message to error log and move on to next file.  If the file is a regular 
    file, look for the .cdf suffix and process accordingly...               */
int process_MASTERS (char *fileName, struct stat *file_INFO, int code)   {

/*  programmer:  c. gallap, hstx              date:  February 7, 1997        */

/*  Declare variables...                                                     */

  char            *TruncString;
  const char      cdfSuffix[] = {".cdf"};
  char            label[CDF_STATUSTEXT_LEN+20];
  CDFid           id;
  CDFstatus       status;
  const CDFstatus CDF_stat = 0;
  int             numVars;
  int             numAttrs;
  const int       mode = 1;
  const int       null = 0;
  const int       SUCCESS = 0;
  int             returnCODE = 0;



  if (code == FTW_DNR)  
    fprintf (logged, "ERROR: %s is a directory that cannot be read.\n", 
	     fileName);

  else if (code == FTW_F)  {

    TruncString = strstr (fileName, cdfSuffix);

    if (TruncString != NULL)  {

/*  If the .cdf suffix is found, open and process...                   */
     
      
      status = CDFlib (OPEN_, CDF_, fileName, &id,
		       NULL_);

      returnCODE = status;

      if (status != CDF_stat)  {

	strcpy (label, fileName);
	strcat (label, ">");
	errHandle (label, status);
	return (returnCODE);
      }
    
      status = CDFlib (SELECT_, CDF_,          id,
		                CDF_zMODE_,    mode,
		       GET_,    CDF_NUMzVARS_, &numVars,
		                CDF_NUMATTRS_, &numAttrs,
		       NULL_);

      returnCODE = status;

      if (status != CDF_stat)  {

	strcpy (label, "Select CDF and get number of attributes:\0");
	errHandle (label, status);
	return (returnCODE);
      }    

      ++master_counter;

      global_data[master_counter] = (gDATA *) malloc (sizeof(gDATA));
      if (global_data[master_counter] == NULL)  reportMallocError; 

      returnCODE = extract_globalDATA (fileName, numAttrs);

      if (returnCODE == SUCCESS) {

/*  Get names of all variables ...   */

	variable_data[master_counter] = (vDATA *) malloc (sizeof (vDATA));
	if (variable_data[master_counter] == NULL)  reportMallocError;  

	variable_data[master_counter]->NUMBER_VARIABLES = 
	  get_VARIABLEnames (fileName, numVars);

      }

      else fprintf (logged, "ERROR occurred while extracting global data.\n");


/*  reset return code so the next master file will be processed...   */
      returnCODE = SUCCESS;

      CDFclose (id);

    }
  }

  else if (code == FTW_SL)
    fprintf 
      (logged, "LINK: %s is a symbolic link, and will not be read further.\n",
       fileName);

  else if (code == FTW_NS)
    fprintf (logged, "ERROR: %s is a file where the STAT function failed.\n", 
	     fileName);

  return (returnCODE);
}



/*   main program allTogetherNow...          */
main ()   {

/*  Performs the following functions:
 *   searches 0MASTER directory for all MASTER files
 *   extracts GLOBAL data from MASTER file and writes 
     to global structure
 *   extracts number and names of variables from MASTER file 
     and writes to variable structure
 *   reads the CDF file created by tree_CDFS; sorts file by 
     dataset name and in ascending time order
 *   Computes the total number of CDFS and time ranges of all 
     CDFS for a dataset name
 *   Matches the current dataset name from the CDF file to a 
     master structure
 *   Writes the results to the database files


  programmer:  c. gallap, hstx           date:  July 10, 1997 */


/*  Variable declarations...                                 */

  char   *master_path;
  int    i;
  int    ftw_check;
  int    cdf_check;
  const int    files_written = -1; /*TJK added initialization so the compiler 
				     would be happy*/
  int    loop;
  int    go;
  int    counter;
  size_t path_size;
  size_t mdir_size;
  char   *name;
  char   *dataset;
  double btime;
  double etime;
  char   *CDF_list;
  char   *LOG_file;
  char   *GAP_file;
  char   campDefs[] = {"/home/rumba/cdaweb/dev/source/CampaignDefinitions"};
  char   camp_dataset[12];
  char   send_dataset[12];
  char   *prefix;
  char   suffix[] = {"_cdfmetafile.txt"};
  char   *fileName;
  char   tempName[100];
  int    begin_year, begin_month, begin_day;
  int    end_year, end_month, end_day;
  int    master_number;


  mdir_size = strlen (getenv("MASTERDIR"));
  master_path = (char *) malloc (mdir_size);
  if (master_path == NULL) reportMallocError;
  strcpy (master_path, getenv("MASTERDIR"));


  path_size = strlen (getenv("META"));


/*  CDF_list contains the DATASET (logical_source) parameter, cdf filename,
    and epoch date/times for the first and last records for each cdf file...*/  
  CDF_list = (char *) malloc (path_size + 10);
  if (CDF_list == NULL) reportMallocError;
  strcpy (CDF_list, getenv("META"));
  strcat (CDF_list, "/CDF_list");
  cdfs =   fopen (CDF_list, "r");

/*  LOG_file contains processing information and errors...        */

  LOG_file = (char *) malloc (path_size + 13);
  if (LOG_file == NULL) reportMallocError;
  strcpy (LOG_file, getenv("META"));
  strcat (LOG_file, "/metadata_LOG");
  logged =   fopen (LOG_file, "w");

/*  GAP_file records redundant files; this file is used to delete duplicates
    in the next run...   */

  GAP_file = (char *) malloc (path_size + 13);
  if (GAP_file == NULL) reportMallocError;
  strcpy (GAP_file, getenv("META"));
  strcat (GAP_file, "/metadata_GAP");
  gaps  =  fopen (GAP_file, "w");


/*  Begin filling global attribute structures...                             */


  master_counter = -1;
  
  ftw_check = ftw (master_path, process_MASTERS);
  if (ftw_check != 0)  {

    printf ("Error flagged by function ftw.\n");
    fprintf (logged, "Return code from ftw:  %i\n", ftw_check);
    fprintf (logged, "Path name:  %s\n", master_path);

    fclose(cdfs);
    fclose(logged);
    fclose(gaps);

    return(-1);
  }

  fprintf (logged, "LOG: Completed filling %i global attribute structures\n\n",
 	   master_counter+1);

/*  Begin processing the CDF file list; group by DATASET_NAME and sort by 
    begin time.  */

  fprintf (logged, 
	   "LOG: Begin process CDF files; group by DATASET_NAME and sort by begin time\n\n");

  dataset = (char *) malloc (15);
  if (dataset == NULL)  reportMallocError;

  name = (char *) malloc (128);
  if (name == NULL)  reportMallocError;

  counter = 0;

/*  Start reading the CDF file name list...  */

  while (1)  {

    go = fscanf (cdfs, "%s %Le %Le %s\n", dataset, &btime, 
		 &etime, name);

    if (go == EOF) break;

    counter++;


/*  Perform a binary tree sort on dataset label ...*/
    tree_on_dataset (&root, dataset, btime, etime, name);

  }

  free (dataset);
  free (name);


/*  Write separate campaign files ...

    Each campaign is defined by the DATASET name and the BEGIN and END dates, 
    given in the format  YYYY:MM:DD.  The first record for each campaign is 
    the first qualifier of the output file name. Each campaign must end with 
    the characters '!!!'                         */

  input = fopen (campDefs, "r");

  if (input == NULL ) {

    fprintf (logged, "ERROR: CampaignDefinitions file does not exist.\n");
    return (files_written);
  }


  for  (;;)  {
    
    go = fscanf (input, "%s\n", tempName);
    if (go == EOF)  break;

    if (strcmp (tempName, "!!!") == NULL) break;

    fileName = (char *) malloc(path_size + strlen(tempName) + 
			       strlen(suffix) + 1);
    if (fileName == NULL)  reportMallocError;

    strcpy(fileName, getenv("META"));
    strcat(fileName, "/");
    strcat(fileName, tempName);

    fprintf (logged, "\n*****\nLOG: Writing file> %s\n", 
	     strcat(fileName, suffix));

    database = fopen (fileName, "w");

    if (database == NULL)  {

      fprintf (logged, "ERROR: Cannot open file> %s for writing.\n", fileName);
      return (files_written);
    }
    
    for (;;)  {

      go = fscanf (input, "%s %i:%i:%i %i:%i:%i\n", camp_dataset, &begin_year, 
		   &begin_month, &begin_day, &end_year, &end_month, &end_day);

      if (go == EOF || strcmp (camp_dataset, "!!!") == NULL)  break;


/*  Find the matching global attributes...  */

      master_number = -1;
      strcpy (send_dataset, camp_dataset);
      
      for (i = 0; i <= master_counter; i++)

	if (strcmp (camp_dataset, global_data[i]->DATASET) == NULL)  {

	  master_number = i;
	  strcpy (send_dataset, global_data[i]->DATASET);

	  break;
	}


      print_dataset (root, master_number, send_dataset);

    }

    fclose (database);
  }
  

/*  Now write full database...   */

  fileName = (char *) malloc(path_size + strlen(tempName) + 21);
  if (fileName == NULL)  reportMallocError;

  strcpy(fileName, getenv("META"));
  strcat(fileName, "/full_cdfmetafile.txt");

  database = fopen (fileName, "w");

  fprintf (logged, "\n*****\nLOG: Writing file> %s\n", fileName);

  for (i = 0; i <= master_counter; i++) {

    strcpy (send_dataset, global_data[i]->DATASET); 
    print_dataset (root, i, send_dataset);

  }


  fclose (database);

  
  fprintf (logged, "\nLOG: Completed processing CDF files.\n");

  fprintf (logged, "\nLOG: %i MASTERCDF files processed\n", master_counter);
  fprintf (logged, "LOG: %i CDF files processed\n", counter);

/*   free up all memory that is still allocated...   */

  free (global_data);
  free (variable_data);

/*  Close files before exiting program...   */
  fclose (cdfs);
  fclose (gaps);
  fclose (logged);


  return(0);
}
