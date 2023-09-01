#! /bin/bash
# DESCRIPTION:
#   This is a custom plugin written in shell script to run Redis ping command to see if Redis is alive.
#
# OUTPUT:
#   Redis status in plain text
#
# PLATFORMS:
#   Linux
#
# USAGE:
#   check-redis-ping.sh -h host -p port

ping_check="$(/bin/redis-cli "$1" "$2" "$3" "$4" PING 2>&1)"
if [ "$ping_check" ]
then
echo "OK. Redis is alive"
exit 0
else
echo "Critical: $ping_check"
exit 1
fi






