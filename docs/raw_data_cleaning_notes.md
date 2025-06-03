
1. **File Names Inconsistent:**

   * **Description:**

     * When trying to parse the files using regex (caract\*), I noticed there is missing data for 2021 and 2022.
     * After checking, it turned out the original names have typos. They are named `carcteristiques-2021.csv` and `carcteristiques-2022.csv`, which contain spelling errors.
   * **Solution:**

     * Use a more universal regex to capture 2021/2022 files: `car*`.
     * Plan to report this issue on the data website.

2. **Data Quality:**

   * **Description:**

     * When trying to display the data from CSV, errors occur.
     * BigQuery automatically detects the column type (e.g., latitude as float).
     * However, the original data files contain errors—there is a letter in that column.
   * **Solution:**

     * When loading the data, load them as strings to avoid failures.
     * Write custom functions to handle integer and float columns.

3. **dbt Macro:**

   * **Description:**

     * It provides a convenient way to do repetitive tasks (e.g., dealing with strings in integer columns).
     * However, it can fail to capture relevant info. For example, in the `usagers` table, the `id_usager` appears as `"203 851 184"`.
     * If we treat it as an integer, it becomes null.
   * **Solution:**

     * Carefully examine the original column and find a proper way to clean the data.
     * Update the dbt macro when needed.

4. **dbt Cloud & dbt Core Configuration Priority:**

   * **Description:**

     * dbt Cloud is the commercial version with a UI; dbt Core is free and interacts via CLI.
     * In dbt Cloud, you define the BigQuery dataset in the settings (through the UI).
     * In dbt Core, you define the BigQuery dataset in `profiles.yml` and `dbt_project.yml`.
   * **Solution:**

     * Only use dbt Core: make sure the project name and profile name defined in `dbt_project.yml` are consistent with `profiles.yml`; otherwise, it will fail to compile.
     * When using dbt Core and dbt Cloud at the same time, ensure you have configured settings for the correct dataset name. It can happen that you use the right dataset name in `dbt_project.yml` and `profiles.yml` but fail to define it in the cloud.
     * Debug command: `dbt debug`—you will get the configuration path and find whether you configured the correct file.