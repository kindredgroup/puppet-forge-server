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
  module Modules
    include PuppetForgeServer::Api::V3::Releases

    def get_modules(metadata)
      modules = {}
      metadata.each do |element|
        if modules[element.metadata.name]
          if max_version(modules[element.metadata.name][:current_release][:version], element.metadata.version) == element.metadata.version
            # Saving curret release tags for merging with new max version current release
            tags = modules[element.metadata.name][:current_release][:tags]
            modules[element.metadata.name][:current_release] = get_releases([element]).first
            modules[element.metadata.name][:current_release][:tags] = (modules[element.metadata.name][:current_release][:tags] + tags).uniq.compact
          end
          modules[element.metadata.name][:releases] = (modules[element.metadata.name][:releases] + releases_version(element.metadata)).uniq.sort_by { |r| Gem::Version.new(r[:version]) }.reverse
        else
          author, name = element.metadata.name.split('-')
          unless name
            name = author
            author = element.metadata.author
          end
          modules[element.metadata.name] = {
              :uri => "/v3/modules/#{element.metadata.name}",
              :name => name,
              :homepage_url => element.metadata.project_page,
              :issues_url => element.metadata.issues_url,
              :releases => releases_version(element.metadata),
              :current_release => get_releases([element]).first,
              :owner => {:username => author, :uri => "/v3/users/#{author}"},
              :private => element.private
          }
        end
      end
      modules.values
    end

    private
    def releases_version(metadata)
      [{:version => metadata.version, :uri => "/v3/releases/#{metadata.name}-#{metadata.version}"}]
    end

    def max_version(left, right)
      [Gem::Version.new(left), Gem::Version.new(right)].max.version
    end
  end
end
