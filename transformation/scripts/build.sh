#!/bin/bash

set -e  

echo "Cleaning dbt artifacts..."
rm -rf target/ logs/
echo "   Removed target/ and logs/ directories"

echo "Installing package dependencies..."
dbt deps --profiles-dir . --project-dir .

echo "Testing connection..."
dbt debug --profiles-dir . --project-dir .

echo "Building all models and running tests..."
dbt build --profiles-dir . --project-dir .
