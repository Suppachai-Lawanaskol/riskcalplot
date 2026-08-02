{smcl}
{* *! version 1.0.0 02aug2026}{...}
{vieweralsosee "[R] logistic" "help logistic"}{...}
{vieweralsosee "[R] glm" "help glm"}{...}
{vieweralsosee "[G-2] graph twoway" "help twoway"}{...}

{title:Title}

{phang}
{bf:riskcalplot} {hline 2} Plot observed and model-predicted risks across values of a discrete clinical score


{title:Syntax}

{p 8 17 2}
{cmd:riskcalplot}
{it:endpoint score}
{ifin}
{cmd:,}
{opt model(model)}
[{opt marker(marker_symbol)}
{it:twoway_options}]


{pstd}
where {it:endpoint} is a binary endpoint coded 0 and 1, and {it:score}
is a numeric discrete clinical score.

{pstd}
{it:model} may be

{p 12 16 2}
{cmd:logit} for a logistic regression model

{p 12 16 2}
{cmd:log} for a binomial generalized linear model with a log link


{title:Description}

{pstd}
{cmd:riskcalplot} displays observed and model-predicted risks across the
values of a discrete clinical prediction score.

{pstd}
The observed risk at each score value is calculated as the proportion of
participants with the endpoint among participants having that score value.
The fitted curve is obtained by regressing the binary endpoint on the score
as a continuous predictor.

{pstd}
When {cmd:model(logit)} is specified, predicted probabilities are obtained
from a logistic regression model.

{pstd}
When {cmd:model(log)} is specified, predicted risks are obtained from a
binomial generalized linear model with a log link. Predicted values greater
than 1 are truncated to 1 for plotting.

{pstd}
Marker size represents the number of observations at each score value.
Larger markers therefore indicate score categories supported by more data.

{pstd}
The command is intended primarily for descriptive assessment of agreement
between observed risk and the risk implied by a score-based regression model.
It is not a substitute for individual-level calibration assessment using
calibration-in-the-large, calibration slope, flexible calibration curves, or
other formal measures of model performance.


{title:Options}

{phang}
{opt model(model)} specifies the regression model used to estimate the
fitted risk curve. This option is required.

{pmore}
{cmd:model(logit)} fits

{p 16 20 2}
logit Pr(endpoint = 1) = beta0 + beta1(score)

{pmore}
and plots the corresponding predicted probabilities.

{pmore}
{cmd:model(log)} fits

{p 16 20 2}
log Pr(endpoint = 1) = beta0 + beta1(score)

{pmore}
using a binomial family and log link. Predicted risks greater than 1 are
set to 1 for graphical display.

{phang}
{opt marker(marker_symbol)} specifies the marker symbol used for observed
risks. The default is {cmd:smcircle_hollow}. See
{help marker_options:marker options} for available marker symbols.

{phang}
{it:twoway_options} are any options allowed by {help twoway}, including
{cmd:title()}, {cmd:subtitle()}, {cmd:xtitle()}, {cmd:ytitle()},
{cmd:xlabel()}, {cmd:ylabel()}, {cmd:legend()}, {cmd:scheme()},
{cmd:graphregion()}, and {cmd:name()}.


{title:Remarks}

{pstd}
The score is entered into the regression model as a linear continuous
predictor. Consequently, the fitted curve assumes that the log odds are
linear in the score under {cmd:model(logit)}, or that the log risk is linear
in the score under {cmd:model(log)}.

{pstd}
A visually smooth fitted line does not establish adequate calibration.
Apparent discrepancies at score values with small sample sizes may reflect
sampling variability rather than systematic miscalibration.

{pstd}
The binomial log-link model may fail to converge because predicted risks are
constrained to the interval from 0 to 1. Even when convergence is achieved,
truncating fitted values greater than 1 is only a plotting convention and
does not correct an incompatible model specification.

{pstd}
Observations with missing values in either the endpoint or score are excluded.

{title:Examples}

{pstd}
Plot observed and logistic-model-predicted risk:

{phang2}
{stata riskcalplot macrosomia macroscore, model(logit)}

{pstd}
Create a rounded version of the macrosomia score:

{phang2}
{stata "capture drop macroscore_rounded":capture drop macroscore_rounded}

{phang2}
{stata "generate macroscore_rounded = round(macroscore)":generate macroscore_rounded = round(macroscore)}

{pstd}
Compare the original and rounded macrosomia scores:

{phang2}
{stata riskcalplot macrosomia macroscore macroscore_rounded, model(logit logit)}

{pstd}
Add axis titles and format the probability axis:

{phang2}
{stata riskcalplot macrosomia macroscore, model(logit) xtitle("Macrosomia score") ytitle("Probability of macrosomia") ylabel(0(.10)1, format(%3.2f))}

{pstd}
Change the observed-risk marker and legend:

{phang2}
{stata riskcalplot macrosomia macroscore, model(logit) marker(circle_hollow) legend(order(1 "Model-predicted risk" 2 "Observed risk"))}

{pstd}
Fit a binomial model with a log link:

{phang2}
{stata riskcalplot macrosomia macroscore, model(log)}

{title:Stored results}

{pstd}
{cmd:riskcalplot} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{synopt:{cmd:r(models)}}specified model or models{p_end}
{synopt:{cmd:r(scores)}}specified score variables{p_end}
{synopt:{cmd:r(endpoint)}}binary endpoint variable{p_end}
{synopt:{cmd:r(stats)}}matrix of performance statistics{p_end}


{title:Requirements}

{pstd}
Stata 16.0 or later is required.


{title:Author}

{pstd}
Suppachai Lawanaskol, MD

{pstd}
Chaiprakarn Hospital, Chiang Mai, Thailand

{pstd}
Jayanton Patumanond, MD, DSc

{pstd}
Clinical Epidemiology Unit, Faculty of Medicine, Naresuan University,
Phitsanulok, Thailand


{title:Suggested citation}

{pstd}
Lawanaskol S, Patumanond J. {it:riskcalplot}: Stata module for plotting
observed and model-predicted risks across values of discrete clinical scores.
Version 1.2.1, 2026.

{title:Also see}

{psee}
Manual:  {manlink R logistic}, {manlink R glm},
         {manlink G-2 graph twoway}

{psee}
Online:  {help logistic}, {help glm}, {help predict},
         {help twoway}, {help marker_options}
