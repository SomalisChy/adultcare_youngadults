
clear all

cd ""

capture log close
log using tascore_cleaning.log, replace

use [path]\tascore.dta



codebook, c

**** RENAME VARIABLES FOR ANALYSIS

*2017
rename ///
	(ER32000 ER66408 ER66683 ER66718 ER66719 ER66731 ER66732 ER34503 ///
	ER34504  ER34548 ER34650 TA170006 TA170381 TA170452 TA170453 ///
	TA170780 TA171955 TA171956 TA171957 TA171958 TA171959 ///
	TA171972 TA171980 TA171981 TA171983 TA171985 ///
	TA171987) /// 
	(sex hrswork_rp2017 hrswork_sp2017 childcare_rp2017 adultcare_rp2017 ///
	childcare_sp2017 adultcare_sp2017 relrp2017 age2017 edyrs_core2017 ///
	pwt2017 rpsp_ofum2017 hrswork_ofum2017 childcare_ofum2017 ///
	adultcare_ofum2017 edu_tas2017 racemen12017 racemen22017 ///
	racemen32017 racemen42017 racemen52017 ///
	emo_wb2017 enrollment2017 momed2017 ///
	daded2017 maritalstat2017 sampwt2017) 


*2019
rename ///
	(ER72408 ER72685 ER72722 ER72723 ER72735 ER72736 ER34703 ///
	ER34704 ER34752 ER34863 TA190005 TA190578 TA190655 TA190656 TA190917 ///
	TA192131 TA192132 TA192133 TA192134 TA192135 TA192149 ///
	TA192158 TA192190 TA192192 TA192194 TA192199) ///
	(hrswork_rp2019 hrswork_sp2019 childcare_rp2019 adultcare_rp2019 ///
	childcare_sp2019 adultcare_sp2019 relrp2019 age2019 edyrs_core2019 ///
	pwt2019 rpsp_ofum2019 hrswork_ofum2019 childcare_ofum2019 ///
	adultcare_ofum2019 edu_tas2019 racemen12019 racemen22019 ///
	racemen32019 racemen42019 racemen52019 emo_wb2019 ///
	maritalstat2019 enrollment2019 ///
	momed2019 daded2019 sampwt2019) 
	
codebook, c	

gen persid =(ER30001*1000)+ER30002
distinct persid 
label var persid "Unique Identifier"
distinct persid

//keep only observations appear in two waves
drop if TAS17==. | TAS19==.

//reshape to long for easier coding

reshape long hrswork_rp hrswork_sp childcare_rp adultcare_rp ///
	childcare_sp adultcare_sp relrp age edyrs_core ///
	pwt rpsp_ofum hrswork_ofum childcare_ofum adultcare_ofum ///
	racemen1 racemen2 racemen3 racemen4 racemen5 ///
	emo_wb maritalstat ///
	enrollment momed daded edu_tas sampwt, i(persid) j(year) 


***CLEANING AND CODING****

***CONTROL VARIABLES***

*gender

codebook sex
recode sex (1=0 "Male") (2=1 "Female"), gen(gender)
label var gender "Gender" 
codebook gender


*race 
gen race =. 

//NH White - mention 1 and no other mention
replace race =1 if racemen1==1 & racemen2==0 & racemen3==0 & ///
		racemen4==0 & racemen5==0
		
//Hispanic - mention 2 and no other mention				  
replace race=2 if racemen1==2 & racemen2==0 & racemen3==0 & ///
		racemen4==0 & racemen5==0 
				  
//White Hispanic -> Hispanic - first mention white; second mention hispanic and no other mention 				  
replace race=2 if racemen1==1 & racemen2==2 & racemen3==0 & ///
		racemen4==0 & racemen5==0
replace race=2 if racemen1==2 & racemen2==1 & racemen3==0 & ///
		racemen4==0 & racemen5==0				  

//Black Hispanic -> Hispanic - first mention black; second mention hispanic and no other mention 				  
replace race=2 if racemen1==3 & racemen2==2 & racemen3==0 & ///
		racemen4==0 & racemen5==0
replace race=2 if racemen1==2 & racemen2==3 & racemen3==0 & ///
		racemen4==0 & racemen5==0
				  
//NH Black - mention 3 and no other mention	
replace race=3 if racemen1==3 & racemen2==0 & racemen3==0 & ///
		racemen4==0 & racemen5==0 
				  
//other race - mention 4-8 and no other mention
replace race=4 if racemen1 >=4 & racemen1 <98 & racemen2==0 & ///
		racemen3==0 & racemen4==0 & racemen5==0 
				
//multiracial
//first and second mentions, no 3, 4, 5th mention

replace race=5 if racemen1==3 & racemen2==1 & racemen3==0 & racemen4==0 ///
		& racemen5==0
		
replace race=5 if racemen1==1 & racemen2==3 & racemen3==0 & racemen4==0 ///
		& racemen5==0 				
				
replace race =5 if racemen1>=4 & racemen1<98 & racemen2 >0 & racemen3==0 ///
		& racemen4==0 & racemen5==0
				
replace race =5 if racemen1 <4 & racemen2 >=4 & racemen3==0 & ///
				racemen4==0 & racemen5==0				
					
//mention any race in 1, 2, and 3 mentions but not 4th and 5th
replace race =5 if racemen1<98 & racemen2 >0 & racemen3 >0 & ///
		racemen4==0  & racemen5==0

//mention any race in 1, 2, 3, and 4 mentions but not in 5th				
replace race =5 if racemen1<98 & racemen2 >0 & racemen3 >0 & ///
		racemen4 >0 & racemen5==0
				
//mention any race in 5 mentions
replace race =5 if racemen1 <98 & racemen2 >0 & racemen3 >0 & ///
		racemen4 >0 & racemen5>0				

//due to small sample size, the last two categories are combined.
//recode and label each value 
recode race  (1=1 "NH White") (2=2 "Hispanic") (3=3 "NH Black") ///
			(4/5=4 "Other Race"),gen(race_eth)

label var race_eth "Race/Ethnicity"	

*marital status
recode maritalstat (2 5 7 8=1 "Single") (1 6=2 "Cohabiting") ///
		(3=3 "Married") (99=.), gen(marital_status)
	

*college enrollment status

recode enrollment (1/7 95=0 "No") (9/11=1 "Yes") (98/99=.), ///
	gen(enroll_status) 

*education core
replace edyrs_core=. if edyrs_core==99

*education tas - conservative measures of  highest degree

replace edu_tas=. if edu_tas==0 | edu_tas>20
gen edyrs_tas=edu_tas 
//code to match core data, anything higher than 17 or higher is set to 17 
replace edyrs_tas=17 if edyrs_tas >=17 & edyrs_tas !=.

gen edyrs=. 
replace edyrs=edyrs_core if edyrs_core != . // fill in from core
replace edyrs= edyrs_tas if edyrs_tas != . ///
		& edyrs_core !=. & edyrs_core==0 //fill in from TAS	

//clean up
drop edyrs_core edyrs_tas edu_tas
		
*parent's education
**Parent Ed equal to dad's edu if dad edu is bigger than mom edu when both are not missing or use dad edu if mom edu is not known 

gen par_ed = daded if daded > momed & momed <96 & daded <96 ///
			| daded <96 & momed >17 

//parent ed equal to mom edu if dad edu if smaller than mom edu when both are not missing or use mom edu if dad edu is not known.  	
		
replace par_ed = momed if daded <= momed & momed <96 & ///
		daded <96 | momed <96 & daded >17

replace par_ed =1 if par_ed <=12 & par_ed !=.
replace par_ed = 2 if par_ed >12 & par_ed <=15 ///
					& par_ed !=.
replace par_ed =3 if par_ed >=16 & par_ed !=.


label define par_ed2 1 "High School or Less" 2 "Some College" ///
			3 "Bachelor's Degree or Higher" 
label values par_ed par_ed2



**GENERATE ONE VARIABLE FOR HRSWORK, ADULTCARE, AND CHILDCARE

	

//make sure there is no missing

replace childcare_rp=. if  childcare_rp >168
replace childcare_sp=. if  childcare_sp >168 
replace childcare_ofum=. if  childcare_ofum >168  
replace adultcare_rp=. if  adultcare_rp >168 
replace adultcare_sp=. if  adultcare_sp >168 
replace adultcare_ofum=. if  adultcare_ofum >168 
replace hrswork_rp=. if hrswork_rp > 112
replace hrswork_sp=. if hrswork_sp > 112
replace hrswork_ofum=. if hrswork_ofum > 112

***child care
***Identify care hours by relationship to reference person 

gen childcare_RP = . 
gen adultcare_RP = . 
gen childcare_SP = . 
gen adultcare_SP = . 

foreach var in childcare_ adultcare_ {
	forvalues i= 2017(2)2019 { 
	
	replace `var'RP = `var'rp if year == `i' & relrp==10

	replace `var'SP = `var'sp if year == `i' & relrp==20 | year == `i' ///
	& relrp==22 | year == `i' & relrp==88 | year == `i' & relrp==90 ///
	| year == `i' & relrp==98

} 
} 


gen childcare_core = childcare_RP if childcare_RP != . //filling in care hours if reference person
replace childcare_core = childcare_SP if childcare_core == . & ///
			childcare_SP !=.  //filling in care hours if spouse  

// checking if data transfer correctly
browse persid year childcare_rp childcare_sp childcare_SP childcare_RP			
			
gen childcare = childcare_ofum // reported childcare in the TAS.

replace childcare  = childcare_core if childcare_core != ///
	childcare_ofum & childcare_core !=. & childcare_ofum !=. //when tas and core are different
		
replace childcare  = childcare_core if childcare_core != childcare_ofum & childcare_ofum == . & rpsp_ofum != 3 // when TAS is missing & missing obs are not ofum			

//check again with complete a childcare variable
browse persid year childcare_* childcare 
			
			
***adultcare 

gen adultcare_core = adultcare_RP if adultcare_RP != . //filling in care hours if reference person
replace adultcare_core = adultcare_SP if adultcare_core == . & ///
		adultcare_SP //filling in care hours if spouse

// checking if data transfer correctly
browse persid year adultcare_rp adultcare_sp adultcare_SP adultcare_RP		
		
gen adultcare = adultcare_ofum  //reported adult care in the TAS.

replace adultcare= adultcare_core if adultcare_core != adultcare_ofum  & adultcare_core != . & adultcare_ofum != .  //when tas and core are different

replace adultcare= adultcare_core if adultcare_core != adultcare_ofum & adultcare_ofum == . & rpsp_ofum !=3  //when TAS is missing & missing obs are not ofum			

//check again with complete a adultcare variable
browse persid year adultcare_* adultcare 

***hrswork
***Identify work hours by relationship to reference person 

gen hrswork_RP=.
gen hrswork_SP=. 

foreach var in hrswork_ {
	forvalues i= 2017(2)2019 { 
	
	replace `var'RP = `var'rp if year == `i' & relrp==10

	replace `var'SP = `var'sp if year == `i' & relrp==20 | year == `i' ///
	& relrp==22 | year == `i' & relrp==88 | year == `i' & relrp==90 ///
	| year == `i' & relrp==98

} 
}

//checking if everything is correct
browse persid year hrswork_rp hrswork_sp hrswork_RP hrswork_SP

gen hrswork_core= hrswork_RP if hrswork_RP !=. //filling info for RP
replace hrswork_core = hrswork_SP if hrswork_core ==. & hrswork_SP !=. //filling info for SP

*hrswork
gen hrswork = hrswork_ofum //reported adult care in the TAS.

replace hrswork= hrswork_core if hrswork_core != hrswork_ofum ///
& hrswork_core != . & hrswork_ofum != .  //when tas and core are different

replace hrswork= hrswork_core if hrswork_core != hrswork_ofum & hrswork_ofum == . & rpsp_ofum !=3 //when TAS is missing & missing is not ofum

// check again with a complete hrswork variable 
browse persid year hrswork_* hrswork

//clean up - keep only complete care and work variables
drop childcare_* adultcare_* hrswork_*


//Create dummy variables with care variables
	
// dummy for child care status
gen CCstatus = . 
replace CCstatus = 1 if childcare>0 & childcare !=.
replace CCstatus=0 if childcare==0
label var CCstatus "Child Care Status"
label de CCstatus 0 "No" 1 "Yes"
label val CCstatus CCstatus

// dummy for adult care status
gen ACstatus=.
replace ACstatus = 1 if adultcare>0 & adultcare !=.
replace ACstatus=0 if adultcare==0
label var ACstatus "Adult Care Status"
label de ACstatus 0 "No" 1 "Yes"
label val ACstatus ACstatus

//categorical variable for adultcare hours
gen adultcare_cat=.
replace adultcare_cat= 0 if adultcare== 0 
replace adultcare_cat = 1 if adultcare > 0 & adultcare < 5 & ///
		adultcare !=.
replace adultcare_cat = 2 if adultcare >4 & adultcare !=.

label define Adultcare 0 "No care" 1 "1 - 4" 2 "5 or more "
label values adultcare_cat Adultcare 

replace emo_wb=. if emo_wb >6


//keep only variables use in analysis 
drop ER30000 ER66001 ER70680 TA170001 ER72001 ER76688 TA190001 racemen1 racemen2 racemen3 racemen4 racemen5 race TA192152 maritalstat enrollment momed daded

//label variables for reference
label var rpsp_ofum "Reference Person/Spouse/OFUM Status" 
label de rpsp_ofum 1 "Reference Person" 2 "Spouse/Partner" 3 "Other Family Unit Member (OFUM)"
label val rpsp_ofum rpsp_ofum

label var year "Year"
label var relrp "Relationship to Reference Person"
label var age "Age"
label var edyrs "Educational Attainment"
label var pwt "Longitudinal Weight"
label var rpsp_ofum "ReferencePerson/Spouse/OFUM Status"
label var emo_wb "Emotional Well-being"
label var gender "Gender"
label var marital_status "Marital Status"
label var enroll_status "College Enrollment"
label var par_ed "Parental Education"
label var childcare "Childcare Hours Per Week"
label var adultcare "Adultcare Hours Per Week"
label var hrswork "Hours Worked Per Week"
label var CCstatus "Childcare Status"
label var ACstatus "Adultcare Status"
label var adultcare_cat "Adultcare Hours Category"

save [path]\tascore_long.dta, replace

reshape wide relrp age pwt rpsp_ofum emo_wb edyrs sampwt gender race_eth marital_status enroll_status par_ed childcare adultcare hrswork CCstatus ACstatus adultcare_cat, i(persid) j(year) 

****SAVE DATA FOR TWO-WAVE ANALYSIS****

save [path]\tascore_wide.dta, replace

log close 

