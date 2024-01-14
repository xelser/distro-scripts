#!/bin/bash

# keyboard led
xset led 3
numlockx

# network time (update upon startup)
[ -f /bin/htpdate ] && sudo htpdate -D -s -i /run/htpdate.pid www.linux.org 
