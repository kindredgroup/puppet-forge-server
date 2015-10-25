# -*- encoding: utf-8 -*-
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
require 'aws-sdk'

module PuppetForgeServer::Backends
  class S3
    include PuppetForgeServer::Utils::Archiver
    # Priority should be lower than v3 API proxies as v3 requires less API calls
    @@PRIORITY = 0
    attr_reader :PRIORITY

    def initialize(bucket, cache_dir, s3_client)
        @bucket = bucket
        @cache_dir = File.join(cache_dir, Digest::SHA1.hexdigest(@bucket))
        @s3 = s3_client
        # Create directory structure for all alphabetic letters
        ('a'..'z').each do |i|
          FileUtils.mkdir_p(File.join(@cache_dir, i))
        end
    end

    def get_modules(filename, options)
      options = ({:with_checksum => true}).merge(options)
      modules = []
      s3_filenames = []

      bucket_list = @s3.list_objects({bucket: @bucket})
      bucket_list.contents.each do |s3_object|
        if /modules\/#{filename}/ =~ s3_object.key
          s3_filenames << s3_object.key.gsub(/^modules\//, '')
        end
      end

      s3_filenames.each do |exact_filename|
        path = File.join(@cache_dir, exact_filename[0].downcase, exact_filename)
        target_file = File.open(path, "w")
        @s3.get_object({bucket: @bucket, key: "modules/#{exact_filename}", response_target: target_file})
        modules << new_module(path, options, exact_filename)
      end

      modules.reject{|i| i.nil?}
    end

    def new_module(path, options, exact_filename)
      metadata = read_metadata(path)
      if metadata
        thismodule = PuppetForgeServer::Models::Module.new({
          :metadata => parse_dependencies(PuppetForgeServer::Models::Metadata.new(normalize_metadata(metadata))),
          :checksum => options[:with_checksum] ? Digest::MD5.file(path).hexdigest : nil,
          :path => exact_filename,
          :private => ! @readonly
          })
      else
        @log.error "Failed reading metadata from #{path}"
        thismodule = nil
      end
      thismodule
    end

    def get_metadata(author, name, options = {})
      version = options[:version] ? options[:version] : '.*'
      get_modules("#{author}-#{name}-#{version}.tar.gz", options)
    end

    def query_metadata(query, options = {})
      get_modules("*#{query}*.tar.gz", options)
    end

    def parse_dependencies(metadata)
      metadata.dependencies = metadata.dependencies.dup.map do |dependency|
        PuppetForgeServer::Models::Dependency.new({:name => dependency['name'], :version_requirement => dependency.key?('version_requirement') ? dependency['version_requirement'] : nil})
      end.flatten
      metadata
    end

    def normalize_metadata(metadata)
      metadata['name'] = metadata['name'].gsub('/', '-')
      metadata
    end

    def get_file_buffer(relative_path)
      file_name = relative_path.split('/').last
      File.join(@cache_dir, file_name[0].downcase, file_name)
      path = Dir["#{@cache_dir}/**/#{file_name}"].first
      unless File.exist?("#{path}")
        buffer = download("#{@file_path}/#{relative_path}")
        File.open(File.join(@cache_dir, file_name[0].downcase, file_name), 'wb') do |file|
          file.write(buffer.read)
        end
        path = File.join(@cache_dir, file_name[0].downcase, file_name)
      end
      File.open(path, 'rb')
      rescue => e
      @log.error("#{self.class.name} failed downloading file '#{relative_path}'")
      @log.error("Error: #{e}")
      return nil
    end

    private
    def read_metadata(archive_path)
        metadata_file = read_from_archive(archive_path, %r[[^/]+/metadata\.json$])
        JSON.parse(metadata_file)
    rescue => error
        warn "Error reading from module archive #{archive_path}: #{error}"
        return nil
    end

  end
end
