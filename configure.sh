#!/bin/bash
# Salt Master deployment and management commands

# 1. INITIAL SETUP COMMANDS
echo "=== Salt Master Initial Setup ==="

# Restart salt-master after configuration changes
systemctl restart salt-master
systemctl status salt-master

# Update Windows repository (for Chocolatey packages)
salt-run winrepo.update_git_repos
salt '*' pkg.refresh_db

# 2. MINION KEY MANAGEMENT
echo "=== Managing Minion Keys ==="

# List all keys
salt-key -L

# Accept specific minion key
# salt-key -a MINION-ID

# Accept all pending keys (use with caution)
# salt-key -A

# Delete a minion key
# salt-key -d MINION-ID

# 3. BASIC CONNECTIVITY TESTS
echo "=== Testing Connectivity ==="

# Test all minions
salt '*' test.ping

# Test specific minion
# salt 'MINION-ID' test.ping

# Get system information
salt '*' grains.items

# Check disk space
salt '*' disk.usage

# 4. DEPLOY CONFIGURATION TO ALL WINDOWS SERVERS
echo "=== Deploying Windows Configuration ==="

# Apply all Windows states
salt '*' state.apply windows

# Apply specific state
salt '*' state.apply windows.chocolatey

# Apply with pillar data
salt '*' state.apply windows pillar='{"custom_var": "value"}'

# 5. SOFTWARE MANAGEMENT
echo "=== Software Management ==="

# Install Notepad++ specifically
salt '*' state.apply windows.software

# Check installed software
salt '*' pkg.list_pkgs

# Update all packages
salt '*' pkg.upgrade

# 6. SHAREPOINT SOFTWARE DEPLOYMENT
echo "=== Proprietary Software Deployment ==="

# Deploy proprietary software from SharePoint
salt '*' state.apply windows.proprietary

# Check if specific software is installed
salt '*' cmd.run 'Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {$_.DisplayName -like "*MyProprietaryApp*"}' shell=powershell

# 7. MONITORING AND MAINTENANCE
echo "=== Monitoring Commands ==="

# Check Salt minion service status
salt '*' service.status salt-minion

# Get system uptime
salt '*' status.uptime

# Check Windows Update status
salt '*' cmd.run 'Get-WUList' shell=powershell

# View recent event logs
salt '*' cmd.run 'Get-EventLog -LogName System -Newest 10' shell=powershell

# 8. CONFIGURATION VERIFICATION
echo "=== Configuration Verification ==="

# Test all states without applying changes
salt '*' state.apply windows test=True

# Show differences that would be applied
salt '*' state.apply windows test=True --state-verbose=True

# Get current state information
salt '*' state.show_sls windows

# 9. TROUBLESHOOTING COMMANDS
echo "=== Troubleshooting ==="

# Check minion logs
# salt 'MINION-ID' cmd.run 'Get-Content C:\salt\var\log\salt\minion -Tail 50' shell=powershell

# Restart minion service
# salt 'MINION-ID' service.restart salt-minion

# Clear minion cache
# salt 'MINION-ID' saltutil.clear_cache

# Refresh pillar data
salt '*' saltutil.refresh_pillar

# Sync all modules and states
salt '*' saltutil.sync_all

# 10. SCHEDULING AND AUTOMATION
echo "=== Scheduling Jobs ==="

# Schedule a one-time job
# salt '*' schedule.add job1 function='state.apply' job_args='["windows"]' seconds=3600

# List scheduled jobs
salt '*' schedule.list

# Enable/disable minion scheduler
salt '*' schedule.enable_job job1
# salt '*' schedule.disable_job job1

# 11. BATCH OPERATIONS
echo "=== Batch Operations Script ==="

# Create a deployment script
cat > deploy_all_windows.sh << 'EOF'
#!/bin/bash

echo "Starting Windows Server deployment..."

# Test connectivity
echo "Testing minion connectivity..."
salt '*' test.ping

# Refresh pillar data
echo "Refreshing pillar data..."
salt '*' saltutil.refresh_pillar

# Apply base configuration
echo "Applying base Windows configuration..."
salt '*' state.apply windows.config

# Install Chocolatey and basic software
echo "Installing Chocolatey and software..."
salt '*' state.apply windows.chocolatey
salt '*' state.apply windows.software

# Deploy proprietary software
echo "Deploying proprietary software..."
salt '*' state.apply windows.proprietary

# Apply security settings
echo "Applying security configuration..."
salt '*' state.apply windows.security

# Final verification
echo "Verifying deployment..."
salt '*' state.apply windows test=True

echo "Deployment completed!"
EOF

chmod +x deploy_all_windows.sh

echo "Deployment script created: deploy_all_windows.sh"
echo "Run ./deploy_all_windows.sh to deploy to all Windows servers"