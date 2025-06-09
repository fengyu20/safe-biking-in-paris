import logging
import os
from typing import Optional, Dict, Any, List
import pandas as pd
from pathlib import Path

class DataLoader:
    def __init__(self, project: str = None, custom_query: str = None, target_table: str = None):
        self.project = project or os.getenv('BIGQUERY_PROJECT', 'biking-in-paris')
        self.custom_query = custom_query
        self.target_table = target_table
        
    def load_from_bigquery(self, dataset: str = None, table: str = None) -> pd.DataFrame:
        try:
            from google.cloud import bigquery
        except ImportError:
            raise ImportError("google-cloud-bigquery is required for BigQuery access. Install with: pip install google-cloud-bigquery")
        
        client = bigquery.Client(project=self.project)
        
        # Use custom query if provided, otherwise build default query
        if self.custom_query:
            print(f"Loading data using custom query...")
            df = client.query(self.custom_query).to_dataframe()
        else:
            # Fallback to default table query
            dataset = dataset or os.getenv('BIGQUERY_DATASET', 'accidents')
            table = table or os.getenv('BIGQUERY_TABLE', 'fct_accidents_hr')
            table_ref = f"{self.project}.{dataset}.{table}"
            print(f"Loading data from BigQuery: {table_ref}")
            df = client.query(f"SELECT * FROM `{table_ref}`").to_dataframe()
        
        print(f"Loaded {len(df):,} records from BigQuery")
        return df

    def load_from_csv(self, file_path: str) -> pd.DataFrame:
        """Load data from CSV file"""
        if not file_path.endswith('.csv'):
            raise ValueError("Only CSV files are supported")
        
        df = pd.read_csv(file_path)
        print(f"Loaded {len(df):,} records from {file_path}")
        return df