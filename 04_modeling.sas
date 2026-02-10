
options nodate nonumber;
title;

libname proj "C:\Users\swaps\OneDrive\Desktop\BS805\Project";

/*
Output location */
%let outpath = C:\Users\swaps\OneDrive\Desktop\BS805\Project\outputs;
%let outfile = &outpath.\04_modeling.pdf;

ods graphics on;
ods pdf file="&outfile" style=journal;

/*
Prep: Analysis dataset (exclude missing outcome if needed) */
data work.ana;
  set proj.adsl_like;
  where exclude = 0;  /* keep only non-missing ADIN7YRS subjects */
run;

title1 "Modeling: Homocysteine and Cognitive Function (MMSE)";
title2 "Analysis Dataset (EXCLUDE=0)";
proc sql;
  select count(*) as N_Analysis
  from work.ana;
quit;

/*
Model 1: Crude association (MMSE ~ LHCY) */
title2 "Model 1 (Crude): MMSE = LHCY";

ods output ParameterEstimates=work.pe_crude FitStatistics=work.fit_crude;
proc reg data=work.ana;
  model mmse = lhcy / clb;
run;
quit;

/*
Model 2: Adjusted model (MMSE ~ LHCY + AGE + EDUCG + MALE + PKYRS) */
title2 "Model 2 (Adjusted): MMSE = LHCY + AGE + EDUCG + MALE + PKYRS";

ods output ParameterEstimates=work.pe_adj OverallANOVA=work.anova_adj FitStatistics=work.fit_adj;
proc glm data=work.ana;
  class educg;
  model mmse = lhcy age male educg pkyrs / solution clparm;
run;
quit;

/*
Model 3: Effect modification (interaction with sex)
MMSE = LHCY + MALE + LHCY*MALE + covariates */
title2 "Model 3 (Interaction): Test Effect Modification by Sex (LHCY*MALE)";

ods output ParameterEstimates=work.pe_int OverallANOVA=work.anova_int;
proc glm data=work.ana;
  class educg;
  model mmse = lhcy male lhcy*male age educg pkyrs / solution clparm;
run;
quit;

/*
Confounding check: compare crude vs adjusted beta for LHCY
Creates a small table in output (beta_crude, beta_adj, % change) */
title2 "Confounding Assessment: Crude vs Adjusted LHCY Coefficient";

proc sql;
  create table work.lhcy_betas as
  select 
    a.estimate as beta_crude format=8.4,
    b.estimate as beta_adjusted format=8.4,
    calculated beta_crude - calculated beta_adjusted as diff format=8.4,
    ( (calculated beta_crude - calculated beta_adjusted) / calculated beta_crude )*100
      as pct_change format=8.2
  from
    (select estimate from work.pe_crude where upcase(variable)="LHCY") as a,
    (select estimate from work.pe_adj where upcase(parameter)="LHCY") as b
  ;
quit;

proc print data=work.lhcy_betas label noobs;
  label
    beta_crude    = "Crude beta (LHCY)"
    beta_adjusted = "Adjusted beta (LHCY)"
    diff          = "Crude - Adjusted"
    pct_change    = "% Change (|attenuation|)";
run;

/*
Diagnostics on adjusted model
Use PROC REG for VIF/TOL + influence outputs.
Note: EDUCG is categorical; for diagnostics we include it as numeric
--------------------------------------------------------------*/
title2 "Adjusted Model Diagnostics (PROC REG): VIF/TOL + Influence Points";

ods output ParameterEstimates=work.pe_diag;
proc reg data=work.ana;
  model mmse = lhcy age male educg pkyrs / vif tol clb;
  id id;
  output out=work.diag_out
    rstudent=rstud
    cookd=cookd
    p=pred
    r=resid;
run;
quit;

/* Identify influential points (common thresholds) */
data work.influential;
  set work.diag_out;
  /* thresholds used in practice vary; these are common screening rules */
  if abs(rstud) > 3 or cookd > 0.1;
run;

title3 "Influential Observations (|RStudent| > 3 OR Cook's D > 0.1)";
proc print data=work.influential noobs;
  var id rstud cookd pred mmse lhcy age male educg pkyrs;
run;

/* Residual diagnostics plots */
title3 "Residual Diagnostics Plots (Adjusted Model)";
proc sgplot data=work.diag_out;
  scatter x=pred y=resid;
  refline 0 / axis=y;
  xaxis label="Predicted MMSE";
  yaxis label="Residual";
run;

proc sgplot data=work.diag_out;
  scatter x=pred y=rstud;
  refline 0 / axis=y;
  refline -3 3 / axis=y;
  xaxis label="Predicted MMSE";
  yaxis label="Studentized Residual";
run;

proc sgplot data=work.diag_out;
  scatter x=pred y=cookd;
  refline 0.1 / axis=y;
  xaxis label="Predicted MMSE";
  yaxis label="Cook's Distance";
run;

/*
Close PDF */
ods pdf close;
ods graphics off;
title;
