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

#Remove akismet plugin
folder="/usr/src/wordpress/wp-content/plugins/akismet"
if [ -d "$folder" ]; then
  # Delete the folder and its contents
  rm -rf "$folder"
  echo "Folder deleted: $folder"
else
  echo "Folder does not exist: $folder"
fi
#Remove hello dolly plugin
file_path="/usr/src/wordpress/wp-content/plugins/hello.php"
if [ -f "$file_path" ]; then
    echo "Deleting $file_path..."
    rm "$file_path"
    echo "File deleted successfully."
else
    echo "File $file_path does not exist."
fi

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


# Add a new user for SFTP access with key-based authentication
USERNAME="sftpuser"
if id "$USERNAME" &>/dev/null; then
   echo "User $USERNAME already exists."
else
   useradd -m -d /home/sftpuser -s /sbin/nologin sftpuser
   mkdir /home/sftpuser/.ssh
fi
chmod 700 /home/sftpuser/.ssh

USERNAME="sshuser"
if id "$USERNAME" &>/dev/null; then
   echo "User $USERNAME already exists."
else
   useradd -m -d /home/sshuser -s /sbin/nologin sshuser
   mkdir /home/sshuser/.ssh
fi
chmod 700 /home/sshuser/.ssh

# Add the public key to the authorized keys file
if [ -v PUBLIC_KEY ]; then
    echo "ssh-rsa $PUBLIC_KEY" > /home/sftpuser/.ssh/authorized_keys
    chown -R sftpuser:sftpuser /home/sftpuser/.ssh
    chmod 600 /home/sftpuser/.ssh/authorized_keys

    echo "ssh-rsa $PUBLIC_KEY" > /home/sshuser/.ssh/authorized_keys
    chown -R sshuser:sshuser /home/sshuser/.ssh
    chmod 600 /home/sshuser/.ssh/authorized_keys

    echo "Public key is: $PUBLIC_KEY"

    usermod -aG www-data sftpuser 
    usermod -aG root sshuser

    chmod -R g+rwx /var/www/html/wp-content
    chown -R www-data:www-data /var/www/html/wp-content
else
    echo "PUBLIC_KEY is not defined."
fi

exec "$@"

## echo "127.0.0.1 $(hostname) localhost localhost.localdomain" >> /etc/hosts;
## service sendmail restart