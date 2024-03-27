import pandas as pd
import pyarrow as pa
# import pyarrow
# from sqlalchemy import create_engine
import boto3

s3_resource = boto3.resource('s3')
processed_bucket = s3_resource.Bucket(name="processed_data_bucket")
data = pd.DataFrame(processed_bucket)

data_table = pa.Table.from_pandas(data)

# parquet_file = include potential parquet file name

# Read parquet file

# Connect to the db using sqlalchemy engine

# to_sql method to send dataframe parquet to db

# Turn off connection

processed_bucket = s3_resource.Bucket(name='processed-data-bucket')
df = pd.DataFrame(processed_bucket)
