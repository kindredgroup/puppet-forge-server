require 'spec_helper'
require 'puppet_forge_server'

describe PuppetForgeServer::Http::HttpClient do
  # Finding a free port to host mock server
  let(:port) do
    require 'socket'
    server = TCPServer.new('127.0.0.1', 0)
    port = server.addr[1]
    server.close
    port
  end
  let(:uri) { "http://localhost:#{port}/" }
  before(:each) do
    # Staring a mock server on free port to test network fetching performence
    @server = TCPServer.new('localhost', port)
    @thr = Thread.new do
      loop do
        socket = @server.accept
        response = "Hello!"
        socket.print "HTTP/1.1 200 OK\r\n" +
                     "Content-Type: text/plain\r\n" +
                     "Content-Length: #{response.bytesize}\r\n" +
                     "Connection: close\r\n"
        socket.print "\r\n"
        # To simulate network lag
        sleep 0.05
        socket.print response
        socket.close
      end
    end
    @original_level = PuppetForgeServer::Logger.get.level.first
    PuppetForgeServer::Logger.get.level = Logger::WARN
  end
  after(:each) do
    @server.close
    @thr.kill
    PuppetForgeServer::Logger.get.level = @original_level
  end
  let(:instance) { described_class.new(cache) }
  describe '#download' do
    let(:load) do
      Proc.new do
        # To simulate multiple fetches
        99.times { instance.download(uri) }
        instance.download(uri)
      end
    end
    subject do
      load.call
    end
    context 'with 1sec LRU cache' do
      let(:cache) do
        require 'lru_redux'
        LruRedux::TTL::Cache.new(100, 1)
      end
      it { expect { load.call }.to run_for < 0.01 }
      it { expect(subject).not_to be_nil }
      it { expect(subject).not_to be_closed }
    end
    context 'with default cache' do
      let(:cache) { nil }
      it { expect { load.call }.to run_for < 0.01 }
      it { expect(subject).not_to be_nil }
      it { expect(subject).not_to be_closed }
    end
  end
  describe '#get' do
    let(:load) do
      Proc.new do
        # To simulate multiple fetches
        99.times { instance.get(uri) }
        instance.get(uri)
      end
    end
    subject do
      load.call
    end
    context 'with 1sec LRU cache' do
      let(:cache) do
        require 'lru_redux'
        LruRedux::TTL::Cache.new(1,100)
      end
      it { expect(subject).to eq('Hello!') }
      it { expect { load.call }.to run_for < 0.01 }
    end
    context 'with default cache' do
      let(:cache) { nil }
      it { expect(subject).to eq('Hello!') }
      it { expect { load.call }.to run_for < 0.01 }
    end
  end
end
