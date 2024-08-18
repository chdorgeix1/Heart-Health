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
    h.HadHeartAttack
FROM 
    tPatients AS p
INNER JOIN 
    tHealthStatus AS h ON p.patient_id = h.patient_id;'

result <- dbGetQuery(conn, sql_query)
dbDisconnect(conn)




result$HadHeartAttack <- ifelse(result$HadHeartAttack == "Yes", 1, 0)
summary_data <- aggregate(HadHeartAttack ~ State, data = result, FUN = mean)


us_states <- st_read("./data/geo_data/cb_2022_us_state_500k.kml")
cleaned_state_names <- gsub("<at><openparen>|<closeparen>", "", us_states$Name)
us_states$Name <- cleaned_state_names


us_states <- merge(us_states, summary_data, by.x = "Name", by.y = "State", all.x = TRUE, all.y = TRUE)  # Left join
names(us_states)[3] <- "ProportionHeartAttacks"
us_states <- na.omit(us_states)
us_states <- subset(us_states, !(Name %in% c("Guam", "Alaska", "Puerto Rico", "Hawaii")))
us_states$ProportionHeartAttacks <- us_states$ProportionHeartAttacks*100


tmap_mode('view')

# Create the map, coloring by ProportionHeartAttacks
map <- tm_shape(us_states) +
  tm_polygons(col = "ProportionHeartAttacks",  # Specify the column for coloring
              palette = "YlOrRd",            # Choose a color palette
              title = "Percent of Individuals Reporting Heart Attacks",
              popup.vars = c("Proportion of Heart Attacks" = "ProportionHeartAttacks")) +
  tm_layout(title = "Map of Proportion of Heart Attacks by State")  # Add a title

  
  
# Print the map
print(map)






