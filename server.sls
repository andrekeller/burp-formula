include:
  - burp.client

burp_data_dir:
  file.directory:
    - name: /srv/burp/data
    - user: burp
    - group: burp
    - mode: 770
    - require:
      - pkg: burp
      - file: burp_server
      - file: burp_server_conf
      - user: burp
    - watch_in:
      - service: burp_server

burp_client_dir:
  file.directory:
    - name: /etc/burp/clients
    - user: root
    - group: burp
    - mode: 750
    - clean: True
    - require:
      - pkg: burp
    - require_in:
      - file: burp_conf_dir
    - watch_in:
      - service: burp_server

burp_ca_conf:
  file.managed:
    - name: /etc/burp/burp-ca.conf
    - user: root
    - group: burp
    - mode: 640
    - source: salt://burp/files/burp-ca.conf
    - template: jinja
    - require_in:
      - file: burp_conf_dir
    - watch_in:
      - service: burp_server
burp_server_conf:
  file.managed:
    - name: /etc/burp/burp-server.conf
    - user: root
    - group: burp
    - mode: 640
    - source: salt://burp/files/burp-server.conf
    - template: jinja
    - watch_in:
      - service: burp_server
    - require_in:
      - file: burp_conf_dir

burp_tmpfiles_conf:
  file.managed:
    - name: /etc/tmpfiles.d/burp-server.conf
    - user: root
    - group: root
    - mode: 644
    - contents:
      - 'd /run/burp 0750 burp burp -'
    - watch_in:
      - service: burp_server
  cmd.wait:
    - name: 'systemd-tmpfiles --create /etc/tmpfiles.d/burp-server.conf'
    - watch:
      - file: burp_tmpfiles_conf

burp_server:
  file.directory:
    - name: /srv/burp
    - user: burp
    - group: burp
    - mode: 770
  service.running:
    - name: burp-server.service
    - enable: True
    - watch:
      - file: burp_conf_dir

{% for client in salt['pillar.get']('burp_clients', []) %}
/etc/burp/clients/{{ client }}:
  file.managed:
    - user: root
    - group: burp
    - mode: 640
    - makedirs: True
    - contents:
      - 'password = {{ salt['pillar.get']('burp_password') }}'
    - require_in:
      - file: burp_client_dir
    - watch_in:
      - service: burp_server
{% endfor %}
