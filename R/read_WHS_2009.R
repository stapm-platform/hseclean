#' Read the Welsh Health Survey 2009 \lifecycle{maturing}
#'
#' Reads and does basic cleaning on the Welsh Health Survey 2009.
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
read_WHS_2009 <- function(
    root = c("X:/", "/Volumes/Shared/")[1],
    file = "HAR_PR/PR/Consumption_TA/HSE/Welsh Health Survey (WHS)/2009/UKDA-6589-tab/tab/welsh_health_09_adult2_archiving.tab"
    ) {

    data <- data.table::fread(
      paste0(root, file),
      na.strings = c("NA", "", "-1", "-2", "-6", "-7", "-8", "-9", "-90", "-90.0", "-99", "N/A"))

    data.table::setnames(data, names(data), tolower(names(data)))

    alc_vars <- Hmisc::Cs(
      #### alc_drink_now_allages
      nodrink, freqalc, freqalc3, everdr,
      # last 7 days
      alcdrink, alcdrbi, alcdrbi0,
      alcoday, #heaviest day

      # normal strength beer
      normpint, normlcan, normscan,                    # amount - pint / large cans&bottles / small cans&bottles
      npinuni, nlcauni, nscauni,                       # units (derived)
      # strong beer
      strpint, strlcan, strscan,
      spinuni, slcauni, sscauni,
      # wine
      winelar, winesta, winesma, winebot,              # amount - large glass, standard glass, small glass, bottles
      wluni, wstuni, wsmuni, wbuni,                    # units (derived)
      # spirits
      spirit,                                          # amount
      # sherry/fortified wine
      fwine,                                           # amount
      # RTDs
      alcopops,
      alcouni,

      ## other alcohlic drinks
      # (1)
      oth1gla, oth1pin, oth1lcan, oth1scan,
      # (2)
      oth2gla, oth2pin, oth2lcan, oth2scan,

      ## derived units on heaviest day
      units, units0,
      alc4,                        # Level of maximal daily alc cosumption
      alc5,                        # Maximum drank last week
      alcagbi,                     # Max daily consumption - above guidelines [binary]
      alcbibi                      # Max daily consumption - binge [binary]
    )
#
#     smk_vars <- tolower(Hmisc::Cs(smok, smokec, smoked, smokee, smokstat, smokex,
#                                   smouthom, smoutoth, smokout,
#                                   sminhome, sminoph, smincar, sminothe,
#                                   smokin, triedgup, trygupbi, compsm, likegup, likgupbi,
#                                   gupnum, guphlthp, guphtlhg, guprelil, gupfam, gupfin, gupchi, gupban, gupoth,
#                                   expouth, expoutot, expinh, expinhot, expincar, expinoth, exouall, exounam, exinall, exinnsm, expoall, exponsm,
#                                   ecigevbi, ecignbi, ecigesmo, ecigeex, ecigenev, ecigenon, ecignsmo, ecignex, ecignnev, ecignnon,
#                                   stpsmk, stpsmk1m, stpsmk1y))

    # smk_vars <- tolower(Hmisc::Cs(Smoke, SmAge, Dvsmokec, Dvsmokstat))
    smk_vars <- tolower(Hmisc::Cs(smok, smokec, smoked, smokee, smokstat, smokex))
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


    # health_vars <- Hmisc::Cs(dvillchap1, dvillchap2, dvillchap3, dvillchap4, dvillchap5,
    #                          dvillchap6, dvillchap7, dvillchap8, dvillchap9, dvillchap10,
    #                          dvillchap11, dvillchap12, dvillchap13, dvillchap14, dvillchap15)
    health_vars <- Hmisc::Cs(llti, lltibi,
                             llticd1, llticd2, llticd3, llticd4,
                             lltich1, lltich2, lltich3, lltich4)
    ### there's also a comprehensive set of binary variables and whether they have received treatment for it,
    ### as well as SF12 and SF36 scores

    other_vars <- Hmisc::Cs(

      #psu,
      #strata, # stratification unit
      # sampleadultweight,
      archhsn, archpsn,     ## scrambled household and person serials
      wt_hhold, wt_adult,   ## Household and Individual NR weight

      #
      #incresp,

      # Education
      #educend,
      qualhi, # Highest educational qualification - revised 2008 [derived]

      # Occupation
      # nssec8, nssec5, nssec3,
      work,       # work status
      employ,     # whether in employment
      ecstat3,    # econ status 3 class
      ecstat,     # econ status

      # # Family
      # marstat,

      # demographic
      age5yrm,    # derived 5 year age cat with 75+ merged
      region,
      # dvethnicity,
      # dvwimdovr5,
      sex)

    names <- c(other_vars, health_vars, alc_vars, smk_vars)

    names <- tolower(names)

    data <- data[ , names, with = F]


    # data.table::setnames(data,
    #
    #                      c(#"dvwimdovr5","dvethnicity","gender",
    #
    #                        ##### alcohol weekly consumption vars
    #                        "dnfreq","dnev","dnocc",
    #
    #                        # frequency of drink type over 12 months
    #                        "dnoftbr","dnoftstbr","dnoftspir","dnoftsher","dnoftwine","dnoftapop",
    #                        # normal strength beer
    #                        "dnubrmeas1", "dnubrmeas2", "dnubrmeas3", "dnubrmeas4",
    #                        "dnubrhalf", "dnubrsmc", "dnubrlgc", "dnubrbot",
    #                        # strong beer
    #                        "dnustbrmeas1", "dnustbrmeas2", "dnustbrmeas3", "dnustbrmeas4",
    #                        "dnustbrhalf", "dnustbrsmc", "dnustbrlgc", "dnustbrbot",
    #                        # wine
    #                        "dnuwinemeas", "dnuwine",
    #                        # sherry
    #                        "dnusher",
    #                        # spirits
    #                        "dnuspir",
    #                        # RTDs
    #                        "dnapopmeas1", "dnapopmeas2", "dnapopmeas3",
    #                        "dnuapopsmc", "dnuapopstbot", "dnuapoplgbot",
    #
    #                        ##### alcohol binge vars
    #                        "dn7dn", "dnsame", "dn7dmost",
    #                        "dntype1", "dntype2", "dntype3", "dntype4", "dntype5", "dntype6",
    #
    #                        # normal strength beer
    #                        "dnbrhalf", "dnbrsmc", "dnbrlgc", "dnbrbot",
    #                        # strong beer
    #                        "dnstbrhalf", "dnstbrsmc", "dnstbrlgc", "dnstbrbot",
    #                        # wine
    #                        "dnwinebot", "dnwinelgg", "dnwinestg", "dnwinesmg",
    #                        # sherry
    #                        "dnsher",
    #                        # spirits
    #                        "dnspir",
    #                        # RTDs
    #                        "dnaplgbot", "dnapstbot", "dnapsmc",
    #
    #                        #### derived variable for weekly units
    #                        "dvunitswk0",
    #
    #
    #                        ## health vars
    #                        "dvillchap1", "dvillchap2", "dvillchap3", "dvillchap4", "dvillchap5",
    #                        "dvillchap6", "dvillchap7", "dvillchap8", "dvillchap9", "dvillchap10",
    #                        "dvillchap11", "dvillchap12", "dvillchap13", "dvillchap14", "dvillchap15"),
    #
    #                      c(#"wimd","dvethnicity","sex",
    #
    #                        ##### alcohol weekly consumption vars
    #                        "dnoft","dnevr","dnany",
    #
    #                        # frequency of drink type over 12 months
    #                        "nbeer","sbeer","spirits","sherry","wine","pops",
    #                        # normal strength beer
    #                        "nbeerm1", "nbeerm2", "nbeerm3", "nbeerm4",
    #                        "nbeerq1", "nbeerq2", "nbeerq3", "nbeerq4",
    #                        # strong beer
    #                        "sbeerm1", "sbeerm2", "sbeerm3", "sbeerm4",
    #                        "sbeerq1", "sbeerq2", "sbeerq3", "sbeerq4",
    #                        # wine
    #                        "bwineq2", "wineq",
    #                        # sherry
    #                        "sherryq",
    #                        # spirits
    #                        "spiritsq",
    #                        # RTDs
    #                        "popsly11", "popsly12", "popsly13",
    #                        "popsq111", "popsq112", "popsq113",
    #
    #                        ##### alcohol binge vars
    #                        "d7many", "drnksame", "whichday",
    #                        "d7typ1", "d7typ2", "d7typ3", "d7typ4", "d7typ5", "d7typ6",
    #
    #                        # normal strength beer
    #                        "nberqhp7", "nberqsm7", "nberqlg7", "nberqbt7",
    #                        # strong beer
    #                        "sberqhp7", "sberqsm7", "sberqlg7", "sberqbt7",
    #                        # wine
    #                        "wbtlgz", "wgls250ml", "wgls175ml", "wgls125ml",
    #                        # sherry
    #                        "sherqgs7",
    #                        # spirits
    #                        "spirqme7",
    #                        # RTDs
    #                        "popsqlg7", "popsqstb7", "popsqsm7",
    #
    #                        #### derived variable for weekly units
    #                        "dv_wk_units",
    #
    #                        ## health vars
    #                        "compm1", "compm2", "compm3", "compm4", "compm5",
    #                        "compm6", "compm7", "compm8", "compm9", "compm10",
    #                        "compm11", "compm12", "compm13", "compm14", "compm15")
    # )


    # Tidy survey weights and only keep the sub-sample that answered smoking
    # and drinking related questions (in 2016/17 this is all respondents, but
    # only a subsample in future years)
    data <- data[!is.na(wt_adult)]
    setnames(data, "wt_adult", "wt_int")

    #data[age < 16, wt_int := NA]

    # Set PSU and cluster
    data[ , psu := paste0("2009_", 1)]
    data[ , cluster := paste0("2009_", 1)]

    data[ , year := 2009]
    data[ , country := "Wales"]

    return(data[])
}
