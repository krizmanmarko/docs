# use bgp for routing, but prevent arp
# arp only does one hop

echo 1 >/proc/sys/net/ipv4/ip_forward

for i in {0..4}; do ip netns add netns$i; done

# left branch
ip link add v0eth0 netns netns0 type veth peer name v1eth0 netns netns1
ip link add v1eth1 netns netns1 type veth peer name v3eth0 netns netns3

# right branch
ip link add v0eth1 netns netns0 type veth peer name v2eth0 netns netns2
ip link add v2eth1 netns netns2 type veth peer name v4eth0 netns netns4

nsenter --net=/run/netns/netns0 bash <<EOF
	ip link set lo up
	ip link set v0eth0 up
	ip link set v0eth1 up
	ip addr add 10.0.0.1/24 dev v0eth0
	ip addr add 10.0.1.1/24 dev v0eth1
EOF

# this will be bridged (arp just goes through the bridge)
nsenter --net=/run/netns/netns1 bash <<EOF
	ip link set lo up
	ip link set v1eth0 up
	ip link set v1eth1 up
	ip link add br0 type bridge
	ip link set br0 up
	ip link set v1eth0 master br0
	ip link set v1eth1 master br0
	#ip addr add 10.0.0.2/24 dev v1eth0
	#ip addr add 10.1.0.1/24 dev v1eth1
EOF
nsenter --net=/run/netns/netns3 bash <<EOF
	ip link set lo up
	ip link set v3eth0 up
	ip addr add 10.1.0.2/24 dev v3eth0
EOF

nsenter --net=/run/netns/netns2 bash <<EOF
	ip link set lo up
	ip link set v2eth0 up
	ip link set v2eth1 up
	ip addr add 10.0.1.2/24 dev v2eth0
	ip addr add 10.2.0.1/24 dev v2eth1
EOF
nsenter --net=/run/netns/netns4 bash <<EOF
	ip link set lo up
	ip link set v4eth0 up
	ip addr add 10.2.0.2/24 dev v4eth0
EOF
