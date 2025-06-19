# Role to install Schneider Electric software
# salt/roles/schneider-electric/init.sls
include:
  - roles.schneider-electric.install_dir
  - roles.schneider-electric.bginfo
