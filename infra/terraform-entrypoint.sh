#!/bin/sh
set -e

# Default command is apply if none provided
COMMAND=${@:-apply}

# Initialize Terraform if not already initialized
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
fi

# Handle different commands
case "$COMMAND" in
    "apply" | "apply -auto-approve")
        echo "Checking current infrastructure state..."
        
        # Run plan to see if there are changes needed
        if terraform plan -detailed-exitcode > /dev/null 2>&1; then
            echo "Infrastructure is up to date. No changes needed."
        elif [ $? -eq 2 ]; then
            echo "Changes detected. Applying infrastructure updates..."
            terraform apply -auto-approve
        else
            echo "Error occurred during planning. Attempting apply anyway..."
            terraform apply -auto-approve
        fi
        ;;
    "destroy" | "destroy -auto-approve")
        echo "Destroying infrastructure..."
        terraform destroy -auto-approve
        ;;
    *)
        # For other commands (plan, show, etc.), run as-is
        echo "Running: terraform $COMMAND"
        terraform $COMMAND
        ;;
esac 