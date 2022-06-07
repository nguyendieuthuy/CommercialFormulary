
/* Start log */
capture log close
log using "${logdir}/2.1.FinalDescriptiveAnalysis.log", replace
	  

////////////////////////////////////////////////////////////////////////////////
//////////////////// SET of PANEL FORMULARIES /////////////////////////////////

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


	merge m:1 formulary_id using "${intdir}/formulary_3privateFormulary_2017_2021.dta", nogen keep(3)   // keep 2,000 plans appeared in 2017-2021 
	sum SmallGroup Individual  Small_IndividualGroup Group1_CMS Group2_private_noHIOS Group3_private_HIOS
	keep if Group1_CMS==1 | Group2_private_noHIOS==1 | Group3_private_HIOS==1
	codebook formulary_id // 866 formulary ID 
	gen Type=""
	replace Type="Appeared in CMS list" if Group1_CMS==1 
	replace Type="Classified as private, no HIOS" if Group2_private_noHIOS==1 
	replace Type="Classified as private, with HIOS" if Group3_private_HIOS==1 
	tab Type
		
	gen InsuranceMarket = "Small Group" if SmallGroup==1 
	replace InsuranceMarket = "Individual" if Individual==1 
	replace InsuranceMarket = "Mix (Small Group and Individual)" if Small_IndividualGroup==1 
		
	tab InsuranceMarket
	
	
	save "${intdir}/unique_plan_formulary_id2017_2021_private.dta", replace 	
	
	
	
****** construct balanced panel ******	
	foreach R in QL ST {
	use  "${intdir}/plan_formulary_BUP`R'2017.dta", clear 
        forvalues t = 2018/2021 {     
	append using "${intdir}/plan_formulary_BUP`R'`t'.dta"
	}
	merge m:1 formulary_id using "${intdir}/unique_plan_formulary_id2017_2021_private.dta", nogen keep(3)   // keep 905 private plans appeared in 2017-2021 
	codebook formulary_id
	save "${intdir}/plan_formulary_BUP`R'2017_2021_temp.dta", replace 	
	}
	
	* PA 
	use  "${intdir}/plan_formulary_BUP2017.dta", clear 
        forvalues t = 2018/2021 {     
	append using "${intdir}/plan_formulary_BUP`t'.dta"
	}
	merge m:1 formulary_id using "${intdir}/unique_plan_formulary_id2017_2021_private.dta", nogen keep(3)   // keep 905 private plans appeared in 2017-2021 
	save "${intdir}/plan_formulary_BUP2017_2021_temp.dta", replace 	

	
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////	
	* combine all datasets 	
	use  "${intdir}/plan_formulary_BUP2017_2021_temp.dta", clear 
	codebook formulary_id name
	
	sum Y_coverBUP, detail
	codebook formulary_id if Y_coverBUP==1 & year==2017 // 21 plans not covering BUP 
	codebook formulary_id if Y_coverBUP==1 & year==2018 // 10
	codebook formulary_id if Y_coverBUP==1 & year==2019 // 10
	codebook formulary_id if Y_coverBUP==1 & year==2020 //9 
	codebook formulary_id if Y_coverBUP==1 & year==2021 // 2 
	
	
	*codebook formulary_id if Y_covergenBUPNALfil==1 & year==2017 // 21 plans not covering BUP 
	*codebook formulary_id if Y_covergenBUPNALfil==1 & year==2018 // 10
	codebook formulary_id if Y_covergenBUPNALfil==1 & year==2019 // 10
	codebook formulary_id if Y_covergenBUPNALfil==1 & year==2020 //9 
	codebook formulary_id if Y_covergenBUPNALfil==1 & year==2021 // 2 
	
	
	
	
	sort formulary_id year 

	merge m:1 formulary_id year using "${intdir}/plan_formulary_BUPQL2017_2021_temp.dta", nogen keep(3) keepusing(nNDCQLBUP nNDCQLER_BUP nNDCQLsublocade nNDCQLprobuphine nNDCQLzubsolv nNDCQLbunavail nNDCQLsuboxone nNDCQLgenBUPtab nNDCQLgenBUPNALtab nNDCQLgenBUPNALfil nNDCQLIR_BUP nNDCQLIR_film  nNDCQLIR_tablet ///
	Y_QLBUP Y_QLER_BUP Y_QLsublocade Y_QLprobuphine Y_QLzubsolv Y_QLbunavail Y_QLsuboxone Y_QLgenBUPtab Y_QLgenBUPNALtab Y_QLgenBUPNALfil Y_QLIR_BUP Y_QLIR_film  Y_QLIR_tablet ///
	AllQLBUP AllQLER_BUP AllQLsublocade AllQLprobuphine AllQLzubsolv AllQLbunavail AllQLsuboxone AllQLgenBUPtab AllQLgenBUPNALtab AllQLgenBUPNALfil AllQLIR_BUP AllQLIR_film  AllQLIR_tablet ///
	NoQLBUP NoQLER_BUP NoQLsublocade NoQLprobuphine NoQLzubsolv NoQLbunavail NoQLsuboxone NoQLgenBUPtab NoQLgenBUPNALtab NoQLgenBUPNALfil NoQLIR_BUP NoQLIR_film  NoQLIR_tablet)  // keep 2,418 plans appeared in 2018-2021 
	merge m:1 formulary_id year using "${intdir}/plan_formulary_BUPST2017_2021_temp.dta", nogen keep(3) keepusing(nNDCSTBUP nNDCSTER_BUP nNDCSTsublocade nNDCSTprobuphine nNDCSTzubsolv nNDCSTbunavail nNDCSTsuboxone nNDCSTgenBUPtab nNDCSTgenBUPNALtab nNDCSTgenBUPNALfil nNDCSTIR_BUP nNDCSTIR_film  nNDCSTIR_tablet ///
	Y_STBUP Y_STER_BUP Y_STsublocade Y_STprobuphine Y_STzubsolv Y_STbunavail Y_STsuboxone Y_STgenBUPtab Y_STgenBUPNALtab Y_STgenBUPNALfil Y_STIR_BUP Y_STIR_film  Y_STIR_tablet ///
	AllSTBUP AllSTER_BUP AllSTsublocade AllSTprobuphine AllSTzubsolv AllSTbunavail AllSTsuboxone AllSTgenBUPtab AllSTgenBUPNALtab AllSTgenBUPNALfil AllSTIR_BUP AllSTIR_film  AllSTIR_tablet ///
	NoSTBUP NoSTER_BUP NoSTsublocade NoSTprobuphine NoSTzubsolv NoSTbunavail NoSTsuboxone NoSTgenBUPtab NoSTgenBUPNALtab NoSTgenBUPNALfil NoSTIR_BUP NoSTIR_film  NoSTIR_tablet)  // keep 2,418 plans appeared in 2018-2021 	
	

	// keep 2,000 plans appeared in 2017-2021 

	merge m:1 formulary_id using "${intdir}/formulary_n_npi_matched2017_2021.dta", nogen keep(1 3) keepusing(n_npi)  // n_npi: average size of network 
	codebook formulary_id if n_npi!=.  // only 490 formulary IDs with network size 
	codebook formulary_id   // 905 formulary IDs 
	tab Type
	sum SmallGroup Individual  Small_IndividualGroup if Type=="Appeared in CMS list"
	
	* vs. previous version: 870 formulary - 453 with network size 

	************************************************************************
	*******************************Measures                           ******
	foreach D in sublocade probuphine zubsolv bunavail suboxone  genBUPtab genBUPNALtab genBUPNALfil BUP ER_BUP IR_BUP IR_film  IR_tablet {	
		foreach R in PA QL ST {	
	replace Y_`R'`D' = . if Y_cover`D'==0	
	replace Y_`R'`D' = 0 if Y_cover`D'==1 & Y_`R'`D' == .
	
	replace All`R'`D' = 0 if Y_cover`D'==1 & All`R'`D' !=1
	replace No`R'`D' = 0 if Y_cover`D'==1 & No`R'`D' !=1
	
	replace nNDC`R'`D' = 0 if Y_cover`D'==1 & nNDC`R'`D' ==.	
	replace nNDCcover`D' = 0 if Y_cover`D'==1 & nNDCcover`D' ==.

	* without `R' for at least one product
	gen No`R'1`D' = 0 if Y_cover`D'==1
	replace No`R'1`D' = 1 if nNDCcover`D' > nNDC`R'`D' & nNDC`R'`D'!=. 
	sum No`R'1`D'
	
	drop No`R'`D'
	gen No`R'`D' = 0 if Y_cover`D'==1
	replace No`R'`D' = 1 if nNDCcover`D' > 0 & nNDC`R'`D'==0 & nNDCcover`D'!=. 
	}
	}
		

	foreach D in sublocade probuphine zubsolv bunavail suboxone  genBUPtab genBUPNALtab genBUPNALfil BUP ER_BUP IR_BUP IR_film  IR_tablet {	
	replace Y_cover`D' = 100*Y_cover`D'
	label var Y_cover`D' "Percent plans covering at least one `D' product"
		}
	
	
	foreach D in sublocade probuphine zubsolv bunavail suboxone  genBUPtab genBUPNALtab genBUPNALfil BUP ER_BUP IR_BUP IR_film  IR_tablet {	
		foreach R in PA QL ST {	
	replace Y_`R'`D' = 100*Y_`R'`D'
	label var Y_`R'`D' "Percent plans having `R' for at least one `D' product"
	
	replace All`R'`D' = 100*All`R'`D'
	label var All`R'`D' "Percent plans having `R' for all`D' products"
	
	replace No`R'`D' = 100*No`R'`D'
	label var No`R'`D' "Percent plans without `R' for any `D' products"

	replace No`R'1`D' = 100*No`R'1`D'
	label var No`R'1`D' "Percent plans without `R' for at least 1 `D' product"
	
	
	gen shareNDC`R'`D' = nNDC`R'`D'/nNDCcover`D'*100
		label var shareNDC`R'`D' "Percent covered NDCs with `R'"
		label var nNDC`R'`D' "N covered NDCs with `R' (`D') "
		label var nNDCcover`D' "N covered NDCs (`D')"
	}
	}	
	save "${intdir}/plan_formulary_BUP2017_2021_private.dta", replace 	



////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
** FIGURE ** 
    forvalues t = 2017/2021 {     
	use "${intdir}/plan_formulary_BUP2017_2021_private.dta", clear 	
	keep if year==`t'
	local X nNDCAll nNDCcoverBUP nNDCcoverER_BUP nNDCcoversublocade nNDCcoverprobuphine nNDCcoverzubsolv nNDCcoverbunavail nNDCcoversuboxone nNDCcovergenBUPtab nNDCcovergenBUPNALtab nNDCcovergenBUPNALfil nNDCcoverIR_BUP nNDCcoverIR_film nNDCcoverIR_tablet nNDCPABUP nNDCPAER_BUP nNDCPAsublocade nNDCPAprobuphine nNDCPAzubsolv nNDCPAbunavail nNDCPAsuboxone nNDCPAgenBUPtab nNDCPAgenBUPNALtab nNDCPAgenBUPNALfil nNDCPAIR_BUP nNDCPAIR_film nNDCPAIR_tablet Y_coverBUP Y_coverER_BUP Y_coversublocade Y_coverprobuphine Y_coverzubsolv Y_coverbunavail Y_coversuboxone Y_covergenBUPtab Y_covergenBUPNALtab Y_covergenBUPNALfil Y_coverIR_BUP Y_coverIR_film Y_coverIR_tablet Y_PABUP Y_PAER_BUP Y_PAsublocade Y_PAprobuphine Y_PAzubsolv Y_PAbunavail Y_PAsuboxone Y_PAgenBUPtab Y_PAgenBUPNALtab Y_PAgenBUPNALfil Y_PAIR_BUP Y_PAIR_film Y_PAIR_tablet AllPABUP AllPAER_BUP AllPAsublocade AllPAprobuphine AllPAzubsolv AllPAbunavail AllPAsuboxone AllPAgenBUPtab AllPAgenBUPNALtab AllPAgenBUPNALfil AllPAIR_BUP AllPAIR_film AllPAIR_tablet nNDCQLBUP nNDCQLER_BUP nNDCQLsublocade nNDCQLprobuphine nNDCQLzubsolv nNDCQLbunavail nNDCQLsuboxone nNDCQLgenBUPtab nNDCQLgenBUPNALtab nNDCQLgenBUPNALfil nNDCQLIR_BUP nNDCQLIR_film nNDCQLIR_tablet Y_QLBUP Y_QLER_BUP Y_QLsublocade Y_QLprobuphine Y_QLzubsolv Y_QLbunavail Y_QLsuboxone Y_QLgenBUPtab Y_QLgenBUPNALtab Y_QLgenBUPNALfil Y_QLIR_BUP Y_QLIR_film Y_QLIR_tablet AllQLBUP AllQLER_BUP AllQLsublocade AllQLprobuphine AllQLzubsolv AllQLbunavail AllQLsuboxone AllQLgenBUPtab AllQLgenBUPNALtab AllQLgenBUPNALfil AllQLIR_BUP AllQLIR_film AllQLIR_tablet nNDCSTBUP nNDCSTER_BUP nNDCSTsublocade nNDCSTprobuphine nNDCSTzubsolv nNDCSTbunavail nNDCSTsuboxone nNDCSTgenBUPtab nNDCSTgenBUPNALtab nNDCSTgenBUPNALfil nNDCSTIR_BUP nNDCSTIR_film nNDCSTIR_tablet Y_STBUP Y_STER_BUP Y_STsublocade Y_STprobuphine Y_STzubsolv Y_STbunavail Y_STsuboxone Y_STgenBUPtab Y_STgenBUPNALtab Y_STgenBUPNALfil Y_STIR_BUP Y_STIR_film Y_STIR_tablet AllSTBUP AllSTER_BUP AllSTsublocade AllSTprobuphine AllSTzubsolv AllSTbunavail AllSTsuboxone AllSTgenBUPtab AllSTgenBUPNALtab AllSTgenBUPNALfil AllSTIR_BUP AllSTIR_film AllSTIR_tablet insurancetype_final n_npi NoPA1sublocade NoPAsublocade NoQL1sublocade NoQLsublocade NoST1sublocade NoSTsublocade NoPA1probuphine NoPAprobuphine NoQL1probuphine NoQLprobuphine NoST1probuphine NoSTprobuphine NoPA1zubsolv NoPAzubsolv NoQL1zubsolv NoQLzubsolv NoST1zubsolv NoSTzubsolv NoPA1bunavail NoPAbunavail NoQL1bunavail NoQLbunavail NoST1bunavail NoSTbunavail NoPA1suboxone NoPAsuboxone NoQL1suboxone NoQLsuboxone NoST1suboxone NoSTsuboxone NoPA1genBUPtab NoPAgenBUPtab NoQL1genBUPtab NoQLgenBUPtab NoST1genBUPtab NoSTgenBUPtab NoPA1genBUPNALtab NoPAgenBUPNALtab NoQL1genBUPNALtab NoQLgenBUPNALtab NoST1genBUPNALtab NoSTgenBUPNALtab NoPA1genBUPNALfil NoPAgenBUPNALfil NoQL1genBUPNALfil NoQLgenBUPNALfil NoST1genBUPNALfil NoSTgenBUPNALfil NoPA1BUP NoPABUP NoQL1BUP NoQLBUP NoST1BUP NoSTBUP NoPA1ER_BUP NoPAER_BUP NoQL1ER_BUP NoQLER_BUP NoST1ER_BUP NoSTER_BUP NoPA1IR_BUP NoPAIR_BUP NoQL1IR_BUP NoQLIR_BUP NoST1IR_BUP NoSTIR_BUP NoPA1IR_film NoPAIR_film NoQL1IR_film NoQLIR_film NoST1IR_film NoSTIR_film NoPA1IR_tablet NoPAIR_tablet NoQL1IR_tablet NoQLIR_tablet NoST1IR_tablet NoSTIR_tablet shareNDCPAsublocade shareNDCQLsublocade shareNDCSTsublocade shareNDCPAprobuphine shareNDCQLprobuphine shareNDCSTprobuphine shareNDCPAzubsolv shareNDCQLzubsolv shareNDCSTzubsolv shareNDCPAbunavail shareNDCQLbunavail shareNDCSTbunavail shareNDCPAsuboxone shareNDCQLsuboxone shareNDCSTsuboxone shareNDCPAgenBUPtab shareNDCQLgenBUPtab shareNDCSTgenBUPtab shareNDCPAgenBUPNALtab shareNDCQLgenBUPNALtab shareNDCSTgenBUPNALtab shareNDCPAgenBUPNALfil shareNDCQLgenBUPNALfil shareNDCSTgenBUPNALfil shareNDCPABUP shareNDCQLBUP shareNDCSTBUP shareNDCPAER_BUP shareNDCQLER_BUP shareNDCSTER_BUP shareNDCPAIR_BUP shareNDCQLIR_BUP shareNDCSTIR_BUP shareNDCPAIR_film shareNDCQLIR_film shareNDCSTIR_film shareNDCPAIR_tablet shareNDCQLIR_tablet shareNDCSTIR_tablet
		
	foreach var in `X' {
	ci means `var'
	gen lb_`var'= r(lb)
	gen ub_`var' = r(ub)
	gen mean_`var' = r(mean)
	}
	sort year
	by year: egen plan =nvals(formulary_id)			
	
	keep if _n==1
	save "${intdir}/mean_plan_formulary_BUP`t'_private.dta", replace  	
	}
	
	
	clear
      forvalues t = 2017/2021 {     
	append using "${intdir}/mean_plan_formulary_BUP`t'_private.dta"
      }

      
twoway (line mean_NoPA1IR_BUP year, lcolor(cranberry%90) msize(small) lw(*1.2) lpattern(solid ))   ///
	(rcap  lb_NoPA1IR_BUP ub_NoPA1IR_BUP year, lcolor(cranberry%60 ) mcolor(cranberry%60)) ///
	
	foreach var in mean_Y_coversublocade ub_Y_coversublocade {
	replace  `var'=. if year==2017
	}
      * graph 1: % of plans covering any immediate release bup 
	graph twoway (connected mean_Y_coverIR_BUP year,lwidth(0.5) lc(dkorange%80) mcolor(dkorange%80) msymbol(sh) msize(1))   ///
	(rcap  lb_Y_coverIR_BUP ub_Y_coverIR_BUP year,msize(4) lwidth(0.4) lcolor(dkorange%80 ) mcolor(dkorange%80)) /// 
	(connected mean_Y_coversublocade year,lwidth(0.5) lc(midblue) mcolor(midblue%80) msymbol(dh) msize(1))   ///
	(rcap  lb_Y_coversublocade ub_Y_coversublocade year,msize(4) lwidth(0.4) lcolor(midblue%80 ) mcolor(midblue%80)) ///	
	, ///
	graphregion(color(white)) xtitle("")   ///
	title("A. Proportion of formularies covering at least one" "immediate-release buprenorphine product and extended-release buprenorphine injection", size(3.5)) ///
	ytitle("Percent",size(3.5))  ///
	ylabel(0(20)100,angle(horizontal) grid labsize(3.5)) /// 
	xlabel(2017(1)2021, angle(horizontal) labsize(3.5) ) ///	
	legend(rows(1) symxsize(5) keygap(1) forcesize colgap(0) rowgap(0) order(1 "Immediate-release buprenorphine" 3 "Extended-release buprenorphine injection") size(2.8) position(6))    name(cover, replace)     

	
	graph twoway (connected mean_NoPA1IR_BUP year,lwidth(0.5) lc(dkorange%80) mcolor(dkorange%80) msymbol(sh) msize(1))   ///
	(rcap  lb_NoPA1IR_BUP ub_NoPA1IR_BUP year,msize(4) lwidth(0.4) lcolor(dkorange%80 ) mcolor(dkorange%80)) ///  
	(connected mean_NoPA1sublocade year,lwidth(.5) lc(midblue) mcolor(midblue%80) msymbol(dh) )   ///
	(rcap  lb_NoPA1sublocade ub_NoPA1sublocade year,msize(4) lwidth(0.4) lcolor(midblue%80 ) mcolor(midblue%80)) ///	
	, ///
	graphregion(color(white)) xtitle("")   ///
	title("B. Proportion of formularies without prior requirements for at least one" "immediate-release buprenorphine product and extended-release buprenorphine injection", size(3.5)) ///
	ytitle("Percent",size(3.5))  ///
	ylabel(0(20)100,angle(horizontal) grid labsize(3.5)) /// 
	xlabel(2017(1)2021, angle(horizontal) labsize(3.5) ) ///	
	legend(rows(1) symxsize(5) keygap(1) forcesize colgap(0) rowgap(0) order(1 "Immediate-release buprenorphine"  3 "Extended-release buprenorphine injection") size(2.8))    name(NoPA1, replace)     	
		
	
	
	grc1leg cover NoPA1, cols(1) ///
	imargin(0 0 0 0) legendfrom(cover) position(b) graphregion(color(white)) ///
			title("", color(black)   size(2.5)) name(Figure_combine, replace)
			
	graph combine Figure_combine,  cols(1) iscale(.82) xsize(10) ysize(10) ///
imargin(0 1 0 0) graphregion(color(white)) ///
	title("", color(black)   size(3.5)) 
	graph export "${tabledir}/Fig1_coverage_restriction_film_tablet.png",  replace width(4000)  
	graph export "${tabledir}/Fig1_coverage_restriction_film_tablet.eps", replace  




*** export excel file 	
	
	
	keep year mean_Y_coverIR_BUP mean_Y_coverIR_film mean_Y_coverIR_tablet  ///
		mean_Y_coversuboxone mean_Y_covergenBUPNALfil mean_Y_coverbunavail mean_Y_coverzubsolv  mean_Y_covergenBUPNALtab mean_Y_covergenBUPtab ///
		mean_Y_coverER_BUP mean_Y_coversublocade mean_Y_coverprobuphine ///		
		mean_NoPA1IR_BUP mean_NoPA1IR_film mean_NoPA1IR_tablet  ///
		mean_NoPA1suboxone mean_NoPA1genBUPNALfil mean_NoPA1bunavail mean_NoPA1zubsolv  mean_NoPA1genBUPNALtab mean_NoPA1genBUPtab ///
		mean_NoPA1ER_BUP mean_NoPA1sublocade mean_NoPA1probuphine 

		
	order year mean_Y_coverIR_BUP mean_Y_coverIR_film mean_Y_coverIR_tablet  ///
		mean_Y_coversuboxone mean_Y_covergenBUPNALfil mean_Y_coverbunavail mean_Y_coverzubsolv  mean_Y_covergenBUPNALtab mean_Y_covergenBUPtab ///
		mean_Y_coverER_BUP mean_Y_coversublocade mean_Y_coverprobuphine ///		
		mean_NoPA1IR_BUP mean_NoPA1IR_film mean_NoPA1IR_tablet  ///
		mean_NoPA1suboxone mean_NoPA1genBUPNALfil mean_NoPA1bunavail mean_NoPA1zubsolv  mean_NoPA1genBUPNALtab mean_NoPA1genBUPtab ///
		mean_NoPA1ER_BUP mean_NoPA1sublocade mean_NoPA1probuphine
	export excel using $plotdir/plan_formulary_BUP2017_2021_PAmean_private, replace firstrow(var)	


************** sensitivity analysis ************************************************
    forvalues t = 2017/2021 {     
	use "${intdir}/plan_formulary_BUP2017_2021_private.dta", clear 	
	keep if year==`t'
	local X nNDCAll nNDCcoverBUP nNDCcoverER_BUP nNDCcoversublocade nNDCcoverprobuphine nNDCcoverzubsolv nNDCcoverbunavail nNDCcoversuboxone nNDCcovergenBUPtab nNDCcovergenBUPNALtab nNDCcovergenBUPNALfil nNDCcoverIR_BUP nNDCcoverIR_film nNDCcoverIR_tablet nNDCPABUP nNDCPAER_BUP nNDCPAsublocade nNDCPAprobuphine nNDCPAzubsolv nNDCPAbunavail nNDCPAsuboxone nNDCPAgenBUPtab nNDCPAgenBUPNALtab nNDCPAgenBUPNALfil nNDCPAIR_BUP nNDCPAIR_film nNDCPAIR_tablet Y_coverBUP Y_coverER_BUP Y_coversublocade Y_coverprobuphine Y_coverzubsolv Y_coverbunavail Y_coversuboxone Y_covergenBUPtab Y_covergenBUPNALtab Y_covergenBUPNALfil Y_coverIR_BUP Y_coverIR_film Y_coverIR_tablet Y_PABUP Y_PAER_BUP Y_PAsublocade Y_PAprobuphine Y_PAzubsolv Y_PAbunavail Y_PAsuboxone Y_PAgenBUPtab Y_PAgenBUPNALtab Y_PAgenBUPNALfil Y_PAIR_BUP Y_PAIR_film Y_PAIR_tablet AllPABUP AllPAER_BUP AllPAsublocade AllPAprobuphine AllPAzubsolv AllPAbunavail AllPAsuboxone AllPAgenBUPtab AllPAgenBUPNALtab AllPAgenBUPNALfil AllPAIR_BUP AllPAIR_film AllPAIR_tablet nNDCQLBUP nNDCQLER_BUP nNDCQLsublocade nNDCQLprobuphine nNDCQLzubsolv nNDCQLbunavail nNDCQLsuboxone nNDCQLgenBUPtab nNDCQLgenBUPNALtab nNDCQLgenBUPNALfil nNDCQLIR_BUP nNDCQLIR_film nNDCQLIR_tablet Y_QLBUP Y_QLER_BUP Y_QLsublocade Y_QLprobuphine Y_QLzubsolv Y_QLbunavail Y_QLsuboxone Y_QLgenBUPtab Y_QLgenBUPNALtab Y_QLgenBUPNALfil Y_QLIR_BUP Y_QLIR_film Y_QLIR_tablet AllQLBUP AllQLER_BUP AllQLsublocade AllQLprobuphine AllQLzubsolv AllQLbunavail AllQLsuboxone AllQLgenBUPtab AllQLgenBUPNALtab AllQLgenBUPNALfil AllQLIR_BUP AllQLIR_film AllQLIR_tablet nNDCSTBUP nNDCSTER_BUP nNDCSTsublocade nNDCSTprobuphine nNDCSTzubsolv nNDCSTbunavail nNDCSTsuboxone nNDCSTgenBUPtab nNDCSTgenBUPNALtab nNDCSTgenBUPNALfil nNDCSTIR_BUP nNDCSTIR_film nNDCSTIR_tablet Y_STBUP Y_STER_BUP Y_STsublocade Y_STprobuphine Y_STzubsolv Y_STbunavail Y_STsuboxone Y_STgenBUPtab Y_STgenBUPNALtab Y_STgenBUPNALfil Y_STIR_BUP Y_STIR_film Y_STIR_tablet AllSTBUP AllSTER_BUP AllSTsublocade AllSTprobuphine AllSTzubsolv AllSTbunavail AllSTsuboxone AllSTgenBUPtab AllSTgenBUPNALtab AllSTgenBUPNALfil AllSTIR_BUP AllSTIR_film AllSTIR_tablet insurancetype_final n_npi NoPA1sublocade NoPAsublocade NoQL1sublocade NoQLsublocade NoST1sublocade NoSTsublocade NoPA1probuphine NoPAprobuphine NoQL1probuphine NoQLprobuphine NoST1probuphine NoSTprobuphine NoPA1zubsolv NoPAzubsolv NoQL1zubsolv NoQLzubsolv NoST1zubsolv NoSTzubsolv NoPA1bunavail NoPAbunavail NoQL1bunavail NoQLbunavail NoST1bunavail NoSTbunavail NoPA1suboxone NoPAsuboxone NoQL1suboxone NoQLsuboxone NoST1suboxone NoSTsuboxone NoPA1genBUPtab NoPAgenBUPtab NoQL1genBUPtab NoQLgenBUPtab NoST1genBUPtab NoSTgenBUPtab NoPA1genBUPNALtab NoPAgenBUPNALtab NoQL1genBUPNALtab NoQLgenBUPNALtab NoST1genBUPNALtab NoSTgenBUPNALtab NoPA1genBUPNALfil NoPAgenBUPNALfil NoQL1genBUPNALfil NoQLgenBUPNALfil NoST1genBUPNALfil NoSTgenBUPNALfil NoPA1BUP NoPABUP NoQL1BUP NoQLBUP NoST1BUP NoSTBUP NoPA1ER_BUP NoPAER_BUP NoQL1ER_BUP NoQLER_BUP NoST1ER_BUP NoSTER_BUP NoPA1IR_BUP NoPAIR_BUP NoQL1IR_BUP NoQLIR_BUP NoST1IR_BUP NoSTIR_BUP NoPA1IR_film NoPAIR_film NoQL1IR_film NoQLIR_film NoST1IR_film NoSTIR_film NoPA1IR_tablet NoPAIR_tablet NoQL1IR_tablet NoQLIR_tablet NoST1IR_tablet NoSTIR_tablet shareNDCPAsublocade shareNDCQLsublocade shareNDCSTsublocade shareNDCPAprobuphine shareNDCQLprobuphine shareNDCSTprobuphine shareNDCPAzubsolv shareNDCQLzubsolv shareNDCSTzubsolv shareNDCPAbunavail shareNDCQLbunavail shareNDCSTbunavail shareNDCPAsuboxone shareNDCQLsuboxone shareNDCSTsuboxone shareNDCPAgenBUPtab shareNDCQLgenBUPtab shareNDCSTgenBUPtab shareNDCPAgenBUPNALtab shareNDCQLgenBUPNALtab shareNDCSTgenBUPNALtab shareNDCPAgenBUPNALfil shareNDCQLgenBUPNALfil shareNDCSTgenBUPNALfil shareNDCPABUP shareNDCQLBUP shareNDCSTBUP shareNDCPAER_BUP shareNDCQLER_BUP shareNDCSTER_BUP shareNDCPAIR_BUP shareNDCQLIR_BUP shareNDCSTIR_BUP shareNDCPAIR_film shareNDCQLIR_film shareNDCSTIR_film shareNDCPAIR_tablet shareNDCQLIR_tablet shareNDCSTIR_tablet
		
	foreach var in `X' {
	ci means `var'  [aw=n_npi]
	gen lb_`var'= r(lb)
	gen ub_`var' = r(ub)
	gen mean_`var' = r(mean)
	}
	sort year
	by year: egen plan =nvals(formulary_id)			
	
	keep if _n==1
	save "${intdir}/mean_plan_formulary_BUP`t'_private_npi.dta", replace  	
	}
	
	** 447 formulary IDs 

	clear
      forvalues t = 2017/2021 {     
	append using "${intdir}/mean_plan_formulary_BUP`t'_private_npi.dta"
      }	  	
	
	keep year mean_Y_coverIR_BUP mean_Y_coverIR_film mean_Y_coverIR_tablet  ///
		mean_Y_coversuboxone mean_Y_covergenBUPNALfil mean_Y_coverbunavail mean_Y_coverzubsolv  mean_Y_covergenBUPNALtab mean_Y_covergenBUPtab ///
		mean_Y_coverER_BUP mean_Y_coversublocade mean_Y_coverprobuphine ///		
		mean_NoPA1IR_BUP mean_NoPA1IR_film mean_NoPA1IR_tablet  ///
		mean_NoPA1suboxone mean_NoPA1genBUPNALfil mean_NoPA1bunavail mean_NoPA1zubsolv  mean_NoPA1genBUPNALtab mean_NoPA1genBUPtab ///
		mean_NoPA1ER_BUP mean_NoPA1sublocade mean_NoPA1probuphine 

		
	order year mean_Y_coverIR_BUP mean_Y_coverIR_film mean_Y_coverIR_tablet  ///
		mean_Y_coversuboxone mean_Y_covergenBUPNALfil mean_Y_coverbunavail mean_Y_coverzubsolv  mean_Y_covergenBUPNALtab mean_Y_covergenBUPtab ///
		mean_Y_coverER_BUP mean_Y_coversublocade mean_Y_coverprobuphine ///		
		mean_NoPA1IR_BUP mean_NoPA1IR_film mean_NoPA1IR_tablet  ///
		mean_NoPA1suboxone mean_NoPA1genBUPNALfil mean_NoPA1bunavail mean_NoPA1zubsolv  mean_NoPA1genBUPNALtab mean_NoPA1genBUPtab ///
		mean_NoPA1ER_BUP mean_NoPA1sublocade mean_NoPA1probuphine
	export excel using $tabledir/plan_formulary_BUP2017_2021_PAmean_private_weight, replace firstrow(var)	

	
////////////////////////////////////////////////////////////////////////////////	
/////////////////////////////////////////////////////////////////////////////////
*** weight adjusted test - using regression ***
	use "${intdir}/plan_formulary_BUP2017_2021_private.dta", clear 		
	
	keep if year==2017 | year == 2021 
	gen Post2020 = 1 if year >=2020 
		replace Post2020 = 0 if Post2020==. 

	codebook formulary_id if n_npi!=.
	
	foreach var in Y_coverIR_BUP Y_coverIR_film Y_coverIR_tablet  ///
		Y_coversuboxone Y_coverbunavail Y_coverzubsolv  Y_covergenBUPNALtab Y_covergenBUPtab ///
		Y_coverER_BUP Y_coverprobuphine ///		
		NoPA1IR_BUP NoPA1IR_film NoPA1IR_tablet  ///
		NoPA1suboxone NoPA1bunavail NoPA1zubsolv  NoPA1genBUPNALtab NoPA1genBUPtab ///
		NoPA1ER_BUP NoPA1probuphine 	{
		reg `var' Post2020 [aw=n_npi]	
		estadd ysumm
		eststo `var'w				

		reg `var' Post2020	
		estadd ysumm
		eststo `var'			
		}
	
	esttab Y_coverIR_BUPw Y_coverIR_filmw Y_coverIR_tabletw Y_coverER_BUPw ///
	NoPA1IR_BUPw NoPA1IR_filmw NoPA1IR_tabletw NoPA1ER_BUPw using "${tabledir}/Table_T-test-private2017_vs_2021.rtf",  ///
	replace modelwidth(14) ///
	keep(Post2020) ///
	order(Post2020) ///
	label nogaps  ///
	cells(b(fmt(a1)star) ci(fmt(a1)par("(" " to " ")")) p(fmt(a2))  )  ///	
	stats(ymean ysd N,fmt(%3.2f %3.2f 0)  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs."))  
		  

	esttab Y_coverIR_BUP Y_coverIR_film Y_coverIR_tablet Y_coverER_BUP ///
	NoPA1IR_BUP NoPA1IR_film NoPA1IR_tablet NoPA1ER_BUP using "${tabledir}/Table_T-test-private2017_vs_2021.rtf",  ///
	append modelwidth(14) ///
	keep(Post2020) ///
	order(Post2020) ///
	label nogaps  ///
	cells(b(fmt(a1)star) ci(fmt(a1)par("(" " to " ")")) p(fmt(a2))  )  ///	
	stats(ymean ysd N,fmt(%3.2f %3.2f 0)  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs."))  

	
	table1, vars(Y_coverIR_BUP cat\  Y_coverIR_film cat\ Y_coverIR_tablet cat\  ///
	Y_coversuboxone cat\ Y_coverbunavail cat\ Y_coverzubsolv cat\ ///
	Y_covergenBUPNALtab cat\ Y_covergenBUPtab cat\ ///
	NoPA1IR_BUP cat\  NoPA1IR_film cat\ NoPA1IR_tablet cat\ ///
	NoPA1suboxone cat\ NoPA1bunavail cat\ NoPA1zubsolv  cat\ ///
	NoPA1genBUPNALtab cat\ NoPA1genBUPtab cat\ ) ///
	 by(Post2020) format(%2.1f) 	saving("${tabledir}/Table_a_2GroupsPost2020.xls", replace)
	

	keep if n_npi!=. 
	
	table1, vars(Y_coverIR_BUP cat\  Y_coverIR_film cat\ Y_coverIR_tablet cat\  ///
	Y_coversuboxone cat\ Y_coverbunavail cat\ Y_coverzubsolv cat\ ///
	Y_covergenBUPNALtab cat\ Y_covergenBUPtab cat\ ///
	NoPA1IR_BUP cat\  NoPA1IR_film cat\ NoPA1IR_tablet cat\ ///
	NoPA1suboxone cat\ NoPA1bunavail cat\ NoPA1zubsolv  cat\ ///
	NoPA1genBUPNALtab cat\ NoPA1genBUPtab cat\ ) ///
	 by(Post2020) format(%2.1f) 	saving("${tabledir}/Table_a_2GroupsPost2020_withNetworkSize.xls", replace)
	
	** sublocade [2018-2021]
	use "${intdir}/plan_formulary_BUP2017_2021_private.dta", clear 		
	keep if year==2018 | year == 2021 
	gen Post2020 = 1 if year >=2020 
		replace Post2020 = 0 if Post2020==. 
	
	foreach var in 	Y_coversublocade  NoPA1sublocade {
		reg `var' Post2020 [aw=n_npi]	
		estadd ysumm
		eststo `var'w				

		reg `var' Post2020	
		estadd ysumm
		eststo `var'			
		}
	
	esttab Y_coversublocade  NoPA1sublocade using "${tabledir}/Table_T-test-private2017_vs_2021_sublocade.rtf",  ///
	replace modelwidth(14) ///
	keep(Post2020) ///
	order(Post2020) ///
	label nogaps  ///
	cells(b(fmt(a1)star) ci(fmt(a1)par("(" " to " ")")) p(fmt(a2))  )  ///	
	stats(ymean ysd N,fmt(%3.2f %3.2f 0)  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs."))  
		  
	esttab Y_coversublocade  NoPA1sublocade using "${tabledir}/Table_T-test-private2017_vs_2021_sublocade.rtf",  ///
	append modelwidth(14) ///
	keep(Post2020) ///
	order(Post2020) ///
	label nogaps  ///
	cells(b(fmt(a1)star) ci(fmt(a1)par("(" " to " ")")) p(fmt(a2))  )  ///	
	stats(ymean ysd N,fmt(%3.2f %3.2f 0)  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs."))  
	
	table1, vars(Y_coversublocade cat \ NoPA1sublocade cat \ ) ///
	 by(Post2020) format(%2.1f) 	saving("${tabledir}/Table_a_2GroupsPost2020_sublocade.xls", replace)
	
	keep if n_npi!=. 
	
	table1, vars(Y_coversublocade cat \ NoPA1sublocade cat \ ) ///
	 by(Post2020) format(%2.1f) 	saving("${tabledir}/Table_a_2GroupsPost2020_withNetworkSize_sublocade.xls", replace)	
	
	** generic bup/nal film  [2019-2021]	
	use "${intdir}/plan_formulary_BUP2017_2021_private.dta", clear 		
	
	keep if year==2019 | year == 2021 
	gen Post2020 = 1 if year >=2020 
		replace Post2020 = 0 if Post2020==. 
	
	foreach var in 	Y_covergenBUPNALfil NoPA1genBUPNALfil {
		reg `var' Post2020 [aw=n_npi]	
		estadd ysumm
		eststo `var'w				

		reg `var' Post2020	
		estadd ysumm
		eststo `var'			
		}
	
	esttab Y_covergenBUPNALfil NoPA1genBUPNALfil using "${tabledir}/Table_T-test-private2017_vs_2021_genBUPNALfil.rtf",  ///
	replace modelwidth(14) ///
	keep(Post2020) ///
	order(Post2020) ///
	label nogaps  ///
	cells(b(fmt(a1)star) ci(fmt(a1)par("(" " to " ")")) p(fmt(a2))  )  ///	
	stats(ymean ysd N,fmt(%3.2f %3.2f 0)  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs."))  
		  
	esttab Y_covergenBUPNALfil NoPA1genBUPNALfil using "${tabledir}/Table_T-test-private2017_vs_2021_genBUPNALfil.rtf",  ///
	append modelwidth(14) ///
	keep(Post2020) ///
	order(Post2020) ///
	label nogaps  ///
	cells(b(fmt(a1)star) ci(fmt(a1)par("(" " to " ")")) p(fmt(a2))  )  ///	
	stats(ymean ysd N,fmt(%3.2f %3.2f 0)  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs."))  

	
	table1, vars(Y_covergenBUPNALfil cat \ NoPA1genBUPNALfil cat \ ) ///
	 by(Post2020) format(%2.1f) 	saving("${tabledir}/Table_a_2GroupsPost2020_genBUPNALfil.xls", replace)
	

	keep if n_npi!=. 
	
	table1, vars(Y_covergenBUPNALfil cat \ NoPA1genBUPNALfil cat \ ) ///
	 by(Post2020) format(%2.1f) 	saving("${tabledir}/Table_a_2GroupsPost2020_withNetworkSize_genBUPNALfil.xls", replace)
	
	
	
	
	
	
	
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
	** testing the adjusted change per year 
/////////////////////////////////////////////////////////////////////////////////
*** weight adjusted test - using regression ***
	use "${intdir}/plan_formulary_BUP2017_2021_private.dta", clear 		
	foreach var in Y_coversublocade NoPA1sublocade {
	replace `var'=. if year<2018
	}

	foreach var in Y_covergenBUPNALfil NoPA1genBUPNALfil {
	replace `var'=. if year<2019
	}
	
	foreach var in IR_BUP IR_film IR_tablet ER_BUP suboxone zubsolv bunavail genBUPNALtab genBUPtab genBUPNALfil sublocade probuphine {
		reg Y_cover`var' year	
		estadd ysumm
		eststo Y_cover`var'	
		
		reg Y_cover`var' year [aw=n_npi]	
		estadd ysumm
		eststo Y_cover`var'w
		
		reg NoPA1`var' year	
		estadd ysumm
		eststo NoPA1`var'	
		
		reg NoPA1`var' year [aw=n_npi]	
		estadd ysumm
		eststo NoPA1`var'w		

	}
	
	esttab Y_coverIR_BUP Y_coverIR_film Y_coverIR_tablet Y_coversuboxone Y_covergenBUPNALfil Y_coverbunavail Y_coverzubsolv  Y_covergenBUPNALtab Y_covergenBUPtab  ///
	Y_coverER_BUP Y_coversublocade Y_coverprobuphine using "${tabledir}/Table1_trendOLS_private.rtf",  ///
	replace modelwidth(14) onecell ///
	keep(year) ///
	order(year) ///
	label nogaps  ///
	cells(b(fmt(a1)) ci(fmt(a1)par("(" " to " ")")) p(fmt(a2))  )  ///	
	stats(ymean ysd N,fmt(%3.2f %3.2f 0)  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs."))  
	
	
	esttab NoPA1IR_BUP NoPA1IR_film NoPA1IR_tablet NoPA1suboxone NoPA1genBUPNALfil NoPA1bunavail NoPA1zubsolv  NoPA1genBUPNALtab NoPA1genBUPtab  ///
	NoPA1ER_BUP NoPA1sublocade NoPA1probuphine using "${tabledir}/Table1_trendOLS_private.rtf",  ///
	append modelwidth(14) onecell ///
	keep(year) ///
	order(year) ///
	label nogaps  ///
	cells(b(fmt(a1)) ci(fmt(a1)par("(" " to " ")")) p(fmt(a2))  )  ///	
	stats(ymean ysd N,fmt(%3.2f %3.2f 0)  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs."))  
		  

	esttab Y_coverIR_BUPw Y_coverIR_filmw Y_coverIR_tabletw Y_coversuboxonew Y_covergenBUPNALfilw Y_coverbunavailw Y_coverzubsolvw Y_covergenBUPNALtabw Y_covergenBUPtabw  ///
	Y_coverER_BUPw Y_coversublocadew Y_coverprobuphinew using "${tabledir}/Table1_trendOLS_privateWeight.rtf",  ///
	replace modelwidth(14) onecell ///
	keep(year) ///
	order(year) ///
	label nogaps  ///
	cells(b(fmt(a1)) ci(fmt(a1)par("(" " to " ")")) p(fmt(a2))  )  ///	
	stats(ymean ysd N,fmt(%3.2f %3.2f 0)  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs."))  
	
	
	esttab NoPA1IR_BUPw NoPA1IR_filmw NoPA1IR_tabletw NoPA1suboxonew NoPA1genBUPNALfilw NoPA1bunavailw NoPA1zubsolvw NoPA1genBUPNALtabw NoPA1genBUPtabw ///
	NoPA1ER_BUPw NoPA1sublocadew NoPA1probuphinew using "${tabledir}/Table1_trendOLS_privateWeight.rtf",  ///
	append modelwidth(14) onecell ///
	keep(year) ///
	order(year) ///
	label nogaps  ///
	cells(b(fmt(a1)) ci(fmt(a1)par("(" " to " ")")) p(fmt(a2))  )  ///	
	stats(ymean ysd N,fmt(%3.2f %3.2f 0)  ///
	label("Dep. Variable Mean" "Dep. Variable SD" "Obs."))  
	
	
	
	*** compare outcomes between formularies without NPIs 
	gen NetworkSize= 0 
	replace NetworkSize= 1 if n_npi!=.
	codebook formulary_id if NetworkSize==1 // 451
	codebook formulary_id if NetworkSize==0 // 415 
	
	sum Y_coverIR_BUP
	
table1, vars(Y_coverIR_BUP cat\  Y_coverIR_film cat\ Y_coverIR_tablet cat\  ///
	NoPA1IR_BUP cat\  NoPA1IR_film cat\ NoPA1IR_tablet cat\ Y_coversublocade cat \ NoPA1sublocade cat \ ) ///
	 by(NetworkSize) format(%2.1f) 	saving("${tabledir}/eTable_summary_2Groups.xls", replace)
	
table1, vars(Y_coverIR_BUP cat\  Y_coverIR_film cat\ Y_coverIR_tablet cat\  ///
	NoPA1IR_BUP cat\  NoPA1IR_film cat\ NoPA1IR_tablet cat\ Y_coversublocade cat \ NoPA1sublocade cat \ ) ///
	format(%2.1f) 	saving("${tabledir}/eTable_summary_AllGroups.xls", replace)
	
	
	stddiff i.Y_coverIR_BUP i.Y_coverIR_film i.Y_coverIR_tablet i.NoPA1IR_BUP i.NoPA1IR_film i.NoPA1IR_tablet ///
	i.Y_coversublocade i.NoPA1sublocade, by(NetworkSize)

	
	
	
	*** compare outcomes across types of formularies 
	
	replace Group1_CMS=0 if Group1_CMS==.

table1, vars(Y_coverIR_BUP cat\  Y_coverIR_film cat\ Y_coverIR_tablet cat\  ///
	Y_coversuboxone cat\ Y_covergenBUPNALfil cat\ Y_coverbunavail cat\ Y_coverzubsolv  cat\ Y_covergenBUPNALtab cat\ Y_covergenBUPtab cat\ ///
	NoPA1IR_BUP cat\  NoPA1IR_film cat\ NoPA1IR_tablet cat\ NoPA1suboxone cat\ NoPA1genBUPNALfil cat\ ///
	NoPA1bunavail cat\ NoPA1zubsolv  cat\ NoPA1genBUPNALtab cat\ NoPA1genBUPtab cat\ ///
	 Y_coversublocade cat \ NoPA1sublocade cat \ ) ///
	 by(Group1_CMS) format(%2.1f) 	saving("${tabledir}/eTable_summary_Group1_CMS.xls", replace)
	
	
table1, vars(Y_coverIR_BUP cat\  Y_coverIR_film cat\ Y_coverIR_tablet cat\  ///
	Y_coversuboxone cat\ Y_covergenBUPNALfil cat\ Y_coverbunavail cat\ Y_coverzubsolv  cat\ Y_covergenBUPNALtab cat\ Y_covergenBUPtab cat\ ///
	NoPA1IR_BUP cat\  NoPA1IR_film cat\ NoPA1IR_tablet cat\ NoPA1suboxone cat\ NoPA1genBUPNALfil cat\ ///
	NoPA1bunavail cat\ NoPA1zubsolv  cat\ NoPA1genBUPNALtab cat\ NoPA1genBUPtab cat\ ///
	 Y_coversublocade cat \ NoPA1sublocade cat \ ) ///
	 by(InsuranceMarket) format(%2.1f) 	saving("${tabledir}/eTable_summary_Group1_CMS_InsuranceMarket.xls", replace)
	

table1, vars(Y_coverIR_BUP cat\  Y_coverIR_film cat\ Y_coverIR_tablet cat\  ///
	Y_coversuboxone cat\ Y_covergenBUPNALfil cat\ Y_coverbunavail cat\ Y_coverzubsolv  cat\ Y_covergenBUPNALtab cat\ Y_covergenBUPtab cat\ ///
	NoPA1IR_BUP cat\  NoPA1IR_film cat\ NoPA1IR_tablet cat\ NoPA1suboxone cat\ NoPA1genBUPNALfil cat\ ///
	NoPA1bunavail cat\ NoPA1zubsolv  cat\ NoPA1genBUPNALtab cat\ NoPA1genBUPtab cat\ ///
	 Y_coversublocade cat \ NoPA1sublocade cat \ ) ///
	 by(Type) format(%2.1f) 	saving("${tabledir}/eTable_summary_All_Type_Private.xls", replace)
	
	
	
		
	
	
	
	clear all 
	
	/*
///
