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

require 'iconv'

module PuppetForgeServer::Utils
  module Encoding

    @@ic = Iconv.new('UTF-8//IGNORE', 'UTF-8')

    # Converts give text to valid UTF-8
    # @param [string] text given string, can be null
    # @return [string] output string in utf-8
    def to_utf8(text)
      replaced = text
      unless replaced.nil?
        replaced = replaced.force_encoding("UTF-8") if is_ascii_8bit?(replaced)
        replaced = cleanup_utf8(replaced)
      end
      replaced
    end

    private

    def is_ascii_8bit?(text)
      text.encoding.name == 'ASCII-8BIT'
    end

    def cleanup_utf8(text)
      @@ic.iconv(text)
    end
  end
end
