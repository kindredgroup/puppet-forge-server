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
      options = ({:with_checksum => true}).merge(options)
      query ="#{author}-#{name}"
      begin
        releases = options[:version] ? [JSON.parse(get("/v3/releases/#{query}-#{options[:version]}"))] : get_all_release_pages("/v3/releases?module=#{query}")
        get_release_metadata(releases)
      rescue OpenURI::HTTPError
        #ignore
      end
    end

    def query_metadata(query, options = {})
      author, name = query.split('-')
      begin
        get_metadata(author, name, options) if author && name
      rescue OpenURI::HTTPError
        #ignore
      end
    end

    private
    def get_all_release_pages(next_page)
      releases = []
      begin
        result = JSON.parse(get(next_page))
        releases += result['results']
        next_page = result['pagination']['next']
      end while next_page
      releases
    end

    def normalize_metadata(metadata)
      metadata['name'] = metadata['name'].gsub('/', '-')
      metadata
    end

    def get_release_metadata(releases)
      releases.map do |element|
        {
            :metadata => PuppetForgeServer::Models::Metadata.new(normalize_metadata(element['metadata'])),
            :checksum => element['file_md5'],
            :path => element['file_uri'],
            :tags => (element['tags'] + (element['metadata']['tags'] ? element['metadata']['tags'] : [])).flatten.uniq
        }
      end
    end
  end
end
