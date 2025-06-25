# salt/top.sls
# Top file for SaltStack configuration management
base:
  'G@os_family:windows':
    - windows
    - windows.install_dir
    - windows.chocolatey
    - windows.software

  'G@roles:schneider-electric.ebo.v6.enterprise-server':
    - roles.schneider-electric.ebo.v6.enterprise-server

  'G@roles:jumpbox and G@os_family:windows':
    - roles.jumpbox.windows

  'G@roles:devbox and G@os_family:windows':
    - roles.devbox.windows

  'G@roles:web-server and G@os_family:windows':
    - roles.web-server.windows