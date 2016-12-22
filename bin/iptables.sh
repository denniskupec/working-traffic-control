#!/bin/sh

in_TCP='22,53,80,123,443,546,547,8080'
in_UDP='53,123,542,546,547'

# do ip6tables too

iptables -F
iptables -t nat -F

iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT

iptables -N LOGGING
iptables -A LOGGING -m limit --limit 10/min -j LOG --log-prefix "IPTables Drop: " --log-level 7


iptables -A FORWARD -s 10.42.0.0/16 -i eth0+ -o usb0 -m conntrack --ctstate NEW -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.42.0.0/16 -o usb0 -j MASQUERADE 


iptables -A INPUT -j LOGGING
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i eth0 -j ACCEPT

iptables -A INPUT -p tcp -m multiport --dports $in_TCP -j ACCEPT
iptables -A INPUT -p udp --dport $in_UDP -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables -A LOGGING -j DROP
iptables -A INPUT -j DROP

iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

iptables-save | tee /etc/iptables.sav
