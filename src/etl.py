import os
import pandas as pd
from datetime import datetime

DATA_DIR = os.getenv("DATA_DIR", "./data")
CLEAN_DIR = os.getenv("CLEAN_DIR", "./clean")
REJECTED_DIR = os.getenv("REJECTED_DIR", "./rejected")
LOGS_DIR = "./logs"

os.makedirs(CLEAN_DIR, exist_ok=True)
os.makedirs(REJECTED_DIR, exist_ok=True)
os.makedirs(LOGS_DIR, exist_ok=True)

def run_etl():
    start_time = datetime.now()
    log_messages = [f"ETL Run Started at: {start_time}"]
    print(f"--- Starting PulseIQ ETL Pipeline ---")

    wos_path = os.path.join(DATA_DIR, "01_LedgerForge_Python_Master_Dataset.xlsx")

    print("Extracting sheets from workbook...")
    try:
        df_employees = pd.read_excel(wos_path, sheet_name="employees")
    except Exception as e:
        print(f"Error reading source files: {e}")
        return

    log_messages.append(f"Extracted 'employees': {len(df_employees)} rows")

    # Use the correct column name found in the dataset
    join_col = 'hire_date'
    exit_col = 'exit_date'

    print(f"Transforming and validating employee data using '{join_col}'...")
    df_employees[join_col] = pd.to_datetime(df_employees[join_col], errors='coerce')
    df_employees[exit_col] = pd.to_datetime(df_employees[exit_col], errors='coerce')

    # Rule: Joining date after leaving date -> Reject
    invalid_dates_mask = df_employees[exit_col].notna() & (df_employees[join_col] > df_employees[exit_col])
    
    df_rejected = df_employees[invalid_dates_mask].copy()
    df_rejected['rejection_reason'] = "dates out of order"
    
    df_clean = df_employees[~invalid_dates_mask].copy()

    reference_date = pd.to_datetime("2026-09-30")
    df_clean['tenure_days'] = (df_clean[exit_col].fillna(reference_date) - df_clean[join_col]).dt.days
    df_clean['join_year'] = df_clean[join_col].dt.year
    df_clean['join_month'] = df_clean[join_col].dt.month
        # Rule: duplicate employee_id -> reject every copy after the first
    dup_mask = df_clean.duplicated(subset=['employee_id'], keep='first')
    df_dups = df_clean[dup_mask].copy()
    df_dups['rejection_reason'] = "duplicate employee_id"
    df_rejected = pd.concat([df_rejected, df_dups])
    df_clean = df_clean[~dup_mask]

    clean_file_path = os.path.join(CLEAN_DIR, "employees_clean.csv")
    rejected_file_path = os.path.join(REJECTED_DIR, "employees_rejected.csv")

    df_clean.to_csv(clean_file_path, index=False)
    df_rejected.to_csv(rejected_file_path, index=False)

    end_time = datetime.now()
    summary = (
        f"\n--- ETL Completed Successfully ---\n"
        f"Start Time: {start_time}\n"
        f"End Time: {end_time}\n"
        f"Rows In (Employees): {len(df_employees)}\n"
        f"Rows Out (Clean): {len(df_clean)}\n"
        f"Rows Rejected: {len(df_rejected)}\n"
    )
    print(summary)
    log_messages.append(summary)

    with open(os.path.join(LOGS_DIR, "etl_run.log"), "w") as log_file:
        log_file.write("\n".join(log_messages))

if __name__ == "__main__":
    run_etl()