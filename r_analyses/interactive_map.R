library(leaflet)
library(tmap)
library(RSQLite)
library(DBI)
library(sf)
library(dplyr)
#install.packages("remotes")
#install_github("r-tmap/tmap")
install.packages("tmap", repos = c("https://r-tmap.r-universe.dev", "https://cloud.r-project.org"))

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


### Combination of tmap, leaflet, and javascript to create interactive map
tmap_mode("view")

us_states$geometry <- sf::st_make_valid(us_states$geometry)

library(htmlwidgets)

map <- tm_shape(us_states) +
  tm_polygons(fill = "ProportionHeartAttacks", 
              group = "Proportion Heart Attacks",
              group.control = 'radio',
              fill.scale = tm_scale_continuous(values = "reds"),
              fill.legend = tm_legend(title = "Proportion Heart Attacks", 
                                      orientation = "landscape",
                                      position = tm_pos_out("center", "bottom"), 
                                      frame = FALSE)) +
  tm_shape(us_states) +
  tm_polygons(fill = "AverageAge", 
              group = "Average Age",
              group.control = 'radio',
              fill.scale = tm_scale_continuous(values = "greens"),
              fill.legend = tm_legend(title = "Average Age", 
                                      orientation = "landscape",
                                      position = tm_pos_out("center", "bottom"), 
                                      frame = FALSE)) +
  tm_basemap('OpenStreetMap', group.control = 'none')

leaflet_map <- tmap_leaflet(map)
leaflet_map <- leaflet_map %>%
  onRender("
    function(el, x) {
      var map = this;

      // Function to hide all legends
      function hideAllLegends() {
        var legends = document.getElementsByClassName('info legend leaflet-control');
        for (var i = 0; i < legends.length; i++) {
          legends[i].style.display = 'none';
        }
      }

      // Hide all legends when the map loads
      hideAllLegends();

      function showInitialLegend() {
        var activeLayers = [];
        map.eachLayer(function(layer) {
          if (layer.options && layer.options.group && map.hasLayer(layer)) {
            activeLayers.push(layer.options.group);
          }
        });

        if (activeLayers.length > 0) {
          var legends = document.getElementsByClassName('info legend leaflet-control');
          for (var i = 0; i < legends.length; i++) {
            if (legends[i].innerHTML.includes(activeLayers[0])) {
              legends[i].style.display = 'block';
              break;
            }
          }
        } else {
        }
      }
      
      showInitialLegend();
  
      // Update legends when layer changes
      map.on('baselayerchange', function (e) {
        hideAllLegends();
        var legends = document.getElementsByClassName('info legend leaflet-control');
        for (var i = 0; i < legends.length; i++) {
          if (legends[i].innerHTML.includes(e.name)) {
            legends[i].style.display = 'block';
          }
        }
      });
    }
  ")

leaflet_map
saveWidget(leaflet_map, "./generated_maps/interactive_US_map_3.html")
