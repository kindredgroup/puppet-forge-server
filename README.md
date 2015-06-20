# Puppet Forge Server

Private Puppet Forge Server supporting local files and both v1 and v3 API proxies. Heavily inspired by the [Puppet Library](https://github.com/drrb/puppet-library).

[![Build Status](https://api.travis-ci.org/unibet/puppet-forge-server.svg)](https://travis-ci.org/unibet/puppet-forge-server)
[![Gem Version](https://badge.fury.io/rb/puppet-forge-server.svg)](http://badge.fury.io/rb/puppet-forge-server)

Puppet Forge Server provides approximated implementation of both [v1](https://projects.puppetlabs.com/projects/module-site/wiki/Server-api)
and [v3](https://forgeapi.puppetlabs.com/) APIs, but behavioral deviations from the official implementation might occur.

Puppet 2, 3 and 4 as well as librarian-puppet are supported.

## Table of Contents

* [Installation](#installation)
  * [Dependencies](#dependencies)
* [Getting Started](#getting-started)
  * [Proxy](#proxy)
    * [Proxy the official Puppet Forge v3 API](#proxy-the-official-puppet-forge-v3-api)
    * [Proxy the official Puppet Forge v1 API and local Pulp puppet repository](#proxy-the-official-puppet-forge-v1-api-and-local-pulp-puppet-repository)
  * [Locally stored modules](#locally-stored-modules)
  * [All-in](#all-in)
  * [Daemon](#daemon)
* [Web UI](#web-ui)
* [Architecture](#command-reference)
  * [API (view)](#api-view)
  * [App (controller)](#app-controller)
  * [Models](#models)
  * [Backends](#backends)
* [Limitations](#limitations)
* [Reference](#reference)

## Installation

Install the gem
```
gem install puppet-forge-server
puppet-forge-server --help
```
or get the latest source
```
git clone https://github.com/unibet/puppet-forge-server
cd puppet-forge-server
bundle install
bundle exec bin/puppet-forge-server --help
```

### Dependencies
The gem installtion requires the ruby development packages and GCC.

Red Hat (and derivitives)
``` yum install gcc ruby-devel ```

Debian (and derivitives)
``` apt-get install gcc ruby-dev ```

## Getting Started

### Proxy

#### Proxy the official Puppet Forge v3 API
Just start the server providing the forge URL
```
bundle exec bin/puppet-forge-server -x https://forgeapi.puppetlabs.com
```

Run puppet module install to test it
```
puppet module install --module_repository=http://localhost:8080 puppetlabs-stdlib
```

#### Proxy the official Puppet Forge v1 API and local Pulp puppet repository
Just start the server providing forge and local pulp URLs
```
bundle exec bin/puppet-forge-server -x http://forge.puppetlabs.com -x http://my.local.pulp/pulp_puppet/forge/repository/demo
```

Run puppet module install to test it. Please note that depending on your internet connection and puppet version it might take a while for the first call to get executed.
v3 API requires checksuming the files, which means all involved module files will be cached.
```
puppet module install --module_repository=http://localhost:8080 puppetlabs-stdlib
```

### Locally stored modules

Download given modules from the official forge and start the server pointing into directory with module files
```
mkdir modules
wget -P modules/ forge.puppetlabs.com/system/releases/p/puppetlabs/puppetlabs-apache-0.9.0.tar.gz
wget -P modules/ forge.puppetlabs.com/system/releases/p/puppetlabs/puppetlabs-concat-1.0.0.tar.gz
wget -P modules/ forge.puppetlabs.com/system/releases/p/puppetlabs/puppetlabs-stdlib-2.4.0.tar.gz
bundle exec bin/puppet-forge-server -m modules/
```

Run puppet module install to test it
```
puppet module install --module_repository=http://localhost:8080 puppetlabs-stdlib
```

### All-in

Download given modules from the official forge and start the server pointing into directory with module files and proxy URLs
```
mkdir modules
wget -P modules/ forge.puppetlabs.com/system/releases/p/puppetlabs/puppetlabs-apache-0.9.0.tar.gz
wget -P modules/ forge.puppetlabs.com/system/releases/p/puppetlabs/puppetlabs-concat-1.0.0.tar.gz
wget -P modules/ forge.puppetlabs.com/system/releases/p/puppetlabs/puppetlabs-stdlib-2.4.0.tar.gz
bundle exec bin/puppet-forge-server -m modules/ -x https://forgeapi.puppetlabs.com -x http://my.local.pulp/pulp_puppet/forge/repository/demo
```

Create an example Puppetfile
```
cat > Puppetfile <<EOF
forge 'http://localhost:8080'

mod 'puppetlabs/apache'
EOF
```

Run librarian-puppet with *--no-use-v1-api* option to instruct it to use v3 API for better performance
```
librarian-puppet install --no-use-v1-api
```

### Daemon

Normally one would want to run server as a deamon:

```
# Assuming puppet-forge-server gem was installed
# Create deamon user
sudo adduser forge -d /opt/forge -s /bin/false
# Create log, cache and modules directories
sudo -u forge mkdir -p /opt/forge/log /opt/forge/modules /opt/forge/cache
# Start the server
sudo -u forge puppet-forge-server -D -m /opt/forge/modules -x https://forgeapi.puppetlabs.com --log-dir /opt/forge/log --cache-basedir /opt/forge/cache --pidfile /opt/forge/server.pid
```

You are done. Now go install some puppet modules.

### Behind Apache (Passenger Support)

Apache virtualhost config:
```
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /opt/forge/public
    <Directory /opt/forge/public>
        Allow from all
        Options -MultiViews
        Require all granted
    </Directory>
</VirtualHost>
```

Create a `config.ru` one folder down from the Apache DocumentRoot, eg: /opt/forge/config.ru:
```
require 'rubygems'
require 'puppet_forge_server'

# Set base cache directory for proxy backends 
cache_dir = '/opt/forge/cache' # default: File.join(Dir.tmpdir.to_s, 'puppet-forge-server', 'cache')

# Create backends
backends = [
  PuppetForgeServer::Backends::Directory.new('/opt/forge/modules'),
  # Add directory backend for serving cached modules in case proxy flips over
  PuppetForgeServer::Backends::Directory.new(cache_dir),
  PuppetForgeServer::Backends::ProxyV3.new('https://forgeapi.puppetlabs.com', cache_dir)
]

# Disable access logging, log errors to STDERR
PuppetForgeServer::Logger.set({:server => STDERR, :access => File.open(File::NULL, "w")})

# Run
run PuppetForgeServer::Server.new.build(backends, PuppetForgeServer::Utils::OptionParser.class_eval('@@DEFAULT_WEBUI_ROOT'))
```

You can now connect to http://localhost and see the web interface, start using and adding modules in the same way as you would running as a Daemon.

## Web UI

Puppet forge server comes with built-in web UI looking very similar to the official puppet forge web page and providing a simple module search feature. Each view haml file corresponds to the request endpoint; for example **/** or index  is formed by the index.haml located in the *views* directory and obviously combined with layout.haml that is being refered to during any request. 

It is possible to set an external web UI root directory containing at least *views* directory with required haml files. See https://github.com/unibet/puppet-forge-server/tree/master/lib/puppet_forge_server/app/views for built-in reference implementation.

## Architecture

Code is structured with MVC in mind to allow easier  maintenance and readability

### API (view)

*API* classes (actually modules only) are used to extend [Sinatra](http://www.sinatrarb.com/) application classes.
Every module corresponds to official API endpoint and used to present received model data in fasion required by the given API version.

### App (controller)

Every *App* class is a [Sinatra](http://www.sinatrarb.com/) application class and is responsible for mapping API endpoints, querying backends for requested data and providing the results using API (view) modules.

### Models

Puppet module *metadata* json representation is used as a main business *model*.

### Backends

*Backend* classes are providing the means of fetching required data and creating model instances.


## Limitations

1. Modulefile is not supported with the *directory* backend

## License

[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt)

## Reference

* [Puppet Library](https://github.com/drrb/puppet-library)
* [Puppet Anvil](https://github.com/jhaals/puppet-anvil)
