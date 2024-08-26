from db_functions import close_connection, return_all_table_names, view_to_df, create_db_conn, create_db_cursor
import uuid
import pandas as pd

conn = create_db_conn('test_db.db')
curs = create_db_cursor(conn)

tables = (return_all_table_names(curs))
for table in tables:
    print(table)
    query = "SELECT * FROM " + table[0] + ";"
    testdf = view_to_df(query, conn)
    print(testdf.columns)
    #print(testdf.shape)
    #print('')

### Close Connection
close_connection(conn)
