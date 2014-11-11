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

require 'rubygems/package'

class Hash
  def deep_merge(other)
    merge(other) do |key, old_val, new_val|
      if old_val.instance_of? Array
        old_val + new_val
      else
        new_val
      end
    end
  end

  def deep_merge!(other)
    replace(deep_merge(other))
  end
end

class Array
  def deep_merge
    inject({}) do |merged, map|
      merged.deep_merge(map)
    end
  end

  def version_sort_by
    sort_by do |element|
      version = yield(element)
      Gem::Version.new(version)
    end
  end
end

# Used by PuppetForgeServer::Utils::Archiver
class Gem::Package::TarReader
  # Old versions of RubyGems don't include Enumerable in here
  def find
    each do |entry|
      if yield(entry)
        return entry
      end
    end
  end
end