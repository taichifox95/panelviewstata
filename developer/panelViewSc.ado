capture program drop panelViewSc

program define panelViewSc
	version 15.1
	syntax varlist(min=4 max=4) [if] [in] [, XLabel(passthru) YLabel(passthru) * BYTIMING CONTINUOUS CONTROL PREPOST(string)]
	marksample touse
	sum `touse'
	
	args outcome treat ids tunit
 
	confirm numeric variable `ids'
	
	tempvar plotvalue
	gen `plotvalue' = `treat'
	
	//prepost
	preserve
	tempfile tmp
	tempvar gcontrol
	
	quietly collapse (max) `treat', by(`ids')

	gen `gcontrol' = 1
	quietly replace `gcontrol' = 0 if `treat' == 1
	quietly save `tmp'
	restore
	quietly merge m:1 `ids' using `tmp'
	drop _merge
	
	levelsof `plotvalue' if `touse', loc(lev)
	di "levs1 are:" `lev'
	foreach x of loc lev {
		replace `plotvalue' = `x' + 1 if `treat' == `x' & `treat' != 0
	}
	replace `plotvalue' = 1 if `treat' == 0 & `gcontrol' == 0

	
	if ("`prepost'"=="off") {
		replace `plotvalue' = 0 if `treat' == 0 & `gcontrol' == 1
	}
	
	
	
	di "touse:" `touse'
	xunits `tunit' `touse'
	loc xdist= 4 * r(units)
	di "xdist:" `xdist'
	xunits `ids' `touse'
	loc ydist=r(units)
	if (`"`xlabel'"'=="") {
		su `tunit', mean
		local xlabel `"xlabel(`r(min)'(`xdist')`r(max)', val angle(90) nogrid labsize(tiny))"'
	}
	if (`"`ylabel'"'=="") {
		su `ids', mean
		local ylabel `"ylabel(`r(min)'(`ydist')`r(max)', val angle(0) nogrid labsize(tiny))"'
	}
	tempvar y0 y1
	g `y1'=`ids'+`ydist'/2
	di "now y1 is:" `y1'
	sum `y1'
	di "now token2 is: " `ids'
	


	
	
	la val `y1' `:val lab `ids''
	g `y0'=`ids'-`ydist'/2
	qui levelsof `plotvalue' if `touse', loc(lev2)
	su `plotvalue' if `touse', mean
	loc minlev=r(min)
	loc maxlev=r(max)
	di "minlev is:" `minlev'
	di "levs2 are:" `lev2'
	
	bysort `ids' : gen n_val = _n == 1
	count if n_val == 1
	scalar a=r(N)
	di a
	local num = r(N)
	di "now num is:"`num'
 
	loc gcom
	
	
	foreach x of loc lev2 {
		loc zlev=(`x'-`minlev')/(`maxlev'-`minlev')
		loc R=int(0)
		loc G=int(255*(1-`zlev'))
		loc B=int(255*(1-`zlev'))
		if ("`continuous'"!="") {
			loc R=int(255*min(1,3*(`zlev')))
			loc G=int(255*min(1,3*max(0,(`zlev'-1/3))))
			loc B=int(255*min(1,3*max(0,(`zlev'-2/3))))
		}

		loc gcom `"`gcom'||rbar `y1' `y0' `tunit' if (`plotvalue'==`x')&(`touse'), barw(`xdist') col("`R' `G' `B'") fi(inten100) lw(none)"'
		}
	loc sc `"sc `ids' `tunit' if `touse', mlabpos(0) msy(i) `scopt'"'
	local gcom `"`gcom' leg(off) xsize(2) ysize(2) yscale(reverse) aspect(1) `ylabel' `xlabel'  xtitle("") ytitle("")"'
	tw `gcom' plotr(fc(white) m(zero)) `options' ||`sc'
	drop n_val
end


capture program drop xunits
program xunits, rclass 
	args v touse
	qui summ `v' if `touse', mean
	di "v in xunits:" `v'
	loc p = 1
	capture assert float(`v') == float(round(`v',1)) if `touse'
	if _rc == 0 {
		while _rc == 0 {
			loc p=`p'*10
			di "2222"`p'
			capture assert float(`v') == float(round(`v',`p')) if `touse'
		}
		loc p=`p'/10
		di "now p is:" `p'
	}
	else {
		while _rc {
			loc p=`p'/10
			capture assert float(`v') == float(round(`v',`p')) if `touse'
		}
	}
	di "now units is:" `p'
	return scalar units = `p'
end

stop

use simdata.dta, replace
panelViewSc Y D id time
stop




