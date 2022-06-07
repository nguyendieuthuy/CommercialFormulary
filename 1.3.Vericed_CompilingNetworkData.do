
/* Start log */
capture log close
log using "${logdir}/1.3.Formulary_CompilingNetworkData.log", replace


	

/////////////////////////////// checking data //////////////////////////////////
	forvalues t = 2020/2021 {
	use  "${Vcleandatadir}/network_providers`t'.dta", clear
	hashsort network_id 
	bysort network_id: egen n_npi=nvals(provider_id)
	gcollapse (mean) n_npi,by(network_id)
	
	merge 1:m network_id using "${Vcleandatadir}/network_plans`t'.dta", keep(3) keepusing(external_plan_id) nogen 
	ren external_plan_id hios_id 
	codebook 
	sort hios_id
	save "${intdir}/plans_n_npi`t'.dta", replace 
	}
	
	forvalues t = 2019/2019 {
	use  "${Vcleandatadir}/network_providers`t'.dta", clear
	hashsort network_id 
	bysort network_id: egen n_npi=nvals(npi)
	gcollapse (mean) n_npi,by(network_id)
	
	merge 1:m network_id using "${Vcleandatadir}/network_plans`t'.dta", keep(3) keepusing(hios_id) nogen 
	codebook 
	sort hios_id
	save "${intdir}/plans_n_npi`t'.dta", replace 
	}	
	
	*************** merging to formulary data ****************************
	  
        forvalues t = 2019/2019 {     
	use "${intdir}/formulary_hios_ID`t'.dta",clear	
	sort hios_id 
	merge 1:m hios_id using "${intdir}/plans_n_npi`t'.dta",keep(3) nogen 
	save "${intdir}/formulary_hios_n_npi`t'.dta",replace 	
	} 		  

        forvalues t = 2020/2021 {     
	use "${intdir}/formulary_hios_ID`t'.dta",clear	
	sort hios_id 
	merge 1:m hios_id using "${intdir}/plans_n_npi`t'.dta",keep(3) nogen 
	save "${intdir}/formulary_hios_n_npi`t'.dta",replace 	
	} 		  

	use  "${intdir}/formulary_hios_n_npi2017.dta", clear
	append using "${intdir}/formulary_hios_n_npi2018.dta"
	append using "${intdir}/formulary_hios_n_npi2020.dta"
	append using "${intdir}/formulary_hios_n_npi2021.dta"
	
	codebook // 80,572 hios_ids, 968 formulary_id, 2001 network_id 
	
	sort hios_id formulary_id n_npi
	duplicates drop  hios_id formulary_id n_npi, force
	gen sum_n_npi=n_npi  
	sum
	collapse (mean) n_npi (sum) sum_n_npi, by(formulary_id)
	save "${intdir}/formulary_n_npi2017_2021.dta",replace 	

	
////////////////////////////////////////////////////////////////////////////////	
////////////////////////////////////////////////////////////////////////////////
	*** enrollment by plan data 
	use  "${Vcleandatadir}/cciio_2019.dta", clear
	append using "${Vcleandatadir}/cciio_2018.dta", force
	append using "${Vcleandatadir}/cciio_2017.dta", force
	codebook
	replace EverEnrolled="" if EverEnrolled=="*"
	destring EverEnrolled, replace 
	sum EverEnrolled
	save "${intdir}/cciio_2017_2019.dta",replace 	
	
	use "${intdir}/cciio_2017_2019.dta", clear 
	gen issuer_Enrolled = EverEnrolled
	gen hios_plan_Enrolled = EverEnrolled	
	collapse (mean) issuer_Enrolled , by(IssuerHIOSID) 
	sort IssuerHIOSID
	save "${intdir}/cciio_issuer_Enrolled_2017_2019.dta",replace 		
	
	use "${intdir}/cciio_2017_2019.dta", clear 
	gen issuer_Enrolled = EverEnrolled
	gen hios_plan_Enrolled = EverEnrolled	
	collapse (mean) hios_plan_Enrolled , by(SelectedInsurancePlan) 
	ren SelectedInsurancePlan hios_id 
	sort hios_id 
	save "${intdir}/cciio_hios_Enrolled_2017_2019.dta",replace 		
	
	use "${intdir}/cciio_2017_2019.dta", clear 
	keep SelectedInsurancePlan 
	ren SelectedInsurancePlan hios_id14
	duplicates drop hios_id14, force
	** 5,293 hios_id (14 digit)
	sort hios_id14
	codebook hios_id14
	save "${intdir}/cciio_crosswalk2017_2019.dta",replace 		
		
	
////////////////////////////////////////////////////////////////////////////////	
////////////////////////////////////////////////////////////////////////////////	
***************************** HIOS plan IDs from formulary data ****************	
        forvalues t = 2017/2021 {     
	use "${Vcleandatadir}/formulary_plans`t'.dta", clear 
	sort formulary_id 
	codebook formulary_id
	compress
	save "${intdir}/formulary_hios_ID`t'.dta", replace 	
	  }
	  
	use "${intdir}/formulary_hios_ID2017.dta", clear 
         forvalues t = 2018/2021 {     
	append using "${intdir}/formulary_hios_ID`t'.dta"
	 }
	 keep hios_id 
	 duplicates drop hios_id, force 
	 sort hios_id 
	 codebook  // 108,711 HIOS plans
	save "${intdir}/formulary_unique_hios_IDs2017_2021.dta", replace 	
	
	
	
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
	replace  hios_id14=subinstr(hios_id14,"-","",1)
	 
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
	
	 
	use "${intdir}/formulary_hios_id142017.dta", clear 
         forvalues t = 2018/2021 {     
	append using "${intdir}/formulary_hios_id14`t'.dta"
	 }
	 
	save "${intdir}/1558formulary_id_unique_hios_ID14_2017_2021.dta", replace 	
	 
	 codebook 
	 keep hios_id14 
	 duplicates drop hios_id14, force 
	 sort hios_id14 
	 codebook  //  87,414 HIOS plans
	save "${intdir}/formulary_unique_hios_ID14_2017_2021.dta", replace 	
	 

/////////////////////////////// clean HIOS ID from network data //////////////////////////////////
	forvalues t = 2020/2021 {
	use  "${Vcleandatadir}/network_providers`t'.dta", clear
	hashsort network_id 
	bysort network_id: egen n_npi=nvals(provider_id)
	gcollapse (mean) n_npi,by(network_id)
	
	merge 1:m network_id using "${Vcleandatadir}/network_plans`t'.dta", keep(3) keepusing(external_plan_id) nogen 
	ren external_plan_id hios_id 
	
	gen hios_id14=hios_id
	replace  hios_id14=subinstr(hios_id14,"-","",1)	 
	gen l_id =length(hios_id14)
	replace hios_id14=substr(hios_id14,1,14)  if l_id>=16 
	tab l_id
	tab hios_id if l_id==11	
	gen issue_id = substr(hios_id14,1,5) if l_id>=14	
	sort hios_id14 issue_id

	gcollapse (mean) n_npi,by(hios_id14)	
	save "${intdir}/network_plans_n_npi`t'.dta", replace 
	}
	
	forvalues t = 2017/2019 {
	use  "${Vcleandatadir}/network_providers`t'.dta", clear
	hashsort network_id 
	bysort network_id: egen n_npi=nvals(npi)
	gcollapse (mean) n_npi,by(network_id)
	
	merge 1:m network_id using "${Vcleandatadir}/network_plans`t'.dta", keep(3) keepusing(hios_id) nogen 
	gen hios_id14=hios_id
	replace  hios_id14=subinstr(hios_id14,"-","",1)	 
	gen l_id =length(hios_id14)
	replace hios_id14=substr(hios_id14,1,14)  if l_id>=16 
	tab l_id
	tab hios_id if l_id==11	
	gen issue_id = substr(hios_id14,1,5) if l_id>=14	
	sort hios_id14 issue_id
	gcollapse (mean) n_npi,by(hios_id14)	
	save "${intdir}/network_plans_n_npi`t'.dta", replace 
	}	
	* clean HIOS PLAN ID
	use "${intdir}/network_plans_n_npi2017.dta", clear	
      forvalues t = 2018/2021 {  	
	append using "${intdir}/network_plans_n_npi`t'.dta" 
      }
	sort hios_id hios_id14
	 duplicates drop hios_id14, force 	
	codebook   // 79,349 HIOS plans /year
	save "${intdir}/network_plans_all_hios_id2017_2021.dta", replace 	
	
	
	use "${intdir}/network_plans_n_npi2017.dta", clear	
      forvalues t = 2018/2021 {  	
	append using "${intdir}/network_plans_n_npi`t'.dta" 
      }
	keep hios_id14
	 duplicates drop hios_id14, force 	
	codebook   // 79,349 14-digit HIOS plans /year
	save "${intdir}/network_plans_unique_hios_id142017_2021.dta", replace 	


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
* merging using 14-digit HIOS plan ID  
	forvalues t = 2020/2021 {
	use  "${Vcleandatadir}/network_providers`t'.dta", clear
	hashsort network_id 
	bysort network_id: egen n_npi=nvals(provider_id)
	gcollapse (mean) n_npi,by(network_id)
	
	merge 1:m network_id using "${Vcleandatadir}/network_plans`t'.dta", keep(3) keepusing(external_plan_id) nogen 
	ren external_plan_id hios_id 
	
	gen hios_id14=hios_id
	replace  hios_id14=subinstr(hios_id14,"-","",1)	 
	gen l_id =length(hios_id14)
	replace hios_id14=substr(hios_id14,1,14)  if l_id>=16 
	tab l_id
	tab hios_id if l_id==11	
	gen issue_id = substr(hios_id14,1,5) if l_id>=14	
	sort hios_id14 issue_id

	gcollapse (mean) n_npi,by(hios_id14)	
	save "${intdir}/network_plans_n_npi`t'.dta", replace 
	}
	
	forvalues t = 2017/2019 {
	use  "${Vcleandatadir}/network_providers`t'.dta", clear
	hashsort network_id 
	bysort network_id: egen n_npi=nvals(npi)
	gcollapse (mean) n_npi,by(network_id)
	
	merge 1:m network_id using "${Vcleandatadir}/network_plans`t'.dta", keep(3) keepusing(hios_id) nogen 
	gen hios_id14=hios_id
	replace  hios_id14=subinstr(hios_id14,"-","",1)	 
	gen l_id =length(hios_id14)
	replace hios_id14=substr(hios_id14,1,14)  if l_id>=16 
	tab l_id
	tab hios_id if l_id==11	
	gen issue_id = substr(hios_id14,1,5) if l_id>=14	
	sort hios_id14 issue_id
	gcollapse (mean) n_npi,by(hios_id14)	
	save "${intdir}/network_plans_n_npi`t'.dta", replace 
	}
	
	
	use "${intdir}/formulary_unique_hios_ID14_2017_2021.dta", clear
	sort hios_id14 
	merge 1:m hios_id14 using "${intdir}/network_plans_unique_hios_id142017_2021.dta"
	 
	
	forvalues t = 2017/2021 {
	use  "${intdir}/formulary_hios_idclean`t'.dta", clear 
	sort hios_id14 
	merge m:1 hios_id14 using "${intdir}/network_plans_n_npi`t'.dta",keepusing(n_npi) keep(1 3)
	sort formulary_id 
	save "${intdir}/formulary_n_npi_matched`t'.dta", replace 
	}
	
	use  "${intdir}/formulary_n_npi_matched2017.dta", clear 	 
	forvalues t = 2018/2021 {
	append using "${intdir}/formulary_n_npi_matched`t'.dta" 
	}
	gcollapse (mean) n_npi,by(formulary_id)
	codebook formulary_id // 1,558 formulary ID 
	save "${intdir}/formulary_n_npi_matched2017_2021.dta", replace    // using HIOS_14 
	
	
	 
	 

	
	
/*	 
	** check a panel set of HIOS-ID  
	** keep balanced panel of plans in 2017-2021
	use  "${intdir}/all_hios_IDs2017_2021.dta", clear 
	merge m:1 hios_id using "${intdir}/formulary_hios_ID2021.dta", nogen keep(3)	
	merge m:1 hios_id using "${intdir}/formulary_hios_ID2020.dta", nogen keep(3)
	merge m:1 hios_id using "${intdir}/formulary_hios_ID2019.dta", nogen keep(3)  
	merge m:1 hios_id using "${intdir}/formulary_hios_ID2018.dta", nogen keep(3)  
	merge m:1 hios_id using "${intdir}/formulary_hios_ID2017.dta", nogen keep(3)  // only 7,534/108,711 plans 

	keep hios_id
	sort hios_id
	by hios_id: keep if _n==1
	save "${intdir}/unique_plan_formulary_id2017_2021_hios.dta", replace 	

	use "${intdir}/all_hios_IDs2017_2021.dta", clear
	split hios_id, parse("-")
	
	gen hios_id_clean = hios_id 
	
	
	gen l_id =length(hios_id1)
	tab l_id 
	tab hios_id if l_id==15
	tab hios_id if l_id==5
	
	
log close
exit

	
	

