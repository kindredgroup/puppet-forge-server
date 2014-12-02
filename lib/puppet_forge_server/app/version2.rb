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

require 'sinatra/base'

module PuppetForgeServer::App
  class Version2 < Sinatra::Base

    configure do
      enable :logging
      use ::Rack::CommonLogger, PuppetForgeServer::Logger.get(:access)
    end

    before {
      env['rack.errors'] =  PuppetForgeServer::Logger.get(:server)
    }

    def initialize(backends)
      super(nil)
      @backends = backends
    end

    post '/v2/releases' do
      halt 410, {'errors' => ['File not provided']}.to_json unless params['file']
      states = @backends.map do |backend|
        backend.upload(params['file'])
      end.compact
      status (states.include?(true) ? 200 : 412)
    end
  end
end
