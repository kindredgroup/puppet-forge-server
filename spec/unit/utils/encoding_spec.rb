require 'spec_helper'

describe 'PuppetForgeServer::Utils::Encoding' do
  let(:dummy_class) { Class.new { include PuppetForgeServer::Utils::Encoding } }
  let(:dummy) { dummy_class.new }
  describe '#to_utf8' do
    subject { dummy.to_utf8(input_text) }
    context 'for nil' do
      let(:input_text) { nil }
      it { expect(subject).to be_nil }
    end

    context 'for valid ascii text' do
      let(:input_text) { 'a simple ascii text!' }
      it { expect(subject).to eq('a simple ascii text!') }
    end

    context 'for valid utf-8 text' do
      let(:input_text) { 'Zażółć gęślą jażń' }
      it { expect(subject).to eq('Zażółć gęślą jażń') }
    end

    context 'for text with ISO-8859-1 encoded as UTF-8' do
      let(:input_text) { "Co\xE2te d'Azur" }
      it { expect(subject).to eq('Cote d\'Azur') }
    end

    context 'for text with UTF-8 not replaced characters' do
      let(:multidot) { [0xE2, 0x80, 0xA6].pack("c*") }
      let(:input_text) { "Read more#{multidot}" }
      it { expect(subject).to eq('Read more…') }
    end
  end
end
