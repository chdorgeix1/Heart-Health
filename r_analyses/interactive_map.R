library(leaflet)
library(tmap)
library(RSQLite)
library(DBI)
library(sf)
library(dplyr)

conn <- dbConnect(RSQLite::SQLite(), dbname = "./sql_db/test_db.db")

sql_query = 
  'SELECT 
    p.State, 
    p.patient_id, 
    p.AgeCategory,
    h.HadHeartAttack
FROM 
    tPatients AS p
INNER JOIN 
    tHealthStatus AS h ON p.patient_id = h.patient_id;'

query_df <- dbGetQuery(conn, sql_query)
dbDisconnect(conn)

age_list <- c("18", "25", "30", "35", "40", "45", "50", "55", "60", "65", "70", "75", "80")
avg_ages <- c(21, 27, 32, 37, 42, 47, 52, 57, 62, 67, 72, 77, 85)  # 85 for "80 or older"
age_map <- setNames(avg_ages, age_list)

# Function to get average age
get_avg_age <- function(age_category) {
  for (age in age_list) {
    if (grepl(age, age_category)) {
      return(age_map[age])
    }
  }
  return(NA)  # Return NA if no match found
}

# Apply the function to create a new column
query_df$AverageAge <- sapply(query_df$AgeCategory, get_avg_age)

# Display the first few rows to verify
head(query_df[, c("AgeCategory", "AverageAge")])
  
query_df$HadHeartAttack <- ifelse(query_df$HadHeartAttack == "Yes", 1, 0)
#summary_data <- aggregate(HadHeartAttack ~ State, data = result, FUN = mean)
#head(summary_data)

heart_att_state_df <- query_df %>%
  group_by(State) %>%
  summarize(
    total_respondents = n_distinct(patient_id),
    heart_attack_count = sum(HadHeartAttack == 1, na.rm = TRUE),
    heart_attack_proportion = heart_attack_count / total_respondents
  ) %>%
  ungroup()

age_summary <- aggregate(AverageAge ~ State, data = query_df, FUN = mean)
age_summary

state_pop_data <- read.csv('./data/state_data/state_population_2020-2023.csv')
state_pop_data <- state_pop_data[ , c(1, 3)]
state_pop_data <- state_pop_data[-c(1, 2, 3, 4, 5, 6, 7, 8), ]
state_pop_data <- state_pop_data[-c(52:67), ]
colnames(state_pop_data) <- c("Location", "Pop_2022")
state_pop_data$Location <- gsub("\\.", "", state_pop_data$Location)

us_states <- st_read("./data/geo_data/cb_2022_us_state_500k.kml")
us_states$Name <- gsub("<at><openparen>|<closeparen>", "", us_states$Name)

us_states <- merge(us_states, heart_att_state_df, by.x = "Name", by.y = "State", all.x = TRUE, all.y = TRUE)  # Left join
us_states <- merge(us_states, state_pop_data, by.x = "Name", by.y = "Location", all.x = TRUE, all.y = TRUE)  # Left join
us_states <- merge(us_states, age_summary, by.x = "Name", by.y = "State", all.x = TRUE, all.y = TRUE)
names(us_states)[5] <- "ProportionHeartAttacks"
us_states <- na.omit(us_states)
us_states <- subset(us_states, !(Name %in% c("Guam", "Alaska", "Puerto Rico", "Hawaii")))
us_states$ProportionHeartAttacks <- us_states$ProportionHeartAttacks*100
us_states$ProportionHeartAttacks <- round(us_states$ProportionHeartAttacks, 1)
us_states$AverageAge <- round(us_states$AverageAge, 1)

head(us_states)

tmap_mode('view')

# Create the map, coloring by ProportionHeartAttacks
map <- tm_shape(us_states) +
  tm_polygons(col = "ProportionHeartAttacks",  # Specify the column for coloring
              palette = "YlOrRd",            # Choose a color palette
              title = "Percent of Individuals Reporting Heart Attacks",
              popup.vars = c("Proportion of Heart Attacks" = "ProportionHeartAttacks" , 
                             'Total Respondents' = 'total_respondents',
                             'Number of Heart Attacks in Respondents' = 'heart_attack_count',
                             'State Population in 2022' = 'Pop_2022')) +
  tm_shape(us_states) +
  tm_polygons(col = "AverageAge",  # Specify the column for coloring
              palette = "YlOrRd",            # Choose a color palette
              title = "Percent of Individuals Reporting Heart Attacks",
              popup.vars = c("Average Age" = "AverageAge")) +
  tm_layout(title = "Map of Proportion of Heart Attacks by State")  # Add a title


map <- map + tm_layers_control(
  position = c("topright"),
  basemaps = c("OpenStreetMap", "Esri.WorldImagery"),
  overlays = c("Heart Attack Proportion", "Average Age")
)

# Print the map
print(map)

tmap_save(map, "./generated_maps/interactive_US_map.html")

tmap_mode("view")

# Create the map with multiple layers
map <- tm_shape(us_states) +
  tm_polygons(col = "ProportionHeartAttacks",  
              palette = "YlOrRd",            
              title = "Percent of Individuals Reporting Heart Attacks",
              id = "name",  # Optional: to add labels on hover
              group = "Heart Attack Proportion",  # Group name for toggling
              
              popup.vars = c("Proportion of Heart Attacks" = "ProportionHeartAttacks", 
                             'Total Respondents' = 'total_respondents',
                             'Number of Heart Attacks in Respondents' = 'heart_attack_count',
                             'State Population in 2022' = 'Pop_2022')) +
  tm_shape(us_states) +
  tm_polygons(col = "AverageAge",  
              palette = "Blues",            
              title = "Average Age",
              id = "name",  # Optional: to add labels on hover
              group = "Average Age",  # Group name for toggling
              popup.vars = c("Average Age" = "AverageAge")) +
  tm_layout(title = "Map of Health Data by State", legend.outside=TRUE)

# Print the map
print(map)

  
  
  
  
  
  





