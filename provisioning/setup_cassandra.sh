HELP="Takes a single integer argument like 0 or 1 representing which node this is."

node=$1
if [ -z "${node}" ]; then
    echo "VAR is unset or set to the empty string"
    exit 1
fi


function create_fs_and_mount {
    DEVICE_NAME=/dev/xvdh
    echo "Creating fs and mounting..."
    sudo mkfs -t ext4 $DEVICE_NAME
    sudo mkdir -p /var/lib/cassandra
    sudo mount $DEVICE_NAME /var/lib/cassandra
    echo "Done creating fs and mounting."
}


create_fs_and_mount
sudo apt-get update
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9
apt_source='deb http://repos.azulsystems.com/debian stable main'
apt_list='/etc/apt/sources.list.d/zulu.list'
echo "$apt_source" | sudo tee "$apt_list" > /dev/null
sudo apt-get update
sudo apt-get install -y zulu-8
sudo apt-get install -y emacs
sudo apt-get install -y python-pip
sudo pip install cassandra-driver
echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y gcc libev4 libev-dev python-dev
sudo apt-get install -y dsc30 -V
sudo apt-get install -y cassandra-tools
sudo service cassandra stop
sudo rm -rf /var/lib/cassandra/data/system/*
sudo sed -i "s/cluster_name: 'Test Cluster'/cluster_name: 'jagat_cassandra_cluster'/g" /etc/cassandra/cassandra.yaml
#Seed nodes are used to bootstrap new nodes into the cluster.  Without a seed node new nodes can't join.  Too many is bad but there should be more than one.
sudo sed -i "s/seeds: \"127.0.0.1\"/seeds: \"10.2.5.170,10.2.5.171\"/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/listen_address: localhost/listen_address:/g" /etc/cassandra/cassandra.yaml
sudo sed -i "s/rpc_address: localhost/rpc_address: 0.0.0.0/g" /etc/cassandra/cassandra.yaml
if [ $node == "0" ]; then
    sudo sed -i "s/# broadcast_rpc_address: 1.2.3.4/broadcast_rpc_address: 10.2.5.170/g" /etc/cassandra/cassandra.yaml
elif [ $node = "1" ]; then
    sudo sed -i "s/# broadcast_rpc_address: 1.2.3.4/broadcast_rpc_address: 10.2.5.171/g" /etc/cassandra/cassandra.yaml
elif [ $node = "2" ]; then
    sudo sed -i "s/# broadcast_rpc_address: 1.2.3.4/broadcast_rpc_address: 10.2.5.172/g" /etc/cassandra/cassandra.yaml
else
    echo "$HELP"
    exit 1
fi

sudo service cassandra start
