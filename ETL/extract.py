import pandas as pd
from pathlib import Path


DATA_DIR = Path(__file__).resolve().parent.parent / 'Data'

def extract_data():

    features_df = pd.read_csv(DATA_DIR / 'Features_dataset.csv')

    sales_df = pd.read_csv(DATA_DIR / 'sales_dataset.csv')
    
    store_df = pd.read_csv(DATA_DIR / 'stores_dataset.csv')

    print('Features Dataset')
    print(features_df.head())
    print(features_df.dtypes)

    print('Sales Dataset')
    print(sales_df.head())
    print(sales_df.dtypes)

    print('Store Dataset')
    print(store_df.head())
    print(store_df.dtypes)

    return features_df, sales_df, store_df
