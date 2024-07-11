# use bgp for routing, but prevent arp
# arp only does one hop

# check out https://dustinspecker.com/posts/kubernetes-networking-from-scratch-bgp-bird-advertise-pod-routes/

killall bird
for i in {0..4}; do ip netns del netns${i}; done

echo 1 >/proc/sys/net/ipv4/ip_forward

for i in {0..4}; do ip netns add netns${i}; done

# arp from 3 does not reach 0, but bgp still announces routes
#   0
#  / \
# 1   2
# |   |
# 3   4

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

nsenter --net=/run/netns/netns1 bash <<EOF
	ip link set lo up
	ip link set v1eth0 up
	ip link set v1eth1 up
	ip addr add 10.0.0.2/24 dev v1eth0
	ip addr add 153.5.81.1/24 dev v1eth1
EOF
nsenter --net=/run/netns/netns3 bash <<EOF
	ip link set lo up
	ip link set v3eth0 up
	ip addr add 153.5.81.21/24 dev v3eth0
	ip route add default via 153.5.81.1 dev v3eth0	# end user device
EOF

nsenter --net=/run/netns/netns2 bash <<EOF
	ip link set lo up
	ip link set v2eth0 up
	ip link set v2eth1 up
	ip addr add 10.0.1.2/24 dev v2eth0
	ip addr add 153.5.81.1/24 dev v2eth1
EOF
nsenter --net=/run/netns/netns4 bash <<EOF
	ip link set lo up
	ip link set v4eth0 up
	ip addr add 153.5.81.21/24 dev v4eth0
	ip route add default via 153.5.81.1 dev v4eth0	# end user device
EOF

# start bird
for i in {0..2}
do
	nsenter --net=/run/netns/netns${i} bird -c /root/conf/${i}-bird.conf -s /run/bird/${i}-bird.ctl
done
