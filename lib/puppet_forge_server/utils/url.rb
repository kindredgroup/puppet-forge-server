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

require 'uri'

module PuppetForgeServer::Utils
  module Url
    def normalize_url(uri_string)
      begin
        url = URI.parse(uri_string)
      rescue URI::InvalidURIError => e
        raise PuppetForgeServer::Error::Expected, "Invalid URL '#{uri_string}': #{e.message}"
      end
      if url.scheme
        raise PuppetForgeServer::Error::Expected, "Invalid URL '#{uri_string}': unsupported protocol '#{url.scheme}'" unless url.scheme =~ /^https?$/
      else
        uri_string = "http://#{uri_string}"
      end
      uri_string.sub /\/$/, ''
    end
  end
end
