capture program drop panelView

program define panelView
	version 15.1
	syntax varlist(min = 4 max = 4) [if] [in] [, XLabel(passthru) YLabel(passthru) MYcolor(string) PREpost(string) * ]
	marksample touse
	sum `touse'
	
	
	args outcome treat ids tunit
	
	tempvar nids
	capture confirm numeric variable `ids'
	if _rc {
		encode `ids', generate(`nids')
	}
	else {
		gen `nids' = `ids'
	}
	quietly xtset `nids' `tunit'
	
	
	preserve
	tempfile tmp
	tempvar gcontrol
	quietly collapse (max) `treat', by(`nids')
	gen `gcontrol' = 1
	gen gc = 1
	quietly replace `gcontrol' = 0 if `treat' >= 1
	quietly replace gc = 0 if `treat' >= 1
	quietly save `tmp'
	restore
	quietly merge m:1 `nids' using `tmp'
	drop _merge
	
	
	tempvar n_val
	tempvar num
	bysort `nids' : gen `n_val' = _n == 1
	count if `n_val' == 1
	local num = r(N)
	
	
	
	///deciding color
	levelsof `treat', loc(lev)
	loc treatlvs = r(r)
	di "levels" "`treatlvs'"
	loc col = "red"
	loc col2 = "orange"
	di "before the col is " "`col'"
	di "`mycolor'"
	if ("`mycolor'" != "") {
		loc col = "`mycolor'"
	}
	di "now color is:" "`col'"

	if ("`prepost'" != "off") {
	loc plotline2 "addplot(line `outcome' `tunit' if `gcontrol' == 0, lc(`col'%20) connect(a)||"
	}
	
	if (`treatlvs' == 2) {
		di "lvs2"	
		loc plotline2 "`plotline2' line `outcome' `tunit' if `treat' == 1, lc(`col') connect(a) || `dtreat')"
		
	}
	if (`treatlvs' == 3) {
		di "lvs3"
		loc plotline2 "`plotline2' line `outcome' `tunit' if `treat' == 1, lc(`col2') connect(a) || "
		loc plotline2 "`plotline2' line `outcome' `tunit' if `treat' == 2, lc(`col') connect(a) || `dtreat')"
		
	}
	if (`treatlvs' == 4) {
		di "lvs4"
		loc plotline2 "`plotline2' line `outcome' `tunit' if `treat' == 1, lc(`col'%40) connect(a) || "
		loc plotline2 "`plotline2' line `outcome' `tunit' if `treat' == 2, lc(`col2'%70) connect(a) || "
		loc plotline2 "`plotline2' line `outcome' `tunit' if `treat' == 3, lc(`col') connect(a) || `dtreat')"
		
	}
	
	
	
	
	
	forvalues i = 1(1)`num' {
	local plotline1 "`plotline1' plot`i' (lc(gs12))"
	}
	
	macro drop num
	
	di "last"
	
	xtline `outcome', overlay `plotline1' legend(off) `plotline2' `option'
	
	
	//cleaning up stuff
	macro drop plotline1
	
end
panelView turnout policy_edr abb year, prepost(of1f)
stop

use turnout.dta, replace
panelView turnout policy_edr abb year, mycolor(green)
panelView turnout policy_edr abb year


