windows:
  # Windows Update settings
  windows_update:
    auto_update: False
    reboot_after_install: False
    scheduled_install_day: "Sunday"
    scheduled_install_time: "03:00"

  # Power management
  power_management:
    hibernate_enabled: False
    sleep_timeout_minutes: 30
    display_timeout_minutes: 15

  # Security settings
  security:
    firewall_enabled: True
    windows_defender: True
    automatic_logon: False
    password_complexity: True
