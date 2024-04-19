from prometheus_api_client import PrometheusConnect
# prom = PrometheusConnect(url ="http://localhost:9090", disable_ssl=True)
prom = PrometheusConnect(url ="http://192.168.56.10:30090", disable_ssl=True)
import datetime
from datetime import datetime, timedelta  
import pandas as pd


# Instant Query
result = prom.custom_query(query="up")
# print(result)
# Range Query
result_range = prom.custom_query_range(
    query="up",
    start_time= datetime.now() - timedelta(hours=2),
    end_time=datetime.now(),
    step='15s'
)

result_range = prom.custom_query_range(
    query='100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)',
    start_time=datetime.now() - timedelta(hours=2),
    end_time=datetime.now(),
    step='15s'
)
print(result_range)

# Creating a list to hold data for DataFrame
data = []
for result in result_range:
    for value in result['values']:
        timestamp = value[0]
        metric_value = value[1]
        metric_info = result['metric']
        data.append({**metric_info, 'timestamp': datetime.fromtimestamp(float(timestamp)), 'value': metric_value})

# Convert list to DataFrame
df = pd.DataFrame(data)

# Save to CSV
df.to_csv('prometheus_data.csv', index=False)

# Optional: Save to other formats
# Save to Excel
# df.to_excel('prometheus_data.xlsx', index=False)


# Display the DataFrame
# print(df.head())
