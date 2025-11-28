#' Publication-ready ggplot2 theme
#'
#' A clean, professional theme for publication-quality figures
#' with white background and refined typography
#'
#' @param base_size Base font size (default 12)
#' @param base_family Base font family (default "sans")
#'
#' @return A ggplot2 theme object
#' @export
#'
theme_publication <- function(base_size = 12, base_family = "sans") {
  ggplot2::theme_bw(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # White background
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),

      # Grid lines - subtle gray
      panel.grid.major = ggplot2::element_line(color = "gray90", linewidth = 0.3),
      panel.grid.minor = ggplot2::element_blank(),

      # Axes
      axis.line = ggplot2::element_line(color = "gray20", linewidth = 0.5),
      axis.ticks = ggplot2::element_line(color = "gray20", linewidth = 0.3),
      axis.text = ggplot2::element_text(color = "gray20", size = ggplot2::rel(0.9)),
      axis.title = ggplot2::element_text(color = "gray10", size = ggplot2::rel(1.0),
                                          face = "bold"),

      # Titles
      plot.title = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.3),
                                          hjust = 0, color = "gray10",
                                          margin = ggplot2::margin(b = 10)),
      plot.subtitle = ggplot2::element_text(size = ggplot2::rel(1.0),
                                             hjust = 0, color = "gray40",
                                             margin = ggplot2::margin(b = 15)),
      plot.caption = ggplot2::element_text(size = ggplot2::rel(0.8),
                                            hjust = 1, color = "gray50",
                                            margin = ggplot2::margin(t = 10)),

      # Legend
      legend.background = ggplot2::element_rect(fill = "white", color = NA),
      legend.key = ggplot2::element_rect(fill = "white", color = NA),
      legend.text = ggplot2::element_text(size = ggplot2::rel(0.9), color = "gray20"),
      legend.title = ggplot2::element_text(size = ggplot2::rel(1.0), face = "bold",
                                            color = "gray10"),
      legend.position = "right",
      legend.key.size = ggplot2::unit(1.2, "lines"),

      # Facets
      strip.background = ggplot2::element_rect(fill = "gray95", color = "gray80"),
      strip.text = ggplot2::element_text(color = "gray10", face = "bold",
                                          size = ggplot2::rel(1.0)),

      # Margins
      plot.margin = ggplot2::margin(t = 10, r = 15, b = 10, l = 10)
    )
}

# Professional color palettes
#' @export
colors_publication <- list(
  # Sequential palette (light to dark)
  blues = c("#EFF3FF", "#C6DBEF", "#9ECAE1", "#6BAED6", "#4292C6", "#2171B5", "#084594"),
  greens = c("#E5F5E0", "#C7E9C0", "#A1D99B", "#74C476", "#41AB5D", "#238B45", "#005A32"),

  # Diverging palette
  diverging = c("#D73027", "#FC8D59", "#FEE090", "#FFFFBF", "#E0F3F8", "#91BFDB", "#4575B4"),

  # Categorical palette (colorblind-friendly)
  categorical = c("#0173B2", "#DE8F05", "#029E73", "#CC78BC", "#CA9161", "#949494", "#ECE133"),

  # Risk categories
  risk = c(
    abstainer = "#7F8C8D",        # Gray
    lower_risk = "#27AE60",       # Green
    increasing_risk = "#E67E22",  # Orange
    higher_risk = "#C0392B"       # Red
  ),

  # Beverages
  beverages = c(
    Beer = "#F39C12",      # Amber
    Wine = "#8E44AD",      # Purple
    Spirits = "#E74C3C",   # Red
    RTDs = "#16A085"       # Teal
  )
)
