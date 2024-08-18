import pandas as pd
import sqlite3

def fill_table(cursor, df, table_name, table_columns):
    try:
        for index, row in df.iterrows():
            values = [row[col] for col in table_columns]
            placeholders = ', '.join(['?'] * len(values))
            query = f"INSERT INTO {table_name} ({', '.join(table_columns)}) VALUES ({placeholders})"
            cursor.execute(query, values)
    except Exception as e:
        print(f"Error filling table {table_name}: {e}")