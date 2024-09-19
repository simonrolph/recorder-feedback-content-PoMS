compute_objects <- function(data){
  #mean number of species
  mean_n_fit_counts = data %>% 
    group_by(user_id) %>% 
    summarise(n_counts = n()) %>%
    pull(n_counts) %>%
    mean()
  
  #mean number of records
  mean_n_insects = data %>% 
    rowwise() %>%
    mutate(n_insects = sum(c(bumblebees, honeybees, solitary_bees, wasps), na.rm=T)) %>%
    group_by(user_id) %>% 
    summarise(total_insects = sum(n_insects, na.rm=T)) %>%
    pull(total_insects) %>%
    mean()
  
  #return the list of precalculated objects
  list(mean_n_fit_counts = mean_n_fit_counts,
       mean_n_insects = mean_n_insects)
  
}