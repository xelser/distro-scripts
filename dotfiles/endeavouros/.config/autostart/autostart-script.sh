#!/bin/bash

# network time (update upon startup)
[ -f /bin/htpdate ] && sudo htpdate -D -s -i /run/htpdate.pid google.com

