require 'spec_helper'

RSpec.describe Enerscore::ResponseParser do

  def read_api_json(name)
    JSON.parse(File.read("spec/fixtures/api/#{name}.json"))
  end

  let(:parser) { Enerscore::ResponseParser.new json }

  context 'when the API returns an error' do
    let(:json) { read_api_json("error") }
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

  context 'when the API returns a response with no results' do
    let(:json) { read_api_json("no_results") }
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
    let(:json) { read_api_json("success") }
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
        expect(subject.addressId).to eq json[0]['addressId']
        expect(subject.addressId).to_not eq json[1]['addressId']
      end
    end

    describe '#success' do
      subject { parser.success? }
      it { is_expected.to eq true }
    end
  end

  context 'when the API returns a hash with unexpected values' do
    subject { parser }
    let(:json) {  read_api_json("unhandled_hash") }
    it 'raises an error' do
      expect { subject }.to raise_error 'Unhandled hash request from Enerscore API'
    end
  end

  context 'when the API returns with unexpected values' do
    subject { parser }
    let(:json) { "randomString" }
    it 'raises an error' do
      expect { subject }.to raise_error 'Unhandled request type from Enerscore API'
    end
  end
end
