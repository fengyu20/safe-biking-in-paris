# Basic Info 
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Create the Google Cloud Storage Bucket

resource "google_storage_bucket" "biking-in-paris-bucket" {
  name     = var.bucket_name
  location = var.region
  force_destroy = true
}

# Create the Google Big Query Dataset
resource "google_bigquery_dataset" "accidents" {
  dataset_id                  = var.dataset_id
  location                    = var.region
}

# Output the bucket name and dataset ID for reference
output "bucket_name" {
  value = google_storage_bucket.biking-in-paris-bucket.name
}

output "dataset_id" {
  value = google_bigquery_dataset.accidents.dataset_id
}
