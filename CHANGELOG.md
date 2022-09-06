# Changelog

Notable project changes. Versions are [semantic][].

## [Unreleased][]

### Added

- LOGIN_SHELL environment variable
- LOGIN_SHELL_CNF environment variable

### Changed

- Key management for apt sources
- MARIA_VER default to 10.10
- MONGO_VER default to 6.0

### Fixed

- Spelling errors

## [0.1.4][] - 2022-02-15

### Added

- HTTPS support for the sys subdomain
- MARIA_VER environment variable
- MONGO_VER environment variable
- Twenty Twenty-Two to the default themes list for WordPress

### Changed

- CouchDB apt source

### Fixed

- Error that prevented mercurial provisioning

## [0.1.3][] - 2022-01-20

### Fixed

- WordPress versioning for X.Y.0 versions

## [0.1.2][] - 2022-01-18

### Fixed

- WP-CLI provisioning (again)

## [0.1.1][] - 2021-05-10

### Fixed

- WP-CLI provisioning

## [0.1.0][] - 2021-04-29

### Added

- phpv utility
- Provisioning keywords:
  - apache
  - couchdb
  - docker
  - git
  - github
  - go
  - hg
  - hugo
  - jekyll
  - mailhog
  - mariadb
  - memcached
  - mongodb
  - nginx
  - node
  - pelican
  - perl
  - php
  - postgres
  - python
  - redis
  - ruby
  - rust
  - shell
  - sqlite
  - svn
  - webmin
  - wordpress
  - xml
  - zola

[unreleased]: https://github.com/mgsisk/providence/compare/v0.1.4...HEAD
[0.1.4]: https://github.com/mgsisk/providence/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/mgsisk/providence/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/mgsisk/providence/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/mgsisk/providence/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/mgsisk/providence/tree/v0.1.0
[semantic]: https://semver.org
