
/* Start log */
capture log close
log using "${logdir}/Formulary_CompilingData.log", replace

** check list of FDA - NDC package code 
	import delimited "${Rootdatadir}/FDA-NDC/package.txt", clear
	codebook // 211,131 ndc package code 
	
	dis 168146 /211131*100
	

/////////////////////////////// checking data //////////////////////////////////
	* name for formulary networks
	use "${Vcleandatadir}/drug_package_formularies2017.dta", clear 
   
	tab tier 
	codebook formulary_id 
	
	use "${Vcleandatadir}/drug_package_formularies2021.dta", clear 
   
	codebook formulary_id ndc_package_code 	// 168,146 NDCs package codes 
	/*
non_preferred_brand	15,077,736	7.56	7.56
non_preferred_generic	18,646,320	9.35	16.91
non_preferred_specialty	844,751	0.42	17.33
not_covered	61,921,345	31.05	48.38
not_listed	7,905,514	3.96	52.34
preferred_brand	6,476,418	3.25	55.59
preferred_generic	88,568,128	44.41	100.00

	*/
	* name for formulary ID 
	use "${Vcleandatadir}/formularies2017.dta", clear 
	codebook id name 
	use "${Vcleandatadir}/formulary_plans2017.dta", clear 
	codebook formulary_id hios_id
		* 821 unque formulary_id | 44,577 hios_id (which is different from ID in formularies file)
		
	use "${Vcleandatadir}/network_plans2017.dta", clear 
	codebook hios_id network_id name 
	sort hios_id network_id name
	ren network_id formulary_id 
	sort formulary_id
	

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
	  		
	use "${intdir}/formulary_hios_ID2017.dta", clear 
	codebook 
		
** extract MOUD-related formularies 
          forvalues t = 2017/2021 {     
	use "${Vcleandatadir}/drug_package_formularies`t'.dta", clear 
	
	sort formulary_id	
	merge m:1 formulary_id using  "${intdir}/formularies_ID`t'.dta", keep(1 3) nogen keepusing(name)
	gen year =`t'
	
	
	gen ndc = subinstr(ndc_package_code,"-","",.)	
	sort ndc 
	gen N_id_ndc = _N 	
	egen n_unique_id =nvals(formulary_id)		
	egen n_unique_ndc =nvals(ndc)		

	label var n_unique_id "N unique formulary IDs per year"
	label var n_unique_ndc "N unique NDC per year"
	
	
	gen ndc_9 = substr(ndc,1,9)
		gen vivitrol=1 if ndc =="65757030001" |  ndc =="65757030202"|  ndc =="65757030403" | ndc =="63459030042"	
		replace vivitrol=1 if regex(ndc_9, "657570300")|regex(ndc_9, "657570302")| regex(ndc_9, "634590300")  			
	
	merge m:1 ndc using  "${intdir}/CDC_NDC_and_mmeBup_Opioid_2020.dta", keep(1 3) nogen keepusing(BUP opioid Product_Drug_Name LongShortActing DEAClassCode Master_Form ER_BUP)
	
	replace BUP=1 if regex(ndc_9, "007817216")|regex(ndc_9, "007817227")|regex(ndc_9, "007817238")|regex(ndc_9, "007817249")
	replace Product_Drug_Name = "BUPRENORPHINE/NALOXONE FILM"  if regex(ndc_9, "007817216")|regex(ndc_9, "007817227")|regex(ndc_9, "007817238")|regex(ndc_9, "007817249")

	
	replace BUP=1 if regex(ndc, "00093215533") | regex(ndc_9, "000932155")
	replace Product_Drug_Name = "CASSIPA" if regex(ndc, "00093215533") | regex(ndc_9, "000932155")

	
	sum N_id_ndc BUP opioid vivitrol	
	compress
	save "${intdir}/drug_package_formularies`t'All.dta", replace 
	  }


	  * https://fda.report/NDC/12496-1208 [Generic sublingual film]

	  
	
	
*** any formulary plans 
	forvalues year = 2017/2021 {  	 
	use "${Vcleandatadir}/drug_package_formularies`year'.dta", clear

	sort formulary_id	
	merge m:1 formulary_id using  "${intdir}/formularies_ID`year'.dta", keep(1 3) nogen keepusing(name)
	gen year =`year'
	
	keep formulary_id name 
	sort formulary_id name 
	duplicates drop formulary_id name, force 	
	
	codebook formulary_id name
	save "${intdir}/plan_formularies`year'All.dta", replace 	
	}
	
	clear
        forvalues year = 2017/2021 {  	 
	append using "${intdir}/plan_formularies`year'All.dta"
	}	
	sort formulary_id name 
	duplicates drop formulary_id name, force 
	
	list name if formulary_id==60876 | formulary_id==60887
	export excel using $plotdir/Plan_ID_names2017-2021, replace firstrow(var)
	codebook         // 3,224 formularies in total 
	save "${intdir}/Plan_ID_names2017-2021.dta", replace 	
	
        forvalues year = 2017/2021 {  	 
	use "${intdir}/plan_formularies`year'All.dta", clear
	dis `year'
	codebook
	}	
	// 2017: 2064
	// 2018: 2420
	// 2019: 2431
	// 2020: 2615
	// 2021: 3224
       forvalues year = 2017/2021 {  	 
	use formulary_id ndc ///
	using "${intdir}/drug_package_formularies`year'All.dta", clear 
	dis `year'
	codebook formulary_id if ndc!="" // drop formularies due to missing NDC
       }
       * after droping missing NDC
  	// 2017: 2064 - 2057
	// 2018: 2420 - 2418
	// 2019: 2431 - 2429
	// 2020: 2615 - 2613
	// 2021: 3224 - 3085    
       
       
       
       
	
	/*
	* MI: plan 
	clear
        forvalues year = 2017/2019 {  	 
	append using "${intdir}/plan_formularies`year'All.dta"
	}
	keep formulary_id name 
	sort formulary_id name 
	duplicates drop formulary_id name, force 		
	save "${intdir}/plan_formularies2017_2019All.dta", replace 
		
			
	use "${intdir}/plan_formularies2017All.dta", clear 
	codebook formulary_id name 
	
	keep formulary_id name 
	sort formulary_id name 
	duplicates drop formulary_id name, force 
	
	gen name_lower = lower(itrim(name))

	gen medicare=1 if regex(name_lower,"medicare")
	gen medicaid=1 if regex(name_lower,"medicaid")
	
	drop if medicare==1 | medicaid==1
		
	export excel using $plotdir/Plan_ID_names2017-2019, replace firstrow(var)		
		
	drop if medicare==1 | medicaid==1	
	sum medicare medicaid 	
	
	export excel using $plotdir/Plan_ID_names2017-2019-excludeMedicareMedicaidPlans, replace firstrow(var)		

	
	gen michigan=1 if regex(name_lower,"michigan")
	gen mi=1 if regex(name_lower," mi ")
	tab name if mi==1 
	tab name if michigan==1 
	
	keep if michigan==1 | mi==1 
	codebook 
	sort formulary_id
	save "${intdir}/Michigan_plan.dta", replace 
	
	use "${intdir}/Michigan_plan.dta", clear
	export excel using $plotdir/Michigan_plan, replace firstrow(var)		
	
	
	
	** any drugs 
	forvalues year = 2017/2019 {  	 
	use "${Vcleandatadir}/drug_package_formularies`year'.dta", clear
	sort formulary_id	
	merge m:1 formulary_id using  "${intdir}/Michigan_plan.dta", keep(3) nogen
	codebook formulary_id ndc_package_code
	save "${intdir}/Michigan_plan_ndc`year'.dta", replace 	
	} 
	** Bup/Vivitrol 

	clear 
          forvalues year = 2017/2019 {  	 
	append using  "${intdir}/NDC_formularies`year'moud.dta" 
	  } 
	keep if BUP == 1 | vivitrol == 1 
	merge m:1 formulary_id using  "${intdir}/Michigan_plan.dta", keep(3) nogen	
	
	save "${intdir}/Michigan_NDC_formularies2017_2019moud.dta", replace 

	
		*/
	
	  
	  

log close
exit

	
	

