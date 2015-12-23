# -*- encoding: utf-8 -*-
#
# Copyright 2015 North Development AB
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
require 'uri'

module PuppetForgeServer::Utils
  module OptionParser

    @@DEFAULT_DAEMONIZE = false
    @@DEFAULT_PORT = 8080
    @@DEFAULT_PID_FILE = File.join(Dir.tmpdir.to_s, 'puppet-forge-server', 'server.pid')
    @@DEFAULT_CACHE_DIR = File.join(Dir.tmpdir.to_s, 'puppet-forge-server', 'cache')
    @@DEFAULT_LOG_DIR = File.join(Dir.tmpdir.to_s, 'puppet-forge-server', 'log')
    @@DEFAULT_WEBUI_ROOT = File.expand_path('../app', File.dirname(__FILE__))
    @@DEFAULT_HOST = '0.0.0.0'
    @@DEFAULT_RAM_CACHE_TTL = 60 * 30 # 30min
    @@DEFAULT_RAM_CACHE_SIZE = 250

    def self.DEFAULT_OPTIONS
      {
        :daemonize      => @@DEFAULT_DAEMONIZE,
        :cache_basedir  => @@DEFAULT_CACHE_DIR,
        :port           => @@DEFAULT_PORT,
        :webui_root     => @@DEFAULT_WEBUI_ROOT,
        :host           => @@DEFAULT_HOST,
        :ram_cache_ttl  => @@DEFAULT_RAM_CACHE_TTL,
        :ram_cache_size => @@DEFAULT_RAM_CACHE_SIZE
      }
    end

    def parse_options(args)
      options = PuppetForgeServer::Utils::OptionParser.DEFAULT_OPTIONS
      option_parser = ::OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename $0} [options]"
        opts.version = PuppetForgeServer::VERSION

        opts.on('-p', '--port PORT', "Port number to bind to (default: #{@@DEFAULT_PORT})") do |port|
          options[:port] = port
        end

        opts.on('-b', '--bind HOST', "Host name or IP address to bind to (default: #{@@DEFAULT_HOST})") do |host|
          options[:host] = host
        end

        opts.on('-D', '--daemonize', "Run server in the background (default: #{@@DEFAULT_DAEMONIZE})") do
          options[:daemonize] = true
        end

        opts.on('--pidfile FILE', "Pid file location (default: #{@@DEFAULT_PID_FILE})") do |pidfile|
          options[:pidfile] = pidfile
        end

        options[:backend] = {'Directory' => [], 'Proxy' => [], 'Source' => []}
        opts.on('-m', '--module-dir DIR', 'Directory containing packaged modules (recursively searched)') do |module_dir|
          options[:backend]['Directory'] << module_dir
        end
        opts.on('-x', '--proxy URL', 'Remote forge URL') do |url|
          options[:backend]['Proxy'] << url
        end

        opts.on('--cache-basedir DIR', "Proxy module cache base directory (default: #{@@DEFAULT_CACHE_DIR})") do |cache_basedir|
          options[:cache_basedir] = cache_basedir
        end

        opts.on('--ram-cache-ttl SECONDS', "The time to live in seconds for remote requests RAM cache (default: #{@@DEFAULT_RAM_CACHE_TTL})") do |ram_cache_ttl|
          options[:ram_cache_ttl] = ram_cache_ttl
        end

        opts.on('--ram-cache-size ENTRIES', "The maximum number of enties in RAM cache for remote requests (default: #{@@DEFAULT_RAM_CACHE_SIZE})") do |ram_cache_size|
          options[:ram_cache_size] = ram_cache_size
        end

        opts.on('--log-dir DIR', "Log directory (default: #{@@DEFAULT_LOG_DIR})") do |log_dir|
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
