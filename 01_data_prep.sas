
options nodate nonumber;
title;

libname proj "C:\Users\swaps\OneDrive\Desktop\BS805\Project";

/* Merge source datasets (inner join = subjects present in all sources) */
proc sql;
  create table work.hcy_base as
  select 
      d.demogid as id label="Subject ID",
      d.age     label="Age (years)",
      d.male    label="Sex (1=Male,0=Female)",
      d.educg   label="Education category (1-4)",
      d.pkyrs   label="Pack-years of smoking",
      l.hcy     label="Plasma homocysteine (umol/L)",
      l.folate  label="Plasma folate (nmol/mL)",
      l.vitb12  label="Plasma vitamin B12 (pmol/L)",
      l.vitb6   label="Plasma vitamin B6 (nmol/L)",
      n.mmse    label="Mini-Mental State Examination (0-30)",
      n.adin7yrs label="AD within 7 years (0/1)"
  from proj.demog_bs805_f25 as d
  inner join proj.labs_bs805_f25  as l
    on d.demogid = l.labsid
  inner join proj.neuro_bs805_f25 as n
    on d.demogid = n.neuroid
  ;
quit;

/* QC: row count + key missingness */
title "QC (01): Base dataset row count";
proc sql;
  select count(*) as n_rows
  from work.hcy_base;
quit;

title "QC (01): Missingness snapshot for key variables";
proc means data=work.hcy_base n nmiss;
  var age male educg pkyrs hcy mmse adin7yrs;
run;

title;

data proj.hcy_base;
  set work.hcy_base;
run;
