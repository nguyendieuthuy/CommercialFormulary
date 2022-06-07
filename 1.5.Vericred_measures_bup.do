
/* Start log */
capture log close
log using "${logdir}/4.1.Formulary_extractRecords.log", replace

	
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
/*
	
* PA 
          forvalues t = 2017/2021 {     
	* BUP records
	use formulary_id ndc tier Product_Drug_Name Master_Form quantity_limit step_therapy prior_authorization name BUP ER_BUP ///
	using "${intdir}/drug_package_formularies`t'All.dta", clear 

	drop if ndc=="" // about 2% missing NDC per year
	
	sort formulary_id ndc
	
	sort formulary_id 
	by formulary_id: egen nU_NDCAll =nvals(ndc)  if tier!="not_covered"			
	by formulary_id: egen nNDCAll =count(ndc)  if tier!="not_covered"			
	
	by formulary_id: egen Y_BUP =max(BUP) // at least 1 BUP
	drop if Y_BUP==1 & BUP!=1 // drop non-bup formulary within plans with at least 1 BUP 
	
	foreach var in sublocade probuphine zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet  {
	gen `var'=0		
	}

	foreach var in sublocade probuphine zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil BUP ER_BUP IR_BUP IR_film  IR_tablet {
	gen cover`var'=0
	}

	replace IR_BUP=1 if BUP==1 & ER_BUP!=1 
	replace sublocade=1 if Product_Drug_Name=="SUBLOCADE"|Product_Drug_Name=="SUBLOCADE 100MG"
	replace probuphine=1 if Product_Drug_Name=="PROBUPHINE"

	replace zubsolv=1 if Product_Drug_Name=="ZUBSOLV"
	replace bunavail=1 if Product_Drug_Name=="BUNAVAIL"
	replace suboxone=1 if Product_Drug_Name=="SUBOXONE"

	replace genBUPtab=1 if Product_Drug_Name=="BUPRENORPHINE HYDROCHLORIDE"|Product_Drug_Name=="BUPRENORPHINE"
	replace genBUPNALtab=1 if Product_Drug_Name=="BUPRENORPHINE-NALOXONE" & Master_Form=="Tablet"
	replace genBUPNALfil=1 if Product_Drug_Name=="BUPRENORPHINE-NALOXONE" & Master_Form=="Film"
	
	replace IR_film=1 if IR_BUP==1 & Master_Form=="Film" 
	replace IR_tablet=1 if IR_BUP==1 & Master_Form=="Tablet" 
	
	* covered drug 	
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	replace cover`D'=1 if tier!="not_covered" & `D'==1
	}
	
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	sort formulary_id 
	by formulary_id: egen nNDCcover`D' =count(ndc) if cover`D'==1
	}
	
	* restriction 
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	gen PA`D'=0
	replace PA`D'=1 if prior_authorization=="t" & cover`D'==1	
	}
	
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {		
	sort formulary_id 
	by formulary_id: egen nNDCPA`D' =count(ndc) if PA`D'==1 & cover`D'==1			
	}
	
	** create plan-level variables 		
		* without PA for at least 1 product 
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {		
	sort formulary_id 
	by formulary_id: egen Y_cover`D' =max(cover`D') // at least cover one drug 
	by formulary_id: egen Y_PA`D' =min(PA`D') // without PA for at least 1 product
	}	

	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {			
	sort formulary_id 
	by formulary_id: gen AllPA`D' = 1 if cover`D' ==1 & nNDCcover`D'== nNDCPA`D'	// N NDCs covered = N NDCs with PA within each plan - PA for any products
	by formulary_id: gen NoPA`D' = 1 if cover`D' ==1 & nNDCPA`D'==0	// without PA for any bup products 
	}
	
	
	collapse (mean) nNDCAll nNDCcover* nNDCPA* Y_cover* Y_PA* AllPA* NoPA*  ///
		(firstnm) name, by(formulary_id )
	gen year =`t'
		
	save "${intdir}/plan_formulary_BUP`t'.dta", replace 
	export excel using $plotdir/plan_formulary_BUP_PA`t', replace firstrow(var)	
	  }

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
* ST and QL 
     
  foreach RES in quantity_limit step_therapy {
  	if "`RES'"=="quantity_limit" local restrict "QL"	
  	if "`RES'"=="step_therapy" local restrict "ST"	 
         forvalues t = 2017/2021 {     
	* BUP records
	use formulary_id ndc tier Product_Drug_Name Master_Form quantity_limit step_therapy prior_authorization name BUP ER_BUP ///
	using "${intdir}/drug_package_formularies`t'All.dta", clear 

	drop if ndc=="" // about 2% missing NDC per year
	
	sort formulary_id ndc
	
	sort formulary_id 
	by formulary_id: egen nU_NDCAll =nvals(ndc)  if tier!="not_covered"			
	by formulary_id: egen nNDCAll =count(ndc)  if tier!="not_covered"			
	
	by formulary_id: egen Y_BUP =max(BUP) // at least 1 BUP
	drop if Y_BUP==1 & BUP!=1 // drop non-bup formulary within plans with at least 1 BUP 

	
	foreach var in sublocade probuphine zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	gen `var'=0		
	}

	foreach var in sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil BUP ER_BUP IR_BUP IR_film  IR_tablet {
	gen cover`var'=0
	}
	
	replace IR_BUP=1 if BUP==1 & ER_BUP!=1 
	replace sublocade=1 if Product_Drug_Name=="SUBLOCADE"|Product_Drug_Name=="SUBLOCADE 100MG"
	replace probuphine=1 if Product_Drug_Name=="PROBUPHINE"

	replace zubsolv=1 if Product_Drug_Name=="ZUBSOLV"
	replace bunavail=1 if Product_Drug_Name=="BUNAVAIL"
	replace suboxone=1 if Product_Drug_Name=="SUBOXONE"

	replace genBUPtab=1 if Product_Drug_Name=="BUPRENORPHINE HYDROCHLORIDE"|Product_Drug_Name=="BUPRENORPHINE"
	replace genBUPNALtab=1 if Product_Drug_Name=="BUPRENORPHINE-NALOXONE" & Master_Form=="Tablet"
	replace genBUPNALfil=1 if Product_Drug_Name=="BUPRENORPHINE-NALOXONE" & Master_Form=="Film"
	
	replace IR_film=1 if IR_BUP==1 & Master_Form=="Film" 
	replace IR_tablet=1 if IR_BUP==1 & Master_Form=="Tablet" 
	
	* covered drug 	
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	replace cover`D'=1 if tier!="not_covered" & `D'==1
	}
	
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	sort formulary_id 
	by formulary_id: egen nNDCcover`D' =count(ndc) if cover`D'==1
	}
	
	* restriction 
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	gen `restrict'`D'=0
	replace `restrict'`D'=1 if `RES'=="t" & cover`D'==1	
	}
	
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {		
	sort formulary_id 
	by formulary_id: egen nNDC`restrict'`D' =count(ndc) if `restrict'`D'==1 & cover`D'==1			
	}
	
	** create plan-level variables 		
		* without `restrict' for at least 1 product 
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {		
	sort formulary_id 
	by formulary_id: egen Y_cover`D' =max(cover`D') // at least cover one drug 
	by formulary_id: egen Y_`restrict'`D' =min(`restrict'`D') // without `restrict' for at least 1 product
	}	

	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {			
	sort formulary_id 
	by formulary_id: gen All`restrict'`D' = 1 if cover`D' ==1 & nNDCcover`D'== nNDC`restrict'`D'	// N NDCs covered = N NDCs with `restrict' within each plan - `restrict' for any products
	by formulary_id: gen No`restrict'`D' = 1 if cover`D' ==1 & nNDC`restrict'`D'==0	// without `restrict' for any bup products 
	}	
	
	collapse (mean) nNDCAll nNDCcover* nNDC`restrict'* Y_cover* Y_`restrict'* All`restrict'* No`restrict'*  ///
		(firstnm) name, by(formulary_id )
	gen year =`t'
		
	save "${intdir}/plan_formulary_BUP`restrict'`t'.dta", replace 
	export excel using $plotdir/plan_formulary_BUP_`restrict'`t', replace firstrow(var)	
	}  
	}
	
*/	
************************************************************************************************ 
/*
year 2018: remove genBUPNALfil due to partial year 

*/	

* PA 
          forvalues t = 2018/2018 {     
	* BUP records
	use formulary_id ndc tier Product_Drug_Name Master_Form quantity_limit step_therapy prior_authorization name BUP ER_BUP ///
	using "${intdir}/drug_package_formularies`t'All.dta", clear 

	drop if ndc=="" // about 2% missing NDC per year
	
	sort formulary_id ndc
	
	sort formulary_id 
	by formulary_id: egen nU_NDCAll =nvals(ndc)  if tier!="not_covered"			
	by formulary_id: egen nNDCAll =count(ndc)  if tier!="not_covered"			
	
	by formulary_id: egen Y_BUP =max(BUP) // at least 1 BUP
	drop if Y_BUP==1 & BUP!=1 // drop non-bup formulary within plans with at least 1 BUP 
	
	drop BUP 
	
	foreach var in BUP sublocade probuphine zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet  {
	gen `var'=0		
	}

	foreach var in BUP sublocade probuphine zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil ER_BUP IR_BUP IR_film  IR_tablet {
	gen cover`var'=0
	}

	replace sublocade=1 if Product_Drug_Name=="SUBLOCADE"|Product_Drug_Name=="SUBLOCADE 100MG"
	replace probuphine=1 if Product_Drug_Name=="PROBUPHINE"

	replace zubsolv=1 if Product_Drug_Name=="ZUBSOLV"
	replace bunavail=1 if Product_Drug_Name=="BUNAVAIL"
	replace suboxone=1 if Product_Drug_Name=="SUBOXONE"

	replace genBUPtab=1 if Product_Drug_Name=="BUPRENORPHINE HYDROCHLORIDE"|Product_Drug_Name=="BUPRENORPHINE"
	replace genBUPNALtab=1 if Product_Drug_Name=="BUPRENORPHINE-NALOXONE" & Master_Form=="Tablet"
	*replace genBUPNALfil=1 if Product_Drug_Name=="BUPRENORPHINE-NALOXONE" & Master_Form=="Film"

	replace BUP=1 if sublocade==1 | zubsolv==1|bunavail==1|suboxone==1|genBUPtab==1|genBUPNALtab==1
	replace IR_BUP=1 if BUP==1 & ER_BUP!=1 
	
	replace IR_film=1 if IR_BUP==1 & Master_Form=="Film" 
	replace IR_tablet=1 if IR_BUP==1 & Master_Form=="Tablet" 
	
	* covered drug 	
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	replace cover`D'=1 if tier!="not_covered" & `D'==1
	}
	
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	sort formulary_id 
	by formulary_id: egen nNDCcover`D' =count(ndc) if cover`D'==1
	}
	
	* restriction 
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	gen PA`D'=0
	replace PA`D'=1 if prior_authorization=="t" & cover`D'==1	
	}
	
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {		
	sort formulary_id 
	by formulary_id: egen nNDCPA`D' =count(ndc) if PA`D'==1 & cover`D'==1			
	}
	
	** create plan-level variables 		
		* without PA for at least 1 product 
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {		
	sort formulary_id 
	by formulary_id: egen Y_cover`D' =max(cover`D') // at least cover one drug 
	by formulary_id: egen Y_PA`D' =min(PA`D') // without PA for at least 1 product
	}	

	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {			
	sort formulary_id 
	by formulary_id: gen AllPA`D' = 1 if cover`D' ==1 & nNDCcover`D'== nNDCPA`D'	// N NDCs covered = N NDCs with PA within each plan - PA for any products
	by formulary_id: gen NoPA`D' = 1 if cover`D' ==1 & nNDCPA`D'==0	// without PA for any bup products 
	}
	
	
	collapse (mean) nNDCAll nNDCcover* nNDCPA* Y_cover* Y_PA* AllPA* NoPA*  ///
		(firstnm) name, by(formulary_id )
	gen year =`t'
		
	save "${intdir}/plan_formulary_BUP`t'.dta", replace 
	export excel using $plotdir/plan_formulary_BUP_PA`t', replace firstrow(var)	
	  }

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
* ST and QL 
     
  foreach RES in quantity_limit step_therapy {
  	if "`RES'"=="quantity_limit" local restrict "QL"	
  	if "`RES'"=="step_therapy" local restrict "ST"	 
         forvalues t = 2018/2018 {     
	* BUP records
	use formulary_id ndc tier Product_Drug_Name Master_Form quantity_limit step_therapy prior_authorization name BUP ER_BUP ///
	using "${intdir}/drug_package_formularies`t'All.dta", clear 

	drop if ndc=="" // about 2% missing NDC per year
	
	sort formulary_id ndc
	
	sort formulary_id 
	by formulary_id: egen nU_NDCAll =nvals(ndc)  if tier!="not_covered"			
	by formulary_id: egen nNDCAll =count(ndc)  if tier!="not_covered"			
	
	by formulary_id: egen Y_BUP =max(BUP) // at least 1 BUP
	drop if Y_BUP==1 & BUP!=1 // drop non-bup formulary within plans with at least 1 BUP 

	drop BUP 
	
	foreach var in BUP sublocade probuphine zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet  {
	gen `var'=0		
	}

	foreach var in BUP sublocade probuphine zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil ER_BUP IR_BUP IR_film  IR_tablet {
	gen cover`var'=0
	}

	replace sublocade=1 if Product_Drug_Name=="SUBLOCADE"|Product_Drug_Name=="SUBLOCADE 100MG"
	replace probuphine=1 if Product_Drug_Name=="PROBUPHINE"

	replace zubsolv=1 if Product_Drug_Name=="ZUBSOLV"
	replace bunavail=1 if Product_Drug_Name=="BUNAVAIL"
	replace suboxone=1 if Product_Drug_Name=="SUBOXONE"

	replace genBUPtab=1 if Product_Drug_Name=="BUPRENORPHINE HYDROCHLORIDE"|Product_Drug_Name=="BUPRENORPHINE"
	replace genBUPNALtab=1 if Product_Drug_Name=="BUPRENORPHINE-NALOXONE" & Master_Form=="Tablet"
	*replace genBUPNALfil=1 if Product_Drug_Name=="BUPRENORPHINE-NALOXONE" & Master_Form=="Film"

	replace BUP=1 if sublocade==1 | zubsolv==1|bunavail==1|suboxone==1|genBUPtab==1|genBUPNALtab==1
	replace IR_BUP=1 if BUP==1 & ER_BUP!=1 
	
	replace IR_film=1 if IR_BUP==1 & Master_Form=="Film" 
	
	* covered drug 	
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	replace cover`D'=1 if tier!="not_covered" & `D'==1
	}
	
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	sort formulary_id 
	by formulary_id: egen nNDCcover`D' =count(ndc) if cover`D'==1
	}
	
	* restriction 
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {
	gen `restrict'`D'=0
	replace `restrict'`D'=1 if `RES'=="t" & cover`D'==1	
	}
	
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {		
	sort formulary_id 
	by formulary_id: egen nNDC`restrict'`D' =count(ndc) if `restrict'`D'==1 & cover`D'==1			
	}
	
	** create plan-level variables 		
		* without `restrict' for at least 1 product 
	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {		
	sort formulary_id 
	by formulary_id: egen Y_cover`D' =max(cover`D') // at least cover one drug 
	by formulary_id: egen Y_`restrict'`D' =min(`restrict'`D') // without `restrict' for at least 1 product
	}	

	foreach D in BUP ER_BUP sublocade probuphine  zubsolv bunavail suboxone genBUPtab genBUPNALtab genBUPNALfil IR_BUP IR_film  IR_tablet {			
	sort formulary_id 
	by formulary_id: gen All`restrict'`D' = 1 if cover`D' ==1 & nNDCcover`D'== nNDC`restrict'`D'	// N NDCs covered = N NDCs with `restrict' within each plan - `restrict' for any products
	by formulary_id: gen No`restrict'`D' = 1 if cover`D' ==1 & nNDC`restrict'`D'==0	// without `restrict' for any bup products 
	}	
	
	collapse (mean) nNDCAll nNDCcover* nNDC`restrict'* Y_cover* Y_`restrict'* All`restrict'* No`restrict'*  ///
		(firstnm) name, by(formulary_id )
	gen year =`t'
		
	save "${intdir}/plan_formulary_BUP`restrict'`t'.dta", replace 
	export excel using $plotdir/plan_formulary_BUP_`restrict'`t', replace firstrow(var)	
	}  
	}
	
	

	  
log close
exit 
