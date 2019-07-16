/*
Version 0.1
Jul 14 2019
*/

capture program drop panelview

program define panelview
	version 13.0
	syntax varlist(min = 2 max = 2 numeric) [if] [in] [, ///
	I(varname) T(varname numeric)	///
	TYPE(string)					///
	DISCrete						///
	bytiming						///
	MYCOLor(string)					///
	PREpost(string) 				///
	continuoustreat					///
	*								///
	]

	tokenize `varlist'
	loc outcome `1'
	loc treat `2'


	///making backup
	tempfile backup
	quietly save `backup'

	///mark to use sample
	marksample touse


	if "`i'`t'" != "" {
		// user supplied time and panel variables
		if "`t'" == "" {
			di as err "option i() requires option t()"
			use `backup' , replace
			exit 198
		}
		if "`i'" == "" {
			di as err "option t() requires option i()"
			use `backup' , replace
			exit 198
		}
	}
	else {
		// check for panel data
		_xt, i(`i') t(`t')
		local i `r(ivar)'
		local t `r(tvar)'
	}
	quietly count if `touse'
	if r(N) == 0 {
		error 2000
	}

	local ids `i'
	local tunit `t'

	/// check if id is encoded
	tempvar nids
	capture confirm numeric variable `ids'
	if _rc {
		encode `ids', generate(`nids')
	}
	else {
		gen `nids' = `ids'
	}

	//check for bad option combinations
	if "`continuoustreat'" != "" {
		if "`prepost'" != "off" {
			di as err ///
			"option ContinuousTreatment and PrePost may not be combined"
			use `backup' , replace
			exit 198
		}
	}

	if "`continuoustreat'" != "" {
		if "`bytiming'" != "" {
			di as err ///
			"option Continuous Treatment and ByTiming may not be combined"
			use `backup' , replace
			exit 198
		}
	}



	///deciding controll or treatment
	preserve
	tempfile tmp
	tempvar gcontrol
	qui collapse (max) `treat', by(`nids')
	gen `gcontrol' = 1
	qui replace `gcontrol' = 0 if `treat' >= 1
	qui save `tmp'
	restore
	qui merge m:1 `nids' using `tmp'
	drop _merge

	///turnback to original order
	sort `ids' `tunit'



	///lets sort by time of first treatment!
	if "`bytiming'" != "" {
		qui findfile sencode.ado

		if "`r(fn)'" == "" {
         di as txt "user-written package sencode needs to be installed first;"
         di as txt "use -ssc install sencode- to do that"
         exit 498
		}



		tempvar bytime
		tempfile tmp2
		gen `bytime' = .
		replace `bytime' = `tunit' if `treat' > = 1
		preserve
		qui collapse (min) `bytime' , by(`nids')
		qui save `tmp2'
		restore
		drop `bytime'
		qui merge m:1 `nids' using `tmp2'
		drop _merge

		tempvar nids2
		tempvar nids3
		decode `ids', generate(`nids2')
		sencode `nids2', generate(`nids3') gsort(`bytime')
		replace `ids' = `nids3'

	}

	qui levelsof `nids' if `touse' , loc (levsnids)
	capture drop _merge


	tempvar plotvalue
	gen `plotvalue' = `treat'
	///remapping continuous treatment to 9 levels to fit color palettes levels:
	if "`continuoustreat'" != "" {
		qui su `plotvalue'
		loc maxminplotvalue = r(max) - r(min)
		qui replace `plotvalue' = int((`plotvalue' - r(min)) * 9 / `maxminplotvalue' )

	}


	qui levelsof `plotvalue' if `touse', loc (levsplot)
	loc numlevsplot = r(r)



	///deciding prepost:
	if "`prepost'" != "off" {
		foreach x of loc levsplot {
			qui replace `plotvalue' = `x' + 1 if `treat' == `x' & `treat' != 0
		}
		qui replace `plotvalue' = 1 if `treat' == 0 & `gcontrol' == 0
		qui levelsof `plotvalue' if `touse', loc (levsplot)
		loc numlevsplot = r(r)
	}



	///deciding color
		///check whether colorpalette is installed:
	qui findfile colorpalette.ado

	if "`r(fn)'" == "" {
         di as txt "user-written package palettes needs to be installed first;"
         di as txt "use -ssc install palettes- to do that"
         exit 498
	}



	colorpalette Reds , n(`numlevsplot') nograph

	if (`"`mycolor'"' != "") {
		colorpalette `mycolor' , n(`numlevsplot') nograph

	}
	qui return list
	foreach w of loc levsplot {
		loc uu = `w' + 1
		loc col`w' = r(p`uu')
		tokenize `col`w''
		loc R`w' = `1'
		loc G`w' = `2'
		loc B`w' = `3'

	}


	///deciding plot coef unit
	qui su `tunit'
	loc maxmintime = r(max) - r(min)
	qui levelsof `tunit'
	loc numsoftime = r(r)
	loc plotcoef = `maxmintime' / (`numsoftime' -1)







	if ("`type'" == "outcome") {
	///ploting outcome:

		if ("`discrete'" == "" ) {
		///plotting lines of continuous outcome:


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
			tw `lines1' , legend(off) `options'





		}
		else {
		///plotting dots of discrete outcome:

			///add some randomness to time units and outcome so that they can scatter around:
			di "now display dots of discrete outcome"
			tempvar rout rtime
			gen `rtime' = `tunit' + runiform(-0.2, 0.2)
			gen `rout' = `outcome' + runiform(-0.2, 0.2)

			///beta:
			loc dot1

			foreach w of loc levsplot {
				loc dot1 `" `dot1' || sc `rout' `rtime' if `plotvalue' == `w' & `touse' , mcolor("`col`w''")   "'
			}

			if (`"`prepost'"' != "off") {
				tw `dot1' legend(label(1 "Control") label(2 "Treated (Pre)") label(3 "Treated (Post)")) ytitle("`outcome'") xtitle("`tunit'") `options'
			}
			else {
				tw `dot1' legend(label(1 "Control") label(2 "Treated")) ytitle("`outcome'") xtitle("`tunit'") `options'
			}
		}
	}

	else if ("`type'" == "treat"){
	///heatmap of treatment:

			////hmap
		xunits `tunit' `touse'


		loc xdist= `plotcoef' * r(units)

		xunits `ids' `touse'
		loc ydist = r(units)
		di "ydist:" `"`ydist'"'
		if (`"`xlabel'"'=="") {
			su `tunit', mean
			local xlabel `"xlabel(`r(min)'(`xdist')`r(max)', val angle(90) nogrid labsize(tiny))"'
		}
		if (`"`ylabel'"'=="") {
			su `ids', mean
			local ylabel `"ylabel(`r(min)'(`ydist')`r(max)', val angle(0) nogrid labsize(tiny))"'
		}
		tempvar y0 y1
		gen `y1'=`ids'+`ydist'/2

		qui sum `y1'

		la val `y1' `:val lab `ids''
		g `y0'=`ids'-`ydist'/2
		qui levelsof `plotvalue' if `touse', loc(levsplot)
		qui su `plotvalue' if `touse', mean
		loc minlev=r(min)
		loc maxlev=r(max)

		loc gcom

		di `levsplot'

		if (`"`continuoustreat'"' != "off") {
			foreach w of loc levsplot{
				loc gcom `"`gcom'||rbar `y1' `y0' `tunit' if (`plotvalue'==`w')&(`touse'), barw(`xdist') col("`col`w''") fi(inten100) lw(none)"'
			}

		}
		else {

		}
		loc sc `"sc `ids' `tunit' if `touse', mlabpos(0) msy(i) `scopt'"'

		local gcom `"`gcom' leg(off) xsize(2) ysize(2) yscale(reverse) aspect(1) `ylabel' `xlabel'  xtitle("") ytitle("")"'

		tw `gcom' plotr(fc(white) m(zero)) ||`sc' `options'
	}






	///restoring backup
	use `backup' , replace

end

capture program drop xunits
program xunits, rclass
	args v touse
	qui summ `v' if `touse', mean
	loc p = 1
	capture assert float(`v') == float(round(`v',1)) if `touse'
	if _rc == 0 {
		while _rc == 0 {
			loc p=`p'*10
			capture assert float(`v') == float(round(`v',`p')) if `touse'
		}
		loc p=`p'/10
	}
	else {
		while _rc {
			loc p=`p'/10
			capture assert float(`v') == float(round(`v',`p')) if `touse'
		}
	}
	return scalar units = `p'
end
