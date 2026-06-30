library(dplyr)

root <- paste0("/Users/", Sys.getenv("USER"),
               "/Library/CloudStorage/Dropbox/SwitchBot/")
data_raw <- paste0(root, "data_raw/")
data_clean <- paste0(root, "data_clean/")

get_time <- function(data, folder) {
  data |> 
    pull(Timestamp) |> 
    last() %>%
    paste(folder, ":", .)
}

common_code <- function(x, slot_names) {
  x |> 
    setNames(slot_names) |> 
    purrr::map(readr::read_csv) |> 
    bind_rows(.id = "file") |> 
    mutate(across(Timestamp, lubridate::mdy_hms))
} 

load_data <- function(folder) {
  folder_name <- paste0(data_raw, folder)
  clean_file <- paste0(data_clean, folder, ".rds")
  if (file.exists(clean_file)) {
    tmp <- readRDS(clean_file)
    already_read <- tmp |> 
      pull(file) |> 
      unique()
    slot_names <- folder_name |> 
      dir() |> 
      setdiff(already_read)
    if (length(slot_names)) {
      out <- slot_names %>% 
        paste0(folder_name, "/", .) |> 
#        setNames(slot_names) |> 
#        purrr::map(readr::read_csv) |> 
#        bind_rows(.id = "file") |> 
#        mutate(across(Timestamp, lubridate::mdy_hms)) |> 
        common_code(slot_names) |> 
        bind_rows(tmp)
    } else {
      return(get_time(tmp, folder))
    }
  } else {
    slot_names <- dir(folder_name)
    out <- folder_name |> 
      dir(full = TRUE) |> 
#      setNames(slot_names) |> 
#      purrr::map(readr::read_csv) |> 
#      bind_rows(.id = "file") |> 
#      mutate(across(Timestamp, lubridate::mdy_hms))
      common_code(slot_names)
  }
  out |> 
    arrange(Timestamp) |> 
    unique() |> 
    saveRDS(clean_file)
  get_time(out, folder)
}


#data_raw |> 
#  dir() |> 
c("etage", "jardin" ) |> 
  purrr::map_chr(load_data) |> 
  cat(file = "README.md", sep = "\n")

folder <- "jardin"


#####################################

#load_data("jardin")
#tmp <- readRDS("jardin.rds")
#
#tmp |> 
#  pull(file) |> 
#  unique()
#
#  
#  paste0(root, folder) |>
#    dir(full = TRUE) |> 
#    purrr::map(readr::read_csv) |> 
#    bind_rows(.id = "file") |> 
#    mutate(across(Timestamp, lubridate::mdy_hms)) |> 
#    arrange(Timestamp) |> 
#    unique() |> 
#    saveRDS(paste0(folder, ".rds"))
#}
#
#walk(root, dir)
#
#load_data("jardin")
#load_data("etage")
#
#readRDS("jardin.rds")
#
#
#dir(root)
#
#write(format(tail(a$Timestamp, 1)), "README.md")
#
#write(format(tail(sbdata$Timestamp, 1)), "README.md")
#
##with(a, plot(Timestamp, `Temperature_Celsius(°C)`, type = "l", col = 4))
#