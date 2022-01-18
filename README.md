# Providence (@mgsisk/providence)

Opinionated Vagrant shell provisioner for web development.

[![Latest release][badge-release]][url-release]
[![Build status][badge-build]][url-build]
[![Code quality][badge-quality]][url-codacy]
[![Maintainer funding][badge-funding]][url-funding]

Providence is an opinionated [Vagrant shell provisioner][] for web development
using [Debian][] base boxes. It includes:

- **Caches** – Memcached, Redis
- **Container Engines** – Docker
- **Content Management Systems** – WordPress
- **Databases** – CouchDB, MariaDB, MongoDB, PostgreSQL, SQLite
- **Languages** – Go, Node, Perl, PHP, Python, Ruby, Rust
- **Package Managers** – Bundler, Cargo, Composer, NPM, Pipenv
- **Static Site Generators** – Hugo, Jekyll, Pelican, Zola
- **Utilities** – Adminer, Docker Compose, MailHog, Git LFS, git-svn,
  GitHub CLI, node-build, ocp, perl-build, phpMemcachedAdmin, phpRedisAdmin,
  postfix, ruby-build, ShellCheck, ShellSpec, vim, Webgrind, webmin, WP-CLI,
  xmllint
- **Version Control Systems** – Git, Mercurial, Subversion
- **Version Managers** – goenv, nodenv, plenv, pyenv, rbenv, rustup
- **Web Servers** – Apache, Nginx

## Installation

The easiest way to use Providence is as a remote shell provisioner, but you can
download and build it locally with:

```sh
git clone https://github.com/mgsisk/providence.git providence
./providence/src/make.sh
```

## Usage

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'debian/buster64'
  config.vm.hostname = 'providence.test'
  config.vm.network 'private_network', type: 'dhcp'
  config.vm.provision 'shell', path: 'https://github.com/mgsisk/providence/releases/download/v0.1.0/provisioner.sh'
end
```

[Support resources][] are available if you need help with this project. Refer to
the [documentation][] for more detailed information on what Providence does and
how it works.

## Contributing

[Contributions][] are always welcome; please read the [code of conduct][]
before you begin. See the [changelog][] for notable project changes, and report
any [security][] concerns you find.

## Thanks

To the [contributors][] that help to build, fund, and maintain this project;
the [other works][] that have contributed to and inspired this project; and
anyone that has found this project useful.

## License

[ISC][]

[badge-build]: https://img.shields.io/github/workflow/status/mgsisk/providence/build
[badge-funding]: https://img.shields.io/github/sponsors/mgsisk
[badge-quality]: https://img.shields.io/codacy/grade/e18fdb6393be43b59ea02a285c1faca8
[badge-release]: https://img.shields.io/github/v/tag/mgsisk/providence?sort=semver
[changelog]: CHANGELOG.md
[code of conduct]: CODE_OF_CONDUCT.md
[contributions]: CONTRIBUTING.md
[contributors]: AUTHORS.md
[debian]: https://app.vagrantup.com/debian
[documentation]: docs/README.md
[isc]: LICENSE.md
[other works]: THANKS.md
[security]: SECURITY.md
[support resources]: SUPPORT.md
[url-build]: https://github.com/mgsisk/github-actions-test/actions?query=workflow%3Abuild
[url-codacy]: https://app.codacy.com/gh/mgsisk/providence
[url-funding]: CONTRIBUTING.md#funding
[url-release]: https://github.com/mgsisk/providence/releases
[vagrant shell provisioner]: https://www.vagrantup.com/docs/provisioning/shell
