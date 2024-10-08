*! cnsrsig V1.03 cloned from durbinh.ado  C F Baum/Vince Wiggins 9901

program define cnsrsig, rclass
	syntax [if] [in] [, noDetail noSample ] 
	version 6.0
	if "`e(cmd)'" ~= "cnsreg" {
		error 301
	}
	
	 tempname b regest
	 				/* get depvar and regressorlist from previous regression */
	 local depvar = e(depvar)
	 local dfmc = e(df_m)	
	 local dfrc = e(df_r)
	 local rmsec = e(rmse)
 	 local llc = e(ll)
     				/* calc sum of squares from restricted regression */
     local ssec = `rmsec'*`dfrc'
     mat `b' = e(b)
     local varlist : colnames `b'
     local varlist : subinstr local varlist "_cons" "", word count(local hascons)
     
     
	marksample touse
	if "`sample'" == "" { qui replace `touse' = 0 if !e(sample) }
	
					/* unconstrained regression */
	if !`hascons' { local cons "noconstant" }
	estimates hold `regest'
	qui regress `depvar'  `varlist' if `touse', `cons'
	local dfm = e(df_m)
	local dfr = e(df_r)
	local rmse = e(rmse)
	local ll = e(ll)
     				/* calc sum of squares from unrestricted regression */
	local sse = `rmse'*`dfr'
	     			/* calc number of constraints */
	return scalar ncns = `dfrc'-`dfr'
	     			/* calc F for restrictions  */
	return scalar F = ((`ssec'-`sse')/return(ncns))/`rmse'
	return scalar p = fprob(return(ncns), `dfr', return(F))
	return scalar df2 = `dfr'
	return scalar lrt = -2.0*(`llc'-`ll')
	return scalar pll = chiprob(return(ncns),return(lrt))
	estimates unhold `regest'
	
	di " "
	di in gr " F(" return(ncns) "," return(df2) ") for restrictions: "   /*
		*/ in ye %9.0g return(F) in gr /* 
		*/ "  P-value = " in ye %6.0g return(p) 
    di in gr " LR statistic = " %9.0g return(lrt) "  P-value = " %6.0g return(pll)
end
	
exit

