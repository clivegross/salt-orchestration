# Windows nodes
# File: salt/windows/install_dir.sls

base_install_directory:
  file.directory:
    - name: C:\\install
    - makedirs: True
    - win_owner: Administrators
    - win_perms:
        Administrators:
          perms: full_control
        Users:
          perms: read_execute

software_directory:
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
        - file: base_install_directory

tools_directory:
  file.directory:
    - name: "C:\\install\\tools"
    - makedirs: True
    - win_owner: Administrators
    - win_perms:
        Administrators:
          perms: full_control
        Users:
          perms: read_execute
    - require:
        - file: base_install_directory

backups_directory:
  file.directory:
    - name: "C:\\install\\backups"
    - makedirs: True
    - win_owner: Administrators
    - win_perms:
        Administrators:
          perms: full_control
        Users:
          perms: read_execute
    - require:
        - file: base_install_directory
