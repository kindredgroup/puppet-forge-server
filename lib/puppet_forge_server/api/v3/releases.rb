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

module PuppetForgeServer::Api::V3
  module Releases
    def get_releases(metadata)
      metadata.map do |element|
        name = element.metadata.name.sub(/^[^-]+-/, '')
        author = element.metadata.name.split('-')[0]
        {
            :uri => "/v3/releases/#{element.metadata.name}-#{element.metadata.version}",
            :module => {
                :uri => "/v3/modules/#{element.metadata.name}",
                :name => name,
                :owner => {:username => author, :uri => "/v3/users/#{author}"}
            },
            :metadata => element.metadata.to_hash,
            :version => element.metadata.version,
            :tags => element.tags ? element.tags : [element.metadata.author, name],
            :file_uri => "/v3/files#{element.path}",
            :file_md5 => element.checksum,
            :deleted_at => element.deleted_at
        }
      end.uniq{|r| r[:version]}.sort_by { |r| Gem::Version.new(r[:version]) }
    end
  end
end
