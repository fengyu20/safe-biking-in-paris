FROM hashicorp/terraform:latest

WORKDIR /

# Copy the Terraform files
COPY . /infra/

# Add entrypoint script
COPY terraform-entrypoint.sh /usr/local/bin/terraform-entrypoint.sh
RUN chmod +x /usr/local/bin/terraform-entrypoint.sh

ENTRYPOINT ["terraform-entrypoint.sh"] 