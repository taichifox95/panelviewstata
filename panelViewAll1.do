capture program drop panelViewAll

program define panelViewAll
	version 15.1
	syntax varlist(min = 3 max = 4) [if] [in] [, XLabel(passthru) YLabel(passthru) DISCRETE CONTINUOUSTREAT MYcolor(string) PREpost(string) * ]

	///making backup
	tempfile backup
	quietly save `backup'
	
	///mark to use sample
	marksample touse
	sum `touse'
	
	
	args treat ids tunit outcome
	
	tempvar nids
	capture confirm numeric variable `ids'
	if _rc {
		encode `ids', generate(`nids')
	}
	else {
		gen `nids' = `ids'
	}
	
	///deciding controll or treatment
	preserve
	tempfile tmp
	tempvar gcontrol
	quietly collapse (max) `treat', by(`nids')
	gen `gcontrol' = 1
	quietly replace `gcontrol' = 0 if `treat' >= 1
	quietly save `tmp'
	restore
	quietly merge m:1 `nids' using `tmp'
	drop _merge
	
	
	///turnback to original order
	sort `ids' `tunit' 
	
	///deciding color
	levelsof `treat' if `touse', loc (levstreat)

	di "levels" "`levstreat'"
	loc col = "red"
	loc col2 = "orange"
	di "before the col is " "`col'"
	di "`mycolor'"
	if ("`mycolor'" != "") {
		loc col = "`mycolor'"
	}
	di "now color is:" "`col'"

	levelsof `nids' if `touse' , loc (levsnids)
	
	
	///for heatmap: deciding prepost:
	tempvar heatvalue
	gen `heatvalue' = `treat'
	levelsof `heatvalue' if `touse', loc (levsheat)
	di "levsheat are:" `levsheat'
	foreach x of loc levsheat {
		replace `heatvalue' = `x' + 1 if `treat' == `x' & `treat' != 0
	}
	
	replace `heatvalue' = 1 if `treat' == 0 & `gcontrol' == 0
	
	if ("`prepost'"=="off") {
		replace `heatvalue' = 0 if `treat' == 0 & `gcontrol' == 1
	}
	
	
	
	
	
	
	
	
	
	if ("`outcome'" != "") {
	///ploting outcome:
		
		if ("`discrete'" == "" ) {
		///plotting lines of continuous outcome:
		
			///initiating a macro of lines:
			loc lines1
			
			///generate lines of outcome from control group
			foreach x of loc levsnids {
				loc lines1 "`lines1' || line `outcome' `tunit' if `nids' == `x' & `gcontrol' == 1 & `touse' , lc(gs12)"
			}
			
			///generate lines of pre-treatment outcome from treatment group 
			if (`"`prepost'"' != "off") {
				foreach x of loc levsnids {
					loc lines1 "`lines1' || line `outcome' `tunit' if `nids' == `x' & `gcontrol' == 0 & `touse' , lc(`col'%30)"
				}
			}
			
			///generate lines of post-treatment outcome from treatment group 
			foreach w of loc levstreat {
				if `w' != 0 {
					foreach x of loc levsnids {
						loc lines1 "`lines1' || line `outcome' `tunit' if `nids' == `x' & `treat' == `w' & `touse' , lc(`col')"
					}
				}

			}
				
			di "`lines1'"
			
			tw `lines1' , legend(off)
		} 
		else {
		///plotting dots of discrete outcome:
		
			///add some randomness to time units and outcome so that they can scatter around:
			tempvar rout rtime
			gen `rtime' = `tunit' + runiform(-0.2, 0.2)
			gen `rout' = `outcome' + runiform(-0.2, 0.2)
			
			loc dot1
			
			loc dot1 "`dot1' || sc `rout' `rtime' if `gcontrol' == 1 & `touse' , mcolor(gs12) "
			
			if (`"`prepost'"' != "off") {
				loc dot1 "`dot1' || sc `rout' `rtime' if `gcontrol' == 0 & `touse' , mcolor(`col'%30) || "
			}
			
			loc dot1 `"`dot1' || sc `rout' `rtime' if `treat' == 1 & `touse', mcolor(`col') legend(label(1 "Control") label(2 "Treated (Pre)") label(3 "Treated (Post)")) ytitle("`outcome'") xtitle("`tunit'") "'
			
			colorpalette hcl, blues
			
			tw `dot1' 
		}
	}
	
	
	else {
	///heatmap of treatment:
		if (`"`continuoustreat'"' != "off") {
			
		}
	}
	

	
	
	
	
	///restoring backup
	use `backup' , replace
	
end



use simdata.dta, replace
panelViewAll D id time Y , mycolor("`mcol'") discrete
stop




stop
use capacity.dta, replace
panelViewAll demo country year lngdp

stop


use turnout.dta, replace
replace policy_edr = 2 if abb == 5
panelViewAll policy_edr abb year turnout if abb < 7 , mycolor(green) 

use simdata.dta, replace
panelViewAll D id time Y , mycolor(green) discrete
stop


