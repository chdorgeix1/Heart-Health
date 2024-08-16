import pandas as pd
import numpy as np
import sqlite3
import sys
from db_functions import *

if __name__ == "__main__":
    db_name = sys.argv[1]

    create_database(db_name)