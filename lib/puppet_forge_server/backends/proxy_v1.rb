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
require 'digest/md5'

module PuppetForgeServer::Backends
  class ProxyV1 < PuppetForgeServer::Backends::Proxy

    # Priority should be lower than v3 API proxies as v3 requires less API calls
    @@PRIORITY = 15
    attr_reader :PRIORITY

    def initialize(url, cache_dir, http_client = PuppetForgeServer::Http::HttpClient.new)
      super(url, cache_dir, http_client)
    end

    def get_metadata(author, name, options = {})
      options = ({:with_checksum => true}).merge(options)
      query ="#{author}/#{name}"
      begin
        get_module_metadata(JSON.parse(get("/modules.json?q=#{query}")).select { |e| e['full_name'].match("#{query}") }, options)
      rescue => e
        @log.debug("#{self.class.name} failed querying metadata for '#{query}' with options #{options}")
        @log.debug("Error: #{e}")
        return nil
      end
    end

    def query_metadata(query, options = {})
      options = ({:with_checksum => true}).merge(options)
      begin
        get_module_metadata(JSON.parse(get("/modules.json?q=#{query}")).select { |e| e['full_name'].match("*#{query}*") }, options)
      rescue => e
        @log.debug("#{self.class.name} failed querying metadata for '#{query}' with options #{options}")
        @log.debug("Error: #{e}")
        return nil
      end
    end

    private
    def read_metadata(element, release)
      element['project_page'] = element['project_url']
      element['name'] = element['full_name'] ? element['full_name'].gsub('/', '-') : element['name']
      element['description'] = element['desc']
      element['version'] = release['version'] ? release['version'] : element['version']
      element['dependencies'] = release['dependencies'] ? release['dependencies'] : []
      %w(project_url full_name releases tag_list desc).each { |key| element.delete(key) }
      element
    end

    def parse_dependencies(metadata)
      metadata.dependencies = metadata.dependencies.dup.map do |dependency|
        PuppetForgeServer::Models::Dependency.new({:name => dependency[0], :version_requirement => dependency.length > 1 ? dependency[1] : nil})
      end.flatten
      metadata
    end

    def get_module_metadata(modules, options)
      modules.map do |element|
        version = options['version'] ? "&version=#{options['version']}" : ''
        JSON.parse(get("/api/v1/releases.json?module=#{element['author']}/#{element['name']}#{version}")).values.first.map do |release|
          tags = element['tag_list'] ? element['tag_list'] : nil
          raw_metadata = read_metadata(element, release)
          {
              :metadata => parse_dependencies(PuppetForgeServer::Models::Metadata.new(raw_metadata)),
              :checksum => options[:with_checksum] ? Digest::MD5.hexdigest(File.read(get_file_buffer(release['file']))) : nil,
              :path => "#{release['file']}",
              :tags => tags
          }
        end
      end
    end
  end
end
