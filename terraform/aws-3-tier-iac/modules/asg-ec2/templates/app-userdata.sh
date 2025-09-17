#!/bin/bash
# userdata script for app EC2 instances

# install required packages
sudo yum update && sudo yum upgrade
sudo yum install -y nmap-ncat
sudo yum install git -y

# install uv - python package manager
curl -LsSf https://astral.sh/uv/install.sh | sh
source /root/.local/bin/env

# install docker
sudo yum install -y docker
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -a -G docker ec2-user
# install Standalone compose
sudo curl -SL https://github.com/docker/compose/releases/download/v2.39.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo docker-compose version

# Setup environment
export RAILWAY_API_TOKEN_=${RAILWAY_API_TOKEN_}
export GOOGLE_GEMINI_API_KEY=${GOOGLE_GEMINI_API_KEY}
export DB_CONNECTION_STRING=${DB_CONNECTION_STRING}
export API_GITHUB_TOKEN=${API_GITHUB_TOKEN}
export BUCKET_BACKUP="mcp-backup"
export BUCKET_NAME="mcp-catalog"
export SUPABASE_ENDPOINT_URL=${SUPABASE_ENDPOINT_URL}
export SUPABASE_REGION=${SUPABASE_REGION}
export BUCKET_ACCESS_KEY_ID=${BUCKET_ACCESS_KEY_ID}
export BUCKET_ACCESS_KEY_SECRET=${BUCKET_ACCESS_KEY_SECRET}
export INTERNAL_API_KEY=${INTERNAL_API_KEY}
export DOPPLER_TOKEN=${DOPPLER_TOKEN}
export API_ONLY_MODE=True
export NGINX_BASIC_AUTH_USERNAME=${NGINX_BASIC_AUTH_USERNAME}
export NGINX_BASIC_AUTH_PASSWORD=${NGINX_BASIC_AUTH_PASSWORD}
export REDIS_PASSWORD=${REDIS_PASSWORD}

cat <<EOF > .env
RAILWAY_API_TOKEN_=${RAILWAY_API_TOKEN_}
GOOGLE_GEMINI_API_KEY=${GOOGLE_GEMINI_API_KEY}
DB_CONNECTION_STRING=${DB_CONNECTION_STRING}
API_GITHUB_TOKEN=${API_GITHUB_TOKEN}
BUCKET_BACKUP="mcp-backup"
BUCKET_NAME="mcp-catalog"
SUPABASE_ENDPOINT_URL=${SUPABASE_ENDPOINT_URL}
SUPABASE_REGION=${SUPABASE_REGION}
BUCKET_ACCESS_KEY_ID=${BUCKET_ACCESS_KEY_ID}
BUCKET_ACCESS_KEY_SECRET=${BUCKET_ACCESS_KEY_SECRET}
INTERNAL_API_KEY=${INTERNAL_API_KEY}
DOPPLER_TOKEN=${DOPPLER_TOKEN}
API_ONLY_MODE=True
NGINX_BASIC_AUTH_USERNAME=${NGINX_BASIC_AUTH_USERNAME}
NGINX_BASIC_AUTH_PASSWORD=${NGINX_BASIC_AUTH_PASSWORD}
REDIS_PASSWORD=${REDIS_PASSWORD}
EOF

# Clone git project
export GIT_REPO_PATH=${GIT_REPO_PATH}
export GIT_TOKEN=${API_GITHUB_TOKEN}
if [[ $${GIT_REPO_PATH} == https://* ]]; then
    git clone https://$${GIT_TOKEN}@$${GIT_REPO_PATH#https://}
else
    git clone https://$${GIT_TOKEN}@github.com/$${GIT_REPO_PATH}
fi
unset GIT_TOKEN
cd mcp-server-deployment-pipeline

# Activate virtual env python3.13
uv venv --python 3.13 --clear
source .venv/bin/activate

# Install required dependencies
uv pip install -r requirements.txt

# Start Redis server
# Start Redis server
sudo docker-compose -f docker/docker-compose.yaml up redis -d
until nc -z localhost 6379; do
  sleep 1
done

# Start app
uv pip install "fastapi[standard]"
.venv/bin/fastapi run main.py --port 8000 --host 0.0.0.0