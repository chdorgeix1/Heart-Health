from db_functions import *
from create_table import *
from fill_table import *

curs, conn = create_database('test_db.db')

#table_name = 'tHeart'
#column_dict = {'BP': 'INTEGER', 'Height': 'REAL', 'Name': 'TEXT'}

#create_table(curs, table_name, column_dict)

#tables = (return_all_table_names(curs))

#for table in tables:
#    print(table)
csv_path = '../data/2022/heart_2022_no_nans.csv'

table_columns = ['BP', 'Height', 'Name']
csv_columns = ['PhysicalHealthDays', 'HeightInMeters', 'State']

#fill_table(curs, csv_path, 'tHeart', table_columns, csv_columns)
#commit_changes(conn)

query = "SELECT * FROM tHeart;"
tHeartdf = view_to_df(query, conn)

print(type(tHeartdf))
print(tHeartdf['Name'])