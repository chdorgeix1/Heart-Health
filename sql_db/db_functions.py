import pandas as pd
import sqlite3

def commit_changes(connection):
    try:
        connection.commit()
    except sqlite3.Error as e:
        print(f"Error committing changes: {e}")

def close_connection(connection):
    try:
        connection.close()
    except sqlite3.Error as e:
        print(f"Error closing connection: {e}")

def create_db_conn(db_name):
    conn = sqlite3.connect(db_name)
    return conn

def create_db_cursor(conn):
    curs = conn.cursor()
    return curs

def create_database(db_name):
    conn = create_db_conn(db_name)
    curs = create_db_cursor(conn)
    ### IMPORTANT!!! ###
    # By default, sqlite does not enforce foreign key constraints. 
    # According to the documentation, this is for backwards compatibility. You have to turn them on yourself.
    curs.execute('PRAGMA foreign_keys=ON;')
    return curs, conn

def return_all_table_names(curs):
    curs.execute("SELECT name FROM sqlite_master WHERE type='table';")
    return curs.fetchall()

def drop_table(curs, table_name):
    try:
        curs.execute('DROP TABLE ' + table_name + ' ;')
    except sqlite3.OperationalError as e:
        print(f"An error occurred: {e}")

def open_ended_sql_query(curs, query):
    output = curs.execute(query)
    return output

def view_to_df(sql_view, conn):
    df = pd.read_sql(sql_view, conn)
    return df

