# pillar/top.sls
base:
  "*":
    - common.defaults
  "os:Windows":
    - match: grain
    - windows.config
    - windows.software
  "os:Linux":
    - match: grain
    - linux.config
