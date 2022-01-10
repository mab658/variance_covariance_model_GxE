/* Set up working environment */;
dm 'log;clear;output;clear;odsresults;clear;';
options ls=120 ps=1500 nocenter nodate pageno=1;
ods graphics off;
ods noresults;

/* Ensure you have the data fiiles:narrowPhenoDat, FA3_loadings, and weatherSumm_cov are within the same folder */;
/* Define macro variable to set the path for import and export data */
*%let dirpath = C:\Users\mab658\Documents\Moshood_PhD_Research_Work\Task_9_setA_GxE\Classical_analysis_setA_output\;

%let dirpath = C:\Users\mab658\Documents\Moshood_PhD_Research_Work\Task_11_GxE\GxE_output\;

/* Define a macro to read spreadsheet file */;

%macro importdat(dsn);
proc import out=&dsn
	datafile="&dirpath&dsn..csv"
	dbms=csv replace;
	getnames=yes;
	guessingrows=13042;
run;
%mend importdat;


/* Macro to export some output dataset to an output directory */;
%macro exportdat(dataset);
proc export data= &dataset
	outfile="&dirpath&dataset..csv"
	dbms=csv replace;
run;
%mend exportdat;

/* invoke the macro to import raw data in a narrow fromat */;
%importdat(narrowPhenoDat);

/********Step 1: Compute Summmary statistics for key traits of interest subset from the raw data *******/;
data raw_pheno;
	set narrowPhenoDat;
	where trait in("fyld","dm","dyld","tyld");
run;

/* you have to make a reference to the folder where summaryStats.sas and be run */;
%include "C:\Users\mab658\Documents\Moshood_PhD_Research_Work\Task_11_GxE\GxE_data\summaryStats.sas";
%summaryStats(raw_pheno); /* invoke macro to carry out summary statistics */;


/* pearson correlation of environmental covariables (weather data) with env or factor loadings from FA3 model */;
%importdat(FA3_loadings);
%importdat(weatherSumm_cov);

/* Merge the two imported data */;
 data env_covariate_loading;
  merge FA3_loadings weatherSumm_cov;
  by env;
  keep env fa1-fa3 crop_growth_cycle--precipitation;
run;


/* Define macro variable to set the path for the output of analysis */
ods html body ="&outpath&.correlation_envCovariable_vs_envLoadings.html";

proc corr data=env_covariate_loading(drop = TMean RH_Mean);
	var fa1-fa3;
	with crop_growth_cycle--precipitation;
run;
ods html close;
