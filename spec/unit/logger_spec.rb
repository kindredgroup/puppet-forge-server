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

module PuppetForgeServer
  describe Logger do
    let(:msg) { 'this is a dummy message' }
    let(:test_io) { StringIO.new }
    let(:logger) { PuppetForgeServer::Logger.new(test_io) }

    describe '#info' do
      it 'should log message on level info' do
        expect(logger).to respond_to(:info)
        logger.info msg
        expect(test_io.string).to include("INFO  #{msg}")
      end
    end

    describe '#error' do
      it 'should log message on level error' do
        expect(logger).to respond_to(:error)
        logger.error msg
        expect(test_io.string).to include("ERROR  #{msg}")
      end
    end

    describe '#warn' do
      it 'should log message on level warn' do
        expect(logger).to respond_to(:warn)
        logger.warn msg
        expect(test_io.string).to include("WARN  #{msg}")
      end
    end

    describe '#debug' do
      it 'should log message on level debug' do
        expect(logger).to respond_to(:debug)
        logger.debug msg
        expect(test_io.string).to include("DEBUG  #{msg}")
      end
    end

    describe '#puts' do
      it 'should log message' do
        expect(logger).to respond_to(:puts)
        logger.puts msg
        expect(test_io.string).to include(msg)
      end
    end

    describe '#<<' do
      it 'should log message' do
        expect(logger).to respond_to('<<')
        logger << msg
        expect(test_io.string).to include(msg)
      end
    end

    describe '#flush' do
      it 'should respond to flush' do
        expect(logger).to respond_to('flush')
      end
    end

    describe '#non_existing' do
      it 'should fail on non existing method' do
        expect { logger.non_existing }.to raise_error(NoMethodError)
      end
    end
  end
end
