# Install pyenv-win via Chocolatey
install_pyenv_win:
  chocolatey.installed:
    - name: pyenv-win
    - refresh: True