# -*- encoding: utf-8 -*-
#
# Copyright 2014 drrb
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

require 'optparse'

module PuppetForgeServer::Utils
  module OptionParser
    include PuppetForgeServer::Utils::Url

    @@DEFAULT_DAEMONIZE = false
    @@DEFAULT_PORT = 8080
    @@DEFAULT_PID_FILE = File.join(Dir.tmpdir.to_s, 'puppet-forge-server', 'server.pid')
    @@DEFAULT_CACHE_DIR = File.join(Dir.tmpdir.to_s, 'puppet-forge-server', 'cache')

    def parse_options(args)
      options = {:daemonize => @@DEFAULT_DAEMONIZE, :cache_basedir => @@DEFAULT_CACHE_DIR, :port => @@DEFAULT_PORT}
      option_parser = ::OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename $0} [options]"
        opts.version = PuppetForgeServer::VERSION

        opts.on('-p', '--port PORT', 'Port to listen on (defaults to whatever Rack wants to use)') do |port|
          options[:port] = port
        end

        opts.on('-b', '--bind-host HOSTNAME', 'Host name to bind to (defaults to whatever Rack wants to use)') do |hostname|
          options[:hostname] = hostname
        end

        opts.on('--daemonize', 'Run the server in the background') do
          options[:daemonize] = true
          options[:pidfile] = @@DEFAULT_PID_FILE unless options[:pidfile]
        end

        opts.on('--pidfile FILE', 'Write a pidfile to this location after starting') do |pidfile|
          options[:pidfile] = pidfile
        end

        options[:backend] = {'Directory' => [], 'Proxy' => [], 'Source' => []}
        opts.on('-m', '--module-dir DIR', 'Directory containing packaged modules (can be specified multiple times)') do |module_dir|
          options[:backend]['Directory'] << module_dir
        end
        opts.on('-x', '--proxy URL', 'Remote forge to proxy (can be specified multiple times)') do |url|
          options[:backend]['Proxy'] << normalize_url(url)
        end
        opts.on('--source-dir DIR', "Directory containing a module's source (can be specified multiple times)") do |module_dir|
          options[:backend]['Source'] << module_dir
        end

        opts.on('--cache-basedir DIR', "Cache all proxies' downloaded modules under this directory") do |cache_basedir|
          options[:cache_basedir] = cache_basedir
        end
      end
      begin
        option_parser.parse(args)
      rescue ::OptionParser::InvalidOption => parse_error
        raise PuppetForgeServer::Errors::Expected, parse_error.message + "\n" + option_parser.help
      end
      return options
    end
  end
end