# -*- encoding: utf-8 -*-
#
# Copyright 2015 North Development AB
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

module PuppetForgeServer::Api::V1
  module Modules

    def get_modules(metadata)
      modules = {}
      metadata.each do |element|
        if modules[element.metadata.name]
          if max_version(modules[element.metadata.name][:version], element.metadata.version) == element.metadata.version
            modules[element.metadata.name][:desc] = element.metadata.description
            modules[element.metadata.name][:version] = element.metadata.version
            modules[element.metadata.name][:project_url] = element.metadata.project_page
          end
          modules[element.metadata.name][:releases] = (modules[element.metadata.name][:releases] + releases_version(element.metadata)).uniq.sort_by { |r| Gem::Version.new(r[:version]) }.reverse
          modules[element.metadata.name][:tag_list] = (modules[element.metadata.name][:tag_list] + element.tags).uniq.compact
        else
          author, name = element.metadata.name.split('-')
          unless name
            name = author
            author = element.metadata.author
          end
          modules[element.metadata.name] = {
            :author => author,
            :full_name => element.metadata.name.sub('-', '/'),
            :name => name,
            :desc => element.metadata.description || element.metadata.summary,
            :version => element.metadata.version,
            :project_url => element.metadata.project_page,
            :releases => releases_version(element.metadata),
            :tag_list =>  element.tags ? element.tags : [author, name],
            :private => element.private
          }
        end
      end

      modules.values
    end

    private
    def releases_version(metadata)
      [{:version => metadata.version}]
    end

    def max_version(left, right)
      [Gem::Version.new(left), Gem::Version.new(right)].max.version
    end
  end
end
