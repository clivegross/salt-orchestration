chocolatey_bootstrap:
  chocolatey.bootstrapped

install_git:
  chocolatey.installed:
    - name: git
    - require:
      - chocolatey: chocolatey_bootstrap