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

module PuppetForgeServer::Models
  describe Dependency do
    let(:name) { 'dummy_name' }
    let(:version_requirement) { '0.0.0' }
    let(:dependency) { PuppetForgeServer::Models::Dependency.new({:name => name, :version_requirement => version_requirement}) }
    describe '#initialize' do
      it 'should create a dependency instance' do
        expect(dependency.name).to eq name
        expect(dependency.version_requirement).to eq version_requirement
      end
    end

    describe '#hash' do
      it 'should calculate hash from name and version_requirement' do
        expect(dependency.hash).to eq(name.hash ^ version_requirement.hash)
      end
    end

    describe '#eql?' do
      it 'should be equal based only on name and version_requirement' do
        dependency2 = dependency.clone
        expect(dependency).to eq dependency2
        dependency2.name = 'something_else'
        expect(dependency).not_to eq dependency2
      end
    end
  end
end
