
options nodate nonumber;
title;

libname proj "C:\Users\swaps\OneDrive\Desktop\BS805\Project";

%let outpath = C:\Users\swaps\OneDrive\Desktop\BS805\Project\outputs;
%let outfile = &outpath.\03_descriptive_analysis.pdf;

ods graphics on;

/* PDF output */
ods pdf file="&outfile" style=journal;

/*
Section 1: Dataset snapshot + missingness */
title1 "Descriptive Analysis: Homocysteine and Cognitive Function";
title2 "Dataset Snapshot and Missingness";

proc sql;
  select count(*) as N_Observations
  from proj.adsl_like;
quit;

proc means data=proj.adsl_like n nmiss;
  var age pkyrs hcy lhcy folate vitb12 vitb6 mmse adin7yrs;
run;

proc freq data=proj.adsl_like;
  tables male educg hsdeg agegrp exclude mmsef hcyge14 / missing;
run;

/*
Section 2: Table 1 style descriptive summary
- Continuous: N, Mean(SD), Median (Q1,Q3), Min-Max
- Categorical: counts and % */
title2 "Table 1: Descriptive Summary (Overall)";

/* Continuous variables */
title3 "Continuous Variables";
proc means data=proj.adsl_like n mean std median q1 q3 min max maxdec=2;
  var age pkyrs hcy lhcy folate vitb12 vitb6 mmse;
run;

/* Categorical variables */
title3 "Categorical Variables";
proc freq data=proj.adsl_like;
  tables male educg hsdeg agegrp mmsef hcyge14 / missing;
run;

/*
Section 3: Distribution plots (correct plot types) */
title2 "Distributions";

/* MMSE */
title3 "MMSE Distribution";
proc sgplot data=proj.adsl_like;
  histogram mmse;
  density mmse;
  xaxis label="MMSE Score";
run;

/* Homocysteine (raw) */
title3 "Homocysteine (HCY) Distribution";
proc sgplot data=proj.adsl_like;
  histogram hcy;
  density hcy;
  xaxis label="Plasma Homocysteine (umol/L)";
run;

/* Log Homocysteine */
title3 "Log Homocysteine (LHCY) Distribution";
proc sgplot data=proj.adsl_like;
  histogram lhcy;
  density lhcy;
  xaxis label="Log Plasma Homocysteine";
run;

/* Folate */
title3 "Folate Distribution";
proc sgplot data=proj.adsl_like;
  histogram folate;
  density folate;
  xaxis label="Plasma Folate (nmol/mL)";
run;

/* Pack-years */
title3 "Pack-years of Smoking (PKYRS) Distribution";
proc sgplot data=proj.adsl_like;
  histogram pkyrs;
  density pkyrs;
  xaxis label="Pack-years";
run;

/* Categorical plots */
title2 "Categorical Distributions";

/* Age group */
title3 "Age Group Distribution";
proc sgplot data=proj.adsl_like;
  vbar agegrp / datalabel;
  xaxis label="Age Group";
  yaxis label="Count";
run;

/* HCY >= 14 */
title3 "Elevated Homocysteine (HCY >= 14) Distribution";
proc sgplot data=proj.adsl_like;
  vbar hcyge14 / datalabel;
  xaxis label="HCY >= 14 (0=No, 1=Yes)";
  yaxis label="Count";
run;

/*
Close PDF */
ods pdf close;
ods graphics off;
title;
