---
title: Providence
permalink: /
---

Providence is an opinionated [Vagrant shell provisioner][] for web development
using [Debian][] base boxes. This documentation explains what Providence does
and how it works. It assumes you have a basic understanding of [Vagrant][]. If
you're not familiar with Vagrant you may want to review HashiCorp's
[Getting Started tutorials][] before continuing.

## Provisioning

The easiest way to get started with Providence is to use it as a remote shell
provisioner. Here's a basic Vagrantfile:

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'debian/buster64'
  config.vm.hostname = 'providence.test'
  config.vm.network 'private_network', type: 'dhcp'
  config.vm.provision 'shell',
    path: 'https://github.com/mgsisk/providence/releases/download/v0.1.0/provisioner.sh'
end
```

This will provision the [debian/buster64][] base box using v0.1.0 of Providence.
It also sets the guest's hostname and creates a private network so that the
guest is reachable from the host. Providence is web development focused so it
assumes you want to reach the guest through a web browser, which requires a
[Vagrant network][]. Any of Vagrant's networking options should work as long as
the guest ends up with an IP the host can access.

When you're ready, `vagrant up` to see what happens. Providence will do its best
to figure out what to provision based on your project structure and
configuration files.

## Initialization

Providence starts by checking for a variety of common configuration files (e.g.
`package.json`) and directories (e.g. `.git/`). The existence – and, in some
cases, contents – of these files and directories utlimately determines the
`PROVIDENCE` of the guest, a list of keywords Providence uses to determine what
it needs to provision. A `Gemfile` in your projects root directory, for example,
will add the `ruby` keyword to `PROVIDENCE` and trigger the installation of
`ruby`, `ruby-build`, `rbenv`, and `bundler`. The contents of the Gemfile may
trigger extra provisioning steps, like installing a specific Ruby version or
building a static site with Jekyll.

Providence writes the `PROVIDENCE` keywords to the `/tmp/prov` file on the
guest. If you're wondering why Providence provisioned in a certain way you can
check this file afterwards to see what keywords Providence used during
provisioning.

## Installation

Once Providence has determined the `PROVIDENCE` of the guest it installs the
packages necessary for provisioning. This is often the longest part of the
process. It starts by updating apt sources and keys, then installing whatever
apt packages the guest needs. Providence writes the list of apt packages it
installs to the `/tmp/prov-apt` file on the guest. If you're wondering what
Providence installed via `apt` during provisioning you can check this file
afterwards.

Next, Providence installs any extra packages that aren't available through
apt, ilke goenv or wp-cli. Providence pulls these from GitHub repos or official
distribution URL's using `wget`. This includes installing package managers like
Bundler or Composer and running their install procedure in the appropriate
directory. If Providence finds a `package.json` file in your projects root
directory, for example, it will run `npm install` for you.

## Configuration

After installation, Providence performs any necessary system configuration.
Configuration is not customizable; Providence assumes a particular structure and
workflow for the guest (e.g. the public web root is always `/srv/web`). The
changes it makes are also unsafe in some situations (e.g. setting the root
password for MariaDB and other packages to `vagrant`) as it assumes the guest is
a development environment. You should not use Providence in a production
environment.

One thing to note is that Providence does not check `/tmp/prov` for keywords to
know what it should configure; it uses `dpkg --get-selections` or `command -v`.
This means that if you install Apache on your own and then run Providence, for
example, it may still recognize the Apache installation and attempt to configure
it. If you need to adjust the guest configuration you'll want to run one or more
provisioners after Providence.

## Implementation

Once configuration is complete, Providence will check for known project types to
see if there's anything it should build for you. This includes generating static
sites using Hugo, Jekyll, Pelican, or Zola, instsalling and configuring the
WordPress content management system, or linking a project directory to the
guests web root. By default, most of these setups are mutually exclusive as
they'll end up using the same web root on the guest, but you can change their
destination folder through standard configuration (e.g. changing Jekyll's
`baseurl` setting) or environment variables (e.g. setting the `WP_SRV` variable)
and Providence will put them in the correct location:

```ruby
config.vm.provision 'shell',
  path: 'https://github.com/mgsisk/providence/releases/download/v0.1.0/provisioner.sh',
  env: {
    'WP_SRV' => '/srv/web/wordpress'
  }
```

## Termination

Providence completes provisioning by creating web-accessible indexes for
`/srv/sys` and `/srv/web` (if necessary), then reporting how long provisioning
took and what IP and hostname you can use to access the guest (if a web server
is running):

```
default: Provisioning completed in 03m 21s
default: Now serving 192.168.84.42 at providence.test
default: See 192.168.84.42:1234 or sys.providence.test for guest utilities
```

Accessing the guest through a web browser by IP is doable, but tedious, so
Providence will use the guest's hostname wherever possible. Setting the guest's
hostname in your Vagrantfile is half of the process; you'll also need to update
your system's hosts file for the hostname to work in a web browser:

```
192.168.84.42    providence.test    sys.providence.test
```

[Vagrant plugins][] like [vagrant-hostsupdater][] can help you automate this, or
you can use [Vagrant triggers][] to automate the process yourself. See
[this gist][] for an exmaple of how to do this with triggers.

## Customization

A set of environment variables define what files, directories, and versions
Providence uses during provisioning. These variables have reasonable defaults
that should work for most projects, but you can also set most of them manually
through the Vagrantfile. See the [environment variables][] page for a complete
list of variables and an explanation of how they impact the provisioning
process.

[environment variables]: env
[debian]: https://app.vagrantup.com/debian/
[debian/buster64]: https://app.vagrantup.com/debian/boxes/buster64
[getting started tutorials]: https://learn.hashicorp.com/collections/vagrant/getting-started
[this gist]: https://gist.github.com/mgsisk/50956eeef7c56a0ca0378e2637d6ea28
[vagrant network]: https://www.vagrantup.com/docs/networking
[vagrant plugins]: https://www.vagrantup.com/docs/plugins
[vagrant shell provisioner]: https://www.vagrantup.com/docs/provisioning/shell
[vagrant triggers]: https://www.vagrantup.com/docs/triggers
[vagrant-hostsupdater]: https://github.com/agiledivider/vagrant-hostsupdater
[vagrant]: https://vagrantup.com
