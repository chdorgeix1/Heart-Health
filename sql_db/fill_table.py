import pandas as pd
import numpy as np
import sqlite3

def fill_table(curs, csv_path, table_name, table_columns, csv_columns):
    ### Drops a table if it already exists
    
    csv_df = pd.read_csv(csv_path)

    sql = """
    INSERT INTO tSample (sample_id, site_id, BGR, collect_date) VALUES (:sample_id, :site_id, :BGR, :date)
    ;"""

    sql_insert = 'INSERT INTO ' + table_name + ' ('
    sql_insert += (', '.join(table_columns)) + ') VALUES ('
    sql_insert += ', '.join(f":{column}" for column in csv_columns) + ');' 
 
    for row in csv_df.to_dict(orient='records'):
        curs.execute(sql_insert, row)