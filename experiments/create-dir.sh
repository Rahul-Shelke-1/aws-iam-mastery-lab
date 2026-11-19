#!/bin/sh

# Exit immediately if a command fails
set -e

SOURCE_PROVIDER="01-single-iam-user/provider.tf"

# Check that the template provider.tf exists before proceeding
if [ ! -f "$SOURCE_PROVIDER" ]; then
  echo "Error: Template file '$SOURCE_PROVIDER' not found in current directory."
  exit 1
fi

# Use the first argument as the base folder name, or prompt for it if not provided
BASE_DIR="$1"
if [ -z "$BASE_DIR" ]; then
  printf "Enter the project/folder name: "
  read -r BASE_DIR
fi

# Ensure a name was entered
if [ -z "$BASE_DIR" ]; then
  echo "Error: Folder name cannot be empty."
  exit 1
fi

# Create the base folder and 2 subdirectories inside it
mkdir -p "$BASE_DIR/evidence" "$BASE_DIR/tests"

# Copy provider.tf and create the 4 standard Terraform files
cp "$SOURCE_PROVIDER" "$BASE_DIR/"
touch "$BASE_DIR/main.tf" "$BASE_DIR/outputs.tf" "$BASE_DIR/variables.tf" "$BASE_DIR/README.md"

echo "Successfully created '$BASE_DIR' with 2 directories, 4 files, and copied '$SOURCE_PROVIDER'."