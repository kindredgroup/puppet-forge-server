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

require 'puppet_forge_server/patches'
require 'puppet_forge_server/version'

module PuppetForgeServer
  autoload :Server, 'puppet_forge_server/server'
  autoload :Errors, 'puppet_forge_server/errors'
  autoload :Logger, 'puppet_forge_server/logger'

  module Api
    module V1
      autoload :Modules, 'puppet_forge_server/api/v1/modules'
      autoload :Releases, 'puppet_forge_server/api/v1/releases'
    end
    module V3
      autoload :Modules, 'puppet_forge_server/api/v3/modules'
      autoload :Releases, 'puppet_forge_server/api/v3/releases'
    end
  end

  module App
    autoload :Version1, 'puppet_forge_server/app/version1'
    autoload :Version3, 'puppet_forge_server/app/version3'
  end

  module Backends
    autoload :Directory, 'puppet_forge_server/backends/directory'
    autoload :Proxy, 'puppet_forge_server/backends/proxy'
    autoload :ProxyV1, 'puppet_forge_server/backends/proxy_v1'
    autoload :ProxyV3, 'puppet_forge_server/backends/proxy_v3'
  end

  module Models
    autoload :Builder, 'puppet_forge_server/models/builder'
    autoload :Metadata, 'puppet_forge_server/models/metadata'
  end

  module Utils
    autoload :Archiver, 'puppet_forge_server/utils/archiver'
    autoload :OptionParser, 'puppet_forge_server/utils/option_parser'
    autoload :Url, 'puppet_forge_server/utils/url'
    autoload :Buffer, 'puppet_forge_server/utils/buffer'
    autoload :Http, 'puppet_forge_server/utils/http'
  end

  module Http
    autoload :HttpClient, 'puppet_forge_server/http/http_client'
  end
end