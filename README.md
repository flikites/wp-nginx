## Dockerized NGINX + WordPress for Flux

### Configure Your Wordpress Container With These ENVs

```WORDPRESS_DB_HOST=operator:3307 # This and all other below DB ENVs are required
WORDPRESS_DB_USER=root #should match what is set for DB container
WORDPRESS_DB_PASSWORD=secret #should match what is set for DB container
WORDPRESS_DB_NAME=test_db
PUBLIC_KEY= #optional
