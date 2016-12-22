
### A Working `tc` Configuration

This works on my machine... 

The subnet `10.42.0.0/16` is divided into two different subnets using virtual 
interfaces. Bridges are unnecessary, LAN and WAN are masqueraded, twice...
(Working on that.)

`10.42.2.0/24` is shaped to limit the total bandwidth. It's not QoS, 
I don't have the patience for that. My ISP has my account termination letter 
just waiting to be mailed out.

`10.42.0.0/24` is 'reserved' for static assignments and what I don't want 
bandwidth limited.

`fd9a:7445:37e8::/48` is assigned to the network, but link-local only. 
Traffic shaping isn't applied to IPv6 networks.

LAN and USB interfaces renamed to something sane.
Google NTP + DNS
