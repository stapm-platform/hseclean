# Assumed beverage volumes

alc_volume_data <- data.table(
  beverage = c(
    "nbeerhalfvol", "nbeerscanvol", "nbeerlcanvol", "nbeerbtlvol", "sbeerhalfvol", "sbeerscanvol",
    "sbeerlcanvol", "sbeerbtlvol", "spiritsvol", "sherryvol",
    "wineglassvol", "winesglassvol", "winelglassvol",
    "winebtlvol", "popsscvol", "popssbvol", "popslbvol"
  ),
  volume = c(284, 330, 440, 330, 284, 330, 440, 330, 25, 50, 175, 125, 250, 750, 250, 275, 700)
)

usethis::use_data(alc_volume_data, overwrite = TRUE)

##### 2022 with Kantar mode data

# Assumed beverage volumes

alc_volume_data_2022 <- data.table(
  beverage = c(
    "nbeerhalfvol", "nbeerscanvol", "nbeerlcanvol", "nbeerbtlvol",
    "sbeerhalfvol", "sbeerscanvol", "sbeerlcanvol", "sbeerbtlvol",
    "nciderhalfvol", "nciderscanvol", "nciderlcanvol", "nciderbtlvol",
    "sciderhalfvol", "sciderscanvol", "sciderlcanvol", "sciderbtlvol",
    "spiritsvol", "sherryvol",
    "wineglassvol", "winesglassvol", "winelglassvol", "winebtlvol",
    "popsscvol", "popssbvol", "popslbvol"
  ),
  volume = c(
    284, 330, 440, 500, # normal beer (half pint, small can, large can, bottle)
    284, 330, 440, 500, # strong beer (half pint, small can, large can, bottle)
    284, 330, 440, 500, # normal cider (half pint, small can, large can, bottle)
    284, 330, 500, 500, # strong cider (half pint, small can, large can, bottle)
    25, 50, # spirits, sherry
    175, 125, 250, 750, # wine (glass, small glass, large glass, bottle)
    250, 275, 700
  ) # pops (small can, small bottle, large bottle)
)

# Notes:
# - Cider volumes added for HSE 2022+ where cider split into normal/strong categories
# - Pint = 568ml (1 UK pint)
# - Small can = 330ml (standard can size)
# - Large can = 440-500ml (varies by strength/type)
# - Bottle = 500ml (standard cider bottle)

usethis::use_data(alc_volume_data_2022, overwrite = TRUE)
