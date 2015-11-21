# -*- encoding: utf-8 -*-
#
# Copyright 2015 North Development AB
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

require 'tilt/redcarpet'

module PuppetForgeServer::Utils
  module MarkdownRenderer

    class CustomRenderer < Redcarpet::Render::HTML
      def block_code(code, lang)
        output = "<pre>"
        output << "<code class=\"prettyprint lang-puppet\">#{code}</code>"
        output << "</pre>"
      end
    end

    def markdown(text)
      options = {
        filter_html:     true,
        with_toc_data:   true,
        hard_wrap:       true,
        prettify:        true
      }

      extensions = {
        autolink:           true,
        superscript:        true,
        disable_indented_code_blocks: false,
        fenced_code_blocks: true,
        strikethrough: true,
        quote: true,
        tables: true
      }

      renderer = CustomRenderer.new(options)
      markdown = Redcarpet::Markdown.new(renderer, extensions)
      markdown.render(text)
    end

  end
end
