# set locale defaults for the Install
lang en_US.UTF-8
keyboard us
timezone UTC

# initialize any invalid partition tables and destroy all of their contents
zerombr

# erase all disk partitions and create a default label
clearpart --all --initlabel

# automatically create xfs partitions with no LVM and no /home partition
autopart --type=plain --fstype=xfs --nohome

# reboot after installation is successfully completed
reboot

# installation will run in text mode
text

# activate network devices and configure with DHCP
network --bootproto=dhcp


# create default user with sudo privileges
user --name=core --groups=wheel --password=edge

# set up the OSTree-based install with disabled GPG key verification, the base
# URL to pull the installation content, 'rhel' as the management root in the
# repo, and 'rhel/8/x86_64/edge' as the branch for the installation
ostreesetup --nogpg --url=http://10.0.2.2:8000/repo/ --osname=rhel --remote=edge --ref=rhel/8/x86_64/edge

%post

mkdir -p /home/admin/data
curl -L https://raw.githubusercontent.com/jeremyrdavis/quarkuscoffeeshop-majestic-monolith/main/init-postgresql.sql  --output /tmp/init-postgresql.sql
cp /tmp/init-postgresql.sql /home/admin/data/init-postgresql.sql

# Set the update policy to automatically download and stage updates to be
# applied at the next reboot
#stage updates as they become available. This is highly recommended
echo AutomaticUpdatePolicy=stage >> /etc/rpm-ostreed.conf

# IP_ADDRESS=$(hostname -I | awk '{print $1}')

cat > /etc/systemd/system/postgresql.service << 'EOF'
# container-postgresql-1.service
# autogenerated by Podman 4.0.2
# Wed Jun 29 15:08:19 EDT 2022

[Unit]
Description=Podman container-postgresql-1.service
Documentation=man:podman-generate-systemd(1)
Wants=network-online.target
After=network-online.target
RequiresMountsFor=%t/containers
BindsTo=pod-postgresql.service
After=pod-postgresql.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=always
TimeoutStopSec=70
ExecStartPre=/bin/rm -f %t/%n.ctr-id
ExecStart=/usr/bin/podman run --cidfile=%t/%n.ctr-id --cgroups=no-conmon --rm --pod-id-file %t/pod-postgresql.pod-id --sdnotify=conmon --replace -d -v /home/admin/data:/data:Z -e POSTGRESQL_DATABASE=coffeeshopdb -e POSTGRESQL_USER=coffeeshopuser -e POSTGRESQL_PASSWORD=redhat-21 --name=postgresql-1 registry.redhat.io/rhel8/postgresql-12
ExecStop=/usr/bin/podman stop --ignore --cidfile=%t/%n.ctr-id
ExecStopPost=/usr/bin/podman rm -f --ignore --cidfile=%t/%n.ctr-id
Type=notify
NotifyAccess=all

[Install]
WantedBy=default.target

# pod-postgresql.service
# autogenerated by Podman 4.0.2
# Wed Jun 29 15:08:19 EDT 2022

[Unit]
Description=Podman pod-postgresql.service
Documentation=man:podman-generate-systemd(1)
Wants=network-online.target
After=network-online.target
RequiresMountsFor=
Requires=container-postgresql-1.service
Before=container-postgresql-1.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
TimeoutStopSec=70
ExecStartPre=/bin/rm -f %t/pod-postgresql.pid %t/pod-postgresql.pod-id
ExecStartPre=/usr/bin/podman pod create --infra-conmon-pidfile %t/pod-postgresql.pid --pod-id-file %t/pod-postgresql.pod-id --name postgresql -p 5432:5432 --network rhel-edge --replace
ExecStart=/usr/bin/podman pod start --pod-id-file %t/pod-postgresql.pod-id
ExecStop=/usr/bin/podman pod stop --ignore --pod-id-file %t/pod-postgresql.pod-id -t 10
ExecStopPost=/usr/bin/podman pod rm --ignore -f --pod-id-file %t/pod-postgresql.pod-id
PIDFile=%t/pod-postgresql.pid
Type=forking

[Install]
WantedBy=default.target
EOF

systemctl enable postgresql.service

cat > /etc/systemd/system/quarkuscoffeeshop-majestic-monolith.service << 'EOF'
# container-quarkuscoffeeshop-majestic-monolith-1.service
# autogenerated by Podman 4.0.2
# Wed Jun 29 14:59:18 EDT 2022

[Unit]
Description=Podman container-quarkuscoffeeshop-majestic-monolith-1.service
Documentation=man:podman-generate-systemd(1)
Wants=network-online.target
After=network-online.target
RequiresMountsFor=%t/containers
BindsTo=pod-quarkuscoffeeshop-majestic-monolith.service
After=pod-quarkuscoffeeshop-majestic-monolith.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
TimeoutStopSec=70
ExecStartPre=/bin/rm -f %t/%n.ctr-id
ExecStart=/usr/bin/podman run --cidfile=%t/%n.ctr-id --cgroups=no-conmon --rm --pod-id-file %t/pod-quarkuscoffeeshop-majestic-monolith.pod-id --sdnotify=conmon --replace -d -e PGSQL_URL=jdbc:postgresql://127.0.0.1:5432/coffeeshopdb?currentSchema=coffeeshop -e PGSQL_USER=coffeeshopuser -e PGSQL_PASSWORD=redhat-21 -e PGSQL_URL_BARISTA=jdbc:postgresql://127.0.0.1:5432/coffeeshopdb?currentSchema=barista -e PGSQL_USER_BARISTA=coffeeshopuser -e PGSQL_PASSWORD_BARISTA=redhat-21 -e PGSQL_URL_KITCHEN=jdbc:postgresql://127.0.0.1:5432/coffeeshopdb?currentSchema=kitchen -e PGSQL_USER_KITCHEN=coffeeshopuser -e PGSQL_PASSWORD_KITCHEN=redhat-21 -e CORS_ORIGINS=http://127.0.0.1 -e STREAM_URL=http://127.0.0.1:8080/dashboard/stream -e STORE_ID=ATLANTA --name quarkuscoffeeshop-majestic-monolith-1 quay.io/quarkuscoffeeshop/quarkuscoffeeshop-majestic-monolith:v0.0.2
ExecStop=/usr/bin/podman stop --ignore --cidfile=%t/%n.ctr-id
ExecStopPost=/usr/bin/podman rm -f --ignore --cidfile=%t/%n.ctr-id
Type=notify
NotifyAccess=all

[Install]
WantedBy=default.target

# pod-quarkuscoffeeshop-majestic-monolith.service
# autogenerated by Podman 4.0.2
# Wed Jun 29 14:59:18 EDT 2022

[Unit]
Description=Podman pod-quarkuscoffeeshop-majestic-monolith.service
Documentation=man:podman-generate-systemd(1)
Wants=network-online.target
After=network-online.target
RequiresMountsFor=
Requires=container-quarkuscoffeeshop-majestic-monolith-1.service
Before=container-quarkuscoffeeshop-majestic-monolith-1.service

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
TimeoutStopSec=70
ExecStartPre=/bin/rm -f %t/pod-quarkuscoffeeshop-majestic-monolith.pid %t/pod-quarkuscoffeeshop-majestic-monolith.pod-id
ExecStartPre=/usr/bin/podman pod create --infra-conmon-pidfile %t/pod-quarkuscoffeeshop-majestic-monolith.pid --pod-id-file %t/pod-quarkuscoffeeshop-majestic-monolith.pod-id --name quarkuscoffeeshop-majestic-monolith -p 8080:8080 --network rhel-edge --replace
ExecStart=/usr/bin/podman pod start --pod-id-file %t/pod-quarkuscoffeeshop-majestic-monolith.pod-id
ExecStop=/usr/bin/podman pod stop --ignore --pod-id-file %t/pod-quarkuscoffeeshop-majestic-monolith.pod-id -t 10
ExecStopPost=/usr/bin/podman pod rm --ignore -f --pod-id-file %t/pod-quarkuscoffeeshop-majestic-monolith.pod-id
PIDFile=%t/pod-quarkuscoffeeshop-majestic-monolith.pid
Type=forking

[Install]
WantedBy=default.target
EOF

systemctl enable quarkuscoffeeshop-majestic-monolith.service


%end