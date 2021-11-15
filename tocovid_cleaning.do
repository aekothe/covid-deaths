//Title: Toronto
//Author: Angela Kothe
//Date: 11.14.21
//Purpose: Cleaning COVID 
//Requires: Open Toronto COVID file, Week 11/14
//Output: Internal

clear all

cd "/Users/annkothe/Documents/GitHub/covid deaths"

import delimited "COVID19cases.csv", clear

//renaming variables
gen id = assigned_id
gen neighbourhood = neighbourhoodname
gen date = reporteddate

keep id date agegroup outbreakassociated neighbourhood classification outcome fsa

* filter by fatalities.

drop if outcome != "FATAL" 

*
gen deaths = 1

collapse (firstnm) outbreakassociated agegroup fsa classification outcome (sum) deaths, by(date neighbourhood)

*make a number of deaths in a day column

egen dailytotal = sum(deaths), by (date)

*column of total number of deaths in the dataset
foreach v of dailytotal {
	gen x = sum(deaths)
}

foreach i of numlist 1952(4)2012 {
 logit vote strg weak lean [pw=w] if year==`i'
}

save "cleanedCOVID19fatalities.dta"
