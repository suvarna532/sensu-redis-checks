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


connection_check="$(/bin/redis-cli "$5" "$6" "$7" "$8" config get maxclients 2>&1)"
if [ $? -ge 1 ]
then
echo "Connection ERROR: $connection_check"
exit 1
else
max_memory="$(/bin/redis-cli "$5" "$6" "$7" "$8" info memory | grep 'maxmemory:' | cut -d ':' -f2 | awk '{print $1 - 0}')"
if [ $((max_memory)) -eq 0 ]
then
total_memory="$(/bin/redis-cli "$5" "$6" "$7" "$8" info memory | grep 'total_system_memory:' | cut -d ':' -f2 | awk '{print $1 - 0}')"
fi

memory_in_use="$(/bin/redis-cli "$5" "$6" "$7" "$8" info memory | grep 'used_memory:' | cut -d ':' -f2 | awk '{print $1 - 0}')"

used_memory="$(echo "$memory_in_use $total_memory" | awk '{printf "%.2f", ($1 / $2)*100}')"

c_memory="$(echo "$2" | awk '{printf "%.2f", $1}')"
w_memory="$(echo "$4" | awk '{printf "%.2f", $1}')"

echo "$used_memory $c_memory $w_memory $6 $8" | awk '{if ($1 >= $2) {print "CRITICAL Redis running on ",$4,":",$5," is above critical limit: ",$1,"%"; exit 1} else if ($1 >= $3) {print "WARNING Redis running on ",$4,":",$5," is above warning limit: ",$1,"%"; exit 1} else {print "OK Redis running on ",$4,":",$5," memory usage ",$1,"% is below the defined limits"; exit 0}}'

fi