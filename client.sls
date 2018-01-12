burp_conf_dir:
  file.directory:
    - name: /etc/burp
    - user: root
    - group: burp
    - mode: 770
    - clean: True
    - exclude_pat: E@^ssl_.*\.pem$
    - require:
      - pkg: burp
      - group: burp

burp_client_config:
  file.managed:
    - name: /etc/burp/burp.conf
    - user: root
    - group: root
    - mode: 640
    - source: salt://burp/files/burp.conf
    - template: jinja
    - require_in:
      - file: burp_conf_dir

burp:
  pkg.installed:
    - pkgs:
      - burp-backup
    - require:
      - sls: pacman
  group.present:
    - name: burp
  user.present:
    - name: burp
    - gid_from_name: True
    - shell: /usr/bin/nologin
    - home: /etc/burp
    - createhome: False
  service.running:
    - name: burp-client.timer
    - enable: True
