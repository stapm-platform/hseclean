
#' Quitting smoking \lifecycle{experimental}
#'
#' Cleans the data on the motivation to quit smoking and the use of support.
#'
#' Only tested on England data
#' Use of support not currently incorporated
#'
#'
#' @param data Data table - the Health Survey for England data.
#' @importFrom data.table :=
#' @return Returns an updated data table with:
#' \itemize{
#' \item giveup_smk - whether a current smoker wants to quit smoking (yes, no).
#' }
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#'
#' data <- read_2001()
#' data <- smk_quit(data)
#'
#' }
#'
smk_quit <- function(
  data
) {

  # Wants to give up smoking
  
  data[ , giveup_smk := NA_character_]
  
  if("giveup" %in% colnames(data)) {
    
    data[giveup == 1, giveup_smk := "yes"]
    data[giveup == 2, giveup_smk := "no"]
    
  }
  
  if("givupsk" %in% colnames(data)) {
    
    data[is.na(giveup_smk) & givupsk == 1, giveup_smk := "yes"]
    data[is.na(giveup_smk) & givupsk == 2, giveup_smk := "no"]
    
  }
  
  if(!("cig_smoker_status" %in% colnames(data))) message("oops, run smk_status() first")
  
  data[cig_smoker_status %in% c("never", "former"), giveup_smk := "non_smoker"]
  
  
return(data[])
}



