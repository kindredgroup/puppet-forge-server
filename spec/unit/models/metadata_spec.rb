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

require 'spec_helper'

module PuppetForgeServer::Models
  describe Metadata do
    let(:name) { 'dummy_name' }
    let(:author) { 'dummy_author' }
    let(:version) { '0.0.0' }
    let(:project_page) { 'http://bogus-project-page.com' }
    let(:metadata) { PuppetForgeServer::Models::Metadata.new({:name => name, :author => author, :version => version, :project_page => project_page}) }
    describe '#initialize' do
      it 'should create a metadata instance' do
        expect(metadata.author).to eq author
        expect(metadata.name).to eq name
        expect(metadata.version).to eq version
      end
    end

    describe '#hash' do
      it 'should calculate hash from name, author and version' do
        expect(metadata.hash).to eq(author.hash ^ name.hash ^ version.hash)
      end
    end

    describe '#eql?' do
      it 'should be equal based only on name, author and version' do
        metadata2 = metadata.clone
        expect(metadata).to eq metadata2
        metadata2.project_page = 'http://bogus-project-page2.com'
        expect(metadata).to eq metadata2
        metadata2.name = 'something_else'
        expect(metadata).not_to eq metadata2
      end
    end
  end
end
