#!/bin/bash
# userdata script for web EC2 instances

LOGFILE="/home/ec2-user/userdata.log"
exec > >(tee -a "$LOGFILE") 2>&1

# install required packages
sudo yum update -y && sudo yum upgrade -y
sudo yum install git -y

# # install nvm - node package manager
# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
# source ~/.bashrc
# nvm install --lts
# nvm use --lts

# install node
curl -fsSL https://rpm.nodesource.com/setup_22.x -o nodesource_setup.sh
bash nodesource_setup.sh
yum install -y nodejs

# Setup environment
export GIT_REPO_PATH=https://github.com/MarcoLuw/admin-portal
export GIT_TOKEN=${API_GITHUB_TOKEN}
export NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
export NEXT_PUBLIC_API_KEY=${NEXT_PUBLIC_API_KEY}
export INTERNAL_APP_ALB_DNS=${INTERNAL_APP_ALB_DNS}

# Setup Nginx Reverse Proxy
yum install nginx -y

cat > /etc/nginx/conf.d/default.conf.template <<'EOF'
resolver 172.16.0.2 valid=20s ipv6=off;
server {
    listen 80;
    server_name _;

    # Timeout settings
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;

    # Proxy Next.js frontend
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
    }

    # Proxy API calls to backend
    location /api/v1 {
        set $backend $${INTERNAL_APP_ALB_DNS};
        proxy_pass $backend;
    }
}
EOF

envsubst '$${INTERNAL_APP_ALB_DNS}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf
systemctl enable nginx
systemctl start nginx

# Clone git project
git clone https://$${GIT_TOKEN}@$${GIT_REPO_PATH#https://}
unset GIT_TOKEN
cd admin-portal

# Install required dependencies
npm install

# Write them to .env.local (overwrite or create)
cat <<EOF > .env.local
NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
NEXT_PUBLIC_API_KEY=${NEXT_PUBLIC_API_KEY}
EOF

# Start app
npm run build
npm start -- -p 3000 -H 0.0.0.0
# npm run dev