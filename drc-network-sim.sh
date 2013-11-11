#!/bin/bash
ETH_IN='eth0'
ETH_OUT='eth1'
BRIDGE='br0'
LATANCY_LOW='100ms'
LATANCY_HIGH='1000ms'
SLEEP_TIME=60

echo 'setup bridge'
brctl addbr $BRIDGE
brctl addif $BRIDGE $ETH_IN
brctl addif $BRIDGE $ETH_OUT
ifconfig $BRIDGE up

echo 'setup interface'
tc qdisc add dev $ETH_IN root netem delay 100ms
tc qdisc add dev $ETH_OUT root netem delay 100ms
sleep 1
echo 'setup default settings'
tc qdisc change dev $ETH_IN root netem delay 0ms
tc qdisc change dev $ETH_OUT root netem delay 0ms

Loop()
{
  tc qdisc change dev $ETH_OUT root netem delay $LATANCY_LOW
  echo 'Latency = '$LATANCY_LOW
  sleep $SLEEP_TIME
  tc qdisc change dev $ETH_OUT root netem delay $LATANCY_HIGH
  echo 'Latency = '$LATANCY_HIGH
  sleep $SLEEP_TIME
  Loop
  exit 0
}

echo 'start loop'
Loop
