*******************************************************************************
* Section A - load data, set time series format
*******************************************************************************
clear all 
cd "/Users/annapeebles-brown/Library/Mobile Documents/com~apple~CloudDocs/Documents/Econometrics"   
import delimited tseriesq.csv 
* Data were downloaded from the UK Office of National Statistics 
* and the Bank of England (tbr and tbr_eq) in Jan 2017
* labels are set for each series
label variable gdp "UK GDP (chained volume measure in £ million, seasonally adjusted)" 
label variable unr "UK unemployment rate %, seasonally adjusted"
label variable cpi "UK consumer price inflation, seasonally adjusted"
label variable tbr "UK 3 month treasury bill rate"
label variable tbr_eq "UK 3 month treasury bill rate, end quarter value"
gen trend =_n  /*t is 1,2,...,_N, a new column vector = time variable*/

gen date=yq(year,quarter)
log using lab1_gdp, text replace 
tsset date, quarterly 
describe
list
********************************************************************************
Graphical Analysis of GDP data
********************************************************************************
gen lgdp=log(gdp) /*takes natural log of GDP*/ 
gen dlgdp=d.lgdp /*first difference* or equivalently dlgdp=lgdp-l.lgdp*/
tsline lgdp, title("lgdp") saving(ch1,replace)
regr lgdp trend 
predict fitted /*stores fitted values*/
predict lgdp_xt, residuals /*stores residuals = deviations in lnGDP from trend*/
tsline lgdp fitted, legend(off) lcolor(black red) title("lgdp and fitted trend line") saving(ch2,replace)
tsline lgdp_xt, title("deviations in lgdp from trend") saving(ch3,replace)
tsline dlgdp, title("dlgdp") saving(ch4,replace)
gr combine ch2.gph ch4.gph ch3.gph, col(2) title("Summary Plots of GDP data") saving(charts1, replace)
graph export charts1.pdf, replace
ac lgdp, lags(8) saving(ch1,replace) ylabel(-1(1)1) title("full sample acf for lgdp") 
ac lgdp_xt, lags(8) saving(ch3,replace) ylabel(-1(1)1) title("full sample acf for detrended lgdp") 
ac dlgdp, lags(8) saving(ch2,replace) ylabel(-1(1)1) title("full sample acf for dlgdp") 
gr combine ch1.gph ch2.gph ch3.gph, col(2) title("ACFs for gdp, detrended gdp and dlgdp") saving(charts2, replace)
graph export charts2.pdf, replace



*******************************************************************************
Summary Statistics, for full and sub sample 
*******************************************************************************
* look at summary statistics for full sample 
* and pre- and post-1985 samples
* is the mean and variance of detrended lgdp time invariant?
tabstat lgdp_xt, stat(n mean variance)
tabstat lgdp_xt if year<1985, stat(n mean variance)
tabstat lgdp_xt if year>1984, stat(n mean variance)
* is the mean and variance of detrended dlgdp time invariant?
tabstat dlgdp, stat(n mean variance)
tabstat dlgdp if year<1985, stat(n mean variance)
tabstat dlgdp if year>1984, stat(n mean variance)
* set up pre- and post-1985 sample values of lgdp and dlgdp
gen lgdpa=lgdp if year<1985
gen lgdpb=lgdp if year>1984
gen lgdp_xta=lgdp_xt if year<1985
gen lgdp_xtb=lgdp_xt if year>1984
gen dlgdpa=dlgdp if year<1985
gen dlgdpb=dlgdp if year>1984
* test of equality of means of lgdp_xt pre- and post-1985 
ttest lgdp_xta == lgdp_xtb, unpaired unequal
* test for equality of variances of lgdp_xt pre- and post-1985
sdtest lgdp_xta == lgdp_xtb
* test of equality of means of dlgdp pre- and post-1985 
ttest dlgdpa == dlgdpb, unpaired unequal
* test for equality of variances of dlgdp pre- and post-1985
sdtest dlgdpa == dlgdpb
* acfs for pre- and post-1985 samples
ac lgdpa, lags(8) saving(ac_a,replace)  ylabel(-1(1)1)  title("pre-1985 acf for lgdp")
ac dlgdpa, lags(8) saving(ac_da, replace)  ylabel(-1(1)1) title("pre-1985 acf for dlgdp")
ac lgdpb, lags(8) saving(ac_b,replace)  ylabel(-1(1)1)  title("post-1985 acf for lgdp")
ac dlgdpb, lags(8) saving(ac_db, replace) ylabel(-1(1)1) title("post-1985 acf for dlgdp")
gr combine ac_a.gph ac_da.gph ac_b.gph ac_db.gph, col(2) title("sub-sample acfs for lgdp and dlgdp") saving(charts2s, replace)
graph export charts2s.pdf, replace
*******************************************************************************
Formal unit root tests 
********************************************************************************
* Formal unit root tests for lgdp
* In each case...
* null hypothesis: lgdp has a unit root, ie. is non-stationary
* alternative hypothesis: lgdp is stationary about a trend
* Augmented Dickey Fuller Tests 
* start with 5 lags in ADF testing regression
* include trend
dfuller lgdp, lags(5) trend reg 
dfuller lgdp, lags(4) trend reg 
dfuller lgdp, lags(3) trend reg
dfuller lgdp, lags(2) trend reg
dfuller lgdp, lags(1) trend reg
dfuller lgdp, lags(0) trend reg
* Phillips and Perron test, with trend
pperron lgdp, trend reg
* Elliott, Rothenberg and Stock's DF-GLS test, with trend
dfgls lgdp, maxlag(5) trend 
*******************************************************************************
* formal unit root tests for dlgdp
* in each case, 
* null hypothesis: dlgdp has a unit root, ie. is non-stationary
* alternative hypothesis: dlgdp is stationary
********************************************************************************
* Augmented Dickey Fuller Tests 
* start with 4 lags in ADF testing regression, no trend
dfuller dlgdp, lags(4)  reg 
dfuller dlgdp, lags(3)  reg
dfuller dlgdp, lags(2)  reg
dfuller dlgdp, lags(1)  reg
dfuller dlgdp, lags(0)  reg
dfuller dlgdp, lags(2) reg
* Phillips and Perron test, no trend
pperron dlgdp, reg
* Elliott, Rothenberg and Stock's DF-GLS test, no trend
dfgls dlgdp, maxlag(4)

log close
