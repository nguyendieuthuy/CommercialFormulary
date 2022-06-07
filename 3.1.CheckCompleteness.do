	
////////////////////////////////////////////////////////////////////////////////	
////////////////////////////////////////////////////////////////////////////////
*****EXERCISE 1: characterize plans **********	
***************************** HIOS plan IDs from formulary data ****************	
          forvalues t = 2017/2021 {     
	use "${Vcleandatadir}/formularies`t'.dta", clear 
	ren id formulary_id
	sort formulary_id 
	codebook formulary_id
	compress
	save "${intdir}/formularies_ID`t'.dta", replace 
	
	use "${Vcleandatadir}/formulary_plans`t'.dta", clear 
	sort formulary_id 
	merge m:1 formulary_id using  "${intdir}/formularies_ID`t'.dta", keep(1 3) nogen keepusing(name)	
	codebook formulary_id
	compress
	save "${intdir}/formulary_hios_ID`t'.dta", replace 	
	  }
  
	  
         forvalues t = 2017/2021 {  	
	use "${intdir}/formulary_hios_ID`t'.dta", clear 
	 sort formulary_id name hios_id 
	 order formulary_id name hios_id
	 duplicates drop formulary_id name hios_id, force 
	 drop if formulary_id==.
	 /*
	 keep if formulary_id ==19943 | formulary_id ==19944 | formulary_id ==59098
	export excel using $plotdir/HIOS_plan_name`t'-2021, replace firstrow(var)
	 */
	gen hios_id14=hios_id
	replace  hios_id14=subinstr(hios_id14,"-","",2)
	 
	gen l_id =length(hios_id14)
	replace hios_id14=substr(hios_id14,1,14)  if l_id>=16 

	tab l_id
	tab hios_id if l_id==11
	
	gen issue_id = substr(hios_id14,1,5) if l_id>=14
	
	sort hios_id14 issue_id
	codebook  // 108,711 HIOS plans
	save "${intdir}/formulary_hios_idclean`t'.dta", replace 	
	
	use "${intdir}/formulary_hios_idclean`t'.dta", clear 
	keep hios_id14 issue_id formulary_id name
	sort hios_id14 issue_id formulary_id name
	duplicates drop hios_id14 formulary_id, force 

	order hios_id14 formulary_id
	sort hios_id14 formulary_id
	bysort hios_id14 formulary_id: keep if _n==1
	
	codebook   // 30,578 14-digit HIOS plans /year
	save "${intdir}/formulary_hios_id14`t'.dta", replace 	
	 }	
	
	
**********characteristics
	use "${intdir}/formulary_hios_ID2017.dta", clear 
         forvalues t = 2018/2021 {     
	append using "${intdir}/formulary_hios_ID`t'.dta"
	 }	
	 codebook hios_id
	gen hios_id10=hios_id
	replace  hios_id10=subinstr(hios_id10,"-","",2)
	 
	gen l_id =length(hios_id10)
	tab l_id
	
	list hios_id hios_id10 if l_id==9 
	
	replace hios_id10=substr(hios_id10,1,10) 	

	 codebook formulary_id hios_id hios_id10 // 1,558 formulary_ID linked to 108,711 hios plans 
	
	sort formulary_id 
	merge m:1 formulary_id using  "${intdir}/formularyID_finalset_private.dta",keep(3) nogen 
	codebook hios_id formulary_id name hios_id10
	**** 460 of 866 Formulary IDs were merged to HIOS_plan (14 digit)
	* 76,044     HIOS plans (not cleaned) / 5381 (10-digit) plans
	save "${intdir}/formulary_id_withData_HIOS_ID_finalset_private.dta", replace 	
	
	
	** combined all HIOS IDs 	
	use "${Vcleandatadir}/cciio_hios_2020q1.dta", clear 
	append using "${Vcleandatadir}/cciio_hios_2020q2.dta"
	append using "${Vcleandatadir}/cciio_hios_2020q3.dta"
	append using "${Vcleandatadir}/cciio_hios_2020q4.dta"
	forvalues t = 2017/2019 { 
      forvalues q = 1/4 {       	
	append using "${Vcleandatadir}/cciio_hios_`t'q`q'.dta" , force 
	 }
	}
	codebook // 45,259 HIOS IDs 
	sort HIOSProductID HIOSIssuerID ProductType MarketType 
	bysort HIOSProductID: keep if _n==1 
	
	tab MarketType
	list ProductName if MarketType=="Large Group"
	drop if MarketType=="Large Group"
	/*
MarketType	Freq.	Percent	Cum.
			
Dental	2	0.00	0.00
Individual	22,131	48.90	48.91
Large Group	199	0.44	49.34
NO	1	0.00	49.35
Other	31	0.07	49.42
Small Group	22,893	50.58	100.00
			
Total	45,257	100.00
	
	*/
	codebook // 45,150 HIOS ID (10-digit) 
	gen hios_id10=HIOSProductID
	replace  hios_id10=subinstr(hios_id10,"-","",2)
	 
	sort hios_id10 
	merge 1:m hios_id10 using "${intdir}/formulary_id_withData_HIOS_ID_finalset_private.dta", keep(1 3)    // formulary_plan data 
	* only 2,083 10-digit HIOS IDs were matched to the CMS HIOS data out of 7,899 HIOS IDs with formulary IDs and data  
	codebook HIOSProductID hios_id10 formulary_id 
	codebook HIOSProductID hios_id10 formulary_id if _merge==3
	tab MarketType if _merge==3 // 40% are individual and 60% are small group. 
	
	keep if  _merge==3 
	drop _merge
	codebook // 439 formularies | 4034 Plans 
	save "${intdir}/cciio_Finder_formulary_mapped_2017_2020.dta",replace 	
	
////////////////////////////////////////////////////////////////////////////////
///////EXERCISE 2: COVERGE /////////////////////////////////////////////////////	
/////////////////////////////////ENROLLMENT DATA////////////////////////////////	
////////////////////////////////////////////////////////////////////////////////
	*** enrollment by plan data 
	forvalues t=2017/2020 {
	use  "${Vcleandatadir}/cciio_2019.dta", clear
	replace EverEnrolled="" if EverEnrolled=="*"
	destring EverEnrolled, replace 
	sum EverEnrolled
	gen hios_id10=substr(SelectedInsurancePlan,1,10) 	
	collapse (sum) EverEnrolled  , by(hios_id10)

	save "${intdir}/cciio_sum_enroll_`t'.dta",replace 	
	}

	use "${intdir}/cciio_sum_enroll_2017.dta", clear 
	forvalues t=2018/2020 {
	append using "${intdir}/cciio_sum_enroll_`t'.dta", force
	}
	collapse (mean) EverEnrolled  , by(hios_id10)
	sum EverEnrolled
	dis r(sum)  // 8,893,289 patients per year in total (average: 23,779/plan)
	** average enrollment per year
	codebook // 374 plans
	save "${intdir}/cciio_EverEnrolled_mean_2017_2020.dta",replace 	
	
	*** merge with final set of formulary data 
	
	
	use  "${intdir}/cciio_Finder_formulary_mapped_2017_2020.dta", clear 
	keep formulary_id name hios_id10
	sort formulary_id name hios_id10  // 499 formularies with HIOS data
	duplicates drop formulary_id name hios_id10, force  
	codebook // 5,388 10-digit HIOS IDs 
	
	sort hios_id10 
	merge m:1 hios_id10 using "${intdir}/cciio_EverEnrolled_mean_2017_2020.dta", keep(1 2 3)    // formulary_plan data 
	codebook 
	
	codebook hios_id10 formulary_id  if _merge==1 // 106 HIOS not matched, total enroll: 1352046
	sum EverEnrolled if _merge==1 
		dis r(sum)
	codebook hios_id10 formulary_id if _merge==2  // 4,842 HIOS not matched from using
	sum EverEnrolled if _merge==2 
		dis r(sum)
	codebook hios_id10 formulary_id if _merge==3 // 546 HIOS matched/204 formularies, total enroll: 5.497e+09
	sum EverEnrolled if _merge==3 
		dis r(sum)
		
		
	keep if _merge==3 
	sort hios_id10 
	bysort hios_id10: keep if _n==1 
	sum EverEnrolled if _merge==3 
		dis r(sum)   // 8572881 enrollees 
		dis 8572881/8893289 * 100   // 96.4% of Exchange 
	codebook
	// 134 formularies | 333 plans 
	

/////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
*** checking the comprehensive of coverage ***
	
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
*** LIST OF ALL FORURLARIES FOR THIS STUDY	
	******************** final set of formulary IDs ***************************
	use "${intdir}/plan_formulary_BUP2017_2021_private.dta", clear 
	codebook formulary_id name
	keep formulary_id 
	sort formulary_id
	bysort formulary_id: keep if _n==1 
	codebook // 905 Ids 
	save "${intdir}/formularyID_finalset_private.dta", replace  
	

	use "${intdir}/plan_formulary_BUP2017_2021_private.dta", clear 
	keep name 
	sort name
	bysort name: keep if _n==1 
	codebook // 866 Ids 
	export excel using $tabledir/ALl_PrivateFormularyplan_formulary_BUP2017_2021, replace firstrow(var)	
	
	
	use "${intdir}/plan_formulary_BUP2017_2021_private.dta", clear 
	codebook formulary_id name
	keep if n_npi!=. 
	keep formulary_id 
	sort formulary_id
	bysort formulary_id: keep if _n==1 
	codebook // 451 Ids 
	save "${intdir}/formularyID_finalset_private_with_networkSize.dta", replace  
	
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////	
	*************** number of plans associated with formularies***************

	use "${intdir}/formulary_hios_id142017.dta", clear 
         forvalues t = 2018/2021 {     
	append using "${intdir}/formulary_hios_id14`t'.dta"
	 }
	sort formulary_id 
	codebook 
	merge m:1 formulary_id using  "${intdir}/formularyID_finalset_private.dta",keep(3) 
	codebook formulary_id hios_id14 name
	**** 460 of 866 Formulary IDs were merged to HIOS_plan (14 digit)
	* 65,089 HIOS plans 

	// identify the formulary IDs were used most frequently [exporting a table]
	sort formulary_id hios_id14 
	bysort formulary_id hios_id14: keep if _n==1
	bysort formulary_id: egen nHOIS =nvals(hios_id14)
	
	bysort formulary_id: keep if _n==1
	
	sum nHOIS // 74,524 HIOS plans were linked to 460 (can have multiple formulary IDs)
	dis r(sum)
	sort nHOIS 
		
	xtile DnHOIS = nHOIS , nq(10)
	tab DnHOIS
	codebook formulary_id nHOIS name if DnHOIS==1 // lowest: 53 formulary IDs; n HOIS range: 1-6 
	codebook formulary_id nHOIS name if DnHOIS==10 // highest: 46 formulary IDs, n HIOIS: 320-9409 
	
	drop _merge 
	order name formulary_id nHOIS 
	gen negative = -nHOIS
	keep name nHOIS DnHOIS
	sort nHOIS 
	codebook  // 460 names 
	

	*********** final sample of formularies in the analysis
	use "${intdir}/plan_formulary_BUP2017_2021_private.dta", clear 		
	codebook formulary_id               // 866 formulary IDs
	codebook formulary_id if n_npi!=.  // only 451 formulary IDs 
	
	use "${intdir}/plan_formulary_BUP2017_2021_ALL.dta", clear 		
	codebook formulary_id               // 3085 formulary IDs
	codebook formulary_id if n_npi!=.  // only 982 formulary IDs 	
	

////////////////////////////////////////////////////////////////////////////////
///////EXERCISE 3: Network size///////////////////////////////////////////////////	
//////////////////////////////////////////////////////////////////////////////////////////////	
* track NPIs for the entire database 	
	forvalues t = 2020/2021 {
	use provider_id using "${Vcleandatadir}/network_providers`t'.dta", clear
	compress
	ren provider_id npi 
	save "${intdir}/network_providers_npi`t'.dta", replace 
	}

	forvalues t = 2017/2019 {
	use npi using "${Vcleandatadir}/network_providers`t'.dta", clear
	compress
	save "${intdir}/network_providers_npi`t'.dta", replace 
	}

	use "${intdir}/network_providers_npi2017.dta", clear
	forvalues t = 2018/2021 {
	append using "${intdir}/network_providers_npi`t'.dta"
	}
	egen n_npi=nvals(npi)
	sum n_npi // 5913980
	dis 5913980
		
	use "/media/thuy/13c83ca8-25b7-471b-a983-b67d635be41c/Projects/DEAwaiver/intermediate_results/nppes_id2019.dta", clear 
	egen n_npi=nvals(npi)
	sum n_npi // 2,589,316/ 5943659
	dis 3069595/ 5943659*100 // = 51.64% 

	use "/media/thuy/13c83ca8-25b7-471b-a983-b67d635be41c/Projects/DEAwaiver/intermediate_results/nppes_id2021.dta", clear 
	egen n_npi=nvals(npi)
	sum n_npi // 2,589,316/ 5943659
	dis 5913980/ 7086961*100 // = 51.64% 

	
	
	* track NPIs for the sample  
		
	use "${intdir}/formularyID_finalset_private_with_networkSize.dta", clear  // 490 formularies with network data 	
	merge 1:m formulary_id using "${intdir}/1558formulary_id_unique_hios_ID14_2017_2021.dta",keep(3) nogen 
	codebook formulary_id
	* 490 formulary_ID were matched | 65,100 HIOS plans 	
	keep hios_id14 
	duplicates drop hios_id14, force 
	sort hios_id14 
	save "${intdir}/unique_hios_id14_490Formulary.dta", replace 	
	
	forvalues t = 2020/2021 {	
	use "${Vcleandatadir}/network_plans`t'.dta", clear 
	ren external_plan_id hios_id 	
	gen hios_id14=hios_id
	replace  hios_id14=subinstr(hios_id14,"-","",2)	 
	gen l_id =length(hios_id14)
	replace hios_id14=substr(hios_id14,1,14) 
	sort hios_id14
	
	merge m:1 hios_id14 using  "${intdir}/unique_hios_id14_490Formulary.dta", keep(3) nogen 
	save "${intdir}/unique_hios_id14_490Formulary`t'.dta", replace 	
	
	keep network_id 
	duplicates drop network_id, force 
	save "${intdir}/unique_network_id_490Formulary`t'.dta", replace 	
	
	}
	
	forvalues t = 2017/2019 {	
	use "${Vcleandatadir}/network_plans`t'.dta", clear 
	gen hios_id14=hios_id
	replace  hios_id14=subinstr(hios_id14,"-","",2)	 
	gen l_id =length(hios_id14)
	replace hios_id14=substr(hios_id14,1,14)  
	sort hios_id14
	
	merge m:1 hios_id14 using  "${intdir}/unique_hios_id14_490Formulary.dta", keep(3) nogen 
	save "${intdir}/unique_hios_id14_490Formulary`t'.dta", replace 	

	keep network_id 
	duplicates drop network_id, force 
	save "${intdir}/unique_network_id_490Formulary`t'.dta", replace 	
	
	}
	** check NETWORK DATA 
	forvalues t = 2020/2021 {
	use provider_id network_id using  "${Vcleandatadir}/network_providers`t'.dta", clear
	sort network_id
	merge m:1 network_id using "${intdir}/unique_network_id_490Formulary`t'.dta", keep(3) nogen 
	ren provider_id npi 
	save "${intdir}/unique_npi_490Formulary`t'.dta", replace 
	}
	
	forvalues t = 2017/2019 {
	use npi network_id using  "${Vcleandatadir}/network_providers`t'.dta", clear
	sort network_id
	merge m:1 network_id using "${intdir}/unique_network_id_490Formulary`t'.dta", keep(3) nogen 
	save "${intdir}/unique_npi_490Formulary`t'.dta", replace 
	}


	use "${intdir}/unique_npi_490Formulary2021.dta", clear
	egen n_npi=nvals(npi)
	sum n_npi // 2393882
	dis 2393882/7086961 // 33.8%

	forvalues t = 2017/2020 {
	use "${intdir}/unique_npi_490Formulary`t'.dta", clear 
	egen n_npi=nvals(npi)
	sum n_npi
	}
	// 2017:  2517765
	// 2018:  2484311 
	// 2019:  2357664 
	// 2020: 2424222
	// 2021: 2393882
	dis 2517765/5250049
	dis 2484311/5756857
	dis 2357664/5943659
	dis 2424222/6410979
	dis 2390858/7086961
	** 33.7% to 48%. 
	
		
	
	
