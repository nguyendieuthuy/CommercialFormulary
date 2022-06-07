
/* Start log */
capture log close
log using "${logdir}/1.6.HIOS_Sample.log", replace


* a set of formularies over time ** 

	use "${intdir}/plan_formulary_BUP2018.dta", clear
	sum Y_covergenBUPNALfil
	
	
	use  "${intdir}/plan_formulary_BUP2021.dta", clear 
	merge m:1 formulary_id using "${intdir}/plan_formulary_BUP2020.dta", nogen keep(3)	
	merge m:1 formulary_id using "${intdir}/plan_formulary_BUP2019.dta", nogen keep(3)
	merge m:1 formulary_id using "${intdir}/plan_formulary_BUP2018.dta", nogen keep(3)   // keep 2,349 plans appeared in 2018-2021 
	merge m:1 formulary_id using "${intdir}/plan_formulary_BUP2017.dta", nogen keep(3)   // keep 2,000 plans appeared in 2017-2021 

	keep formulary_id
	sort formulary_id
	by formulary_id: keep if _n==1

	codebook // 2057 formularies 
	save "${intdir}/unique_plan_formulary_id2017_2021.dta", replace 	



** formulary data ** 
        forvalues t = 2017/2021 {     
	use "${Vcleandatadir}/formulary_plans`t'.dta", clear // formulary - HIOS mapping
	sort formulary_id 
	codebook formulary_id
	save "${intdir}/formulary_hios_ID`t'.dta", replace 	
	  }
	  
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
	  ** formulary ID with data ** 
        forvalues t = 2017/2021 {     	  
	use formulary_id using "${Vcleandatadir}/drug_package_formularies`t'.dta", clear 
	bysort formulary_id: keep if _n==1
	codebook formulary_id  
	save "${intdir}/formulary_id_withData`t'.dta", replace 	
		} 
	
	use "${intdir}/formulary_id_withData2017.dta", clear 
         forvalues t = 2018/2021 {     
	append using "${intdir}/formulary_id_withData`t'.dta"
	 }
	 sort formulary_id 
	 codebook  // 3,224 IDs 
	by formulary_id: keep if _n==1	 
	save "${intdir}/formulary_id_withData_All_2017_2021.dta", replace 	
		
		
	
	  
	*** all formularies with HIOS IDs *** 	  
	use "${intdir}/formulary_hios_ID2017.dta", clear 
         forvalues t = 2018/2021 {     
	append using "${intdir}/formulary_hios_ID`t'.dta"
	 }
	 sort hios_id formulary_id 
	 codebook  // 108,711 HIOS plans  | 1,558 formulary IDs with HIOS ID | 1548 names 
	save "${intdir}/formulary_hios_All_2017_2021.dta", replace 	
	
		** subset of formularies without HIOS IDs 
	use "${intdir}/formulary_hios_All_2017_2021.dta", clear 
	keep formulary_id
	sort formulary_id
	by formulary_id: keep if _n==1

	merge m:1 formulary_id using "${intdir}/unique_plan_formulary_id2017_2021.dta", keep(3) nogen 
	
	save "${intdir}/Subset_formulary_withHIOS_All_2017_2021.dta", replace 	

	use "${intdir}/formulary_id_withData_All_2017_2021.dta", clear 
	merge m:1 formulary_id using "${intdir}/unique_plan_formulary_id2017_2021.dta", keep(3) nogen 
	
	
	merge m:1 formulary_id using "${intdir}/Subset_formulary_withHIOS_All_2017_2021.dta"
	/*
	    Not matched                         1,667
		from master                     1,666  (_merge==1)
		from using                          1  (_merge==2)    // no formulary data 

	    Matched                             1,558  (_merge==3)		
	*/
	gen mappedFormularyID= 1 if _merge==3 
	gen nonmappedFormularyID= 1 if _merge==1 
	gen noFormularydataID= 1 if _merge==2 
	drop _merge
	codebook
	save "${intdir}/ThreeSubset_formulary_All_2017_2021.dta", replace 	

	
	*** formulary with manual classification ***
	use "${intdir}/plan_formulary_id_name_group2017_2021v2.dta", clear 
	codebook 
	/*
		2427 formulary IDs 	
		427	"Medicaid"
		751	"Medicare"
		75	"No plan name"
		53	"Other"
		1,092	"Private"
		29	"Unclassified"	
	*/
	
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
	* mapping with the CMS lsit * 

	
	
	use "${intdir}/formulary_hios_All_2017_2021.dta", clear 

	 sort formulary_id name hios_id
	 duplicates drop formulary_id name hios_id, force 
	 drop if formulary_id==.
	 
	 merge m:1 formulary_id using "${intdir}/unique_plan_formulary_id2017_2021.dta", keep(3) 
	 codebook  // 87,413  HIOS plans  | 992 formulary IDs with HIOS ID | 992 names 	 
	 
	 * 10-digit HIOS 
	gen hios_id10=hios_id
	replace  hios_id10=subinstr(hios_id10,"-","",2)
	 
	gen l_id =length(hios_id10)
	tab l_id
	
	list hios_id10 if l_id==14 & _n<1000
	list hios_id10 if l_id==16 & _n<1000
	list hios_id10 if l_id<14 & _n<5000  // non-standard HIOS (e.g. H52640020; H52640030; S48020120 )
	gen Initial_hios = substr(hios_id10,1,1) 
		tab Initial_hios
	list hios_id10 if Initial_hios=="E"  // non-standard HIOS (e.g. H52640020; H52640030; S48020120 )
	list hios_id10 if Initial_hios=="R" & _n<5000  // non-standard HIOS (e.g. H52640020; H52640030; S48020120; R53290010;R74440010; E30148010;E30148020  )
		
	replace hios_id10=substr(hios_id10,1,10) 	
	gen issue_id = substr(hios_id10,1,5)
		
	keep hios_id10 issue_id formulary_id name hios_id
	sort hios_id10 formulary_id name hios_id 

	codebook  // 992 formulary ID - 11,481 (10-digit HIOS IDs) 
	order hios_id10 formulary_id
	sort hios_id10 formulary_id
	bysort hios_id10 formulary_id: keep if _n==1	
	save "${intdir}/formulary_hios_id10_clean2017_2021.dta", replace 	


	** combined all HIOS IDs [CMS LIST]	
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

	drop if MarketType=="Large Group" 
	
	sort hios_id10 
	merge 1:m hios_id10 using "${intdir}/formulary_hios_id10_clean2017_2021.dta", keep(1 3)    // formulary_plan data 
	* only 4144 10-digit HIOS IDs were matched to the CMS HIOS data out of 13,903 HIOS IDs with formulary IDs and data  | 478 formularies 
	codebook HIOSProductID hios_id10 formulary_id if _merge==3
	
	
	
	tab MarketType if _merge==3 // 40% are individual and 60% are small group. 
	/* by HIOS 
	MarketType	Freq.	Percent	Cum.				
 Individual |      1,980       36.84       36.84
Large Group |          1        0.02       36.86
Small Group |      3,393       63.14      100.00
      Total |      5,374      100.00
	*/
	codebook hios_id10 formulary_id if _merge==3 & MarketType=="Individual"
	codebook hios_id10 formulary_id if _merge==3 & MarketType=="Small Group"
	save "${intdir}/cciio_formulary_matchingALl_2017_2021.dta", replace 	

	
	*** COUNT - plnas 	
	// identify the formulary IDs were used most frequently [exporting a table]
	use "${intdir}/cciio_formulary_matchingALl_2017_2021.dta", clear 
	keep if _merge==3 
	merge m:1 formulary_id using "${intdir}/plan_formulary_id_name_group2017_2021v2.dta", nogen keep(1 3)  // 2,427 formulary with classification (as 2020)
	drop if insurancetype_final!="Private"

	codebook formulary_id hios_id10
	sort formulary_id hios_id10 
	bysort formulary_id hios_id10: keep if _n==1
	bysort formulary_id: egen nHOIS =nvals(hios_id10)
	
	bysort formulary_id: keep if _n==1
	
	sum nHOIS // 5373 HIOS plans were linked to 460 (can have multiple formulary IDs)
	dis r(sum)
	
	
	
/////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
	** subset 1: matched formulary 
	use "${intdir}/cciio_formulary_matchingALl_2017_2021.dta", clear 
	keep if _merge==3 
	keep formulary_id ProductName ProductType MarketType
	sort formulary_id MarketType
	order formulary_id MarketType
	
	bysort formulary_id MarketType: keep if _n==1 
	bysort formulary_id: egen count_type = count(MarketType)

	tab MarketType // 995 
	
	tab count_type
	
	gen SmallGroup=1 if MarketType=="Small Group" & count_type==1 	
	gen Individual=1 if MarketType=="Individual" & count_type==1 
	gen Small_IndividualGroup=1 if count_type==2
	

	list if formulary_id==60746 // large group (also small group)
	
	sort formulary_id SmallGroup Individual  Small_IndividualGroup
	bysort formulary_id: keep if _n==1 
	codebook formulary_id 
	sum SmallGroup Individual  Small_IndividualGroup
	keep formulary_id SmallGroup Individual  Small_IndividualGroup  // 650 formularies 
	codebook 
	save "${intdir}/formulary_Set1_matched_cciio_2017_2021.dta", replace 	
	
	** subset 2: formulary without HIOS IDs 
	use "${intdir}/ThreeSubset_formulary_All_2017_2021.dta", clear 
	sum mappedFormularyID nonmappedFormularyID noFormularydataID
	
	merge 1:1 formulary_id using "${intdir}/formulary_Set1_matched_cciio_2017_2021.dta", keep(1 3)  // 650 formulary mapped with CCIIO list 
	
	gen Group1_CMS=1 if _merge==3 
	drop _merge 
	tab Group1_CMS

	merge 1:1 formulary_id using "${intdir}/plan_formulary_id_name_group2017_2021v2.dta", nogen keep(1 3)  // 2,427 formulary with classification (as 2020)
	sum mappedFormularyID nonmappedFormularyID noFormularydataID SmallGroup Individual Small_IndividualGroup if insurancetype_final=="Private"
	
	** group 1: mapped to the CMS list 
	sum mappedFormularyID nonmappedFormularyID noFormularydataID SmallGroup Individual Small_IndividualGroup if Group1_CMS==1
	tab Group1_CMS
	tab insurancetype_final if Group1_CMS==1
	
	replace Group1_CMS=0 if Group1_CMS==1 & insurancetype_final!="Private"
	
	
	/*
	Variable	Obs	Mean	Std.	dev.	Min	Max							
	SmallGroup	115	1		0	1	1
	Individual	190	1		0	1	1
	LargeGroup	1	1		.	1	1
	Small_Indi~p	344	1		0	1	1
	*/
	** group 2: no HIOS ID, classified as private 
	gen Group2_private_noHIOS = 1 if nonmappedFormularyID==1 & insurancetype_final=="Private"
	tab Group2_private_noHIOS  // 563 of 1,666
	
	** group 3: have HIOS ID but unmapped to the CMS list, classified as private 
	gen Group3_private_HIOS = 1 if mappedFormularyID==1 & insurancetype_final=="Private" & Group1_CMS!=1 
	tab mappedFormularyID
	tab Group3_private_HIOS  // 23 of [529 mapped and unmapped to the CMS list] of 1,558 with HIOS ID 
	codebook 

	sum Group1_CMS Group2_private_noHIOS Group3_private_HIOS

	save "${intdir}/formulary_3privateFormulary_2017_2021.dta", replace 	
	
	keep if Group2_private_noHIOS==1 
	keep formulary_id name
	order name formulary_id 
	sort name 
	save "${intdir}/Vericred_563formulary_NoHIOS_2017_2021.dta", replace 	
	export delimited using  "${intdir}/Vericred_563formulary_NoHIOS_private_2017_2021.csv", replace 
	
/*	
	
///////////////////////////////////////////////////////////////////////////////////	
	  
	use "${Vcleandatadir}/formularies2017.dta", clear 
       forvalues t = 2018/2021 {     	
	append using "${Vcleandatadir}/formularies`t'.dta" 
       }
       ren id formulary_id
       sort formulary_id name 
       bysort formulary_id name: keep if _n==1 
       codebook
  	save "${intdir}/formulary_unique_name_ALL2017_2021.dta", replace // 3,128 formularies 
     
       
	
	** any formulary without HIOS IDs 
	use "${intdir}/ThreeSubset_formulary_All_2017_2021.dta", clear 
	sum mappedFormularyID nonmappedFormularyID noFormularydataID
	
	merge 1:1 formulary_id using "${intdir}/formulary_Set1_matched_cciio_2017_2021.dta", keep(1 3)  // 650 formulary mapped with CCIIO list 	
	gen Group1_CMS=1 if _merge==3 
	drop _merge 
	tab Group1_CMS

	merge 1:1 formulary_id using "${intdir}/formulary_unique_name_ALL2017_2021.dta", nogen keep(1 3)  // 2,427 formulary with classification (as 2020)


	** group 2: no HIOS ID, classified as private 
	gen Group2_noHIOS = 1 if nonmappedFormularyID==1 
	tab Group2_noHIOS  // 1,666
	
	
	keep if Group2_noHIOS==1 
	keep formulary_id name
	order name formulary_id 
	sort name 
	codebook
	save "${intdir}/Vericred_1666formulary_NoHIOS_2017_2021.dta", replace 	
	export delimited using  "${intdir}/Vericred_1666formulary_NoHIOS_2017_2021.csv", replace 
	
	
	
	
	
	
	
	
