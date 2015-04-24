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
    attr_reader :PRIORITY

    def initialize(url, cache_dir, http_client = PuppetForgeServer::Http::HttpClient.new)
      super(url, cache_dir, http_client)
    end

    def get_metadata(author, name, options = {})
      query ="#{author}-#{name}"
      begin
        releases = options[:version] ? [JSON.parse(get("/v3/releases/#{query}-#{options[:version]}"))] : get_all_result_pages("/v3/releases?module=#{query}")
        get_release_metadata(releases)
      rescue => e
        @log.debug("#{self.class.name} failed querying metadata for '#{query}' with options #{options}")
        @log.debug("Error: #{e}")
        nil
      end
    end

    def query_metadata(query, options = {})
      begin
        releases = get_all_result_pages("/v3/modules?query=#{query}").map {|element| element['current_release']}
        get_release_metadata(releases)
      rescue => e
        @log.debug("#{self.class.name} failed querying metadata for '#{query}' with options #{options}")
        @log.debug("Error: #{e}")
        nil
      end
    end

    private
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

    def get_release_metadata(releases)
      releases.map do |element|
        {
            :metadata => parse_dependencies(PuppetForgeServer::Models::Metadata.new(normalize_metadata(element['metadata']))),
            :checksum => element['file_md5'],
            :path => element['file_uri'],
            :tags => (element['tags'] + (element['metadata']['tags'] ? element['metadata']['tags'] : [])).flatten.uniq
        }
      end
    end
  end
end
