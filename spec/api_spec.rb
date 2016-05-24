require 'spec_helper'

describe Enerscore::Api do
  describe '#fetch' do
    subject { Enerscore::Api.new.fetch address }
    context 'when an enerscore report is available for the address' do
      let(:address) { '1409 Cold Canyon Rd, Calabasas, CA, 91302' }
      it 'returns the results' do
        expect(subject.address1).to eq '1409 COLD CANYON RD'
      end

      it { is_expected.to be_an_instance_of(Enerscore::Result) }
    end

    context 'when an enerscore report is not available for the address' do
      let(:address) { '729 6th St NW, Washington, DC, 20001' }
      it { is_expected.to be_nil }
    end

    context 'when an enerscore report is not available for an incomplete address' do
      let(:address) { 'New York, NY, USA' }
      it { is_expected.to be_nil }
    end
  end
end
