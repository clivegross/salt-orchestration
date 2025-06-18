# Common default settings for all minions

# Organization information
organization:
  name: "Your Organization"
  domain: "example.com"
  timezone: "Australia/Brisbane"

# Default users and groups
default_users:
  admin_user: "saltadmin"
  service_account: "saltservice"

# Network settings
network:
  dns_servers:
    - "8.8.8.8"
    - "8.8.4.4"
  ntp_servers:
    - "0.au.pool.ntp.org"
    - "1.au.pool.ntp.org"
