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

require 'open-uri'
require 'open_uri_redirections'
require 'timeout'
require 'net/http'
require 'net/http/post/multipart'


module PuppetForgeServer::Http
  class HttpClient
    include PuppetForgeServer::Utils::CacheProvider
    include PuppetForgeServer::Utils::FilteringInspecter

    def initialize(cache = nil)
      cache = cache_instance if cache.nil?
      cache.extend(PuppetForgeServer::Utils::FilteringInspecter)
      @log = PuppetForgeServer::Logger.get
      @cache = cache
      @uri_options= {
        'User-Agent' => "Puppet-Forge-Server/#{PuppetForgeServer::VERSION}",
        :allow_redirections => :safe,
      }
      # OpenURI does not work with  http_proxy=http://username:password@proxyserver:port/
      # so split the proxy_url and feed it basic authentication.
      if ENV.has_key?('http_proxy')
        proxy = URI.parse(ENV['http_proxy'])
        if proxy.userinfo != nil
          @uri_options[:proxy_http_basic_authentication] = [
            "#{proxy.scheme}://#{proxy.host}:#{proxy.port}",
            proxy.userinfo.split(':')[0],
            proxy.userinfo.split(':')[1]
          ]
        end
      end

    end

    def post_file(url, file_hash, options = {})
      options = { :http => {}, :headers => {}}.merge(options)

      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      options[:http].each {|k,v| http.call(k, v) }

      req = Net::HTTP::Post::Multipart.new uri.path, "file" => UploadIO.new(File.open(file_hash[:tempfile]), file_hash[:type], file_hash[:filename])
      options[:headers].each {|k,v| req[k] = v }

      http.request(req)
    end

    def get(url)
      open_uri(url).read
    end

    def download(url)
      open_uri(url)
    end

    def inspect
      cache_inspected = @cache.inspect_without [ :@data ]
      cache_inspected.gsub!(/>$/, ", @size=#{@cache.count}>")
      inspected = inspect_without [ :@cache ]
      inspected.gsub(/>$/, ", @cache=#{cache_inspected}>")
    end

    private

    def open_uri(url)
      hit_or_miss = @cache.key?(url) ? 'HIT' : 'MISS'
      @log.info "Cache in RAM memory size: #{@cache.count}, #{hit_or_miss} for url: #{url}"
      contents = @cache.fetch(url) do
        tmpfile = ::Timeout.timeout(10) do
          PuppetForgeServer::Logger.get.debug "Fetching data for url: #{url} from remote server"
          open(url, @uri_options)
        end
        contents = tmpfile.read
        tmpfile.close
        contents
      end
      @log.debug "Data for url: #{url} fetched, #{contents.size} bytes"
      @cache[url] = contents
      StringIO.new(contents)
    end
  end
end
