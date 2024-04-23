import json
import pandas as pd
from IPython.display import display
import os
from pandas import json_normalize

def read_json(file_path):
    with open(file_path, 'rt', encoding='utf-8') as file:
        data = json.load(file)

    print()
    # display(data)
    print("--- keys ---------------------------------------")
    display(data[0].keys())
    print("--- Metric Keys----------------------------------")
    display(data[0]['metric'].keys())
    df = json_normalize(data)
    print("\n\n")
    print("-+-" * 10)
    print("\nUnique values in each column except values columns:\n")
    for col in df.drop(columns=['values']).columns:
        print()
        print(f"{col}: {df[col].unique()}")
        print()
    print("=*=" * 10)
    display(df)
    print("\n\n")




def filter_filenames(path, substrings, and_or):
    # Normalize substrings to lower case for case-insensitive comparison
    substrings = [s.lower() for s in substrings]
    
    # Initialize list to hold matching filenames
    matching_files = []
    
    # Walk through the directory
    try:
        # List all files in the directory
        files = os.listdir(path)
    except Exception as e:
        print(f"Error accessing directory: {e}")
        return []
    
    # Check each file in the directory
    for file in files:
        # Convert filename to lower case
        file_lower = file.lower()
        
        # Check if 'and' or 'or' conditions are met
        if and_or == 'and':
            # Check if all substrings are in the filename
            if all(sub in file_lower for sub in substrings):
                matching_files.append(file)
        elif and_or == 'or':
            # Check if any substring is in the filename
            if any(sub in file_lower for sub in substrings):
                matching_files.append(file)

    return matching_files


def get_filename_and_root_path(file_path):
    # Extract the file name from the path
    file_name = os.path.basename(file_path)
    # Extract the directory (root path) from the path
    root_path = os.path.dirname(file_path)
    return file_name, root_path


def json_2_pandas(json_file_path):
    with open(json_file_path, 'rt', encoding='utf-8') as file:
        data = json.load(file)
    df = json_normalize(data)
    file_name, root_path = get_filename_and_root_path(json_file_path)
    csv_file_path = os.path.join(root_path+"/csv/",file_name.replace('.json', '.csv'))
    if not os.path.exists(os.path.dirname(root_path+"/csv/")):
        os.makedirs(os.path.dirname(root_path+"/csv/"))
    df.to_csv(csv_file_path)