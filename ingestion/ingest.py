#!/usr/bin/env python3
import os
import sys
import yaml
import requests
from google.cloud import storage

def load_manifest(path: str) -> dict:
    with open(path, 'r') as f:
        return yaml.safe_load(f)

def upload_csvs(manifest: dict, bucket_name: str, prefix: str = ""):
    client = storage.Client()
    bucket = client.bucket(bucket_name)

    for year, datasets in manifest.get('years', {}).items():
        for name, url in datasets.items():
            target_path = f"{prefix.rstrip('/')}/{year}/{name}.csv"
            print(f"[{year}][{name}] → downloading {url}")
            resp = requests.get(url, stream=True)
            if resp.status_code != 200:
                print(f"  ! failed to download ({resp.status_code})", file=sys.stderr)
                continue

            blob = bucket.blob(target_path.lstrip('/'))
            blob.upload_from_file(resp.raw)
            print(f"  ✓ uploaded to gs://{bucket_name}/{target_path}")

def main():
    manifest_path = os.getenv('MANIFEST_PATH', 'ingest_manifest.yaml')
    bucket_name   = os.getenv('BUCKET')
    prefix        = os.getenv('PREFIX', 'data/raw')

    if not bucket_name:
        print("ERROR: set BUCKET env var to your GCS bucket name", file=sys.stderr)
        sys.exit(1)

    manifest = load_manifest(manifest_path)
    upload_csvs(manifest, bucket_name, prefix)

if __name__ == '__main__':
    main()