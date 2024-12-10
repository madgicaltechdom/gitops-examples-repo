#!/bin/bash

# Update the package index and install required packages
sudo apt-get update
sudo apt-get install -y curl tar

# Define variables (replace with your specific values)
NON_ROOT_USER="azureuser"  # Replace with your non-root user
DEVOPS_URL="https://dev.azure.com/your-org"  # Replace with your Azure DevOps organization URL
PAT_TOKEN="your-pat-token"  # Replace with your Personal Access Token (PAT)
POOL_NAME="your-pool-name"  # Replace with your agent pool name

# Create a directory for the Azure DevOps agent and navigate to it
mkdir -p /home/$NON_ROOT_USER/azagent
cd /home/$NON_ROOT_USER/azagent

# Download the Azure DevOps agent package
curl -fkSL -o vstsagent.tar.gz https://vstsagentpackage.azureedge.net/agent/3.246.0/vsts-agent-linux-x64-3.246.0.tar.gz

# Extract the downloaded package
tar -zxf vstsagent.tar.gz
if [ $? -ne 0 ]; then
  echo "Extraction of vstsagent.tar.gz failed" >> /var/log/agent_install.log
  exit 1
fi

# Configure the Azure DevOps agent
sudo -u "$NON_ROOT_USER" ./config.sh --unattended \
  --url "$DEVOPS_URL" \
  --auth pat \
  --token "$PAT_TOKEN" \
  --pool "$POOL_NAME" \
  --agent "$HOSTNAME" \
  --replace \
  --acceptTeeEula \
  --work _work >> /var/log/agent_install.log 2>&1

if [ $? -ne 0 ]; then
  echo "config.sh run failed" >> /var/log/agent_install.log
  exit 1
fi

# Install and start the Azure DevOps agent service
sudo ./svc.sh install >> /var/log/agent_install.log 2>&1
sudo ./svc.sh start >> /var/log/agent_install.log 2>&1
