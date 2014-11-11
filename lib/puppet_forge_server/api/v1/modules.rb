# -*- encoding: utf-8 -*-
#
# Copyright 2014 drrb
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

module PuppetForgeServer::Api::V1
  module Modules

    def get_modules(metadata)
      modules = metadata.map do |element|
        name = element[:metadata].name.sub(/^[^-]+-/, '')
        full_name = element[:metadata].name.sub('-', '/')
        {
            :author => element[:metadata].author,
            :full_name => full_name,
            :name => name,
            :desc => element[:metadata].description,
            :version => element[:metadata].version,
            :project_url => element[:metadata].project_page,
            :releases => [{:version => element[:metadata].version}],
            :tag_list => [element[:metadata].author, name]
        }
      end

      merge_modules(modules)
    end

    private
    def merge_modules(modules)
      grouped_modules = modules.group_by do |result|
        result[:full_name]
      end

      grouped_modules.values.map do |value|
        merge_values(value)
      end.flatten.uniq
    end

    def merge_values(value)
      highest_version, tags, releases = value.inject([nil, [], []]) do |(highest_version, tags, releases), result|
        [
            max_version(highest_version, result[:version]),
            tags + (result[:tag_list] || []),
            releases + (result[:releases] || [])
        ]
      end

      value.first.tap do |result|
        result[:version] = highest_version
        result[:tag_list] = tags.uniq
        result[:releases] = releases.uniq.version_sort_by { |r| r[:version] }.reverse
      end
    end

    def max_version(left, right)
      [Gem::Version.new(left), Gem::Version.new(right)].max.version
    end
  end
end
