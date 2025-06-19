# salt/roles/schneider-electric/ebo/v6/enterprise-central-firewall.sls
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
