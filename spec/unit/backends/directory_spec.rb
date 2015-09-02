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

module PuppetForgeServer::Backends
  describe Directory do
    let(:url) { 'bogus_url' }
    let(:name) { 'bogus_name' }
    let(:author) { 'bogus_author' }
    let(:version) { 'bogus_version' }
    let(:directory) { PuppetForgeServer::Backends::Directory.new(url) }
    let(:file_metadata) { { :metadata => nil, :checksum => nil, :path => nil} }
    let(:backend_module) { PuppetForgeServer::Models::Module.new(file_metadata) }
    let(:file_data) { { :filename => 'bogus_filename' } }

    before(:each) do
      allow(directory).to receive(:get_modules).with("*#{name}*.tar.gz", {}) { backend_module }
      allow(directory).to receive(:get_modules).with("#{author}-#{name}-*.tar.gz", {}) { backend_module }
      allow(directory).to receive(:get_modules).with("#{author}-#{name}-#{version}.tar.gz", {:version => version}) { backend_module }
      allow(File).to receive(:open).with("#{url}/#{file_data[:filename]}", 'w')
    end

    describe '#query_metadata' do
      it 'query metadata should return file metadata array' do
        expect(directory.query_metadata(name)).to eq(backend_module)
      end
    end

    describe '#get_metadata' do
      it 'get_metadata without version should return file metadata array' do
        expect(directory.get_metadata(author, name)).to eq(backend_module)
      end

      it 'get_metadata with version should return file metadata array' do
        expect(directory.get_metadata(author, name, {:version => version})).to eq(backend_module)
      end
    end

    describe '#upload' do
      it 'upload when file does not exist should return true' do
        allow(File).to receive(:exist?).with("#{url}/#{file_data[:filename]}") { false }
        expect(directory.upload(file_data)).to be
      end

      it 'upload when file exists should return false' do
        allow(File).to receive(:exist?).with("#{url}/#{file_data[:filename]}") { true }
        expect(directory.upload(file_data)).not_to be
      end
    end
  end
end
