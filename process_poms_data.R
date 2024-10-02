library(readxl)
library(dplyr)
library(ggplot2)
library(tidyr)

fit_count_data <- read_excel("data/FIT Count data_all surveys_2024.xlsx")

fit_count_data <- fit_count_data %>% filter(country_main == "United Kingdom")

fit_count_data <- fit_count_data %>% mutate(user_id = digitised_by)
fit_count_data <- fit_count_data %>% mutate(target_flower =  sub("-.*", "", target_flower))
write.csv(fit_count_data,"data/fit_count.csv")


flower_types <- fit_count_data$target_flower %>% unique()
write.table(flower_types,"data/flower_types.csv",row.names = F,col.names = T)