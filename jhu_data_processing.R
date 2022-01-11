#### JHU Time Series Data Processing
## By Jonah Pool

library(tidyverse)
library(magrittr)
library(lubridate)


# Constants
yd <- today()  - ddays(1)
td <- today()

td
day <- yd
MichiganRiots<- seq(ymd("2020-05-26"), ymd("2020-06-03"), by = 1)
exclude = c("")
# date for daily data release
a <- as.character(ymd(day))
b <- str_split(a, "-")
b1 <- as.character(b[[1]][2])
b2 <- as.character(b[[1]][3]) 
b3 <- as.character(b[[1]][1])
d_lookup_str <- str_c(b1, b2, b3, sep = "-")
sinceMarch16 <- seq(date("2020-03-16"), day, by=1)
#sinceMarch16
last30 <- seq(td-30, td, by=1)
last21 <- seq(td-21, td, by=1)
last14 <- seq(td-14, td, by=1)
last7 <- seq(td-7, td, by=1)

red_states <- c("Alabama", "Alaska", "Arizona", "Arkansas", "Florida", "Georgia", "Idaho", "Indiana", "Iowa", "Maryland", "Massachusetts", "Mississippi", "Missouri", "Nebraska", "New Hampshire", "North Dakota", "Ohio", "Oklahoma", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "West Virginia", "Wyoming")

blue_states <- c("California", "Colorado", "Connecticut", "Delaware", "Hawaii", "Illinois", "Kansas", "Kentucky", "Louisiana", "Maine", "Michigan", "Minnesota", "Montana", "Nevada", "New Jersey", "New Mexico", "New York", "North Carolina", "Oregon", "Pennsylvania", "Rhode Island", "Virginia", "Washington", "Wisconsin")

bold.14.text <- element_text(face = "bold", size = 12)

red.fill.5 <- c("#bf080e","#bf080e","#bf080e","#bf080e","#bf080e")
blue.fill.5 <- c("#0016bd","#0016bd","#0016bd","#0016bd","#0016bd")

red.fill.10 <- c("#bf080e","#bf080e","#bf080e","#bf080e","#bf080e","#bf080e","#bf080e","#bf080e","#bf080e","#bf080e", "#bf080e")
blue.fill.10 <- c("#0016bd","#0016bd","#0016bd","#0016bd","#0016bd","#0016bd","#0016bd","#0016bd","#0016bd","#0016bd", "#0016bd")

x.limit.march15 <- seq(ymd("2020-03-15"), day, by=1)

movingAverage <- function(x, n=14, centered=TRUE) {
  
  if (centered) {
    before <- floor  ((n-1)/2)
    after  <- ceiling((n-1)/2)
  } else {
    before <- n-1
    after  <- 0
  }
  
  # Track the sum and count of number of non-NA items
  s     <- rep(0, length(x))
  count <- rep(0, length(x))
  
  # Add the centered data 
  new <- x
  # Add to count list wherever there isn't a 
  count <- count + !is.na(new)
  # Now replace NA_s with 0_s and add to total
  new[is.na(new)] <- 0
  s <- s + new
  
  # Add the data from before
  i <- 1
  while (i <= before) {
    # This is the vector with offset values to add
    new   <- c(rep(NA, i), x[1:(length(x)-i)])
    
    count <- count + !is.na(new)
    new[is.na(new)] <- 0
    s <- s + new
    
    i <- i+1
  }
  
  # Add the data from after
  i <- 1
  while (i <= after) {
    # This is the vector with offset values to add
    new   <- c(x[(i+1):length(x)], rep(NA, i))
    
    count <- count + !is.na(new)
    new[is.na(new)] <- 0
    s <- s + new
    
    i <- i+1
  }
  
  # return sum divided by count
  s/count
}


### Chart Funcitons


pq <- theme(text = bold.14.text) +
  #theme(axis.ticks = element_blank()) +
  theme(panel.border = element_rect(colour = "black", fill=NA, size=2),
        panel.background=element_rect(colour = NA, fill = "white"))
jhu_caption <- labs(caption="Data Source: Johns Hopkins University CSSE")



bar_chart_ts <- function(df, y, custom.fill = blue.fill.10, lab.title, y.lim = max(y)) {
  plot <- ggplot(df, aes(x = date, y = y, fill = "")) + 
    geom_col() +
    scale_fill_manual(values = custom.fill) +
    labs(y = "", title = lab.title, x = "Date") +
    theme(legend.position = "none") +
    ylim(0,y.lim) +
    pq
  return(plot)
}

line_chart_ts <- function(df, y, custom.fill = blue.fill.10, lab.title, y.lim = max(y)) {
  plot <- ggplot(df, aes(x = date, y = y, color = "", fill = "")) + 
    geom_line(size = 1.2) +
    scale_fill_manual(values = custom.fill) +
    scale_color_manual(values = custom.fill)+
    labs(y = "", title = lab.title, x = "Date") +
    theme(legend.position = "none") +
    ylim(0,y.lim) +
    pq
  return(plot)
}

line_chart_ma_ts <- function(df, y, custom.fill = blue.fill.10, lab.title, y.lim = max(y)) {
  plot <- ggplot(df, aes(x = date, y = y, color = "", fill = "")) + 
    geom_smooth(size = 1.2) +
    scale_fill_manual(values = custom.fill) +
    scale_color_manual(values = custom.fill)+
    labs(y = "", title = lab.title, x = "Date") +
    theme(legend.position = "none") +
    ylim(0,y.lim) +
    pq
  return(plot)
}

ts_date_count <- as.period(ymd("2020-01-22") %--% today())

daily_fname <- str_c("../COVID-19/csse_covid_19_data/csse_covid_19_daily_reports_us/", d_lookup_str, ".csv")
csse_today <- read_csv(daily_fname, col_types = "ccTddddddddddddcdd")
csse_confirmed_us_ts <- read_csv("../COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv",
                                 col_types=str_c('cccddcccddc', 
                                                 str_c(rep("i", times=ts_date_count), collapse=""))
)

csse_deaths_us_ts <- read_csv("../COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv", 
                              col_types=str_c('cccddcccddc', 
                                              str_c(rep("i", times=ts_date_count+1), collapse=""))
)
uid <- read_csv("../COVID-19/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv", col_types = "ccccccccddci")
daily_updates_ts <- read_csv("daily_updates_ts_us.csv", col_types="ccDdTdcdddddddddddddd")


# us_uid <- uid %>% 
#   filter(code3 %in% c(16, 316, 580, 850, 630, 840)) %>%
#   select(UID, Admin2, Province_State, Combined_Key, Population) %>% 
#   arrange(UID)
# 
# states <- c(us_uid$Province_State[1:4], us_uid$Province_State[6:57])
# states_uid <-seq(84000001, 84000056, by = 1)
# uid_states <- us_uid %>% 
#   filter(UID %in% c(seq(84000001, 84000056, by = 1))) %>% 
#   filter(UID != 84000011)
# 
# nyc_uid <- uid$UID[uid$Combined_Key == "New York City, New York, US"]
# nyc_pop <- uid$Population[uid$Combined_Key == "New York City, New York, US"]

us_patt <- '[0-5]\\d{4}'
us_regex <- regex(us_patt)

# Lookup table for US counties
us_counties <- uid %>% 
  filter(str_detect(FIPS, us_regex))

us_counties_uid <- us_counties$UID

# Lookup table for US states
us_states <- uid %>% 
  filter(FIPS %in% as.character(seq(1,56,1)))

us_states_uid <- us_states$UID
us_states_names <- us_states$Province_State


# Function to extract time series data into tabular data
extract_ts_data <- function(df, value_name="X1") {
  df_piv <- df %>% 
    pivot_longer(`1/22/20`:last_col(), names_to="date", values_to=value_name) %>% 
    mutate(date = mdy(date))
  return(df_piv)
}


# Get county level time series
us_cases_county <- csse_confirmed_us_ts %>% 
  filter(UID %in% us_counties_uid) %>% 
  extract_ts_data(value_name="cases") %>% 
  select(UID, date, cases)

us_deaths_county <- csse_deaths_us_ts %>% 
  filter(UID %in% us_counties_uid) %>% 
  extract_ts_data(value_name="deaths") %>% 
  select(UID, date, deaths)

us_by_county <- us_cases_county %>%  
  inner_join(us_deaths_county, by=c("UID", "date")) %>% 
  left_join(us_counties, by="UID")

# Get state level time series
us_cases_state <- csse_confirmed_us_ts %>% 
  filter(Province_State %in% us_states_names) %>%
  select(Province_State, `1/22/20`:last_col()) %>% 
  extract_ts_data(value_name="cases") %>%
  group_by(Province_State, date) %>% 
  summarize(cases=sum(cases)) %>% 
  ungroup()

us_deaths_state <- csse_deaths_us_ts %>% 
  filter(Province_State %in% us_states_names) %>%
  select(Province_State, `1/22/20`:last_col()) %>% 
  extract_ts_data(value_name="deaths") %>%
  group_by(Province_State, date) %>% 
  summarize(deaths=sum(deaths)) %>% 
  ungroup()

us_by_state <- us_cases_state %>% 
  inner_join(us_deaths_state, by=c("Province_State", "date")) %>%
  left_join(us_states, by="Province_State")