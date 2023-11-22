#!/bin/bash
ST_NAME=$1
ST_NAMESPACE=$2

running=$(kubectl describe statefulset $ST_NAME -n $ST_NAMESPACE | grep 'Pods Status:' | awk -F':' '{print $2}' | awk '{print $1}')
waiting=$(kubectl describe statefulset $ST_NAME -n $ST_NAMESPACE | grep 'Pods Status:' | awk -F'/' '{print $2}' | awk '{print $1}')
success=$(kubectl describe statefulset $ST_NAME -n $ST_NAMESPACE | grep 'Pods Status:' | awk -F'/' '{print $3}' | awk '{print $1}')
failed=$(kubectl describe statefulset $ST_NAME -n $ST_NAMESPACE | grep 'Pods Status:' | awk -F'/' '{print $4}' | awk '{print $1}')

if [ "$running" -ne 0 ] && [ "$waiting" -eq 0 ] && [ "$success" -eq 0 ] && [ "$failed" -eq 0 ]; then
	echo "status is ok"
else
	echo "status is not ok"
	#exit 1
fi

date_time_orig=$(kubectl describe statefulset $ST_NAME -n $ST_NAMESPACE | grep 'CreationTimestamp' | awk -F ',' '{print $2}')
date_time=$(echo "$date_time_orig" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
formatted_date=$(date -d "$date_time" "+%Y-%m-%d %H:%M:%S %z")
current_time=$(date +%s)
formatted_timestamp=$(date -d "$formatted_date" +%s)
time_diff=$((current_time - formatted_timestamp))
echo $time_diff

if [ "$time_diff" -gt 600 ]; then
	echo "deployment date is too old for new deployment"
	#exit 1
fi

# Extract the "AGE" field from the kubectl output
age=$(kubectl get pods -n $ST_NAMESPACE | grep $ST_NAME | awk '{print $5}')

# Parse the "AGE" field and calculate the equivalent time in seconds
time_in_seconds=0
while IFS= read -r part; do
  value="${part%[a-zA-Z]*}"  # Extract numeric value
  unit="${part#*[0-9]}"     # Extract time unit

  case $unit in
    "d") time_in_seconds=$((time_in_seconds + value * 86400));;  # 1 day = 86400 seconds
    "h") time_in_seconds=$((time_in_seconds + value * 3600));;   # 1 hour = 3600 seconds
    "m") time_in_seconds=$((time_in_seconds + value * 60));    # 1 minute = 60 seconds
  esac
done <<< "$age"

# Get the current timestamp in seconds since the epoch
current_timestamp=$(date +%s)

# Calculate the difference between the current time and the pod's "AGE"
time_difference=$((current_timestamp - time_in_seconds))

echo "Time difference in seconds: $time_difference seconds"

if [ "$time_difference" -gt 600 ]; then
	echo "pod looks too old for new deployment"
	#exit 1
fi