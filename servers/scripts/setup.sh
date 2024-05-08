#!/bin/bash

# Update and upgrade the system packages
echo "Updating system packages..."
apt-get update && apt-get upgrade -y

# Install unattended-upgrades for automatic package updates
echo "Installing unattended-upgrades for automatic system updates..."
apt-get install -y unattended-upgrades
dpkg-reconfigure -pmedium unattended-upgrades

# Add Docker's official GPG key:
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y

# Install docker
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Create a non-root user 'fred-bot'
echo "Creating user 'fred-bot'..."
useradd -m -s /bin/bash fred-bot

# Add 'fred-bot' to the docker group to allow running docker without sudo
echo "Adding 'fred-bot' to the docker group..."
usermod -aG docker fred-bot

# Switch to user 'fred-bot' and set up environment
echo "Setting up environment for 'fred-bot'..."
sudo -i -u fred-bot bash << EOF
# Clone the specified git repository using HTTPS
echo "Cloning repository..."
git clone https://github.com/jacob-grahn/platform-racing-4.git ~/platform-racing-4

# Set up cron job to run sync-from-repo.sh every 10 minutes
echo "Setting up cron job..."
(crontab -l 2>/dev/null; echo "*/5 * * * * cd ~/platform-racing-4/servers/scripts && bash sync-from-repo.sh &> cron.log") | crontab -

EOF

# Set up a root cron job to restart the VM once per month
echo "Setting up monthly VM restart cron job..."
(crontab -l 2>/dev/null; echo "0 0 1 * * /sbin/reboot") | crontab -

# Set up a system service to run sync-from-repo.sh at system boot as 'fred-bot'
echo "Setting up system boot service..."
cat > /etc/systemd/system/sync-from-repo.service << EOL
[Unit]
Description=Run sync-from-repo script at startup

[Service]
Type=simple
User=fred-bot
ExecStart=/bin/bash -c 'cd /home/fred-bot/platform-racing-4/servers/scripts && ./sync-from-repo.sh'

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the service
systemctl enable sync-from-repo.service
systemctl start sync-from-repo.service

echo "Setup complete!"
echo "Note that dev.secrets.yaml and prod.secrets.yaml need to be created."
