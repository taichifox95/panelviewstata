



capture program drop panelHmap

program define panelHmap
 version 15.1
 syntax varlist(min=3 max=3) [if] [in] [, XLabel(passthru) YLabel(passthru) * CONTINOUS CONTROL]
 marksample touse
 tokenize `varlist'
 di "at first `1' is:" `1'
 di "at first `2' is:" `2'
 
 
 
 di "touse:" `touse'
 xunits `1' `touse'
 loc xdist=4*r(units)
 di "xdist:" `xdist'
 xunits `2' `touse'
 loc ydist=r(units)
 if (`"`xlabel'"'=="") {
  su `1', mean
  local xlabel `"xlabel(`r(min)'(`xdist')`r(max)', val angle(90) nogrid labsize(tiny))"'
  }
 if (`"`ylabel'"'=="") {
  su `2', mean
  local ylabel `"ylabel(`r(min)'(`ydist')`r(max)', val angle(0) nogrid labsize(tiny))"'
  }
 tempvar y0 y1
 g `y1'=`2'+`ydist'/2
 di "now y1 is:" `y1'
 di "now token2 is: " `2'
 la val `y1' `:val lab `2''
 g `y0'=`2'-`ydist'/2
 qui levelsof `3' if `touse', loc(lev)
 su `3' if `touse', mean
 loc minlev=r(min)
 loc maxlev=r(max)
 di "minlev is:" `minlev'
 di "levs are:" `lev'
 
 
 
 
 
 
 loc gcom
 foreach x of loc lev {
  loc zlev=(`x'-`minlev')/(`maxlev'-`minlev')
  loc R=int(0)
  loc G=int(200*(1-`zlev'))
  loc B=int(255)
  if ("`continous'"!="") {
   loc R=int(255*min(1,3*(`zlev')))
   loc G=int(255*min(1,3*max(0,(`zlev'-1/3))))
   loc B=int(255*min(1,3*max(0,(`zlev'-2/3))))
  }

  loc gcom `"`gcom'||rbar `y1' `y0' `1' if (`3'==`x')&(`touse'), barw(`xdist') col("`R' `G' `B'") fi(inten100) lw(none)"'
  }
  loc sc `"sc `2' `1', mlabpos(0) msy(i) `scopt'"'
 local gcom `"`gcom' leg(off) xsize(2) ysize(2) yscale(reverse) aspect(1) `ylabel' `xlabel'  xtitle("") ytitle("")"'
 tw `gcom' plotr(fc(white) m(zero)) `options' ||`sc'
 
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

use capacity.dta, replace

panelHmap year country polity2, continous title("polity2 score hmap", size(small)) xlabel()
panelHmap year country demo,  title("demo score hmap", size(small))


use turnout.dta, replace

panelHmap year abb policy_edr

