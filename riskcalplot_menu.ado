*! riskcalplot_menu version 1.0.0

program define riskcalplot_menu
    version 16.0

    syntax , INSTALL

    **Locate the personal ado directory
    local personal "`c(sysdir_personal)'"
    local profile "`personal'profile.do"

    **Create profile.do if it does not exist
    capture confirm file "`profile'"

    if _rc {

        file open fh using "`profile'", ///
            write text replace
    }

    else {

        file open fh using "`profile'", ///
            write text append
    }

    **Add riskcalplot to User > Graphics
    file write fh _n ///
        `"capture window menu append item "stUserGraphics" "Risk calibration plot (riskcalplot)" "db riskcalplot""' _n

    file write fh ///
        `"window menu refresh"' _n

    file close fh

    **Add the menu immediately in the current Stata session
    capture window menu append item "stUserGraphics" ///
        "Risk calibration plot (riskcalplot)" ///
        "db riskcalplot"

    window menu refresh

    display as text ///
        "riskcalplot has been added to User > Graphics"

end