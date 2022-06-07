/// 2020  version - accessed: 12-12-2021 ///

clear
import excel "${Rootdatadir}/DataSets-other/Crosswalk/CDC_opioid NDC_oral MME conversion_update_2020.xlsx", ///
	sheet("Opioids") cellrange(A1:L15300 ) firstrow  clear
	ren NDC ndc
	drop MME_Conversion_Factor
	sort ndc
	ren GENNME Generic_Drug_Name
	ren PRODNME Product_Drug_Name
	gen buprenorphine=1 if strpos(lower(Drug), "buprenorphine")>0 &  ///
	(strpos(lower(Product_Drug_Name), "butrans")==0 ///
	&strpos(lower(Product_Drug_Name), "belbuca")==0  & ///
	Master_Form!="Patch, Extended Release")
	//delete 115/132 NDCs	
	gen methadone=1 if  strpos(lower(Drug), "methadone")>0 
	gen opioid=1 if buprenorphine!=1 & methadone!=1
	foreach var in methadone opioid buprenorphine {
		replace `var'=0 if `var'==.
		}
	drop if methadone ==1 
	
	keep ndc NDC_Numeric buprenorphine opioid Product_Drug_Name LongShortActing DEAClassCode Master_Form
	ren buprenorphine BUP 
	
	gen ER_BUP=0
	replace ER_BUP=1 if Product_Drug_Name=="SUBLOCADE"|Product_Drug_Name=="SUBLOCADE 100MG" | Product_Drug_Name=="PROBUPHINE" 
	
	sort ndc 
	codebook ndc 
	save "${intdir}/CDC_NDC_and_mmeBup_Opioid_2020",replace
	keep if BUP==1
	tab Product_Drug_Name Master_Form
	tab Product_Drug_Name
	tab Master_Form
	list ndc Product_Drug_Name Master_Form if Product_Drug_Name=="BUPRENORPHINE"
	
/// 2018 version


clear
import excel "${Rootdatadir}/DataSets-other/Crosswalk/CDC_Oral_Morphine_Milligram_Equivalents_Sept_2018.xlsx", ///
	sheet("Opioids") cellrange(A1:L14549 ) firstrow  clear
	ren NDC ndc
	drop MME_Conversion_Factor
	sort ndc
	ren GENNME Generic_Drug_Name
	ren PRODNME Product_Drug_Name
	gen buprenorphine=1 if strpos(lower(Drug), "buprenorphine")>0 &  ///
	(strpos(lower(Product_Drug_Name), "butrans")==0 ///
	&strpos(lower(Product_Drug_Name), "belbuca")==0  & ///
	Master_Form!="Patch, Extended Release")
	//delete 115/132 NDCs	
	gen methadone=1 if  strpos(lower(Drug), "methadone")>0 
	gen opioid=1 if buprenorphine!=1 & methadone!=1
	foreach var in methadone opioid buprenorphine {
		replace `var'=0 if `var'==.
		}
	drop if methadone ==1 
	
	keep ndc NDC_Numeric buprenorphine opioid Product_Drug_Name LongShortActing DEAClassCode Master_Form
	ren buprenorphine BUP 
	
	gen ER_BUP=0
	replace ER_BUP=1 if Product_Drug_Name=="SUBLOCADE" | Product_Drug_Name=="PROBUPHINE" 
	
	sort ndc 
	codebook ndc 
	save "${intdir}/CDC_NDC_and_mmeBup_Opioid_2018",replace

	keep if BUP==1
	tab Product_Drug_Name Master_Form
	
	
	// STATIN THERAPY https://www.ncqa.org/hedis/measures/hedis-2017-national-drug-code-ndc-license/hedis-2017-final-ndc-lists/
	
clear
import excel "${datadir}/SPD-A_2017-final.xlsx", ///
	sheet("SPD-A_2017") cellrange(A1:A1565 ) firstrow  clear
	ren NDCCode ndc 
	codebook ndc 
	sort ndc
	gen statin =1 
	save "${intdir}/NDC_Statin_2017",replace
	
