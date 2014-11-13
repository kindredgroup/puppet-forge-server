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
require 'json'

module PuppetForgeServer::App
  class Version1 < Sinatra::Base
    include PuppetForgeServer::Api::V1::Releases
    include PuppetForgeServer::Api::V1::Modules
    include PuppetForgeServer::Utils::Buffer

    configure do
      use ::Rack::CommonLogger, PuppetForgeServer::Logger.get(:access)
    end

    before {
      env['rack.errors'] =  PuppetForgeServer::Logger.get(:server)
    }

    def initialize(backends)
      super(nil)
      @backends = backends
    end

    get '/api/v1/releases.json' do
      unless params[:module]
        halt 400, {'error' => 'The number of version constraints in the query does not match the number of module names'}.to_json
      end

      author, name = params[:module].split '/'
      version = params[:version] if params[:version]

      metadata = @backends.map do |backend|
        backend.get_metadata(author, name, {:version => version, :with_checksum => false})
      end.flatten.uniq

      halt 400, {'errors' => ["'#{params[:module]}' is not a valid module slug"]}.to_json if metadata.empty?

      {"#{author}/#{name}" => get_releases(metadata)}.to_json
    end

    get '/api/v1/files/*' do
      captures = params[:captures].first
      buffer = get_buffer(@backends, captures)

      halt 404, {'errors' => ['404 Not found']}.to_json unless buffer

      content_type 'application/octet-stream'
      attachment captures.split('/').last
      download buffer
    end

    get '/modules.json' do
      query = params[:q]
      metadata = @backends.map do |backend|
        backend.query_metadata(query, {:with_checksum => false})
      end.flatten.uniq
      get_modules(metadata).to_json
    end
  end
end
