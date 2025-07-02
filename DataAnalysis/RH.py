import subprocess
import time
import json
from datetime import datetime, timezone

def get_k8s_events(namespace):
    """
    Fetch Kubernetes events for a namespace and return them as JSON.
    """
    result = subprocess.run(
        ["kubectl", "get", "events", "-n", namespace, "-o", "json"],
        capture_output=True, text=True
    )
    return json.loads(result.stdout)

def find_rehealing_timestamps(events, new_pod_name):
    """
    Find timestamps for new pod lifecycle events by matching the new pod name.
    """
    running_time = None

    for event in events['items']:
        involved_object = event['involvedObject']
        if involved_object['name'] == new_pod_name:  # Match exact new pod name
            if event['reason'] == "Started":
                running_time = event['lastTimestamp']

    return running_time

def calculate_time_difference(start, end):
    """
    Calculate time difference between two ISO timestamps.
    """
    start_dt = datetime.fromisoformat(start.replace("Z", "+00:00")).replace(tzinfo=timezone.utc)
    end_dt = datetime.fromisoformat(end.replace("Z", "+00:00")).replace(tzinfo=timezone.utc)
    return (end_dt - start_dt).total_seconds()

if __name__ == "__main__":
    namespace = "ros"  # Replace with your namespace
    pod_prefix = "ros-"  # Replace with your pod's name prefix

    # Step 1: Get the current pod name dynamically
    print("Fetching current pod information...")
    result = subprocess.run(
        ["kubectl", "get", "pods", "-n", namespace, "-o", "json"],
        capture_output=True, text=True
    )
    pods = json.loads(result.stdout)['items']
    if not pods:
        print(f"No pods found with prefix {pod_prefix} in namespace {namespace}.")
        exit(1)

    current_pod_name = next((pod['metadata']['name'] for pod in pods if pod['metadata']['name'].startswith(pod_prefix)), None)

    if not current_pod_name:
        print(f"Pod with prefix {pod_prefix} not found in namespace {namespace}.")
        exit(1)

    print(f"Found current pod: {current_pod_name}")

    # Step 2: Delete the pod
    print("Deleting current pod...")
    delete_time = datetime.now(timezone.utc).isoformat()  # Record deletion time
    subprocess.run(["kubectl", "delete", "pod", current_pod_name, "-n", namespace])
    time.sleep(5)  # Allow time for Kubernetes to generate a new pod

    # Step 3: Fetch new pod information
    print("Fetching new pod information...")
    new_pod_name = None
    while not new_pod_name:
        result = subprocess.run(
            ["kubectl", "get", "pods", "-n", namespace, "-o", "json"],
            capture_output=True, text=True
        )
        pods = json.loads(result.stdout)['items']
        new_pod_name = next((pod['metadata']['name'] for pod in pods if pod['metadata']['name'].startswith(pod_prefix) and pod['metadata']['name'] != current_pod_name), None)
        time.sleep(1)

    print(f"New pod created: {new_pod_name}")

    # Step 4: Fetch events and find new pod Running timestamp
    print("Fetching Kubernetes events...")
    events = get_k8s_events(namespace)
    running_time = find_rehealing_timestamps(events, new_pod_name)

    if running_time:
        # Step 5: Calculate rehealing time
        rehealing_time = calculate_time_difference(delete_time, running_time)
        print(f"Pod rehealing time: {rehealing_time:.2f} seconds")
    else:
        print("Could not find required events for the new pod. Ensure the pod is being recreated correctly.")
