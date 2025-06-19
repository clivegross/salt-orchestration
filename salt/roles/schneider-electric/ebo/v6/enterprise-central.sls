# salt/roles/schneider-electric/ebo/v6/enterprise-central.sls
include:
  - roles.schneider-electric.ebo.v6 # install base software- license administrator, workstation
  - roles.schneider-electric.ebo.v6.enterprise-central-firewall # firewall rules for enterprise central

transfer_ebo_enterprise_central_installer:
  file.managed:
    - name: 'C:\install\software\Schneider Electric\Enterprise Central v6.0.4.90 - EcoStruxure Building - Software.exe'
    - source: salt://windows/installers/schneider-electric/ebo/v6/Enterprise Central v6.0.4.90 - EcoStruxure Building - Software.exe
    - makedirs: True
    - require:
        - file: software_schneider_directory
