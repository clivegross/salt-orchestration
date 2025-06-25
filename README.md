# Salt Orchestration

Bootstrapped SaltStack configuration management for automated infrastructure orchestration and software deployment across Windows and Linux environments.

## Overview

This repository contains Salt states, pillar data, and deployment scripts for managing a heterogeneous infrastructure with a Linux Salt master orchestrating Windows and Linux minions. The configuration supports automated software installation, system configuration management, and compliance enforcement.

## Architecture

- **Salt Master**: Linux server, tested on Amazon Linux EC2 instance
- **Salt Minions**: Windows servers and workstations, Linux servers
- **Management**: Centralized configuration through Salt states and pillar data
- **Deployment**: Automated scripts for bootstrap, deployment, and rollback

## Features

- ✅ Automated Windows software installation via Chocolatey
- ✅ System configuration management
- ✅ Registry management and compliance
- ✅ Service configuration and monitoring
- ✅ Centralized logging and reporting
- ✅ Environment-specific configurations
- ✅ Backup and rollback capabilities

## Quick Start

### 1. Bootstrap Salt Master

```bash
# Clone this repository
git clone git@github.com:clivegross/salt-orchestration.git
cd salt-orchestration

# Run the master bootstrap script
sudo sh scripts/bootstrap/bootstrap-salt-master.sh -master <YOUR-MASTER-IP-ADDRESS-OR-HOSTNAME>

# Deploy salt configurations
sudo sh deploy.sh
```

If you make changes to the local salt-master configuration files, just run the deploy script again.

```bash
sudo sh deploy.sh
```

If the Master is also a file server for hosting installers, config files etc, upload the files. In the default config, install files have been saved to `/mnt/salt-files` and declared in the `master.d/file_roots.conf`:

```
file_roots:
  base:
    - /srv/salt           # config and top.sls
    - /mnt/salt-files     # files system, installers etc
```

### 2. Bootstrap Windows Minions

On each Windows machine:

```powershell
# Download and run the minion bootstrap script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/yourusername/salt-orchestration/main/scripts/bootstrap/bootstrap-salt-minion-windows.ps1" -OutFile "bootstrap-salt-minion-windows.ps1"
.\bootstrap-salt-minion-windows.ps1 -Master "YOUR-SALT-MASTER-IP-OR-HOSTNAME"
```

### 3. Accept Minion Keys

```bash
# On the Salt master
sudo salt-key -L                    # List pending keys
sudo salt-key -a 'YOUR-MINION-ID'   # Accept YOUR-MINION-ID key
sudo salt '*' test.ping             # Test connectivity
```

### 4. Manage State

The workflow for managing minions and applying state:

1. Configure the different desired roles in `.sls` files in the `salt/roles` directory. Browse throught the `salt` state file directories to see sample roles already configured, see [Roles](#roles). Update the `top.sls` file so the roles are defined.
2. Assign roles to minions, see [Assign Roles](#assign-roles).
3. Apply state to minions, see [Apply States](#apply-states).

#### Assign Roles

From the Master, you can view and modify roles to minions.

View current assigned roles:

```bash
sudo salt 'WINSVR01-V' grains.get roles
```

Append roles to a minion:

```bash
salt 'WINSVR01-V' grains.append roles jumpbox
salt 'WINSVR01-V' grains.append roles web-server
```

Then apply the updated state, see [Apply States](#apply-states).

#### Apply States

```bash
# Apply all states
sudo salt '*' state.apply

# Apply to specific targets
sudo salt -G 'os:Windows' state.apply -v
sudo salt 'MINION-NAME*' state.apply -v

# Test run (dry run)
sudo salt -G 'os:Windows' state.apply test=True
```

Example assignment of role `schneider-electric.ebo.v6.enterprise-server` to minion `'WINSVR01-V'`, verify and apply state:

```bash
$ sudo salt 'WINSVR01-V' grains.setval roles schneider-electric.ebo.v6.enterprise-server
$ sudo salt 'WINSVR01-V' grains.get roles
WINSVR01-V:
    - schneider-electric.ebo.v6.enterprise-server
$ sudo salt 'WINSVR01-V' state.show_top
WINSVR01-V:
    ----------
    base:
        - windows
        - windows.chocolatey
        - windows.software
        - roles.schneider-electric.ebo.v6.enterprise-server

$ sudo salt 'WINSVR01-V' state.apply

```

## Project Structure

(in progress)

```
salt-orchestration/
├── salt/                    # Salt state files
│   ├── windows/            # Windows-specific states
│   ├── linux/              # Linux-specific states
│   └── common/             # Cross-platform states
├── pillar/                 # Configuration data
├── scripts/                # Bootstrap and deployment scripts
├── config/                 # Salt daemon configurations
├── files/                  # Static files served by Salt
└── docs/                   # Documentation
```

## Configuration

### Salt Master Configuration

Key configuration files:

- `config/master` - Salt master daemon configuration
- `salt/top.sls` - State assignments
- `pillar/top.sls` - Pillar data assignments

### Windows Minion Management

Common operations:

```bash
# Install software via Chocolatey
sudo salt -G 'os:Windows' chocolatey.install firefox

# Execute PowerShell commands
sudo salt 'WIN-*' cmd.run 'Get-Service' shell=powershell

# Manage Windows services
sudo salt -G 'os:Windows' service.start Spooler

# Registry management
sudo salt -G 'os:Windows' reg.set_value 'HKLM\SOFTWARE\MyApp' 'Setting' 'Value'
```

### Environment Management

Switch between environments:

```bash
# Development
sudo salt '*' state.apply pillar='{"environment": "dev"}'

# Production
sudo salt '*' state.apply pillar='{"environment": "production"}'
```

## Available States

### Roles

| Role                                           | Description                                                               |
| ---------------------------------------------- | ------------------------------------------------------------------------- |
| `devbox`                                       | Configures a Windows machine with essential developer tools and settings. |
| `jumpbox`                                      | Sets up a secure intermediary host for accessing remote networks.         |
| `web-server`                                   | Installs and configures a basic web server environment.                   |
| `schneider-electric`                           | Prepares the system for Schneider Electric software deployments.          |
| `schneider-electric.ebo.v6.enterprise-server`  | Installs and configures the EBO v6 Enterprise Server platform.            |
| `schneider-electric.ebo.v6.enterprise-central` | Installs and configures the EBO v6 Enterprise Central platform.           |

### Windows States

| State                              | Description                           |
| ---------------------------------- | ------------------------------------- |
| `windows.base`                     | Basic Windows configuration           |
| `windows.chocolatey`               | Chocolatey package manager            |
| `windows.software.notepadplusplus` | Notepad++ installation                |
| `windows.software.vscode`          | VS Code installation                  |
| `windows.software.iis`             | Microsoft IIS web server installation |
| `windows.config.bginfo`            | BGinfo tool deployment                |

## Deployment Scripts

### Bootstrap Scripts

- `scripts/bootstrap/bootstrap-salt-master.sh` - Sets up Salt master on Amazon Linux
- `scripts/bootstrap/bootstrap-salt-minion.ps1` - Sets up Salt minion on Windows

### Deployment Scripts

- `deploy.sh` - Deploy latest configurations with backup
- `scripts/deployment/backup.sh` - Backup current configurations
- `scripts/deployment/rollback.sh` - Rollback to previous configuration

### Utility Scripts

- `scripts/utilities/test-minions.sh` - Test minion connectivity and health
- `scripts/utilities/cleanup.sh` - Clean up old backups and logs

## Usage Examples

### Software Installation

```bash
# Install software on all Windows machines
sudo salt -G 'os:Windows' state.apply windows.software.firefox

# Install specific software on target machines
sudo salt 'WIN-WEB-*' state.apply windows.software.iis
```

### Configuration Management

```bash
# Apply registry settings
sudo salt -G 'os:Windows' state.apply windows.config.registry

# Configure services
sudo salt 'WIN-DB-*' state.apply windows.config.services
```

### System Information

```bash
# Get system information
sudo salt '*' grains.items

# Check disk space
sudo salt '*' disk.usage

# View running processes
sudo salt -G 'os:Windows' ps.get_pid_list
```

## Troubleshooting

### Common Issues

**Minions not responding:**

```bash
sudo salt-key -d MINION-NAME     # Delete key
# Re-run bootstrap script on minion
sudo salt-key -a MINION-NAME     # Accept new key
```

**State execution failures:**

```bash
sudo salt 'MINION-NAME' state.apply test=True -l debug
```

**Chocolatey issues:**

```bash
sudo salt 'MINION-NAME' chocolatey.list
sudo salt 'MINION-NAME' cmd.run 'choco --version' shell=powershell
```

### Logs

- **Salt Master logs**: `/var/log/salt/master`
- **Salt Minion logs**: `C:\salt\var\log\salt\minion` (Windows)
- **Deployment logs**: `logs/` directory

## Security Considerations

- Salt master should be behind a firewall with only necessary ports open (4505, 4506)
- Use Salt's built-in authentication and encryption
- Regularly rotate Salt keys
- Store sensitive data in pillar files with proper permissions
- Use environment-specific configurations for secrets

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Test your changes in a development environment
4. Commit your changes: `git commit -am 'Add new feature'`
5. Push to the branch: `git push origin feature-name`
6. Submit a pull request

## Support

For issues and questions:

- Check the [troubleshooting documentation](docs/troubleshooting.md)
- Review Salt logs for error details
- Open an issue in this repository

## Documentation

Additional documentation available in the `docs/` directory:

- [Installation Guide](docs/installation.md)
- [Configuration Reference](docs/configuration.md)
- [Troubleshooting Guide](docs/troubleshooting.md)
- [Architecture Overview](docs/architecture.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
