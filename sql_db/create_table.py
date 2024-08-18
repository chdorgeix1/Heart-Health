import sqlite3

def create_table(curs, table_name, columns_dict):
    try:
        columns = ', '.join([f"{col} {dtype}" for col, dtype in columns_dict.items()])
        curs.execute(f"CREATE TABLE IF NOT EXISTS {table_name} ({columns});")
    except sqlite3.Error as e:
        print(f"Error creating table {table_name}: {e}")