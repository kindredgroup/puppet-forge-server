# Puppet Forge Server

Private Puppet Forge Server supporting local files and both v1 and v3 API proxies. Heavily inspired by the [Puppet Library](https://github.com/drrb/puppet-library).

[![Build Status](https://api.travis-ci.org/unibet/puppet-forge-server.svg)](https://travis-ci.org/unibet/puppet-forge-server)
[![Gem Version](https://badge.fury.io/rb/puppet-forge-server.svg)](http://badge.fury.io/rb/puppet-forge-server)

Puppet Forge Server provides approximated implementation of both [v1](https://projects.puppetlabs.com/projects/module-site/wiki/Server-api)
and [v3](https://forgeapi.puppetlabs.com/) APIs, but behavioral deviations from the official implementation might occur.

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

Run librarian-puppet with *--no-use-v1-api* option to instruct it to use v3 API
```
librarian-puppet install --no-use-v1-api
```
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


## TODO

1. Create UTs for core logic
2. Implement *source* and *git* backends to match [puppet library](https://github.com/drrb/puppet-library) feature set

## License

[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0.txt)

## Reference

* [Puppet Library](https://github.com/drrb/puppet-library)
* [Puppet Anvil](https://github.com/jhaals/puppet-anvil)
