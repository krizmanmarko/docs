send "nsenter --net=/run/netns/netns0 bash" C-m
send 'export PS1="(netns0) $PS1"' C-m
send 'birdc -s /run/bird/0-bird.ctl' C-m
send 'show protocols' C-m
split-window -v
send "nsenter --net=/run/netns/netns1 bash" C-m
send 'export PS1="(netns1) $PS1"' C-m
send 'birdc -s /run/bird/1-bird.ctl' C-m
send 'show protocols' C-m
split-window -h
send "nsenter --net=/run/netns/netns2 bash" C-m
send 'export PS1="(netns2) $PS1"' C-m
send 'birdc -s /run/bird/2-bird.ctl' C-m
send 'show protocols' C-m

new-window
send "nsenter --net=/run/netns/netns3 bash" C-m
send 'export PS1="(netns3) $PS1"' C-m
split-window -h
send "nsenter --net=/run/netns/netns4 bash" C-m
send 'export PS1="(netns4) $PS1"' C-m
