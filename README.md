# riskcalplot

`riskcalplot` is a Stata command for plotting observed and model-predicted
risks across one to five discrete clinical scores.

The command supports logistic and binomial log-link models and reports
apparent model performance statistics, including E:O, calibration-in-the-large,
calibration slope, scaled Brier R-squared, RMSE, and AUROC.

## Requirements

Stata 16.0 or later

## Installation

Install the current version directly from GitHub:

```stata
net install riskcalplot, ///
    from("https://raw.githubusercontent.com/Suppachai-Lawanaskol/riskcalplot/main/") ///
    replace
```

After installation:

```stata
help riskcalplot
```

## Basic syntax

```stata
riskcalplot endpoint score1 [score2 ... score5], ///
    model(model_list)
```

## Example

```stata
riskcalplot macrosomia macroscore, ///
    model(logit)
```

Compare the original and rounded scores:

```stata
generate macroscore_rounded = round(macroscore)

riskcalplot macrosomia macroscore macroscore_rounded, ///
    model(logit logit)
```

## Authors

Suppachai Lawanaskol, MD  
Chaiprakarn Hospital, Chiang Mai, Thailand

Jayanton Patumanond, MD, DSc  
Clinical Epidemiology Unit, Faculty of Medicine, Naresuan University,  
Phitsanulok, Thailand

## Suggested citation

Lawanaskol S, Patumanond J. *riskcalplot*: Stata module for plotting observed
and model-predicted risks across values of discrete clinical scores.
Version 1.0.0, 2026.