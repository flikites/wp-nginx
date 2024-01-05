#!/bin/bash
pidfile="/usr/local/bin/php-fpm-pid"
# Start the process
php-fpm -g $pidfile &
# Wait for 10 seconds
sleep 10
# Kill the process
pid=$(cat $pidfile)
kill $pid
# loop that resests php-fpm and folder permissions each 30 minutes
while true; do
    # Start the process
    php-fpm -g $pidfile &
    # Wait for 30 minutes
    sleep 1800
    # Kill the process
    pid=$(cat $pidfile)
    kill $pid
    # reset wp folder permissions
    chmod -R g+rwx /var/www/html/
    chown -R www-data:www-data /var/www/html/
done