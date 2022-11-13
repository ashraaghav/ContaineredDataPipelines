import argparse
import atexit
import json

import pandas as pd
from pymongo import MongoClient
from sqlalchemy import create_engine

import queries as q


def get_connection_strings(pg_host, mongo_host):
    """
    Helper function to generate database connection strings
    TODO: they should not be in git!
    """
    pg_db_uri = f"postgresql+psycopg2://analyst:ana_pass1@{pg_host}:5432/datastore"
    mongo_uri = f"mongodb://analyst:ana_pass1@{mongo_host}:27017/datastore"
    mongo_db = "datastore"
    return pg_db_uri, mongo_uri, mongo_db


class Executor:
    def __init__(self, pg_uri, mongo_uri, mongo_dbname):
        # create database engine
        self.pg_engine = create_engine(pg_uri, echo=False)
        self.pg_conn = self.pg_engine.connect()
        # create mongo client
        self.mn_client = MongoClient(mongo_uri)
        self.mn_conn = self.mn_client[mongo_dbname]

        # close connections gracefully at exit
        atexit.register(self.close)

    def close(self):
        print('closing connections...')
        self.pg_conn.close()
        self.mn_client.close()

    def execute_query(self, pg_query, collection):
        # read query
        table = pd.read_sql(pg_query, self.pg_conn)
        # convert to JSON document
        doc = table.to_dict(orient='records')
        # create a collection for the KPI and add document
        mn_col = self.mn_conn[collection]
        mn_col.insert_many(doc)
        print(f'successfully inserted to {collection}')

def main():
    parser = argparse.ArgumentParser('KPI Estimator')
    parser.add_argument('--config', type=str, help='Path to file containing the database URIs', required=True)
    args = parser.parse_args()

    with open(args.config, 'r') as f:
        config = json.load(f)

    # get connection strings
    pg_db_uri, mongo_uri, mongo_db = get_connection_strings(config['PG_HOST'], config['MONGO_HOST'])

    # initialize executor
    executor = Executor(pg_uri=pg_db_uri,
                        mongo_uri=mongo_uri,
                        mongo_dbname=mongo_db)

    # compute KPIs and store in Mongo DB
    executor.execute_query(q.query_brand_rank(), 'kpi_brand_rank')
    executor.execute_query(q.query_min_max_hdd(), 'kpi_min_max_hdd')
    executor.execute_query(q.query_median_ghz(), 'kpi_median_ghz_per_ramgb')


if __name__ == '__main__':
    main()
