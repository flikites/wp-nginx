#!/bin/bash
pidfile="/usr/local/bin/php-fpm-pid"
# Start the process
php-fpm -g $pidfile &
# Wait for 10 seconds
sleep 10
# Kill the process
pid=$(cat $pidfile)
kill $pid
# start the loop that restarts php-fpm each 20 minutes
while true; do
    # Start the process
    php-fpm -g $pidfile &
    # Wait for 20 minutes
    sleep 1200
    # Kill the process
    pid=$(cat $pidfile)
    kill $pid
done