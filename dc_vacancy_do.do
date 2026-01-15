/*PPD 647 Term Project*/
/* Zachary Johnson */
/* Determining Whether DC's Vacancy Tax Impacted Housing Prices */

/* Install Synth Commands - if needed */
*ssc install synth, all replace
*capture ado uninstall synth_runner
*net install synth_runner, ///
*  from(https://raw.github.com/bquistorff/synth_runner/master/) replace
*ssc install allsynth

/* Setup */
clear all

cd "C:/Users/Zak Johnson/Documents/Fall 2022/Public Finance"
import excel "C:\Users\Zak Johnson\Documents\Fall 2022\Public Finance\Term Project\dc_vacancy.xlsx", sheet("Sheet1") firstrow

encode city, generate(city_number)
/* Set Panel */
by city, sort: gen city_num = _n == 1
count if city_num
replace city_num = sum(city_num)
xtset city_num year




/* Clean Data */
gen subprime_percent = real(subprime)
replace property_tax = property_tax*100
gen log_percap_income = log(percap_income)
gen new_units_percap = new_units/pop
replace new_units_percap = new_units_percap*100000
replace new_units_percap = new_units_percap*100
replace property_tax = property_tax/100
replace property_tax=property_tax/percap_income
destring pop_change, replace
destring minwage, replace
bysort city_num: gen diff_housing=D.housing_index
replace property_tax=property_tax*100

save cleaned, replace

*Drop for Shorter Period (Temporarily)*
drop if year>2013



/* Plot Housing Prices for All Cities */
xtline housing_index, overlay legend(off) plot15(lcolor(black) lwidth(vvthick)) ///
  xline(2003)
graph export "Johnson_housing_index.png", replace





/* Plot Housing Index & Average of All Other Cities */
preserve
gen treat = (city_num==31)
collapse (mean) housing_index, by(treat year)
xtset treat year
xtline housing_index, overlay xline(2003) xtitle(Year) ytitle(Housing Index)
graph export "Johnson_housing_indexDCvsUS.png", replace
restore







/* Synthetic Control Method */
/* Synth2 Results */
synth2 housing_index housing_index(1980&1985&1990&1995&2000) diff_housing(1979(1)2002) property_tax(1978(1)2000) pop pop_change pop_density minwage unemploy(1990(1)2002) subprime_percent(1999(1)2002) log_percap_income(1978(1)2002) new_units_percap(1988(1)2002) econ_index(1991(1)2002), trunit(31) trperiod(2003) fig nested allopt 





/* Leave One Out */
synth2 housing_index housing_index(1980&1985&1990&1995&2000) diff_housing(1979(1)2002) property_tax(1978(1)2000) pop pop_change pop_density minwage unemploy(1990(1)2002) subprime_percent(1999(1)2002) log_percap_income(1978(1)2002) new_units_percap(1988(1)2002) econ_index(1991(1)2002), trunit(31) trperiod(2003) fig nested allopt loo





/* Prepare for Synth Runner */
preserve
capture drop lead housing_index_synth effect pre_rmspe post_rmspe

/* Placebo in Space & RMPSEs */
synth_runner housing_index housing_index(1980&1985&1990&1995&2000) diff_housing(1979(1)2002) property_tax(1978(1)2000) pop pop_change pop_density minwage unemploy(1990(1)2002) subprime_percent(1999(1)2002) log_percap_income(1978(1)2002) new_units_percap(1988(1)2002) econ_index(1991(1)2002), trunit(31) trperiod(2003) gen_vars nested
  
/* Generate Placebo Graph */
single_treatment_graphs, trlinediff(-1) raw_gname(housing_index_raw) effects_gname(housing_index_effects) effects_ylabels(-100(25)100) effects_ymax(100) effects_ymin(-100)
graph export "Johnson_placebo_in_space.png", replace

/* Restore Data */
restore





/* All Time Series Methods */
/* Interrupted Time Series */

clear
use cleaned

*ITSA Graph*
itsa housing_index, treatid(31) single trperiod(2003) lag(1) posttrend figure

/* Time Series Analysis */
drop if city_num!=31
*Test for Unit Root*
xtunitroot ht housing_index, trend
line diff_housing year
 
*Autocorrelations Across Variables*
preserve
keep if city_num==31
pwcorr year housing_index diff_housing property_tax pop pop_change pop_density minwage unemploy subprime_percent log_percap_income new_units_percap econ_index
pwcorr housing_index L.housing_index, sig
pwcorr pop_change L.pop_change, sig
pwcorr subprime_percent L.subprime_percent, sig
ac housing_index
graph export "Johnson_autocorrelation.png", replace
restore
 