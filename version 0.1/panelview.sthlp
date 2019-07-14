{smcl}
{* *! version 1.0 14 Jul 2019}{...}
{cmd:help panelview}

{hline}

{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "panelview##syntax"}{...}
{viewerjumpto "Description" "panelview##description"}{...}
{viewerjumpto "Options" "panelview##options"}{...}
{viewerjumpto "Remarks" "panelview##remarks"}{...}
{viewerjumpto "Examples" "panelview##examples"}{...}
{title:Title}

{phang}
{bf:panelview} {hline 2} Panel data visualization tool


{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmd:panelview} {it:outcome} {it:treat} {ifin} [{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opth "i(varname:varname_i)"}}use
	{it:varname_i} as the panel ID variable{p_end}
{synopt :{opth "t(varname:varname_t)"}}use
	{it:varname_t} as the time variable{p_end}
{synopt:{opt type(string)}} specify plotting {opt treat} or {opt outcome} {p_end}

{syntab:Advanced}
{synopt:{opt disc:rete}} specify whether the outcome is discrete{p_end}
{synopt:{opt bytiming}} specify whether treat condition is sorted by first time being treated {p_end}
{synopt:{opt mycol:or(string)}} customize color scheme {p_end}
{synopt:{opt pre:post(string)}} specify whether plot pre-treat or post-treatment condition {p_end}
{synopt:{opt continuoustreat					}} specify whether treatment is continuous {p_end}
{synopt:{opt *}} {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{p 4 6 2}
A panel variable and a time variable must be specified.  Use {cmd:xtset}
(see {helpb xtset:[XT] xtset}) or specify the {cmd:i()} and {cmd:t()} options.
The {cmd:t()} option allows noninteger values for the time variable, whereas
{cmd:xtset} does not.


{marker description}{...}
{title:Description}
{pstd}
{opt panelview} visualizes panel data. {opt panelview} has two main functionalities: (1) it 
visualizes the treatment and missing-value statuses of each observation in a 
panel/time-series-cross-sectional (TSCS) dataset; and (2) it plots the outcome 
variable (either continuous or discrete) in a time-series fashion.
{p_end}


{marker options}{...}
{title:Options}
{dlgtab:Main}

{phang}
{opt i(varname_i)} and {opt i(varname_i)} override the panel settings from {helpb xtset}.
{it:varname_i} must be a numeric variable. For string variable, you can use {helpb encode} to generate numeric variable with string label. {p_end}

{dlgtab:Type}

{phang}
{opt type(string)}  {it:type} specifies whether to plot {opt outcome} or {opt treat}ment condition. If plot treatment condition, we use colorbricks to reveal whether the id is treated.  {p_end}

{phang}
{opt disc:rete}  specifies whether the outcome is discrete. If the outcome is discrete, the plot would display dots.  {p_end}

{phang}
{opt bytiming}  sets whether sorting units by the timing of receiving the treatment.  {p_end}

{phang}
{opt mycol:or(string)}  changes color scheme. We use Color Brewer from {opt colorpalette} 
package. Please install {opt palettes} before using. The default color scheme is {opt Reds}.{p_end} 
{phang}
{opt pre:post(string)} shows pre-treatment by distinguishing its color. Use {opt prepost(off)} to turn off this option.{p_end}

{phang}
{opt continuoustreat}  specifies the treatment condition to be continuous. With the help of {opt colorpalette}, we could show 9 levels of treatment condition. This option maps continuous treatment condition into these 9 levels.{p_end}



{title:Examples}

We provide three datasets to illustrate how {cmd:panelview} works. 

{pstd}Load sample dataset 1 (continuous outcome, discrete treatment){p_end}
{p 4 8 2}{stata "use turnout.dta, clear":. use turnout.dta, clear}{p_end}

{pstd}Plot the treatment condition{p_end}
{p 4 8 2}{stata "panelview turnout policy_edr, type(treat) i(abb) t(year)":. panelview turnout policy_edr, type(treat) i(abb) t(year)}{p_end}

{pstd}Turn off pre-post treatment visualization, and set your own y title and y label{p_end}
{p 4 8 2}{stata `"panelview turnout policy_edr, type(treat) i(abb) t(year) prepost(off) ytitle(I LOVE PANELVIEW) ylabel("")"':. panelview turnout policy_edr, type(treat) i(abb) t(year) prepost(off) ytitle("I LOVE PANELVIEW") ylabel("")}{p_end}

{pstd}Sort plot by treatment time{p_end}
{p 4 8 2}{stata `"panelview turnout policy_edr, type(treat) i(abb) t(year) bytiming ylabel("")"':. panelview turnout policy_edr, type(treat) i(abb) t(year) prepost(off) ylabel("")}{p_end}

{pstd}Plot the outcome{p_end}
{p 4 8 2}{stata "panelview turnout policy_edr, type(outcome) i(abb) t(year)":. panelview turnout policy_edr, type(outcome) i(abb) t(year)}{p_end}




{pstd}Load sample dataset 2 (continuous outcome, continuous treatment){p_end}
{p 4 8 2}{stata "use capacity.dta, clear":. use capacity.dta, clear}{p_end}

{pstd}Set panel variable using {helpb xtset}{p_end}
{p 4 8 2}{stata "xtset country year":. xtset country year}{p_end}

{pstd}Plot continuous treatment condition{p_end}
{p 4 8 2}{stata `"panelview lngdp polity2 ,type(treat) continuoustreat prepost(off) ylabel("")"':. panelview lngdp polity2 ,type(treat) continuoustreat prepost(off) ylabel("") }{p_end}




{pstd}Load sample dataset 3 (discrete outcome, discrete treatment){p_end}
{p 4 8 2}{stata "use simdata.dta, clear":. use simdata.dta, clear}{p_end}

{pstd}Plot with discrete outcome, and a new color scheme: Green{p_end}
{p 4 8 2}{stata `"panelview Y D , type(outcome) i(id) t(time) mycolor(Greens) discrete"':. panelview Y D , type(outcome) i(id) t(time) mycolor(Greens) discrete }{p_end}


