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
  class Metadata < Builder
    attr_accessor :author, :name, :version, :dependencies, :summary, :description, :project_page, :types
    attr_accessor :checksums, :source, :license, :issues_url, :operatingsystem_support, :requirements
    attr_accessor :puppet_version, :tags, :mail, :classes, :definitions
    attr_accessor :pdk_version, :template_url, :template_ref, :data_provider, :docs_project
    attr_accessor :forge_url, :package_release_version, :issue_url
    attr_accessor :kpn_quality_label, :kpn_module_owner, :kpn_module_support

    def initialize(attributes)
      super(attributes)
    end

    def ==(other)
      other && self.class.equal?(other.class) &&
        @author == other.author &&
        @name == other.name &&
        @version == other.version
    end

    def hash
      @author.hash ^ @name.hash ^ @version.hash
    end

    def eql?(other)
      other && self.class.equal?(other.class) &&
        @author.eql?(other.author) &&
        @name.eql?(other.name) &&
        @version.eql?(other.version)
    end
  end
end
