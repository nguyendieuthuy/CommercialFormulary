/* Start log */
capture log close
log using "${logdir}/SamplesOfPlans$S_DATE.log", replace

************** cleaned version by Kao and Kao's RA
	clear 
	import excel using "${datadir}/Plan names_v2.xlsx", firstrow
	tab insurancetype_initial insurancetype_final
	drop URL F
	codebook formulary_id if insurancetype_final =="Private" // 854 private plans 
	
	sort formulary_id
	* 1092 verified commercial plans 
	save "${intdir}/plan_formulary_id_name_group2017_2021v2.dta", replace 	
	
	
 ****** construct balanced panel ******
        forvalues t = 2017/2021 {     
	use  "${intdir}/plan_formulary_BUP`t'.dta", clear
	codebook formulary_id if nNDCAll == .  
	drop if nNDCAll == . // there were about 80 plans specifically not covered any listed NDCs. I excluded these plans for comparisons. 2017 (76), 2018 (77), 2019(78), 2020(79), 2021(88)
	
	keep formulary_id name 
	sort formulary_id 
	
	
	
	save "${intdir}/plan_formulary_id`t'.dta", replace 
	}	
	
	use "${intdir}/plan_formulary_id2021.dta", clear
        forvalues t = 2017/2020 {     
	append using "${intdir}/plan_formulary_id`t'.dta"
	}
	sort formulary_id
	by formulary_id: keep if _n==1
	codebook formulary_id // 2999 unique plans after excluding 88 plans with noncovered drugs 
	save "${intdir}/plan_formulary_id2017_2021.dta", replace 


	use "${intdir}/plan_formulary_id2017_2021.dta",clear 
	merge 1:m formulary_id using "${intdir}/Plan_ID_names2017-2021.dta",keepusing(name) nogen keep(1 3)    /// all plans (3224 with ID, only 3128 specific name); keep only 2999 plans with covered drugs 
	
	save "${intdir}/plan_formulary_id_name2017_2021.dta", replace 	
	
////////////////////////////////////////////////////////////////////////////////	
////////////////////////////////////////////////////////////////////////////////	
	use "${intdir}/plan_formulary_id_name2017_2021.dta", clear 
	drop if name==""
	gen plan_name = lower(trim(name))
	list plan_name 
	
	replace plan_name = "trilogy badgercare plus" if plan_name=="trilogy badgecare plus"
				
				
	local commercial_list ///
		hix ///
		exchange /// 
		fehbp /// 
		hdhp /// 
		commercial /// 
		walmart /// 
		vanderbilt /// 
		yale /// 
		employee /// 
		corporation ///
		foods ///
		kroger ///
		ibm ///
		johnsonville
		
	gen plan_type = ""
		foreach PLAN in `commercial_list' {
		replace plan_type="private" if regex(plan_name, "`PLAN'")
		}
		list name plan_name if plan_type=="private"
		replace plan_type="private" if regex(plan_name, "us bank")
		replace plan_type="private" if regex(plan_name, "self-insured")
		replace plan_type="private" if regex(plan_name, "harvard pilgrim")
		replace plan_type="private" if regex(plan_name, "health alliance plan")
		replace plan_type="private" if regex(plan_name, "physicians health plan of michigan")	
		tab plan_type // 515 private plans 

	** BadgerCare Plus is a Wisconsin Medicaid program  
	
////////////////////////////////////////////////////////////////////////////////	
	local medicare_list /// /*Medicare or Medicare Advantage*/
		medicare ///
		advantage ///
		senior ///
		dual ///
		medi-medi /// 
		fida ///
		esrd ///
		medvantage 

	foreach PLAN in `medicare_list' {
		replace plan_type="Medicare" if regex(plan_name, "`PLAN'") & plan_type!="private"
		}
	replace plan_type="Medicare" if regex(plan_name, " mmp")
	
		list name plan_name if plan_type=="Medicare" & regex(plan_name, " mmp")
		list name plan_name if plan_type=="Medicare" & regex(plan_name, " esrd")
		list name plan_name if plan_type=="Medicare" & regex(plan_name, " dual")
		list name plan_name if plan_type=="Medicare" & regex(plan_name, "dual")

////////////////////////////////////////////////////////////////////////////////	
	local medicaid_list /// /*Medicaid*/
		medicaid ///
		amerigroup ///
		molina ///
		chip ///
		star ///
		child ///
		medi-cal ///
		masshealth ///
		badger 
		
	foreach PLAN in `medicaid_list' {
		replace plan_type="Medicaid" if regex(plan_name, "`PLAN'") & plan_type!="private" & plan_type!="Medicare" 
		}
	replace plan_type="Medicaid" if regex(plan_name, "aetna better health")
	replace plan_type="Medicaid" if regex(plan_name, "new york")
	replace plan_type="Medicaid" if regex(plan_name, "aca")
	replace plan_type="Medicaid" if regex(plan_name, " kid")
	replace plan_type="Medicaid" if regex(plan_name, " mma")
	replace plan_type="Medicaid" if regex(plan_name, " hip")	
		list name plan_name if plan_type=="Medicaid" & regex(plan_name, "aca")
		
////////////////////////////////////////////////////////////////////////////////	
	local other_list /// /*Other*/
		tricare 
		
	foreach PLAN in `other_list' {
		replace plan_type="other" if regex(plan_name, "`PLAN'") & plan_type!="private" & plan_type!="Medicare" & plan_type!="Medicaid"  
		}
	replace plan_type="other" if regex(plan_name, "aids drug")
		list name plan_name if plan_type=="other" & regex(plan_name, "aids drug")		

////////////////////////////////////////////////////////////////////////////////
	replace plan_type="private" if regex(plan_name, "university")
	replace plan_type="private" if regex(plan_name, "kaiser permanente")

	replace plan_type="unclassified" if plan_type==""

	tab plan_type 

	sort formulary_id
	save "${intdir}/plan_formulary_id_name_group2017_2021.dta", replace 	
	
	keep if plan_type=="unclassified" 
	keep formulary_id name plan_name 
	gen plan_type=""
	export excel using $plotdir/unclassified_plan_formulary2017_2021, replace firstrow(var)	
	
	use  "${intdir}/plan_formulary_id_name_group2017_2021.dta", clear
	tab plan_type
	
	use "${intdir}/plan_formulary_id_name_group2017_2021v2.dta", clear 
	codebook
	
