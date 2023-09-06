#! /bin/bash
#
#   check-redis-memory-percentage.sh
#
# DESCRIPTION:
#   This is a custom plugin written in shell script to check the memory usage of Redis in percentage
#
# OUTPUT:
#   Redis memory usage percentage in plain text
#
# PLATFORMS:
#   Linux
#
# USAGE:
#   check-redis-memory-percentage.sh -c Critical_percentage -w warning_percentage -h Redis_host_ip -p port
#


connection_check="$(/bin/redis-cli "$5" "$6" "$7" "$8" PING 2>&1)"
if [ $? -ge 1 ]
then
echo "Connection ERROR: $connection_check"
exit 1
else
max_memory="$(/bin/redis-cli "$5" "$6" "$7" "$8" info memory | grep 'maxmemory:' | cut -d ':' -f2 | tr -d $'\r')"
if [ $((max_memory)) -eq 0 ]
then
total_memory="$(/bin/redis-cli "$5" "$6" "$7" "$8" info memory | grep 'total_system_memory:' | cut -d ':' -f2 | tr -d $'\r' )"
fi

memory_in_use="$(/bin/redis-cli "$5" "$6" "$7" "$8" info memory | grep 'used_memory:' | cut -d ':' -f2 | tr -d $'\r')"

used_memory="$(echo "($memory_in_use/$total_memory)*100"|bc -l)"
used_memory="$(printf "%.2f" "$used_memory")"

c_memory="$(echo "$2" | bc -l)"
w_memory="$(echo "$4" | bc -l)"

if (( $(echo "$used_memory >= $c_memory" |bc -l) ))
then
echo "CRITICAL Redis running on $6:$8 is above critical limit: $used_memory %"
exit 1
elif (( $(echo "$used_memory >= $w_memory" |bc -l) ))
then
echo "WARNING Redis running on $6:$8 is above warning limit: $used_memory %"
exit 1
else
echo "OK Redis running on $6:$8 memory usage: $used_memory % is below the defined limits"
exit 0
fi
fi