#!/bin/bash
# userdata script for web EC2 instances

# install required packages
sudo yum update -y && sudo yum upgrade -y
sudo yum install git -y

# install nvm - node package manager
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts

# Clone git project
export GIT_REPO_PATH=${GIT_REPO_PATH}
export GIT_TOKEN=${API_GITHUB_TOKEN}
if [[ ${GIT_REPO_PATH} == https://* ]]; then
    git clone https://$${GIT_TOKEN}@$${GIT_REPO_PATH#https://}
else
    git clone https://$${GIT_TOKEN}@github.com/$${GIT_REPO_PATH}
fi
unset GIT_TOKEN
cd mcp-server-deployment-pipeline/admin-portal

# Install required dependencies
npm install

# Setup environment
export NEXT_PUBLIC_API_URL="${NEXT_PUBLIC_API_URL}/api/v1"
export NEXT_PUBLIC_API_KEY=${NEXT_PUBLIC_API_KEY}

# Start app
#npm run build
#next start -p 3000 -H 0.0.0.0
npm run dev -- -p 3000 -H 0.0.0.0