program define riskcalplot, rclass
    version 16.0

    syntax varlist(min=2 max=6 numeric) [if] [in], ///
        MODEL(string asis)                         ///
        [                                          ///
            MARKER(string)                         ///
            NOSTAT                                 ///
            STATOPTS(string asis)                  ///
            PLOT1OPTS(string asis)                 ///
            PLOT2OPTS(string asis)                 ///
            PLOT3OPTS(string asis)                 ///
            PLOT4OPTS(string asis)                 ///
            PLOT5OPTS(string asis)                 ///
            SCATTER1OPTS(string asis)              ///
            SCATTER2OPTS(string asis)              ///
            SCATTER3OPTS(string asis)              ///
            SCATTER4OPTS(string asis)              ///
            SCATTER5OPTS(string asis)              ///
            *                                      ///
        ]

    marksample touse
	
**Set the default hollow markers**
local defaultmarker1 Oh
local defaultmarker2 Dh
local defaultmarker3 Th
local defaultmarker4 Sh
local defaultmarker5 X


    **Coin the endpoint and scores**
    gettoken y scores : varlist

    local nscore : word count `scores'

    **Coin the model list**
    local models = lower(strtrim("`model'"))

    local nmodel : word count `models'

    **Use the same model for all scores if only one model was specified**
    if `nmodel' == 1 {

        local onemodel : word 1 of `models'

        local models

        forvalues j = 1/`nscore' {
            local models `models' `onemodel'
        }
    }

    **Check the number of models**
    else if `nmodel' != `nscore' {

        display as error ///
            "The number of models must be one or equal to the number of scores"

        display as error ///
            "Number of scores: `nscore'"

        display as error ///
            "Number of models: `nmodel'"

        exit 198
    }

    **Check the binary endpoint**
    quietly count if `touse' & !inlist(`y', 0, 1)

    if r(N) > 0 {

        display as error ///
            "The endpoint `y' must be coded 0 and 1"

        exit 459
    }

    **Check the variation of the endpoint**
    quietly summarize `y' if `touse', meanonly

    if r(N) == 0 {

        display as error ///
            "No observations are available for analysis"

        exit 2000
    }

    if r(min) == r(max) {

        display as error ///
            "The endpoint must contain both 0 and 1"

        exit 2000
    }

    **Fill the default marker**
    if "`marker'" == "" {
        local marker smcircle_hollow
    }

    display as text ///
        _column(5) "Endpoint" ///
        _column(20) "`y'"

    display as text ///
        _column(5) "Scores" ///
        _column(20) "`scores'"

    display as text ///
        _column(5) "Models" ///
        _column(20) "`models'"

    **Create the statistics matrix**
    tempname statistics

    matrix `statistics' = J(`nscore', 6, .)

    matrix colnames `statistics' = ///
        E_O ///
        CITL ///
        Cal_slope ///
        R2_Brier ///
        RMSE ///
        AUROC

    local rownames
    local plots
    local legorder
    local statlines
    local i = 0

    foreach score of local scores {

        local ++i

		**Call the default marker for each score**
		local markeri `defaultmarker`i''
		
        **Call the model for each score**
        local modeli : word `i' of `models'

        **Check the model type**
        if !inlist("`modeli'", "logit", "log") {

            display as error ///
                "Invalid model for score `score': `modeli'"

            display as error ///
                "The available models are logit and log"

            exit 198
        }

        display as text ///
            _newline "Score `i': `score'"

        display as text ///
            "Model `i': `modeli'"

        local rownames `rownames' `score'

        tempvar pred
        tempvar obsrisk
        tempvar size
        tempvar tag
        tempvar sqerror
        tempvar pclip
        tempvar linear_predictor

        **Generate the observed risk by score**
        quietly egen double `obsrisk' = ///
            mean(`y') if `touse', ///
            by(`score')

        **Generate the number of observations by score**
        quietly egen long `size' = ///
            count(`y') if `touse', ///
            by(`score')

        **Select one observation from each score value**
        quietly egen byte `tag' = ///
            tag(`score') if `touse'

        **Fit the logistic model**
        if "`modeli'" == "logit" {

            capture quietly logistic ///
                `y' c.`score' if `touse'

            local modelrc = _rc

            if `modelrc' {

                display as error ///
                    "Logistic regression failed for score `score'"

                exit `modelrc'
            }

            quietly predict double `pred' ///
                if e(sample), pr
        }

        **Fit the log-binomial model**
        if "`modeli'" == "log" {

            capture quietly glm ///
                `y' c.`score' if `touse', ///
                family(binomial) ///
                link(log)

            local modelrc = _rc

            if `modelrc' {

                display as error ///
                    "The log-binomial model failed for score `score'"

                exit `modelrc'
            }

            quietly predict double `pred' ///
                if e(sample), mu

            **Confine the predicted risk between zero and one**
            quietly replace `pred' = 1 ///
                if `pred' > 1 & !missing(`pred')

            quietly replace `pred' = 0 ///
                if `pred' < 0 & !missing(`pred')
        }

        **Calculate the expected number of events**
        quietly summarize `pred' ///
            if `touse' & !missing(`pred'), ///
            meanonly

        local expected = r(sum)

        **Calculate the observed number of events**
        quietly summarize `y' ///
            if `touse' & !missing(`pred'), ///
            meanonly

        local observed = r(sum)
        local prevalence = r(mean)

        **Calculate the expected-to-observed ratio**
        local eo = .

        if `observed' > 0 {
            local eo = `expected' / `observed'
        }

        **Calculate the squared prediction error**
        quietly generate double `sqerror' = ///
            (`y' - `pred')^2 ///
            if `touse' & !missing(`pred')

        quietly summarize `sqerror', meanonly

        local brier = r(mean)

        **Calculate the root mean squared error**
        local rmse = sqrt(`brier')

        **Calculate the scaled Brier R-squared**
        local nullbrier = ///
            `prevalence' * (1 - `prevalence')

        local r2 = .

        if `nullbrier' > 0 {
            local r2 = ///
                1 - (`brier' / `nullbrier')
        }

        **Confine the predicted risk before logit transformation**
        quietly generate double `pclip' = ///
            min(max(`pred', 1e-8), 1 - 1e-8) ///
            if `touse' & !missing(`pred')

        **Generate the linear predictor**
        quietly generate double `linear_predictor' = ///
            ln(`pclip' / (1 - `pclip')) ///
            if !missing(`pclip')

        **Calculate the calibration-in-the-large**
        local citl = .

        capture quietly logit `y' ///
            if `touse' & !missing(`linear_predictor'), ///
            offset(`linear_predictor')

        if !_rc {
            local citl = _b[_cons]
        }

        **Calculate the calibration slope**
        local slope = .

        capture quietly logit ///
            `y' c.`linear_predictor' ///
            if `touse' & !missing(`linear_predictor')

        if !_rc {
            local slope = _b[`linear_predictor']
        }

        **Calculate the area under the receiver operating characteristic curve**
        local auc = .

        capture quietly roctab ///
            `y' `pred' ///
            if `touse' & !missing(`pred')

        if !_rc {
            local auc = r(area)
        }

        **Store the statistics**
        matrix `statistics'[`i', 1] = `eo'
        matrix `statistics'[`i', 2] = `citl'
        matrix `statistics'[`i', 3] = `slope'
        matrix `statistics'[`i', 4] = `r2'
        matrix `statistics'[`i', 5] = `rmse'
        matrix `statistics'[`i', 6] = `auc'

        **Call the options from the corresponding plot**
        local lineopts ///
            ``plot`i'opts''

        local scatteropts ///
            ``scatter`i'opts''

        **Add the fitted line and observed risks**
        local plots `plots'                              ///
            (line `pred' `score'                           ///
                if `tag' == 1,                             ///
                sort                                       ///
                pstyle(p`i')                               ///
                `lineopts')                                ///
            (scatter `obsrisk' `score'                     ///
                if `tag' == 1                              ///
                [fweight = `size'],                        ///
                pstyle(p`i')                               ///
                msymbol(`markeri')                          ///
                `scatteropts')

        **Add one legend entry for each score**
        local lineindex = 2 * `i' - 1

        local legorder ///
            `"`legorder' `lineindex' "`score'""'

        **Format the statistics**
        local seo = ///
            strtrim(string(`eo', "%6.3f"))

        local scitl = ///
            strtrim(string(`citl', "%6.3f"))

        local sslope = ///
            strtrim(string(`slope', "%6.3f"))

        local sr2 = ///
            strtrim(string(`r2', "%6.3f"))

        local srmse = ///
            strtrim(string(`rmse', "%6.3f"))

        local sauc = ///
            strtrim(string(`auc', "%6.3f"))

        **Add the statistics to the graph note**
        local statlines ///
            `"`statlines' "`score' (`modeli'): E:O=`seo'; CITL=`scitl'; slope=`sslope'; R2=`sr2'; RMSE=`srmse'; AUROC=`sauc'""'
    }

    **Name the rows of the statistics matrix**
    matrix rownames `statistics' = ///
        `rownames'

    **Display the statistics by default**
    local statgraph

    if "`nostat'" == "" {

        display as text ///
            _newline "Apparent performance statistics"

        matrix list `statistics', ///
            format(%9.3f)

        **Fill the default statistics options**
        if `"`statopts'"' == "" {
            local statopts ///
                "size(vsmall) justification(left)"
        }

        local statgraph ///
            `"note(`statlines', `statopts')"'
    }

    **Plot the risk calibration graph**
    twoway `plots', ///
        legend(order(`legorder')) ///
        `statgraph' ///
        `options'

    **Store the results**
    return matrix stats = `statistics'
    return local endpoint "`y'"
    return local scores "`scores'"
    return local models "`models'"

end