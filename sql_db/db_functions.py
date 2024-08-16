import pandas as pd
import numpy as np
import sqlite3

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
    return curs

def return_all_table_names(curs):
    curs.execute("SELECT name FROM sqlite_master WHERE type='table';")
    return curs.fetchall()