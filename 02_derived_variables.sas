
options nodate nonumber;
title;

libname proj "C:\Users\swaps\OneDrive\Desktop\BS805\Project";

/* Formats for readable outputs */
proc format;
  value sexf  0="Female" 1="Male";
  value yesnof 0="No" 1="Yes";
  value educgf
    1="<8 years"
    2=">=8 years, no HS"
    3="HS, no college"
    4="Some college+";
run;

/* Derive analysis variables */
data proj.adsl_like;
  set proj.hcy_base;

  length agegrp $8;
  label
    lhcy     = "Log plasma homocysteine"
    hcyge14  = "HCY >= 14 umol/L (1=Yes,0=No)"
    agegrp   = "Age group (65-89)"
    hsdeg    = "HS degree or higher (1=Yes,0=No)"
    exclude  = "Exclude due to missing ADIN7YRS (1=Yes,0=No)"
    mmsef    = "Cognitive deficit flag (education-adjusted)"
  ;

  format male sexf.
         educg educgf.
         hcyge14 yesnof.
         hsdeg yesnof.
         exclude yesnof.
         mmsef yesnof.;

  /* Log transform (guard against nonpositive values) */
  if hcy > 0 then lhcy = log(hcy);
  else lhcy = .;

  /* Binary cutoff variable */
  if not missing(hcy) then hcyge14 = (hcy >= 14);
  else hcyge14 = .;

  /* Age group variable */
  if 65 <= age <= 74 then agegrp = "65-74";
  else if 75 <= age <= 79 then agegrp = "75-79";
  else if 80 <= age <= 84 then agegrp = "80-84";
  else if 85 <= age <= 89 then agegrp = "85-89";
  else agegrp = "OTHER";

  /* HS degree flag from EDUCG */
  if educg in (3,4) then hsdeg = 1;
  else if educg in (1,2) then hsdeg = 0;
  else hsdeg = .;

  /* Exclusion flag: missing outcome */
  exclude = missing(adin7yrs);

  /* Education-adjusted cognitive deficit flag */
  if not missing(mmse) and not missing(educg) then do;
    if educg = 1 then mmsef = (mmse <= 22);
    else if educg = 2 then mmsef = (mmse <= 24);
    else if educg = 3 then mmsef = (mmse <= 25);
    else if educg = 4 then mmsef = (mmse <= 26);
  end;
  else mmsef = .;

run;

/* QC (02): derived variables sanity checks */
title "QC (02): Row count for analysis-ready dataset";
proc sql;
  select count(*) as n_rows
  from proj.adsl_like;
quit;

title "QC (02): Derived variable distributions (incl. missing)";
proc freq data=proj.adsl_like;
  tables exclude hsdeg mmsef hcyge14 agegrp / missing;
run;

title "QC (02): Key continuous variables";
proc means data=proj.adsl_like n mean std min p25 median p75 max nmiss;
  var age pkyrs hcy lhcy folate vitb12 vitb6 mmse;
run;

title;
