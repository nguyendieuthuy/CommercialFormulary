
/* Start log */
capture log close
log using "${logdir}/Formulary_ReadingVericredData$S_DATE.log", replace

cd "${basedir}"
 
	/*

	// basic files 
	forvalues t = 2017/2021 {			
	import delimited  "${Vrawdatadir}/Formulary/`t'/formularies.csv", clear 
	compress 
	sum 
	save "${Vcleandatadir}/formularies`t'.dta", replace 

	import delimited  "${Vrawdatadir}/Formulary/`t'/drug_package_formularies.csv", clear 
	compress 
	sum 
	save "${Vcleandatadir}/drug_package_formularies`t'.dta", replace 

	import delimited  "${Vrawdatadir}/Formulary/`t'/formulary_plans.csv", clear 
	compress 
	sum 
	save "${Vcleandatadir}/formulary_plans`t'.dta", replace 
	}
	
	*/

	
	
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
	
	
	// NetworkFile 
	forvalues t = 2017/2018 {			
	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/network_plans.csv", clear 
	compress 
	sum 
	save "${Vcleandatadir}/network_plans`t'.dta", replace 

	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/network_providers.csv", clear 
	compress 
	sum 
	save "${Vcleandatadir}/network_providers`t'.dta", replace 

	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/networks.csv", clear 
	compress 
	sum 
	save "${Vcleandatadir}/networks`t'.dta", replace 

	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/providers.csv", clear 
	compress 
	sum 
	save "${Vcleandatadir}/providers`t'.dta", replace 		
	}	
	
		
	forvalues t = 2019/2019 {
	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/network_providers.csv", clear 
	compress 
	sum 
	save "${Vcleandatadir}/network_providers`t'.dta", replace 

	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/providers.csv", clear 
	compress 
	sum 
	save "${Vcleandatadir}/providers`t'.dta", replace 			
		/*
	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/network_plans.csv", clear 
	compress 
	sum 
	save "${Vcleandatadir}/network_plans`t'.dta", replace 


	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/networks.csv", clear 
	compress 
	sum 
	save "${Vcleandatadir}/networks`t'.dta", replace 
	*/
	}

	
	forvalues t = 2020/2021 {			
	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/network_plans.csv", clear // bridge file: network_id; hios_id 
	compress 
	sum 
	save "${Vcleandatadir}/network_plans`t'.dta", replace 

	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/network_providers.csv", clear // bridge file: network_id; npi 
	compress 
	sum 
	save "${Vcleandatadir}/network_providers`t'.dta", replace  

	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/networks.csv", clear // bridge file: network_id; network name (carrier name- network)
	compress 
	sum 
	save "${Vcleandatadir}/networks`t'.dta", replace 

	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/providers.csv", clear  // npi and zipcode 
	compress 
	sum 
	save "${Vcleandatadir}/providers`t'.dta", replace 
	
	* new files 
	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/provider_addresses.csv", clear  // npi and zipcode 
	compress 
	sum 
	save "${Vcleandatadir}/provider_addresses`t'.dta", replace 	
	
	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/network_provider_specialties.csv", clear  // npi and zipcode 
	compress 
	sum 
	save "${Vcleandatadir}/network_provider_specialties`t'.dta", replace 	
	
	
	import delimited  "${Vrawdatadir}/ACA Network/`t' Network Package/network_provider_addresses.csv", clear  // npi and zipcode 
	compress 
	sum 
	save "${Vcleandatadir}/network_provider_addresses`t'.dta", replace 		
	}		
	
	* data of 2017
	use "${Vcleandatadir}/network_plans2017.dta", clear
	codebook
	use "${Vcleandatadir}/networks2017.dta", clear
	codebook
	use "${Vcleandatadir}/network_providers2017.dta", clear
	codebook
	use "${Vcleandatadir}/providers2017.dta", clear
	codebook
////////////////////////////////////////////////////////////////////////////////	
	use "${Vcleandatadir}/network_plans2020.dta", clear
	codebook
	use "${Vcleandatadir}/networks2020.dta", clear
	codebook
	use "${Vcleandatadir}/network_providers2020.dta", clear
	codebook
	use "${Vcleandatadir}/providers2020.dta", clear
	codebook	
	

/// CCIIO data 
	import excel  "${Rootdatadir}/FormularyData/RawData/CCIIO/2019-Enrollment-Disenrollment-PUF.xlsx", firstrow sheet("QHP Enrollment Counts") cellrange(a2:e2651) clear 
	codebook
	save "${Vcleandatadir}/cciio_2019.dta", replace 		

	import excel  "${Rootdatadir}/FormularyData/RawData/CCIIO/2018-Enrollment-Disenrollment-PUF.xlsx", firstrow sheet("QHP Enrollment Counts") cellrange(a2:e2073) clear 
	codebook
	destring IssuerHIOSID, replace 
	save "${Vcleandatadir}/cciio_2018.dta", replace 
	
	import excel  "${Rootdatadir}/FormularyData/RawData/CCIIO/2017 Enrollment Disenrollment PUF.xlsx", firstrow sheet("QHP Enrollment Cnts") cellrange(a2:e3095) clear 
	codebook	
	save "${Vcleandatadir}/cciio_2017.dta", replace 	

	
	
	
	
	log close
	exit 
