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
    let(:backend) { double() }
    let(:app) { PuppetForgeServer::App::Version1.new([backend]) }
    let(:module_author) { 'bogus_author' }
    let(:module_name) { 'bogus_name' }
    let(:module_string) { "#{module_author}/#{module_name}" }
    let(:module_deps) { [ PuppetForgeServer::Models::Dependency.new({:name => 'bogus_dep1'})] }
    let(:module_metadata) { PuppetForgeServer::Models::Metadata.new({:author => module_author, :name => module_name, :dependencies => module_deps}) }
    let(:module_hash) { { :metadata => module_metadata, :checksum => nil, :path => nil} }
    let(:backend_module) { PuppetForgeServer::Models::Module.new(module_hash) }

    before(:each) do
      allow(backend).to receive(:get_metadata).with(module_author, module_name, {:version => nil, :with_checksum => false}) { backend_module }
      allow(backend).to receive(:query_metadata).with(module_string, {:with_checksum => false}) { backend_module }
    end

    describe '#get /api/v1/releases.json' do
      it 'should get bogus release json' do
        get '/api/v1/releases.json', params={ :module => module_string }
        expect(last_response).to be_ok
        expect(JSON.parse(last_response.body).keys.first).to eq(module_string)
      end
    end

    describe '#get /modules.json' do
      it 'should get bogus modules json' do
        get '/modules.json', params={ :q => module_string }
        expect(last_response).to be_ok
        module_hash = JSON.parse(last_response.body).first

        expect(module_hash['author']).to eq(module_author)
        expect(module_hash['full_name']).to eq(module_name)
        expect(module_hash['name']).to eq(module_name)
        expect(module_hash['tag_list']).to eq([module_author, module_name])
        expect(module_hash['private']).not_to be
      end
    end
  end
end
