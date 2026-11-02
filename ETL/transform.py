
import pandas as pd

def transform_data(features_df, sales_df, store_df):

    # 1. Konversi tanggal
    features_df['Date'] = pd.to_datetime(
        features_df['Date'],
        format='%Y-%m-%d'
    )

    sales_df['Date'] = pd.to_datetime(
        sales_df['Date'],
        format='%d/%m/%Y'
    )

    # 2. Menghapus kolom Markdown
    markdown_colms = [
        'MarkDown1',
        'MarkDown2',
        'MarkDown3',
        'MarkDown4',
        'MarkDown5'
    ]

    features_df = features_df.drop(
        columns=markdown_colms,
        errors='ignore'
    )

    # 3. Membuat dimensi Store
    dim_store = store_df.drop_duplicates().reset_index(drop=True)

    # 4. Membuat dimensi Date
    dim_date = sales_df[
        ['Date', 'IsHoliday']
    ].drop_duplicates().copy()

    dim_date['year'] = dim_date['Date'].dt.year
    dim_date['month'] = dim_date['Date'].dt.month
    dim_date['week'] = (
        dim_date['Date'].dt.isocalendar().week.astype(int)
    )

    # 5. Membuat dimensi Feature
    dim_feature = features_df.drop_duplicates().reset_index(drop=True)

    # 6. Membuat Fact Sales
    fact_sales = sales_df.copy()

    # 7. Normalisasi nama kolom
    def normalize(df):
        df.columns = (
            df.columns.str.lower()
            .str.replace(' ', '_')
        )
        return df

    dim_date = normalize(dim_date)
    dim_store = normalize(dim_store)
    dim_feature = normalize(dim_feature)
    fact_sales = normalize(fact_sales)

    # 8. Mengembalikan hasil transformasi
    return fact_sales, dim_date, dim_feature, dim_store

        


 

    #