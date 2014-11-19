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
  class Version3 < Sinatra::Base
    include PuppetForgeServer::Api::V3::Releases
    include PuppetForgeServer::Api::V3::Modules
    include PuppetForgeServer::Utils::Buffer

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

    get '/v3/releases' do
      halt 400, {'error' => 'The number of version constraints in the query does not match the number of module names'}.to_json unless params[:module]

      author, name, version = params[:module].split '-'
      metadata = @backends.map do |backend|
        backend.get_metadata(author, name, {:version => version})
      end.flatten.compact.uniq

      halt 404, {'pagination' => {'next' => false}, 'results' => []}.to_json if metadata.empty?

      releases = get_releases(metadata)
      {'pagination' => {'next' => false, 'total' => releases.count}, 'results' => releases}.to_json
    end

    get '/v3/files/*' do
      captures = params[:captures].first
      buffer = get_buffer(@backends, captures)

      halt 404, {'errors' => ['404 Not found']}.to_json unless buffer

      content_type 'application/octet-stream'
      attachment captures.split('/').last
      download buffer
    end

    get '/v3/modules/:author-:name' do
      author = params[:author]
      name = params[:name]

      halt 400, {'errors' => "'#{params[:module]}' is not a valid module slug"}.to_json unless author && name

      metadata = @backends.map do |backend|
        backend.get_metadata(author, name)
      end.flatten.compact.uniq

      halt 404, {'errors' => ['404 Not found']}.to_json if metadata.empty?

      get_modules(metadata).to_json
    end
  end
end
