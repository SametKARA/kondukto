apt update
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common jq --yes


curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt-get install docker-ce docker-ce-cli containerd.io --yes

curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

export MONGODB_IMAGE=mongo:5.0
export MONGODB_S1_RS=rs1
export MONGODB_S1_PRIMARY_PORT=17001
export MONGODB_S1_SECONDARY1_PORT=17002
export MONGODB_S1_SECONDARY2_PORT=17003
export MONGODB_S2_RS=rs2
export MONGODB_S2_PRIMARY_PORT=17004
export MONGODB_S2_SECONDARY1_PORT=17005
export MONGODB_S2_SECONDARY2_PORT=17006
export MONGODB_CONFIGSVR_RS=csReplSet
export MONGODB_CONFIGSVR1_PORT=17007
export MONGODB_CONFIGSVR2_PORT=17008
export MONGODB_CONFIGSVR3_PORT=17009
export MONGODB_MONGOS_PORT=17000

chown -R 472:0 * grafana/

docker-compose up -d

mkdir mongodb-exporter

cd mongodb-exporter
wget https://github.com/percona/mongodb_exporter/releases/download/v0.20.5/mongodb_exporter-0.20.5.linux-amd64.tar.gz
tar xvzf mongodb_exporter-0.20.5.linux-amd64.tar.gz

cd mongodb_exporter-0.20.5.linux-amd64
cp mongodb_exporter /usr/local/bin/mongodb_exporter_mongos
cp mongodb_exporter /usr/local/bin/mongodb_exporter_cnf
cp mongodb_exporter /usr/local/bin/mongodb_exporter_rs1
cp mongodb_exporter /usr/local/bin/mongodb_exporter_rs2

cd ~
cp mongodb_exporter_mongos.service /lib/systemd/system/
cp mongodb_exporter_cnf.service /lib/systemd/system/
cp mongodb_exporter_rs1.service /lib/systemd/system/
cp mongodb_exporter_rs2.service /lib/systemd/system/

systemctl daemon-reload
systemctl start mongodb_exporter_mongos.service
systemctl start mongodb_exporter_cnf.service
systemctl start mongodb_exporter_rs1.service
systemctl start mongodb_exporter_rs2.service

docker exec -it grafana grafana-cli plugins install vertamedia-clickhouse-datasource
docker exec -it grafana grafana-cli plugins install digiapulssi-breadcrumb-panel
docker exec -it grafana grafana-cli plugins install yesoreyeram-boomtable-panel
docker exec -it grafana grafana-cli plugins install petrslavotinek-carpetplot-panel
docker exec -it grafana grafana-cli plugins install jdbranham-diagram-panel
docker exec -it grafana grafana-cli plugins install natel-discrete-panel
docker exec -it grafana grafana-cli plugins install camptocamp-prometheus-alertmanager-datasource

docker restart grafana
