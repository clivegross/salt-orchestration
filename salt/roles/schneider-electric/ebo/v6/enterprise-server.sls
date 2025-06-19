# salt/roles/schneider-electric/ebo/v6/enterprise-server.sls
include:
  - roles.schneider-electric.ebo.v6 # install base software- license administrator, workstation
  - roles.schneider-electric.ebo.v6.enterprise-server-firewall # firewall rules for enterprise server

transfer_ebo_enterprise_server_installer:
  file.managed:
    - name: 'C:\install\software\Schneider Electric\Enterprise Server v6.0.4.90 - EcoStruxure Building - Software.exe'
    - source: salt://windows/installers/schneider-electric/ebo/v6/Enterprise Server v6.0.4.90 - EcoStruxure Building - Software.exe
    - makedirs: True
    - require:
        - file: software_schneider_directory

ebo_license_service_available:
  module.run:
    - name: service.available
    - m_name: 'Building Operation 6.0 License Server'

ebo_license_service_running:
  service.running:
    - name: "Building Operation 6.0 License Server"
    - enable: True
    - require:
        - module: ebo_license_service_available

ebo_enterprise_service_available:
  module.run:
    - name: service.available
    - m_name: 'Building Operation 6.0 Enterprise Server'

ebo_enterprise_service_running:
  service.running:
    - name: "Building Operation 6.0 Enterprise Server"
    - enable: True
    - require:
        - service: ebo_license_service_running
        - module: ebo_enterprise_service_available
