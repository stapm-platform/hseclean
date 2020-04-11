
# Assumed beverage volumes

alc_volume_data <- data.table(
  beverage = c("nbeerhalfvol", "nbeerscanvol", "nbeerlcanvol", "nbeerbtlvol", "sbeerhalfvol", "sbeerscanvol",
               "sbeerlcanvol", "sbeerbtlvol", "spiritsvol", "sherryvol", "wineglassvol", "winesglassvol", "winelglassvol",
               "winebtlvol", "popsscvol", "popssbvol", "popslbvol"),

  volume = c(284, 330, 440, 330, 284, 330, 440, 330, 25, 50, 175, 125, 250, 750, 250, 275, 700)
)

usethis::use_data(alc_volume_data)




