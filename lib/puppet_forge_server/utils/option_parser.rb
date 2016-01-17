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

    def parse_options(args)
      options = {:daemonize => @@DEFAULT_DAEMONIZE, :cache_basedir => @@DEFAULT_CACHE_DIR, :port => @@DEFAULT_PORT, :webui_root => @@DEFAULT_WEBUI_ROOT, :host => @@DEFAULT_HOST}
      option_parser = ::OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename $0} [options]"
        opts.version = PuppetForgeServer::VERSION

        if ENV.has_key?('FORGE_PORT')
          options[:port] = ENV['FORGE_PORT']
        else
          opts.on('-p', '--port PORT', "Port number to bind to (default: #{@@DEFAULT_PORT})") do |port|
            options[:port] = port
          end
        end

        if ENV.has_key?('FORGE_BIND')
          options[:host] = ENV['FORGE_BIND']
        else
          opts.on('-b', '--bind HOST', "Host name or IP address to bind to (default: #{@@DEFAULT_HOST})") do |host|
            options[:host] = host
          end
        end

        if ENV.has_key?('FORGE_DAEMONIZE')
          options[:daemonize] = true
        else
          opts.on('-D', '--daemonize', "Run server in the background (default: #{@@DEFAULT_DAEMONIZE})") do
            options[:daemonize] = true
          end
        end

        if ENV.has_key?('FORGE_PIDFILE')
          options[pidfile] = ENV['FORGE_PIDFILE']
        else
          opts.on('--pidfile FILE', "Pid file location (default: #{@@DEFAULT_PID_FILE})") do |pidfile|
            options[:pidfile] = pidfile
          end
        end

        options[:backend] = {'Directory' => [], 'Proxy' => [], 'Source' => [], 'S3' => []}

        if ENV.has_key?('FORGE_MODULEDIR')
          options[:backend]['Directory'] << ENV['FORGE_MODULEDIR']
        else
          opts.on('-m', '--module-dir DIR', 'Directory containing packaged modules (recursively searched)') do |module_dir|
            options[:backend]['Directory'] << module_dir
          end
        end

        if ENV.has_key?('FORGE_PROXY')
          options[:backend]['Proxy'] << ENV['FORGE_PROXY']
        else
          opts.on('-x', '--proxy URL', 'Remote forge URL') do |url|
            options[:backend]['Proxy'] << url
          end
        end

        if ENV.has_key?('FORGE_AWS_REGION')
          options[:aws_region] = ENV['FORGE_AWS_REGION']
        else
          opts.on('--aws-region AWSREGION', 'AWS Region where the bucket is located') do |region|
            options[:aws_region] = region
          end
        end

        if ENV.has_key?('FORGE_AWS_KEY')
          options[:aws_key_id] = ENV['FORGE_AWS_KEY']
        else
          opts.on('--aws-key KEY', 'AWS Key id') do |key|
            options[:aws_key_id] = key
          end
        end

        if ENV.has_key?('FORGE_AWS_SECRET')
          options[:aws_secret_key] = ENV['FORGE_AWS_SECRET']
        else
          opts.on('--aws-secret SECRET', 'AWS Secret key') do |secret|
            options[:aws_secret_key] = secret
          end
        end

        if ENV.has_key?('FORGE_S3BUCKET')
          options[:backend]['S3'] << ENV['FORGE_S3BUCKET']
        else
          opts.on('-s', '--s3 BucketName', 'use S3') do |bucket|
            options[:backend]['S3'] << bucket
          end
        end

        if ENV.has_key?('FORGE_CACHEDIR')
          options[:cache_basedir] = ENV['FORGE_CACHEDIR']
        else
          opts.on('--cache-basedir DIR', "Proxy module cache base directory (default: #{@@DEFAULT_CACHE_DIR})") do |cache_basedir|
            options[:cache_basedir] = cache_basedir
          end
        end

        if ENV.has_key?('FORGE_LOGDIR')
          options[:log_dir] = ENV['FORGE_LOGDIR']
        else
          opts.on('--log-dir DIR', "Log directory (default: #{@@DEFAULT_LOG_DIR})") do |log_dir|
            options[:log_dir] = log_dir
          end
        end

        if ENV.has_key?('FORGE_WEBUI_ROOT')
          options[:webui_root] = ENV['FORGE_WEBUI_ROOT']
        else
          opts.on('--webui-root DIR', "Directory containing views and other public files used for web UI: #{@@DEFAULT_WEBUI_ROOT})") do |webui_root|
            options[:webui_root] = webui_root
          end
        end

        if ENV.has_key?('FORGE_DEBUG')
          options[:debug] = true
        else
          opts.on('--debug', 'Log everything into STDERR') do
            options[:debug] = true
          end
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
