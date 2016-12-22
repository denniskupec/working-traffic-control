#!/bin/sh

IF=eth0:0
SUB=10.42.2.0/24

start()
{
  tc qdisc add dev $IF root handle 1: htb default 30
  tc class add dev $IF parent 1: classid 1:1 htb rate 6mbit
  tc class add dev $IF parent 1: classid 1:2 htb rate 1200kbit
}

start-slow()
{
  tc qdisc add dev $IF root handle 1: htb default 30
  tc class add dev $IF parent 1: classid 1:1 htb rate 3mbit
  tc class add dev $IF parent 1: classid 1:2 htb rate 600kbit
}

set-speed()
{
  tc qdisc add dev $IF root handle 1: htb default 30
  tc class add dev $IF parent 1: classid 1:1 htb rate "$1"mbit
  tc class add dev $IF parent 1: classid 1:2 htb rate "$2"mbit
}

add-rules()
{
  tc filter add dev $IF protocol ip parent 1:0 prio 1 u32 match ip dst $SUB flowid 1:1
  tc filter add dev $IF protocol ip parent 1:0 prio 1 u32 match ip src $SUB flowid 1:2
}

stop()
{
  tc qdisc del dev $IF root
}

status()
{
  tc -s qdisc ls dev $IF
}

case "$1" in

  start)
    echo -n "starting normal tc rules: "
    start
    add-rules
    echo "done"
    ;;

  start-slow)
    echo -n "starting ultra-slow tc rules: "
    start-slow
    add-rules
    echo "done"
    ;;

  stop)
    echo -n "stopping tc: "
    stop
    ;;

  set)
    if [ -z "$2" ] || [ -z "$3" ] ; then
      echo "Usage: tc.sh set [down mbits] [up mbits]"
      exit
    fi

    set-speed $2 $3
    add-rules
    echo "done"
    ;;


  restart)
    echo -n "restarting tc: "
    stop
    sleep 1
    start
    echo "done"
    ;;

  status)
    echo "tc stats for interface $IF:"
    status
    echo ""
    ;;

  *)

    pwd=$(pwd)
    echo "Usage: tc.sh {start|start-slow|set|stop|restart|status} [down mbits] [up mbits]"
    ;;

esac

exit 0
