#!/bin/bash

if [ -z "$re_fqdns" ]; then
  echo "Environment variable 're_fqdns' is not set."
  exit 1
fi

IFS=',' read -r -a fqdn_array <<< "$re_fqdns"

re_username=admin@admin.com
re_password=admin
redb_name=mydb
redb_port=12000

max_retries=120
wait_between_retry=15
success=false

for re_fqdn in "${fqdn_array[@]}"; do
  retry_count=0
  while [ $retry_count -lt $max_retries ]; do
      response=$(curl -k -L -u "$re_username:$re_password" -X GET -H "Content-Type: application/json" https://$re_fqdn:9443/v1/cluster 2>/dev/null)
      http_status=$(curl -o /dev/null -s -w "%{http_code}" -k -L -u "$re_username:$re_password" -X GET -H "Content-Type: application/json" https://$re_fqdn:9443/v1/cluster)
      
      if [ $http_status -eq 200 ] && [ -n "$response" ]; then
          success=true
          break
      fi
      
      retry_count=$((retry_count + 1))
      echo "Retry $retry_count/$max_retries: Waiting for $wait_between_retry seconds before retrying..."
      sleep $wait_between_retry
  done

  if [ "$success" = false ]; then
      echo "operation was unsuccessful for $re_fqdn exiting now!!!"
      exit 1
  else
      echo "operation was successful for $re_fqdn"
  fi
done

max_retries=30
wait_between_retry=15
success=false
retry_count=0

while [ $retry_count -lt $max_retries ]; do
    HTTP_RESPONSE=$(curl -o response.txt -w "%{http_code}" -k -L -u "$re_username:$re_password" -X POST -H "Content-Type: application/json" https://${fqdn_array[0]}:9443/v2/bdbs --data "{\"bdb\": {\"name\": \"$redb_name\",\"type\": \"redis\",\"memory_size\": 1073741824,\"shards_count\": 1,\"port\": $redb_port, \"module_list\": [ { \"module_name\": \"search\" }, { \"module_name\": \"bf\" } ]}}")
    if [ $? -ne 0 ]; then
        echo "DB creating curl request failed"
        exit 1
    fi

    if [ "$HTTP_RESPONSE" -eq 200 ]; then
        echo "DB is created successfully"
        success=true
        break
    fi

  retry_count=$((retry_count + 1))
  echo "Retry $retry_count/$max_retries: Waiting for $wait_between_retry seconds before retrying to created DB..."
  sleep $wait_between_retry
done

if [ "$success" = false ]; then
    echo "DB creating was unsuccessful exiting now!!!"
    exit 1
else
    echo "created DB endpoint: redis-$redb_port.${fqdn_array[0]}:$redb_port"
fi

echo "Operation completed successfully!!!"
