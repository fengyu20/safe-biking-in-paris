import logging
import os
from typing import Optional, Dict, Any, List
import pandas as pd
from pathlib import Path

class DataLoader:
    def __init__(self, project: str = None):
        self.project = project or os.getenv('BIGQUERY_PROJECT', 'biking-in-paris')
        
    def load_from_bigquery(self, dataset: str = None, table: str = None) -> pd.DataFrame:
        try:
            from google.cloud import bigquery
        except ImportError:
            raise ImportError("google-cloud-bigquery is required for BigQuery access. Install with: pip install google-cloud-bigquery")
        
        dataset = dataset or os.getenv('BIGQUERY_DATASET', 'accidents')
        table = table or os.getenv('BIGQUERY_TABLE', 'fct_accidents_hr')
        
        client = bigquery.Client(project=self.project)
        
        # Focus on target vehicle types: 1 (Bicycle), 50 (E-personal transport motorized), 80 (E-bicycle)
        # Can filter by year if needed
        query = f"""
        SELECT *,
               -- Add geographic scope categorization
               CASE 
                 WHEN department = '75' THEN 'Paris'
                 WHEN department IN ('75', '77', '78', '91', '92', '93', '94', '95') THEN 'Île-de-France'
                 ELSE 'Other France'
               END as geographic_scope
        FROM `{self.project}.{dataset}.{table}`
        WHERE vehicle_category_cd IN (1, 50, 80)
        """
        
        print(f"Loading data from BigQuery: {self.project}.{dataset}.{table}")
        print("Filtering for vehicle types: 1 (Bicycle), 50 (E-personal transport motorized), 80 (E-bicycle)")
        df = client.query(query).to_dataframe()
        print(f"Loaded {len(df):,} records from BigQuery")
        return df

    def load_from_csv(self, file_path: str) -> pd.DataFrame:
        """Load data from CSV file"""
        if not file_path.endswith('.csv'):
            raise ValueError("Only CSV files are supported")
        
        df = pd.read_csv(file_path)
        print(f"Loaded {len(df):,} records from {file_path}")
        return df