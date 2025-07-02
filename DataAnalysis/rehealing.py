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

def find_event_timestamps(events, pod_name):
    """
    Find timestamps for pod lifecycle events by matching pod name exactly.
    """
    killing_time = None
    running_time = None

    for event in events['items']:
        involved_object = event['involvedObject']
        if involved_object['name'] == pod_name:  # Match by exact pod name
            
            if event['reason'] == "Killing":
                killing_time = event['lastTimestamp']
                print("\n\n 1==> ", event)

            if event['reason'] == "Started":
                running_time = event['lastTimestamp']
                print("\n\n 2==> ", event)

    return killing_time, running_time

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

    # Step 1: Get the exact pod name dynamically
    print("Fetching pod information...")
    result = subprocess.run(
        ["kubectl", "get", "pods", "-n", namespace, "-o", "json"],
        capture_output=True, text=True
    )
    pods = json.loads(result.stdout)['items']
    if not pods:
        print(f"No pods found with prefix {pod_prefix} in namespace {namespace}.")
        exit(1)

    pod_name = next((pod['metadata']['name'] for pod in pods if pod['metadata']['name'].startswith(pod_prefix)), None)

    if not pod_name:
        print(f"Pod with prefix {pod_prefix} not found in namespace {namespace}.")
        exit(1)

    print(f"Found pod: {pod_name}")

    # Step 2: Delete the pod
    print("Deleting pod...")
    subprocess.run(["kubectl", "delete", "pod", pod_name, "-n", namespace])
    time.sleep(3)  # Allow time for Kubernetes to generate events

    # Step 3: Fetch events and find timestamps
    print("Fetching Kubernetes events...")
    events = get_k8s_events(namespace)
    killing_time, running_time = find_event_timestamps(events, pod_name)

    if killing_time and running_time:
        # Step 4: Calculate recreation time
        recreation_time = calculate_time_difference(killing_time, running_time)
        print(f"Pod recreation time: {recreation_time:.2f} seconds")
    else:
        print("Could not find required events. Ensure the pod is recreated correctly.")
