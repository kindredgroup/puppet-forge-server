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

require 'spec_helper'

module PuppetForgeServer::App
  describe Version1 do
    let(:app) { PuppetForgeServer::App::Version1.new([directory]) }
    let(:directory) do
      double('directory', :get_file_buffer => file)
    end

    describe "#get /system/releases/m/user/user-module.tar.gz" do
      context 'when the module does not exists' do
        let(:file) { nil }

        it 'returns 404' do
          get "/system/releases/i/user/user-idonotexist.tar.gz"

          expect(last_response).to be_not_found
          expect(last_response.body).to eq(
            JSON.generate({:errors => ['404 Not found']})
          )
        end
      end

      context 'when the module does not exists' do
        let(:file) { 'user-module.tar.gz' }

        it 'download the module when it exists' do
          get "/system/releases/m/user/#{file}"

          expect(last_response).to be_ok
          expect(last_response.body).to eq(file)
          expect(last_response.header).to include({
            'Content-Disposition' => "attachment; filename=\"#{file}\"",
            'Content-Type'=>'application/octet-stream',
            'Content-Length'=>'18',
          })
        end
      end
    end
  end
end
