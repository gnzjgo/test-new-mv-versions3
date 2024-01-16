#!/bin/bash
source .tinyenv
# Function to convert date to epoch time
get_epoch_time() {
    date -u -d "$1" +"%s"
}

# Function to wait until a specific UTC time is reached
wait_until_utc_time() {
    target_utc_time=$1
    target_epoch_time=$(get_epoch_time "$target_utc_time")
    
    echo "target time $target_epoch_time"

    current_epoch_time=$(date -u +"%s")
    echo "current time $current_epoch_time"
    time_difference=$((target_epoch_time - current_epoch_time))
    echo "time diff $time_difference"

    while [ $time_difference -gt 60 ]; do
        sleep 60
        current_epoch_time=$(date -u +"%s")
        time_difference=$((target_epoch_time - current_epoch_time))
        echo "time diff $time_difference"
    done
    
    while [ $time_difference -gt 0 ]; do
        sleep 1
        current_epoch_time=$(date -u +"%s")
        time_difference=$((target_epoch_time - current_epoch_time))
        echo "time diff $time_difference"
    done
}

tb --semver ${VERSION} deploy --v3
tb --semver ${VERSION} pipe rm mat_safe_populate --yes
tb --semver ${VERSION} pipe ls
tb --semver ${VERSION} datasource truncate location_count_mv --yes


# Wait until set time has passed
target_utc_time="2024-01-16 08:25:00"
echo "Waiting until $target_utc_time UTC..."
wait_until_utc_time "$target_utc_time"

echo "Time has reached $target_utc_time UTC! Continue with the rest of the script."

tb --semver ${VERSION} push pipes/mat_safe_populate.pipe --populate --wait