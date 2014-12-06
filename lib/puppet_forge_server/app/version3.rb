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
require 'sinatra/json'

module PuppetForgeServer::App
  class Version3 < Sinatra::Base
    include PuppetForgeServer::Api::V3::Releases
    include PuppetForgeServer::Api::V3::Modules
    include PuppetForgeServer::Utils::Buffer

    configure do
      enable :logging
      use ::Rack::CommonLogger, PuppetForgeServer::Logger.get(:access)
    end

    before do
      content_type :json
      env['rack.errors'] = PuppetForgeServer::Logger.get(:server)
    end

    def initialize(backends)
      super(nil)
      @backends = backends
    end

    get '/v3/releases/:module' do
      halt 404, json({:errors => ['404 Not found']}) unless params[:module]
      author, name, version = params[:module].split '-'
      halt 400, json({:errors => ["'#{params[:module]}' is not a valid release slug"]}) unless author && name && version
      releases = releases(author, name, version)
      halt 404, json({:errors => ['404 Not found']}) unless releases
      PuppetForgeServer::Logger.get(:server).error "Requested releases count is more than 1:\n#{releases}" unless releases.count > 1
      json releases.first
    end

    get '/v3/releases' do
      halt 400, json({:error => 'The number of version constraints in the query does not match the number of module names'}) unless params[:module]
      releases = releases(params[:module].split '-')
      halt 404, json({:pagination => {:next => false}, :results => []}) unless releases
      json :pagination => {:next => false, :total => releases.count}, :results => releases
    end

    get '/v3/files/*' do
      captures = params[:captures].first
      buffer = get_buffer(@backends, captures)

      halt 404, json({:errors => ['404 Not found']}) unless buffer

      content_type 'application/octet-stream'
      attachment captures.split('/').last
      download buffer
    end

    get '/v3/modules/:author-:name' do
      author = params[:author]
      name = params[:name]

      halt 400, json({:errors => "'#{params[:module]}' is not a valid module slug"}) unless author && name

      metadata = @backends.map do |backend|
        backend.get_metadata(author, name)
      end.flatten.compact.uniq

      halt 404, json({:errors => ['404 Not found']}) if metadata.empty?

      json get_modules(metadata)
    end

    private
    def releases(author, name, version = nil)
      metadata = @backends.map do |backend|
        backend.get_metadata(author, name, {:version => version})
      end.flatten.compact.uniq
      metadata.empty? ? nil : get_releases(metadata)
    end
  end
end
