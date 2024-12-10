#!/bin/bash

# Update and install essential packages
sudo apt-get update
sudo apt-get install -y curl tar

# Define variables
NON_ROOT_USER="azureuser"
DEVOPS_URL="https://dev.azure.com/your-organization-name"
PAT_TOKEN="YOUR_PAT_TOKEN"
POOL_NAME="vmss-deployment"

# Create a directory for Azure DevOps agent and navigate to it
mkdir -p /home/azureuser/azagent
cd /home/azureuser/azagent

# Download and extract the Azure DevOps agent package
curl -fkSL -o vstsagent.tar.gz https://vstsagentpackage.azureedge.net/agent/3.246.0/vsts-agent-linux-x64-3.246.0.tar.gz
tar -zxf vstsagent.tar.gz

# Check if extraction was successful
if [ $? -ne 0 ]; then
  echo "Extraction of vstsagent.tar.gz failed" >> /var/log/agent_install.log
  exit 1
fi

# Configure and register the agent with Azure DevOps
echo "Running config.sh"
sudo -u "$NON_ROOT_USER" ./config.sh --unattended --url "$DEVOPS_URL" --auth pat --token "$PAT_TOKEN" --pool "$POOL_NAME" --agent "$HOSTNAME" --replace --acceptTeeEula --work _work >> /var/log/agent_install.log 2>&1

# Check if agent configuration was successful
if [ $? -ne 0 ]; then
  echo "config.sh run failed"
  exit 1
fi

# Install and start the Azure DevOps agent service
sudo ./svc.sh install >> /var/log/agent_install.log 2>&1
sudo ./svc.sh start >> /var/log/agent_install.log 2>&1

# Install Node.js, Nginx, and PM2

