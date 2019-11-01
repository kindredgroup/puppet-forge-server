# -*- encoding: utf-8 -*-
#
# Copyright 2014 North Development AB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

$:.push File.expand_path('../lib', __FILE__)
require 'puppet_forge_server/version'

Gem::Specification.new do |spec|
  spec.name = 'puppet-forge-server'
  spec.version = PuppetForgeServer::VERSION
  spec.authors = 'Ilja Bobkevic'
  spec.email = 'ilja.bobkevic@unibet.com'
  spec.description = 'Private Puppet forge server supports local files, both v1 and v3 API proxies'
  spec.summary = <<-EOF
    Private Puppet forge server
  EOF
  spec.homepage = 'https://github.com/unibet/puppet-forge-server'
  spec.license = 'Apache 2'

  spec.files = `git ls-files`.split($/)
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'sinatra', '~> 1.4'
  spec.add_dependency 'sinatra-contrib', '~> 1.4'
  spec.add_dependency 'json', '~> 1.8'
  spec.add_dependency 'rack-mount', '~> 0.8'
  spec.add_dependency 'rack', '1.5.5'
  spec.add_dependency 'open4', '~> 1.3'
  spec.add_dependency 'open_uri_redirections', '~> 0.1'
  spec.add_dependency 'haml', '~> 4.0'
  spec.add_dependency 'deep_merge', '~> 1.0'
  spec.add_dependency 'multipart-post', '~> 2.0.0'
  spec.add_dependency 'redcarpet', '~> 3.3.0'
  spec.add_dependency 'lru_redux', '~> 1.1.0'
  spec.add_dependency 'iconv', '~> 1.0.4'
  spec.add_dependency 'logger-colors', '~> 1.0'

  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 3.1'
  spec.add_development_dependency 'rspec-core', '~> 3.1'
  spec.add_development_dependency 'simplecov', '~> 0.17.0'
  spec.add_development_dependency 'rspec-stopwatch', '~> 0.1.3'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug' if RUBY_VERSION > '2.0.0'

  spec.required_ruby_version = '>= 1.9.3'
end
