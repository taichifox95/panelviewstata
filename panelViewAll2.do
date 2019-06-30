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
	loc options `*'
	
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
	
	
	
	
	
	
	
	
	
	
	levelsof `nids' if `touse' , loc (levsnids)
	
	
	///deciding prepost:
	tempvar plotvalue
	gen `plotvalue' = `treat'
	levelsof `plotvalue' if `touse', loc (levsplot)
	loc numlevsplot = r(r)
	di "levsplot are:" `levsplot'

	if ("`prepost'"!="off") {
		foreach x of loc levsplot {
			replace `plotvalue' = `x' + 1 if `treat' == `x' & `treat' != 0
		}
		replace `plotvalue' = 1 if `treat' == 0 & `gcontrol' == 0
		levelsof `plotvalue' if `touse', loc (levsplot)
		loc numlevsplot = r(r)
	}
	
	
	
	///deciding color

	colorpalette Reds , n(`numlevsplot') nograph

	if (`"`mycolor'"' != "") {
		di "collll nowwww" `"`mycolor'"'
		colorpalette `mycolor' , n(`numlevsplot') nograph
	}
	return list
	foreach w of loc levsplot {
		loc uu = `w' + 1
		loc col`w' = r(p`uu')
		tokenize `col`w''
		loc R`w' = `1'
		loc G`w' = `2'
		loc B`w' = `3'

	}
	di "col0"  "is " "`col0'"
	di "R1 is " `R1'

	
	

	
	
	
	
	if ("`outcome'" != "") {
	///ploting outcome:
		
		if ("`discrete'" == "" ) {
		///plotting lines of continuous outcome:
			
			
			///beta:
			
			
			loc lines1
			
			foreach w of loc levsplot {
				loc thiscol = `"`col`w''"'
				di "`thiscol'"
				foreach x of loc levsnids {
					///ploting the gaps
					if (`"`prepost'"' != "off" & `w' == 1 ) {
					
						loc lines1 `" `lines1' || line `outcome' `tunit' if `nids' == `x' & `gcontrol' == 0 & `touse' , lcolor("`col`w''") "'
					}
					else if (`"`prepost'"' == "off" & `w' == 0 ) {
					
						loc lines1 `" `lines1' || line `outcome' `tunit' if `nids' == `x' & `gcontrol' == 0 & `touse' , lcolor("`col`w''") "'
					}
					
					
					loc lines1 `" `lines1' || line `outcome' `tunit' if `nids' == `x' & `plotvalue' == `w' & `touse' , lcolor("`col`w''") "'
				}
			}
			
			
			di `"`lines1'"'
			tw `lines1' , legend(off)
			
			
			
			
			
			
		} 
		else {
		///plotting dots of discrete outcome:
		
			///add some randomness to time units and outcome so that they can scatter around:
			tempvar rout rtime
			gen `rtime' = `tunit' + runiform(-0.2, 0.2)
			gen `rout' = `outcome' + runiform(-0.2, 0.2)
			
			///beta:
			loc dot1
			
			foreach w of loc levsplot {
				loc dot1 `" `dot1' || sc `rout' `rtime' if `plotvalue' == `w' & `touse' , mcolor("`col`w''")   "'
			}
			
			if (`"`prepost'"' != "off") {
				tw `dot1' legend(label(1 "Control") label(2 "Treated (Pre)") label(3 "Treated (Post)")) ytitle("`outcome'") xtitle("`tunit'")
			}
			else {
				tw `dot1' legend(label(1 "Control") label(2 "Treated")) ytitle("`outcome'") xtitle("`tunit'") 
			}
		}
	}
	
	else {
	///heatmap of treatment:
	
			////hmap
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
		qui levelsof `plotvalue' if `touse', loc(levsplot)
		su `plotvalue' if `touse', mean
		loc minlev=r(min)
		loc maxlev=r(max)
		di "minlev is:" `minlev'
		di "levs2 are:" `plotlev'
		
		loc gcom
		if (`"`continuoustreat'"' != "off") {
			foreach w of loc levsplot{
				loc gcom `"`gcom'||rbar `y1' `y0' `tunit' if (`plotvalue'==`w')&(`touse'), barw(`xdist') col("`col`w''") fi(inten100) lw(none)"'
			}
		}
		else {
		
		}
		loc sc `"sc `ids' `tunit' if `touse', mlabpos(0) msy(i) `scopt'"'
		local gcom `"`gcom' leg(off) xsize(2) ysize(2) yscale(reverse) aspect(1) `ylabel' `xlabel'  xtitle("") ytitle("")"'
		tw `gcom' plotr(fc(white) m(zero)) `options' ||`sc'
	}
	

	
	
	
	
	///restoring backup
	use `backup' , replace
	
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

use simdata.dta, replace
panelViewAll D id time Y , mycolor(Blues) discrete
stop


use turnout.dta, replace
replace policy_edr = 2 if abb == 5
panelViewAll policy_edr abb year turnout if abb <= 30 , mycolor(GnBu)
stop
panelViewAll policy_edr abb year turnout if abb <= 80 , mycolor(Blues)

use turnout.dta, replace
replace policy_edr = 2 if abb == 5
panelViewAll policy_edr abb year turnout if abb <= 80 , mycolor(Blues)
panelViewAll policy_edr abb year turnout if abb <= 80 , mycolor(Greys)

stop


use capacity.dta, replace
panelViewAll demo country year lngdp , mycolor(Greys)

stop


use turnout.dta, replace
replace policy_edr = 2 if abb == 5
panelViewAll policy_edr abb year turnout if abb < 7 , mycolor(green) 

use simdata.dta, replace
panelViewAll D id time Y , mycolor(green) discrete
stop


