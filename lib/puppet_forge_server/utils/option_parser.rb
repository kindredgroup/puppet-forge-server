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
require 'tmpdir'

module PuppetForgeServer::Utils
  module OptionParser
    include PuppetForgeServer::Utils::Url

    @@DEFAULT_DAEMONIZE = false
    @@DEFAULT_PORT = 8080
    @@DEFAULT_PID_FILE = File.join(Dir.tmpdir.to_s, 'puppet-forge-server', 'server.pid')
    @@DEFAULT_CACHE_DIR = File.join(Dir.tmpdir.to_s, 'puppet-forge-server', 'cache')
    @@DEFAULT_LOG_DIR = File.join(Dir.tmpdir.to_s, 'puppet-forge-server', 'log')
    @@DEFAULT_WEBUI_ROOT = File.expand_path('../app', File.dirname(__FILE__))

    def parse_options(args)
      options = {:daemonize => @@DEFAULT_DAEMONIZE, :cache_basedir => @@DEFAULT_CACHE_DIR, :port => @@DEFAULT_PORT, :webui_root => @@DEFAULT_WEBUI_ROOT}
      option_parser = ::OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename $0} [options]"
        opts.version = PuppetForgeServer::VERSION

        opts.on('-p', "--port PORT', 'Port to listen on (default: #{@@DEFAULT_PORT})") do |port|
          options[:port] = port
        end

        opts.on('-b', '--bind-host HOSTNAME', 'Host name to bind to (default: whatever Rack wants to use)') do |hostname|
          options[:hostname] = hostname
        end

        opts.on('-D', '--daemonize', "Run the server in the background (default: #{@@DEFAULT_DAEMONIZE})") do
          options[:daemonize] = true
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

        opts.on('--cache-basedir DIR', "Cache all proxies' downloaded modules under this directory (default: #{@@DEFAULT_CACHE_DIR})") do |cache_basedir|
          options[:cache_basedir] = cache_basedir
        end

        opts.on('--log-dir DIR', "Directory containing all server logs (if daemonized default: #{@@DEFAULT_LOG_DIR})") do |log_dir|
          options[:log_dir] = log_dir
        end

        opts.on('--webui-root DIR', "Directory containing views and other public files used for web UI: #{@@DEFAULT_WEBUI_ROOT})") do |webui_root|
          options[:webui_root] = webui_root
        end

        opts.on('--debug', 'Log everything into STDERR') do
          options[:debug] = true
        end
      end
      begin
        option_parser.parse(args)
      rescue ::OptionParser::InvalidOption => parse_error
        raise PuppetForgeServer::Errors::Expected, parse_error.message + "\n" + option_parser.help
      end

      raise PuppetForgeServer::Errors::Expected, "Web UI directory doesn't exist: #{options[:webui_root]}" unless Dir.exists?(options[:webui_root])

      # Handle option dependencies
      if options[:daemonize]
        options[:pidfile] = @@DEFAULT_PID_FILE unless options[:pidfile]
        options[:log_dir] = @@DEFAULT_LOG_DIR unless options[:log_dir]
      end

      if options[:log_dir] && !options[:daemonize]
        options[:debug] = true
      end

      return options
    end
  end
end