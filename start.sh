#!/bin/bash

# Check if the environment variable 're_fqdns' is set
if [ -z "$re_fqdns" ]; then
  echo "Environment variable 're_fqdns' is not set." > /temp/test.txt
  echo "Environment variable 're_fqdns' is not set."
  exit 1
fi

# Create the /temp directory if it does not exist
mkdir -p /temp

# Write the value of 're_fqdns' to /temp/test.txt
echo "$re_fqdns" > /temp/test.txt

echo "Value of 're_fqdns' written to /temp/test.txt"
