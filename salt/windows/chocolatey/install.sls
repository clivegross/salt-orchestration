# Install Chocolatey itself (this still needs cmd.run since there's no chocolatey.bootstrap state)
chocolatey_install_script:
  cmd.run:
    - name: |
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    - shell: powershell
    - unless: "where.exe choco"
    - timeout: 300

chocolatey_verify:
  cmd.run:
    - name: "choco --version"
    - shell: cmd
    - require:
        - cmd: chocolatey_install_script
