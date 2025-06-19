# salt/roles/schneider-electric/ebo/v6/enterprise-server-firewall.sls
firewall_enabled:
  win_firewall.enabled:
    - name: allprofiles

open_https_port:
  win_firewall.add_rule:
    - name: "Allow HTTPS"
    - localport: 443
    - protocol: TCP
    - action: allow
    - dir: in

open_csp_port:
  win_firewall.add_rule:
    - name: "Allow CSP"
    - localport: 4444
    - protocol: TCP
    - action: allow
    - dir: in

open_graphdb_port:
  win_firewall.add_rule:
    - name: "Allow GraphDB/Semantics"
    - localport: 7200
    - protocol: TCP
    - action: allow
    - dir: in

open_saml_auth_port:
  win_firewall.add_rule:
    - name: "Allow SAML Auth"
    - localport: 9615
    - protocol: TCP
    - action: allow
    - dir: in

open_bacnet_ip_port:
  win_firewall.add_rule:
    - name: "Allow BACnet/IP"
    - localport: 47808
    - protocol: UDP
    - action: allow
    - dir: in

open_modbus_tcp_port:
  win_firewall.add_rule:
    - name: "Allow Modbus TCP"
    - localport: 502
    - protocol: TCP
    - action: allow
    - dir: in

