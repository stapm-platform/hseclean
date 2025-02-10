#' Read the National Survey for Wales 2016-17 \lifecycle{maturing}
#'
#' Reads and does basic cleaning on the National Survey for Wales 2016-17.
#'
#' @template read-data-description
#'
#' @template read-data-args
#'
#' @importFrom data.table :=
#'
#' @return Returns a data table.
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#'
#' }
read_NSW_2016_17 <- function(
    root = c("X:/", "/Volumes/Shared/")[1],
    file = "HAR_PR/PR/Consumption_TA/HSE/National Survey for Wales (NSW)/NSW 2017/UKDA-8301-tab/tab/national_survey_for_wales_2016-17_respondent_data_anonymised_ukds.tab"
    ) {

    data <- data.table::fread(
      paste0(root, file),
      na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-8", "-9", "-90", "-90.0", "-99", "N/A"))

    data.table::setnames(data, names(data), tolower(names(data)))

    alc_vars <- Hmisc::Cs(
      #### alc_drink_now_allages
      dnfreq, dnnow, dnocc, dnev,
      #### alc_sevenday_adult (heaviest day)

      #### alc_weekmean_adult
      # normal strength beer
      dnoftbr,                                         # how often in last 12 months
      dnubrmeas1, dnubrmeas2, dnubrmeas3, dnubrmeas4,  # measure drank
      dnubrhalf, dnubrsmc, dnubrlgc, dnubrbot,         # amount of measure drank
      # strong beer
      dnoftstbr,
      dnustbrmeas1, dnustbrmeas2, dnustbrmeas3, dnustbrmeas4,
      dnustbrhalf, dnustbrsmc, dnustbrlgc, dnustbrbot,
      # spirits
      dnoftspir,                                       # how often in last 12 months
      dnuspir,                                         # how many units
      # sherry/fortified wine
      dnoftsher,
      dnusher,
      # wine
      dnoftwine,                                 # how often in last 12 months
      dnuwinemeas,                               # measure drank (main size of wine glass)
      dnuwine,                                   # amount of measure drank
      # RTDs
      dnoftapop,                                  # how often in last 12 months
      dnapopmeas1, dnapopmeas2, dnapopmeas3,   # measure drank
      dnuapopsmc, dnuapopstbot, dnuapoplgbot,     # amount of measure drank

      #### alc_sevenday_adult (for binge)
      dn7dn, dnsame, dn7dmost,
      dntype1, dntype2, dntype3, dntype4, dntype5, dntype6,

      # normal strength beer
      dnbrhalf, dnbrsmc, dnbrlgc, dnbrbot,
      # strong beer
      dnstbrhalf, dnstbrsmc, dnstbrlgc, dnstbrbot,
      # wine
      dnwinebot, dnwinelgg, dnwinestg, dnwinesmg,
      # sherry
      dnsher,
      # spirits
      dnspir,
      # RTDs
      dnaplgbot, dnapstbot, dnapsmc,

      # derived weekly units variable
      dvunitswk0
    )

    # smk_vars <- tolower(Hmisc::Cs(Smoke, SmQuitTry, SmQuitWant, SmQuitTm, SmAge, EcigEv, EcigNow, EcigOft, EcigAge,
    #                               SmEcigFirst, EcigReas1, EcigReas2, EcigReas3, EcigReas4, EcigReas5, EcigReas6, EcigReas7,
    #                               EcigReas8, EcigReasOth, EcigReasDK, EcigReasRef, EcigReasOT_E, EcigReasOT_W,
    #                               SmExp1, SmExp2, SmExp3, SmExp4, SmExp5, SmExp6, SmExp7, SmExp8, SmExp9, SmExpDK,
    #                               SmExpRef, EcigSee1, EcigSee2, EcigSee3, EcigSee4, EcigSee5, EcigSee6, EcigSee7, EcigSee8,
    #                               EcigSee9, EcigSee10, EcigSee11, EcigSee12, EcigSee13, EcigSeeDK, EcigSeeRef,
    #                               Dvsmokec, Dvsmokstat, Dvtrygupbi, Dvlikgupbi,
    #                               Dvstpsmk1m, Dvstpsmk1y, Dvecigevbi, Dvecignbi, Dvdualfirst,
    #                               Dvexouall, Dvexounsm, Dvexinall, Dvexinnsm, Dvexpoall,
    #                               Dvexponsm, Dvexecouall, Dvexecounsm, Dvexecinall, Dvexecinnsm,
    #                               Dvexecall, Dvexecnsm))

    smk_vars <- tolower(Hmisc::Cs(Smoke, SmAge, Dvsmokec, Dvsmokstat, SmQuitTm))
    # SmAge only measured in some years

    # key smoking variables are
#     Smoke	Smoking - Which one of these best describes you	-99	Refused
#     -98	Interview terminated early
#     -88	Not selected in sub-sample
#     -9	Don't Know (SPONTANEOUS ONLY)
# 		-8	Question not asked due to routing
# 		1	I smoke daily
# 		2	I smoke occasionally but not every day
# 		3	I used to smoke daily but do not smoke at all now
# 		4	I used to smoke occasionally but do not smoke at all now
# 		5	I have never smoked

#     SmAge	Smoking - How old were you when you started smoking?	-99	Refused
#     -98	Interview terminated early
#     -88	Not selected in sub-sample
#     -9	Don't Know (SPONTANEOUS ONLY)
# 		-8	Question not asked due to routing

#     Dvsmokec	Derived variable - Currently smoke either daily or occasionally	-99	Refused
#     -98	Interview terminated early
#     -88	Not selected in sub-sample
#     -9	Don't Know (SPONTANEOUS ONLY)
# 		-8	Question not asked due to routing
# 		0	No
# 		1	Yes
#
# Dvsmokstat	Derived variable - Smoking status	-99	Refused
# 		-98	Interview terminated early
# 		-88	Not selected in sub-sample
# 		-9	Don't Know (SPONTANEOUS ONLY)
#     -8	Question not asked due to routing
#     1	Smoker
#     2	Ex-smoker
#     3	Never smoked
#


    health_vars <- Hmisc::Cs(dvillchap1, dvillchap2, dvillchap3, dvillchap4, dvillchap5,
                             dvillchap6, dvillchap7, dvillchap8, dvillchap9, dvillchap10,
                             dvillchap11, dvillchap12, dvillchap13, dvillchap14, dvillchap15)

    other_vars <- Hmisc::Cs(
      dvla, dvfirereg,
      #psu,
      #strata, # stratification unit
      sampleadultweight,

      #
      #incresp,

      # Education
      #educend,
      educat, # Highest educational qualification - revised 2008

      # Occupation
      #nssec3, nssec8,
      econstat,

      # Family
      marstat,

      # demographic
      age,
      dvethnicity,
      dvwimdovr5, dvwimdinc5,

      gender

    )

    names <- c(other_vars, health_vars, alc_vars, smk_vars)

    names <- tolower(names)

    data <- data[ , names, with = F]


    data.table::setnames(data,

                         c("dvfirereg", "dvwimdovr5","dvethnicity","gender",

                           ##### alcohol weekly consumption vars
                           "dnfreq","dnev","dnocc",

                           # frequency of drink type over 12 months
                           "dnoftbr","dnoftstbr","dnoftspir","dnoftsher","dnoftwine","dnoftapop",
                           # normal strength beer
                           "dnubrmeas1", "dnubrmeas2", "dnubrmeas3", "dnubrmeas4",
                           "dnubrhalf", "dnubrsmc", "dnubrlgc", "dnubrbot",
                           # strong beer
                           "dnustbrmeas1", "dnustbrmeas2", "dnustbrmeas3", "dnustbrmeas4",
                           "dnustbrhalf", "dnustbrsmc", "dnustbrlgc", "dnustbrbot",
                           # wine
                           "dnuwinemeas", "dnuwine",
                           # sherry
                           "dnusher",
                           # spirits
                           "dnuspir",
                           # RTDs
                           "dnapopmeas1", "dnapopmeas2", "dnapopmeas3",
                           "dnuapopsmc", "dnuapopstbot", "dnuapoplgbot",

                           ##### alcohol binge vars
                           "dn7dn", "dnsame", "dn7dmost",
                           "dntype1", "dntype2", "dntype3", "dntype4", "dntype5", "dntype6",

                           # normal strength beer
                           "dnbrhalf", "dnbrsmc", "dnbrlgc", "dnbrbot",
                           # strong beer
                           "dnstbrhalf", "dnstbrsmc", "dnstbrlgc", "dnstbrbot",
                           # wine
                           "dnwinebot", "dnwinelgg", "dnwinestg", "dnwinesmg",
                           # sherry
                           "dnsher",
                           # spirits
                           "dnspir",
                           # RTDs
                           "dnaplgbot", "dnapstbot", "dnapsmc",

                           #### derived variable for weekly units
                           "dvunitswk0",


                           ## health vars
                           "dvillchap1", "dvillchap2", "dvillchap3", "dvillchap4", "dvillchap5",
                           "dvillchap6", "dvillchap7", "dvillchap8", "dvillchap9", "dvillchap10",
                           "dvillchap11", "dvillchap12", "dvillchap13", "dvillchap14", "dvillchap15"),

                         c("region", "wimd","dvethnicity","sex",

                           ##### alcohol weekly consumption vars
                           "dnoft","dnevr","dnany",

                           # frequency of drink type over 12 months
                           "nbeer","sbeer","spirits","sherry","wine","pops",
                           # normal strength beer
                           "nbeerm1", "nbeerm2", "nbeerm3", "nbeerm4",
                           "nbeerq1", "nbeerq2", "nbeerq3", "nbeerq4",
                           # strong beer
                           "sbeerm1", "sbeerm2", "sbeerm3", "sbeerm4",
                           "sbeerq1", "sbeerq2", "sbeerq3", "sbeerq4",
                           # wine
                           "bwineq2", "wineq",
                           # sherry
                           "sherryq",
                           # spirits
                           "spiritsq",
                           # RTDs
                           "popsly11", "popsly12", "popsly13",
                           "popsq111", "popsq112", "popsq113",

                           ##### alcohol binge vars
                           "d7many", "drnksame", "whichday",
                           "d7typ1", "d7typ2", "d7typ3", "d7typ4", "d7typ5", "d7typ6",

                           # normal strength beer
                           "nberqhp7", "nberqsm7", "nberqlg7", "nberqbt7",
                           # strong beer
                           "sberqhp7", "sberqsm7", "sberqlg7", "sberqbt7",
                           # wine
                           "wbtlgz", "wgls250ml", "wgls175ml", "wgls125ml",
                           # sherry
                           "sherqgs7",
                           # spirits
                           "spirqme7",
                           # RTDs
                           "popsqlg7", "popsqstb7", "popsqsm7",

                           #### derived variable for weekly units
                           "dv_wk_units",

                           ## health vars
                           "compm1", "compm2", "compm3", "compm4", "compm5",
                           "compm6", "compm7", "compm8", "compm9", "compm10",
                           "compm11", "compm12", "compm13", "compm14", "compm15")
    )


    # Tidy survey weights and only keep the sub-sample that answered smoking
    # and drinking related questions (in 2016/17 this is all respondents, but
    # only a subsample in future years)
    data[ , wt_int := sampleadultweight]
    data <- data[!is.na(sampleadultweight), ]
    #data[age < 16, wt_int := NA]

    # Set PSU and cluster
    #data[ , psu := paste0("2016_", 1)]
    data[ , cluster := paste0("2016_", dvla)]

    data[ , year := 2016]
    data[ , country := "Wales"]

    return(data[])
}
