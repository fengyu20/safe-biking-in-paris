#!/bin/bash

set -e  

echo "Cleaning dbt artifacts..."
rm -rf target/ dbt_packages/
echo "   Removed target/ and dbt_packages/ directories"

echo "Installing package dependencies..."
dbt deps --profiles-dir . --project-dir .

echo "Building all models and running tests..."
dbt build --profiles-dir . --project-dir .
