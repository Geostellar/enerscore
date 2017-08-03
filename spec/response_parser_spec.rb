require 'spec_helper'

RSpec.describe Enerscore::ResponseParser do

  def read_api_json(name)
    read_api_file("#{name}.json")
  end

  def read_api_file(name)
    File.read "spec/fixtures/api/#{name}"
  end

  let(:parser) { Enerscore::ResponseParser.new response }

  context 'when the API returns with a network timeout' do
    let(:response) { :network_timeout }
    describe '#status' do
      subject { parser.status }
      it { is_expected.to eq :network_timeout }
    end

    describe '#result' do
      subject { parser.result }
      it { is_expected.to be_nil }
    end
  end

  context 'when the API returns a response with no results' do
    let(:response) { read_api_json("no_results") }
    describe '#status' do
      subject { parser.status }
      it { is_expected.to eq :success }
    end

    describe '#result' do
      subject { parser.result }
      it { is_expected.to be_nil }
    end
  end

  context 'when the API returns a response with valid results' do
    let(:response) { read_api_json("success") }
    describe '#status' do
      subject { parser.status }
      it { is_expected.to eq :success }
    end

    describe '#result' do
      subject { parser.result }
      it { is_expected.to be_an_instance_of Enerscore::Result }
      it 'returns the first result' do
        json_response = JSON.parse(response)
        expect(subject.obiId).to eq json_response['_embedded']['addresses'][0]['obiId']
        expect(subject.obiId).to_not eq json_response['_embedded']['addresses'][1]['obiId']
      end
    end
  end

  context 'when the API returns a server error' do
    let(:response) { double(:response, code: 504, data: read_api_file('server_error.html')) }
    describe '#status' do
      subject { parser.status }
      it { is_expected.to eq :server_error }
    end

    describe '#result' do
      subject { parser.result }
      it { is_expected.to be_nil }
    end
  end
end
