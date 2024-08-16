from db_functions import *
from create_table import *

curs = create_database('test_db.db')

#table_name = 'tHeart'
#column_dict = {'BP': 'INTEGER', 'Height': 'REAL', 'Name': 'TEXT'}

#create_table(curs, table_name, column_dict)

tables = (return_all_table_names(curs))

for table in tables:
    print(table)