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

require 'rack/mount'

module PuppetForgeServer
  class Server
    include PuppetForgeServer::Utils::OptionParser
    include PuppetForgeServer::Utils::Http

    def go(args)
      begin
        options = parse_options(args)
        @log = logging(options)
        backends = backends(options)
        server = build(backends)
        announce(options, backends)
        start(server, options)
      rescue PuppetForgeServer::Errors::Expected
        @log.error error
      end
    end

    def logging(options)
      if options[:log_dir]
        FileUtils.mkdir_p options[:log_dir]
        server_loggers = [File.join(options[:log_dir], 'server.log')]
        server_loggers << STDERR if options[:debug]
        access_loggers = [File.join(options[:log_dir], 'access.log')]
        access_loggers << STDERR if options[:debug]
        PuppetForgeServer::Logger.set({:server => server_loggers, :access => access_loggers})
      end
      PuppetForgeServer::Logger.get
    end

    def build(backends)
      Rack::Mount::RouteSet.new do |set|
        set.add_route PuppetForgeServer::App::Frontend.new
        set.add_route PuppetForgeServer::App::Generic.new
        set.add_route PuppetForgeServer::App::Version1.new(backends)
        set.add_route PuppetForgeServer::App::Version2.new(backends)
        set.add_route PuppetForgeServer::App::Version3.new(backends)
      end
    end

    def announce(options, backends)
      options = options.clone
      options.default = 'default'
      @log.info " +- Daemonizing: #{options[:daemonize]}"
      @log.info " |- Port: #{options[:port]}"
      @log.info " |- Host: #{options[:hostname]}"
      @log.info " |- Pidfile: #{options[:pidfile]}" if options[:pidfile]
      @log.info " |- Server: #{options[:server]}"
      @log.info ' `- Backends:'
      backends.each do |backend|
        @log.info "    - #{backend.inspect}"
      end
    end

    def start(server, options)
      FileUtils.mkdir_p File.dirname(options[:pidfile]) if options[:pidfile]
      Rack::Server.start(
          :app => server,
          :Host => options[:hostname],
          :Port => options[:port],
          :server => options[:server],
          :daemonize => options[:daemonize],
          :pid => options[:pidfile]
      )
    end

    private
    def backends(options)
      options[:backend].map do |type, typed_backends|
        typed_backends.map do |url|
          case type
            when 'Proxy'
              @log.info "Detecting API version for #{url}..."
              PuppetForgeServer::Backends.const_get("#{type}V#{get_api_version(url)}").new(url.chomp('/'), options[:cache_basedir])
            else
              PuppetForgeServer::Backends.const_get(type).new(url)
          end
        end
      end.flatten.sort_by { |backend| backend.PRIORITY }
    end
  end
end
