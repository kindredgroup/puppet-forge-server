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

require 'open-uri'
require 'open_uri_redirections'

module PuppetForgeServer::Http
  class HttpClient
    def get(url)
      open_uri(url).read
    end

    def download(url)
      open_uri(url)
    end

    private
    def open_uri(url)
      open(url, 'User-Agent' => "Puppet-Forge-Server/#{PuppetForgeServer::VERSION}", :allow_redirections => :safe)
    end
  end
end
