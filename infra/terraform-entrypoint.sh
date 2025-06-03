#!/bin/sh
set -e

# Default command is apply if none provided
COMMAND=${@:-apply}

# Check if we should auto-approve
if [ "$COMMAND" = "apply" ] || [ "$COMMAND" = "destroy" ]; then
    if [ -z "$TF_NO_AUTO_APPROVE" ]; then
        COMMAND="$COMMAND -auto-approve"
    fi
fi

# Initialize Terraform if not already initialized
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
fi

# Execute the command
echo "Running: terraform $COMMAND"
terraform $COMMAND 