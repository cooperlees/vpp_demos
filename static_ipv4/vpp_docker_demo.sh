#!/bin/bash

# Stolen + Hacked from https://wiki.fd.io/view/VPP/Configure_VPP_TAP_Interfaces_For_Container_Routing

CONTAINER_1_NAME="vpp1"
CONTAINER_2_NAME="vpp2"
CONTAINER_1_NS="vpp1_ns"
CONTAINER_2_NS="vpp2_ns"
DOCKER_IMAGE="vpp_sleeper:latest"
VPP_CONF="vpp-demo.conf"


exposedockernetns () {
    if [ "$1" == "" ]; then
        echo "usage: $0 <container_name>"
      echo "Exposes the netns of a docker container to the host"
          exit 1
        fi

        pid=`docker inspect -f '{{.State.Pid}}' $1`
        ln -s /proc/$pid/ns/net /var/run/netns/$1

        echo "netns of ${1} exposed as /var/run/netns/${1}"

        echo "try: ip netns exec ${1} ip addr list"
   return 0
}

#Create VPE Engine config
if [ ! -e "$VPP_CONF" ]; then
    echo "Generating VPP_CONF"
    cat > "$VPP_CONF" <<EOL
tap connect tapvpp1
tap connect tapvpp2
set int ip addr tap-0 10.6.9.2/25
set int ip addr tap-1 10.6.9.130/25
set int state tap-0 up
set int state tap-1 up
EOL
fi

#Remove old netns simlink
# rm -Rf /var/run/netns/*
# mkdir /var/run/netns

#Start VPE, use our config
sudo vpe unix {cli-listen 0.0.0.0:5002 startup-config $VPP_CONF } dpdk {no-pci no-huge num-mbufs 8192}
echo "Wait for VPE to configure and bring up interfaces"
sleep 2

# Add host TAP IPs
ip addr add 10.6.9.1/25 dev taphost1
ip addr add 10.6.9.129/25 dev taphost2

# Create a docker container
docker run -d --name "$CONTAINER_1_NAME" "$DOCKER_IMAGE"
docker run -d --name "$CONTAINER_2_NAME" "$DOCKER_IMAGE"
echo "Waiting for docker images to spin up"
sleep 2

#Expose our container to the 'ip netns exec' tools
exposedockernetns "$CONTAINER_1_NS"
exposedockernetns "$CONTAINER_2_NS"

#Move the 'tapcontainer1+2 VPP linux tap interface's into container1+2's network namespace respectivley.
ip link set tapcontainer1 netns "$CONTAINER_1_NS"
ip link set tapcontainer2 netns "$CONTAINER_2_NS"

#Give our in-container TAP interface's IP addresses and bring them up. Add routes back to the host TAP's via VPP.
ip netns exec "$CONTAINER_1_NS" ip addr add 10.6.9.2/25 dev tapcontainer1
ip netns exec "$CONTAINER_1_NS" ip link set tapcontainer1 up
ip netns exec "$CONTAINER_1_NS" ip route add 10.6.9.128/25 via 10.6.9.1
ip netns exec "$CONTAINER_1_NS" ip route add default via 10.6.9.1

ip netns exec "$CONTAINER_2_NS" ip addr add 10.6.9.130/25 dev tapcontainer2
ip netns exec "$CONTAINER_2_NS" ip link set tapcontainer2 up
ip netns exec "$CONTAINER_2_NS" ip route add 10.6.9.0/25 via 10.6.9.129
ip netns exec "$CONTAINER_1_NS" ip route add default via 10.6.9.129

#Let the host also know howto get to the container TAP via VPE
ip route add 10.6.9.0/25 via 10.6.9.1
ip route add 10.6.9.128/25 via 10.6.9.129

#Block ICMP out of the default docker0 container interfaces to prevent false positive results
ip netns exec "$CONTAINER_1_NS" iptables -A OUTPUT -p icmp -o eth0 -j REJECT
ip netns exec "$CONTAINER_2_NS" iptables -A OUTPUT -p icmp -o eth0 -j REJECT

echo "## Testing TIME ... "

echo "Pinging VPP1"
ping -c2 10.6.9.2

echo "Pinging VPP2"
ping -c2 10.6.9.130
