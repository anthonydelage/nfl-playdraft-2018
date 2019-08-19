# nfl-playdraft-2018

A project that analyzes DRAFT's 2018 Best Ball data using Google BigQuery and Jupyter Notebooks. The data is open-source and can be downloaded [here](https://drive.google.com/drive/folders/1N4-Gyxpd3xwnQEXWT2Ri3vzz-GwoxhjS).

A [similar project](https://github.com/anthonydelage/nfl-playdraft-2017) analyzes DRAFT's 2017 data.

Two main components are included:

- Tooling to load the data into Google BigQuery (assuming local CSVs have already been downloaded from the listed source)
- Jupyter notebooks that analyze the data

## Loading the data

To load the data into BigQuery, follow these steps:

1. Download the data from the DRAFT Google Drive ([here](https://drive.google.com/drive/folders/1N4-Gyxpd3xwnQEXWT2Ri3vzz-GwoxhjS)).
2. Place it in a `./data` directory.
3. Ensure that the filenames in `config.yaml`'s `draft` key match those in the local directory.

```yaml
data:
  dir: ./data
  drafts_path:
    - draft_1_2018.csv
    - draft_2_2018.csv
  leagues_path: leagues_2018.csv
  players_path: players_2018.csv
  results_path: weekly_results_2018.csv
  ranks_path: ranks_2018.csv
```

4. Set up an empty project and dataset in Google BigQuery.
5. Update the `project_id` and `dataset_id` fields in `config.yaml`'s `bigquery` key to match the empty project and dataset that were created.

```yaml
bigquery:
  project_id: ad-fantasy-football
  dataset_id: playdraft_2018
  schemas: ...
```

6. Download a JSON service account keyfile with "BigQuery Admin" rights and place it in the `./credentials` directory. Ensure that the `credentials` path in `config.yaml` is correct:

```yaml
credentials:
  bigquery: bigquery-loader.json
```

7. Set up the local virtual environment using `make venv`.
8. Initialize tables in BigQuery using `make tables`.
9. Populate the tables in BigQuery using `make data`.
