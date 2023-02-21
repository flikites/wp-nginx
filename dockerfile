FROM wordpress:6.1.1-fpm

# COPY ./wp-content/ /usr/src/wordpress/wp-content
COPY ./wp-config.php /usr/src/wordpress
ENV WORDPRESS_DB_USER=root
ENV WORDPRESS_DB_PASSWORD=123secret
ENV WORDPRESS_DB_NAME=test_db

  # PHP upload size
RUN { \
    echo 'upload_max_filesize = 256M'; \
    echo 'post_max_size = 256M'; \
	} > /usr/local/etc/php/conf.d/extra.ini

RUN apt-get update
RUN apt-get install -y --no-install-recommends nginx
COPY ./default.conf /etc/nginx/conf.d/
COPY --chmod=777 ./bootstrap.sh /

EXPOSE 80
WORKDIR "/var/www/html"
CMD ["/bootstrap.sh"]