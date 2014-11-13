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


require 'logger'

module PuppetForgeServer
  class Logger
    @@DEFAULT_DESTINATION = STDERR
    @@DEFAULT_DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S'
    @static_loggers = {:server => nil, :access => nil}

    def initialize(destinations = [@@DEFAULT_LOGGER])
      @loggers = Array.new(destinations).flatten.map do |dest|
        logger = ::Logger.new(dest)
        logger.formatter = proc do |severity, datetime, progname, msg|
          datetime = datetime.strftime @@DEFAULT_DATETIME_FORMAT
          "[#{datetime}] #{severity}  #{msg}\n"
        end
        logger
      end
    end

    def method_missing (method_name, *args, &block)
      method_name = method_name == :write ? :'<<' : method_name
      @loggers.each { |logger| logger.send(method_name, args.first) }
    end

    class << self
      def get(type = :server)
        set unless @static_loggers[type]
        @static_loggers[type]
      end

      def set(loggers= {})
        loggers = {:server => [@@DEFAULT_DESTINATION], :access => [@@DEFAULT_DESTINATION]}.merge(loggers)
        loggers.each do |type, destinations|
          @static_loggers[type] = PuppetForgeServer::Logger.new(destinations)
        end
      end
    end
  end
end