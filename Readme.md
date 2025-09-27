# NHANES Rheumatoid Arthritis Causal Analysis

## Overview
Causal inference analysis examining modifiable risk factors for rheumatoid arthritis using NHANES 2009-2010 data. Compares traditional epidemiological associations with causal effect estimates using Targeted Maximum Likelihood Estimation (TMLE).

## Key Findings
- **Smoking**: Strong causal effect (ATE = +9.8 percentage points RA risk, p<0.001)
- **Vitamin D deficiency**: No significant causal association (ATE = +1.5 percentage points, p=0.30)
- **Biomarker clustering**: Identified high-inflammation phenotype with 44% RA prevalence

## Methods
- **Population**: 3,487 US adults ≥20 years from NHANES 2009-2010
- **Exposures**: Current smoking, vitamin D deficiency (<50 nmol/L)
- **Outcome**: Doctor-diagnosed rheumatoid arthritis
- **Analysis**: Survey-weighted logistic regression, TMLE for causal inference, k-means clustering

## Data Sources
- Demographics (DEMO_F.xpt)
- Medical conditions (MCQ_F.xpt) 
- Vitamin D levels (VID_F.xpt)
- Smoking history (SMQ_F.xpt)
- C-reactive protein (CRP_F.xpt)

## Repository Structure
```
├── data/                    # Raw NHANES XPT files
├── clean.r                  # Data processing pipeline
├── stat.r                   # Traditional statistical analysis
├── tmle_fast.r             # Causal inference with TMLE
├── forest_plot.r           # Visualization comparing methods
├── biomarker.r             # Inflammatory phenotype clustering
├── cleaned_nhanes_f.csv    # Analysis-ready dataset
└── outputs/                # Results and visualizations
```

## Clinical Implications
Results support smoking cessation as a primary RA prevention strategy. Vitamin D supplementation shows no causal benefit for RA prevention, despite observational associations in some studies.

## Technical Notes
- Survey weights applied for population representativeness
- TMLE provides double-robust causal estimates
- Complete case analysis (missing data <5% for key variables)
- Reproducible with `set.seed(123)`

## Future Extensions
- Multi-cycle analysis (2009-2018) for increased power
- Gene-environment interactions with HLA-DRB1
- Longitudinal analysis with incident RA cases
