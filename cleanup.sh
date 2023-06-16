#!/bin/bash

# Docker registry URL
REGISTRY_URL="https://registry.junaid.guru"

# Credentials for accessing the registry
USERNAME="junaid"
PASSWORD="b113snahmed"

repositories=$(curl -sS -u "$USERNAME:$PASSWORD" "$REGISTRY_URL/v2/_catalog" | jq -r '.repositories[]')
current_time_seconds=$(date -j -u +%s)

for repository in $repositories; do
  echo "Processing - $repository"
  # Get a list of all image tags in the registry
  image_tags=$(curl -sS -u "$USERNAME:$PASSWORD" "$REGISTRY_URL/v2/$repository/tags/list" | jq -r '.tags[]')

  # Loop through each image tag
  for tag in $image_tags; do
    # Exclude 'latest' and 'main' tags
    if [[ $tag == "latest" || $tag == "main" ]]; then
      continue
    fi

    # Get the created timestamp of the image tag
    created_at=$(curl -sS -u "$USERNAME:$PASSWORD" "$REGISTRY_URL/v2/$repository/manifests/$tag" | jq -r '.history[0].v1Compatibility' | jq -r '.created')

    # Remove the fractional seconds and 'Z' from the timestamp
    created_at=${created_at%.*}
    created_at=${created_at%Z}

    # Convert the created timestamp to seconds since epoch
    created_at_seconds=$(date -u -j -f "%Y-%m-%dT%H:%M:%S" "$created_at" +%s)

    # Calculate the number of days since the image was created
    days_since_created=$(( (current_time_seconds - created_at_seconds) / (24*60*60) ))

    # Delete the image if it is older than 30 days
    if (( days_since_created > 1 )); then
      echo "Deleting image with tag: $tag"
      #curl -X DELETE -u "$USERNAME:$PASSWORD" "$REGISTRY_URL/v2/$repository/manifests/$tag"
    fi
  done

done
