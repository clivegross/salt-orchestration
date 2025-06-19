# salt/roles/schneider-electric/install_dir.sls
# Role to install Schneider Electric install dirs
include:
  - windows.install_dir # Ensure C:\install and subfolders exist

software_schneider_directory:
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
        - file: software_directory
