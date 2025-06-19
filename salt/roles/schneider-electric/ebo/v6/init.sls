# salt/roles/schneider-electric/ebo/v6/init.sls
include:
  - roles.schneider-electric.ebo # ensures base directories exist

transfer_ebo_license_administrator_installer:
  file.managed:
    - name: 'C:\install\software\Schneider Electric\License Administrator v6.0.4.90 - EcoStruxure Building - Software.exe'
    - source: salt://windows/installers/schneider-electric/ebo/v6/License Administrator v6.0.4.90 - EcoStruxure Building - Software.exe
    - makedirs: True
    - require:
        - file: software_schneider_directory

transfer_ebo_evaluation_license:
  file.managed:
    - name: 'C:\install\software\Schneider Electric\EcoStruxure Building Operation (EBO) Evaluation License Expiring Sep 1 2025.asr'
    - source: salt://windows/installers/schneider-electric/ebo/EcoStruxure Building Operation (EBO) Evaluation License Expiring Sep 1 2025.asr
    - makedirs: True
    - require:
        - file: software_schneider_directory

transfer_ebo_workstation_installer:
  file.managed:
    - name: 'C:\install\software\Schneider Electric\WorkStation v6.0.4.90 - EcoStruxure Building - Software.exe'
    - source: salt://windows/installers/schneider-electric/ebo/v6/WorkStation v6.0.4.90 - EcoStruxure Building - Software.exe
    - makedirs: True
    - require:
        - file: software_schneider_directory


