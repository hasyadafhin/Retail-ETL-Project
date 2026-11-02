
import os
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

# Membaca file .env dari folder utama Retail_Project
env_path = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(dotenv_path=env_path)

def load_data(dim_date, dim_store, dim_feature, fact_sales):

    # Konfigurasi PostgreSQL dari .env
    db_name = os.getenv("DB_NAME")
    db_host = os.getenv("DB_HOST")
    db_port = os.getenv("DB_PORT")
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")

    # Validasi konfigurasi
    if not all([db_name, db_host, db_port, db_user, db_password]):
        raise ValueError("Konfigurasi database di .env belum lengkap.")

    # Membuat koneksi PostgreSQL
    db_url = URL.create(
        drivername="postgresql+psycopg",
        username=db_user,
        password=db_password,
        host=db_host,
        port=int(db_port),
        database=db_name
    )

    engine = create_engine(db_url)

    # Load dim_store
    dim_store.to_sql(
        'dim_store',
        engine,
        schema='public',
        if_exists='replace',
        index=False
    )

    # Load dim_date
    dim_date.to_sql(
        'dim_date',
        engine,
        schema='public',
        if_exists='replace',
        index=False
    )

    # Load dim_feature
    dim_feature.to_sql(
        'dim_feature',
        engine,
        schema='public',
        if_exists='replace',
        index=False
    )

    # Load fact_sales
    fact_sales.to_sql(
        'fact_sales',
        engine,
        schema='public',
        if_exists='replace',
        index=False
    )

    engine.dispose()

    print("Data loaded successfully into PostgreSQL database.")
