#load requiring packages
library(rvest)
library(stringr)
library(tidyverse)
library(lubridate)

#setting up working directory
setwd(dir = "c:/Users/mickeyang/Desktop")

#set the web page url
url <- "http://dongping.co.nz/getRate.php"

#read html content from the web page
webpage <- read_html(url)

#convert to plain text
plain_text <- html_text(webpage)

#extract useful data from the text
df <- plain_text %>%
  str_replace_all(pattern = "\"|\'|[:blank:]","") %>%
  str_split(pattern = "=", n = 7) 

#convert to data frame
df <- as.data.frame(df)

#change column name to make is more readable
names(df) = "value"

#tidy up the data format
df<- as.tibble(str_sub(df$value,start = 1, end = 6))[,] %>%
  mutate(date = as.character.Date(Sys.Date()))

#add additional column
note_column <- as.tibble(c("toRMB","buyRMB","soldRMB","toUSD","buyUSD","soldUSD"))
names(note_column) <- "note"

#make data flat
new_entries <- df[-1,]%>%
  bind_cols(note_column) %>%
  spread(note,value)

#read historical data from CSV file
historical_data <- read_csv(file = "currency.csv",col_types = "ccccccc")

#merge new data with the historical
merged_data <- historical_data %>%
  bind_rows(new_entries)

#export data and overwrite the historical file
write_csv(merged_data,path = "currency.csv")