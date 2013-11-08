#!/usr/bin/env python
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

import sys
import time
from ctypes import *
import commands as c
import curses
stdscr = curses.initscr()
curses.cbreak()
stdscr.keypad(1)

sleepTime = 60  #sleep time in sec

sIndent = 11
sLine = 6

stdscr.refresh()


stdscr.addstr(2, 2, "DRC-Network Sim: Daniel M. Lofaro <dan@danLofaro.com>")
stdscr.addstr(3, 2, "-----------------------------------------------------")
stdscr.addstr(4, 2, "Input: eth0  -  Output: eth1")

stdscr.addstr(sLine,2,"Status:")

stdscr.addstr(sLine, sIndent,"Starting          ")
stdscr.refresh()
c.getoutput('brctl addbr br0')
c.getoutput('brctl addif br0 eth0')
c.getoutput('brctl addif br0 eth1')

c.getoutput('tc qdisc add dev eth0 root tbf rate 100kbit latency 100ms burst 1540')
c.getoutput('tc qdisc add dev eth1 root netem delay 100ms')

c.getoutput('tc qdisc change dev eth0 root tbf rate 100kbit latency 100ms burst 1540')
c.getoutput('tc qdisc change dev eth1 root netem delay 0ms')


state = 0

while True:
    if state == 0: 
        c.getoutput('tc qdisc change dev eth0 root tbf rate 1000kbit latency 100ms burst 1540')
        stdscr.addstr(sLine, sIndent,"1Mbps - 100ms latency         ")
        state = 1 # change to 1
    elif state == 1:
        c.getoutput('tc qdisc change dev eth0 root tbf rate 100kbit latency 100ms burst 1540')
        stdscr.addstr(sLine, sIndent,"100kbps - 100ms latency         ")
        state = 2 # change to 1
    elif state == 2:
        c.getoutput('tc qdisc change dev eth0 root tbf rate 1000kbit latency 1000ms burst 1540')
        stdscr.addstr(sLine, sIndent,"1Mbps - 1000ms latency         ")
        state = 3 # change to 1
    elif state == 3:
        c.getoutput('tc qdisc change dev eth0 root tbf rate 100kbit latency 1000ms burst 1540')
        stdscr.addstr(sLine, sIndent,"100kbps - 1000ms latency         ")
        state = 0 # change to 1
    stdscr.refresh()
    time.sleep(sleepTime)


