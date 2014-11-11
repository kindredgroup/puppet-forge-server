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


module PuppetForgeServer::Utils
  module Http
    def get_api_version(url)
      check_url = '/v3/modules/puppetlabs-stdlib'
      begin
        PuppetForgeServer::Http::HttpClient.new.get("#{url.chomp('/')}#{check_url}")
        3
      rescue OpenURI::HTTPError
        1
      end
    end
  end
end