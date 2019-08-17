#!/usr/bin/env python3
"""data.py

This module is used to bootstrap tables in a BigQuery database.

Example:
    $ python data.py
"""

import os
import sys
import logging

import pandas as pd
from pandas_gbq import to_gbq
from google.cloud import bigquery
from google.oauth2 import service_account

import utils.config as config
import utils.data_prep as data_prep

DATA_CONFIG = config.get_config('data')
BQ_CONFIG = config.get_config('bigquery')
CREDENTIALS_CONFIG = config.get_config('credentials')

DATA_DIR = DATA_CONFIG['dir']
SERVICE_ACCOUNT_PATH = os.path.join('./credentials', CREDENTIALS_CONFIG['bigquery'])
CLIENT = bigquery.Client.from_service_account_json(SERVICE_ACCOUNT_PATH)
BQ_CREDENTIALS = service_account.Credentials.from_service_account_file(
    SERVICE_ACCOUNT_PATH
)

logger = logging.getLogger('pandas_gbq')
logger.setLevel(logging.INFO)
logger.addHandler(logging.StreamHandler(stream=sys.stdout))

def _get_data(csv_path):
    _df = pd.DataFrame()

    if isinstance(csv_path, list):
        print('Loading data from {}'.format(', '.join(csv_path)))
        _df = pd.concat([pd.read_csv(os.path.join(DATA_DIR, path)) for path in csv_path],
                        ignore_index=True)
    else:
        print('Loading data from {}'.format(csv_path))
        _df = pd.read_csv(os.path.join(DATA_DIR, csv_path))

    return _df

def _to_bq(data, project_id, dataset_id, table_id):
    _dataset_ref = CLIENT.dataset(dataset_id)

    _tables = list(CLIENT.list_tables(_dataset_ref))
    _table_ids = [item.table_id for item in _tables]

    assert table_id in _table_ids, 'table_id must already exist to add data'

    _table_name = dataset_id + '.' + table_id

    print('Writing to {}.'.format(_table_name))
    data.to_gbq(
        project_id=project_id,
        destination_table=_table_name,
        if_exists='replace',
        credentials=BQ_CREDENTIALS
    )

def main():
    """Main"""

    print('LOADING DATA')
    df_drafts = data_prep.prep_drafts(_get_data(DATA_CONFIG['drafts_path']))
    df_leagues = data_prep.prep_leagues(_get_data(DATA_CONFIG['leagues_path']))
    df_players = _get_data(DATA_CONFIG['players_path'])
    df_results = data_prep.prep_results(_get_data(DATA_CONFIG['results_path']))
    df_ranks = _get_data(DATA_CONFIG['ranks_path'])

    print('WRITING DATA TO BIGQUERY')
    _to_bq(df_drafts, BQ_CONFIG['project_id'], BQ_CONFIG['dataset_id'], 'drafts')
    _to_bq(df_leagues, BQ_CONFIG['project_id'], BQ_CONFIG['dataset_id'], 'leagues')
    _to_bq(df_players, BQ_CONFIG['project_id'], BQ_CONFIG['dataset_id'], 'players')
    _to_bq(df_results, BQ_CONFIG['project_id'], BQ_CONFIG['dataset_id'], 'results')
    _to_bq(df_ranks, BQ_CONFIG['project_id'], BQ_CONFIG['dataset_id'], 'ranks')

if __name__ == "__main__":
    main()
