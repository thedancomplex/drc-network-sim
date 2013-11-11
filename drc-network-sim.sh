#!/bin/bash
# /* -*-  indent-tabs-mode:t; tab-width: 8; c-basic-offset: 8  -*- */
# /*
# Copyright (c) 2013, Daniel M. Lofaro
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the author nor the names of its contributors may
#       be used to endorse or promote products derived from this software
#       without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# */

ETH_IN='eth0'
ETH_OUT='eth1'
BRIDGE='br0'
LATENCY_LOW='100ms'
LATENCY_HIGH='1000ms'
SLEEP_TIME=60

echo 'DRC-Network Sim: Daniel M. Lofaro <dan@danLofaro.com>'
echo '-----------------------------------------------------'
echo 'Input: '$ETH_IN'  -  Output: '$ETH_OUT
echo 'Min Latency: '$LATENCY_LOW' - Max Latency: '$LATENCY_HIGH


echo '*setup bridge'
brctl addbr $BRIDGE
brctl addif $BRIDGE $ETH_IN
brctl addif $BRIDGE $ETH_OUT
ifconfig $BRIDGE up

echo '*setup interface'
tc qdisc add dev $ETH_IN root netem delay 100ms
tc qdisc add dev $ETH_OUT root netem delay 100ms
sleep 1
echo '*setup default settings'
tc qdisc change dev $ETH_IN root netem delay 0ms
tc qdisc change dev $ETH_OUT root netem delay 0ms

Loop()
{
  tc qdisc change dev $ETH_OUT root netem delay $LATENCY_LOW
  echo 'Latency = '$LATENCY_LOW
  sleep $SLEEP_TIME
  tc qdisc change dev $ETH_OUT root netem delay $LATENCY_HIGH
  echo 'Latency = '$LATENCY_HIGH
  sleep $SLEEP_TIME
  Loop
  exit 0
}

echo '*start loop'
Loop
