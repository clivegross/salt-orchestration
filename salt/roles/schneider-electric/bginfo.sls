# roles/schneider-electric/bginfo.sls
{% set startup = 'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup' %}

include:
  - windows.install_dir  # Ensure C:\install and subfolders exist
  - windows.software.bginfo  # Ensure BGInfo is installed

# Transfer the custom BGInfo configuration file
bginfo_config_file:
  file.managed:
    - name: C:\install\tools\bginfo\config.bgi
    - source: salt://windows/bginfo/schneider-electric.bgi
    - makedirs: True
    - require:
        - file: tools_directory

# Transfer the custom wallpaper
bginfo_wallpaper:
  file.managed:
    - name: C:\install\tools\bginfo\schneider-electric-bg.jpg
    - source: salt://wallpaper/schneider-electric-bg.jpg
    - require:
        - file: tools_directory

# Transfer the PowerShell script file
bginfo_shortcut_script:
  file.managed:
    - name: C:\install\tools\bginfo\create_bginfo_shortcut.ps1
    - source: salt://windows/bginfo/create_bginfo_shortcut.ps1
    - makedirs: True
    - require:
      - file: bginfo_config_file  # ensure config files exist first
      - file: bginfo_wallpaper

# Run the PowerShell script
create_bginfo_shortcut:
  cmd.run:
    - name: powershell -NoProfile -ExecutionPolicy Bypass -File C:\install\tools\bginfo\create_bginfo_shortcut.ps1
    - shell: cmd
    - require:
      - file: bginfo_shortcut_script

# Check if the BGInfo shortcut exists in the Startup folder
check_bginfo_shortcut_exists:
  cmd.run:
    - name: powershell -Command "if (-Not (Test-Path 'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\BGInfo.lnk')) { throw 'BGInfo shortcut not found in Startup folder' }"
    - shell: cmd
    - require:
      - cmd: create_bginfo_shortcut



