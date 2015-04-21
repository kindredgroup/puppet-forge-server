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
  describe Version2 do
    let(:directory) { double() }
    let(:app) { PuppetForgeServer::App::Version2.new([directory]) }
    let(:file_name_true) { 'bogus_file_true' }
    let(:file_name_false) { 'bogus_file_false' }

    before(:each) do
      allow(directory).to receive(:upload).with(file_name_true) { true }
      allow(directory).to receive(:upload).with(file_name_false) { false }
    end

    describe '#post /v2/releases' do
      it 'file upload should succeed' do
        post '/v2/releases', params={ :file => file_name_true }
        expect(last_response).to be_ok
      end

      it 'file upload should fail' do
        post '/v2/releases', params={ :file => file_name_false }
        expect(last_response.status).to eq(412)
      end
    end
  end
end
