
options nodate nonumber;
title;

libname proj "C:\Users\swaps\OneDrive\Desktop\BS805\Project";

/* Merge source datasets (inner join = subjects present in all three) */
proc sql;
  create table work.hcy_project as
  select 
      d.demogid  as id,
      d.age,
      d.male,
      d.educg,
      d.pkyrs,
      l.hcy,
      l.folate,
      l.vitb12,
      l.vitb6,
      n.mmse,
      n.adin7yrs
  from proj.demog_bs805_f25 as d
  inner join proj.labs_bs805_f25  as l on d.demogid = l.labsid
  inner join proj.neuro_bs805_f25 as n on d.demogid = n.neuroid
  ;
quit;

/*Derive variables */
data work.adsl_like;
  set work.hcy_project;

  length agegrp $8;
  label
    id       = "Subject ID"
    age      = "Age (years)"
    male     = "Sex (1=Male, 0=Female)"
    educg    = "Education category (1-4)"
    pkyrs    = "Pack-years of smoking"
    hcy      = "Plasma homocysteine (umol/L)"
    lhcy     = "Log plasma homocysteine"
    hcyge14  = "HCY >= 14 umol/L (1=Yes, 0=No)"
    agegrp   = "Age group"
    hsdeg    = "HS degree or higher (1=Yes, 0=No)"
    exclude  = "Exclude due to missing AD outcome (1=Yes, 0=No)"
    mmsef    = "Cognitive deficit flag (education-adjusted)"
  ;

  /* Log transform (guard against nonpositive values) */
  if hcy > 0 then lhcy = log(hcy);
  else lhcy = .;

  /* HCY cutoff */
  if not missing(hcy) then hcyge14 = (hcy >= 14);

  /* Age groups */
  if 65 <= age <= 74 then agegrp = "65-74";
  else if 75 <= age <= 79 then agegrp = "75-79";
  else if 80 <= age <= 84 then agegrp = "80-84";
  else if 85 <= age <= 89 then agegrp = "85-89";
  else agegrp = "OTHER";

  /* HS degree flag */
  if educg in (3,4) then hsdeg = 1;
  else if educg in (1,2) then hsdeg = 0;
  else hsdeg = .;

  /* Exclusion flag */
  exclude = missing(adin7yrs);

  /* Education-adjusted MMSE deficit flag */
  if not missing(mmse) and not missing(educg) then do;
    if educg = 1 then mmsef = (mmse <= 22);
    else if educg = 2 then mmsef = (mmse <= 24);
    else if educg = 3 then mmsef = (mmse <= 25);
    else if educg = 4 then mmsef = (mmse <= 26);
  end;
  else mmsef = .;

run;

/* Basic QC: counts + missingness */
proc sql;
  select count(*) as n_rows from work.adsl_like;
quit;

proc freq data=work.adsl_like;
  tables exclude hsdeg mmsef agegrp / missing;
run;

/* Save to PROJ library for downstream programs */
data proj.adsl_like;
  set work.adsl_like;
run;
