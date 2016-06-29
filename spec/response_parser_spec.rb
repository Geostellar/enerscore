require 'spec_helper'

RSpec.describe Enerscore::ResponseParser do

  def read_api_json(name)
    JSON.parse(read_api_file("#{name}.json"))
  end

  def read_api_file(name)
    File.read "spec/fixtures/api/#{name}"
  end

  let(:parser) { Enerscore::ResponseParser.new response }

  context 'when the API returns an error' do
    let(:response) { read_api_json("error") }
    describe '#status' do
      subject { parser.status }
      it { is_expected.to eq :error }
    end

    describe '#error?' do
      subject { parser.error? }
      it { is_expected.to eq true }
    end

    describe '#no_results?' do
      subject { parser.no_results? }
      it { is_expected.to eq false }
    end

    describe '#results' do
      subject { parser.results }
      it { is_expected.to be_nil }
    end

    describe '#result' do
      subject { parser.result }
      it { is_expected.to be_nil }
    end

    describe '#success' do
      subject { parser.success? }
      it { is_expected.to eq false }
    end
  end

  context 'when the API returns with a network timeout' do
    let(:response) { :network_timeout }
    describe '#status' do
      subject { parser.status }
      it { is_expected.to eq :network_timeout }
    end

    describe '#error?' do
      subject { parser.error? }
      it { is_expected.to eq false }
    end

    describe '#no_results?' do
      subject { parser.no_results? }
      it { is_expected.to eq false }
    end

    describe '#results' do
      subject { parser.results }
      it { is_expected.to be_nil }
    end

    describe '#result' do
      subject { parser.result }
      it { is_expected.to be_nil }
    end

    describe '#success' do
      subject { parser.success? }
      it { is_expected.to eq false }
    end
  end

  context 'when the API returns a response with no results' do
    let(:response) { read_api_json("no_results") }
    describe '#status' do
      subject { parser.status }
      it { is_expected.to eq :no_results }
    end

    describe '#error?' do
      subject { parser.error? }
      it { is_expected.to eq false }
    end

    describe '#no_results?' do
      subject { parser.no_results? }
      it { is_expected.to eq true }
    end

    describe '#results' do
      subject { parser.results }
      it { is_expected.to be_nil }
    end

    describe '#result' do
      subject { parser.result }
      it { is_expected.to be_nil }
    end

    describe '#success' do
      subject { parser.success? }
      it { is_expected.to eq false }
    end
  end

  context 'when the API returns a response with valid results' do
    let(:response) { read_api_json("success") }
    describe '#status' do
      subject { parser.status }
      it { is_expected.to eq :success }
    end

    describe '#error?' do
      subject { parser.error? }
      it { is_expected.to eq false }
    end

    describe '#no_results?' do
      subject { parser.no_results? }
      it { is_expected.to eq false }
    end

    describe '#results' do
      subject { parser.results }
      it { is_expected.to be_an_instance_of Array }
      it 'handles multiple results' do
        expect(subject.count).to eq 2
      end
    end

    describe '#result' do
      subject { parser.result }
      it { is_expected.to be_an_instance_of Enerscore::Result }
      it 'returns the first result' do
        expect(subject.addressId).to eq response[0]['addressId']
        expect(subject.addressId).to_not eq response[1]['addressId']
      end
    end

    describe '#success' do
      subject { parser.success? }
      it { is_expected.to eq true }
    end
  end

  context 'when the API returns a server error' do
    let(:response) { double(:response, code: 504, data: read_api_file('server_error.html')) }
    describe '#status' do
      subject { parser.status }
      it { is_expected.to eq :server_error }
    end

    describe '#error?' do
      subject { parser.error? }
      it { is_expected.to eq false }
    end

    describe '#no_results?' do
      subject { parser.no_results? }
      it { is_expected.to eq false }
    end

    describe '#results' do
      subject { parser.results }
      it { is_expected.to be_nil }
    end

    describe '#result' do
      subject { parser.result }
      it { is_expected.to be_nil }
    end

    describe '#success' do
      subject { parser.success? }
      it { is_expected.to eq false }
    end
  end

  context 'when the API returns a hash with unexpected values' do
    subject { parser }
    let(:response) {  read_api_json("unhandled_hash") }
    it 'raises an error' do
      expect { subject }.to raise_error 'Unhandled hash request from Enerscore API'
    end
  end

  context 'when the API returns with unexpected values' do
    subject { parser }
    let(:response) { "randomString" }
    it 'raises an error' do
      expect { subject }.to raise_error 'Unhandled request type from Enerscore API'
    end
  end
end
