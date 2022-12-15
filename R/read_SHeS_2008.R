
#' Read Scottish Health Survey 2008
#'
#' Reads and does basic cleaning on the Scottish Health Survey 2008.
#'
#' The Scottish Health Survey is designed to yield a representative sample of the general population
#' living in private households in Scotland every year. An initial sample of 9,906 addresses were selected, comprising of
#' three sample types:
#' \itemize{
#' \item 6,945 formed the main sample, at which adults and children were eligible;
#' \item 2,301 addresses formed an additional child boost sample at which only households containing children ages 0-15 were eligible;
#' \item 660 addresses formed the Health Board boost sample, at which only only adults were eligible to interview.
#' }
#'
#' Note: Optional NHS Health Board boost - NHS Health Boards were given the option to boost their samples beyond the levels which is funded centrally.
#' In 2008, Fife Borders and Grampian Health Boards chose to boost the number of adults interviewed. These cases have been included in the main 2008 file,
#' and their additional selection probability has been adjusted for in the weighting scheme.
#'
#' MISSING VALUES
#'
#' \itemize{
#' \item -1 Not applicable: Used to signify that a particular variable did not apply to a given respondent
#' usually because of internal routing. For example, men in women only questions.
#' \item -2 Schedule not applicable: Used mainly for variables on the self-completions when the
#' respondent was not of the given age range, also used for children without legal guardians in the
#' home who could not participate in the nurse schedule.
#' \item -6 Schedule not obtained: Used to signify that a particular variable was not answered because the
#' respondent did not complete or agree to a particular schedule (i.e. nurse schedule or selfcompletions).
#' \item -8 Don't know, Can't say.
#' \item -9 No answer/ Refused
#' }
#'
#' @param root Character - the root directory.
#' @param file Character - the file path and name.
#' @importFrom data.table :=
#' @return Returns a data table. Note that:
#'
#' \itemize{
#' \item Missing data ("NA", "", "-1", "-2", "-6", "-7", "-9", "-90", "-90.0", "N/A") is replace with NA,
#' -8 ("don't know") is also replaced with NA.
#' \item All variable names are converted to lower case.
#' \item Each data point is assigned a weight of 1 as there is no weight variable supplied.
#' \item A single sampling cluster is assigned.
#' \item The probabilistic sampling unit have the year appended to them.
#' }
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data_2008 <- read_SHeS_2008("X:/",
#' "ScHARR/PR_Tobacco_mup/Data/Scottish Health Survey/SHeS 2008/UKDA-6383-tab/tab/shes08i_v11.tab")
#'
#' }
#'
read_SHeS_2008 <- function(
  root = "X:/ScHARR/PR_Consumption_TA/HSE/Scottish Health Survey (SHeS)/",
  file = "SHeS 2008/UKDA-6383-tab/tab/shes08i_v11.tab"
) {

  data <- data.table::fread(
    paste0(root[1], file),
    na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-8", "-9", "-90", "-90.0", "N/A")
  )

  data.table::setnames(data, names(data), tolower(names(data)))

  alc_vars <- Hmisc::Cs(
    # alc_drink_now_allages
    dnoft, dnnow, dnany, dnevr,
    # alc_sevenday_adult (heaviest day)
    d7day, d7many,
    nberqhp7, l7ncodeq, nberqlg, nberqsm, nberqbt7,
    sberqhp7, l7scodeq, sberqlg, sberqsm, sberqbt7,
    w250gl7, w175gl7, w125gl7, w125bl7,
    d7typ1, d7typ2, d7typ3, d7typ4, d7typ5, d7typ6,
    sherqgs7, spirqme7,
    popscl7, popsbl7, poplbl7,
    drnksame, whichday,
    # alc_weekmean_adult
    nbeer, sbeer, spirits, sherry, wine, pops03,
    nbeerm1, nbeerm2, nbeerm3, nbeerm4,
    nbeerq1, nbeerq2, nbeerq3, nberqbt,
    sbeerm1, sbeerm2, sbeerm3, sbeerm4,
    sbeerq1, sbeerq2, sbeerq3, sberqbt,
    wqglz1, wqglz2, wqglz3, q250glz, q175glz, q125glz, wqbt, wineq,
    sherryq, spiritsq,
    popsm031, popsm032, popsm033, popsq031, popsq032, popsq033,

    # to compare SHeS calcs with our estimates of weekly units
    nberwu, sberwu, spirwu, sherwu, winewu, popswu, drating,

    #self-completed amount
    dwin08q0, dwin08q2, dwin08q3, dwin08q4, dshryq08, dspiritq,
    dsbeerq0, dsbeerq2, dsbeerq3, dnbeerq0, dnbeerq2, dnbeerq3,
    dpop08q0, dpop08q2, dpop08q3,

    #self-completed frequency
    dpops08, dwine08, dshery08, dspirits, dsbeer, dnbeer

    #wineq, wqbt, wqgl, nberf, nberqhp, sberqhp, sberf, spirf, spirqme, sherf, sherqgs, winef,
    #win250g, win175g, win125g, win125b, popsf, popsqlb, popsqsb, popsqsc, nberqsm7, nberqlg7,
    #sberqsm7, sberqlg7
  )

  smk_vars <- tolower(Hmisc::Cs(SmokEver, SmokeNow, DlySmoke, DlyEst, DlyG, DlyOz, WkndSmok, WkndEst,
                                WkndG, WkndOz, SmokeReg, NumSmok, NumEst, NumG, NumOz, SmokYrs, EndSmoke,
                                LongEnd, StartSmk, cignow, smkevr, cigevr, cigregs, cigwday, cigwend, cigdyal,
                                cigst3, DSmokCig, DCigAge, DSmokNow, DSmokReg, DDlySmok, DWkndSmo))

  health_vars <- paste0("compm", 1:14)

  other_vars <- Hmisc::Cs(

    psu,
    strata, # stratification unit
    int08wt, # individual weight after calibration
    cint08wt, # Child weight after calibration

    eqv5, eqvinc,

    # Education
    educend,
    hedqul08, # Highest educational qualification - revised 2008

    # Occupation
    nssec3, nssec8,
    nactiv, econac08,

    # Family
    maritalg,

    # demographic
    age,
    ethnici,
    simd5_sg, simd5_rp,
    sex,

    # how much they weigh
    htval, wtval

  )


  names <- c(other_vars, health_vars, alc_vars, smk_vars)

  names <- tolower(names)

  data <- data[ , names, with = F]

  data.table::setnames(data,

           c("simd5_rp", "strata", "ethnici", "eqv5", "eqvinc", "econac08",
             "cigregs",
             "w250gl7", "w175gl7", "w125gl7", "w125bl7",
             "popscl7", "popsbl7", "poplbl7",
             "l7scodeq", "sberqlg", "sberqsm",
             "l7ncodeq", "nberqlg", "nberqsm",

             # amount drunk on one day
             "nberqbt", "sberqbt",
             "pops03", "popsm031", "popsm032", "popsm033", "popsq031", "popsq032", "popsq033",

             #self-completed
             "dnbeerq0", "dnbeerq2", "dnbeerq3",
             "dsbeerq0", "dsbeerq2", "dsbeerq3",
             "dwin08q0", "dwin08q2", "dwin08q3", "dwin08q4", "dshryq08", "dspiritq",
             "dpop08q0", "dpop08q2", "dpop08q3",
             #self-completed frequency
             "dpops08", "dwine08", "dshery08", "dspirits", "dsbeer", "dnbeer"
             ),

           c("simd", "cluster", "ethnicity_raw", "eqv5_15", "eqvinc_15", "econac12",
             "cigreg",
             "wgls250ml", "wgls175ml", "wgls125ml", "wbtlgz",
             "popsqsmc7", "popsqsm7", "popsqlg7",
             "sberqpt7", "sberqlg7", "sberqsm7",
             "nberqpt7", "nberqlg7", "nberqsm7",

             # amount drunk on one day
             "nbeerq4", "sbeerq4",
             "pops", "popsly11", "popsly12", "popsly13", "popsq111", "popsq112", "popsq113",

             #self-completed
             "scnbeeq1", "scnbeeq3", "scnbeeq2",
             "scsbeeq1", "scsbeeq3", "scsbeeq2",
             "scwineq3", "scwineq2", "scwineq1", "scwineq4", "scsherrq", "scspirq",
             "scpopsq3", "scpopsq2", "scpopsq1",
             #self-completed frequency
             "scpops", "scwine", "scsherry", "scspirit", "scsbeer", "scnbeer"
             ))

  # Tidy survey weights
  data[ , wt_int := int08wt]
  data[age < 16, wt_int := cint08wt]

  data[ , `:=` (int08wt = NULL, cint08wt = NULL)]

  # Set PSU and cluster
  data[ , psu := paste0("2008_", psu)]
  data[ , cluster := paste0("2008_", cluster)]

  data[ , year := 2008]
  data[ , country := "Scotland"]

  return(data[])
}





