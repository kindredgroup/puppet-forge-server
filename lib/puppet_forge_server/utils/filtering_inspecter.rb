# -*- encoding: utf-8 -*-
#
# Copyright 2015 Centralny Osroder Informatyki (gov.pl)
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

module PuppetForgeServer::Utils
  module FilteringInspecter
    def self.inspect_without(object, variables)
      filtered = object.instance_variables.reject { |n| variables.include? n }
      vars = filtered.map { |n| "#{n}=#{object.instance_variable_get(n).inspect}" }
      oid = object.object_id << 1
      "#<%s:0x%x %s>" % [ object.class, oid, vars.join(', ') ]
    end

    def inspect_without(variables)
      PuppetForgeServer::Utils::FilteringInspecter.inspect_without(self, variables)
    end
  end
end
