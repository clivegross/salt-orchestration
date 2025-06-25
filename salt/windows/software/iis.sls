install_iis_with_required_features:
  win_feature.installed:
    - names:
        - Web-Server           # IIS Web Server
        - Web-CGI              # CGI
        - Web-ISAPI-Ext        # ISAPI Extensions
    - restart: False           # Optional: don't auto-reboot
