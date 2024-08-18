import pandas as pd
import uuid


csv_path = '../data/2022/heart_2022_no_nans.csv'
df = pd.read_csv(csv_path)
df['patient_id'] = [str(uuid.uuid4()) for i in range(len(df))]
df.to_csv('../data/2022/heart_2022_no_nans.csv')