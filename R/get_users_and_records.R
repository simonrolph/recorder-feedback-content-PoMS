# This script automates the process of retrieving subscriber information from an email list and their corresponding biodiversity records from the Indicia data warehouse. First, it loads necessary libraries, sources helper functions (get_records_from_indicia and get_subscribers_from_controller), and retrieves subscribers from a specified email list using the API. It then saves the subscriber data into a CSV file. For each subscriber, the script fetches their most recent species records from Indicia by looping through the subscriber list. For each user, it processes and extracts relevant information like species, vernacular names, coordinates, and observation dates, appending the results to a master data frame. Finally, the script saves the compiled species data to another CSV file.
library(httr)
library(jsonlite)
library(curl)

config <- config::get()

source("R/get_records_from_indicia.R")
source("R/get_subscribers_from_controller.R")

email_list_id <- "1"  # Replace with your email list ID

# Get subscribers and print the data frame
subscribers_df <- get_subscribers_from_controller(api_url = config$controller_app_base_url, 
                                                  email_list_id, 
                                                  api_token = config$controller_app_api_key)
subscribers_df

#save the data
write.csv(subscribers_df,config$participant_data_file,row.names = F)



#loop through users

records_data <- data.frame()#create an empty data frame
for (i in 1:nrow(subscribers_df)){
  data_out <- get_user_records_from_indicia(base_url = config$indicia_warehouse_base_url, 
                                           client_id = config$indicia_warehouse_client_id,
                                           shared_secret = config$indicia_warehouse_secret,
                                           user_warehouse_id = subscribers_df$user_id[i],
                                           n_records = 20)
  
  if (data_out$hits$total$value >0){
    #any intermediate data processing
    latlong <- data_out$hits$hits$`_source`$location$point
    
    #extract all the columns you need
    user_records <- data.frame(latitude = strsplit(latlong,",")[[1]][1],
                               longitude = strsplit(latlong,",")[[1]][2],
                               species = data_out$hits$hits$`_source`$taxon$taxon_name,
                               species_vernacular = data_out$hits$hits$`_source`$taxon$vernacular_name,
                               date = data_out$hits$hits$`_source`$event$date_start,
                               user_id = data_out$hits$hits$`_source`$metadata$created_by_id
    )
    
    records_data <- rbind(records_data,user_records)
  }
}

records_data

#save the data
write.csv(records_data,config$data_file,row.names = F)
