#!/bin/bash

# Exit on error
set -e

# Injects the private SSH key into the container from the .env file.

# Run the command in argument
exec "$@"
