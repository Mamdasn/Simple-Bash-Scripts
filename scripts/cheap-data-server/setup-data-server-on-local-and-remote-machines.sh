#!/bin/bash

U_LOCAL="localuser"
H_LOCAL="/home/$U_LOCAL"
U_REMOTE="remoteuser"
H_REMOTE="/home/$U_REMOTE"

setup_server() {
    echo Setting up server
    ssh -fN -R 2222:localhost:22 rasp
    sudo systemctl start sshd
    echo Done
}

close_server() {
    echo Closing server
    pids=$(pgrep -f "ssh -fN -R 2222:localhost:22 rasp")
    [ -n "$pids" ] && echo "$pids" | xargs kill -9 || echo no running reverse ssh is found
    echo Done
}


setup_nginx_remote() {
    sudo tee /etc/nginx/sites-available/fileserver > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    location / {
        root /var/www/files;
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
    }
}
EOF
    sudo ln -sf /etc/nginx/sites-available/fileserver /etc/nginx/sites-enabled/fileserver
    sudo nginx -t && sudo systemctl reload nginx
}

setup_remote() {
    echo Setting up remote
    [ ! -d "/var/www/files" ] && sudo mkdir -p /var/www/files
    sudo chown -R $U_REMOTE:www-data /var/www/files
    setup_nginx_remote
    echo "user_allow_other" | sudo tee -a /etc/fuse.conf
    sshfs data-server:$H_LOCAL/shared-data $H_REMOTE/mountpoints/data-server -o allow_other,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,cache_timeout=30,auto_cache
    #sudo chown $U_REMOTE:www-data $H_REMOTE/mountpoints/data-server
    sudo mount --bind $H_REMOTE/mountpoints/data-server /var/www/files
    echo Done
}

close_remote() {
    echo Closing remote
    pids=$(pgrep -f "sshfs")
    [ -n "$pids" ] && echo "$pids" | xargs kill -9 || echo no running sshfs is found
    sudo umount /var/www/files
    sudo fusermount -u $H_REMOTE/mountpoints/data-server
    echo Done
}

case "$@" in
"server setup")
    setup_server
    ;;
"server close")
    close_server
    ;;
"remote setup")
    setup_remote
    ;;
"remote close")
    close_remote
    ;;
*)
    echo "Usage: $0 {server setup|server close|remote setup|remote close}"
    echo
    echo "Commands:"
    echo "  server setup    - Set up the local server environment"
    echo "  server close    - Shut down and clean up the local server"
    echo "  remote setup    - Prepare the remote server for use"
    echo "  remote close    - Terminate and clean up the remote server"
    exit 1
    ;;
esac
