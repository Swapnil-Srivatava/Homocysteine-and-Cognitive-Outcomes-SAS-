# Homocysteine-and-Cognitive-Outcomes-SAS-
## TL;DR
- End-to-end SAS analysis evaluating homocysteine and cognitive outcomes
- Clinical-style data preparation using PROC SQL and derived analysis flags
- Confounding and effect modification assessed using regression modeling
- Age identified as a major confounder; homocysteine effect attenuated after adjustment
- Variable selection compared using traditional regression vs LASSO
- Designed to mirror observational clinical / epidemiologic workflows

**Project Overview**

Cognitive decline in older adults is influenced by a combination of demographic, behavioral, and biochemical factors. Elevated plasma homocysteine has been proposed as a potential biomarker for impaired cognition, but its independent association remains unclear when key confounders are considered.

This project evaluates the relationship between plasma homocysteine levels and cognitive function, measured using the Mini-Mental State Examination (MMSE), using a structured statistical programming workflow implemented in SAS. The analysis emphasizes data preparation, variable derivation, regression modeling, confounding assessment, and model diagnostics, mirroring workflows commonly used in observational clinical and epidemiologic research.

**Objectives**

* Characterize distributions of demographic, laboratory, and cognitive variables
* Assess the association between plasma homocysteine and MMSE scores
* Evaluate age as a confounder and determine the most appropriate functional form
* Assess effect modification by sex
* Examine confounding through multivariable adjustment
* Compare traditional regression modeling with LASSO-based variable selection

## Repository Structure

### SAS Programs (run in order)
- `01_data_prep.sas`  
  Imports/merges source tables, cleans data, applies exclusion flags, and outputs an analysis-ready dataset.

- `02_derived_variables.sas`  
  Creates derived variables (e.g., transformed biomarkers, categorical covariates) used for modeling.

- `03_descriptive_analysis.sas`  
  Produces descriptive statistics and exploratory summaries.
- `03_descriptive_analysis.pdf`  
  Output report from descriptive analyses.

- `04_modeling.sas`  
  Runs crude and multivariable regression models, confounding checks, interaction tests, and diagnostics.
- `04_modeling.pdf`  
  Output report from modeling and diagnostics.

- `05_model_selection.sas`  
  Performs variable selection using `PROC GLMSELECT` (LASSO, SBC) and compares selected vs full models.
- `05_model_selection.pdf`  
  Output report from model selection results.

### Documentation
- `Analysis_plan.docx`  
  Study-style analysis plan describing objectives, variables, and modeling strategy.
- `Data_Dictionary.docx`  
  Variable-level definitions, coding, and derivation notes.



**Data Description**

This analysis uses a de-identified, simulated epidemiologic dataset derived from multiple source tables representing:

* **Demographics:** age, sex, education, smoking exposure
* **Laboratory measures:** plasma homocysteine, folate, vitamin B12, vitamin B6
* **Neurocognitive outcomes:** MMSE score, Alzheimer’s disease status

Datasets were merged using subject-level identifiers via PROC SQL, followed by data cleaning, exclusion flagging, and derivation of analysis-ready variables.

**Statistical Programming Workflow**

Key programming and analytical steps included:

* **Data Preparation**

- Multi-dataset integration using PROC SQL
- Creation of exclusion flags for missing outcomes
- Derivation of categorical and continuous covariates

* **Variable Derivation**

- Log-transformation of skewed biomarkers (log homocysteine)
- Education-adjusted cognitive impairment flag
- Age modeled as continuous, categorical, and piecewise variables

* **Modeling and Inference**

- Descriptive statistics and visualization
- Simple and multivariable linear regression
- Interaction testing for effect modification by sex
- Confounding assessment via comparison of crude and adjusted estimates
- Regression diagnostics (influence, leverage, multicollinearity)

* **Model Selection**

- Variable selection using PROC GLMSELECT with LASSO and SBC
- Comparison of selected models with full regression models

**Key Findings**

* Plasma homocysteine was significantly associated with MMSE in unadjusted analyses
* After adjustment, the association was substantially attenuated, indicating confounding
* Age and education were the strongest predictors of cognitive function
* No evidence of effect modification by sex was observed
* LASSO-based selection produced results consistent with traditional regression

**Interpretation**

While higher homocysteine levels were associated with poorer cognitive function in crude analyses, this relationship was largely explained by demographic factors, particularly age and educational attainment. These findings highlight the importance of confounding assessment and careful model specification when evaluating potential biomarkers in observational studies.

**Tools & Skills Demonstrated**

* SAS 9.4 (Base SAS Certified)
* PROC SQL, REG, GLM, GLMSELECT
* Clinical-style data preparation and derivations
* Regression modeling and diagnostics
* Reproducible and modular programming practices
