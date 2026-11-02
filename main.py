from ETL.extract import extract_data
from ETL.transform import transform_data
from ETL.load import load_data

def run_pipeline():
    print("Starting ETL pipeline...")

    features_df, sales_df, store_df = extract_data()

    fact_sales, dim_date, dim_feature, dim_store = transform_data(
        features_df, sales_df, store_df
    )

    load_data(
        dim_date,
        dim_store,
        dim_feature,
        fact_sales
    )

    print("ETL pipeline completed successfully.")


if __name__ == "__main__":
    run_pipeline()
