from db_functions import create_database, commit_changes, close_connection, return_all_table_names, view_to_df, drop_table
from create_table import create_table
from fill_table import fill_table
import uuid
import pandas as pd

curs, conn = create_database('test_db.db')
csv_path = '../data/heart_health_data/2022/heart_2022_no_nans.csv'
df = pd.read_csv(csv_path)

### Create table tPatients including patient demographic infomation
table_name = 'tPatients'
patients_column_dict = {
    'patient_id': 'TEXT PRIMARY KEY',  # UUID as a string
    'State': 'TEXT',
    'Sex': 'TEXT',
    'RaceEthnicityCategory': 'TEXT',
    'AgeCategory': 'TEXT',
    'HeightInMeters': 'REAL',
    'WeightInKilograms': 'REAL',
    'BMI': 'REAL'
}
create_table(curs, table_name, patients_column_dict)

### Fill table tPatients with patient demographic information
patient_table_columns = [
    "patient_id",
    "State",
    "Sex",
    "RaceEthnicityCategory",
    "AgeCategory",
    "HeightInMeters",
    "WeightInKilograms",
    "BMI"
]
fill_table(curs, df, 'tPatients', patient_table_columns)
commit_changes(conn)


### Create and populate table tHealthStatus
table_name = 'tHealthStatus'
health_status_column_dict = {
    'patient_id': 'TEXT PRIMARY KEY',  # Foreign key as a string
    'GeneralHealth': 'TEXT',
    'PhysicalHealthDays': 'INTEGER',
    'MentalHealthDays': 'INTEGER',
    'LastCheckupTime': 'TEXT',
    'PhysicalActivities': 'TEXT',
    'SleepHours': 'REAL',
    'RemovedTeeth': 'TEXT',
    'HadHeartAttack': 'TEXT',
    'HadAngina': 'TEXT',
    'HadStroke': 'TEXT',
    'HadAsthma': 'TEXT',
    'HadSkinCancer': 'TEXT',
    'HadCOPD': 'TEXT',
    'HadDepressiveDisorder': 'TEXT',
    'HadKidneyDisease': 'TEXT',
    'HadArthritis': 'TEXT',
    'HadDiabetes': 'TEXT'
}
create_table(curs, table_name, health_status_column_dict)

health_status_table_columns = [
    "patient_id",
    "GeneralHealth",
    "PhysicalHealthDays",
    "MentalHealthDays",
    "LastCheckupTime",
    "PhysicalActivities",
    "SleepHours",
    "RemovedTeeth",
    "HadHeartAttack",
    "HadAngina",
    "HadStroke",
    "HadAsthma",
    "HadSkinCancer",
    "HadCOPD",
    "HadDepressiveDisorder",
    "HadKidneyDisease",
    "HadArthritis",
    "HadDiabetes"
]
fill_table(curs, df, 'tHealthStatus', health_status_table_columns)


### Create and populate table tDisabilities
table_name = 'tDisabilities'
disabilities_column_dict = {
    'patient_id': 'TEXT PRIMARY KEY',  # Foreign key as a string
    'DeafOrHardOfHearing': 'TEXT',
    'BlindOrVisionDifficulty': 'TEXT',
    'DifficultyConcentrating': 'TEXT',
    'DifficultyWalking': 'TEXT',
    'DifficultyDressingBathing': 'TEXT',
    'DifficultyErrands': 'TEXT'
}
create_table(curs, table_name, disabilities_column_dict)

disabilities_table_columns = [
    "patient_id",
    "DeafOrHardOfHearing",
    "BlindOrVisionDifficulty",
    "DifficultyConcentrating",
    "DifficultyWalking",
    "DifficultyDressingBathing",
    "DifficultyErrands"
]
fill_table(curs, df, 'tDisabilities', disabilities_table_columns)


### Create and populate table tLifestyle
table_name = 'tLifestyle'
lifestyle_column_dict = {
    'patient_id': 'TEXT PRIMARY KEY',  # Foreign key as a string
    'SmokerStatus': 'TEXT',
    'ECigaretteUsage': 'TEXT',
    'AlcoholDrinkers': 'TEXT'
}
create_table(curs, table_name, lifestyle_column_dict)

lifestyle_table_columns = [
    "patient_id",
    "SmokerStatus",
    "ECigaretteUsage",
    "AlcoholDrinkers"
]
fill_table(curs, df, 'tLifestyle', lifestyle_table_columns)


### Create and populate table tMedicalTests
table_name = 'tMedicalTests'
medical_tests_column_dict = {
    'patient_id': 'TEXT PRIMARY KEY',  # Foreign key as a string
    'ChestScan': 'TEXT',
    'HIVTesting': 'TEXT',
    'FluVaxLast12': 'TEXT',
    'PneumoVaxEver': 'TEXT',
    'TetanusLast10Tdap': 'TEXT',
    'HighRiskLastYear': 'TEXT',
    'CovidPos': 'TEXT'
}
create_table(curs, table_name, medical_tests_column_dict)

medical_tests_table_columns = [
    "patient_id",
    "ChestScan",
    "HIVTesting",
    "FluVaxLast12",
    "PneumoVaxEver",
    "TetanusLast10Tdap",
    "HighRiskLastYear",
    "CovidPos"
]
fill_table(curs, df, 'tMedicalTests', medical_tests_table_columns)


### Commit changes
commit_changes(conn)

### Query each table and return a view as a df and examine each df head
tables = (return_all_table_names(curs))
for table in tables:
    print(table)
    query = "SELECT * FROM " + table[0] + ";"
    testdf = view_to_df(query, conn)
    print(testdf.head())
    print(testdf.shape)
    print('')

### Close Connection
close_connection(conn)



