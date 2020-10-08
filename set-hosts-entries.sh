#!/bin/bash

vms=$(pct list | sed "s/  \+/ /g" | sed "/Lock/d")
rm .our_entries
echo "$vms" | while IFS= read -r line 
do
  vm=$(echo "$line" | cut -d' ' -f1)
  status=$(echo "$line" | cut -d ' ' -f2)
  name=$(echo "$line" | cut -d' ' -f3)
  if [ "$status" == "running" ]; then
    ip=$(pct exec $vm -- ip addr show | grep 192 | cut -d" " -f6 | cut -d"/" -f1)
    #pct exec $vm -- apt install shtool -y
    #pct exec $vm -- npm install --silent npm@latest -g
    #pct exec $vm -- npm install --silent hostile -g 
    what=$(pct exec $vm -- shtool platform -v -F "%sp (%ap)")
    if [ $z "$ip" ]; then
      # echo "# Proxmox VM $vm; $what" > ".ip_$name"
      #pct exec $vm -- /usr/local/lib/node_modules/hostile/bin/cmd.js set $ip $name
      # our_entries="$our_entries\n$ip $name"
      our_entries+=( "$ip $name" )
      echo "$ip $name" >> .our_entries
    fi
  fi
done
echo "$vms" | while IFS= read -r line 
do
  vm=$(echo "$line" | cut -d' ' -f1)
  status=$(echo "$line" | cut -d ' ' -f2)
  if [ "$status" == "running" ]; then
    while read line2; do
      ip=$(echo "$line2" | cut -d' ' -f1)
      name=$(echo "$line2" | cut -d' ' -f2)
      # echo "$vm $ip $name ll"
      pct exec $vm -- /usr/local/lib/node_modules/hostile/bin/cmd.js set $ip $name
    done <.our_entries
  fi
done
