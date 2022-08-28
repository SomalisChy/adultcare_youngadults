clear all

***Set up working directory***
 
cd "" 

capture log close
log using analysis.log, replace


*** Loading TAS 2017 data for cross-sectional analysis ***
use clean_tas2017.dta


*** BEGIN CROSS-SECTIONAL ANALYSIS ***
***keep only variables use for analyses***
keep rpsp_ofum emo_wb sampwt gender age_cat race_eth marital_status enroll_status edyrs par_ed childcare adultcare hrswork CCstatus ACstatus adultcare_cat

**assign weight to variables: sampling weight

svyset [pweight=sampwt]

**create analytic sample

gen miss_flag =.

foreach var in rpsp_ofum emo_wb gender age_cat race_eth enroll_status marital_status  edyrs par_ed childcare adultcare hrswork CCstatus ACstatus adultcare_cat  { 

	replace miss_flag = 1 if `var' == . & miss_flag ==.
	
}

gen analytic_samp = . 
replace analytic_samp = 1 if miss_flag != 1 

count if analytic_samp==1 // n=2,396


**examine if there is outlier for adult care hours 

tab adultcare if analytic_samp==1

**drop outlier (168 hours per week) to avoid skewing the results

drop if adultcare==168

count if analytic_samp==1 

***final analytic_samp for 2017 is 2,394


***DESCRIPTIVE STATISTICS***


*TABLE 1. Dependent variables*
putdocx begin 

table (var) ACstatus () if analytic_samp==1 [pweight=sampwt], stat(mean edyrs hrswork emo_wb ) stat(sd edyrs hrswork emo_wb) stat(n ACstatus) ///
style(table-1) nformat(%12.2fc mean sd) sformat("(%s)" sd)

collect label values ACstatus 0 "Non-Adult Caregivers" 1 "Adult Caregivers"
collect preview
putdocx collect 


*TABLE 1. Key Variables*
svy: mean adultcare if ACstatus==1 & analytic_samp==1
estat sd

tab adultcare_cat if analytic_samp==1
sum adultcare if ACstatus==1 & analytic_samp==1,detail //median is 4 hours


*TABLE 2. Controls*

table (var) ACstatus () if analytic_samp==1 [pweight=sampwt], stat(fvproportion  i.gender i.age_cat i.race i.marital_stat i.enroll_stat ///
i.CCstatus i.par_ed i.rpsp_ofum) stat(n ACstatus) ///
style(table-1) nformat(%12.2fc fvproportion)
 

collect label values ACstatus 0 "Non-Adult Caregivers" 1 "Adult Caregivers"
collect preview

putdocx collect 
putdocx save tables.docx, replace  


**** T-TEST ****
*gen variables for each categorical variable
foreach var in gender age_cat race marital_status enroll_stat CCstatus par_ed rpsp_ofum {
	tab `var', gen(`var'_)
}

*t-test for table 1 and 2  

local vars edyrs hrswork emo_wb gender_1 gender_2 age_cat_1 age_cat_2 race_1 race_2 race_3 race_4 marital_status_1 marital_status_2 marital_status_3 enroll_stat_1 enroll_stat_2 CCstatus_1 CCstatus_2 par_ed_1 par_ed_2 par_ed_3 rpsp_ofum_1 rpsp_ofum_2 rpsp_ofum_3
qui: estpost ttest `vars' if analytic_samp==1, by(ACstatus)

esttab using ttest_analysis1.doc, replace ar2 


**renaming marital status and enroll status to avoid code break for ambiguous name
rename (marital_status enroll_status) (marital enroll)

***REGRESSION ANALYSIS***

svyset, clear	

**RUNNING PARSIMONIOUS MODELS with  adultcare indicator

** For educational attainment 
reg edyrs ACstatus if analytic_samp == 1
est sto M1

** model with only traits

reg edyrs ACstatus i.gender i.age_cat i.race_eth i.par_ed if analytic_samp == 1
est sto M2

*model with traits and states characteristics

reg edyrs ACstatus i.gender i.age_cat i.race_eth i.par_ed ///
		i.marital CCstatus ///
		i.rpsp_ofum if analytic_samp == 1
est sto M3 	

		
** For work hours per week

reg hrswork ACstatus if analytic_samp == 1
est sto M4

** model with only traits

reg hrswork ACstatus i.gender i.age_cat i.race_eth i.par_ed if analytic_samp == 1
est sto M5

*model with traits and states characteristics

reg hrswork ACstatus i.gender i.age_cat i.race_eth i.par_ed ///
		i.marital i.enroll CCstatus ///
		i.rpsp_ofum if analytic_samp == 1
est sto M6 	

** For emotional wellbeing

reg emo_wb ACstatus if analytic_samp == 1
est sto M7

** model with only traits

reg emo_wb ACstatus i.gender i.age_cat i.race_eth i.par_ed if analytic_samp == 1
est sto M8

*model with traits and states
reg emo_wb ACstatus i.gender i.age_cat i.race_eth i.par_ed ///
		i.marital i.enroll CCstatus ///
		i.rpsp_ofum if analytic_samp == 1
est sto M9 	

** Output table 

		
outreg2 [M1 M2 M3 M4 M5 M6 M7 M8 M9] ///
		using "reg_acstatus_ead.doc", replace dec(2) alpha(0.001, 0.01, 0.05)	
		

**RUNNING PARSIMONIOUS MODELS with adult care hour category	

** For educational attainment 
reg edyrs i.adultcare_cat if analytic_samp == 1
est sto M1

** model with only traits

reg edyrs i.adultcare_cat i.gender i.age_cat i.race_eth i.par_ed if analytic_samp == 1
est sto M2

** model with traits and states
reg edyrs i.adultcare_cat i.gender i.age_cat i.race_eth i.par_ed ///
		i.marital CCstatus ///
		i.rpsp_ofum if analytic_samp == 1
est sto M3 	

		
** For work hours per week 
reg hrswork i.adultcare_cat if analytic_samp == 1
est sto M4

** model with only traits

reg hrswork i.adultcare_cat i.gender i.age_cat i.race_eth i.par_ed if analytic_samp == 1
est sto M5

*model with traits and states
reg hrswork i.adultcare_cat i.gender i.age_cat i.race_eth i.par_ed ///
		i.marital i.enroll CCstatus ///
		i.rpsp_ofum if analytic_samp == 1
est sto M6 

** For emotional wellbeing

reg emo_wb i.adultcare_cat if analytic_samp == 1
est sto M7

** model with only traits

reg emo_wb i.adultcare_cat i.gender i.age_cat i.race_eth i.par_ed if analytic_samp == 1
est sto M8

*model with traits and states
reg emo_wb i.adultcare_cat i.gender i.age_cat i.race_eth i.par_ed ///
		i.marital i.enroll CCstatus ///
		i.rpsp_ofum if analytic_samp == 1
est sto M9 	

** Output table

		
outreg2 [M1 M2 M3 M4 M5 M6 M7 M8 M9] ///
		using "reg_achours_ead.doc", replace dec(2) alpha(0.001, 0.01, 0.05)

** Coefficient plots

quietly eststo edu: reg edyrs i.adultcare_cat i.gender ///
i.age_cat i.race_eth i.marital i.CCstatus i.par_ed ///
	i.rpsp_ofum if analytic_samp == 1
 
quietly eststo work: reg hrswork i.adultcare_cat ///
	i.gender i.age_cat i.race_eth i.marital ///
	i.enroll i.CCstatus i.par_ed i.rpsp_ofum if analytic_samp==1
	
quietly eststo emo: reg emo_wb i.adultcare_cat i.gender ///
	i.age_cat i.race_eth i.marital i.enroll ///
	i.CCstatus i.par_ed i.rpsp_ofum if analytic_samp==1	
				
coefplot (edu, 			), bylabel(Educational Attainment) ///
		|| (work) 			, bylabel(Hours Worked Per Week) ///
		|| (emo)				, bylabel(Emotional Well-Being) ///
		|| , keep(*adultcare_cat) drop(_cons) xline(0) byopts(xrescale) scheme(s1mono)
graph export "Figure1.tif", replace as(tif) name("Graph") 
	
**** 
	
*******END 2017 CROSS-SECTIONAL ANALYSIS*************

*******************************************************************
********** BEGIN ANAYSIS WITH 2-WAVE *****************		


*** Loading wide form TAS-CORE data 
		
use tascore_wide.dta, clear

****Prepared data to create key variables of interest **** 

***reshape to long except for baseline control variables.

reshape long gender pwt edyrs hrswork emo_wb  ///
		adultcare ACstatus adultcare_cat, i(persid) j(year)


xtset persid year

***Analytic Sample***

gen miss_flag =.

foreach var in gender age2017 race_eth2017 marital_status2017 ///
		enroll_status2017 CCstatus2017 par_ed2017 rpsp_ofum2017 ///
		hrswork edyrs emo_wb adultcare ACstatus ///
		adultcare_cat { 

replace miss_flag = 1 if `var' == . & miss_flag ==.
}


gen analytic_samp = . 
replace analytic_samp = 1 if miss_flag != 1 


** create key variable, Last Care 

*gen year care
bysort persid (year): gen year_care = year if ACstatus ==1 
tab year_care if analytic_samp==1

*gen maxyear care
bysort persid (year): egen maxyear_care = max(year_care)

**gen year last_care
gen last_care=0 
replace last_care=1 if maxyear_care==2017
replace last_care=2 if maxyear_care==2019
label var last_care "Year Most Recent Care"
label define last_care 0 "Never Care" 1 "Last Care 2017" 2 "Last Care 2019"
label values last_care last_care



*** RESHAPE TO WIDE FOR ANALYSIS ***

reshape wide pwt ACstatus adultcare adultcare_cat ///
		year_care hrswork edyrs emo_wb ///
		miss_flag analytic_samp, i(persid) j(year) 
		
// clean up 
drop analytic_samp2017 analytic_samp2019 miss_flag2019 miss_flag2017

*************DESCRIPTIVE STATISTICS AND REGRESS ANALYSIS*******************

**create new analytic sample with 2019 DVs and IVs at baseline in 2017

gen miss_flag =.

foreach var in gender age2017 race_eth2017 marital_status2017 ///
		enroll_status2017 CCstatus2017 par_ed2017 rpsp_ofum2017 ///
		hrswork2019 edyrs2019 emo_wb2019  { 

replace miss_flag = 1 if `var' == . & miss_flag ==.
}


gen analytic_samp = . 
replace analytic_samp = 1 if miss_flag != 1 

count if last_care !=0 & last_care !=. & analytic_samp==1 //  287 including those who care both year

count if last_care==1 & analytic_samp==1 //116
count if last_care==2 & analytic_samp==1 //171


***new and final analytic sample size N=1,661

****DESCRIPTIVE STATS****

// proceed with individual longitudinal weight 2019  

svyset [pweight=pwt2019]


**Prep variables for tables

gen age_cat=0 if age2017 < 23 // 17-22
replace age_cat=1 if age2017 >=23 // 23-28
tab age_cat

label var age2017 "Age Continuous"
label var age_cat "Age"
label de age_cat 0 "17 - 22" 1 "23 - 28"

**Appendix Table 2**

svy:mean adultcare2017 if analytic_samp==1 & last_care==1
svy:mean adultcare2019 if analytic_samp==1 & last_care==2

tab last_care if analytic_samp==1

**Appendix Table 3**

table (var) last_care () if analytic_samp==1 [pweight=pwt2019], ///
 stat(fvproportion i.gender i.age_cat i.race_eth2017 i.marital_status2017 i.enroll_status2017 i.CCstatus2017 i.par_ed2017 i.rpsp_ofum2017) ///
style(table-1) nformat(%12.2fc fvproportion)


collect label values last_care 0 "Never Care" 1 "Last Care 2017" 2 "Last Care 2019"
collect preview

collect export sumstat_lastcare.docx, replace 
 


*** T-TEST ****

*gen variables for each categorical variable


foreach var in gender age_cat race_eth2017 marital_status2017 enroll_status2017 CCstatus2017  par_ed2017 rpsp_ofum2017 {
	tab `var', gen(`var'_)
}

*t-test- Never care vs last care 2017 
local vars gender_1 gender_2 age_cat_1 age_cat_2 race_eth2017_1 race_eth2017_2 race_eth2017_3 race_eth2017_4 marital_status2017_1 marital_status2017_2 marital_status2017_3 enroll_status2017_1 enroll_status2017_2 CCstatus2017_1 CCstatus2017_2 par_ed2017_1 par_ed2017_2 par_ed2017_3 rpsp_ofum2017_1 rpsp_ofum2017_2 rpsp_ofum2017_3

estpost ttest `vars' if analytic_samp==1 & (last_care==0 | last_care==1), by(last_care)
esttab using analysis2_ttest1.doc, replace ar2


*t-test- Never care vs last care 2019 
local vars gender_1 gender_2 age_cat_1 age_cat_2 race_eth2017_1 race_eth2017_2 race_eth2017_3 race_eth2017_4 marital_status2017_1 marital_status2017_2 marital_status2017_3 enroll_status2017_1 enroll_status2017_2 CCstatus2017_1 CCstatus2017_2 par_ed2017_1 par_ed2017_2 par_ed2017_3 rpsp_ofum2017_1 rpsp_ofum2017_2 rpsp_ofum2017_3

estpost ttest `vars' if analytic_samp==1 & (last_care==0 | last_care==2), by(last_care)
esttab using analysis2_ttest2.doc, replace ar2

*t-test- Last care vs last care 2019 
local vars gender_1 gender_2 age_cat_1 age_cat_2 race_eth2017_1 race_eth2017_2 race_eth2017_3 race_eth2017_4 marital_status2017_1 marital_status2017_2 marital_status2017_3 enroll_status2017_1 enroll_status2017_2 CCstatus2017_1 CCstatus2017_2 par_ed2017_1 par_ed2017_2 par_ed2017_3 rpsp_ofum2017_1 rpsp_ofum2017_2 rpsp_ofum2017_3

estpost ttest `vars' if analytic_samp==1 & (last_care==1 | last_care==2), by(last_care)
esttab using analysis2_ttest3.doc, replace ar2


 
***REGRESSION ANALYSIS***

 
*set up controls
svyset, clear

		
*****Medium-Term Analysis****
		
* regress outcomes with LAST_CARE indicator	

*education
reg edyrs2019 i.last_care if analytic_samp == 1
est sto M1

**with only traits

reg edyrs2019 i.last_care i.gender i.age_cat i.race_eth2017 i.par_ed2017 if analytic_samp == 1
est sto M2

*with traits and states
reg edyrs2019 i.last_care i.gender i.age_cat i.race_eth2017 i.par_ed2017 ///
		i.marital_status2017 i.CCstatus2017 ///
		i.rpsp_ofum2017 if analytic_samp == 1
est sto M3 	

*work
reg hrswork2019 i.last_care if analytic_samp == 1
est sto M4

**with only traits

reg hrswork2019 i.last_care i.gender i.age_cat i.race_eth2017 i.par_ed2017 if analytic_samp == 1
est sto M5

*with traits and states
reg hrswork2019 i.last_care i.gender i.age_cat i.race_eth2017 i.par_ed2017 ///
		i.marital_status2017 i.enroll_status2017 i.CCstatus2017 ///
		i.rpsp_ofum2017 if analytic_samp == 1
est sto M6 

*emo wellbeing

reg emo_wb2019 i.last_care if analytic_samp == 1
est sto M7

**with only traits

reg emo_wb2019 i.last_care i.gender i.age_cat i.race_eth2017 i.par_ed2017 if analytic_samp == 1
est sto M8

*with traits and states
reg emo_wb2019 i.last_care i.gender i.age_cat ///
	i.race_eth2017 i.marital_status2017 i.enroll_status2017 ///
	i.CCstatus2017 i.par_ed2017 i.rpsp_ofum2017 if analytic_samp==1
est sto M9 	
	
outreg2 [M1 M2 M3 M4 M5 M6 M7 M8 M9] ///
		using "reg_lastcare.doc", replace dec(2) alpha(0.001, 0.01, 0.05)	
	

//add coefplot	

		
quietly eststo edu: reg edyrs2019 i.last_care i.gender i.age_cat ///
	i.race_eth2017 i.marital_status2017 i.CCstatus2017 ///
	i.par_ed2017 i.rpsp_ofum2017 if analytic_samp==1
	
quietly eststo work: reg hrswork2019 i.last_care i.gender i.age_cat ///
	i.race_eth2017 i.marital_status2017 i.enroll_status2017 ///
	i.CCstatus2017 i.par_ed2017 i.rpsp_ofum2017 if analytic_samp==1 

quietly eststo emo: reg emo_wb2019 i.last_care i.gender i.age_cat ///
	i.race_eth2017 i.marital_status2017 i.enroll_status2017 ///
	i.CCstatus2017 i.par_ed2017 i.rpsp_ofum2017 if analytic_samp==1
					
coefplot (edu, 			), bylabel(Educational Attainment) ///
		|| (work) 			, bylabel(Hours Worked Per Week) ///
		|| (emo)				, bylabel(Emotional Well-Being) ///
		|| , keep(*last_care) drop(_cons) xline(0) byopts(xrescale) scheme(s1mono)
		
graph export "Figure2.tif", replace as(tif) name("Graph")
	
***ROBUSTNESS CHECK****


**selection into ACstatus

***ROBUSTNESS CHECK****


**selection into ACstatus
**address concern of whether an obs become a cargiver because they already work less hours.

reg hrswork2017 ACstatus2019 if ACstatus2017==0 
//baseline group is people who are not caregiver in 2019
//confirms that caregiver in 2019 are indeed already working less hours in 2017 than non-caregiver. 

//similar test descriptively
sum hrswork2017 if ACstatus2019==1 & ACstatus2017==0 //mean=24.71 hrswork

sum hrswork2017 if ACstatus2019==0 & ACstatus2017==0 //mean=31.06 hrswork

**address concern of whether those who have childcare also provide adult care 
reg ACstatus2017 CCstatus2017 //slightly more likely
reg ACstatus2019 CCstatus2019
reg ACstatus2019 CCstatus2017

********* END SUB-ANALYSIS ***************		
		
log close 



