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

module PuppetForgeServer::Models
  class Builder
    def initialize(attributes={})
      attributes.each do |name, value|
        send("#{name}=", value) unless value.to_s.empty?
      end
    end

    def method_missing (method_name, *args, &block)
      STDERR.puts "ERROR: Method #{method_name} with args #{args} not found in #{self.class.to_s}" unless method_name == :to_ary
    end

    def to_hash
      hash = {}
      self.instance_variables.each do |var|
        hash[var.to_s.delete('@')] = self.instance_variable_get var
      end
      hash
    end
  end
end