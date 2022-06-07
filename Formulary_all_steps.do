* 		File Description
*************************************************
*Author: Thuy Nguyen
*Date created: 12/01/2021
*Date modified: 06/06/2022

	clear
	cap clear matrix
	/*Working Directories*/
	* change to your working directory
	* you need intermediate_results, plot, source, log, data folders
	global Rootdatadir "/media/thuy/13c83ca8-25b7-471b-a983-b67d635be41c/DataSets"	
	global Vrawdatadir "/media/thuy/13c83ca8-25b7-471b-a983-b67d635be41c/DataSets/FormularyData/RawData/Vericred"	
	global HIXrawdatadir "/media/thuy/13c83ca8-25b7-471b-a983-b67d635be41c/DataSets/FormularyData/RawData/HIX"	
	global HIXcleandatadir "${Rootdatadir}/FormularyData/CleanData/HIX"
	global Dcleandatadir "${Rootdatadir}/FormularyData/CleanData/PartD"
	global Vcleandatadir "${Rootdatadir}/FormularyData/CleanData/Vericed"
	
	global basedir "/media/thuy/13c83ca8-25b7-471b-a983-b67d635be41c/Projects/Formulary"
	global intdir "${basedir}/intermediate_results"
	global plotdir "${basedir}/writeup/plot"
	global tabledir "${basedir}/writeup/table"
	global sourcedir "${basedir}/script-JM HF"
	global logdir "${basedir}/log"
	global datadir "${basedir}/data"
	global rawfdir "${Rootdatadir}//Vericred/FormularyFiles/RawData"

	

// Version of stata
version 17

// Clear Memory
clear all
cap clear matrix	
set matsize 11000
clear mata
set maxvar 32767

// Set Date
global date = subinstr("$S_DATE", " ", "-", .)

	

/* Start log */
capture log close
log using "${logdir}/Formulary_allstep$S_DATE.log", replace


clear
set matsize 11000
clear mata
set maxvar 32767

clear
cd "${basedir}"

***************************************************************************
* reading files and create stata versions of data:                        *
***************************************************************************
	do "${sourcedir}/0.1.MOUD_NDC_list.do" 	
	do "${sourcedir}/1.1.ReadVericed.do" 	
***************************************************************************
* process data                                                            *
***************************************************************************
	do "${sourcedir}/1.2.Vericed_CompilingData.do" 	
	do "${sourcedir}/1.3.Vericed_CompilingNetworkData.do" 	
	do "${sourcedir}/1.4.classifyPlanType.do" 	
	do "${sourcedir}/1.5.Vericred_measures_bup.do" 	
	do "${sourcedir}/1.6.Vericred_HIOS_Samples.do" 	
	
***************************************************************************
* analysis                                                                *
***************************************************************************
	do "${sourcedir}/2.1.Vericed_Private_Coverage.do" 	

	** data validation 
	do "${sourcedir}/3.1.CheckCompleteness.do" 	
