*cd "/Users/jeff_wong/Documents/github/panelviewstata"



use eg_simdata.dta, replace
panelview Y D , type(outcome) i(id) t(time) mycolor(Reds) discrete ytitle("haha my y title here") title("Discrete Outcome")
stop


use eg_turnout.dta, replace
panelview turnout policy_edr, type(treat) i(abb) t(year) mycolor(PuBu) bytiming prepost(off) ylabel("") title("How's bytiming working?")

stop

use eg_capacity.dta, replace
panelview lngdp polity2 ,type(treat) i(country) t(year) continuoustreat mycolor(Reds) ///
prepost(off) ylabel("") xlabel("") title("How's Continuous Treat Mappin Working?")

stop

use eg_capacity.dta, replace
panelview lngdp demo ,type(treat) i(country) t(year) mycolor(Greens) prepost(off) ylabel("") xlabel("") title("hah")

stop


use eg_turnout.dta, replace
replace policy_edr = 2 if abb == 5
panelViewAll policy_edr abb year turnout if abb <= 30 , mycolor(GnBu)
stop
panelViewAll policy_edr abb year turnout if abb <= 80 , mycolor(Blues)

use eg_turnout.dta, replace
replace policy_edr = 2 if abb == 5
panelViewAll policy_edr abb year turnout if abb <= 80 , mycolor(Blues)
panelViewAll policy_edr abb year turnout if abb <= 80 , mycolor(Greys)

stop


use eg_capacity.dta, replace
panelViewAll demo country year , mycolor(YlOrRd)

stop


use eg_turnout.dta, replace
replace policy_edr = 2 if abb == 5
panelViewAll policy_edr abb year turnout if abb < 7 , mycolor(green) 

use eg_simdata.dta, replace
panelViewAll D id time Y , mycolor(green) discrete
stop


sysdir

