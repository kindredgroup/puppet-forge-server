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
        if name.to_s == 'decription'
          normalized_name = :description
        else
          normalized_name = name.to_s.tr('-', '_').to_sym
        end
        send("#{normalized_name}=", value) unless value.to_s.empty?
      end
    end

    def method_missing (method_name, *args, &block)
      PuppetForgeServer::Logger.get.error "Method #{method_name} with args #{args} not found in #{self.class.to_s}" unless method_name == :to_ary
    end

    def to_hash(obj = self)
      # Quickly return if it's not one of ours
      unless obj.kind_of? Builder
        return obj
      end
      # Otherwise start building hash
      hash = {}
      obj.instance_variables.each do |var|
        var_value = obj.instance_variable_get(var)
        hash[var.to_s.delete('@')] = if var_value.kind_of?(Array)
          var_value.map {|v| to_hash(v)}
        elsif var_value.respond_to?(:to_hash)
         var_value.to_hash
        else
          var_value
        end
      end
      hash
    end
  end
end
