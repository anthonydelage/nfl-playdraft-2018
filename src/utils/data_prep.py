#!/usr/bin/env python3
"""data_prep.py

    This module provides utility functions to prepare data before committing it to
        the `playdraft` database.
"""

import pandas as pd

DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S.%f'

def prep_drafts(data):
    """Prepare a Drafts DataFrame

    Transforms the Drafts data to suit the `drafts` table schema.

    Args:
        data (DataFrame): A DataFrame to prepare.
    """

    data['id'] = data['draft_id'].astype(str) + '.' \
                 + data['team_id'].astype(str) + '.' \
                 + data['player_id'].astype(str)

    data['pick_time'] = pd.to_datetime(
        data['pick_time'],
        infer_datetime_format=True,
        format=DATETIME_FORMAT,
        errors='coerce'
    )

    return data

def prep_leagues(data):
    """Prepare a Leagues DataFrame

    Transforms the Leagues data to suit the `leagues` table schema.

    Args:
        data (DataFrame): A DataFrame to prepare.
    """

    data['draft_tm'] = pd.to_datetime(
        data['draft_tm'],
        infer_datetime_format=True,
        format=DATETIME_FORMAT,
        errors='coerce'
    )

    return data


def prep_results(data):
    """Prepare a Results DataFrame

    Transforms the Results data to suit the `results` table schema.

    Args:
        data (DataFrame): A DataFrame to prepare.
    """

    data['id'] = data['year'].astype(str) + '.' \
                 + data['week'].astype(str) + '.' \
                 + data['player_id'].astype(str)

    return data
