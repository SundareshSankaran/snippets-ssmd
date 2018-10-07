/* Define inputs here (alternatively you can define these as command line arguments and then assign them to the respective macro variables */

/* Input Directory from where you wish to append files */
%let inpDir = "C:\SSMD\Test\"

/* ControlFile location where you want to save your Control file */
%let cfDir = "C:\SSMD\ControlFile.txt";

/* Output dataset */
%let resultDataset= ;

/* (Hint : I usually like to save the control file one level above the actual directory location, but will leave that up to you) */

/* This line creates a list of files (assuming a linux system - change as per what you like (dir for a windows)) */
x "ls -A1 &inpDir. > &cfDir.";

libname ALL "&inpDir."
 
/* We then create a dataset called files which contains the files */
data files;
    length filenm $100; /*change if you think you might have very long filenames*/
    infile "&cfDir." lrecl=100 dsd truncover;
    input @1 filenm $;

/* Here is an optional tweak - you might want to restrict your selection to only one type of file - you can input your condition here example - take only files which start with ABC_  */
    if substr(filenm,1,4) ne "ABC_" then delete;

    filenm=tranwrd(filenm,".sas7bdat",""); /*remove the extension*/

run;


/* Delete resultDataset if already exists (and if you want to delete it) */

proc delete data=&resultDataset.;
run;

 
%macro mdfile;

      proc sql noprint;
           select count(*) into:nfiles from files;
      quit;

 
      %do i = 1 %to &nfiles.;


           data _null_;
           set files;
                 if _n_ = &i. then call symput("ff",filenm);
           run;

           proc append data= ALL.&ff. base=&resultDataset. force;
           run;

        /* The below %IF loop is optional. 
        A common source of error that occurs with appends is the truncation that occurs when force is specified.
        If you are unsure about different record lengths or other characteristics, use this opportunity (first append)
        to make changes as needed */

           %if &i. = 1 %then %do;

                 data &resultDataset.;
                      /* length someRandomVar $100.; */
                 set &resultDataset.;
                 run;

           %end;

      %end;

 

%mend mdfile;

 

%mdfile;