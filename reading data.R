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
        common_code(slot_names) |> 
        bind_rows(tmp)
    } else {
      return(get_time(tmp, folder))
    }
  } else {
    slot_names <- dir(folder_name)
    out <- folder_name |> 
      dir(full = TRUE) |> 
      common_code(slot_names)
  }
  out <- out |> 
    arrange(Timestamp) |> 
    unique()
  saveRDS(out, clean_file)
  get_time(out, folder)
}


data_raw |> 
  dir() |> 
  purrr::map_chr(load_data) |> 
  cat(file = "README.md", sep = "\n\n")

## with(a, plot(Timestamp, `Temperature_Celsius(°C)`, type = "l", col = 4))
