//Title: Toronto
//Author: Angela Kothe
//Date: 12.22.21
//Purpose: Cleaning COVID 
//Requires: Open Toronto COVID file, Week 11/14
//Output: Internal

clear all

cd "/Users/annkothe/Documents/GitHub/covid deaths"

import delimited "COVID19cases.csv", clear

// renaming variables
gen id = assigned_id
gen neighbourhood = neighbourhoodname
gen date = reporteddate

keep id date agegroup outbreakassociated neighbourhood classification outcome fsa

// filter by fatalities.
drop if outcome != "FATAL" 

// calculating deaths
gen x = 1

egen ndeaths = sum(x), by (date neighbourhood)

*deaths per day
egen dailytotal = sum(ndeaths), by (date)

*column of total number of deaths in the dataset
sort date neighbourhood

gen grosstotal = dailytotal + (_n - 1)

*collapse to organize by neighborhood and date
collapse (firstnm) outbreakassociated agegroup fsa classification outcome dailytotal gross ndeaths, by(date neighbourhood)

// save
save "cleanedCOVID19fatalities.dta"
