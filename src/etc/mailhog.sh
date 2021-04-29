#!/bin/sh
#
# Configure MailHog and related packages.
# ------------------------------------------------------------------------------

if command -v mailhog >/dev/null
  then echo 'Configuring MailHog'
  mkdir -p /srv/sys/mailhog
  echo "<meta http-equiv='refresh' content='0; url=http://$(hostname -f):8025'>" >/srv/sys/mailhog/index.html

  cat <<_ >/etc/init.d/mailhog
#!/bin/sh

### BEGIN INIT INFO
# Provides: MailHog
# Required-Start: \$remote_fs \$syslog
# Required-Stop: \$remote_fs \$syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: MailHog test SMTP
# Description: Start the MailHog SMTP
### END INIT INFO

PID=/var/run/mailhog.pid

case "\$1" in
  restart|force-reload) ${0} stop && ${0} start ;;
  start) start-stop-daemon --start --pidfile "\$PID" --make-pidfile --user nobody --background --exec /usr/local/bin/mailhog ;;
  status)
    printf 'MailHog is'
    [ -f "\$PID" ] || printf ' not'
    echo ' running'
    ;;
  stop) [ -f "\$PID" ] && start-stop-daemon --stop --pidfile "\$PID" ;;
  *) echo 'Usage: /etc/init.d/mailhog {start|stop|restart|force-reload|status}' ;;
esac
_

  chmod +x /etc/init.d/mailhog
  update-rc.d mailhog defaults
  service mailhog start
  sed -i 's/^relayhost = .*/relayhost = [localhost]:1025/' /etc/postfix/main.cf
  service mailhog restart
  service postfix restart
fi
