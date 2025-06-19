# windows/software.sls
include:
  - windows.chocolatey

choco_bginfo:
  chocolatey.installed:
    - name: bginfo
