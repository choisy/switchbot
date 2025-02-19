library(dplyr)

user <- whoami::whoami()[["username"]]

sbdata <- paste0("/Users/", user, "/Library/CloudStorage/Dropbox/SwitchBot") |> 
  dir(full = TRUE) |> 
  purrr::map(readr::read_csv) |> 
  bind_rows() |> 
  mutate(across(Timestamp, lubridate::mdy_hms))

with(sbdata, plot(Timestamp, `Temperature_Celsius(°C)`, type = "l", col = 4))
