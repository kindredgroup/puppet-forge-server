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

module PuppetForgeServer::Api::V1
  module Releases
    def get_releases(metadata)
      metadata.map do |element|
        {
            :file => "/api/v1/files#{element[:path]}",
            :version => element[:metadata].version,
            :dependencies => element[:metadata].dependencies.map {|dep| [dep.name, dep.version_requirement]}.compact
        }
      end.uniq{|r| r[:version]}.sort_by {|r| Gem::Version.new(r[:version])}
    end
  end
end
