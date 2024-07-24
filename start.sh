#!/bin/bash

# Create the /tmp directory if it does not exist
mkdir -p /tmp

# Check if the environment variable 're_fqdns' is set
if [ -z "$re_fqdns" ]; then
  echo "Environment variable 're_fqdns' is not set." > /tmp/test.txt
  echo "Environment variable 're_fqdns' is not set."
  exit 1
fi

# Write the value of 're_fqdns' to /tmp/test.txt
echo "$re_fqdns" > /tmp/test.txt

echo "Value of 're_fqdns' written to /tmp/test.txt"
