# EcoStruxure Building Operation Enterprise Server v6 Role
# File: salt/roles/ecostruxure-building-operation-v6/init.sls

ecostruxure_base_install_directory:
  file.directory:
    - name: C:\\install
    - makedirs: True
    - win_owner: Administrators
    - win_perms:
        Administrators:
          perms: full_control
        Users:
          perms: read_execute

ecostruxure_software_directory:
  file.directory:
    - name: "C:\\install\\software"
    - makedirs: True
    - win_owner: Administrators
    - win_perms:
        Administrators:
          perms: full_control
        Users:
          perms: read_execute
    - require:
        - file: ecostruxure_base_install_directory

ecostruxure_schneider_directory:
  file.directory:
    - name: "C:\\install\\software\\Schneider Electric"
    - makedirs: True
    - win_owner: Administrators
    - win_perms:
        Administrators:
          perms: full_control
        Users:
          perms: read_execute
    - require:
        - file: ecostruxure_software_directory
