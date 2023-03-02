

#' @param root Character string - the root directory. This is the section of the file path to where the data is stored
#' that might vary depending on how the network drive is being accessed. The default is "X:/",
#' which corresponds to the University of Sheffield's X drive in the School of Health and Related Research.
#' Within the function, the root is pasted onto the front of the rest of the file path specified in the 'file' argument.
#' Thus, if root = NULL, then the complete file path is given in the 'file' argument.
#' @param file Character string - the file path and the name and extension of the file. The function has been
#' designed and tested to work with tab delimited files '.tab'. Files are read by the function [data.table::fread].
#' @param select_cols Character string - select either:
#' "all" - keep all variables in the survey data;
#' "tobalc" - keep a reduced set of variables associated with tobacco and alcohol consumption and a selected set of
#' survey design and socio-demographic variables that are needed for the functions within the hseclean package to work.
#'
#'
