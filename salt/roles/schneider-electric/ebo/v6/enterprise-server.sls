include:
  - roles.schneider-electric.ebo.v6 # install base software- license administrator, workstation

transfer_ebo_enterprise_server_installer:
  file.managed:
    - name: 'C:\install\software\Schneider Electric\Enterprise Server v6.0.4.90 - EcoStruxure Building - Software.exe'
    - source: salt://windows/installers/schneider-electric/ebo/v6/Enterprise Server v6.0.4.90 - EcoStruxure Building - Software.exe
    - makedirs: True
