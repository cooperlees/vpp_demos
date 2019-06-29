#!/bin/bash

NS_1="vpp1"
NS_1_INT="tap0"
NS_2="vpp2"
NS_2_INT="tap1"
SLEEP_TIME=5
VPP_CONF="cli.conf"

function load_vpp_running_config() {
  while IFS= read -r line
  do
    vppctl "$line"
  done < "$1"
}

echo "Deleting netns if they exist"
ip netns del $NS_1
ip netns del $NS_2

# Restart VPP to be clear
echo "Restarting VPP and waiting $SLEEP_TIME seconds for it to start"
systemctl restart vpp
sleep $SLEEP_TIME

echo "Loading vppctl config"
load_vpp_running_config "${VPP_CONF}"

# Create NS
echo "Adding netns $NS_1 + $NS_2"
ip netns add "$NS_1"
ip netns add "$NS_2"

# Move tapX to NS
ip link set "$NS_1_INT" netns "$NS_1"
ip link set "$NS_2_INT" netns "$NS_2"

# Add IP + bring up ns interfaces
ip netns exec $NS_1 ip addr add fc00:0:0:100::69/64 dev tap0
ip netns exec $NS_1 ip link set up dev lo
ip netns exec $NS_1 ip link set up dev tap0
ip netns exec $NS_2 ip addr add fc00:0:0:200::69/64 dev tap1
ip netns exec $NS_2 ip link set up dev lo
ip netns exec $NS_2 ip link set up dev tap1

# Add default routes - Seems we learn a default route via RA too
ip netns exec $NS_1 ip route add default via fc00:0:0:100::1
ip netns exec $NS_2 ip route add default via fc00:0:0:200::1
