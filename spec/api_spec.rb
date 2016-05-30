require 'spec_helper'

describe Enerscore::Api do
  let(:api) { Enerscore::Api.new(cache_store) }
  let(:cache_store) { nil }

  describe '#fetch' do
    subject { api.fetch address }
    context 'when a cache is not present' do
      before { expect(cache_store).to be_nil }
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

    context 'when a cache is present' do
      subject { api.fetch address }
      let(:cache_store) { Redis.new }
      context 'when the value is previously cached' do
        before { api.fetch address }

        context 'when an enerscore report is available for the address' do
          let(:address) { '1409 Cold Canyon Rd, Calabasas, CA, 91302' }
          it 'returns the results' do
            expect(subject.address1).to eq '1409 COLD CANYON RD'
          end

          it { is_expected.to be_an_instance_of(Enerscore::Result) }

          it 'does not make a network request' do
            expect(Enerscore::Api).to_not receive(:get)
            subject
          end
        end

        context 'when an enerscore report is not available for the address' do
          let(:address) { '729 6th St NW, Washington, DC, 20001' }
          it { is_expected.to be_nil }

          it 'does not make a network request' do
            expect(Enerscore::Api).to_not receive(:get)
            subject
          end
        end

        context 'when an enerscore report is not available for an incomplete address' do
          let(:address) { 'New York, NY, USA' }
          it { is_expected.to be_nil }

          it 'does not make a network request' do
            expect(Enerscore::Api).to_not receive(:get)
            subject
          end
        end
      end

      context 'when the value is not previously cached' do
        subject { api.fetch address }
        context 'when an enerscore report is available for the address' do
          let(:address) { '1409 Cold Canyon Rd, Calabasas, CA, 91302' }
          it 'returns the results' do
            expect(subject.address1).to eq '1409 COLD CANYON RD'
          end

          it 'caches the result' do
            expect(cache_store.keys).to be_empty
            subject
            key = cache_store.keys[0]
            expect(cache_store.get(key)).to include '1409 COLD CANYON'
          end

          it { is_expected.to be_an_instance_of(Enerscore::Result) }
        end

        context 'when an enerscore report is not available for the address' do
          let(:address) { '729 6th St NW, Washington, DC, 20001' }
          it { is_expected.to be_nil }

          it 'caches the result' do
            expect(cache_store.keys).to be_empty
            subject
            key = cache_store.keys[0]
            expect(cache_store.get(key)).to_not be_nil
          end
        end

        context 'when an enerscore report is not available for an incomplete address' do
          let(:address) { 'New York, NY, USA' }
          it { is_expected.to be_nil }

          it 'caches the result' do
            expect(cache_store.keys).to be_empty
            subject
            key = cache_store.keys[0]
            expect(cache_store.get(key)).to_not be_nil
          end
        end
      end
    end
  end

  describe '#pre_cache' do
    subject { api.pre_cache address, value }
    let(:address) { 'test_address' }
    let(:value) { { 'test' => 'object' } }
    context 'when a cache is present' do
      let(:cache_store) { Redis.new }
      it 'caches the value 'do
        subject
        key = cache_store.keys[0]
        expect(cache_store.get(key)).to eq value.to_json
      end
    end

    context 'when a cache is not present' do
      it 'raises an error' do
        expect{ subject }.to raise_error 'No cache present'
      end
    end
  end
end
