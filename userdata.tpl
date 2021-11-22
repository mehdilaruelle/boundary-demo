#! /bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

#Install boundary, user and group
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install boundary

groupadd -f boundary
if ! id "boundary" &>/dev/null; then
  useradd --system -g boundary boundary
fi

chown boundary:boundary /usr/bin/boundary

NAME="boundary"
BOUNDARY_PATH=$(whereis boundary | cut -f 2 -d " ")

#Boundary controler installation
TYPE="controller"

#Systemd configuration file
cat << EOF > /etc/systemd/system/$NAME-$TYPE.service
[Unit]
Description=$NAME $TYPE

[Service]
ExecStart=$BOUNDARY_PATH server -config /etc/$NAME-$TYPE.hcl
User=boundary
Group=boundary
LimitMEMLOCK=infinity
#Capabilities=CAP_IPC_LOCK+ep
#CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF

#Boundary controler configuration file
cat << EOF > /etc/$NAME-$TYPE.hcl
disable_mlock = true

controller {
  name = "demo-controller"
  description = "A default controller for demonstration"

  database {
      url = "${db_url}"
  }
}

listener "tcp" {
  address = "0.0.0.0:9200"
  purpose = "api"

  tls_disable = true
}

listener "tcp" {
  address = "0.0.0.0:9201"
  purpose = "cluster"

  tls_disable = true
}

kms "awskms" {
  purpose    = "root"
  region     = "eu-west-1"
  kms_key_id = "${key_id_root}"
}

kms "awskms" {
  purpose    = "worker-auth"
  region     = "eu-west-1"
  kms_key_id = "${key_id_worker}"
}

kms "awskms" {
  purpose    = "recovery"
  region     = "eu-west-1"
  kms_key_id = "${key_id_recovery}"
}
EOF

chown boundary:boundary /etc/$NAME-$TYPE.hcl

#Init the database and restart the service
$BOUNDARY_PATH database init -config /etc/$NAME-$TYPE.hcl

chmod 664 /etc/systemd/system/$NAME-$TYPE.service
systemctl daemon-reload
systemctl enable $NAME-$TYPE
systemctl start $NAME-$TYPE

#Boundary worker installation
TYPE="worker"

#Systemd configuration file
cat << EOF > /etc/systemd/system/$NAME-$TYPE.service
[Unit]
Description=$NAME $TYPE

[Service]
ExecStart=$BOUNDARY_PATH server -config /etc/$NAME-$TYPE.hcl
User=boundary
Group=boundary
LimitMEMLOCK=infinity
#Capabilities=CAP_IPC_LOCK+ep
#CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
EOF

#Boundary worker configuration file
cat << EOF > /etc/$NAME-$TYPE.hcl
listener "tcp" {
    purpose = "proxy"
    tls_disable = true
    address = "0.0.0.0:9202"
}

worker {
  name = "demo-worker"
  description = "A default worker for demonstration"

  controllers = [
    "127.0.0.1",
  ]

  public_addr = "$(curl http://169.254.169.254/latest/meta-data/public-ipv4)"
}

kms "awskms" {
  purpose    = "worker-auth"
  region     = "eu-west-1"
  kms_key_id = "${key_id_worker}"
}
EOF

#Restart the service
chown boundary:boundary /etc/$NAME-$TYPE.hcl

chmod 664 /etc/systemd/system/$NAME-$TYPE.service
systemctl daemon-reload
systemctl enable $NAME-$TYPE
systemctl start $NAME-$TYPE
