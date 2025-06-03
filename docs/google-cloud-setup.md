# Google Cloud Setup Guide


## Prerequisites

- A Google account
- Access to [Google Cloud Console](https://console.cloud.google.com/)

## Step 1: Create a New Google Cloud Project

First, you'll need to create a new Google Cloud project or use an existing one.

![Create New Project](img/1.%20new_project.png)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click on the project dropdown at the top
3. Click "New Project"
4. Enter the project name: `safe-biking-paris`
5. Click "Create"

## Step 2: Navigate to Service Accounts

Once your project is created, you need to set up a service account for authentication.

![Service Accounts](img/2.%20service_accounts.png)

1. In the Google Cloud Console, open the navigation menu (☰)
2. Go to **IAM & Admin** → **Service Accounts**
3. Make sure you're in the correct project (check the project name at the top)

## Step 3: Create a New Service Account

![New Service Account](img/3.%20new_service_account.png)

1. Click the **"+ CREATE SERVICE ACCOUNT"** button
2. This will open the service account creation form

## Step 4: Fill in Service Account Details

![Service Account Creation Form](img/4.%20new_service_account_creation.png)

1. **Service account name**: Enter a descriptive name (e.g., "safe-biking-data-pipeline")
2. **Service account ID**: This will be auto-generated based on the name
3. **Description**: Add a description like "Service account for Safe Biking in Paris data pipeline"
4. Click **"CREATE AND CONTINUE"**

## Step 5: Configure Service Account Permissions

![Manage Permissions](img/5.%20manage%20permissions.png)

You need to grant the following roles to your service account:

### Required Roles:
1. **BigQuery Admin** - For creating and managing BigQuery datasets and tables
2. **Storage Admin** - For creating and managing Cloud Storage buckets
3. **Storage Object Admin** - For uploading and managing files in storage buckets

### How to add roles:
1. In the "Grant this service account access to project" section
2. Click "Select a role" dropdown
3. Search for and select each required role:
   - `BigQuery Admin`
   - `Storage Admin` 
   - `Storage Object Admin`
4. Click **"CONTINUE"**
5. Skip the "Grant users access to this service account" section (optional)
6. Click **"DONE"**

## Step 6: View Service Account in IAM

![Service Account IAM](img/6.%20service_account_iam.png)

After creation, you should see your service account listed in the IAM section with the assigned roles. Verify that all the necessary permissions are correctly assigned.

## Step 7: Create and Download Service Account Key

![Create New Key](img/7.%20create_new_key.png)

Now you need to create a JSON key file for authentication:

1. Find your service account in the list
2. Click on the service account email to open its details
3. Go to the **"Keys"** tab
4. Click **"ADD KEY"** → **"Create new key"**
5. Select **"JSON"** as the key type
6. Click **"CREATE"**

## Step 8: Save the Downloaded Credentials

![Downloaded Key](img/8.%20downloaded_key.png)

1. The JSON key file will automatically download to your computer
2. **Important**: Rename this file to `credentials.json`
3. Move the file to your project root directory (same level as `docker-compose.yml`)
4. **Security Note**: Never commit this file to git! It's already in `.gitignore`

## Step 9: Enable Required APIs

Before running the project, make sure these APIs are enabled:

1. Go to **APIs & Services** → **Library**
2. Search for and enable:
   - **BigQuery API**
   - **Cloud Storage API**
   - **Cloud Resource Manager API**