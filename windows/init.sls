# /srv/salt/windows/init.sls
# Main state file for Windows Server 2022 configuration

include:
  - windows.chocolatey
  - windows.software
  - windows.config
  - windows.security
  - windows.proprietary