# Test the functions

library(readr)
library(dplyr)

setwd("C:/Users/hriisalu/OneDrive - Tartu Ülikool/Dokumendid/Koolitus/Coursera/Building packages/farsfunctions")
setwd("C:/Users/hriisalu/Documents/Coursera/Building packages/farsfunctions")

source("R/fars_functions_hr.R")

#data <- read_csv("fars_data/data/accident_2013.csv.bz2")
kuki <- fars_read("data/accident_2013.csv.bz2")

make_filename(2013)

fars_read_years(2013)
fars_read_years(c(2013, 2014))
fars_read_years(2013:2015)

fars_summarize_years(c(2013, 2015))
fars_summarize_years(2013:2014)

dat_list <- fars_read_years(c(2013, 2015))

fars_map_state(50, 2013)
