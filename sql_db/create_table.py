import pandas as pd
import numpy as np
import sqlite3

def create_table(curs, table_name, column_dict):
    ### Drops a table if it already exists
    curs.execute("DROP TABLE IF EXISTS tSample;")

    ### Uses the provided table_name and 
    ### column_dict consisting of keys as column names and values are datatypes
    
    sql_table = 'CREATE TABLE ' + table_name + '('
    sql_table += (', '.join(f"{key} {value}" for key, value in column_dict.items()))
    sql_table += ");"
    print(sql_table)
    curs.execute(sql_table)


