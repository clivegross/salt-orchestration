#!/bin/bash

# Salt Setup Script for Ubuntu
# Downloads and installs SaltStack with master and minion roles
# ./bootstrap-salt-master.sh -master <master_hostname_or_ip>

# Configuration variables
MINION_ID="master" # Default minion ID for the master

# Function to display usage
usage() {
    echo "Usage: $0 -master <master_hostname_or_ip>"
    echo ""
    echo "Options:"
    echo "  -master    Specify the salt-master DNS name or IP address"
    echo "             This will be stored under /etc/salt/minion.d/99-master-address.conf"
    echo ""
    echo "Example:"
    echo "  $0 -master 10.1.1.121"
    echo "  $0 -master salt-master.example.com"
    exit 1
}

# Parse command line arguments
MASTER_ADDRESS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -master)
            MASTER_ADDRESS="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate required parameters
if [[ -z "$MASTER_ADDRESS" ]]; then
    echo "Error: -master parameter is required"
    usage
fi

echo "Starting Salt installation..."
echo "Master address: $MASTER_ADDRESS"
echo "Minion ID: $MINION_ID"
echo ""

# Download and install latest SaltStack on a Linux system
echo "Downloading bootstrap script..."
curl -o bootstrap-salt.sh -L https://github.com/saltstack/salt-bootstrap/releases/latest/download/bootstrap-salt.sh

# Ensure the script is executable
chmod +x bootstrap-salt.sh

# Install SaltStack with the master minion roles, python pip installation, and configure master address and minion ID
echo "Installing SaltStack with master and minion roles..."
sudo ./bootstrap-salt.sh -P -M -A "$MASTER_ADDRESS" -i "$MINION_ID"

# Copy files in master.d to /etc/salt/master.d (if directory exists)
if [[ -d "./master.d" ]]; then
    echo "Copying master configuration files..."
    sudo cp -r ./master.d/* /etc/salt/master.d/
else
    echo "Warning: ./master.d directory not found, skipping master config copy"
fi

# Copy files in minion.d to /etc/salt/minion.d (if directory exists)
if [[ -d "./minion.d" ]]; then
    echo "Copying minion configuration files..."
    sudo cp -r ./minion.d/* /etc/salt/minion.d/
else
    echo "Warning: ./minion.d directory not found, skipping minion config copy"
fi

# Enable the Salt master and minion services to start on boot
echo "Enabling Salt services..."
sudo systemctl enable salt-master
sudo systemctl enable salt-minion

# Start the Salt master and minion services
echo "Starting Salt services..."
sudo systemctl start salt-master
sudo systemctl start salt-minion

# Wait a moment for services to fully start
sleep 5

# Check service status
echo ""
echo "Checking service status..."
echo "Salt Master status:"
sudo systemctl status salt-master --no-pager -l

echo ""
echo "Salt Minion status:"
sudo systemctl status salt-minion --no-pager -l

echo ""
echo "Installation completed successfully!"
echo ""
echo "Configuration summary:"
echo "- Master address: $MASTER_ADDRESS"
echo "- Minion ID: $MINION_ID"
echo "- Master config: /etc/salt/master.d/"
echo "- Minion config: /etc/salt/minion.d/"
echo "- Master address config: /etc/salt/minion.d/99-master-address.conf"
echo "- Minion ID file: /etc/salt/minion_id"
echo ""
echo "Next steps:"
echo "1. Check and accept the minion key on the master:"
echo "   sudo salt-key"
echo "2. Accept the minion key:"
echo "   sudo salt-key -a $MINION_ID"
echo "3. Test the connection:"
echo "   sudo salt '$MINION_ID' test.ping"
echo ""
echo "Troubleshooting commands:"
echo "- Check master logs: sudo journalctl -u salt-master -f"
echo "- Check minion logs: sudo journalctl -u salt-minion -f"
echo "- Restart minion if needed: sudo systemctl restart salt-minion"