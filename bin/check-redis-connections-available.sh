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
connection_check="$(/bin/redis-cli "$5" "$6" "$7" "$8" PING 2>&1)"
if [ $? -ge 1 ]
then
echo "Connection ERROR: $connection_check"
exit 1
else
max_clients="$(/bin/redis-cli "$5" "$6" "$7" "$8" config get maxclients 2>&1 | cut -d ' ' -f2 | tail -1 | tr -d $'\r')"
connected_clients="$(/bin/redis-cli "$5" "$6" "$7" "$8" info clients 2>&1 | sed -n '2p' | cut -d ':' -f2 | tr -d $'\r')"
available_connection="$(echo "$max_clients-$connected_clients" | bc -l | tr -d $'\r')"

c_count="$(echo "$2" | bc)"
w_count="$(echo "$4" | bc)"

if [ "$available_connection" -le "$c_count" ]
then
echo "CRITICAL Only $available_connection connections left available ($connected_clients/$max_clients) on Redis $6:$8"
exit 1
elif [ "$available_connection" -le "$w_count" ]
then
echo "WARNING Only $available_connection connections left available ($connected_clients/$max_clients) on Redis $6:$8"
exit 1
else
echo "OK There are $available_connection connections available ($connected_clients/$max_clients) on Redis $6:$8"
exit 0
fi
fi