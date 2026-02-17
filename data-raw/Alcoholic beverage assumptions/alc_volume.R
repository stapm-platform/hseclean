
# Assumed beverage volumes
# Updated to include cider volumes for HSE 2022 processing

alc_volume_data <- data.table(
  beverage = c(
    # Beer volumes
    "nbeerhalfvol", "nbeerscanvol", "nbeerlcanvol", "nbeerbtlvol", 
    "sbeerhalfvol", "sbeerscanvol", "sbeerlcanvol", "sbeerbtlvol",
    
    # Cider volumes (added for HSE 2022)
    "nciderpintvol", "nciderscanvol", "nciderlcanvol", "nciderbtlvol",
    "sciderpintvol", "sciderscanvol", "sciderlcanvol", "sciderbtlvol",
    
    # Other beverage volumes
    "spiritsvol", "sherryvol", 
    "wineglassvol", "winesglassvol", "winelglassvol", "winebtlvol", 
    "popsscvol", "popssbvol", "popslbvol"
  ),

  volume = c(
    # Beer volumes (ml)
    284, 330, 440, 330,    # Normal beer: half-pint, small can, large can, bottle
    284, 330, 440, 330,    # Strong beer: half-pint, small can, large can, bottle
    
    # Cider volumes (ml) - added for HSE 2022
    568, 330, 440, 500,    # Normal cider: pint, small can, large can, bottle
    568, 330, 500, 500,    # Strong cider: pint, small can, large can, bottle
    
    # Other beverage volumes (ml)
    25, 50,                # Spirits, sherry
    175, 125, 250, 750,    # Wine: glass, small glass, large glass, bottle
    250, 275, 700          # RTDs: small can, small bottle, large bottle
  )
)

usethis::use_data(alc_volume_data, overwrite = TRUE)




