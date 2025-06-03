variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "europe-west1"  # Region near Paris
}

variable "zone" {
  description = "The GCP zone within the region"
  type        = string
  default     = "europe-west1-b"
}

variable "bucket_name" {
  description = "Name of the GCS bucket for storing bike accident data"
  type        = string
  default     = "biking-in-paris-bucket"
}

variable "dataset_id" {
  description = "ID for the BigQuery dataset"
  type        = string
  default     = "biking-in-paris"
}