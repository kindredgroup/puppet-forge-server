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
require 'haml'
require 'json'
require 'tilt/haml'

module PuppetForgeServer::App
  class Frontend < Sinatra::Base
    include PuppetForgeServer::Utils::MarkdownRenderer

    configure do
      set :haml, :format => :html5
      enable :logging
      use ::Rack::CommonLogger, PuppetForgeServer::Logger.get(:access)
    end

    before do
      env['rack.errors'] =  PuppetForgeServer::Logger.get(:server)
    end

    def initialize(root, http_client = PuppetForgeServer::Http::HttpClient.new)
      super(nil)
      settings.root = root
      @http_client = http_client
    end

    get '/' do
      haml :index
    end

    get '/modules' do
      query = params[:query]
      halt(400, haml(:security, :locals => {:query => query})) \
        unless safe_input? query

      modules = get("/v3/modules?query=#{query}")['results']
      haml :modules, :locals => {:query => query, :modules => modules}
    end

    get '/module' do
      module_v3_name = params[:name].gsub(/\//, '-')
      halt(400, haml(:security, :locals => {:query => module_v3_name})) \
        unless safe_input? module_v3_name

      releases = get("/v3/modules/#{module_v3_name}")['releases']
      if params.has_key? 'version'
        module_uri = releases.find {|r| r['version'] == params['version']}['uri']
        module_metadata = get("#{module_uri}")
      else
        module_metadata = get("#{releases[0]['uri']}")
      end
      begin
        readme_markdown = markdown(module_metadata['readme'])
      rescue
        readme_markdown = ''
      end
      haml :module, :locals => { :module_metadata => module_metadata,
                                 :base_url => url(request.base_url),
                                 :readme_markdown => readme_markdown,
                                 :releases => releases }
    end

    get '/upload' do
      haml :upload, :locals => {:upload_status => ''}
    end

    post '/upload' do
      halt(200, haml(:upload, :locals => {:upload_status => 'No file selected'})) unless params[:file]
      response = @http_client.post_file("#{request.base_url}/v2/releases", params[:file])
      haml :upload, :locals => {:upload_status => response.code}
    end

    private
    def get(relative_url)
      begin
        JSON.parse(@http_client.get(url(relative_url)))
      rescue
        {'results' => []}
      end
    end

    def safe_input?(query)
      unsafe_query = CGI::unescape(query)
      %w[< javascript:].none? { |q| unsafe_query.include?(q) }
    end
  end
end
