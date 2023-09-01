#! /bin/bash
#   check-redis-connection.sh
#
# DESCRIPTION:
#   This is a custom plugin written in shell script to check the number of connections available on redis
#
# OUTPUT:
#   Number of available connections in plain text
#
# PLATFORMS:
#   Linux
#
# USAGE:
#   check-redis-connections-available.sh -c CRITICAL_COUNT -w WARNING_COUNT -h REDIS_HOST -p PORT
connection_check="$(/bin/redis-cli "$5" "$6" "$7" "$8" config get maxclients 2>&1)"
if [ $? -ge 1 ]
then
echo "Connection ERROR: $connection_check"
exit 1
else
max_clients="$(/bin/redis-cli "$5" "$6" "$7" "$8" config get maxclients 2>&1 | cut -d ' ' -f2 | tail -1 | awk '{print $1-0}')"
connected_clients="$(/bin/redis-cli "$5" "$6" "$7" "$8" info clients 2>&1 | sed -n '2p' | cut -d ':' -f2 | awk '{print $1-0}')"
available_connection="$(echo "$max_clients" "$connected_clients" | awk '{print $1 - $2}')"

c_count="$(echo "$2" | awk '{print $1-0}')"
w_count="$(echo "$4" | awk '{print $1-0}')"

echo "$available_connection $connected_clients $max_clients $c_count $w_count $6 $8" | awk '{if ($1 <= $4) {print "CRITICAL Only ",$1,"connections left available (",$2,"/",$3,") on Redis",$6,":",$7; exit 1} else if ($1 <= $5) {print "WARNING Only ",$1,"connections left available (",$2,"/",$3,") on Redis",$6,":",$7; exit 1} else {print "OK There are",$1,"connections available (",$2,"/",$3,") on Redis",$6,":",$7; exit 0}}'

fi