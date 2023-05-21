#!/bin/bash

wait_for_input() {
    echo "Press any key to continue"
    while [ true ] ; do
        read -t 3 -n 1
        if [ $? = 0 ] ; then
            break
        else
            echo "waiting for the keypress"
        fi
    done
}

DROPBOX_DIR=~/Dropbox/droplet_bot


mkdir -p /tmp/dropbox
mkdir -p /opt/dropbox
wget -O /tmp/dropbox/dropbox.tar.gz "https://www.dropbox.com/download?plat=lnx.x86_64"
tar xzfv /tmp/dropbox/dropbox.tar.gz --strip 1 -C /opt/dropbox
/opt/dropbox/dropboxd

wait_for_input

mkdir -p /etc/sysconfig
echo "DROPBOX_USERS=\"`whoami`\"" >> /etc/sysconfig/dropbox

## Create ubuntu version of /etc/systemd/system/dropbox:
cat <<EOT > /etc/systemd/system/dropbox
#!/bin/sh

# To configure, add line with DROPBOX_USERS="user1 user2" to /etc/sysconfig/dropbox
# Probably should use a dropbox group in /etc/groups instead.

# Source function library.
. /lib/lsb/init-functions

prog=dropboxd
lockfile=${LOCKFILE-/var/lock/subsys/$prog}
RETVAL=0

start() {
    echo -n $"Starting $prog"
    echo
    if [ -z $DROPBOX_USERS ] ; then
        echo -n ": unconfigured: $config"
        echo_failure
        echo
        rm -f ${lockfile} ${pidfile}
        RETURN=6
        return $RETVAL
    fi
    for dbuser in $DROPBOX_USERS; do
        dbuser_home=`cat /etc/passwd | grep "^$dbuser:" | cut -d":" -f6`
        daemon --user $dbuser /bin/sh -c "/opt/dropbox/dropboxd"
    done
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && touch ${lockfile}
    return $RETVAL
}

status() {
    for dbuser in $DROPBOX_USERS; do
        dbpid=`pgrep -u $dbuser dropbox | grep -v grep`
        if [ -z $dbpid ] ; then
            echo "dropboxd for USER $dbuser: not running."
        else
            echo "dropboxd for USER $dbuser: running (pid $dbpid)"
        fi
    done
}
stop() {
    echo -n $"Stopping $prog"
    for dbuser in $DROPBOX_USERS; do
        dbuser_home=`cat /etc/passwd | grep "^$dbuser:" | cut -d":" -f6`
        dbpid=`pgrep -u $dbuser dropbox | grep -v grep`
        if [ -z $dbpid ] ; then
            echo -n ": dropboxd for USER $dbuser: already stopped."
            RETVAL=0
        else
            kill -KILL $dbpid
            RETVAL=$?
        fi
    done
    echo
    [ $RETVAL = 0 ] && rm -f ${lockfile} ${pidfile}
}

# See how we were called.
case "$1" in
    start)
        start
        ;;
    status)
        status
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo $"Usage: $prog {start|status|stop|restart}"
        RETVAL=3
esac
EOT

## Modify /etc/systemd/system/dropbox.service:
cat <<EOT > /etc/systemd/system/dropbox.service
[Unit]
Description=Dropbox is a filesyncing sevice provided by dropbox.com. This service starts up the dropbox daemon.
After=network.target syslog.target

[Service]
Environment=LC_ALL=en_US.UTF-8
Environment=LANG=en_US.UTF-8
EnvironmentFile=-/etc/sysconfig/dropbox
ExecStart=/etc/systemd/system/dropbox start
ExecReload=/etc/systemd/system/dropbox restart
ExecStop=/etc/systemd/system/dropbox stop
Type=forking

[Install]
WantedBy=multi-user.target
EOT

# enable systemd service
systemctl daemon-reload
systemctl start dropbox
systemctl enable dropbox

# install dropbox cli
cd ~
wget -P ~/ -O dropbox.py https://www.dropbox.com/download?dl=packages/dropbox.py
chmod +x ~/dropbox.py
ln -s /opt/dropbox ~/.dropbox-dist

# copy logs dir if needed (should be in dropbox)
# copy config and credentials files

wait_for_input

mkdir -p $DROPBOX_DIR/logs
