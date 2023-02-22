# Use an official Nginx runtime as a parent image
FROM nginx:latest

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Install necessary packages
RUN apt-get update && \
    apt-get install -y curl git zip unzip php-fpm php-mysqli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure PHP-FPM
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 127.0.0.1:9000/' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/;listen.owner/listen.owner/' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/;listen.group/listen.group/' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/;listen.mode/listen.mode/' /etc/php/7.4/fpm/pool.d/www.conf && \
    echo "clear_env = no" >> /etc/php/7.4/fpm/pool.d/www.conf

# Copy the Nginx configuration file into the container at /etc/nginx/nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the contents of the current directory into the container at /var/www/html
COPY . /var/www/html

# Download and install WordPress
RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzvf wordpress.tar.gz && \
    rm -f wordpress.tar.gz && \
    mv wordpress/* . && \
    rm -rf wordpress && \
    chown -R www-data:www-data /var/www/html && \
    find /var/www/html/ -type d -exec chmod 755 {} \; && \
    find /var/www/html/ -type f -exec chmod 644 {} \;

# Add wordpress config and database env
COPY wp-config.php /var/www/html/wp-config.php
ENV WORDPRESS_DB_USER=root
ENV WORDPRESS_DB_PASSWORD=123secret
ENV WORDPRESS_DB_NAME=test_db
# Expose port 80 for Nginx
EXPOSE 80

# Start PHP-FPM and Nginx servers
CMD service php7.4-fpm start && nginx -g "daemon off;"
