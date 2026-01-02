
options nodate nonumber;
title;

libname proj "C:\Users\swaps\OneDrive\Desktop\BS805\Project";

/*
Output location */
%let outpath = C:\Users\swaps\OneDrive\Desktop\BS805\Project\outputs;
%let outfile = &outpath.\05_model_selection.pdf;

ods graphics on;
ods pdf file="&outfile" style=journal;

/*
Analysis dataset: match 04_modeling.sas (exclude missing outcome) */
data work.ana;
  set proj.adsl_like;
  where exclude = 0;
run;

title1 "Model Selection (LASSO): MMSE Outcome";
title2 "Analysis Dataset (EXCLUDE=0)";
proc sql;
  select count(*) as N_Analysis
  from work.ana;
quit;

/*
Full model fit (for comparison)
- Use PROC GLM (EDUCG categorical) */
title2 "Reference: Full Model Fit (GLM)";
ods output FitStatistics=work.fit_full OverallANOVA=work.anova_full ParameterEstimates=work.pe_full;
proc glm data=work.ana;
  class educg;
  model mmse = lhcy age male educg pkyrs / solution;
run;
quit;

/*
LASSO selection using SBC (BIC)
Notes:
- CLASS variables are split internally during LASSO selection.
- Use DETAILS=ALL to show selection path. */
title2 "LASSO Selection Using SBC (BIC): Candidate Predictors";
title3 "Candidates: LHCY, AGE, MALE, EDUCG (categorical), PKYRS";

ods output
  SelectedEffects=work.sel_effects
  FitStatistics=work.fit_lasso
  ParameterEstimates=work.pe_lasso
  SelectionSummary=work.sel_summary
  StopReason=work.stop_reason
;

proc glmselect data=work.ana plots=all;
  class educg male;
  model mmse = lhcy age male educg pkyrs
    / selection=lasso(choose=SBC stop=none)
      stats=all
      details=all;
run;

/*
Present key selection outputs */
title2 "Selected Effects (Final LASSO Model)";
proc print data=work.sel_effects noobs label;
run;

title2 "Selection Summary (Path + SBC)";
proc print data=work.sel_summary noobs;
run;

title2 "Final LASSO Model Parameter Estimates";
proc print data=work.pe_lasso noobs label;
run;

/*
Compare Full vs LASSO model (fit statistics)
GLM gives standard fit stats; GLMSELECT fit stats differ slightly.
Still useful as a portfolio comparison. */
title2 "Model Comparison: Full vs LASSO (Fit Statistics)";

/* Keep a compact subset of fit stats if available */
proc print data=work.fit_full noobs;
run;

proc print data=work.fit_lasso noobs;
run;

title2 "Quick Summary: What LASSO Kept vs Dropped";

data work.kept_dropped;
  length item $40 status $10;
  item="LHCY";   status="(see SelectedEffects)"; output;
  item="AGE";    status="(see SelectedEffects)"; output;
  item="MALE";   status="(see SelectedEffects)"; output;
  item="EDUCG";  status="(see SelectedEffects)"; output;
  item="PKYRS";  status="(see SelectedEffects)"; output;
run;

proc print data=work.kept_dropped noobs;
run;

ods pdf close;
ods graphics off;
title;

