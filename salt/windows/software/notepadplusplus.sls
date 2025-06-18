include:
  - windows.chocolatey

# Use official Salt chocolatey state
notepadplusplus:
  chocolatey.installed:
    - name: notepadplusplus
    # - version: latest
    - require:
        - cmd: chocolatey_verify
