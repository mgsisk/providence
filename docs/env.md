---
title: Environment Variables
---

Providence uses a set of environment variables to provision the guest, and you
can specify most of them through your Vagrantfile. The following table
summarizes the user-settable variables Providence recognizes. More information
for specific variables is available below.

Variable               | Default value                                  | Implied keywords
---------------------- | ---------------------------------------------- | ----------------
BUNDLER_CNF            | /vagrant/Gemfile                               | ruby
CARGO_CNF              | /vagrant/Cargo.toml                            | rust
CERT                   | /etc/ssl/certs/ssl-cert-snakeoil.pem           | nginx
CKEY                   | /etc/ssl/private/ssl-cert-snakeoil.key         | nginx
COMPOSER_CNF           | /vagrant/composer.json                         | php
DOCKER_CNF             | /vagrant/Dockerfile                            | docker
DOCKER_COMPOSE_CNF     | /vagrant/docker-compose.yml                    | docker
GIT_DIR                | /vagrant/.git                                  | git
GITHUB_DIR             | /vagrant/.github                               | github
GO_VER                 |                                                | go
HG_DIR                 | /vagrant/.hg                                   | hg
HUGO_DIR               |                                                | hugo nginx
HUGO_SRV               | /srv/web                                       | 
JEKYLL_CNF             | First _config TOML or YAML file in JEKYLL_DIR  | 
JEKYLL_DIR             | Directory containing JEKLL_CNF or BUNDLER_CNF  | jekyll nginx ruby
JEKYLL_SRV             | /srv/web                                       | 
[LANG][]               | en_US.UTF-8                                    | 
NODE_CNF               | /vagrant/package.json                          | node
[NODE_VER][]           | Derived from NODE_CNF                          | node
PELICAN_CNF            | First *conf.py file in PELICAN_DIR             | 
PELICAN_DIR            | Directory containing PELICAN_CNF or PIPENV_CNF | nginx pelican python
PELICAN_SRV            | /srv/web                                       | 
PERL_VER               |                                                | perl
[PHP_VER][]            | Dervied from WP_CNF or COMPOSER_CNF            | php
PIPENV_CNF             | /vagrant/Pipfile                               | python
[PROVIDENCE][]         | .                                              | 
PYTHON_VER             | Derived fro PIPENV_CNF                         | python
[RUBY_VER][]           | Derived from BUNDLER_CNF                       | ruby
RUST_CNF               | /vagrant/rust-toolchain.toml                   | rust
RUST_VER               | Derived from RUST_CNF                          | rust
SHELLSPEC_CNF          | /vagrant/.shellspec                            | shell
SVN_DIR                | /vagrant/.svn                                  | svn
TEST_DIR               | /vagrant/test                                  | 
WEB_DIR                |                                                | nginx
WEB_SRV                | /srv/web                                       | 
WP_CNF                 | WP_DIR/readme.txt                              | 
[WP_DATA][]            | <https://github.com/WPTT/theme-test-data>      | apache mailhog mariadb php svn wordpress
[WP_DIR][]             | Directory containing WP_CNF or COMPOSER_CNF    | apache mailhog mariadb php svn wordpress
[WP_PLUGINS][]         | .                                              | apache mailhog mariadb php svn wordpress
[WP_SRC][]             | <https://develop.svn.wordpress.org/branches>   | apache mailhog mariadb php svn wordpress
WP_SRV                 | /srv/web                                       | 
[WP_THEME][]           |                                                | apache mailhog mariadb php svn wordpress
[WP_THEMES][]          | .                                              | apache mailhog mariadb php svn wordpress
[WP_VER][]             | Derived from WP_CNF or COMPOSER_CNF            | apache mailhog mariadb php svn wordpress
ZOLA_CNF               | ZOLA_DIR/config.toml                           | 
ZOLA_DIR               | Directory containing ZOLA_CNF                  | nginx zola
ZOLA_SRV               | /srv/web                                       | 
[ZONE][]               |                                                | 

## LANG

Guest locale. Must be a locale recognized by the guest.

## NODE_VER

Version of [Node.js][] to install with [nodenv][]. No default, but Providence
will use the version specified in NODE_CNF if found (e.g.
`"node": ">=0.10.3 <15"`). Note that Providence does not understand Node version
constraints and may attempt to install an incorrect version.

## PHP_VER

Version of [PHP][] to install with [phpv][]. No default, but Providence will use
the version specified in WP_CNF (e.g. `Requires PHP: 7.4`) or COMPOSER_CNF (e.g.
`"php": ">=7.4"`) if found  (`WP_CNF` takes priority). Note that Providence does
not understand Composer version constraints and may attempt to install an
incorrect version.

## PROVIDENCE

Space-separated list of keywords used to provision the guest.

Keyword      | Provisions
------------ | ----------
\*           | Everything
.            | Based on project structure and configuration files
apache       | [Apache][]
couchdb      | [CouchDB][]
docker       | [Docker][], [Docker Compose][]
hg           | [Mercurial][]
git          | [Git][], [Git LFS][]
github       | [GitHub CLI][]
go           | [Go][], [goenv][]
hugo         | [Hugo][]
jekyll       | [Jekyll][]
mailhog      | [MailHog][], [postfix][]
mariadb      | [MariaDB][]
memcached    | [Memcached][]
mongodb      | [MongoDB][]
nginx        | [Nginx][]
node         | [Node.js][], [nodenv][], [node-build][], [NPM][]
pelican      | [Pelican][]
perl         | [Perl][], [perl-build][], [plenv][]
php          | [Composer][], [PHP][]
postgres     | [PostgreSQL][]
python       | [Pipenv][], [pyenv][], [Python][]
redis        | [Redis][]
ruby         | [Bundler][], [rbenv][], [Ruby][], [ruby-build][]
rust         | [Cargo][], [Rust][], [rustup][]
shell        | [ShellCheck][], [ShellSpec][]
sqlite       | [SQLite][]
svn          | [Subversion][]
webmin       | [Webmin][]
wordpress    | [WordPress][], [WP-CLI][]
xml          | [xmllint][]
zola         | [Zola][]

Some keyword combinations trigger extra provisioning.

Keyword | Keyword         | Keyword                               | Provisions
------- | --------------- | ------------------------------------- | ----------
git     | svn             |                                       | [git-svn][]
php     | apache or nginx |                                       | [ocp][], [Webgrind][]
php     | apache or nginx | mariadb, mongodb, postgres, or sqlite | [Adminer][]
php     | apache or nginx | memcached                             | [phpMemcachedAdmin][]
php     | apache or nginx | redis                                 | [phpRedisAdmin][]

Some keyword and variable combinations trigger extra actions.

Keyword  | Variable           | Action
-------- | ------------------ | ------
docker   | DOCKER_CNF         | `docker run -d` (`docker-compose` takes priority)
docker   | DOCKER_COMPOSE_CNF | `docker-compose up -d`
go       | GO_VER             | `goenv install $GO_VER`
hugo     | HUGO_DIR           | `hugo -d $HUGO_SRV`
jekyll   | JEKYLL_DIR         | `jekyll build -d $JEKYLL_SRV`
node     | NODE_CNF           | `npm install`
node     | [NODE_VER][]       | `nodenv install $NODE_VER`
pelican  | PELICAN_DIR        | `pelican -s $PELICAN_CNF -e OUTPUT_DIR=$PELICAN_SRV`
perl     | PERL_VER           | `plenv install $PERL_VER`
php      | COMPOSER_CNF       | `composer install`
python   | PIPENV_CNF         | `pipenv install`
python   | PYTHON_VER         | `pyenv install $PYTHON_VER`
ruby     | BUNDLER_CNF        | `bundle install`
ruby     | [RUBY_VER][]       | `rbenv install $RUBY_VER`
rust     | RUST_VER           | `rustup toolchain install $RUST_VER`
zola     | ZOLA_DIR           | `zola build -o $ZOLA_SRV`

Note that Providence does not install Jekyll or Pelican on its own; you must
have Jekyll or Pelican listed as a dependency in BUNDLER_CNF or PIPENV_CNF.

## RUBY_VER

Version of [Ruby][] to install with [rbenv][]. No default, but Providence will
use the version specified in BUNDLER_CNF if found (e.g. `ruby '~> 2.3.0'`). Note
that Providence does not understand Bundler version constraints and may attempt
to install an incorrect version.

## WP_DATA

URL or file containing WordPress data to import with [WP-CLI][]. Defaults to the
theme unit test data from <https://github.com/WPTT/theme-test-data>.

## WP_DIR

Directory containg a WordPress project. Defaults to the directory containing
WP_CNF or COMPOSER_CNF (WP_CNF takes priority). If WP_DIR exists and
COMPOSER_CNF contains an apropriate custom WordPress type (e.g.
`wordpress-plugin`), Providence will create a link to WP_DIR in the correct
location (e.g. `$WP_SRV/wp-content/plugins`).

## WP_PLUGINS

Space-separate list of WordPress plugins to install with [WP-CLI][]. The default
value, `.`, is a placeholder for the following plugins:

- [debug-bar-console](https://wordpress.org/plugins/debug-bar-console)
- [debug-bar-cron](https://wordpress.org/plugins/debug-bar-cron)
- [debug-bar](https://wordpress.org/plugins/debug-bar)
- [developer](https://wordpress.org/plugins/developer)
- [jetpack](https://wordpress.org/plugins/jetpack)
- [log-deprecated-notices](https://wordpress.org/plugins/log-deprecated-notices)
- [log-viewer](https://wordpress.org/plugins/log-viewer)
- [monster-widget](https://wordpress.org/plugins/monster-widget)
- [piglatin](https://wordpress.org/plugins/piglatin)
- [polldaddy](https://wordpress.org/plugins/polldaddy)
- [query-monitor](https://wordpress.org/plugins/query-monitor)
- [regenerate-thumbnails](https://wordpress.org/plugins/regenerate-thumbnails)
- [rewrite-rules-inspector](https://wordpress.org/plugins/rewrite-rules-inspector)
- [rtl-tester](https://wordpress.org/plugins/rtl-tester)
- [simply-show-hooks](https://wordpress.org/plugins/simply-show-hooks)
- [simply-show-ids](https://wordpress.org/plugins/simply-show-ids)
- [theme-check](https://wordpress.org/plugins/theme-check)
- [theme-test-drive](https://wordpress.org/plugins/theme-test-drive)
- [user-switching](https://wordpress.org/plugins/user-switching)
- [wordpress-beta-tester](https://wordpress.org/plugins/wordpress-beta-tester)

Providence always installs [wordpress-importer][], regardless of the value of
WP_PLUGINS.

## WP_SRC

Source URL for WordPress files. Defaults to <https://develop.svn.wordpress.org>.
Providence will attempt to download test files (e.g. a PHPUnit test config) from
WP_SRC into TEST_DIR when provisioning WordPress if appropriate TEST_DIR
directories exist (e.g. `$TEST_DIR/phpunit`).

## WP_THEME

WordPress theme to activate by default with [WP-CLI][].

## WP_THEMES

Space-separate list of WordPress themes to install with [WP-CLI][]. The default
value, `.`, is a placeholder for the following themes:

- [classic][]
- [default][]
- [twentyten][]
- [twentyeleven][]
- [twentytwelve][]
- [twentythirteen][]
- [twentyfourteen][]
- [twentyfifteen][]
- [twentysixteen][]
- [twentyseventeen][]
- [twentynineteen][]
- [twentytwenty][]
- [twentytwentyone][]

Providence always installs WP_THEME if specified, regardless of the value of
WP_THEMES.

## WP_VER

Version of [WordPress][] to install with [WP-CLI][]. No default, but Providence
will use the version specified in WP_CNF (e.g. `Requires at least: 5.1`) or
COMPOSER_CNF (e.g. `"johnpbloch/wordpress": ">=5.1"`) if found (WP_CNF takes
priority). Note that Providence does not understand Composer version constraints
and may attempt to install an incorrect version.

## ZONE

Guest time zone. Must be a valid tz database value (e.g. `America/Detroit`).

[adminer]: https://www.adminer.org
[Apache]: https://httpd.apache.org
[Bundler]: https://bundler.io
[Cargo]: https://doc.rust-lang.org/cargo/
[classic]: https://wordpress.org/themes/classic
[Composer]: https://getcomposer.org
[CouchDB]: https://couchdb.apache.org
[debug-bar-console]: https://wordpress.org/plugins/debug-bar-console
[debug-bar-cron]: https://wordpress.org/plugins/debug-bar-cron
[debug-bar]: https://wordpress.org/plugins/debug-bar
[default]: https://wordpress.org/themes/default
[developer]: https://wordpress.org/plugins/developer
[Docker Compose]: https://docs.docker.com/compose/
[Docker]: https://www.docker.com
[Git LFS]: https://git-lfs.github.com
[git-svn]: https://git-scm.com/docs/git-svn
[Git]: https://git-scm.com
[GitHub CLI]: https://cli.github.com
[Go]: https://golang.org
[goenv]: https://github.com/syndbg/goenv
[Hugo]: https://gohugo.io
[Jekyll]: https://jekyllrb.com
[jetpack]: https://wordpress.org/plugins/jetpack
[LANG]: #lang
[log-deprecated-notices]: https://wordpress.org/plugins/log-deprecated-notices
[log-viewer]: https://wordpress.org/plugins/log-viewer
[MailHog]: https://github.com/mailhog/MailHog
[MariaDB]: https://mariadb.org
[Memcached]: https://memcached.org
[Mercurial]: https://www.mercurial-scm.org
[MongoDB]: https://www.mongodb.com
[monster-widget]: https://wordpress.org/plugins/monster-widget
[Nginx]: https://www.nginx.com
[NODE_VER]: #node_ver
[node-build]: https://github.com/nodenv/node-build
[Node.js]: https://nodejs.org
[nodenv]: https://github.com/nodenv/nodenv
[NPM]: https://github.com/nodenv/nodenv
[ocp]: https://gist.github.com/kabel/d12c35bde74814e45c14
[Pelican]: https://getpelican.com/
[perl-build]: https://github.com/tokuhirom/Perl-Build
[Perl]: https://www.perl.org
[PHP_VER]: #php_ver
[PHP]: https://www.php.net
[phpMemcachedAdmin]: https://github.com/elijaa/phpmemcachedadmin
[phpRedisAdmin]: https://github.com/erikdubbelboer/phpRedisAdmin
[phpv]: phpv
[piglatin]: https://wordpress.org/plugins/piglatin
[Pipenv]: https://pypi.org/project/pipenv
[plenv]: https://github.com/tokuhirom/plenv
[polldaddy]: https://wordpress.org/plugins/polldaddy
[postfix]: http://www.postfix.org
[PostgreSQL]: https://www.postgresql.org
[PROVIDENCE]: #providence
[pyenv]: https://github.com/pyenv/pyenv
[Python]: https://www.python.org
[query-monitor]: https://wordpress.org/plugins/query-monitor
[rbenv]: https://github.com/rbenv/rbenv
[redis]: https://redis.io
[regenerate-thumbnails]: https://wordpress.org/plugins/regenerate-thumbnails
[rewrite-rules-inspector]: https://wordpress.org/plugins/rewrite-rules-inspector
[rtl-tester]: https://wordpress.org/plugins/rtl-tester
[RUBY_VER]: #ruby_ver
[ruby-build]: https://github.com/rbenv/ruby-build
[Ruby]: https://www.ruby-lang.org
[Rust]: https://www.rust-lang.org
[rustup]: https://rustup.rs
[ShellCheck]: https://github.com/koalaman/shellcheck
[ShellSpec]: https://github.com/shellspec/shellspec
[simply-show-hooks]: https://wordpress.org/plugins/simply-show-hooks
[simply-show-ids]: https://wordpress.org/plugins/simply-show-ids
[SQLite]: https://www.sqlite.org
[Subversion]: https://subversion.apache.org
[theme-check]: https://wordpress.org/plugins/theme-check
[theme-test-drive]: https://wordpress.org/plugins/theme-test-drive
[twentyeleven]: https://wordpress.org/themes/twentyeleven
[twentyfifteen]: https://wordpress.org/themes/twentyfifteen
[twentyfourteen]: https://wordpress.org/themes/twentyfourteen
[twentynineteen]: https://wordpress.org/themes/twentynineteen
[twentyseventeen]: https://wordpress.org/themes/twentyseventeen
[twentysixteen]: https://wordpress.org/themes/twentysixteen
[twentyten]: https://wordpress.org/themes/twentyten
[twentythirteen]: https://wordpress.org/themes/twentythirteen
[twentytwelve]: https://wordpress.org/themes/twentytwelve
[twentytwenty]: https://wordpress.org/themes/twentytwenty
[twentytwentyone]: https://wordpress.org/themes/twentytwentyone
[user-switching]: https://wordpress.org/plugins/user-switching
[Webgrind]: https://github.com/jokkedk/webgrind
[Webmin]: https://www.webmin.com
[wordpress-beta-tester]: https://wordpress.org/plugins/wordpress-beta-tester
[wordpress-importer]: https://wordpress.org/plugins/wordpress-importer
[WordPress]: https://wordpress.org
[WP_CNF]: #wp_cnf
[WP_DATA]: #wp_data
[WP_DIR]: #wp_dir
[WP_PLUGINS]: #wp_plugins
[WP_SRC]: #wp_src
[WP_SRV]: #wp_srv
[WP_THEME]: #wp_theme
[WP_THEMES]: #wp_themes
[WP_VER]: #wp_ver
[WP_VER]: #wp_ver
[WP-CLI]: https://wp-cli.org
[xmllint]: http://xmlsoft.org/xmllint.html
[Zola]: https://www.getzola.org
[ZONE]: #zone
