clear all

capture log close
log using clean_code_2017.log, replace

cd ""

use [path]\tas2017.dta


codebook, c

**** RENAME VARIABLES FOR ANALYSIS


*2017
rename ///
	(ER32000  ER34503 ER34504 ER34548 ER34650 ///
	TA170006 TA170381 TA170452 TA170453 TA170780 TA171955 TA171956 ///
	TA171957 TA171958 TA171959 TA171972 TA171980 TA171981 TA171983 ///
	TA171985 TA171987) ///
	(sex relrp age edyrs_core pwt rpsp_ofum hrswork childcare ///
	adultcare edyrs_tas racemen1 racemen2 racemen3 racemen4 racemen5 ///
	emo_wb enrollment momed daded maritalstat sampwt) 

**Review that new var names match variables** 
codebook, c	


***CONTROL VARIABLES***

*gender

codebook sex
recode sex (1=0 "Male") (2=1 "Female"), gen(gender)
label var gender "Gender" 
codebook gender

*age 
gen age_cat=0 if age < 23 // 17-22 [in college]
replace age_cat=1 if age >=23 // 23-28 [college grad]

label var age "Age Continuous"
label var age_cat "Age"
label de age_cat 0 "17 - 22" 1 "23 - 28"

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
codebook maritalstat
recode maritalstat (2 5 7 8=1 "Single") (1 6=2 "Cohabiting") ///
		(3=3 "Married") (99=.), gen(marital_status)

*college enrollment status

recode enrollment (1/7 95=0 "No") (9/11=1 "Yes") (98/99=.), ///
	gen(enroll_status) 	


*education core
replace edyrs_core=. if edyrs_core==99

*education tas - conservative measures of  highest degree

replace edyrs_tas=. if edyrs_tas==0 | edyrs_tas>20

//code to match core data, anything higher than 17 or higher is set to 17 
replace edyrs_tas=17 if edyrs_tas >=17 & edyrs_tas !=.


gen edyrs=. 
replace edyrs=edyrs_core if edyrs_core != . // fill in from core
replace edyrs= edyrs_tas if edyrs_tas != . ///
		& edyrs_core !=. & edyrs_core==0 //fill in from TAS	

//clean up
drop edyrs_core edyrs_tas 
		
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


**recode for missing 
	
replace childcare=. if  childcare >168  
replace adultcare=. if  adultcare >168 
replace hrswork=. if hrswork > 112

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

//label variables for reference

label var rpsp_ofum "Reference Person/Spouse/OFUM Status" 
label de rpsp_ofum 1 "Reference Person" 2 "Spouse/Partner" 3 "Other Family Unit Member (OFUM)"
label val rpsp_ofum rpsp_ofum

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

save [path]\clean_tas2017.dta, replace

log close

******************************************************************************



