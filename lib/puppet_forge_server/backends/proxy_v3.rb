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

require 'json'

module PuppetForgeServer::Backends
  class ProxyV3 < PuppetForgeServer::Backends::Proxy

    @@PRIORITY = 10
    @@FILE_PATH = '/v3/files'
    attr_reader :PRIORITY

    def initialize(url, cache_dir, http_client = PuppetForgeServer::Http::HttpClient.new)
      super(url, cache_dir, http_client, @@FILE_PATH)
    end

    def get_metadata(author, name, options = {})
      query ="#{author}-#{name}"
      begin
        releases = get_releases(query, options)
        get_modules(releases)
      rescue => e
        @log.error("#{self.class.name} failed querying metadata for '#{query}' with options #{options}")
        @log.error("Error: #{e}")
        return nil
      end
    end

    def query_metadata(query, options = {})
      begin
        releases = get_all_result_pages("/v3/modules?query=#{query}").map {|element| element['current_release']}
        get_modules(releases)
      rescue => e
        @log.error("#{self.class.name} failed querying metadata for '#{query}' with options #{options}")
        @log.error("Error: #{e}")
        return nil
      end
    end

    private

    def get_releases(query, options = {})
      version = options[:version]
      unless version.nil?
        url = "/v3/releases/#{query}-#{version}"
        buffer = get_non_mutable(url)
        release = JSON.parse(buffer)
        [ release ]
      else
        get_all_result_pages("/v3/releases?module=#{query}")
      end
    end

    def get_all_result_pages(next_page)
      results = []
      begin
        current_page = JSON.parse(get(next_page))
        results += current_page['results']
        next_page = current_page['pagination']['next']
      end while next_page
      results
    end

    def normalize_metadata(metadata)
      metadata['name'] = metadata['name'].gsub('/', '-')
      metadata
    end

    def parse_dependencies(metadata)
      metadata.dependencies = metadata.dependencies.dup.map do |dependency|
        PuppetForgeServer::Models::Dependency.new({:name => dependency['name'], :version_requirement => dependency['version_requirement']})
      end.flatten
      metadata
    end

    def get_modules(releases)
      releases.map do |element|
        PuppetForgeServer::Models::Module.new({
          :metadata => parse_dependencies(PuppetForgeServer::Models::Metadata.new(normalize_metadata(element['metadata']))),
          :checksum => element['file_md5'],
          :path => element['file_uri'].gsub(/^#{@@FILE_PATH}/, ''),
          :tags => (element['tags'] + (element['metadata']['tags'] ? element['metadata']['tags'] : [])).flatten.uniq,
          :deleted_at => element['deleted_at'],
          :readme => element['readme']
        })
      end
    end
  end
end
