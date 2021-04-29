#!/bin/sh
#
# Create the phpv utility.
# ------------------------------------------------------------------------------

cat <<_ >/usr/local/bin/phpv
#!/bin/sh

if [ "\$(id -u)" -ne 0 ]
  then sudo /usr/local/bin/phpv "\$@"
  exit
fi

help() {
  cat <<__
Usage: phpv [options] [version]

  Install (if necessary) and switch to the specified PHP version (X.Y).

Options:

  -a    Print a list of available versions.
  -h    Print this help.
  -l    Print a list of installed versions.
__
  exit
}

while getopts ahl o
  do case "\$o" in
    a) what=: ;;
    h) help ;;
    l) list=: ;;
    *) help ;;
  esac
done

shift \$((OPTIND - 1))

php=\$(php -v 2>/dev/null | grep ^PHP | cut -d' ' -f2 | cut -d. -f-2)

[ -n "\$what" ] && apt-cache search '^php.+-fpm' | grep -o '^php.*-fpm ' | sort -u | tr -d '[:alpha:]-' | sed 's/^/   /' && exit

if [ -n "\$list" ]
  then [ -z "\$(find /usr/bin -name 'php?*')" ] && exit
  find /usr/bin -name 'php?*' | sort | sed 's|^/usr/bin/php|   |g' | sed "s/   \$php/ * \$php/"
  exit
fi

p=\$1

[ -n "\$p" ] && ! echo "\$p" | grep -q '^[0-9][0-9]*\.[0-9][0-9]*$' && echo 'Versions must be in X.Y format (e.g. 8.0)' >&2 && exit 1
[ -n "\$p" ] && [ -z "\$(apt-cache search "^php\$p-fpm")" ] && echo "PHP \$p is not available" >&2 && exit 2

cat <<__ >/tmp/php
php-ast
php-imagick
php-oauth
php-ssh2
php-yaml
php\$p-bcmath
php\$p-curl
php\$p-fpm
php\$p-gd
php\$p-imap
php\$p-intl
php\$p-mbstring
php\$p-soap
php\$p-xdebug
php\$p-xml
php\$p-zip
__
grep -qw mariadb /tmp/prov && echo "php\$p-mysql" >>/tmp/php
grep -qw memcached /tmp/prov && echo 'php-memcached' >>/tmp/php
grep -qw mongodb /tmp/prov && echo 'php-mongodb' >>/tmp/php
grep -qw postgres /tmp/prov && echo "php\$p-pgsql" >>/tmp/php
grep -qw redis /tmp/prov && echo 'php-redis' >>/tmp/php
grep -qw sqlite /tmp/prov && echo "php\$p-sqlite3" >>/tmp/php
cat /tmp/php >>/tmp/prov-apt
sort -uo /tmp/prov-apt /tmp/prov-apt
apt-get -qq install --no-install-recommends \$(tr "\n" ' ' </tmp/php) >/dev/null 2>/dev/null

[ -n "\$p" ] || p=\$(php -v | grep ^PHP | cut -d' ' -f2 | cut -d. -f-2)

ln -fs "/usr/bin/php\$p" /usr/bin/php
sed -i 's/^display_errors .*/display_errors = On/' "/etc/php/\$p/fpm/php.ini"
sed -i 's/^error_reporting .*/error_reporting = E_ALL/' "/etc/php/\$p/fpm/php.ini"
sed -i 's/^max_file_uploads .*/max_file_uploads = 99/' "/etc/php/\$p/fpm/php.ini"
sed -i 's/^memory_limit .*/memory_limit = 512M/' "/etc/php/\$p/fpm/php.ini"
sed -i 's/^post_max_size .*/post_max_size = 999M/' "/etc/php/\$p/fpm/php.ini"
sed -i 's/^upload_max_filesize .*/upload_max_filesize = 999M/' "/etc/php/\$p/fpm/php.ini"

cat <<__ >"/etc/php/\$p/mods-available/xdebug.ini"
zend_extension=xdebug.so
xdebug.collect_assignments = 1
xdebug.collect_params = 1
xdebug.collect_return = 1
xdebug.profiler_enable_trigger = 1
xdebug.remote_autostart = 1
xdebug.remote_enable = 1
xdebug.var_display_max_children = -1
xdebug.var_display_max_data = -1
xdebug.var_display_max_depth = -1
__

dpkg --get-selections | grep -q '^apache.*\si' && ln -fs "/etc/apache2/conf-available/php\$p-fpm.conf" /etc/apache2/conf-enabled/php-fpm.conf
dpkg --get-selections | grep -q '^nginx.*\si' && echo "include snippets/fastcgi-php.conf; fastcgi_pass unix:/run/php/php\$p-fpm.sock;" >/etc/nginx/php-fpm
dpkg --get-selections | grep -q '^webmin.*\si' && printf 'php_ini=%s=Configuration for php-cli\t%s=Configuration for php-fpm' "/etc/php/\$p/cli/php.ini" "/etc/php/\$p/fpm/php.ini" >/etc/webmin/phpini/config && service webmin restart

service --status-all | grep -q '+.*apache2' && service apache2 restart
service --status-all | grep -q '+.*nginx' && service nginx restart
service "php\$p-fpm" restart
_
chmod +x /usr/local/bin/phpv
