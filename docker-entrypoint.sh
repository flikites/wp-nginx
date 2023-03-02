#!/usr/bin/env bash
set -Eeuo pipefail

sourceTarArgs=(
  --create
  --file -
  --directory /usr/src/wordpress
  --owner "www-data" --group "www-data"
)
targetTarArgs=(
  --extract
  --file -
)

# loop over "pluggable" content in the source, and if it already exists in the destination, skip it
# https://github.com/docker-library/wordpress/issues/506 ("wp-content" persisted, "akismet" updated, WordPress container restarted/recreated, "akismet" downgraded)
for contentPath in \
  /usr/src/wordpress/.htaccess \
  /usr/src/wordpress/wp-content/*/*/ \
; do
  contentPath="${contentPath%/}"
  [ -e "$contentPath" ] || continue
  contentPath="${contentPath#/usr/src/wordpress/}" # "wp-content/plugins/akismet", etc.
  if [ -e "$PWD/$contentPath" ]; then
    echo >&2 "WARNING: '$PWD/$contentPath' exists! (not copying the WordPress version)"
    sourceTarArgs+=( --exclude "./$contentPath" )
  fi
done
tar "${sourceTarArgs[@]}" . | tar "${targetTarArgs[@]}"
echo >&2 "Complete! WordPress has been successfully copied to $PWD"


exec "$@"

## echo "127.0.0.1 $(hostname) localhost localhost.localdomain" >> /etc/hosts;
## service sendmail restart